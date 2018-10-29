パイプライン
================================================================

ここでは、Collaborageが提供するパイプラインの内容を簡単に説明します。

- [Jenkins](#jenkins)
- [Concourse](#concourse)



# Jenkins


![](images/jenkins-pipeline.png)

- 「ユニットテスト」＞「コード解析」＞「デモ環境へのデプロイ」を順に行います。
- 「ユニットテスト」は「mvn -P gsp generate-resources」「mvn test」を実行しレポート出力します。
- 「コード解析」は「mvn sonar:sonar」を実行し、SonarQubeにコード解析結果を連携します。
- 「デモ環境へのデプロイ」はdevelopブランチのみ行います。develop以外のブランチはデプロイしません。
- 「デモ環境へのデプロイ」は次の処理で行っています。
  - 「mvn -P gsp generate-resources」「mvn waitt:jar」を実行して、初期データとExecutable Jarを作成します。
  - 初期データとExecutable Jar、Dockerfile、アプリ起動スクリプトをsshpassを使ってデモサーバに送信し、アプリ起動スクリプトを実行します。


# Concourse


![](images/concourse-pipeline.png)

- 「ユニットテスト」＞「コード解析」＞「デモ環境へのデプロイ」を順に行います。
- 「ユニットテスト」は「mvn -P gsp generate-resources」「mvn test」を実行します。
  Concourseには、Jenkinsのようなレポート出力がないので、実行ログでテストNGを確認します。
  - Jenkinsのようなレポート出力したい場合は[Concourse CIでビルドした結果をS3互換なオブジェクトストレージサーバMinioにアップロードする](http://qiita.com/tenten0213/items/52d28122fbeeb8fce86d)を参考に対応してください。
- 「コード解析」は「mvn verify  sonar:sonar」を実行し、SonarQubeにコード解析結果を連携します。
- 「デモ環境へのデプロイ」はdevelopブランチのみ行います。develop以外のブランチはデプロイしません。
- 「デモ環境へのデプロイ」はJenkinsの場合と同じ方法でデモサーバにデプロイします。

