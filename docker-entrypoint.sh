#!/bin/bash
set -e

# 启动sglang服务
echo "启动sglang服务..."
python -m sglang.launch_server --host 0.0.0.0 --port 30024 &
SGLANG_PID=$!

# 等待sglang服务启动
echo "等待sglang服务启动..."
for i in {1..30}; do
  if curl -s "http://localhost:30024/v1/models" >/dev/null 2>&1; then
    echo "sglang服务已启动"
    break
  fi
  
  if [ $i -eq 30 ]; then
    echo "sglang服务启动超时，继续执行..."
  fi
  
  echo "等待sglang服务启动 ($i/30)..."
  sleep 1
done

# 检查是否包含通配符
if [[ "$@" == *"*.pdf"* ]]; then
  # 获取所有参数
  args=("$@")
  
  # 寻找--pdfs参数的位置
  for ((i=0; i<${#args[@]}; i++)); do
    if [[ "${args[i]}" == "--pdfs" ]]; then
      # 下一个参数是PDF路径
      pdf_path="${args[i+1]}"
      
      # 检查是否是通配符路径
      if [[ "$pdf_path" == *"*"* ]]; then
        # 替换通配符为具体文件列表
        files=$(ls $pdf_path 2>/dev/null || echo "")
        
        if [ -z "$files" ]; then
          echo "警告: 没有找到匹配的PDF文件: $pdf_path"
          # 如果没有找到文件，传递原始参数
          exec python -m olmocr.pipeline "$@"
        else
          # 构建新的命令，替换通配符为具体文件
          new_args=()
          for ((j=0; j<${#args[@]}; j++)); do
            if [ $j -eq $((i+1)) ]; then
              # 第一个文件
              first_file=$(ls $pdf_path | head -n 1)
              new_args+=("$first_file")
              
              # 添加其余文件
              for file in $(ls $pdf_path | tail -n +2); do
                new_args+=("--pdfs" "$file")
              done
            elif [ $j -ne $((i+1)) ]; then
              # 保留其他参数
              new_args+=("${args[j]}")
            fi
          done
          
          echo "执行命令: python -m olmocr.pipeline ${new_args[@]}"
          exec python -m olmocr.pipeline "${new_args[@]}"
        fi
      fi
      break
    fi
  done
fi

# 如果没有特殊处理，直接执行原始命令
exec python -m olmocr.pipeline "$@" 