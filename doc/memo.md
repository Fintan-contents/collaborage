Collaborage開発メモ
================================================================

# AWS

- [AWSの事前準備](aws.md#事前準備)をやります。
- CloudFormationでnop-with-ssl.yamlを使って作ります。
  - 以下のインスタンスのImageIdをベースに使用するOSを提供しているAMIのImageIdに修正します。
    - Ec2Cq > Properties > ImageId
    - Ec2Ci > Properties > ImageId
    - Ec2Demo > Properties > ImageId
- 各インスタンスのボリュームを設定します。
  - xvdaの拡張
    - EC2のインスタンス詳細 > ストレージ
      - ブロックデバイスのデバイス名：/dev/xvda のボリュームIDを選択
    - ボリューム詳細 > 変更
      - ボリュームタイプ：gp2
      - ボリュームサイズ：20GiB
  - sdbの追加（CQ/CIのみ）
    - EC2のボリューム > ボリュームの作成
      - ボリュームタイプ：gp2
      - ボリュームサイズ：40GiB
      - AZ：ap-northeast-1a
    - ボリュームをアタッチ
      - インスタンス；CQ/CI のインスタンスID
      - デバイス名：/dev/sdb
- [OSの初期設定～アプリのインストール](app.md)をやります。
- DemoサーバのAMIを作ります。
- DemoサーバのAMI作成前に修正します。
  ```
  # regionをap-northeast-1(東京)に修正します。
  $ cat ~/.aws/config
  $ aws configure
  $ cat ~/.aws/config
  ```
- Route53でRecordSetを作ります。
- [アプリの初期設定](init.md)をやります。
  - 管理者のパスワード等は[各サーバの状態を理解します](ami.md#各サーバの状態を理解します)を見ます。
- [プロジェクトの開発準備](dev.md)をやります。
  - グループ/ユーザ/プロジェクト/リポジトリ等は[各サーバの状態を理解します](ami.md#各サーバの状態を理解します)を見ます。
- CQサーバ、CIサーバのAMI作成前に修正します。
  ```
  # cronを削除します。
  $ crontab -l
  $ crontab -r
  $ crontab -l
  
  # cronのエラーログを消します。
  $ ls -l nop/log/
  $ rm nop/log/*
  $ ls -l nop/log/

  # regionをap-northeast-1(東京)に修正します。
  $ cat ~/.aws/config
  $ aws configure
  $ cat ~/.aws/config

  # 不要なボリュームを消します。
  $ docker volume prune
  ```
- CQサーバ、CIサーバのAMIを作ります。

# textlintの実行
doc以下のmdファイルを修正した場合、表記ゆれ、誤字脱字等がないかtextlintでチェックします。
- textlintインストール
  - Collaboradeのディレクトリの直下で以下をインストールします。
    - Node.js（v16.16.0で動作確認済み）
    - npmで依存ライブラリをインストールします。
      ```
      npm install
      ```
    - [textlint-plugin-rst](https://github.com/jimo1001/textlint-plugin-rst)の依存ライブラリである docutils-ast-writerをインストールします。
      ```
      pip install docutils-ast-writer
      ```
- textlint実行
  - 以下のコマンドでdoc以下のファイルの解析を行います。
    ```
    ./node_modules/.bin/textlint doc
    ```
<!-- textlint-disable -->
- チェック除外対象
  - 以下は修正対象外とします。
    - /doc/aws.md
      - [AWS](aws.md#aws)  利用 => 使用　の表記ゆれ
        - 画面項目の名称が検知されているため対応不要
    - /doc/dev.md
      - [Redmineでのユーザ追加](dev.md#redmineでのユーザ追加) ユーザー => ユーザ　の表記ゆれ
        - 画面項目の名称が検知されているため対応不要
      - [Rocket.Chatでのユーザ追加](dev.md#rocketchatでのユーザ追加) ユーザー => ユーザ　の表記ゆれ
        - 画面項目の名称が検知されているため対応不要
    - /doc/init.md
      - [Nexus](init.md#nexus)  repo => repository　の表記ゆれ
        - URLの一部が検知されているため対応不要
<!-- textlint-enable -->        
