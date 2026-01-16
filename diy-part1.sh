#!/bin/bash

# DIY 脚本第一部分 - 编译前执行

echo "========== DIY Part 1 Start =========="

# 首先备份原始的 feeds.conf.default
if [ -f feeds.conf.default ]; then
    mv feeds.conf.default feeds.conf.default.backup
fi

# 创建新的 feeds.conf.default
cat > feeds.conf.default << 'EOF'
src-git packages https://github.com/immortalwrt/packages.git;openwrt-23.05
src-git luci https://github.com/immortalwrt/luci.git;openwrt-23.05
src-git routing https://github.com/openwrt/routing.git;openwrt-23.05
src-git telephony https://github.com/openwrt/telephony.git;openwrt-23.05
EOF

# 添加第三方软件源
echo "添加第三方软件源..."

# 创建第三方包目录
mkdir -p package/thirdparty

# 添加 OpenClash
if [ ! -d "package/thirdparty/luci-app-openclash" ]; then
    git clone --depth=1 https://github.com/vernesong/OpenClash.git package/thirdparty/luci-app-openclash
fi

# 添加 PassWall
if [ ! -d "package/thirdparty/passwall" ]; then
    git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall.git package/thirdparty/passwall
fi

if [ ! -d "package/thirdparty/passwall2" ]; then
    git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall2.git package/thirdparty/passwall2
fi

# 添加 Argon 主题
if [ ! -d "package/thirdparty/luci-theme-argon" ]; then
    git clone --depth=1 https://github.com/jerrykuku/luci-theme-argon.git package/thirdparty/luci-theme-argon
fi

if [ ! -d "package/thirdparty/luci-app-argon-config" ]; then
    git clone --depth=1 https://github.com/jerrykuku/luci-app-argon-config.git package/thirdparty/luci-app-argon-config
fi

# 添加 OpenAppFilter 应用过滤
if [ ! -d "package/thirdparty/luci-app-openappfilter" ]; then
    git clone --depth=1 https://github.com/destan19/OpenAppFilter.git package/thirdparty/luci-app-openappfilter
fi

# 创建符号链接，将第三方包链接到 package 目录
for dir in package/thirdparty/*; do
    if [ -d "$dir" ]; then
        base_name=$(basename $dir)
        if [ ! -L "package/$base_name" ] && [ ! -d "package/$base_name" ]; then
            ln -s ../thirdparty/$base_name package/
        fi
    fi
done

echo "========== DIY Part 1 Complete =========="
