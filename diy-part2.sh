#!/bin/bash
# DIY 脚本第二部分 - 在更新 feeds 后、编译前运行
# 位置：你的仓库根目录

echo "开始执行第二阶段自定义配置..."

# 1. 手动添加 Argon 主题（确保使用最新版）
echo "添加 Argon 主题..."
if [ ! -d "package/luci-theme-argon" ]; then
  git clone --depth=1 https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon
fi

# 2. 可选：添加其他主题或插件（如果 feeds 中没有）
# git clone --depth=1 https://github.com/LuttyYang/luci-theme-material.git package/luci-theme-material

# 3. 为 Dockerman 安装必要依赖
# ./scripts/feeds install -a

# 4. 应用千兆网络优化配置（内核参数等）
echo "应用内核优化参数..."
cat >> package/kernel/linux/files/sysctl.conf << EOF
# 千兆网络优化
net.core.default_qdisc=fq_codel
net.ipv4.tcp_congestion_control=bbr
# 增强 TCP 性能
net.ipv4.tcp_fastopen=3
net.ipv4.tcp_syncookies=1
net.ipv4.tcp_tw_reuse=1
net.ipv4.tcp_fin_timeout=30
# SYN Flood 防护
net.ipv4.tcp_syncookies=1
net.ipv4.tcp_max_syn_backlog=8192
net.ipv4.tcp_synack_retries=2
EOF

echo "第二阶段自定义配置完成！"
