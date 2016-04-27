# rakuda #

## rakuda使用方法 ##

ActiveRecordを利用したマイグレータです。
rakudaの由来は、データを運ぶ「ラクダ」と設定が「楽だ」から来ています。

## 開発環境 ##

* Ruby 2.3.0

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

## つかいかた ##

* 環境変数
  - RAKUDA_ENV 動作モード
  - RAKUDA_IM_PATH 中間ファイル出力ディレクトリ

* 前データベースからのデータ抽出

**１．データベースを設定する**

config/database.ymlを編集します。

任意のキー名で移行元データベースを全て定義してください。

```
test_before_database:
  adapter:  mysql2
  host:     1.1.1.1
  username: guest
  password: password
  database: before_db
  encoding: utf8
  reconnect: true
```

**２．コンフィグを設定する**

config/generate.ymlを編集します。
変換対象のテーブルに従って下記を定義してください。

```
default:
  models:
    -
      name: テーブル名
      db: データベース設定名(config/database.ymlに設定した値)
      id: テーブルのプライマリキー(idの場合は不要)
      table: テーブル名(ActiveRecord規約通りの場合は不要)
      # 移行データ作成に他テーブルとの関連が必要な場合のみ記載
      associations:
        -
          method: 関連名(has_many, has_one, belongs_toなど)
          scope: 関連モデル(Authore の場合 author など)
          options: オプション(through: books_authors など)
        -
          method: 関連名(has_many, has_one, belongs_toなど)
          scope: 関連モデル(Author の場合 author など)
          options: オプション(through: books_authors など)
      # 自動採番する／しない
      auto_numbering: true
      # 自動採番をする場合の開始番号
      auto_numbering_begin: 1
      # GeneralAttributesモジュールへは全モデルで共通のカラムを定義する
      # GeneralAttributesは必ずロードされる
      # それ以外で移行用の独自モジュールが必要な場合のみ下記を記載する
      modules:
        - モジュールクラス名1
        - モジュールクラス名2
        - モジュールクラス名3
      # 単純なカラム名変更の場合に定義可能（モジュールを定義する程でもない時用）
      # alias_attribute によるエイリアスを自動定義する
      aliases:
        新カラム名: 旧カラム名
      # 移行後の項目名を定義
      attributes:
        - 項目名1
        - 項目名2
        - 項目名3
        - 項目名4
      inheritance: false(旧テーブルのカラム名でtypeなど予約文字を利用している場合はtrue)
      keep_mem_data: false(他のモジュールから$models["クラス名"]等で利用する場合はtrueにすることで、中間ファイル出力後もメモリ上にデータを保持する)
      data_output_finally: false(trueにすることで全てのモデル出力が終わった後にデータを出力する)
```

**３．移行用の独自モジュール作成**

移行元データを加工して移行後データを作成する場合は、移行用の独自モジュールを作成する必要があります。
移行用モジュールは「lib/generate/モジュール名.rb」として作成することで自動的にロードされます。
2の各テーブル毎定義のmodulesに作成したモジュールクラス名を設定することで、モデルにインクルードされます。

4. 移行コマンドの実行

移行コマンドを実行します。

rake data:generate (出力先フォルダ)

出力先フォルダを入力しない場合は自動的に dist/intermediate_files となります。

* 新データベースへのデータ登録

**１．データベースを設定する**

config/database.ymlを編集します。

任意のキー名で移行先データベースを全て定義してください。

```
test_after_database:
  adapter:  mysql2
  host:     1.1.1.1
  username: guest
  password: password
  database: after_db
  encoding: utf8
  reconnect: true
```

**２．コンフィグを設定する**

config/submit.ymlを編集します。
変換対象のテーブルに従って下記を定義してください。

```
default:
  force_reset: 有効無効 (true or false 登録前に強制データクリア)
  models:
    -
      name: テーブル名
      db: データベース設定名(config/database.ymlに設定した値)
      id: テーブルのプライマリキー(idの場合は不要)
      table: テーブル名(ActiveRecord規約通りの場合は不要)
      # 移行データ登録に他テーブルとの関連が必要な場合のみ記載
      associations:
        -
          method: 関連名(has_many, has_one, belongs_toなど)
          scope: 関連モデル(Authorの場合 author など)
          options: オプション(through: books_authors など)
        -
          method: 関連名(has_many, has_one, belongs_toなど)
          scope: 関連モデル(Bookの場合 book など)
          options: オプション(through: books_authors など)
      # 移行用の独自モジュールが必要な場合のみ記載
      modules:
        - モジュールクラス名1
        - モジュールクラス名2
        - モジュールクラス名3
      # アトリビュートの記載（パスワードの暗号化等）
      attrs:
        -
          method: アトリビュート（attr_encrypted など)
          scope: カラム（:password など)
          options: オプション (key: 'aaa', attribute: 'encrypt_password' など)
      inheritance: true(旧テーブルのカラム名でtypeなど予約文字を利用している場合に必要)
```

**３．登録用の独自モジュール作成**

登録用に独自モジュールを定義可能です。
登録用モジュールは「lib/submit/モジュール名.rb」として作成することで自動的にロードされます。
2の各テーブル毎定義のmodulesに作成したモジュールクラス名を設定することで、モデルにインクルードされます。

4. 登録コマンドの実行

登録コマンドを実行します。

rake data:submit (データ格納フォルダ)

データ格納フォルダを指定しない場合は自動的に dist/intermediate_files がロードされます。

* ログの確認

**１．ActiveRecordのログ**

ActiveRecordのログは log/active_record.log へ出力されます。

## License -ライセンス- ##

このソフトウェアは、 MITライセンスで配布されている製作物が含まれています。  
このソフトウェアは、 Apache 2.0ライセンスで配布されている製作物が含まれています。

this software includes the work that is distributed in the MIT License  
this software includes the work that is distributed in the Apache License 2.0

## Authors -作者- ##

[metalels](https://github.com/metalels)
[bon10](https://github.com/bon10)

