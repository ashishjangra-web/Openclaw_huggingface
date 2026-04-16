FROM node:24-bookworm-slim

WORKDIR /app

# ---------------------------------------------------------------------------
# 1. System Dependencies (single layer, fully cleaned)
# ---------------------------------------------------------------------------
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        git \
        wget \
        bash \
        ca-certificates \
        fontconfig \
        python3 \
        python3-pip \
        ffmpeg \
        libreoffice \
        poppler-utils \
        ghostscript \
        chromium \
        fonts-dejavu \
        fonts-liberation \
        fonts-noto-core \
        fonts-noto-extra \
        fonts-noto-cjk \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# ---------------------------------------------------------------------------
# 2. Python Libraries (explicit error on failure)
# ---------------------------------------------------------------------------
RUN python3 -m pip install --no-cache-dir --default-timeout=120 \
        python-docx \
        python-pptx \
        openpyxl \
        xlsxwriter \
        pandas \
        fpdf2 \
        reportlab \
        pydub \
        pdf2image \
        edge-tts \
        --break-system-packages \
    && python3 -c "import docx, pptx, openpyxl, xlsxwriter, pandas, fpdf, reportlab, pydub, pdf2image, edge_tts; print('[BUILD] Python libs verified OK')"

# Install OpenClaw CLI + Playwright
#
# Note: `playwright install --with-deps chromium` pulls any extra OS libs
# Playwright needs for headless Chromium in Debian.
RUN npm install -g openclaw@latest playwright@latest \
    && playwright install --with-deps chromium

# App files
COPY entrypoint.sh /app/entrypoint.sh
# Normalize Windows CRLF -> Unix LF (HF sometimes checks out CRLF)
RUN sed -i 's/\r$//' /app/entrypoint.sh && chmod +x /app/entrypoint.sh

# Workspace + git env (memory repo)
ENV OPENCLAW_WORKSPACE=/workspace

RUN mkdir -p /workspace

EXPOSE 7860

CMD ["bash", "/app/entrypoint.sh"]

