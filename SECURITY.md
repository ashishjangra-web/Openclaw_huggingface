# Security Policy

## Supported Versions

Only the latest `main` branch version is actively maintained.

## Reporting a Vulnerability

> [!WARNING]
> **DO NOT** report security vulnerabilities via public GitHub issues. 

Please follow these steps to report a vulnerability:
1. Revoke any exposed API keys immediately.
2. If the vulnerability is in the OpenClaw core, please report it to the upstream maintainers.
3. If the vulnerability is specific to this deployment configuration, please use private contact channels.

## Protect Your Secrets
Always use **Hugging Face Secrets** to store `MODEL_KEY_1`, `HF_GITHUB_TOKEN`, etc. Never commit these directly to your repository logs or Dockerfiles.
