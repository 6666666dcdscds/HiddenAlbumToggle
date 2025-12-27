#!/bin/bash

# HiddenAlbumToggle 自动编译脚本
# 适用于 macOS/Linux

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 打印横幅
print_banner() {
    echo -e "${BLUE}"
    echo "╔════════════════════════════════════════════════╗"
    echo "║   HiddenAlbumToggle 自动编译脚本              ║"
    echo "║   iOS 16 Control Center Module                ║"
    echo "╚════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# 检查 Theos 环境
check_theos() {
    print_info "检查 Theos 环境..."
    
    if [ -z "$THEOS" ]; then
        print_error "THEOS 环境变量未设置！"
        print_info "请设置 THEOS 环境变量，例如："
        echo "  export THEOS=/opt/theos"
        exit 1
    fi
    
    if [ ! -d "$THEOS" ]; then
        print_error "THEOS 目录不存在: $THEOS"
        exit 1
    fi
    
    print_success "Theos 环境检查通过: $THEOS"
}

# 检查 SDK
check_sdk() {
    print_info "检查 iOS SDK..."
    
    SDK_PATH="$THEOS/sdks"
    if [ ! -d "$SDK_PATH" ]; then
        print_warning "SDK 目录不存在，可能会使用默认 SDK"
        return
    fi
    
    SDK_COUNT=$(ls -1 "$SDK_PATH" | grep -i "iPhoneOS" | wc -l)
    if [ "$SDK_COUNT" -eq 0 ]; then
        print_warning "未找到 iOS SDK，编译可能失败"
    else
        print_success "找到 $SDK_COUNT 个 iOS SDK"
        ls -1 "$SDK_PATH" | grep -i "iPhoneOS" | sed 's/^/  - /'
    fi
}

# 清理旧文件
clean_build() {
    print_info "清理旧的编译文件..."
    
    if [ -d ".theos" ]; then
        rm -rf .theos
        print_success "已删除 .theos 目录"
    fi
    
    if [ -d "packages" ]; then
        print_info "保留 packages 目录（旧的 .deb 文件）"
    fi
    
    make clean 2>/dev/null || true
    print_success "清理完成"
}

# 编译项目
compile_project() {
    print_info "开始编译项目..."
    
    if ! make; then
        print_error "编译失败！"
        exit 1
    fi
    
    print_success "编译成功"
}

# 打包 deb
package_deb() {
    print_info "打包 .deb 文件..."
    
    if ! make package; then
        print_error "打包失败！"
        exit 1
    fi
    
    print_success "打包成功"
}

# 显示生成的文件
show_result() {
    print_info "查找生成的 .deb 文件..."
    
    if [ ! -d "packages" ]; then
        print_error "packages 目录不存在！"
        exit 1
    fi
    
    DEB_FILE=$(ls -t packages/*.deb 2>/dev/null | head -n 1)
    
    if [ -z "$DEB_FILE" ]; then
        print_error "未找到 .deb 文件！"
        exit 1
    fi
    
    FILE_SIZE=$(du -h "$DEB_FILE" | cut -f1)
    
    echo ""
    print_success "编译完成！"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}文件路径:${NC} $DEB_FILE"
    echo -e "${BLUE}文件大小:${NC} $FILE_SIZE"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# 询问是否安装
ask_install() {
    echo -e "${YELLOW}是否要安装到设备？${NC} (y/n)"
    read -r response
    
    if [[ "$response" =~ ^[Yy]$ ]]; then
        install_to_device
    else
        print_info "跳过安装"
    fi
}

# 安装到设备
install_to_device() {
    print_info "准备安装到设备..."
    
    if [ -z "$THEOS_DEVICE_IP" ]; then
        echo -e "${YELLOW}请输入设备 IP 地址:${NC}"
        read -r device_ip
        export THEOS_DEVICE_IP="$device_ip"
    fi
    
    if [ -z "$THEOS_DEVICE_PORT" ]; then
        export THEOS_DEVICE_PORT=22
    fi
    
    print_info "目标设备: $THEOS_DEVICE_IP:$THEOS_DEVICE_PORT"
    
    if ! make install; then
        print_error "安装失败！"
        exit 1
    fi
    
    print_success "安装成功！SpringBoard 将自动重启"
}

# 主函数
main() {
    print_banner
    
    # 检查环境
    check_theos
    check_sdk
    
    echo ""
    
    # 编译流程
    clean_build
    echo ""
    
    compile_project
    echo ""
    
    package_deb
    echo ""
    
    show_result
    
    # 询问是否安装
    ask_install
    
    echo ""
    print_success "所有操作完成！"
}

# 运行主函数
main

