#!/bin/bash
cd openwrt

# 1. 添加第三方插件源 (示例：Passwall)
# 编辑 feeds.conf.default 文件，或在脚本中添加
echo 'src-git passwall https://github.com/xiaorouji/openwrt-passwall;lede-x86' >> feeds.conf.default

# 2. 再次更新并安装所有 feeds (包括第三方)
./scripts/feeds update -a
./scripts/feeds install -a

# 3. 手动添加 Argon 主题
git clone https://github.com/jerrykuku/luci-theme-argon package/luci-theme-argon

# 4. 安装编译所需工具（如ethtool）的包定义（如果需要从源码编译）
# 通常直接在后缀的 .config 文件中选中即可
