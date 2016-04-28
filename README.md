# rakuda #

* master: [![Build Status](https://travis-ci.org/tlab-jp/rakuda.svg?branch=master)](https://travis-ci.org/tlab-jp/rakuda)

## rakudaについて ##

ActiveRecordを利用したマイグレータです。
rakudaの由来は、データを運ぶ「ラクダ」と設定が「楽だ」から来ています。

## テスト環境 ##

* Ruby 2.1.0, 2.2.0, 2.3.0

* System dependencies
  - ActiveRecordがサポートしているDB

* Gem dependancies
  - bundler

* Configuration Files
  - config/share.yml
  - config/generate.yml
  - config/submit.yml
  - config/migrate.yml
  - config/verify.yml
  - config/database.yml

* Library Instaration
  - bundle install (--path vendor/bundler)

## 使用方法 ##

### 環境変数 ###
  - RAKUDA_ENV 動作モード
  - RAKUDA_IM_PATH 中間ファイル出力ディレクトリ

### データ移行(中間ファイル経由での移行) ###

1. [移行元DBから中間ファイルを生成](https://github.com/tlab-jp/rakuda/blob/master/doc/generate.md)

2. [中間ファイルから移行先DBへデータを登録](https://github.com/tlab-jp/rakuda/blob/master/doc/submit.md)

3. [前後データを比較する](https://github.com/tlab-jp/rakuda/blob/master/doc/verify.md)

### データ移行(直接移行） ###

1. [移行元DBから移行先DBへデータを登録](https://github.com/tlab-jp/rakuda/blob/master/doc/migrate.md)

2. [前後データを比較する](https://github.com/tlab-jp/rakuda/blob/master/doc/verify.md)

## Log -ログ- ##

ActiveRecordのログは log/active_record.log へ出力されます。

## License -ライセンス- ##

このソフトウェアは、 MITライセンスで配布されている製作物が含まれています。  
このソフトウェアは、 Apache 2.0ライセンスで配布されている製作物が含まれています。

this software includes the work that is distributed in the MIT License  
this software includes the work that is distributed in the Apache License 2.0

## Authors -作者- ##

[metalels](https://github.com/metalels)
[bon10](https://github.com/bon10)

