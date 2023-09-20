パイプライン
================================================================

ここでは、Collaborageが提供するパイプラインの内容を簡単に説明します。

- [Jenkins](#jenkins)
- [GitLab Runner](#gitlab-runner)



# Jenkins


![](images/jenkins-pipeline.png)
- develop 
  - 「ユニットテスト」＞「コード解析」＞「デモ環境へのデプロイ」を順に行います。
  - 「ユニットテスト」は 「mvn test」を実行しレポート出力します。
  - 「コード解析」は「mvn sonar:sonar」を実行し、SonarQubeにコード解析結果を連携します。
  - 「デモ環境へのデプロイ」はdevelopブランチのみ行います。develop以外のブランチはデプロイしません。
  - 「デモ環境へのデプロイ」は次の処理で行っています。
    - 「mvn package」を実行してWarを作成します。
    - War、アプリ起動スクリプトをsshpassを使ってデモサーバに送信し、アプリ起動スクリプトを実行します。
- push-docker-image
  - 「ユニットテスト」＞「コード解析」＞「NexusへDockerイメージをpush」を順に行います。
  - 「ユニットテスト」、「コード解析」はdevelopと同じ内容を実行します。
  - 「NexusへDockerイメージをpush」はpush-docker-imageブランチのみ行います。push-docker-image以外のブランチはデプロイしません。
  - 「NexusへDockerイメージをpush」は次の処理で行っています。
    - 「mvn package」を実行してWarを作成します。
    - 「jib:build」を実行してDockerイメージの作成、pushを行います。

# GitLab Runner


![](images/gitlab-pipeline.png)
- develop
  - 「ユニットテスト及びコード解析」＞「デモ環境へのデプロイ」を順に行います。  
    Jenkinsの場合と異なり、ユニットテストとコード解析をまとめています。  
    ユニットテスト時のビルド結果をコード解析でも使用したいのですが、GitLab RunnerはStageごとにコンテナを作り直すためビルド結果がstage間で連携されないためです。
  - 「ユニットテスト及びコード解析」は「mvn test」「mvn sonar:sonar」を実行し、SonarQubeにコード解析結果を連携します。  
    GitLab Runnerには、Jenkinsのようなレポート出力がないので、実行ログでテストNGを確認します。
  - 「デモ環境へのデプロイ」はdevelopブランチのみ行います。develop以外のブランチはデプロイしません。
  - 「デモ環境へのデプロイ」はJenkinsの場合と同じ方法でデモサーバにデプロイします。
- push-docker-image
  - 「ユニットテスト及びコード解析」＞「デモ環境へのデプロイ」を順に行います。  

