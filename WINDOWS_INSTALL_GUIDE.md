# Windows 系统安装 Theos 完整指南（小白版）

## 📌 第一步：打开管理员 PowerShell

### 最简单的方法：
1. 按键盘上的 `Win` 键（Windows 图标键）
2. 输入 `powershell`
3. 在搜索结果中，**右键点击** "Windows PowerShell"
4. 选择 **"以管理员身份运行"**
5. 如果弹出提示框，点击 **"是"**

### 验证是否成功：
窗口标题应该显示：`管理员: Windows PowerShell`

---

## 📌 第二步：安装 WSL（Linux 子系统）

在 PowerShell 中输入以下命令：

```powershell
wsl --install
```

**然后按回车键**

### 可能的情况：

#### 情况 A：提示重启
```
请重新启动计算机以完成安装
```
→ **重启电脑**，然后跳到第三步

#### 情况 B：提示已安装
```
适用于 Linux 的 Windows 子系统已安装
```
→ 直接跳到第三步

#### 情况 C：提示错误
如果出现错误，依次执行以下命令：

```powershell
# 命令 1
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart

# 命令 2
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# 命令 3
wsl --set-default-version 2
```

然后**重启电脑**

---

## 📌 第三步：启动 Ubuntu

### 方法 1：自动启动
重启后，Ubuntu 会自动打开一个黑色窗口

### 方法 2：手动启动
1. 按 `Win` 键
2. 输入 `ubuntu`
3. 点击 **Ubuntu** 应用

### 首次设置：
```
Enter new UNIX username: 输入用户名（例如：myname）
New password: 输入密码（输入时不会显示，这是正常的）
Retype new password: 再次输入密码
```

**⚠️ 重要：记住这个密码！后面会用到**

---

## 📌 第四步：安装开发工具

在 Ubuntu 终端中，**复制粘贴**以下命令（一次一行）：

```bash
# 1. 更新软件包列表（可能需要几分钟）
sudo apt update

# 2. 安装基础工具
sudo apt install -y git curl wget build-essential fakeroot rsync libplist-utils perl ldid

# 3. 安装 Python（某些工具需要）
sudo apt install -y python3
```

**提示：**
- 如果要求输入密码，输入第三步设置的密码
- 输入密码时不会显示，这是正常的
- 输入完按回车即可

---

## 📌 第五步：安装 Theos

继续在 Ubuntu 终端中执行：

```bash
# 1. 下载 Theos
sudo git clone --recursive https://github.com/theos/theos.git /opt/theos

# 2. 设置权限
sudo chown -R $(whoami):$(whoami) /opt/theos

# 3. 设置环境变量
echo 'export THEOS=/opt/theos' >> ~/.bashrc
echo 'export PATH=$THEOS/bin:$PATH' >> ~/.bashrc

# 4. 重新加载配置
source ~/.bashrc

# 5. 验证安装
echo $THEOS
```

**如果最后一行显示 `/opt/theos`，说明成功！** ✅

---

## 📌 第六步：安装 iOS SDK

```bash
# 1. 进入 SDK 目录
cd /opt/theos/sdks

# 2. 下载 SDK（选择方法 A 或 B）

# 方法 A：下载所有 SDK（推荐）
sudo git clone https://github.com/theos/sdks.git temp_sdks
sudo mv temp_sdks/*.sdk .
sudo rm -rf temp_sdks

# 方法 B：只下载 iOS 16 SDK
sudo wget https://github.com/theos/sdks/releases/download/master/iPhoneOS16.5.sdk.tar.xz
sudo tar -xf iPhoneOS16.5.sdk.tar.xz
sudo rm iPhoneOS16.5.sdk.tar.xz

# 3. 验证 SDK
ls /opt/theos/sdks
```

**应该能看到类似 `iPhoneOS16.5.sdk` 的文件夹** ✅

---

## 📌 第七步：编译你的插件

### 1. 进入项目目录

在 Ubuntu 终端中：

```bash
# Windows 的 C 盘在 WSL 中的路径是 /mnt/c/
cd /mnt/c/Users/Administrator/Desktop/插件
```

**提示：** 如果路径有中文，可能需要用引号：
```bash
cd "/mnt/c/Users/Administrator/Desktop/插件"
```

### 2. 编译项目

```bash
# 清理旧文件
make clean

# 编译
make

# 打包成 .deb 文件
make package
```

### 3. 查看生成的文件

```bash
ls packages/
```

应该能看到 `.deb` 文件 ✅

---

## 📌 第八步：安装到 iOS 设备

### 方法 A：通过 SSH（推荐）

**前提条件：**
- iOS 设备已越狱
- 已安装 OpenSSH（通过 Cydia/Sileo）
- 设备和电脑在同一 WiFi

**步骤：**

```bash
# 1. 设置设备 IP（替换为你的设备 IP）
export THEOS_DEVICE_IP=192.168.1.100
export THEOS_DEVICE_PORT=22

# 2. 安装
make package install

# 3. 输入密码（默认是 alpine）
```

### 方法 B：手动安装

1. 在 Windows 文件资源管理器中打开：
   ```
   C:\Users\Administrator\Desktop\插件\packages
   ```

2. 找到 `.deb` 文件

3. 通过以下方式传输到 iOS 设备：
   - AirDrop
   - 微信/QQ 文件传输
   - iCloud Drive
   - 数据线 + iTunes

4. 在 iOS 设备上：
   - 使用 **Filza** 打开 `.deb` 文件
   - 点击右上角 **"安装"**
   - 重启 SpringBoard

---

## 🎯 快速检查清单

安装完成后，在 Ubuntu 终端中检查：

```bash
# ✅ 检查 Theos
ls /opt/theos

# ✅ 检查 SDK
ls /opt/theos/sdks

# ✅ 检查环境变量
echo $THEOS

# ✅ 检查 make
which make

# ✅ 检查 git
which git
```

所有命令都应该有输出，没有报错 ✅

---

## ❓ 常见问题

### Q1: Ubuntu 终端关闭后，下次怎么打开？
**A:** 按 `Win` 键，输入 `ubuntu`，点击打开

### Q2: 忘记了 Ubuntu 密码怎么办？
**A:** 在 PowerShell（管理员）中执行：
```powershell
wsl -u root passwd 你的用户名
```

### Q3: 编译时提示 "No such file or directory"
**A:** 检查路径是否正确，中文路径需要加引号

### Q4: make 命令找不到
**A:** 重新执行第四步的安装命令

### Q5: 如何在 Windows 和 WSL 之间复制文件？
**A:** 
- WSL 访问 Windows：`/mnt/c/Users/...`
- Windows 访问 WSL：在文件资源管理器地址栏输入 `\\wsl$\Ubuntu\home\你的用户名`

---

## 📞 需要帮助？

如果遇到任何问题，请：
1. 截图错误信息
2. 告诉我你在哪一步遇到问题
3. 我会帮你解决！

---

## 🎉 成功标志

当你能成功执行 `make package` 并在 `packages/` 目录看到 `.deb` 文件时，说明安装成功！

祝你好运！🚀

