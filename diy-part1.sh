# 编译前自定义脚本

#!/bin/bash

# DIY 脚本第一部分 - 编译前执行

echo "========== DIY Part 1 Start =========="

# 添加第三方软件源
echo "添加第三方软件源..."

# 添加 OpenClash
git clone --depth=1 https://github.com/vernesong/OpenClash.git package/luci-app-openclash

# 添加 PassWall
git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall.git package/passwall
git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall2.git package/passwall2

# 添加 Argon 主题
git clone --depth=1 https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon
git clone --depth=1 https://github.com/jerrykuku/luci-app-argon-config.git package/luci-app-argon-config

# 更新 feeds
./scripts/feeds update -a
./scripts/feeds install -a

echo "========== DIY Part 1 Complete =========="
