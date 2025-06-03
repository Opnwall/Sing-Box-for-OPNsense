## Sing-box for OPNsense
sing-box安装工具，运行Sing-Box、在OPNsense上实现透明代理功能。支持DNS分流，带Web控制界面，方便进行配置修改、程序控制、日志查看。在OPNsense 25.1.7上测试通过。

![](images/proxy.png)

## 程序版本
[Vincent-Loeng大佬魔改Sing-Box](https://github.com/Vincent-Loeng/sing-box) 

## 注意事项
1. 当前仅支持x86_64 平台。
2. 脚本不提供任何节点信息，请准备好自己的出站配置文件。
3. 脚本会自动添加tun接口、china_ip别名、分流规则，安装完成后可以手动修改。
4. 脚本已集成了可用的默认配置，只需补充sing-box的outbounds部分配置即可使用。
5. 由于sing-box不同版本的配置有差异，已发布Release的配置文件只针对安装程序的版本。
6. 为减少长期运行保存的日志数量，在调试完成后，请将所有配置的日志类型修改为error或warn。

## 安装命令

```bash
sh install.sh
```
![](images/install.png)

## 卸载命令

```bash
sh uninstall.sh
```
## 使用方法

[OPNsense 配置 sing-box 透明代理教程](https://pfchina.org/?p=12933)
