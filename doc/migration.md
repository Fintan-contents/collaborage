データ移行
================================

ここでは、既存のCollaborage環境からCollaborage 2.0.0環境へのデータ移行を行います。

# 前提
- 各ミドルウェアのマイグレーション前後のバージョンは下記を想定しています。
  
  | サーバ | コンテナ　              | 変更前　                                        | 変更後　                                | 移行形態             |
  |:----|:-------------------|:--------------------------------------------|:------------------------------------|:-----------------| 
  | 共通  | docker             |                                             | 20.10.23                            | -                |
  |     | docker compose     | 1.14.0                                      | v2.18.1                             | -                |
  | cq  | proxy              | httpd:2.2.34-alpine                         | httpd:2.4.57-alpine                 | 移行対象データなし        |
  |     | subversion         | alpine:3.10.3<br/>subversion:1.12.2         | alpine:3.18.0<br/>subversion:1.14.2 | 完全移行             |
  |     | redmine            | redmine:3.3.4-passenger                     | redmine:4.2.10-passenger            | 一部移行             |
  |     | redmine-db         | postgres:9.5.7-alpine                       | postgres:15.3-alpine                | 完全移行             |
  |     | rocketchat         | rocket.chat:2.0.0                           | rocket.chat:5.4.9                   | -　               |
  |     | rocketchat-db      | mongo:3.6.9                                 | mongo:6.0.6                         | 完全移行             |
  |     | mongo-init-replica | mongo:3.6.9                                 | mongo:6.0.6                         | 移行対象データなし        |
  |     | sonarqube          | sonarqube:6.7.5-alpine                      | sonarqube:10.1.0-community          | -                |
  |     | sonarqube-db       | postgres:9.5.7-alpine                       | postgres:15.3-alpine                | 完全移行             |
  | ci  | proxy              | httpd:2.2.34-alpine                         | httpd:2.4.57-alpine                 | 移行対象データなし        |
  |     | jenkins            | jenkins/jenkins:2.190.3                     | jenkins/jenkins:2.401.1             | パイプライン再作成＋参照環境作成 |
  |     | gitbucket          | openjdk:jre-alpine<br/>GITBUCKET_VER 4.31.1 | gitbucket/gitbucket:4.38.4          | 完全移行             |
  |     | gitbucket-db       | postgres:9.5.7-alpine                       | postgres:15.3-alpine                | 完全移行             |
  |     | gitlab             | gitlab/gitlab-ce:12.4.2-ce.0                | gitlab/gitlab-ce:16.0.1-ce.0        | パイプライン再作成＋参照環境作成 |
  |     | gitlab-db          | postgres:9.5.7-alpine                       | postgres:15.3-alpine                | パイプライン再作成＋参照環境作成 |
  |     | gitlab-runner      | gitlab/gitlab-runner:ubuntu-v12.4.1         | gitlab/gitlab-runner:ubuntu-v16.1.0 | パイプライン再作成＋参照環境作成 |
  |     | nexus.repository   | sonatype/nexus3:3.19.1                      | sonatype/nexus3:3.55.0              | 完全移行　            |
- 移行前のサーバと移行後のサーバは同一VPC上に存在していることを想定しています。

# 移行手順

- [事前準備](#事前準備)
- [subversion](#subversion)
- [Redmine](#redmine)
- [Rocket.Chat](#rocketChat)
- [SonarQube](#sonarQube)
- [GitBucket](#gitbucket)
- [Jenkins](#jenkins)
- [GitLab](#gitlab)
- [Nexus](#nexus)
- [参照用環境の作成](#参照用環境の作成)
- [バックアップの削除](#バックアップの削除)

## 事前準備
- 各サーババックアップ用データ配置用のディレクトリを作成します。
  - 移行先のCIサーバにSSH で接続します。
  - バックアップ用データ配置用のディレクトリを作成します。
    ```
    $ mkdir ~/nop/backup/
    ```
  - 移行先のCIサーバ、移行元のCQサーバ、CIサーバにも同様にディレクトリを作成します。

## subversion

### 概要
- 下記データのバックアップ＋リストアを実施します。
  - ファイル情報
  - マウントディレクトリ

### 手順 
- 移行元サーバーでバックアップを作成します。
  - SSHで移行先のCQサーバーに接続します。
  - バックアップ用のディレクトリを作成します。
    ```
    $ mkdir ~/nop/backup/svn
    ```
  - ファイル情報のバックアップを作成します。
    ```
    $ cd nop/docker/cq
    $ docker exec subversion ash -c "svnadmin dump /var/svn/repo/" > ~/nop/backup/svn/repo.dump
    ```
  - コンテナを停止します。
    ```
    $ docker-compose stop subversion
    ```
  - ユーザ情報のバックアップを作成します。
    ```
    $ sudo tar cvzf ~/nop/backup/svn/svn-davsvn-htpasswd.tar.gz -C /data svn-davsvn-htpasswd
    ```
  - コンテナを起動します。
    ```
    $ docker-compose start subversion
    ```
  - SSHを切断します。
    ```
    $ exit
    ```
- 移行先サーバーでバックアップのリストアを実行します。
  - SSHで移行先のCQサーバーに接続します。
  - バックアップデータを移行元から移行先に移動します。
    ```
    $ scp -r centos@<移行元nop-cq>:nop/backup/svn/ nop/backup/
    ```
  - コンテナを停止します。
    ```
    $ cd ~/nop/docker/cq
    $ docker compose stop subversion && docker compose rm -f subversion
    ```
  - 既存のデータを削除します。
    ```
    $ sudo rm -rf {/data/svn/*,/data/svn-davsvn-htpasswd/*}
    ```
  - ユーザ情報をリストアします。
    ```
    $ sudo tar xvfz ~/nop/backup/svn/svn-davsvn-htpasswd.tar.gz -C /data
    ```
  - コンテナを起動します。
    ```
    $ docker compose up -d subversion
    ```
  - ファイル情報のバックアップをリストアします。
    ```
    $ sudo cp ~/nop/backup/svn/repo.dump /data/svn/
    $ docker exec subversion ash -c "svnadmin load /var/svn/repo/ < /var/svn/repo.dump"
    ```
  - コンテナを再起動します。
    ```
    $ docker compose restart subversion
    ```
  - SSHを切断します。
    ```
    $ exit
    ```
- 動作確認を行います。
  - 任意のSVNクライアント(TortoiseSVN等)でアクセスします。  
    (ブラウザを使用した場合、プロトコルが強制的に変更されアクセスできないことがありますので、SVNクライアントの使用をお勧めします。)
    ```
    <CQサーバのホスト>/svn/repo/
    ```
  - 移行元環境に存在するユーザでログインします。
  - 移行元環境のファイルが存在することを確認します。

## Redmine

### 概要
- 下記データのバックアップ＋リストアを実施します。
  - データベース
  - マウントディレクトリ
- Redmineのマイグレーションを実施します。
- pluginの移行を行います。

### 参考
- [Backing up and restoring Redmine](https://www.redmine.org/projects/redmine/wiki/RedmineBackupRestore)
- [Redmineガイド - アップグレード](http://guide.redmine.jp/RedmineUpgrade/)

### 手順
- 移行元サーバーでバックアップを作成します。
  - SSHで移行元のCQサーバーに接続します。
  - バックアップ用のディレクトリを作成します。
    ```
    $ mkdir ~/nop/backup/redmine
    ```
  - コンテナを停止します。
    ```
    $ cd nop/docker/cq
    $ docker-compose stop redmine
    ```
  - DBのバックアップを作成します。
    ```
    $ docker exec redmine-db bash -c "pg_dump -U redmine -h localhost -Fc --file=/var/lib/postgresql/data/redmine-db.dump redmine"
    $ sudo mv /data/redmine-db/redmine-db.dump ~/nop/backup/redmine
    ```
  - 添付ファイルのバックアップを作成します。
    ```
    $ sudo tar cvzf ~/nop/backup/redmine/redmine-files.tar.gz -C /data redmine-files
    ```
  - コンテナを起動します。
    ```
    $ docker-compose start redmine
    ```
  - SSHを切断します。
    ```
    $ exit
    ```
- 移行先サーバーでバックアップのリストアを実行します。
  - SSHで移行先のCQサーバーに接続します。
  - バックアップデータを移行元から移行先に移動します。
    ```
    $ scp -r centos@<移行元nop-cq>:nop/backup/redmine/ nop/backup/
    ```
  - アプリ、DBのコンテナを停止します。
    ```
    $ cd ~/nop/docker/cq
    $ docker compose stop redmine redmine-db && docker compose rm -f redmine redmine-db
    ```
  - 既存のデータディレクトリを削除します。
    ```
    $ sudo su -
    $ sudo rm -rf {/data/redmine-db/*,/data/redmine-files/*}
    $ exit
    ```
  - DBコンテナを起動します。
    ```
    $ docker compose up -d redmine-db
    ```
  - DBのバックアップをリストアします。
    ```
    $ sudo cp ~/nop/backup/redmine/redmine-db.dump /data/redmine-db/
    $ docker exec redmine-db bash -c "pg_restore -U redmine -h localhost -d redmine /var/lib/postgresql/data/redmine-db.dump"
    $ sudo rm -rf /data/redmine-db/redmine-db.dump
    ```
  - 添付ファイルをリストアします。
    ```
    $ sudo tar xvfz ~/nop/backup/redmine/redmine-files.tar.gz -C /data
    ```
  - コンテナを起動します。
    ```
    $ docker compose up -d redmine
    ```
  - マイグレーションコマンドを実行します。
    ```
    docker compose exec redmine bash -c "bundle exec rake db:migrate RAILS_ENV=production"
    docker compose exec redmine bash -c "bundle exec rake tmp:cache:clear RAILS_ENV=production"
    ```
  - コンテナを再起動します。
    ```
    docker compose restart redmine
    ./redmine-sub-uri.sh
    ```
  - SSHを切断します。
    ```
    $ exit
    ```
- pluginの再インストールをします。
  - collaborage環境作成後にpluginの追加インストールを行っている場合、pluginごとに案内されている手順に従ってデータ移行を行うか、設定を保存した上で再インストールを行ってください。
- 動作確認を行います。
  - ブラウザでアクセスします。
    ```
    <CQサーバのホスト>/redmine
    ```
  - ログインしてデータの移行ができていることを確認します。

## Rocket.Chat
### 概要
- 下記データのバックアップ＋リストアを実施します。
  - データベース
- Rocket.Chat のマイグレーションを行います。

### 参考
- [Docker Mongo Backup and Restore](https://docs.rocket.chat/deploy/prepare-for-your-deployment/rapid-deployment-methods/docker-and-docker-compose/docker-mongo-backup-and-restore)

### 手順
- 移行元サーバーでバックアップを作成します。
  - SSHで移行元のCQサーバーに接続します。
  - バックアップ用のディレクトリを作成します。
    ```
    $ mkdir ~/nop/backup/rocketchat
    ```
  - コンテナを停止します。
    ```
    $ cd nop/docker/cq
    $ docker-compose stop rocketchat
    ```
  - DBのバックアップを作成します。
    ```
    $ docker exec rocketchat-db sh -c "mongodump --archive" > ~/nop/backup/rocketchat/rocketchat-db.dump
    ```
  - コンテナを起動します。
    ```
    $ docker-compose start rocketchat
    ```
  - SSHを切断します。
    ```
    $ exit
    ```
- 移行先サーバーでバックアップのリストアを実行します。
  - SSHで移行先のCQサーバーに接続します。
  - バックアップデータを移行元から移行先に移動します。
    ```
    $ scp -r centos@<移行元nop-cq>:nop/backup/rocketchat/ nop/backup/
    ```
  - アプリのコンテナを停止します。
    ```
    $ cd ~/nop/docker/cq
    $ docker compose stop rocketchat && docker compose rm -f rocketchat
    ```
  - DBのバックアップをリストアします。
    ```
    $ docker exec -i rocketchat-db sh -c "mongorestore --archive" < ~/nop/backup/rocketchat/rocketchat-db2.dump
    ```
  - Rocket.Chat のマイグレーションを行います。  
    - Rocket.Chat のマイグレーションは特定のバージョンにアップグレード後、docker起動時に自動的に実施されるため、段階的にバージョンアップを行います。
      - バージョンアップは「3.9.7」→「4.8.7」→「5.4.9」の順に行います。
    - アプリのコンテナを停止します。
      ```
      $ docker compose stop rocketchat && docker compose rm -f rocketchat
      ```
    - docker-compose.yml を変更します。
      ```
      $ vi docker-compose.yml
      ```
      - rocketchatのimage、environment、MONGO_OPLOG_URLを修正します。
        - ～ 4.8.7 の場合
          ```
          rocketchat:
              image: rocket.chat:3.9.7
              （略）
              environment:
                MONGO_URL: mongodb://rocketchat-db:27017/rocketchat
                MONGO_OPLOG_URL: mongodb://rocketchat-db:27017/local
          ```
        - 5.4.9 ～ の場合
          ```
          rocketchat:
              image: rocket.chat:5.4.9
              （略）
              environment:
                MONGO_URL: mongodb://rocketchat-db:27017/rocketchat?replicaSet=rs0&directConnection=true
                MONGO_OPLOG_URL: mongodb://rocketchat-db:27017/local?replicaSet=rs0&directConnection=true
          ```
    - コンテナを起動します。
      ```
      $ docker compose up -d rocketchat
      ```
    - rocketchatの起動完了後、バージョン: 5.4.9 まで上記の手順を繰り返します。
  - SSHを切断します。
    ```
    $ exit
    ```
- 動作確認を行います。
  - ブラウザでアクセスします。
    ```
    <CQサーバのホスト>/rocketchat
    ```
  - ログインしてデータの移行ができていることを確認します。

## SonarQube
### 概要
- 下記データのバックアップ＋リストアを実施します。
  - データベース
- SonarQube のマイグレーションを行います。
- pluginの移行を行います。

### 手順
- 移行元サーバでバックアップを作成します。
  - SSHで移行元のCQサーバに接続します。
  - バックアップ用のディレクトリを作成します。
    ```
    $ mkdir ~/nop/backup/sonarqube
    ```
  - コンテナを停止します。
    ```
    $ cd nop/docker/cq
    $ docker-compose stop sonarqube
    ```
  - DBのバックアップを作成します。
    ```
    $ docker exec sonarqube-db bash -c "pg_dump -U sonar -h localhost -Fc --file=/var/lib/postgresql/data/sonarqube-db.dump sonar"
    $ sudo mv /data/sonarqube-db/sonarqube-db.dump ~/nop/backup/sonarqube
    ```
  - コンテナを起動します。
    ```
    $ docker-compose start sonarqube
    ```
  - SSHを切断します。
    ```
    $ exit
    ```
- 移行先サーバでバックアップのリストアを実行します。
  - SSHで移行先のCQサーバに接続します。
  - バックアップデータを移行元から移行先に移動します。
    ```
    $ scp -r centos@<移行元nop-cq>:nop/backup/sonarqube/ nop/backup/
    ```
  - アプリ、DBのコンテナを停止します。
    ```
    $ cd ~/nop/docker/cq
    $ docker compose stop sonarqube sonarqube-db && docker compose rm -f sonarqube sonarqube-db
    ```
  - 既存のデータディレクトリを再作成します。
    ```
    $ sudo su -
    $ sudo rm -rf /data/sonarqube-db/*
    $ exit
    ```
  - DBコンテナを起動します。
    ```
    $ docker compose up -d sonarqube-db
    ```
  - DBのバックアップをリストアします。
    ```
    $ sudo cp ~/nop/backup/sonarqube/sonarqube-db.dump /data/sonarqube-db/
    $ docker exec sonarqube-db bash -c "pg_restore -U sonar -h localhost -d sonar /var/lib/postgresql/data/sonarqube-db.dump"
    ```
  - SonarQube のマイグレーションを行います。
    - SonarQube のマイグレーションは特定のバージョンにアップグレード後、docker起動時にブラウザから実行する必要があるため、段階的にバージョンアップを行います。
      - バージョンアップは「7.9.6」→「8.9.9」→「9.9.1」→「10.1.0」の順に行います。
    - アプリのコンテナを停止します。
      ```
      $ docker compose stop sonarqube && docker compose rm -f sonarqube
      ```
    - docker-compose.yml を変更します。
      ```
      $ vi docker-compose.yml
      ```
      - image、environment、MONGO_OPLOG_URLを修正します。
        - バージョン: ～ 8.9.9 の場合
          ```
          sonarqube:
            container_name: sonarqube
            image: sonarqube:8.9.9-community
            （略）
            environment:
              SONARQUBE_JDBC_URL: jdbc:postgresql://sonarqube-db:5432/sonar
              SONARQUBE_JDBC_USERNAME: sonar
              SONARQUBE_JDBC_PASSWORD: sonar
          ```
        - バージョン: 9.9.1 ～ の場合
          ```
          sonarqube:
            container_name: sonarqube
            image: sonarqube:9.9.1-community
            （略）
            environment:
              SONAR_JDBC_URL: jdbc:postgresql://sonarqube-db:5432/sonar
              SONAR_JDBC_USERNAME: sonar
              SONAR_JDBC_PASSWORD: sonar
          ```
    - コンテナを起動します。
      ```
      $ docker compose up -d sonarqube
      ```
    - https:// <ブラウザからSonarQubeにアクセスする場合のURL>/setup にアクセスして「setup」を選択します。
    - マイグレーションの完了後、バージョン: 10.1.0 まで上記の手順を繰り返します。
  - SSHを切断します。
    ```
    $ exit
    ```
- pluginの移行を行います。
  - collaborage環境作成後にpluginの追加インストールを行っている場合、pluginごとに案内されている手順に従ってデータ移行を行うか、設定を保存した上で再インストールを行ってください。
- 動作確認を行います。
  - ブラウザでアクセスします。
    ```
    <CQサーバのホスト>/sonarqube
    ```
  - ログインしてデータの移行ができていることを確認します。

## GitBucket

### 概要
- 下記データのバックアップ＋リストアを実施します。
  - データベース
  - マウントディレクトリ

### 手順
- 移行元サーバでバックアップを作成します。
  - SSHで移行元のCIサーバに接続します。
  - バックアップ用のディレクトリを作成します。
    ```
    $ mkdir ~/nop/backup/gitbucket
    ```
  - コンテナを停止します。
    ```
    $ cd nop/docker/ci
    $ docker-compose stop gitbucket
    ```
  - DBのバックアップを作成します。
    ```
    $ docker exec gitbucket-db bash -c "pg_dump -U gitbucket -h localhost -Fc --file=/var/lib/postgresql/data/gitbucket-db.dump gitbucket"
    $ sudo mv /data/gitbucket-db/gitbucket-db.dump ~/nop/backup/gitbucket
    ```
  - ホームディレクトリのバックアップを作成します。
    ```
    $ sudo tar cvzf ~/nop/backup/gitbucket/gitbucket.tar.gz -C /data gitbucket
    ```
  - コンテナを起動します。
    ```
    $ docker-compose start gitbucket
    ```
  - SSHを切断します。
    ```
    $ exit
    ```
- 移行先サーバでバックアップのリストアを実行します。
  - SSHで移行先のCIサーバに接続します。
  - バックアップデータを移行元から移行先に移動します。
    ```
    $ scp -r centos@<移行元nop-cq>:nop/backup/gitbucket/ nop/backup/
    ```
  - アプリ、DBのコンテナを停止します。
    ```
    $ cd ~/nop/docker/ci
    $ docker compose stop gitbucket gitbucket-db && docker compose rm -f gitbucket gitbucket-db
    ```
  - 既存のデータディレクトリを削除します。
    ```
    $ sudo su -
    $ sudo rm -rf {/data/gitbucket/*,/data/gitbucket-db/*}
    $ exit
    ```
  - DBコンテナを起動します。
    ```
    $ docker compose up -d gitbucket-db
    ```
  - DBのバックアップをリストアします。
    ```
    $ sudo cp ~/nop/backup/gitbucket/gitbucket-db.dump /data/gitbucket-db/
    $ docker exec gitbucket-db bash -c "pg_restore -U gitbucket -h localhost -d gitbucket /var/lib/postgresql/data/gitbucket-db.dump"
    ```
  - ホームディレクトリをリストアします。
    ```
    $ sudo tar xvfz ~/nop/backup/gitbucket/gitbucket.tar.gz -C /data
    ```
  - コンテナを起動します。
    ```
    $ docker compose up -d gitbucket
    ```
  - SSHを切断します。
    ```
    $ exit
    ```
- 動作確認を行います。
  - ブラウザでアクセスします。
    ```
    <CIサーバのホスト>/gitbucket
    ```
  - ログインしてデータの移行ができていることを確認します。

## Jenkins
### 概要
- パイプラインを再登録します。  
- 既存のデータを参照が必要な場合は移行後のサーバに参照用の環境を作成してください。
- 手順は[参照用環境の作成](#参照用環境の作成)を参照してください。
- pluginの移行を行います。

### 手順
- Jenkinsのデータを削除します。  
  - SSHで移行先のCIサーバに接続します。
  - アプリのコンテナを停止します。
    ```
    $ cd nop/docker/ci
    $ docker compose stop jenkins && docker compose rm -f jenkins
    ```
  - 既存のデータを削除します。
    ```
    $ sudo su -
    $ sudo rm -rf /data/jenkins/*
    ```
  - アプリのコンテナを起動します。
    ```
    $ docker compose up -d jenkins
    ```
  - SSHを切断します。
    ```
    $ exit
    ```
- アプリの初期設定の[Jenkins](./init.md#jenkins)を参照して、設定を行います。
-  [JenkinsでのCI追加](./dev.md#jenkinsでのci追加)を参照して、設定を行います。
- パイプラインを再設定します。
  - パイプラインの設定時、Jenkinsfileで利用中の引数の名称変更・追加があるので、変更を行ってください。
    - environment
      - `SONAR_TOKEN` を追加します。
        - SonarQubeのトークンを設定してください。
        - トークンの設定方法は [JenkinsでのCI追加](./dev.md#jenkinsでのci追加)を参照してください。
      - `PROJECT_KEY = "${JOB_NAME}".replaceAll("/", ":")` を追加します。
        - SonarQubeのプロジェクトキーとして利用します。
    - Code analysis
      - `mvn sonar:sonar`の引数を修正します。
        - `-Dsonar.branch=${BRANCH_NAME}`を削除します。
        - `-Dsonar.token=${SONAR_TOKEN}`、`-Dsonar.projectKey=${PROJECT_KEY}`、`-Dsonar.projectName=${PROJECT_KEY}`を追加します。
        - 設定例
          ```
          sh 'mvn sonar:sonar -s ci/settings.xml -Dsonar.token=${SONAR_TOKEN} -Dsonar.host.url=${SONAR_HOST_URL} -Dsonar.projectKey=${PROJECT_KEY} -Dsonar.projectName=${PROJECT_KEY}'
          ```
- pluginの移行を行います。
  - collaborage環境作成後にpluginの追加インストールを行っている場合、pluginごとに案内されている手順に従ってデータ移行を行うか、設定を保存した上で再インストールを行ってください。

## GitLab

### 概要
- パイプラインを再登録します。
- 既存のデータを参照が必要な場合は移行後のサーバに参照用の環境を作成してください。
  手順は[参照用環境の作成](#参照用環境の作成)を参照してください。

### 手順
- GitLabのデータを削除します。  
  - SSHで移行先のCIサーバに接続します。
  - アプリのコンテナを停止します。
    ```
    $ cd nop/docker/ci
    $ docker compose stop gitlab gitlab-db && docker compose rm -f gitlab gitlab-db

  - 既存のデータを削除します。
    ```
    $ sudo su -
    $ sudo rm -rf /data/gitlab/*
    ```
  - アプリのコンテナを起動します。
    ```
    $ docker compose up -d gitlab gitlab-db
    ```
  - SSHを切断します。
    ```
    $ exit
    ```
- アプリの初期設定の[GitLab](./init.md#gitlab)を参照して、設定を行います。
- [GitLabでのリポジトリ追加](./dev.md#gitlabでのリポジトリ追加)を参照して、設定を行います。
  - 登録するリポジトリは移行元GitLabのリポジトリを利用します。
    - 作業PCの適当な場所で次のコマンドを実行します。
      ```
      $ git clone <移行元のリポジトリのURL>
      $ cd nablarch-example-web/
      $ git config --local user.name <作成したユーザのログインID>
      $ git config --local user.email <作成したユーザのメールアドレス>
      $ git remote set-url origin <移行先のリポジトリのURL>
      $ git push origin master
      ```
      - `! [rejected]        master -> master (non-fast-forward)` のようにpushがrejectされた場合、以下のコマンドで push します。
        ```
        $ git fetch
        $ git merge --allow-unrelated-histories origin/master
        $ git push origin master
        ```
- [GitLabでのCI追加](./dev.md#gitlabでのci追加)を参照して、設定を行います。
  - パイプラインの設定時、.gitlab-ci.ymlで利用中の引数の名称変更・追加があるので、変更を行ってください。
    - variables
      - `SONAR_TOKEN` を追加します。
        - SonarQubeのトークンを設定してください。
        - トークンの設定方法は [GitLabでのCI追加](./dev.md#gitlabでのci追加)を参照してください。
    - Build_Job
      - `mvn sonar:sonar`の引数を修正します。
        - `-Dsonar.branch=${CI_BUILD_REF_NAME}`を削除します。
        - `-Dsonar.token=${SONAR_TOKEN}`、`-Dsonar.projectKey=${CI_PROJECT_NAME}:${CI_COMMIT_REF_NAME}`、`-Dsonar.projectName=${CI_PROJECT_NAME}:${CI_COMMIT_REF_NAME}`を追加します。
        - 設定例
          ```
          - mvn sonar:sonar -Dsonar.host.url=http://${SONAR_HOST_URL}/sonarqube -Dsonar.token=${SONAR_TOKEN} -Dsonar.projectKey=${CI_PROJECT_NAME}:${CI_COMMIT_REF_NAME} -Dsonar.projectName=${CI_PROJECT_NAME}:${CI_COMMIT_REF_NAME} -s ci/settings.xml
          ```

## Nexus

### 概要
- 下記データのバックアップ＋リストアを実施します。
  - データベース

### 手順
- 移行元サーバでバックアップを作成します。
  - SSHで移行元のCIサーバに接続します。
  - バックアップ用のディレクトリを作成します。
    ```
    $ mkdir ~/nop/backup/nexus
    ```
  - コンテナを停止します。
    ```
    $ docker-compose stop nexus.repository
    ```
  - nexusのバックアップを作成します。
    - nexus/cache, nexus/tmp ディレクトリは移行対象から除外します。
      ```
      $ sudo tar cvzf ~/nop/backup/nexus/nexus.tar.gz --exclude nexus/cache --exclude nexus/tmp -C /data nexus
      ```
  - コンテナを起動します。
    ```
    $ docker-compose start nexus.repository
    ```
  - SSHを切断します。
    ```
    $ exit
    ```
- 移行先サーバでバックアップのリストアを実行します。
  - SSHで移行先のCIサーバに接続します。
  - バックアップデータを移行元から移行先に移動します。
    ```
    $ scp -r centos@<移行元nop-ci>:nop/backup/nexus/ nop/backup/
    ```
    - コンテナを停止します。
    ```
    $ cd ~/nop/docker/ci
    $ docker compose stop nexus.repository && docker compose rm -f nexus.repository
    ```
  - 既存のデータディレクトリを削除します。
    ```
    $ sudo rm -rf /data/nexus/* 
    ```
  - nexusのバックアップデータをリストアします。
    ```
    $ sudo tar xvfz ~/nop/backup/nexus/nexus.tar.gz -C /data
    ```
  - コンテナを起動します。
    ```
    $ docker compose up -d nexus.repository
    ```
  - SSHを切断します。
    ```
    $ exit
    ```
- 動作確認を行います。
  - ブラウザでアクセスします。
    ```
    <CIサーバのホスト>/nexus
    ```
  - ログインしてデータの移行ができていることを確認します。

## 参照用環境の作成
必要に応じて参照用の環境を作成します。
### 概要
- Jenkins または GitLab の参照用環境を作成します。
  - 移行先の環境にサブディレクトリに参照用環境を作成します。
  - 参照データは移行元のマウントディレクトリを移行先のマウントディレクトリにコピーして準備します。
- 外部からの接続設定を追加します。

### 手順

#### 参照用のJenkins環境を作成
- 移行元サーバでバックアップを作成します。
  - SSHで移行元のCIサーバに接続します。
    - バックアップ用のディレクトリを作成します。
      ```
      $ mkdir ~/nop/backup/jenkins
      ```
  - コンテナを停止します。
    ```
    $ cd nop/docker/ci
    $ docker-compose stop jenkins
    ```
  - バックアップを作成します。
    ```
    $ sudo tar cvzf ~/nop/backup/jenkins.tar.gz -C /data jenkins
    ```
  - コンテナを起動します。
    ```
    $ docker-compose start jenkins
    ```
  - docker環境作成用ファイルのバックアップを作成します。
    ```
    $ sudo cp ~/nop/docker/ci/docker-compose.yml ~/nop/backup/jenkins/
    $ sudo cp ~/nop/docker/ci/httpd.conf ~/nop/backup/jenkins/
    $ sudo cp ~/nop/docker/ci/dockerfiles/jenkins/Dockerfile ~/nop/backup/jenkins/
    ```
  - SSHを切断します。
    ```
    $ exit
    ```

- 移行先サーバで参照用の環境を作成します。
  - SSHで移行先のCIサーバに接続します。
  - バックアップデータを移行元から移行先に移動します。
    ```
    $ scp -r centos@<移行元nop-ci>:nop/backup/jenkins/ nop/backup/
    ```
  - 設定ファイルを移動します。
    ```
    $ mkdir  ~/nop/docker/ref 
    $ cp ~/nop/backup/jenkins/httpd.conf ~/nop/docker/ref
    $ cp ~/nop/backup/jenkins/docker-compose.yml ~/nop/docker/ref
    $ mkdir -p ~/nop/docker/ref/dockerfiles/jenkins
    $ cp ~/nop/backup/jenkins/Dockerfile ~/nop/docker/ref/dockerfiles/jenkins 
    $ cp ~/nop/backup/jenkins/docker-compose.yml ~/nop/docker/ref
    $ cd ~/nop/docker/ref
    $ cp ~/nop/docker/ci/common.env .
    ```
  - docker-compose.ymlを修正します。
    ```
    $ vi docker-compose.yml
    ```
    - proxy のportを変更します。
      ```
      ports:
        - "<参照用ポート番号>:80"
      ```
    - proxy, jenkinsのcontainer_nameを変更します。
      - proxy
        ```
        proxy:
          container_name: proxy-ref
        ```
      - jenkins
        ```
        gitlab:
          container_name: jenkins-ref
        ```
    - jenkinsのvolumesを変更します。
      - jenkins
        ```
        volumes:
          - /data/ref/jenkins:/var/jenkins_home
        ```
    - gitbucket, gitbucket-db, nexus.repositoryの設定をコメントアウトします。
      - Jenkinsの参照環境ではnexus.repositoryは不要となるため、コメントアウトします。
        - gitbucket
          ```
          #gitbucket:
          #  container_name: gitbucket
          (略)
          #  logging:
          #    options:
          #    max-size: "10m"
          #    max-file: "10"
          ```
        - gitbucket-db
          ```
          #gitbucket-db:
          #  container_name: gitbucket-db
          (略)
          #  logging:
          #    options:
          #    max-size: "10m"
          #    max-file: "10"
          ```
        - nexus.repository
          ```
          #nexus.repository:
          #  container_name: nexus.repository
          (略)
          #  logging:
          #    options:
          #    max-size: "10m"
          #    max-file: "10"
          ```
      - proxy > environment > no_proxy から gitbucket, nexus.repository を除外します。
        ```
        proxy:
          (略)
          environment:
            no_proxy: jenkins
        ```
      - proxy > depends_on の gitbucket, nexus.repository をコメントアウトします。
        ```
        proxy:
          container_name: proxy
          image: httpd:2.2.34-alpine
          (略) 
          depends_on:
            - jenkins
        #    - gitbucket
        #    - nexus.repository
        ```
  - Dockerfileを修正します。
    ```
    $ vi dockerfiles/jenkins/Dockerfile
    ```
    - 参照のみに利用するため、不要処理（apt-get関連処理）をコメントアウトします。
      ~~~
      FROM jenkins/jenkins:2.190.3

      USER root

      RUN echo "Acquire::http::proxy \"$http_proxy\";\nAcquire::https::proxy \"$https_proxy\";" > /etc/apt/apt.conf
      
      #RUN apt-get update -y \
      #&& apt-get -y install sshpass

      USER jenkins
      ~~~

  - 設定情報をリストアします。
    ```
    $ sudo mkdir /data/ref
    $ sudo tar xvfz ~/nop/backup/jenkins/jenkins.tar.gz  -C /data/ref
    ```
  - コンテナを起動します。
    ```
    $ docker compose up -d
    ```

#### 参照用のGitLab環境を作成
- 移行元サーバでバックアップを作成します。
  - SSHで移行元のCIサーバに接続します。
    - バックアップ用のディレクトリを作成します。
      ```
      $ mkdir ~/nop/backup/gitlab
      ```
  - コンテナを停止します。
    ```
    $ cd nop/docker/ci
    $ docker-compose stop gitlab gitlab-runner
    ```
  - バックアップを作成します。
    ```
    $ sudo tar cvzf ~/nop/backup/gitlab/gitlab.tar.gz -C /data gitlab
    $ sudo tar cvzf ~/nop/backup/gitlab/gitlab-db.tar.gz -C /data gitlab-db
    $ sudo tar cvzf ~/nop/backup/gitlab/gitlab-runner.tar.gz -C /data gitlab-runner
    ```
  - コンテナを起動します。
    ```
    $ docker-compose start gitlab gitlab-runner
    ```
  - docker環境作成用ファイルのバックアップを作成します。
    ```
    $ sudo cp ~/nop/docker/ci/docker-compose.yml ~/nop/backup/gitlab/
    $ sudo cp ~/nop/docker/ci/httpd.conf ~/nop/backup/gitlab/
    ```
  - SSHを切断します。
    ```
    $ exit
    ```

- 移行先サーバで参照用の環境を作成します。
  - SSHで移行先のCIサーバに接続します。
  - バックアップデータを移行元から移行先に移動します。
    ```
    $ scp -r centos@<移行元nop-ci>:nop/backup/gitlab/ nop/backup/
    ```
  - 設定ファイルを移動します。
    ```
    $ mkdir ~/nop/docker/ref 
    $ cp ~/nop/backup/gitlab/httpd.conf ~/nop/docker/ref
    $ cp ~/nop/backup/gitlab/docker-compose.yml ~/nop/docker/ref
    $ cd ~/nop/docker/ref
    $ cp ~/nop/docker/ci/common.env .
    ```
  - docker-compose.ymlを修正します。
    ```
    $ vi docker-compose.yml
    ```
    - proxy のportを変更します。
      ```
      ports:
        - "<参照用ポート番号>:80"
      ```
    - GitLab のexternal_urlを変更します。
      ```
      environment:
        GITLAB_OMNIBUS_CONFIG: |
          external_url '<ブラウザからGitLabにアクセスする場合のURL>'
      ```
    - 各アプリのcontainer_nameを変更します。
      - proxy
        ```
        proxy:
          container_name: proxy-ref
        ```
      - gitlab
        ```
        gitlab:
          container_name: gitlab-ref
        ```
      - gitlab-db
        ```
        gitlab-db:
          container_name: gitlab-db-ref
        ```
      - gitlab-runner
        ```
        gitlab-runner:
          container_name: gitlab-runner-ref
        ```
    - 各アプリのvolumesを変更します。
      - gitlab
        ```
        volumes:
          - /data/ref/gitlab/data:/var/opt/gitlab
          - /data/ref/gitlab/config:/etc/gitlab
        ```
      - gitlab-db
        ```
        volumes:
        - /data/ref/gitlab-db:/var/lib/postgresql/data
        ```
      - gitlab-runner
        ```
        volumes:
          (略)
          - /data/ref/gitlab-runner/config:/etc/gitlab-runner
          (略)
        ```
    - nexus.repository の設定をコメントアウトします。
      - GitLabの参照環境ではnexus.repositoryは不要となるため、コメントアウトします。
        ```
        #nexus.repository:
        #  container_name: nexus.repository
        (略)
        #  logging:
        #    options:
        #    max-size: "10m"
        #    max-file: "10"
        ```
      - proxy > environment > no_proxy から nexus.repository を除外します。
        ```
        proxy:
          (略)
          environment:
            no_proxy: gitlab
        ```
      - proxy > depends_on の nexus.repository をコメントアウトします。
        ```
        proxy:
          container_name: proxy
          image: httpd:2.2.34-alpine
          (略) 
          depends_on:
            - jenkins
        #    - gitbucket
        #    - nexus.repository
        ```
  - 設定情報をリストアします。
    ```
    $ sudo mkdir /data/ref 
    $ sudo tar xvfz ~/nop/backup/gitlab/gitlab.tar.gz  -C /data/refsudo tar xvfz ~/nop/backup/gitlab/gitlab.tar.gz  -C /data/ref
    $ sudo tar xvfz ~/nop/backup/gitlab/gitlab-db.tar.gz  -C /data/ref
    $ sudo tar xvfz ~/nop/backup/gitlab/gitlab-runner.tar.gz  -C /data/ref
    ```
  - コンテナを起動します。
    ```
    $ docker compose up -d
    ```

#### 外部からの接続設定
- Jenkins、GitLab共通の手順です。
- 外部からの接続設定をします。
  - AWSで下記のリソースの作成・参照用ポートの開放を行います。
    - ターゲットグループ
    - ロードバランサー
    - レコードセット
      - レコードセットの設定方法は [Route53でサブドメインを追加して、各アプリにアクセスできるようにします](./aws.md#route53でサブドメインを追加して各アプリにアクセスできるようにします)を参照してください。
    - ポートの開放
      - CIサーバへの接続が可能となるように設定します。
- 動作確認を行います。
  - ブラウザでアクセスします。
    - Jenkinsの場合
      ```
      <CIサーバのホスト>/jenkins
      ```
    - GitLabの場合
      ```
      <CIサーバのホスト>/gitlab
      ```
  - ログインしてデータの移行ができていることを確認します。

## バックアップの削除
- 各アプリの動作確認完了後、作成したバックアップファイルを削除します。
  - 移行先のCIサーバにSSH で接続します。
  - バックアップ用データ配置用のディレクトリを削除します。
    ```
    $ rm -rf ~/nop/backup
    ```
  - 移行先のCIサーバ、移行元のCQサーバ、CIサーバでも同様にディレクトリを削除します。