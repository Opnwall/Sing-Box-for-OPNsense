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

# 添加tun接口
log "$YELLOW" "添加 tun_3000 接口..."
sleep 1
if grep -q "<if>tun_3000</if>" "$CONFIG_FILE"; then
  echo "存在同名接口，忽略"
else
  awk '
  BEGIN { inserted = 0 }
  {
    print
    if ($0 ~ /<\/lo0>/ && inserted == 0) {
      print "    <opt10>"
      print "      <enable>1</enable>"
      print "      <lock>1</lock>"
      print "      <descr>TUN</descr>"
      print "      <if>tun_3000</if>"
      print "      <ipaddr>172.19.0.2</ipaddr>"
      print "      <subnet>30</subnet>"
      print "      <gateway>TUN_GW</gateway>"
      print "    </opt10>"
      inserted = 1
    }
  }
  ' "$CONFIG_FILE" > "$TMP_FILE" && mv "$TMP_FILE" "$CONFIG_FILE"
  echo "接口添加完成"
fi
echo ""

# 添加tun网关
log "$YELLOW" "添加 TUN_GW 网关..."
sleep 1
if grep -q "<name>TUN_GW</name>" "$CONFIG_FILE"; then
  echo "存在同名网关，忽略"
else
  awk '
  BEGIN { inserted = 0 }
  /<Gateways>/ {
    print
    next
  }
  /<\/Gateways>/ && inserted == 0 {
    print "      <gateway_item uuid=\"6639b95f-ee46-423c-b9ab-f042653cd41b\">"
    print "        <interface>opt10</interface>"
    print "        <gateway>172.19.0.1</gateway>"
    print "        <name>TUN_GW</name>"
    print "        <ipprotocol>inet</ipprotocol>"
    print "        <descr></descr>"
    print "        <defaultgw>0</defaultgw>"
    print "        <monitor_disable>1</monitor_disable>"
    print "        <disabled>0</disabled>"
    print "      </gateway_item>"
    inserted = 1
  }
  { print }
  ' "$CONFIG_FILE" > "$TMP_FILE" && mv "$TMP_FILE" "$CONFIG_FILE"
  echo "网关添加完成"
fi
echo ""

# 添加防火墙规则（将流量导入TUN_GW）
log "$YELLOW" "添加分流规则..."
if grep -q "c0398153-597b-403b-9069-734734b46497" "$CONFIG_FILE"; then
  echo "存在同名规则，忽略"
  echo ""
else
  awk '
  /<filter>/ {
    print
    print "    <rule uuid=\"c0398153-597b-403b-9069-734734b46497\">"
    print "      <type>pass</type>"
    print "      <interface>lan</interface>"
    print "      <ipprotocol>inet</ipprotocol>"
    print "      <statetype>keep state</statetype>"
    print "      <gateway>TUN_GW</gateway>"
    print "      <direction>in</direction>"
    print "      <floating>yes</floating>"
    print "      <quick>1</quick>"
    print "      <source>"
    print "        <network>lan</network>"
    print "      </source>"
    print "      <destination>"
    print "        <any>1</any>"
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
log "$YELLOW" "重启所有服务，请稍等..."
/usr/local/etc/rc.reload_all >/dev/null 2>&1
echo "所有服务已重新加载！"
echo ""

# 完成提示
log "$GREEN" "安装完毕，请刷新浏览器，导航到VPN > Sing-Box 菜单进行配置。"
echo ""