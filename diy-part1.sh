#!/bin/bash
# DIY 脚本第一部分 - 在更新 feeds 前运行
# 位置：你的仓库根目录

echo "开始执行第一阶段自定义配置..."
# 1. 修改默认管理 IP 为 192.168.6.1
sed -i 's/192.168.1.1/192.168.6.1/g' package/base-files/files/bin/config_generate
# 2. 修改主机名
sed -i "s/hostname='OpenWrt'/hostname='ImmortalWrt-X86'/g" package/base-files/files/bin/config_generate
# 3. 设置时区
sed -i "s/timezone='UTC'/timezone='CST-8'/g" package/base-files/files/bin/config_generate
sed -i "/timezone='CST-8'/a\ \ \ \ \ \ \ \ set system.@system[-1].zonename='Asia/Shanghai'" package/base-files/files/bin/config_generate
# 4. 可选：添加第三方插件源到 feeds.conf.default
# 由于我们要编译的插件较多，建议在此添加必要的第三方源
# 例如 Passwall 的源（注意：可能导致依赖冲突）
echo "src-git passwall https://github.com/xiaorouji/openwrt-passwall;packages" >> feeds.conf.default
echo "src-git passwall2 https://github.com/xiaorouji/openwrt-passwall2;main" >> feeds.conf.default

echo "第一阶段自定义配置完成！"
