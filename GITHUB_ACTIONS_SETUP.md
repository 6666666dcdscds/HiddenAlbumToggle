# 🎯 GitHub Actions 自动编译完整指南

## 📋 前置要求

1. ✅ GitHub 账号
2. ✅ Git 已安装（检查：在终端运行 `git --version`）
3. ✅ 项目文件已准备好

---

## 🚀 步骤 1：创建 GitHub 仓库

### 方法 A：通过网页创建

1. 访问 https://github.com/new
2. 填写仓库信息：
   - **Repository name**: `HiddenAlbumToggle`（或你喜欢的名字）
   - **Description**: `iOS 控制中心隐藏相簿切换插件`
   - **Public/Private**: 选择公开或私有
   - ⚠️ **不要勾选** "Add a README file"
   - ⚠️ **不要勾选** "Add .gitignore"
   - ⚠️ **不要勾选** "Choose a license"
3. 点击 **"Create repository"**
4. 复制仓库地址（例如：`https://github.com/username/HiddenAlbumToggle.git`）

---

## 🚀 步骤 2：推送代码到 GitHub

### 方法 A：使用自动脚本（推荐）

#### Windows 用户：

1. 双击运行 `push-to-github.bat`
2. 按提示输入你的 GitHub 仓库地址
3. 等待推送完成

#### Linux/WSL 用户：

```bash
cd /mnt/c/Users/Administrator/Desktop/插件
chmod +x push-to-github.sh
./push-to-github.sh
```

### 方法 B：手动执行命令

```bash
# 进入项目目录
cd /mnt/c/Users/Administrator/Desktop/插件

# 初始化 Git 仓库
git init
git branch -M main

# 添加所有文件
git add .

# 提交
git commit -m "Initial commit: Hidden Album Toggle with GitHub Actions"

# 添加远程仓库（替换成你的仓库地址）
git remote add origin https://github.com/你的用户名/HiddenAlbumToggle.git

# 推送
git push -u origin main
```

---

## 🚀 步骤 3：查看自动编译

1. 访问你的 GitHub 仓库页面
2. 点击顶部的 **"Actions"** 标签
3. 你会看到一个正在运行的工作流：**"Build iOS Tweak"**
4. 点击进入查看详细日志

### 编译过程（约 2-5 分钟）：

- ✅ Checkout（检出代码）
- ✅ Setup Theos（安装 THEOS）
- ✅ Build Package（编译插件）
- ✅ Upload Artifact（上传产物）

---

## 🚀 步骤 4：下载编译好的 .deb 文件

### 编译成功后：

1. 在 Actions 页面，点击最新的成功运行（绿色✅）
2. 滚动到页面底部，找到 **"Artifacts"** 部分
3. 点击 **"HiddenAlbumToggle-deb"** 下载
4. 解压 ZIP 文件，得到 `.deb` 安装包

---

## 🎉 步骤 5：安装到 iOS 设备

### 方法 1：使用 Filza

1. 将 `.deb` 文件传输到 iOS 设备（通过 AirDrop、iCloud 等）
2. 使用 Filza 打开 `.deb` 文件
3. 点击右上角 **"安装"**
4. 安装完成后重启 SpringBoard

### 方法 2：使用 SSH

```bash
# 将 .deb 传输到设备
scp packages/*.deb root@你的设备IP:/var/root/

# SSH 连接到设备
ssh root@你的设备IP

# 安装
dpkg -i /var/root/*.deb

# 重启 SpringBoard
killall -9 SpringBoard
```

---

## 🏷️ 创建正式发布版本（可选）

如果你想创建一个正式的 Release：

```bash
# 创建标签
git tag v1.0.0

# 推送标签
git push origin v1.0.0
```

GitHub Actions 会自动：
1. 编译插件
2. 创建 Release
3. 附加 `.deb` 文件到 Release

---

## 🔄 后续更新

当你修改代码后：

```bash
# 添加更改
git add .

# 提交
git commit -m "描述你的更改"

# 推送
git push
```

每次推送都会自动触发编译！

---

## 🐛 常见问题

### Q: 编译失败怎么办？

**A:** 点击失败的工作流，查看详细日志，通常会显示具体错误信息。

### Q: 无法推送到 GitHub？

**A:** 检查：
- Git 是否已安装
- 仓库地址是否正确
- 是否有权限（可能需要配置 SSH 密钥或 Personal Access Token）

### Q: 如何手动触发编译？

**A:** 
1. 访问仓库的 Actions 页面
2. 选择 "Build iOS Tweak" 工作流
3. 点击 "Run workflow" 按钮

### Q: Artifacts 保存多久？

**A:** GitHub 默认保存 90 天，之后会自动删除。

---

## 📞 需要帮助？

如果遇到问题：
1. 检查 GitHub Actions 日志
2. 确认所有文件都已正确推送
3. 验证 Makefile 和 control 文件格式

---

## ✨ 优势

使用 GitHub Actions 的好处：

- ✅ 无需本地安装 THEOS
- ✅ 无需下载 iOS SDK
- ✅ 跨平台（Windows/Mac/Linux 都可以）
- ✅ 自动化编译
- ✅ 版本控制
- ✅ 免费（公开仓库）

---

**祝你编译顺利！** 🎉

