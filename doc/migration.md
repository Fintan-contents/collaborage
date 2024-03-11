データ移行
================================

ここでは、既存のCollaborage環境からCollaborage 2.1.0環境へのデータ移行を行います。  
Collaborage 1.0.0をお使いの方は、こちらの[マイグレーション手順](https://github.com/Fintan-contents/collaborage/blob/1.1.0/doc/aws.md#%E3%83%9E%E3%82%A4%E3%82%B0%E3%83%AC%E3%83%BC%E3%82%B7%E3%83%A7%E3%83%B3)もご参照ください。  
Collaborage 2.0.0をお使いの方は、こちらの[Rocket.Chat用DBのダウングレード](#rocketchat用dbのダウングレード)、[GitLab用DBのダウングレード](#gitlab用dbのダウングレード)もご参照ください。

# 前提
- 各ミドルウェアのマイグレーション前後のバージョンは下記を想定しています。  
  移行形態はそれぞれ以下の内容を指します。
  - 完全移行  
    移行元環境でのデータを完全に移行します。
  - 一部以降  
    移行元環境でのデータを可能な限り移行しますが、一部個別の移行手順・再インストールが必要になります。  
    個別での移行が必要になるものは以下となります。
    - Redmine: 追加でインストールしたプラグイン
    - SonarQube: 追加でインストールしたプラグイン
  - パイプライン再作成＋参照環境作成  
    パイプラインのデータの移行を行うとエラーが発生するため、手動での再登録を行います。  
    その際、移行元のアプリの参照を行えるよう参照用環境を作成します。
  
  | サーバ | コンテナ　                           | 変更前　    | 変更後　     | 移行形態             |
  |:----|:--------------------------------|---------|:---------|:-----------------| 
  | 共通  | Docker                          | -       | 20.10.23 | -                |
  |     | Docker Compose                  | 1.14.0  | 2.18.1   | -                |
  | CQ  | Apache HTTP Server              | 2.2.34  | 2.4.57   | 移行対象データなし        |
  |     | Apache Subversion               | 1.12.2  | 1.14.2   | 完全移行             |
  |     | Redmine                         | 3.3.4   | 4.2.10   | 一部移行             |
  |     | Redmine DB(PostgreSQL)          | 9.5.7   | 15.3     | -                |
  |     | Rocket.Chat                     | 2.0.0   | 5.4.9    | 完全移行　            |
  |     | Rocket.Chat DB(MongoDB)         | 3.6.9   | 5.0.25   | -                |
  |     | Rocket.Chat レプリケーションDB(MongoDB) | 3.6.9   | 5.0.25   | -                |
  |     | SonarQube(Community Edition)    | 6.7.5   | 10.1.0   | 一部移行             |
  |     | SonarQube DB(PostgreSQL)        | 9.5.7   | 15.3     | -                |
  | CI  | Apache HTTP Server              | 1.14.0  | 2.4.57   | 移行対象データなし        |
  |     | Jenkins                         | 2.190.3 | 2.414.1  | パイプライン再作成＋参照環境作成 |
  |     | GitBucket                       | 4.31.1  | 4.38.4   | 完全移行             |
  |     | GitBucket DB(PostgreSQL)        | 9.5.7   | 15.3     | -                |
  |     | GitLab (Community Edition)      | 12.4.2  | 16.0.6   | パイプライン再作成＋参照環境作成 |
  |     | GitLab DB(PostgreSQL)           | 9.5.7   | 14.9     | -                |
  |     | GitLab Runner                   | 12.4.1  | 16.1.0   | -                |
  |     | Nexus Repository Manager 3  　   | 3.19.1  | 3.55.0   | 完全移行　            |
- 移行前のサーバと移行後のサーバは同一VPC上に存在していることを想定しています。

# 移行手順

- [事前準備](#事前準備)
- [Subversion](#subversion)
- [Redmine](#redmine)
- [Rocket.Chat](#rocketChat)
- [SonarQube](#sonarQube)
- [Nexus](#nexus)
- [GitBucket](#gitbucket)
- [Jenkins](#jenkins)
- [GitLab](#gitlab)
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

## Subversion

### 概要
- 下記データのバックアップ＋リストアを実施します。
  - リポジトリ情報
  - ユーザ情報

### 手順 
- 移行元サーバでバックアップを作成します。
  - SSHで移行先のCQサーバに接続します。
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
- 移行先サーバでバックアップのリストアを実行します。
  - SSHで移行先のCQサーバに接続します。
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
    $ sudo rm -f /data/svn/repo.dump
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
  - システム設定
  - ユーザ情報
  - チケット情報（バックログ等のデータ含む）
- Redmineのマイグレーションを実施します。
- pluginの移行を行います。

### 手順
- 移行元サーバでバックアップを作成します。
  - SSHで移行元のCQサーバに接続します。
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
- 移行先サーバでバックアップのリストアを実行します。
  - SSHで移行先のCQサーバに接続します。
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
    $ docker compose exec redmine bash -c "bundle exec rake db:migrate RAILS_ENV=production"
    $ docker compose exec redmine bash -c "bundle exec rake tmp:cache:clear RAILS_ENV=production"
    ```
    - `Could not find gem 'icalendar' in any of the gem sources listed in your Gemfile.`のエラーが発生した場合以下のコマンドを実行した上、再度実行します。
      ```
      $ docker compose exec redmine bash -c "gem install icalendar"
      ```
  - コンテナを再起動します。
    ```
    $ docker compose restart redmine
    $ ./redmine-sub-uri.sh
    ```
  - SSHを切断します。
    ```
    $ exit
    ```
- pluginの移行を行います。
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
  - アプリ設定
  - ユーザ情報
  - チャットログ
- Rocket.Chat のマイグレーションを行います。

### 手順
- 移行元サーバでバックアップを作成します。
  - SSHで移行元のCQサーバに接続します。
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
- 移行先サーバでバックアップのリストアを実行します。
  - SSHで移行先のCQサーバに接続します。
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
    $ sudo cp ~/nop/backup/rocketchat/rocketchat-db.dump /data/rocketchat-db/
    $ docker exec rocketchat-db sh -c "mongorestore --archive=data/db/rocketchat-db.dump --drop"
    $ sudo rm -rf /data/rocketchat-db/rocketchat-db.dump
    ```
  - Rocket.Chat のマイグレーションを行います。  
    - Rocket.Chat のデータのマイグレーションは特定のバージョンにアップグレード後、docker起動時に自動的に実施されるため、段階的にバージョンアップを行います。
      - バージョンアップは「3.9.7」→「4.8.7」→「5.4.9」の順に行います。
    - アプリのコンテナを停止します。
      ```
      $ docker compose stop rocketchat && docker compose rm -f rocketchat
      ```
    - docker-compose.yml を変更します。
      ```
      $ vi docker-compose.yml
      ```
      - rocketchatのimage、environmentを修正します。
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
  - ユーザ情報
  - コード解析結果
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
    $ sudo rm -rf {/data/sonarqube-db/*,/data/sonarqube}
    $ exit
    $ sudo mkdir -p /data/sonarqube/data
    $ sudo mkdir -p /data/sonarqube/extensions
    $ sudo mkdir -p /data/sonarqube/bundled-plugins
    $ sudo chmod -R 777 /data/sonarqube
    ```
  - DBコンテナを起動します。
    ```
    $ docker compose up -d sonarqube-db
    ```
  - DBのバックアップをリストアします。
    ```
    $ sudo cp ~/nop/backup/sonarqube/sonarqube-db.dump /data/sonarqube-db/
    $ docker exec sonarqube-db bash -c "pg_restore -U sonar -h localhost -d sonar /var/lib/postgresql/data/sonarqube-db.dump"
    $ sudo rm -rf /data/sonarqube-db/sonarqube-db.dump
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
      - image、environmentを修正します。
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


## Nexus

### 概要
- 下記データのバックアップ＋リストアを実施します。
  - システム設定
  - ユーザ情報
  - リポジトリ情報

### 手順
- 移行元サーバでバックアップを作成します。
  - SSHで移行元のCIサーバに接続します。
  - バックアップ用のディレクトリを作成します。
    ```
    $ mkdir ~/nop/backup/nexus
    ```
  - コンテナを停止します。
    ```
    $ cd nop/docker/ci
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

## GitBucket

### 概要
- 下記データのバックアップ＋リストアを実施します。
  - システム設定
  - ユーザ情報
  - リポジトリ

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
    $ scp -r centos@<移行元nop-ci>:nop/backup/gitbucket/ nop/backup/
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
    $ sudo rm -rf /data/gitbucket-db/gitbucket-db.dump
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
- [JenkinsでのCI追加](./dev.md#jenkinsでのci追加)を参照して、設定を行います。
  - JDK17以外のバージョンが必要な場合は、以下の手順で追加してください。
    - Jenkinsに管理者でログインします。
    - 「Jenkinsの管理」＞「Tools」を選択します。
    - 「JDK追加」をクリックします。入力欄が表示されます。
    - 「インストーラーの追加」プルダウン＞「*.zip/*.tar.gz展開」を選択します。
    - 各項目を入力します。  
      以下はJDK11を追加する場合の例です。
      - 名前: JDK11
      - 自動インストール: on
      - *.zip/*.tar.gz展開
        - アーカイブダウンロードURL: `https://qiita.com/boushi-bird@github/items/49627b6a355ea2dfa57a#インストールするjdkを設定する` を参考に入力します。  
          以下に例を示します。
          ```
          https://download.java.net/java/GA/jdk11/9/GPL/openjdk-11.0.2_linux-x64_bin.tar.gz
          ```
        - アーカイブを展開するサブディレクトリ: 前述のサイトを参考にしてを指定します。  
          以下に例を示します。
          ```
          jdk-11.0.2
          ```
    - 追加したJDKはJenkinsfileで以下のように設定して使用します。
      ```
      pipeline {
        (略)
        tools {
          jdk 'JDK11'
        }
      ```
- パイプラインを再設定します。
  - パイプラインの設定時、Jenkinsfileで使用中の引数の名称変更・追加があるので、変更を行ってください。
    - environment
      - `SONAR_TOKEN` を追加します。
        - SonarQubeのトークンを設定してください。
        - トークンの設定方法は [JenkinsでのCI追加](./dev.md#jenkinsでのci追加)を参照してください。
      - `PROJECT_KEY = "${JOB_NAME}".replaceAll("/", ":")` を追加します。
        - SonarQubeのプロジェクトキーとして使用します。
    - Code analysis
      - `mvn sonar:sonar`の引数を修正します。
        - `-Dsonar.branch=${BRANCH_NAME}`を削除します。
        - `-Dsonar.token=${SONAR_TOKEN}`、`-Dsonar.projectKey=${PROJECT_KEY}`、`-Dsonar.projectName=${PROJECT_KEY}`を追加します。
        - 設定例
          ```
          sh 'mvn sonar:sonar -s ci/settings.xml -Dsonar.token=${SONAR_TOKEN} -Dsonar.host.url=${SONAR_HOST_URL} -Dsonar.projectKey=${PROJECT_KEY} -Dsonar.projectName=${PROJECT_KEY}'
          ```
    - rocketSend message
      - Rocket.Chatのバージョンアップに伴い、emojiの無効化、Jenkinsへのリンクの無効化が発生しているため、修正します。
        - 設定例
          ```
          post {
            always { junit 'target/surefire-reports/**/*.xml' }
            success { rocketSend message: ":blush: Unit test, ${JOB_NAME} #${BUILD_ID}, ${BUILD_URL}", rawMessage: true }
            failure { rocketSend message: ":sob: Unit test, ${JOB_NAME} #${BUILD_ID}, ${BUILD_URL}", rawMessage: true }
          }
          ```
- 既存のパイプラインを削除します。
  - Jenkinsに管理者でログインします。
  - 「ダッシュボード」＞「jakartaee-hello-world」を選択します。
  - 「Multibranch Pipelineの削除」を選択します。
  - 「はい」を選択します。
- pluginの移行を行います。
  - collaborage環境作成後にpluginの追加インストールを行っている場合、pluginごとに案内されている手順に従ってデータ移行を行うか、設定を保存した上で再インストールを行ってください。

## GitLab

### 概要
- パイプラインを再登録します。
- 既存のデータを参照が必要な場合は移行後のサーバに参照用の環境を作成してください。
  手順は[参照用環境の作成](#参照用環境の作成)を参照してください。

### 手順
- CIサーバにNexusへの認証情報を保存するためにDockerで一度ログインします。
  ```
  $ docker login -u admin -p <変更したパスワード> <NexusのホストのIPアドレス>:19081
  ```
  - 例を示します。
    ```
    $ docker login -u admin -p pass123- 192.0.2.3:19081
    ```
- [GitLabでのリポジトリ追加](./dev.md#gitlabでのリポジトリ追加)を参照して、設定を行います。
  - 登録するリポジトリは移行元GitLabのリポジトリを使用します。
    - 作業PCの適当な場所で次のコマンドを実行します。
      ```
      $ git clone <移行元のリポジトリのURL>
      $ cd <プロジェクのトディレクトリ>/
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
      - master以外に移行したいブランチがある場合は続けてpushします。
- ビルド結果の通知設定を行います。  
  [GitLabでのCI追加](./dev.md#gitlabでのci追加)も参照して作業を行ってください。
- パイプラインのパラメータを変更します。  
  [GitLabでのCI追加](./dev.md#gitlabでのci追加)も参照して作業を行ってください。
  - パイプラインの設定時、.gitlab-ci.ymlで使用中の引数の名称変更・追加があるので、変更を行ってください。
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
- 既存のプロジェクトを削除します。
  - GitLabに管理者でログインします。
  - 画面左上のアイコン（MainMenu）＞「Admin」＞「Overview」＞「Projects」を選択します。
  - 「jakartaee-hello-world」の「Delete」を選択します。


## 参照用環境の作成
必要に応じて参照用の環境を作成します。
Jenkins、GitLabはマウントディレクトリやDBのリストアを行っても、大きくバージョンが変更されると履歴の閲覧等ができなくなります。
移行後の環境ではパイプラインを再作成していますが、中には過去のビルドの失敗時履歴を参照したい、といったケースがあることも想定されます。
そのため、本手順により参照用の環境の作成を案内してします。

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
    $ sudo tar cvzf ~/nop/backup/jenkins/jenkins.tar.gz -C /data jenkins
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
        jenkins:
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
    - 参照のみに使用するため、不要処理（apt-get関連処理）をコメントアウトします。
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
            - gitbucket
        #    - nexus.repository
        ```
  - 設定情報をリストアします。
    ```
    $ sudo mkdir /data/ref 
    $ sudo tar xvfz ~/nop/backup/gitlab/gitlab.tar.gz  -C /data/ref
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
      - ターゲットタイプ: インスタンス
      - プロトコル: HTTP
      - ターゲット
        - インスタンス: CIサーバのインスタンス
        - ポート：参照用ポート番号
    - ロードバランサー
      - ロードバランサータイプ: アプリケーションロードバランサー
      - VPC: 自身の環境のVPC
      - セキュリティグループ: 自身の環境のALb用セキュリティグループ
      - プロトコル: HTTPS
      - デフォルトアクション: 作成したターゲットグループ
    - レコードセット
      - レコードセットの設定方法は [Route53でサブドメインを追加して、各アプリにアクセスできるようにします](./aws.md#route53でサブドメインを追加して各アプリにアクセスできるようにします)を参照してください。
        - ロードバランサー: 作成したロードバランサー
    - ポートの開放
      - CIサーバのセキュリティグループのインバウンドルールを追加します。
      - 開放済の場合は不要です。
        - プロトコル: カスタムTCP
        - ポート: 参照用ポート番号
        - ソース: 自身の環境のALB用セキュリティグループ
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

# Rocket.Chat用DBのダウングレード
- Rocket.Chat用のDB（MongoDB）のバージョンを6.0.6から5.0.25にダウングレードします。  
  ダウングレードの実施理由は[Changelog](../CHANGELOG.md#210---2024-03-dd)を参照してください。

### 概要
- 下記データのバックアップを実施し、DBのダウングレード後リストアを行います。
  - アプリ設定
  - ユーザ情報
  - チャットログ

### 手順
- バックアップを作成します。
  - SSHでCIサーバに接続します。
  - バックアップ用のディレクトリを作成します。
    ```
    $ mkdir -p ~/nop/backup/rocketchat
    ```
  - コンテナを停止します。
    ```
    $ cd nop/docker/cq
    $ docker compose stop rocketchat && docker compose rm -f rocketchat
    ```
  - DBのバックアップを作成します。
    ```
    $ docker exec rocketchat-db sh -c "mongodump --archive" > ~/nop/backup/rocketchat/rocketchat-db.dump
    ```
  - DBを停止します。
    ```
    $ docker compose stop rocketchat-db mongo-init-replica && docker compose rm -f rocketchat-db mongo-init-replica
    ```
- DBコンテナのイメージを変更します。
  - docker-compose.ymlを編集します。
    ```
    $ vi docker-compose.yml
    ```
    ```
    rocketchat-db:
      container_name: rocketchat-db
      #image: mongo:6.0.6
      image: mongo:5.0.25
    ```
    ```
    mongo-init-replica:
      #image: mongo:6.0.6
      image: mongo:5.0.25
    ```
  - 既存のデータディレクトリを削除します。
    ```
    $ sudo su -
    $ sudo rm -rf /data/rocketchat-db/*
    $ exit
    ```
  - DBコンテナを起動します。
    ```
    $ docker compose up -d rocketchat-db mongo-init-replica
    ```
- バックアップをリストアします。
  - DBのバックアップをリストアします。
    ```
    $ sudo cp ~/nop/backup/rocketchat/rocketchat-db.dump /data/rocketchat-db/
    $ docker exec rocketchat-db sh -c "mongorestore --archive=data/db/rocketchat-db.dump --drop"
    $ sudo rm -rf /data/rocketchat-db/rocketchat-db.dump
    ```
  - コンテナを起動します。
    ```
    $ docker compose up -d rocketchat
    ```
- 動作確認を行います。
  - ブラウザでアクセスします。
    ```
    <CQサーバのホスト>/rocketchat
    ```
  - ログインしてデータの移行ができていることを確認します。

- 動作確認完了後、作成したバックアップファイルを削除します。
  - バックアップ用データ配置用のディレクトリを削除します
    ```
    $ rm -rf ~/nop/backup
    ```
  - SSHを切断します。
    ```
    $ exit
    ```

# GitLab用DBのダウングレード
- GitLab用のDB（PostgreSQL）のバージョンを15.3から14.9にダウングレードします。  
  ダウングレードの実施理由は[Changelog](../CHANGELOG.md#210---2024-03-dd)を参照してください。

### 概要
- 下記データのバックアップを実施し、DBのダウングレード後リストアを行います。
  - リポジトリ情報（パイプライン、issue等の情報を含む）
  - ユーザ情報

### 手順
- バックアップを作成します。
  - SSHでCIサーバに接続します。
  - バックアップ用のディレクトリを作成します。
    ```
    $ mkdir -p ~/nop/backup/gitlab
    ```
  - コンテナを停止します。
    ```
    $ cd nop/docker/ci
    $ docker compose stop gitlab gitlab-runner && docker compose rm -f gitlab gitlab-runner
    ```
  - DBのバックアップを作成します。
    ```
    $ docker exec gitlab-db bash -c "pg_dump -U gitlab -h localhost -Fc --file=/var/lib/postgresql/data/gitlab-db.dump gitlab"
    $ sudo cp /data/gitlab-db/gitlab-db.dump ~/nop/backup/gitlab
    ```
  - DBを停止します。
    ```
    $ docker compose stop gitlab-db && docker compose rm -f gitlab-db 
    ```
- DBコンテナのイメージを変更します。
  - docker-compose.ymlを編集します。
    ```
    $ vi docker-compose.yml
    ```
    ```
    gitlab-db:
      container_name: gitlab-db
      #image: postgres:15.3-alpine
      image: postgres:14.9-alpine
    ```
  - 既存のデータディレクトリを削除します。
    ```
    $ sudo su -
    $ sudo rm -rf /data/gitlab-db/*
    $ exit
    ```
  - DBコンテナを起動します。
    ```
    $ docker compose up -d gitlab-db
    ```
- バックアップをリストアします。
  - DBのバックアップをリストアします。
    ```
    $ sudo cp ~/nop/backup/gitlab/gitlab-db.dump /data/gitlab-db/
    $ docker exec gitlab-db bash -c "pg_restore -U gitlab -h localhost -d gitlab /var/lib/postgresql/data/gitlab-db.dump"
    $ sudo rm -rf /data/gitlab-db/gitlab-db.dump
    ```
  - コンテナを起動します。
    ```
    $ docker compose up -d gitlab gitlab-runner
    ```
- 動作確認を行います。
  - ブラウザでアクセスします。
    ```
    <CIサーバのホスト>/gitlab
    ```
  - ログインしてデータの移行ができていることを確認します。

- 動作確認完了後、作成したバックアップファイルを削除します。
  - バックアップ用データ配置用のディレクトリを削除します
    ```
    $ rm -rf ~/nop/backup
    ```
  - SSHを切断します。
    ```
    $ exit
    ```
  