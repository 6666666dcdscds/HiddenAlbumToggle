#!/bin/bash

echo "🚀 准备推送到 GitHub..."
echo ""

# 检查是否已经初始化 Git
if [ ! -d ".git" ]; then
    echo "📦 初始化 Git 仓库..."
    git init
    git branch -M main
fi

# 添加所有文件
echo "📝 添加文件..."
git add .

# 提交
echo "💾 提交更改..."
git commit -m "Add GitHub Actions build workflow"

# 提示用户输入仓库地址
echo ""
echo "请输入你的 GitHub 仓库地址（例如：https://github.com/username/repo.git）："
read REPO_URL

if [ -z "$REPO_URL" ]; then
    echo "❌ 错误：仓库地址不能为空"
    exit 1
fi

# 检查是否已经添加了 origin
if git remote | grep -q "origin"; then
    echo "🔄 更新远程仓库地址..."
    git remote set-url origin "$REPO_URL"
else
    echo "➕ 添加远程仓库..."
    git remote add origin "$REPO_URL"
fi

# 推送
echo "⬆️  推送到 GitHub..."
git push -u origin main

echo ""
echo "✅ 完成！"
echo ""
echo "📍 下一步："
echo "1. 访问你的 GitHub 仓库"
echo "2. 点击 'Actions' 标签查看编译进度"
echo "3. 编译完成后在 'Artifacts' 下载 .deb 文件"
echo ""

