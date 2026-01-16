#!/bin/bash

# 解析参数
while [[ $# -gt 0 ]]; do
    case $1 in
        --docker)
            INSTALL_DOCKER="$2"
            shift 2
            ;;
        --store)
            INSTALL_STORE="$2"
            shift 2
            ;;
        --ip)
            MANAGEMENT_IP="$2"
            shift 2
            ;;
        --luci-version)
            LUCI_VERSION="$2"
            shift 2
            ;;
        *)
            shift
            ;;
    esac
done

# 设置默认值
MANAGEMENT_IP=${MANAGEMENT_IP:-192.168.6.1}
LUCI_VERSION=${LUCI_VERSION:-24.10.5}
INSTALL_DOCKER=${INSTALL_DOCKER:-false}
INSTALL_STORE=${INSTALL_STORE:-true}

echo "开始自定义配置..."
echo "管理IP: $MANAGEMENT_IP"
echo "Luci版本: $LUCI_VERSION"
echo "安装Docker: $INSTALL_DOCKER"
echo "安装商店: $INSTALL_STORE"

# 创建文件系统覆盖
mkdir -p files/etc/uci-defaults

# 设置管理IP（仅多网口设备）
cat > files/etc/uci-defaults/99-set-network << EOF
#!/bin/sh

# 检查网口数量
ETH_COUNT=\$(ls -1 /sys/class/net/ | grep -E '^eth[0-9]+$' | wc -l)

if [ "\$ETH_COUNT" -gt 1 ]; then
    # 多网口设备，设置固定IP
    echo "多网口设备，设置固定IP: $MANAGEMENT_IP"
    uci set network.lan.ipaddr='$MANAGEMENT_IP'
    uci set network.lan.proto='static'
    uci set network.lan.netmask='255.255.255.0'
    uci commit network
else
    # 单网口设备，使用DHCP
    echo "单网口设备，使用DHCP自动获取IP"
    uci set network.lan.proto='dhcp'
    uci commit network
fi

exit 0
EOF

chmod +x files/etc/uci-defaults/99-set-network

# 根据Luci版本调整 feeds.conf.default
if [ -f feeds.conf.default.backup ]; then
    cp feeds.conf.default.backup feeds.conf.default
fi

case $LUCI_VERSION in
    "22.03")
        echo "使用 Luci 22.03 分支"
        sed -i 's/openwrt-23.05/master/g' feeds.conf.default
        ;;
    "master")
        echo "使用 Luci master 分支"
        sed -i 's/openwrt-23.05/master/g' feeds.conf.default
        ;;
    *)
        echo "使用默认 Luci 版本"
        ;;
esac

# 添加应用商店
if [ "$INSTALL_STORE" = "true" ]; then
    echo "添加应用商店支持"
    if [ ! -d "package/thirdparty/luci-app-store" ]; then
        git clone --depth=1 https://github.com/linkease/istore.git package/thirdparty/istore
        # 创建符号链接
        if [ ! -L "package/luci-app-store" ] && [ ! -d "package/luci-app-store" ]; then
            ln -s ../thirdparty/istore/luci/luci-app-store package/
        fi
        if [ ! -L "package/luci-lib-xterm" ] && [ ! -d "package/luci-lib-xterm" ]; then
            ln -s ../thirdparty/istore/luci/luci-lib-xterm package/
        fi
    fi
    
    # 在 .config 中添加应用商店
    echo "CONFIG_PACKAGE_luci-app-store=y" >> .config
    echo "CONFIG_PACKAGE_luci-lib-xterm=y" >> .config
fi

echo "自定义配置完成！"
