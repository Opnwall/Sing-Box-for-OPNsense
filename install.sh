#!/bin/bash

echo -e ''
echo -e "\033[32m========Sing-Box for OPNsense一键安装脚本=========\033[0m"
echo -e ''

# 定义颜色变量
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
CYAN="\033[36m"
RESET="\033[0m"

# 定义目录变量
ROOT="/usr/local"
BIN_DIR="$ROOT/bin"
WWW_DIR="$ROOT/www"
CONF_DIR="$ROOT/etc"
MENU_DIR="$ROOT/opnsense/mvc/app/models/OPNsense"
RC_DIR="$ROOT/etc/rc.d"
PLUGINS="$ROOT/etc/inc/plugins.inc.d"
ACTIONS="$ROOT/opnsense/service/conf/actions.d"
RC_CONF="/etc/rc.conf.d/"
CONFIG_FILE="/conf/config.xml"
TMP_FILE="/tmp/config.xml.tmp"
TIMESTAMP=$(date +%F-%H%M%S)
BACKUP_FILE="/conf/config.xml.bak.$TIMESTAMP"

# 定义日志函数
log() {
    local color="$1"
    local message="$2"
    echo -e "${color}${message}${RESET}"
}

# 创建目录
log "$YELLOW" "创建目录..."
sleep 1
mkdir -p "$CONF_DIR/sing-box" || log "$RED" "目录创建失败！"

# 复制文件
log "$YELLOW" "复制文件..."
sleep 1
log "$YELLOW" "生成菜单..."
# 删除菜单缓存
rm -f /tmp/opnsense_menu_cache.xml
rm -f /tmp/opnsense_acl_cache.json
sleep 1
log "$YELLOW" "生成服务..."
sleep 1
log "$YELLOW" "添加权限..."
sleep 1
chmod +x bin/*
chmod +x rc.d/*
cp -f bin/* "$BIN_DIR/" || log "$RED" "bin 文件复制失败！"
cp -f www/* "$WWW_DIR/" || log "$RED" "www 文件复制失败！"
cp -f rc.d/* "$RC_DIR/" || log "$RED" "rc.d 文件复制失败！"
cp -R -f menu/* "$MENU_DIR/" || log "$RED" "menu 文件复制失败！"
cp -f rc.conf/* "$RC_CONF/" || log "$RED" "rc.conf 文件复制失败！"
cp -f plugins/* "$PLUGINS/" || log "$RED" "plugins 文件复制失败！"
cp -f actions/* "$ACTIONS/" || log "$RED" "actions 文件复制失败！"
cp -f conf/* "$CONF_DIR/sing-box/" || log "$RED" "sing-box 配置文件复制失败！"


# 启动Tun接口
log "$YELLOW" "启动sing-box..."
service singbox start > /dev/null 2>&1
echo ""

# 备份配置文件
cp "$CONFIG_FILE" "$BACKUP_FILE" || {
  echo "配置备份失败，终止操作！"
  echo ""
  exit 1
}

# 添加防火墙规则
log "$YELLOW" "添加分流规则..."
RULE_UUID="75588d32-4930-4295-8d70-a19464be233b"
if grep -q "$RULE_UUID" "$CONFIG_FILE"; then
  echo "存在同名规则，忽略"
  echo ""
else
  awk -v rule_uuid="$RULE_UUID" '
  /<filter>/ {
    print
    print "    <rule uuid=\"" rule_uuid "\">"
    print "      <type>pass</type>"
    print "      <interface>lan</interface>"
    print "      <ipprotocol>inet</ipprotocol>"
    print "      <statetype>keep state</statetype>"
    print "      <direction>any</direction>"
    print "      <interfacenot>1</interfacenot>"
    print "      <floating>yes</floating>"
    print "      <quick>1</quick>"
    print "      <protocol>tcp/udp</protocol>"
    print "      <source>"
    print "        <address>172.19.0.0/30</address>"
    print "      </source>"
    print "      <destination>"
    print "        <address>172.19.0.0/30</address>"
    print "      </destination>"
    print "    </rule>"
    next
  }
  { print }
  ' "$CONFIG_FILE" > "$TMP_FILE" && mv "$TMP_FILE" "$CONFIG_FILE"
  echo "规则添加完成"
fi
  echo ""

# 重启所有服务
log "$YELLOW" "重启防火墙..."
/usr/local/etc/rc.filter_configure >/dev/null 2>&1
echo "重启完成！"
echo ""

# 完成提示
log "$GREEN" "安装完毕，请刷新浏览器，导航到VPN > Sing-Box 菜单进行配置。"
echo ""