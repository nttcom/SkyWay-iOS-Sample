# SkyWay iOS Sample
Sample application of SkyWayiOSSDK

## How to build
 1. Register an account on [SkyWay](http://nttcom.github.io/skyway/) and get an API key
 1. Clone or download this repository.
 1. Open "SkyWay-iOS-Sample.xcodeproj"
 1. Add "SkyWay.framework" library to the "Link Binary With Libraries" build phase of your project.
  1. Download "SkyWay.framework" from [SkyWay](http://nttcom.github.io/skyway/)
 1. Set kAPIKey and kDomain to your API key/Domain registered on SkyWay.io at the top of both "DataConnectionViewController.m" and "MediaConnectionViewController.m" and build!
```objective-c
// Enter your APIkey and Domain
// Please check this page. >> https://skyway.io/ds/
static NSString *const kAPIkey = @"yourAPIKEY";
static NSString *const kDomain = @"yourDomain";
```

##Installation of SkyWay.framework with CocoaPods
Podfile

```
platform :ios, '7.0'
pod 'SkyWay-iOS-SDK'
```

Install
```
pod install
```

## NOTICE
This application requires v0.2.0+ of SkyWay iOS SDK.

------

## ビルド方法
 1. [SkyWay](http://nttcom.github.io/skyway/)でアカウントを作成し、APIkeyを取得
 1. このレポジトリをクローンまたはダウンロード
 1. "SkyWay-iOS-Sample.xcodeproj"を開く
 1. "SkyWay.framework"をプロジェクトのBuild Phasesの"Link Binary With Libraries"に追加
  1. "SkyWay.framework"は[SkyWay](http://nttcom.github.io/skyway/)からダウンロード
 1. "DataConnectionViewController.m" と "MediaConnectionViewController.m"の上部にあるkAPIKeyとkDomainにAPIkeyとDomainを入力し、ビルド

```objective-c
// Enter your APIkey and Domain
// Please check this page. >> https://skyway.io/ds/
static NSString *const kAPIkey = @"yourAPIKEY";
static NSString *const kDomain = @"yourDomain";
```
##CocoaPodsを利用したSkyWay.frameworkのインストール
Podfile

```
platform :ios, '7.0'
pod 'SkyWay-iOS-SDK'
```

Install
```
pod install
```


## 注意事項
本アプリケーションはSkyWay iOS SDKのv0.2.0以降で動作します。
