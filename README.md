# YubikeyとOpenSSLで作る電子認証局
## 概要
このレポジトリは、2019年09月22日（日）に開催されました、技術書典7で配布した新刊、YubikeyとOpenSSLで作る電子認証局のサンプルコード置き場になります。
書籍はBoothでも取得することができます。

* https://electric-sheep.booth.pm/items/1573781

## 動作バージョン
本レポジトリのスクリプト類を動作させるには以下のインストールが必要です。
```
sudo apt install yubico-piv-tool yubikey-piv-manager libengine-pkcs11-openssl opensc-pkcs11 opensc
```

動作はUbuntu16.04、以下のライブラリバージョンで確認しています。
* opensc-pkcs11：0.17.0-3
* libengine-pkcs11-openssl：0.4.7-3
* yubico-piv-tool：2.1.1\~ppa1\~bionic1
* yubikey-piv-manager：1.3.0-1.1
* opensc：0.17.0-3
