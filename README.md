# MyAdminStyle ベータ版
管理画面に独自ファイルを読み込ませてカスタマイズが可能な[Movable Type][PowerCMS]のプラグインです。

## Description
管理画面に独自の JavaScript や CSS を追加して、簡単にカスタマイズすることができるプラグインです。

本プラグインが提供する機能は3つです。

- 管理画面に[独自ファイル]へのパスが登録できる。
- 管理画面に[カスタマイズに必要なパラメータ]を追加する。
- モジュールディレクトリ

[詳しくはこちら](https://cms-note.com/movabletype/plugin_myadminstyle.html)

## 使用例
### CMS管理画面
管理画面からシステムのプラグイン設定を開き[body の閉じタグ直前へ] 下記を登録する。

    <script type="module" src="/cms-path/mt-static/plugins/MyAdminStyle/src/index.js"></script>

### スクリプト内容

    import {myVars} from '../modules/MyAdminStyle/index.js'; // カスタマイズに必要なパラメータの宣言モジュール
    import {myHelloWorld} from '../modules/HelloWorld/index.js'; // サードパーティ製モジュール読み込み

    if (myVars.screen_id === 'edit-entry') { // 自分の処理
      myHelloWorld(); // サードパーティ製モジュールの実行
    }

## 動作するCMS
以下のCMSでご利用いただけます。記載より古いバージョンでも動作すると思いますが未確認です。

- Movable Type 6 以上
- PowerCMS 5 以上

## Document
まだない

## Varsion
0.0.1

## License
Released under the [MIT license](https://opensource.org/licenses/mit-license.php)

## Author
[CMS NOTE](https://cms-note.com/)