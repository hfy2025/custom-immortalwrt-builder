# 自定义脚本

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
    uci set network.lan.ipaddr='$MANAGEMENT_IP'
    uci set network.lan.proto='static'
    uci set network.lan.netmask='255.255.255.0'
    uci commit network
else
    # 单网口设备，使用DHCP
    uci set network.lan.proto='dhcp'
    uci commit network
fi

exit 0
EOF

chmod +x files/etc/uci-defaults/99-set-network

# 根据Luci版本调整
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
    cat >> .config << EOF
CONFIG_PACKAGE_luci-app-store=y
CONFIG_PACKAGE_luci-lib-xterm=y
EOF
fi

echo "自定义配置完成！"
