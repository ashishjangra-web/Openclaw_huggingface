---
title: openclaw-Primus
emoji: 🦞
colorFrom: blue
colorTo: indigo
sdk: docker
pinned: false
---

# 🦞 OpenClaw: Autonomous AI Agent Space
### 🚀 Free 24/7 Cloud Version

> [!CAUTION]
> This file is named `README.md` to avoid conflicts with the standard `README.md` required by Hugging Face do not commit this file to hugging face.

> **DO NOT COMMIT SECRETS DIRECTLY TO GITHUB OR HUGGING FACE.**
> Always use the **Settings -> Variables & secrets** dashboard to manage your API keys, tokens, and passwords. Committing secrets to your repository will expose them to the public or Hugging Face logs.

OpenClaw is a premium, autonomous AI agent environment designed to run for **free, 24/7 in the cloud** via Hugging Face Spaces. It leverages the power of multimodal LLMs to browse the web, control interfaces, and maintain a persistent memory across sessions.



## 🚀 Quick Start (Hugging Face Deployment)

1.  **Duplicate this Space** (or push this code to a new Docker Space).
2.  **Configure Secrets**: Go to **Settings -> Variables & secrets** and add the following:

### 🔑 Required Secrets
| Secret | Description |
| :--- | :--- |
| `MODEL_KEY_1` | Primary Google Gemini API Key |
| `MODEL_KEY_2` | Second Gemini Key (for rotation/quota) |
| `MODEL_KEY_3` | Third Gemini Key (for rotation/quota) |
| `MODEL_KEY_4` | Fourth Gemini Key (for rotation/quota) |
| `TELEGRAM_BOT_TOKEN` | Token from @BotFather for your bot |
| `TELEGRAM_ALLOWED_USER_ID` | Your numeric Telegram ID for private access |
| `HF_GITHUB_TOKEN` | GitHub Personal Access Token (for memory sync) |

### 📁 Required Variables
| Variable | Value |
| :--- | :--- |
| `GIT_MEMORY_REPO` | `https://github.com/<user>/<repo>.git` |
| `MODEL_NAME` | Name of the primary model (e.g., `google/gemini-3.1-flash-lite-preview`) |
| `MODEL_FALLBACK` | Backup model name (default: `openrouter/google/gemma-4-31b-it`) |
| `MODEL_PROVIDER` | Provider of the model (default: `google`) |

#### Example Model Configuration
```bash
# Set your primary engine
MODEL_NAME=google/gemini-3.1-flash-lite-preview

# Set your backup/fallback engine
MODEL_FALLBACK=openrouter/google/gemma-4-31b-it
```

---

## 🌟 Key Features

*   **Multimodal Reasoning**: Uses the **Model of your choice** (Primary) with automated fallback support for secondary providers.
*   **Persistent Memory**: Periodically syncs your agent's workspace to a private GitHub repository every 15 minutes.
*   **Web Navigation**: Built-in support for autonomous browsing via Playwright.
*   **Document Mastery (LibreOffice)**: Integrated with **LibreOffice** for professional automation. The agent can natively create, edit, and convert Word (`.docx`), Excel (`.xlsx`), and PowerPoint (`.pptx`) files.
*   **Media Processing**: Integrated with FFmpeg, Poppler, and Ghostscript for handling video, audio, and documents.
*   **API Rotation**: Automatically rotates through up to 4 keys to maximize your free tier quotas.

---

## 🛠️ Infrastructure Overview

*   **Runtime**: Node.js 24 + Python 3.12 (Debian Bookworm)
*   **Gateway**: OpenClaw Gateway (Port 7860)
*   **Browser**: Headless Chromium
*   **Sync**: Git-based background loop in `entrypoint.sh`

## 💻 Local Development

1.  Copy `.env.example` to `.env`.
2.  Fill in your API keys and repository details.
3.  Build and run with Docker:
    ```bash
    docker build -t openclaw .
    ```
4.  Run the container:
    ```bash
    docker run -p 7860:7860 --env-file .env openclaw
    ```

## 📜 License
This project is for educational and research purposes. Ensure you comply with the Terms of Service for the LLM providers (Google, OpenRouter) and Hugging Face.

---
*Created with ❤️ by the OpenClaw Community.*
