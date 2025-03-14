# olmOCR Docker部署指南

本文档介绍如何使用Docker容器部署和运行olmOCR项目。

## 前提条件

- [Docker](https://www.docker.com/get-started) 已安装
- [Docker Compose](https://docs.docker.com/compose/install/) 已安装
- 如果要使用GPU，请确保安装了[NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html)

## 快速开始

1. 创建输入PDF文件夹：

```bash
mkdir -p input_pdfs
mkdir -p workspace
```

2. 将您需要处理的PDF文件放入`input_pdfs`文件夹中

3. 使用Docker Compose构建并启动容器：

```bash
docker-compose up --build
```

4. 处理结果将保存在`workspace/results`目录中

## 自定义命令

如果您需要使用不同的参数运行olmOCR，可以覆盖docker-compose.yml中的默认命令：

```bash
docker-compose run --rm olmocr /data/workspace --pdfs /data/pdfs/specific_file.pdf
```

## 查看结果

处理完成后，可以使用以下命令查看结果：

```bash
# 首先，启动查看器容器
docker-compose run --rm olmocr python -m olmocr.viewer.dolmaviewer /data/workspace/results/output_*.jsonl
```

然后，查看生成的HTML文件：

```bash
cd workspace/dolma_previews
# 使用您喜欢的浏览器打开相应的HTML文件
```

## 使用提示

- 确保您的PDF文件路径不包含特殊字符
- 对于大型PDF文件，可能需要为容器分配更多内存
- 如果遇到GPU内存不足的错误，尝试在docker-compose.yml中配置GPU内存限制

## 故障排除

1. 如果遇到GPU相关错误，请确认NVIDIA驱动和NVIDIA Container Toolkit已正确安装：

```bash
nvidia-smi
docker run --rm --gpus all nvidia/cuda:12.4.0-base-ubuntu22.04 nvidia-smi
```

2. 如果遇到权限问题，请确保当前用户有权限访问Docker：

```bash
sudo usermod -aG docker $USER
# 重新登录后生效
``` 