# Changelog

このプロジェクトに対するすべての重要な変更は、このファイルに文書化されます。

## [2.0.0] - 2023-09-25
### AMIイメージ
- CQサーバ
  - AMI: nop-dev-cq-2.0.0
- CIサーバ(Jenkins構成)
  - AMI: nop-dev-ci-jenkins-2.0.0
- CIサーバ(Gitlab構成)
  - AMI: nop-dev-ci-gitlab-2.0.0
- Demoサーバ
  - AMI: nop-inst-demo-2.0.0

### 更新内容
#### 追加
- GitLab RunnerのAutoscaling機能の利用手順を追加しました。
- Collaborageのバージョン1.1.0から2.0.0へのデータ移行手順を追加しました。

#### 変更
- AMIのOSをAmazon Linux 2023に変更しました。
- 各利用ツールを2023年9月時点の最新の安定版にバージョンアップしました。  
  ただし、Redmineはプラグインの「Redmine Backlogs」が5.Xに未対応のため、4.2.10 (2023-03-05リリース)を採用しています。
- GitLab RunnerのAutoscaling機能を利用できるようにしました。
- メトリクスの取得に利用するツールを、をAmazon CloudWatch モニタリングスクリプトからCloudWatchAgentに変更しました。
  Amazon CloudWatch モニタリングスクリプトが非推奨となったためです。

## [1.1.0] - 2020-01-28
### AMIイメージ
- CQサーバ
  - AMI: nop-dev-cq-0.2.2
- CIサーバ(Jenkins構成)
  - AMI: nop-dev-ci-jenkins-0.2.3
- CIサーバ(Gitlab構成)
  - AMI: nop-dev-ci-gitlab-0.2.3
- Demoサーバ
  - AMI: nop-inst-demo-0.1.4

### 更新内容
#### 追加
- CQサーバにSubversionを追加しました。  
  ドキュメントの版管理に使用したいというニーズがあったためです。
- ツールのバージョンアップ方法を記載しました。  
  「どうやってバージョンアップする想定なのかよくわからない」という声があったためです。

#### 変更
- Java11を採用したアプリ開発ができるようにツールのバージョンアップとガイド更新を実施しました。
- 各利用ツールを2019年11月時点の最新の安定版にバージョンアップしました。  
  ただし、いくつかのツールはこれまで利用できていた機能が使えなくなるため、最新の安定版にバージョンアップしていません。
- GitLab構成の際に使用するCIを、Concourseから、GitLab Runnerに変更しました。  
  GitLab Runnerは必要十分な機能を備えていることと、Concourseの使用者が少ないことがその理由です。
- EC2を起動していなくても、データボリュームのバックアップを取れるようにしました。


## [1.0.0] - 2017-09-28
### AMIイメージ
- CQサーバ
  - AMI: nop-dev-cq-0.1.6
- CIサーバ(Jenkins構成)
  - AMI: nop-dev-ci-jenkins-0.1.6
- CIサーバ(Concourse構成)
  - AMI: nop-dev-ci-concourse-0.1.6
- Demoサーバ
  - AMI: nop-inst-demo-0.1.4

### 更新内容
- 初版公開
