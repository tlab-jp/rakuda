## DB2DB 直接移行 ##

### 1. データベースを設定する ###

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
test_after_database:
  adapter:  mysql2
  host:     1.1.1.1
  username: guest
  password: password
  database: after_db
  encoding: utf8
  reconnect: true
```

### 2. コンフィグを設定する ###

config/migrate.ymlを編集します。
比較対象のテーブルに従って下記を定義してください。

```
default:
  models:
    -
      name: 移行先モデル名(Testと定義した場合はTestAfterとTestBeforeが内部で定義される)
      # 自動移行する／しない 新旧テーブルで同名のカラムが存在する場合に自動的にデータを移行します
      auto_matching: true
      before:
        # ※1
      after:
        # ※2
      # 移行項目名を定義(auto_matchingよりも優先度高)
      attributes:
        移行元メソッド名1: 移行先メソッド名1
        移行元メソッド名2: 移行先メソッド名2
        移行元メソッド名3: 移行先メソッド名3
        移行元メソッド名4: 移行先メソッド名4
```

※1 オプションは[generate](https://github.com/tlab-jp/rakuda/blob/master/doc/generate.md)を参照
※2 オプションは[submit](https://github.com/tlab-jp/rakuda/blob/master/doc/submit.md)を参照

### 3. 移行用の独自モジュール作成 ###

データを加工して移行元から移行先へ登録する場合は、移行用の独自モジュールを作成する必要があります。
移行用モジュールは「lib/migrate/モジュール名.rb」として作成することで自動的にロードされます。
2の各テーブル毎定義のbefore内及びafter無のmodulesに作成したモジュールクラス名を設定することで、モデルにインクルードされます。

### 4. コマンドの実行 ###

DB2DB直接データ移行コマンドを実行します。

```
bundle exec rake data:migrate
```

