## 移行元データベースからのデータ抽出 ##

### 環境変数 ###
  - RAKUDA_IM_PATH 中間ファイル出力先パス

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
```

### 2. コンフィグを設定する ###

config/generate.ymlを編集します。
変換対象のテーブルに従って下記を定義してください。

```
default:
  models:
    -
      name: 移行元モデル名
      after_name: 移行先モデル名(移行元モデル名と移行先モデル名が同じ場合は不要)
      db: 移行元データベース設定名(config/database.ymlに設定した値)
      id: 移行元テーブルのプライマリキー(idの場合は不要)
      table: 移行元テーブル名(ActiveRecord規約通りの場合は不要)
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
        移行元カラム名: 移行先カラム名
      # 移行後の項目名を定義
      attributes:
        - 移行先項目名1
        - 移行先項目名2
        - 移行先項目名3
        - 移行先項目名4
      inheritance: false(旧テーブルのカラム名でtypeなど予約文字を利用している場合はtrue)
      keep_mem_data: false(他のモジュールから$models["クラス名"]等で利用する場合はtrueにすることで、中間ファイル出力後もメモリ上にデータを保持する)
      data_output_finally: false(trueにすることで全てのモデル出力が終わった後にデータを出力する)
```

### 3. 移行用の独自モジュール作成 ###

移行元データを加工して移行後データを作成する場合は、移行用の独自モジュールを作成する必要があります。
移行用モジュールは「lib/generate/モジュール名.rb」として作成することで自動的にロードされます。
2の各テーブル毎定義のmodulesに作成したモジュールクラス名を設定することで、モデルにインクルードされます。

### 4. コマンドの実行 ###

中間ファイル生成コマンドを実行します。

```
bundle exec rake data:generate
```

中間ファイル出力先パスを指定しない場合は自動的に dist/intermediate_files が設定されます。

