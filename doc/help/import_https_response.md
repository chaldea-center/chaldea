## HTTPS抓包导入

1.教程详见

注意：日服/美服需要使用修改版apk安装包(且仅Android，不支持iOS)，国服和台服均可(Android&iOS)

[https://docs.chaldea.center/zh/guide/import_https/](https://docs.chaldea.center/zh/guide/import_https/)

目录:
- **Stream-iOS**: 国服/台服iOS抓包教程
- **HttpCanary-Android**: Android抓包教程
- **Charles版教程-PC**: Android/iOS配合Charles(PC)教程
- **mitmproxy版教程-PC**: Android/iOS配合mitmproxy(PC)教程
- **Quantumult X-iOS**: 国服&台服iOS抓包（付费app）


2.简要说明

- 首先通过上面的教程借助解析HTTPS响应保存为如a.txt
- 上面导出的文件在任一平台的Chaldea应用中均可导入
- 在Chaldea中点击右上角导入按钮导入a.txt
- 筛选想要导入的资料
    - 素材/从者/保管室从者
    - 筛选仅“已锁定”从者
    - 若存在多个重复从者，默认从者为一号机，其余为二号机！以3个技能和最大者为默认从者，若技能相同，按获取时间最早。
    - 点击单个从者可进行忽略/添加
- 最终点击“导入”到当前账户
- 注意：考虑到会规划未来待抽从者，因此导入时仅覆盖解析出的数据，而未实装/未抽到的则不做更改

3.关于HTTPS解密

通过拦截并解析游戏在登陆时向客户端发送的包含账户信息的HTTPS响应导入素材和从者信息。 客户端与服务器之间的HTTPS通信是经过加密的，解密需要在本机或电脑通过Charles/Fiddler(PC)等工具伪造证书服务器并安装其提供的证书以实现。 因此在导入结束后请及时取消信任或删除证书以保障设备安全。

日服美服存在客户端证书绑定，需使用去除证书绑定的第三方安卓客户端。

本软件源码已开源，不涉及https捕获解密等过程，只将以上工具导出的结果解析素材和从者信息，不做其他用途。

若您无法信任本软件或教程所使用的第三方软件/客户端，请勿使用。
