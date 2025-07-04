#!/bin/bash

echo -e ''
echo -e "\033[32m========Sing-box for OPNsense 一键卸载脚本=========\033[0m"
echo -e ''

# 定义颜色变量
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
RESET="\033[0m"

# 定义日志函数
log() {
    local color="$1"
    local message="$2"
    echo -e "${color}${message}${RESET}"
}

# 删除程序和配置
log "$YELLOW" "删除代理程序和配置，请稍等..."

# 停止服务
service singbox stop > /dev/null 2>&1

# 删除配置
rm -rf /usr/local/etc/sing-box

# 删除rc.d
rm -f /usr/local/etc/rc.d/sing-box

# 删除rc.conf
rm -f /etc/rc.conf.d/sing-box

# 删除action
rm -f /usr/local/opnsense/service/conf/actions.d/actions_sing-box.conf

# 删除inc
rm -f /usr/local/etc/inc/plugins.inc.d/sing_box.inc

# 删除php
rm -f /usr/local/www/services_sing_box.php
rm -f /usr/local/www/status_sing_box_logs.php
rm -f /usr/local/www/status_sing_box.php
rm -f /usr/local/www/services_sub.php
rm -f /usr/bin/sub


# 删除程序
rm -f /usr/local/bin/sing-box
echo ""

# 删除菜单和缓存
rm -rf /usr/local/opnsense/mvc/app/models/OPNsense/sing-box
rm -f /tmp/opnsense_menu_cache.xml
rm -f /tmp/opnsense_acl_cache.json

# 重启服务
log "$YELLOW" "重新应用所有更改，请稍等..."
/usr/local/etc/rc.reload_all >/dev/null 2>&1
service configd restart > /dev/null 2>&1
echo ""

# 完成提示
log "$GREEN" "卸载完成，请手动删除TUN接口、别名和浮动防火墙分流规则。"
echo ""