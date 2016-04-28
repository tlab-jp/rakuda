## 前後データの比較 ##

### 環境変数 ###
  - RAKUDA_VF_PATH 比較用ファイル出力先パス

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

config/verify.ymlを編集します。
比較対象のテーブルに従って下記を定義してください。

```
default:
  models:
    -
      name: 移行先モデル名(Testと定義した場合はTestAfterとTestBeforeが内部で定義される)
      before:
        db: 移行元データベース設定名(config/database.ymlに設定した値)
        id: 移行元テーブルのプライマリキー(idの場合は不要)
        table: 移行元テーブル名(ActiveRecord規約通りの場合は不要)
        inheritance: false(移行元テーブルのカラム名でtypeなど予約文字を利用している場合はtrue)
        # 比較用の独自モジュールが必要な場合のみ下記を記載する
        modules:
          - モジュールクラス名1
          - モジュールクラス名2
          - モジュールクラス名3
      after:
        db: 移行先データベース設定名(config/database.ymlに設定した値)
        id: 移行先テーブルのプライマリキー(idの場合は不要)
        table: 移行先テーブル名(ActiveRecord規約通りの場合は不要)
        inheritance: false(移行先テーブルのカラム名でtypeなど予約文字を利用している場合はtrue)
        # 比較用の独自モジュールが必要な場合のみ下記を記載する
        modules:
          - モジュールクラス名4
          - モジュールクラス名5
          - モジュールクラス名6
      # 比較項目名を定義
      attributes:
        移行元項目名1: 移行先項目名1
        移行元項目名2: 移行先項目名2
        移行元項目名3: 移行先項目名3
        移行元項目名4: 移行先項目名4
        移行元項目名5: 移行先項目名5
```

### 3. 比較用の独自モジュール作成 ###

データを加工して移行元と移行先を比較する場合は、比較用の独自モジュールを作成する必要があります。
比較用モジュールは「lib/verify/モジュール名.rb」として作成することで自動的にロードされます。
2の各テーブル毎定義のmodulesに作成したモジュールクラス名を設定することで、モデルにインクルードされます。

### 4. コマンドの実行 ###

データ比較用ファイル出力コマンドを実行します。

```
bundle exec rake data:verify
```

出力先フォルダを入力しない場合は自動的に dist/verify となります。

