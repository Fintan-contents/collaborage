Collaborage開発メモ
================================================================

# AWS

- [AWSの事前準備](aws.md#事前準備)をやります。
- CloudFormationでnop-with-ssl.yamlを使って作ります。
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

  # AWS CLIのキャッシュ(インスタンスID)を削除します。
  $ ls -l /var/tmp/aws-mon/instance-id
  $ sudo rm /var/tmp/aws-mon/instance-id
  $ ls -l /var/tmp/aws-mon/instance-id

  # 不要なボリュームを消します。
  $ docker volume prune
  ```
- CQサーバ、CIサーバのAMIを作ります。
