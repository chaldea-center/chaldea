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

The app upgrades itself in one click (Settings → About → Check Update): it
downloads, verifies, backs up the old version into `_backups/`, replaces the
files and restarts automatically. To roll back manually, run `sh restore.sh`
inside any `_backups/chaldea-backup-<version>/` folder. See
`安装与升级说明-InstallAndUpgrade.txt` for details.

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

支持应用内一键自动升级（设置 → 关于 → 检查更新）：自动下载、校验、备份旧版本到
`_backups/`、替换文件并重启。如需手动回滚，在任意
`_backups/chaldea-backup-<版本号>/` 中执行 `sh restore.sh`。详见
`安装与升级说明-InstallAndUpgrade.txt`。
