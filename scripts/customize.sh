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
    echo "多网口设备 (\$ETH_COUNT 个网口)，设置固定IP: $MANAGEMENT_IP"
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
if [ -f feeds.conf.default.bak ]; then
    cp feeds.conf.default.bak feeds.conf.default
fi

# 创建 feeds.conf.default 的备份
cp feeds.conf.default feeds.conf.default.bak

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
        echo "使用默认 Luci 版本 24.10.5"
        ;;
esac

# 添加 Docker 配置
if [ "$INSTALL_DOCKER" = "true" ]; then
    echo "添加 Docker 支持..."
    echo "# Docker 配置" >> .config
    echo "CONFIG_PACKAGE_docker=y" >> .config
    echo "CONFIG_PACKAGE_dockerd=y" >> .config
    echo "CONFIG_PACKAGE_docker-compose=y" >> .config
    echo "CONFIG_PACKAGE_luci-app-dockerman=y" >> .config
    echo "CONFIG_PACKAGE_luci-i18n-dockerman-zh-cn=y" >> .config
    
    # Docker 依赖
    echo "CONFIG_PACKAGE_kmod-veth=y" >> .config
    echo "CONFIG_PACKAGE_kmod-dm=y" >> .config
    echo "CONFIG_PACKAGE_kmod-br-netfilter=y" >> .config
    echo "CONFIG_PACKAGE_kmod-ikconfig=y" >> .config
    echo "CONFIG_PACKAGE_kmod-nf-conntrack-netlink=y" >> .config
    echo "CONFIG_PACKAGE_kmod-nf-ipvs=y" >> .config
    echo "CONFIG_PACKAGE_kmod-nf-nat=y" >> .config
    echo "CONFIG_PACKAGE_kmod-ipt-ipset=y" >> .config
    echo "CONFIG_PACKAGE_kmod-fs-btrfs=y" >> .config
    echo "CONFIG_PACKAGE_kmod-fs-overlay=y" >> .config
    echo "CONFIG_PACKAGE_kmod-dax=y" >> .config
fi

# 添加应用商店
if [ "$INSTALL_STORE" = "true" ]; then
    echo "添加应用商店支持"
    echo "CONFIG_PACKAGE_luci-app-store=y" >> .config
    echo "CONFIG_PACKAGE_luci-lib-xterm=y" >> .config
fi

echo "自定义配置完成！"
