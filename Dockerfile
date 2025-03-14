FROM nvidia/cuda:12.4.0-devel-ubuntu22.04

WORKDIR /app

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    python3.11 \
    python3.11-dev \
    python3-pip \
    poppler-utils \
    fonts-crosextra-caladea \
    fonts-crosextra-carlito \
    gsfonts \
    lcdf-typetools \
    ttf-mscorefonts-installer \
    msttcorefonts \
    git \
    wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 设置Python环境
RUN ln -sf /usr/bin/python3.11 /usr/bin/python3 && \
    ln -sf /usr/bin/python3 /usr/bin/python

# 复制项目文件
COPY . /app/

# 安装GPU依赖
RUN pip3 install --no-cache-dir --upgrade pip && \
    pip3 install --no-cache-dir -e .[gpu] --find-links https://flashinfer.ai/whl/cu124/torch2.4/flashinfer/

# 设置工作目录
RUN mkdir -p /data/workspace

# 设置环境变量
ENV PYTHONPATH=/app

# 设置容器入口命令
ENTRYPOINT ["python", "-m", "olmocr.pipeline"]
CMD ["/data/workspace", "--help"] 