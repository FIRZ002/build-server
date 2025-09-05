FROM node:18-slim

# 安装必要的系统依赖（用于camoufox浏览器）
RUN apt-get update && apt-get install -y \
    wget \
    fonts-liberation \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libatspi2.0-0 \
    libcups2 \
    libdbus-1-3 \
    libdrm2 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libx11-xcb1 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxrandr2 \
    libxss1 \
    libxtst6 \
    xvfb \
    && rm -rf /var/lib/apt/lists/*

# 创建用户目录
RUN useradd -m -s /bin/bash user
WORKDIR /home/user

# 安装依赖
COPY package*.json ./
RUN npm install

# 复制应用文件
COPY unified-server.js dark-browser.js ./
COPY auth/ ./auth/
# --- 诊断专用代码块 ---

# 设置一个变量来存储下载链接
ARG CAMOUFOX_URL="https://github.com/daijro/camoufox/releases/download/v135.0.1-beta.24/camoufox-135.0.1-beta.24-lin.x86_64.zip"

# 安装下载和解压工具
RUN apt-get update && apt-get install -y wget unzip file

# 1. 创建并进入工作目录
WORKDIR /home/user/camoufox
RUN echo "--- 当前工作目录: $(pwd) ---"

# 2. 下载文件
RUN echo "--- 开始下载文件 ---" && \
    wget -O camoufox.zip ${CAMOUFOX_URL}
RUN echo "--- 文件下载完成 ---"

# 3. 检查下载的文件信息（关键诊断步骤）
RUN echo "--- 检查文件大小和类型 ---" && \
    ls -lh camoufox.zip && \
    file camoufox.zip

# 4. 尝试解压文件
RUN echo "--- 尝试解压文件 ---" && \
    unzip camoufox.zip

# 5. 清理工作
RUN echo "--- 清理安装包 ---" && \
    rm camoufox.zip

# 操作完成后，返回上一级目录
WORKDIR /home/user
RUN echo "--- 构建步骤完成 ---"
# 设置文件权限和camoufox可执行权限
RUN chown -R user:user /home/user && \
    chmod +x /home/user/camoufox-linux/camoufox

# 切换到user用户
USER user

# 暴露端口
EXPOSE 8889

# 启动命令
CMD ["node", "unified-server.js"]




