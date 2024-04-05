# Chaldea

## Installation

Check in docs for more about installation and startup: https://docs.chaldea.center/guide/install.html

The app requires `libappindicator` to enable the system tray feature. If it is not installed or builtin in your system,
you have to install it manually first.

```sh
sudo apt-get install libayatana-appindicator3-dev
# or
sudo apt-get install appindicator3-0.1 libappindicator3-dev
```

The system tray may crash app. To reset it to disabled state, removing the `"showSystemTray": true` from `userdata/user/settings.json`, or delete the entire `settings.json` file if you don't know json format.

## Upgrade

Simply override old files with new extracted files.

## 安装

更多关于安装与启动的问题请参考文档: https://docs.chaldea.center/zh/guide/install.html

应用需 `libappindicator` 来启用系统托盘功能，若 Linux 系统中未安装，可以尝试以下方法安装

```sh
# Debian
sudo apt-get install libayatana-appindicator3-dev
# or
sudo apt-get install appindicator3-0.1 libappindicator3-dev
```

系统托盘功能可能导致应用闪退崩溃，需在`userdata/user/settings.json`文件中删除`"showSystemTray": true`设置项以重置该设置。若不了解json格式，可直接删除整个`settings.json`文件。

## 升级

直接解压并覆盖旧文件即可。
