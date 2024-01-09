# 设备管控程序JSON配置说明

## 概述
本文档旨在提供对学生使用手机设备的管控程序JSON配置文件的详细说明。通过这个文档，用户可以了解JSON配置的格式、功能，并根据自身需求进行自定义配置。

## JSON配置结构概览
该配置文件主要由两大部分组成：`strategies`和`policies`。

- `strategies`（策略配置）: 包含了不同类型的策略设置，如应用程序允许/禁止策略、应用程序控制策略、设备配置策略和网络访问策略。这些策略定义了具体的控制规则和参数。
  
- `policies`（管控措施）: 定义了具体的管控措施，如学习模式、放假模式等。每项措施可以关联一个或多个`strategies`，以在特定时间或条件下启用这些策略。

### 1. 整体JSON示意
以下是整体JSON示意，包括`strategies`和`policies`的基本结构和示例内容：

```json
{
    "strategies": {
        "queryPolicyInterval": 600,
        "appAllowance": [...],
        "appControl": [...],
        "deviceConfig": [...],
        "network": [...]
    },
    "policies": [...]
}
```

在下文中，我们将详细说明各个部分的配置和示例。

### 2. Strategies（策略配置）
`strategies`部分包含多种策略，用于细致控制学生在学校中对手机设备的使用。这些策略涉及到应用程序的使用权限、设备的配置设置、网络访问控制等多个方面。

#### 2.1 queryPolicyInterval（策略查询间隔） 
- `queryPolicyInterval`（数字）：查询策略间隔时间，单位：秒。设备在持续亮屏时，每隔该时间段会去服务器拉取一次最新策略。此外，在设备开机、亮屏时，均会拉取策略。

#### 2.2 App Allowance（应用程序允许/禁止策略）
此部分定义了哪些应用程序被允许或禁止在特定场景下使用。它通过设置黑白名单来管理学生可以访问的应用程序。

**JSON示例**:
```json
{
    "id": "3234567890abcdef",
    "name": "工作日应用禁用策略",
    "controlType": "whitelist",
    "apps": [
        "com.chaoxing.mobile",
        "com.tencent.edu",
        "com.yaoo.qlauncher",
        "com.android.chrome"
    ]
}
```

- `id` (文本): 策略的唯一标识符。
- `name` (文本): 策略的名称，如“工作日应用禁用策略”。
- `controlType` (文本): 控制类型，可以是`whitelist`（白名单）或`blacklist`（黑名单）。
- `apps` (字符串数组): 应用程序包名列表，指定哪些应用程序被允许或禁止。

#### 2.3 App Control（应用程序控制策略）
此部分详细定义了对特定应用程序的控制策略，包括应用的安装、使用时间、权限设置等方面。这允许对学生使用特定应用的方式和时长进行更精确的管理。

**JSON示例**:
```json
{
    "id": "5234567890abcdef",
    "name": "工作日应用控制策略",
    "apps": [
        {
            "applicationName": "如意老年人桌面",
            "applicationIcon": "https://baibaomen.oss-cn-hangzhou.aliyuncs.com/icon/com.yaoo.qlauncher_V7.3710728.png",
            "packageName": "com.yaoo.qlauncher",
            "versionCode": "371",
            "installUrl": "https://baibaomen.oss-cn-hangzhou.aliyuncs.com/apk/com.yaoo.qlauncher_V7.3710728.apk",
            "allowedMinutesPerDay": "10",
            "installOtherAppsAllowed": "allowed",
            "installAllowed": true,
            "autoInstall": true,
            "upgradeAllowed": true,
            "uninstallAllowed": false,
            "autoGrantPermissions": false,
            "autoUpgrade": false
        }
    ]
}
```

- `id` (文本): 策略的唯一标识符。
- `name` (文本): 策略的名称，如“工作日应用控制策略”。
- `apps` (对象数组): 包含多个应用控制配置，每个配置包括以下属性：
  - `applicationName` (文本): 应用的显示名称。
  - `applicationIcon` (字符串, URL): 应用的图标链接。
  - `packageName` (文本): 应用的包名。
  - `versionCode` (文本): 应用的版本号。
  - `installUrl` (字符串, URL): 应用的安装链接。
  - `allowedMinutesPerDay` (文本): 每天允许使用的分钟数。
  - `installOtherAppsAllowed` (文本): 是否允许安装其他应用，可选值为`allowed`、`notallowed`、`nocontrol`。
  - `installAllowed` (布尔值): 是否允许安装当前应用。
  - `autoInstall` (布尔值): 是否允许自动安装应用。
  - `upgradeAllowed` (布尔值): 是否允许升级应用。
  - `uninstallAllowed` (布尔值): 是否允许卸载应用。
  - `autoGrantPermissions` (布尔值): 是否自动授予权限。
  - `autoUpgrade` (布尔值): 是否自动升级低版本的应用。

#### 2.4 Device Config（设备配置策略）
设备配置策略部分提供了对学生设备硬件和系统功能的全面控制，允许管理员精确管理设备的核心功能。

**JSON示例**:
```json
{
    "id": "7234567890abcdef",
    "name": "受控设备配置",
    "globalLock": false,
    "wifi": "enforced",
    "mobileData": "disabled",
    "bluetoothData": "enforced",
    "camera": "open",
    "usbDebug": "open",
    "developerMode": "open",
    "usbDataTransfer": "nocontrol",
    "sdcard": "disabled",
    "silentMode": "enforced",
    "location": "enforced",
    "screenshot": "nocontrol",
    "factoryReset": "disabled",
    "safeMode": "disabled",
    "eyeProtection": "open",
    "networkTethering": "disabled",
    "foregroundApp": "",
    "currentLauncher": "com.yaoo.qlauncher"
}
```

- `id` (文本): 策略的唯一标识符。
- `name` (文本): 策略的名称，如“受控设备配置”。
- `globalLock` (布尔值): 指定是否对设备进行全局锁定。
- `wifi` (枚举): 控制设备的WiFi连接。可选值及含义如下：
  - `open`: 功能开启且可由用户控制关闭。
  - `close`: 功能关闭且可由用户控制打开。
  - `enforced`: 功能被强制开启，用户无法关闭。
  - `disabled`: 功能被禁用，用户无法开启。
  - `nocontrol`: 不进行任何控制。
- `mobileData` (枚举): 控制移动数据的使用，取值同上。
- `bluetoothData` (枚举): 控制蓝牙数据传输，取值同上。
- `camera` (枚举): 控制摄像头的使用，取值同上。
- `usbDebug` (枚举): 控制USB调试模式，取值同上。
- `developerMode` (枚举): 控制设备的开发者模式，取值同上。
- `usbDataTransfer` (枚举): 控制USB数据传输功能，取值同上。
- `sdcard` (枚举): 控制SD卡使用，取值同上。
- `silentMode` (枚举): 控制设备的静音模式，取值同上。
- `location` (枚举): 控制定位服务，取值同上。
- `screenshot` (枚举): 控制截屏功能，取值同上。
- `factoryReset` (枚举): 控制恢复出厂设置的能力，取值同上。
- `safeMode` (枚举): 控制安全模式的使用，取值同上。
- `eyeProtection` (枚举): 控制护眼模式的使用，取值同上。
- `networkTethering` (枚举): 控制设备的网络共享功能，取值同上。
- `foregroundApp` (文本): 指定始终保持在前台运行的应用的包名。
- `currentLauncher` (文本): 指定设备使用的桌面启动器的包名。

#### 2.5 Network（网络访问策略）
网络访问策略部分专注于控制和管理学生设备对互联网资源的访问。通过这些策略，可以设置访问特定网站的白名单或黑名单，从而确保学生在上网时的安全性和适宜性。

**JSON示例**:
```json
{
    "id": "1234567890abcdef",
    "name": "标准管控策略",
    "config": [
        {
            "applyTo": "all",
            "rules": [
                {
                    "type": "blacklist",
                    "sites": ["*.taobao.com"]
                },
                {
                    "type": "whitelist",
                    "sites": ["123.123.123.123"]
                }
            ]
        }
    ]
}
```

- `id` (文本): 策略的唯一标识符。
- `name` (文本): 策略的名称，如“标准管控策略”。
- `config` (对象数组): 包含多个配置项，每个配置项包括以下字段：
  - `applyTo` (文本): 指定该策略适用的范围。例如，`all`表示全局应用，或者指定特定应用的包名。
  - `rules` (对象数组): 包含一组规则，每个规则定义如下：
    - `type` (枚举): 规则的类型，`blacklist`或`whitelist`。
      - `blacklist`: 列出不允许访问的站点。
      - `whitelist`: 列出只允许访问的站点。
    - `sites` (文本数组): 根据规则类型，列出具体的网站或IP地址。域名可以用*前缀，比如*.taobao.com；IP可以用#后缀，比如123.123.123.#。

### 3. Policies（管控措施）
`policies`部分定义了整体的管控措施，将前述的各类策略组合应用于特定时间段和日期，以实现对学生使用手机的全面管理。

#### 3.1 Policy（管控措施）
每项管控措施可以指定特定的策略，如应用禁用策略、应用控制策略等，以及它们的应用时间和日期。

**JSON示例**:
```json
{
    "id": "b318ec76-f9b5-400a-ba12-6c1244b34009",
    "name": "学习模式",
    "appliedWeekdays": [1, 3, 4, 5],
    "appliedTimeRanges": [
        {
            "startTime": "00:00",
            "endTime": "24:00"
        }
    ],
    "strategies": {
        "appAllowance": "3234567890abcdef",
        "appControl": "5234567890abcdef",
        "network": "0c8e70d8-84b1-40f5-9217-7a5b0bfc4716",
        "deviceConfig": "7234567890abcdef"
    }
}
```

- `id` (文本): 管控措施的唯一标识符。
- `name` (文本): 管控措施的名称，如“学习模式”。
- `appliedWeekdays` (数字数组): 指定应用此措施的周天，数字1至7分别代表周一至周日。
- `appliedTimeRanges` (对象数组): 指定措施应用的时间段，每个时间段包括：
  - `startTime` (文本): 时间段的开始时间。
  - `endTime` (文本): 时间段的结束时间。如需配置全天策略，请startTime设为00:00，endTime设为24:00。
- `strategies` (对象): 指定该措施所应用的策略ID，包括：
  - `appAllowance` (文本): 应用允许/禁止策略的ID。
  - `appControl` (文本): 应用控制策略的ID。
  - `network` (文本): 网络访问策略的ID。
  - `deviceConfig` (文本): 设备配置策略的ID。

通过结合不同的策略和时间控制，`policies`部分为学校提供了灵活的设备管理方案，确保学生在适当的时间使用适当的设备功能。

至此，我们已经详细介绍了配置文件的主要部分和属性。如有任何问题或需要进一步的说明，请随时提出。
