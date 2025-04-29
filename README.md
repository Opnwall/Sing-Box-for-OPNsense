## Sing-Box for OPNsense
sing-box安装工具，用于运行Sing-Box、Tun2socks，实现透明代理功能。支持DNS分流，带Web控制界面，方便进行配置修改、程序控制、日志查看。在OPNsense 25.1.5上测试通过。

## 项目源代码
该项目集成了以下工具：

[Sing-Box](https://github.com/SagerNet/sing-box) 

[MetaCubeXD](https://github.com/MetaCubeX/metacubexd) 

[Hev-Socks5-Tunnel](https://github.com/heiher/hev-socks5-tunnel)

## 注意事项
1. 当前仅支持x86_64 平台。
2. 脚本不提供任何节点信息，请准备好自己的配置文件。
3. 脚本会自动添加tun接口、china_ip别名、分流规则，安装完成后可以手动修改。
4. 脚本已集成了可用的默认配置，只需补充sing-box的outbounds部分配置即可使用。
5. 为减少长期运行保存的日志数量，在调试完成后，请将所有配置的日志类型修改为error或warn。

## 安装方法
下载后解压，上传到防火墙根目录，进入安装目录，运行以下命令安装：

```bash
sh install.sh
```

## 使用方法
请参考以下文章：
[pfSense、OPNsense配置sing-box代理教程](https://pfchina.org/?p=12933)

## 参考资料  
- [pfSense、OPNsense设置http透明代理教程](https://pfchina.org/?p=13572)  
- [pfSense、OPNsense配置hev-socks5-tunnel透明代理教程](https://pfchina.org/?p=14551)
