#!/usr/bin/env bash
set -eu
set -o pipefail

echo "🦞 OpenClaw Space booting…"
echo "📁 Workspace: ${OPENCLAW_WORKSPACE:-/workspace}"

export OPENCLAW_WORKSPACE=${OPENCLAW_WORKSPACE:-/workspace}
mkdir -p "$OPENCLAW_WORKSPACE"

############################
# 1. Git config + memory repo
############################
git config --global init.defaultBranch main

# Ensure the workspace is writable and visible
mkdir -p "$OPENCLAW_WORKSPACE"
chmod 777 "$OPENCLAW_WORKSPACE"

if [ -n "$GIT_USER_NAME" ]; then
  git config --global user.name "$GIT_USER_NAME"
fi
if [ -n "$GIT_USER_EMAIL" ]; then
  git config --global user.email "$GIT_USER_EMAIL"
fi

IS_PLACEHOLDER_REPO=0
if [ -n "${GIT_MEMORY_REPO:-}" ]; then
  if [[ "${GIT_MEMORY_REPO:-}" == *"<YOUR_"* ]]; then
    IS_PLACEHOLDER_REPO=1
    echo "⚠️ GIT_MEMORY_REPO is still a placeholder. Set it in HF Variables, e.g. https://github.com/<user>/<repo>.git"
  else
    echo "🔗 Memory repo: $GIT_MEMORY_REPO"
  fi
fi

if [ -n "${HF_GITHUB_TOKEN:-}" ] && [ -n "${GIT_MEMORY_REPO:-}" ] && [ "$IS_PLACEHOLDER_REPO" -eq 0 ]; then
  REPO_AUTH=${GIT_MEMORY_REPO/https:\/\/github.com/https://$HF_GITHUB_TOKEN@github.com}

  if [ ! -d "$OPENCLAW_WORKSPACE/.git" ]; then
    echo "🔄 Cloning memory repo into $OPENCLAW_WORKSPACE…"
    git clone "$REPO_AUTH" "$OPENCLAW_WORKSPACE" || {
      echo "⚠️ Clone failed, initializing new repo…"
      mkdir -p "$OPENCLAW_WORKSPACE"
      cd "$OPENCLAW_WORKSPACE"
      git init
      git remote add origin "$REPO_AUTH"
      cd /app
    }
  fi
else
  echo "ℹ️ GitHub sync disabled (missing HF_GITHUB_TOKEN / GIT_MEMORY_REPO, or repo is placeholder)."
fi

############################
# 2. OpenClaw config
############################
echo "🧩 Writing OpenClaw config…"
mkdir -p ~/.openclaw

# Memory Repo logic

TELEGRAM_ENABLED=$( [ -n "${TELEGRAM_BOT_TOKEN:-}" ] && echo "true" || echo "false" )
TELEGRAM_ALLOW_LIST=$( [ -n "${TELEGRAM_ALLOWED_USER_ID:-}" ] && echo "\"${TELEGRAM_ALLOWED_USER_ID}\"" || echo "" )

cat > ~/.openclaw/openclaw.json <<EOF
{
  "gateway": {
    "mode": "local",
    "bind": "lan",
    "controlUi": {
      "allowedOrigins": ["*"]
    }
  },
  "agents": {
    "defaults": {
      "workspace": "$OPENCLAW_WORKSPACE",
      "model": {
        "primary": "${MODEL_NAME:-google/gemini-3.1-flash-lite-preview}",
        "fallbacks": [
          "${MODEL_FALLBACK:-openrouter/google/gemma-4-31b-it}"
        ]
      }
    }
  },
  "channels": {
    "telegram": {
      "enabled": ${TELEGRAM_ENABLED},
      "botToken": "${TELEGRAM_BOT_TOKEN:-}",
      "dmPolicy": "allowlist",
      "allowFrom": [ ${TELEGRAM_ALLOW_LIST} ]
    }
  }
}
EOF

############################
# 3. Gemini auth profiles (4 keys rotated)
############################
echo "🔑 Configuring Gemini auth profiles…"
AUTH_DIR=~/.openclaw/agents/main/agent
mkdir -p "$AUTH_DIR"

AUTH_FILE="$AUTH_DIR/auth-profiles.json"
# Always (re)write on boot so provider/id changes take effect.
if [ -f "$AUTH_FILE" ]; then
  cp "$AUTH_FILE" "$AUTH_FILE.bak" || true
fi

cat > "$AUTH_FILE" <<EOF
{
  "profiles": {
    "model:key1": { "type": "api_key", "provider": "${MODEL_PROVIDER:-google}", "key": "$MODEL_KEY_1" },
    "model:key2": { "type": "api_key", "provider": "${MODEL_PROVIDER:-google}", "key": "$MODEL_KEY_2" },
    "model:key3": { "type": "api_key", "provider": "${MODEL_PROVIDER:-google}", "key": "$MODEL_KEY_3" },
    "model:key4": { "type": "api_key", "provider": "${MODEL_PROVIDER:-google}", "key": "$MODEL_KEY_4" }
  },
  "auth": {
    "order": {
      "${MODEL_PROVIDER:-google}": [
        "model:key1",
        "model:key2",
        "model:key3",
        "model:key4"
      ]
    }
  }
}
EOF

############################
# 4. Start OpenClaw gateway (HF expects port 7860)
############################
# 🚀 Starting OpenClaw gateway on port 7860…
# We use --bind lan and --port 7860 to satisfy Hugging Face network routing.
openclaw gateway --port 7860 --bind lan &
echo "✅ Gateway started on port 7860 (running in background)."

############################
# 5. 15-min memory Git sync loop
############################
while true; do
  if [ -d "$OPENCLAW_WORKSPACE/.git" ]; then
    cd "$OPENCLAW_WORKSPACE"
    git add -A
    if ! git diff --cached --quiet; then
      echo "💾 Syncing OpenClaw memory to GitHub…"
      git commit -m "chore: sync OpenClaw memory"
      git push origin HEAD:main || echo "⚠️ Git push failed (will retry later)"
    else
      echo "🟢 No memory changes to sync."
    fi
    cd /app
  fi
  echo "⏳ Next sync in 15 minutes…"
  sleep 900  # 15 minutes
done

