AMIから作成したEC2インスタンスの初期設定
================================================================

ここでは、Collaborageが提供するAMIから作成した各サーバの初期設定を行います。

ここでの作業内容は次の通りです。
- [データボリュームを定期的にバックアップするように設定します](#データボリュームを定期的にバックアップするように設定します)
- [CQサーバの設定を変更します](#cqサーバの設定を変更します)
- [CIサーバの設定を変更します](#ciサーバの設定を変更します)
- [Demoサーバの設定を変更します](#demoサーバの設定を変更します)
- [メトリクスが取得できていることを確認します](#メトリクスが取得できていることを確認します)
- [CloudWatchでディスク使用率にアラームを設定します](#cloudwatchでディスク使用率にアラームを設定します)
- [CloudWatchでバックアップ失敗時の通知を設定します](#cloudwatchでバックアップ失敗時の通知を設定します)
- [アプリにアクセスし、初期設定を行います](#アプリにアクセスし初期設定を行います)
- [リカバリに備えてAMIを作成します](#リカバリに備えてamiを作成します)


# 各サーバの状態を理解します


AMIは、次の手順で作成し、[Nablarch](https://github.com/nablarch/nablarch)の[Example](https://github.com/nablarch/nablarch-example-web)のCIを組み込んであります。

- [OSの初期設定～アプリのインストール](app.md)
- [アプリの初期設定](init.md)
- [プロジェクトの開発準備](dev.md)

各アプリでは、管理者、グループ、ユーザ、プロジェクト/リポジトリを次の内容で作成しています。

- 管理者
  - admin/pass123-（Redmine、Rocket.Chat、SonarQube、Nexus、Jenkins、Subversion）
  - root/pass123-（GitBucket、GitLab、Subversion）
- グループ
  - sample（Redmine、GitBucket、GitLab）
- ユーザ
  - nop/pass456-（Redmine、Rocket.Chat、GitBucket、GitLab、Subversion）
    - 開発メンバ
    - sampleグループに割り当て済みです。
  - jenkins/pass456-（Rocket.Chat）
    - JenkinsからCI結果を通知するためのユーザ
- プロジェクト/リポジトリ
  - nablarch-example-web（Redmine、GitBucket、GitLab）
    - sampleグループに割り当て済みです。

各サーバのディレクトリ構成は以下になります。
OSの初期設定やアプリのインストール時に使用したシェルスクリプトが多数ありますが、
ここではアプリの運用に関連する部分のみコメントします。

CQサーバとCIサーバ
```
home
  centos
    nop
      docker
        ci      … docker-compose.ymlがあります。CIサーバのアプリを操作する場所です。
        cq      … docker-compose.ymlがあります。CQサーバのアプリを操作する場所です。
      log       … cronのエラーログがあります。cronでエラーが発生するとメール通知されるので、ここのログを確認します。
      script
        config  … cronの設定内容があります。
        cron    … cronで呼び出すシェルファイルがあります。
```

Demoサーバ
```
home
  centos
    app         … アプリのデプロイ先です。Executable Jarをdockerで立ち上げています。
```

# データボリュームを定期的にバックアップするように設定します
- バックアップ対象の目印となる名前をデータボリュームに設定します。
  - AWSマネジメントコンソールでEC2にアクセスし、「nop-ec2-cq」＞ブロックデバイスの「/dev/sdb」＞「EBS ID」のリンクを選択します。
    - ![](images/aws-ec2-datavolume.png)
  - Name列にカーソルを持っていくと鉛筆アイコンが表示されるので選択し、「nop-ebs-data-cq」と指定します。
    - ![](images/aws-ec2-volumename.png)
  - タグを追加します。
    - タグタブに切り替えて、「タグの追加/編集」＞「タグの作成」をクリックします。
      - キーと値を入力して、「保存」をクリックします。
        - キー: NopDataDlmTarget
        - 値: true
        - ![](images/aws-ec2-volume-tag-dlm.png)
  - 「nop-ec2-ci」インスタンスについても同じ操作で名前とタグの追加を行います。
    - データボリュームの名前に「nop-ebs-data-ci」と指定します。
    - 「nop-ec2-cq」に設定したものと同一のタグを追加します。

- CQサーバのデータボリュームのバックアップのスケジュールを設定します。
  - AWSマネジメントコンソールでEC2にアクセスし、「ライフサイクルマネージャー」＞「スナップショットライフサイクルポリシーの作成」をクリックします。
    - 説明: nop-data-volume-backup
    - リソースタイプを選択します: ボリューム
    - これらのタグを持つターゲット: NopDataDlmTarget:true
      - タグはテキストボックスをクリックすると表示される選択肢から選びます。  
        選ぶと以下のようになります。
        - ![](images/aws-ec2-dlm-target-tag.png)
    - ライフサイクルポリシーテキスト: デフォルトのまま
    - ポリシースケジュール
      - スケジュール名: nop-data-volume-backup-schedule
      - ポリシーの実行間隔: 24時間
      - 開始時刻: 14:10 UCT (日本時刻23:10になります。)
      - Retention type: Age
      - Retain: 7
      - 間隔の単位: Days
    - タグ付け情報
      - ボリュームからタグをコピーする: ON
    - IAMロール: デフォルトのロールを使用
    - ポリシー
      - 作成後のポリシーのステータス: 有効化
    - 「ポリシーの作成」をクリックします。
- スナップショットの取得に成功していることを翌日確認します。  
  ライフサイクルマネージャーは「指定された開始時刻から1時間以内に作成が開始される」仕様であり、設定後、すぐに確認できないためです。

# CQサーバの設定を変更します


- SSHでCQサーバにアクセスします。
- centosユーザのパスワードを変更します。
  ```
  $ passwd
  ```
  - 現在のパスワード: pass789-
- プロキシ環境下の場合は、centosユーザのプロキシの設定を変更します。
  ```
  $ vi ~/.bash_profile
  ```
  - プロキシ情報はネットワーク管理者に確認してください。
  - プロキシの設定のみ変更します。no_proxyは追加します。
    ```
    export HTTP_PROXY=http://26.247.64.251:3128
    export HTTPS_PROXY=http://26.247.64.251:3128
    export http_proxy=http://26.247.64.251:3128
    export https_proxy=http://26.247.64.251:3128
    export no_proxy=169.254.169.254
    ```
    - no_proxyには「169.254.169.254」を指定します。インスタンスメタデータを取得する際のIPになります。
      - cronで実行するメトリクス送信でAWS CLIを使います。
        プロキシ環境下で、EC2インスタンスにロールを指定してAWS CLIを使う場合に、インスタンスメタデータを取得するため、この設定が必要になります。
  - 設定を反映します。
    ```
    $ source ~/.bash_profile
    ```
- プロキシ環境下の場合は、yumのプロキシの設定を変更します。
  ```
  $ sudo vi /etc/yum.conf
  ```
  - 最後の行に以下を追加します。
    ```
    proxy=http://26.247.64.251:3128
    ```
- OSのパッケージを更新します。
  ```
  $ sudo yum -y update
  ```
- SSHを切断します。
  ```
  $ exit
  ```
- サービスを再起動するため、EC2のインスタンスごと一度停止し起動しなおします。
  - AWSマネジメントコンソールでEC2にアクセスし、nop-ec2-cqのインスタンスを選択します。
  - 画面上部の「アクション」＞「インスタンスの状態」＞「停止」を選択します。  
    (「再起動」でもよいのですが、時間が掛かることがあります。一度「停止」することをお勧めします。)
  - 停止するまで待ちます。
  - 画面上部の「アクション」＞「インスタンスの状態」＞「開始」を選択します。
- SSHでCQサーバにアクセスします。  
  AWSマネジメントコンソール上で起動しても接続できない場合があります。  
  その場合は待ちます(5分以上待つ必要があることもあります)。
- Rocket.Chatの設定を変更します。
  ```
  $ vi nop/docker/cq/docker-compose.yml
  ```
  - Rocket.Chatの外部URLを指定します。
    ```
    nop/docker/cq/docker-compose.yml
    ```
    - 「rocketchat」＞「environment」＞「ROOT_URL」に指定します。
      ```
      rocketchat:
        container_name: rocketchat
        # 省略
        environment:
          # 省略
          ROOT_URL: <ブラウザからrocketchatにアクセスする場合のURL>
      ```
    - Rocket.ChatのURLは「<ホスト>/rocketchat」となります。設定例を示します。
      ```
      ROOT_URL: https://nop-cq.adc-tis.com/rocketchat/
      ```
- プロキシ環境下の場合は、Dockerコンテナのプロキシの設定を変更します。
  ```
  $ vi nop/docker/cq/common.env
  ```
  - プロキシの設定のみ変更します。
    ```
    HTTP_PROXY=http://26.247.64.251:3128
    HTTPS_PROXY=http://26.247.64.251:3128
    http_proxy=http://26.247.64.251:3128
    https_proxy=http://26.247.64.251:3128
    ```
- プロキシ環境下の場合は、SonarQubeのプロキシの設定を変更します。
  ```
  $ sudo vi nop/docker/cq/sonar.properties
  ```
  - プロキシの設定のみ変更します。
    ```
    http.proxyHost=26.247.64.251
    http.proxyPort=3128
    ```
- アプリを作り直します。
  - アプリを操作するディレクトリに移動します。
    ```
    $ cd ~/nop/docker/cq/
    ```
  - アプリを停止して削除します。
    ```
    $ docker-compose down
    ```
  - アプリを作成して起動します。
    ```
    $ docker-compose up -d
    ```
  - RedmineにサブURIの設定を入れます。
    ```
    $ ./redmine-sub-uri.sh
    ```
  - ブラウザでアクセスします。
    ```
    <CQサーバのホスト>/redmine
    ```
    - アクセスできない場合は、以下のコマンドでredmineのログを確認します。
      ```
      $ docker-compose logs redmine
      ```
      プロキシの設定がされているのにgemの取得に失敗しているログがでている場合は、外部のサイトが一時的に停止している可能性があります。  
      この場合は数時間おいて、「アプリを停止して削除します」からやり直します。
    
- トピックのARNを変更します。
  ```
  $ vi ~/.bash_profile
  ```
  - AWSマネジメントコンソールでSNSにアクセスし、トピックのARNを確認します。
    - ![SNSのトピックARN](images/aws-sns-topicarn.png)
  - AWS_SNS_TOPICのみ変更します。
  ```
  export AWS_SNS_TOPIC=arn:aws:sns:ap-northeast-1:746256062285:nop-alarm
  ```
  - 設定を反映します。
    ```
    $ source ~/.bash_profile
    ```
- プロキシ環境下の場合は、Amazon CloudWatch モニタリングスクリプトをプロキシ環境下で使うための設定を行います。
  - 環境変数を追加します。
    ```
    $ vi ~/.bash_profile
    ```
    - 2つの環境変数を追加します。
      ```
      export PERL_NET_HTTPS_SSL_SOCKET_CLASS=Net::SSL
      export PERL_LWP_SSL_VERIFY_HOSTNAME=0
      ```
    - 設定を反映します。
      ```
      $ source ~/.bash_profile
      ```
  - パッケージをインストールします。
    ```
    $ sudo yum install perl-Switch perl-DateTime perl-Sys-Syslog perl-LWP-Protocol-https -y
    $ sudo yum install perl-Net-SSLeay perl-Crypt-SSLeay perl-IO-Socket-SSL -y
    ```
- cronを設定します。
  ```
  $ cd ~/nop/script/
  $ ./set-cron-after-try-command.sh
  ```
  - テストメールの送信、CloudWatchへのメトリクス送信を実行し、
    エラーが出なければcronの設定を行い、cronの設定内容が表示されます。  
    cronでは以下を設定します。
    - 監視用のメトリクス取得…5分間隔
    - アプリデータのバックアップ前のアプリ停止…23時00分
    - アプリデータのバックアップ後のアプリ開始… 0時30分
- SSHを切断します。
  ```
  $ exit
  ```


# CIサーバの設定を変更します


- SSHでCIサーバにアクセスします。
- centosユーザのパスワードを変更します。
  ```
  $ passwd
  ```
  - 現在のパスワード: pass789-
- プロキシ環境下の場合は、centosユーザのプロキシの設定を変更します。
  ```
  $ vi ~/.bash_profile
  ```
  - プロキシの設定のみ変更します。no_proxyは追加します。
    ```
    export HTTP_PROXY=http://26.247.64.251:3128
    export HTTPS_PROXY=http://26.247.64.251:3128
    export http_proxy=http://26.247.64.251:3128
    export https_proxy=http://26.247.64.251:3128
    export no_proxy=169.254.169.254
    ```
    - no_proxyには「169.254.169.254」を指定します。インスタンスメタデータを取得する際のIPになります。
      - cronで実行するメトリクス送信でAWS CLIを使います。
        プロキシ環境下で、EC2インスタンスにロールを指定してAWS CLIを使う場合に、インスタンスメタデータを取得するため、この設定が必要になります。
  - 設定を反映します。
    ```
    $ source ~/.bash_profile
    ```
- プロキシ環境下の場合は、yumのプロキシの設定を変更します。
  ```
  $ sudo vi /etc/yum.conf
  ```
  - 最後の行に以下を追加します。
    ```
    proxy=http://26.247.64.251:3128
    ```
- OSのパッケージを更新します。
  ```
  $ sudo yum -y update
  ```
- SSHを切断します。
  ```
  $ exit
  ```
- サービスを再起動するため、EC2のインスタンスごと一度停止し起動しなおします。
  - AWSマネジメントコンソールでEC2にアクセスし、nop-ec2-ciのインスタンスを選択します。
  - 画面上部の「アクション」＞「インスタンスの状態」＞「停止」を選択します。  
    (「再起動」でもよいのですが、時間が掛かることがあります。一度「停止」することをお勧めします。)
  - 停止するまで待ちます。
  - 画面上部の「アクション」＞「インスタンスの状態」＞「開始」を選択します。
- SSHでCIサーバにアクセスします。  
  AWSマネジメントコンソール上で起動しても接続できない場合があります。  
  その場合は待ちます(5分以上待つ必要があることもあります)。
- プロキシ環境下の場合は、Dockerコンテナのプロキシの設定を変更します。
  ```
  $ vi nop/docker/ci/common.env
  ```
  - プロキシの設定のみ変更します。
    ```
    HTTP_PROXY=http://26.247.64.251:3128
    HTTPS_PROXY=http://26.247.64.251:3128
    http_proxy=http://26.247.64.251:3128
    https_proxy=http://26.247.64.251:3128
    ```
- GitLabを使う場合はアプリの設定を変更します。
  ```
  $ vi nop/docker/ci/docker-compose.yml
  ```
  - GitLabの外部URLを指定します。
    - 「gitlab」＞「environment」＞「GITLAB_OMNIBUS_CONFIG」＞「external_url」に指定します。
      ```
      gitlab:
        container_name: gitlab
        # 省略
        environment:
          GITLAB_OMNIBUS_CONFIG: |
            external_url '<ブラウザからGitLabにアクセスする場合のURL>'
            gitlab_rails['time_zone'] = 'Tokyo'
       ```
    - GitLabのURLは「<ホスト>/gitlab」となります。設定例を示します。
      ```
      external_url 'https://nop-ci.adc-tis.com/gitlab/'
      ```
  - GitLabの外部URLがhttpsでない場合は、以下の設定をコメントアウトします。
    ```
    nginx['proxy_set_headers'] = {
      "X-Forwarded-Proto" => "https",
      "X-Forwarded-Ssl" => "on"
    }
    ```
    - 先頭に「#」を付けます。
    ```
    #nginx['proxy_set_headers'] = {
    #  "X-Forwarded-Proto" => "https",
    #  "X-Forwarded-Ssl" => "on"
    #}
    ```
- GitLabのCIは、ビルドの実行環境をVirtualBox・Docker等から選べます。今回はDockerを使用しますので、その設定を行います。
  ```
  $ sudo vi /etc/docker/daemon.json
  ```
  - Nexusに証明書を登録することなくCIで使用するDockerイメージをPush/Pullできるように、設定を行います。
      ```
      {
       　"insecure-registries": ["<nexsusのホストのIPアドレス>:19081"]
      }
      ```
    - 設定例を示します。
      ```
      {
       　"insecure-registries": ["10.0.1.9:19081"]
      }
      ```
  - Dockerで起動しているアプリを停止し、Dockerを再起動します。
      - アプリを操作するディレクトリに移動します。
        ```
        $ cd ~/nop/docker/ci/
        ```
      - アプリを停止します。
        ```
        $ docker-compose stop
        ```
      - Dockerを再起動します。
        ```
        $ sudo systemctl restart docker
        ```
      - Docker再起動と共に、アプリが再開したことを確認します。各アプリのStateがUpになっていれば、起動しています。
        ```
        $ docker-compose ps
        ```
  - CIサーバにNexusへの認証情報を保存するためにDockerで一度ログインします。  
    ```
    $ docker login -u admin -p pass123- <CIサーバのIPアドレス>:19081
    ```
    - 例を示します。
      ```
      $ docker login -u admin -p pass123- 10.0.1.9:19081
      ```

- アプリを作り直します。
  - アプリを操作するディレクトリに移動します。
    ```
    $ cd ~/nop/docker/ci/
    ```
  - アプリを停止して削除します。
    ```
    $ docker-compose down
    ```
  - アプリを作成して起動します。
    ```
    $ docker-compose up -d
    ```
- トピックのARNを変更します。
  ```
  $ vi ~/.bash_profile
  ```
  - AWSマネジメントコンソールでSNSにアクセスし、トピックのARNを確認します。
    - ![SNSのトピックARN](images/aws-sns-topicarn.png)
  - AWS_SNS_TOPICのみ変更します。
  ```
  export AWS_SNS_TOPIC=arn:aws:sns:ap-northeast-1:746256062285:nop-alarm
  ```
  - 設定を反映します。
    ```
    $ source ~/.bash_profile
    ```
- プロキシ環境下の場合は、Amazon CloudWatch モニタリングスクリプトをプロキシ環境下で使うための設定を行います。
  - 環境変数を追加します。
    ```
    $ vi ~/.bash_profile
    ```
    - 2つの環境変数を追加します。
      ```
      export PERL_NET_HTTPS_SSL_SOCKET_CLASS=Net::SSL
      export PERL_LWP_SSL_VERIFY_HOSTNAME=0
      ```
    - 設定を反映します。
      ```
      $ source ~/.bash_profile
      ```
  - パッケージをインストールします。
    ```
    $ sudo yum install perl-Switch perl-DateTime perl-Sys-Syslog perl-LWP-Protocol-https -y
    $ sudo yum install perl-Net-SSLeay perl-Crypt-SSLeay perl-IO-Socket-SSL -y
    ```
- cronを設定します。
  ```
  $ cd ~/nop/script/
  $ ./set-cron-after-try-command.sh
  ```
  - テストメールの送信、CloudWatchへのメトリクス送信を実行し、
    エラーが出なければcronの設定を行い、cronの設定内容が表示されます。  
    cronでは以下を設定します。
    - 監視用のメトリクス取得…5分間隔
    - アプリデータのバックアップ前のアプリ停止…23時00分
    - アプリデータのバックアップ後のアプリ開始… 0時30分
- SSHを切断します。
  ```
  $ exit
  ```


# Demoサーバの設定を変更します


- SSHでDemoサーバにアクセスします。
- centosユーザのパスワードを変更します。
  ```
  $ passwd
  ```
  - 現在のパスワード: pass789-
- プロキシ環境下の場合は、centosユーザのプロキシの設定を変更します。
  ```
  $ vi ~/.bash_profile
  ```
  - プロキシの設定のみ変更します。
    ```
    export HTTP_PROXY=http://26.247.64.251:3128
    export HTTPS_PROXY=http://26.247.64.251:3128
    export http_proxy=http://26.247.64.251:3128
    export https_proxy=http://26.247.64.251:3128
    ```
  - 設定を反映します。
    ```
    $ source ~/.bash_profile
    ```
- プロキシ環境下の場合は、yumのプロキシの設定を変更します。
  ```
  $ sudo vi /etc/yum.conf
  ```
  - 最後の行に以下を追加します。
    ```
    proxy=http://26.247.64.251:3128
    ```
- OSのパッケージを更新します。
  ```
  $ sudo yum -y update
  ```
- SSHを切断します。
  ```
  $ exit
  ```
- サービスを再起動するため、EC2のインスタンスごと一度停止し起動しなおします。
  - AWSマネジメントコンソールでEC2にアクセスし、nop-ec2-demoのインスタンスを選択します。
  - 画面上部の「アクション」＞「インスタンスの状態」＞「停止」を選択します。  
    (「再起動」でもよいのですが、時間が掛かることがあります。一度「停止」することをお勧めします。)
  - 停止するまで待ちます。
  - 画面上部の「アクション」＞「インスタンスの状態」＞「開始」を選択します。
- SSHでDemoサーバにアクセスします。  
  AWSマネジメントコンソール上で起動しても接続できない場合があります。  
  その場合は待ちます(5分以上待つ必要があることもあります)。
- プロキシ環境下の場合は、Dockerのプロキシの設定を変更します。
  - docker.serviceをコピーします。
    ```
    $ sudo cp /usr/lib/systemd/system/docker.service /etc/systemd/system/
    ```
  - コピーしたdocker.serviceにProxyの設定を追加します。
    ```
    $ sudo vi /etc/systemd/system/docker.service
    ```
    - ExecStartコマンドの直前にProxyの設定を追加します。
      ```
      Environment="HTTP_PROXY=http://26.247.64.251:3128"
      ```
  - 設定の再読込とDockerの再起動を行います。
    ```
    $ sudo systemctl daemon-reload
    $ sudo systemctl restart docker
    ```
- SSHを切断します。
  ```
  $ exit
  ```


# メトリクスが取得できていることを確認します


- AWSマネジメントコンソールでCloudWatchにアクセスし、メトリクスを確認します。
  - 「メトリクス」＞「Linuxシステム」＞「Filesystem, InstanceId, MountPath」を選択します
    - ![CloudWatchのLinux](images/aws-cw-linux.png)
    - ![CloudWatchのファイルシステム](images/aws-cw-file.png)
  - MountPath:/data、メトリクス名:DiskSpaceUtilizationで取得されます。
    - メトリクスを選択すると、グラフに表示され、インスタンスの名前(nop-ec2-cq、nop-ec2-ci)を確認できます。
      - ![CloudWatchのメトリクス](images/aws-cw-metrics.png)


# CloudWatchでディスク使用率にアラームを設定します


- AWSマネジメントコンソールでCloudWatchにアクセス、「アラーム」＞「アラームの作成」を選択します。
- 先ほど確認したメトリクスを選択し次に進みます。
  - ![CloudWatchのアラームのメトリクス](images/aws-cw-alarm-metrics.png)
- アラームの定義を指定して作成します。
  - ![CloudWatchのアラームの定義](images/aws-cw-alarm-config1.png)
    - 「アラーム条件」、「しきい値」を指定し、「次へ」をクリックします。  
      
  - ![CloudWatchのアラームの定義](images/aws-cw-alarm-config2.png)
    - 「通知の送信先」を指定し、「次へ」をクリックします。  
    
  - ![CloudWatchのアラームの定義](images/aws-cw-alarm-config3.png)
    - 「アラーム名」を指定し、「次へ」をクリックします。
      - アラーム名は「CIサーバのディスク使用率」「CQサーバのディスク使用率」等、任意の名前にします。  
      
  - 「アラームの作成」をクリックします。


# CloudWatchでバックアップ失敗時の通知を設定します

- AWSマネジメントコンソールでCloudWatchにアクセス、「ルール」＞「ルールの作成」を選択します。
  - ![CloudWatchのルールの定義](images/aws-cw-rule-create-snapshot-failed.png)  
    以下の項目を設定し、「設定の詳細」をクリックします。
    - イベントソース
      - イベントパターン
      - サービス名: EC2
      - イベントタイプ: EBS Snapshot Notification
      - 特定のイベント
        - createSnapshot
      - 特定の結果
        - failed
    - ターゲット
      - SNSトピック
        - トピック: nop-alarm
  - 以下を入力します。
    - ルールの定義
      - 名前: notification-createSnapshot-failed
      - 説明: 空欄
      - 状態: 有効化をON

# アプリにアクセスし、初期設定を行います


## Redmine

- ブラウザでアクセスします。
  ```
  <CQサーバのホスト>/redmine
  ```
- ブラウザでアクセスしたURLをブックマークしておきます。
- 管理者でログインします。
  - 画面右上の「ログイン」を選択します。
    - ログインID: admin
    - パスワード: pass123-
- 管理者のパスワードを変更します。
  - 画面右上の「個人設定」＞「パスワード変更」を選択します。
  - パスワードを変更します。

## Rocket.Chat

- ブラウザでアクセスします。
  ```
  <CQサーバのホスト>/rocketchat
  ```
- ブラウザでアクセスしたURLをブックマークしておきます。
- 管理者でログインします。
  - ユーザ名: admin
  - パスワード: pass123-
- 管理者のパスワードを変更します。
 - 画面左上のadmin横のプルダウン＞「マイアカウント」＞「プロフィール」を選択します。
   - 新しいパスワードを入力して、変更を保存します。
   - 変更前のパスワードの入力が求められるので「pass123-」を入力します。

## SonarQube

- ブラウザでアクセスします。
  ```
  <CQサーバのホスト>/sonarqube
  ```
- ブラウザでアクセスしたURLをブックマークしておきます。
- 管理者でログインします。
  - 画面右上の「Log in」を選択します。
    - Login: admin
    - Password: pass123-
- 管理者のパスワードを変更します。
  - 画面右上の「Administration」＞「Security」＞「Users」を選択します。
    - adminの鍵アイコン「Change password」を選択し、パスワードを変更します。

## Nexus

- ブラウザでアクセスします。
  ```
  <CIサーバのホスト>/nexus
  ```
- ブラウザでアクセスしたURLをブックマークしておきます。
- 管理者でログインします。
  - 画面右上の「Sign in」を選択します。
    - Username: admin
    - Password: pass123-
- 管理者のパスワードを変更します。
  - 画面右上の「admin」＞「Change password」を選択します。
    - はじめに、再度認証が求められるので、変更前のパスワード「pass123-」を指定して、パスワードを変更します。
- プロキシ環境下の場合は、プロキシの設定を行います。
  - 画面左上の「歯車(Server administration and configuration)」アイコン＞画面左のSystemの「HTTP」を選択します。
    - HTTP proxy: チェックしてプロキシを設定します。
    - HTTPS proxy: チェックしてプロキシを設定します。
    - Saveします。

## GitBucket

- ブラウザでアクセスします。
  ```
  <CIサーバのホスト>/gitbucket
  ```
  - 初回表示時、ブラウザが `http://` で始まるURLを表示しようとすることがあります。  
    エラーが発生した場合は、入力通りのプロトコルから始まるURLを表示しようとしているか、確認してください。
- ブラウザでアクセスしたURLをブックマークしておきます。
- 管理者でログインします。  
  - 画面右上の「Sign in」を選択します。
    - Username: root
    - Password: pass123-
  - Base URLの設定がされていないため、存在しないURLに遷移した場合は、再度「`<CIサーバのホスト>/gitbucket`」にアクセスするとログイン済みの画面が表示されます。
- 管理者のパスワードを変更します。
  - 画面右上のプルダウン(＋の右となり)＞「Account Settings」
    - Password (input to change password): 新しいパスワード
    - Saveします。
- Base URLを設定します。
  - 画面右上のプルダウン(＋の右となり)＞「System Administration」＞「System Settings」を選択します。
    - Base URL (e.g. http://example.com/gitbucket): ブラウザでアクセスしたURLを指定します。
    - Apply changesします。

## Jenkins

- ブラウザでアクセスします。
  ```
  <CIサーバのホスト>/jenkins
  ```
- ブラウザでアクセスしたURLをブックマークしておきます。
- 管理者でログインします。
  - 画面右上の「ログイン」を選択します。
    - Username: admin
    - Password: pass123-
- 管理者のパスワードを変更します。
  - 画面右上のadminにカーソルを合わせて表示されるプルダウン＞「設定」
    - パスワードを入力し、保存します。
- プロキシ環境下の場合は、プロキシの設定を行います。
  - ロゴを選択してトップページを表示します。
  - 画面左の「Jenkinsの管理」＞「プラグインの管理」＞「高度な設定」タブを選択します。
    - HTTP Proxyの設定を入力し、保存します。
      - 対象外ホスト: Jenkinsからアクセスする可能性がある「proxy(docker-composeのサービス名)」と「CQサーバのプライベートIP」をカンマ区切りで指定します。
        - 例: proxy,10.0.1.110
        - 指定内容は[URLの仕組み](url.md)を参照してください。
- Jenkinsの位置のJenkins URLにURLを指定します。  
  この設定を行うことで、Jenkinsの管理画面に表示される「リバースプロキシの設定がおかしいようです」という警告を解決できます。
  - ブラウザでアクセスする場合と同じURLを指定します。
  - 例: https://nop-ci.adc-tis.com/jenkins
- RocketChatへの通知設定を変更します。
  - ロゴを選択してトップページを表示します。
  - 画面左の「Jenkinsの管理」＞「システムの設定」を選択します。
    - 画面一番下のGlobal RocketChat Notifier Settingsを指定します。
      - Rocket Server URL: Rocket.ChatのURLを指定します。
      - [URLの仕組み](url.md)を参照し、環境に合わせて適切なURL指定を行ってください。
      - 例: http://10.0.1.110/rocketchat/
    - Test Connectionします。Successと表示されればOKです。Rocket.Chatのチャンネルにメッセージが届いています。
      - メッセージのリンクをクリックしてJenkinsへ移動できることを確認します。
    - 保存します。
- nablarch-example-webのパイプラインを変更します。
  - GibBucketにnopユーザでログインします。
    - Username: nop
    - Password: pass456-
  - 画面左にある「sample/nablarch-example-web」を選択します。
  - 画面右側にあるリポジトリのURLをコピーします。
  - 作業PCの適当な場所にgit cloneします。
    - ユーザ名/パスワードを聞かれるのでnopユーザを指定します。
    - 503エラーとなった場合は環境変数no_proxyにCIサーバのホストを設定します。
      ```
      $ export no_proxy=26.247.135.132
      ```
  - IDEでnablarch-example-web(Mavenプロジェクト)を開きます。
  - ブランチを「develop」に切り替えます。
  - パイプラインのパラメータを変更します。
    ```
    nablarch-example-web/Jenkinsfile
    ```
    - 環境変数を修正します。
      ```
      environment {
        SONAR_HOST_URL = '<SonarQubeのURL>'
        DEMO_HOST = '<Demoサーバのホスト>'
        DEMO_PORT = '<DemoサーバのSSHのポート番号>'
        DEMO_USERNAME = '<DemoサーバのSSHのユーザ名>'
        DEMO_PASSWORD = '<DemoサーバのSSHのパスワード>'
      }
      ```
      - [URLの仕組み](url.md)を参照し、環境に合わせて適切なURL指定を行ってください。
      - こんな感じになります。
        ```
        environment {
          SONAR_HOST_URL = 'http://10.0.1.110/sonarqube'
          DEMO_HOST = '10.0.1.63'
          DEMO_PORT = '22'
          DEMO_USERNAME = 'centos'
          DEMO_PASSWORD = 'pass789-'
        }
        ```
- pushします。
- Jenkinsが変更を検知してジョブが実行されます。
  - CI結果（テスト、デプロイなど）はRocket.Chatに通知されます。
  - 「Deploy to demo」まで成功すると、デプロイされたアプリにアクセスできます。ブラウザでアクセスします。
    ```
    <DEMOサーバのホスト>/
    ```
    - ログインID: 10000001
    - パスワード: pass123-

## GitLab

- ブラウザでアクセスします。
  ```
  <CIサーバのホスト>/gitlab
  ```
- ブラウザでアクセスしたURLをブックマークしておきます。
- 管理者でログインします。
  - 画面右上の「Sign in」を選択します。
    - Username: root
    - Password: pass123-
- 管理者のパスワードを変更します。
  - 画面右上のプルダウン＞「Settings」＞「Password」タブを選択します。
    - パスワードを変更します。
- GitLabのCIコンポーネント(GitLab Runner)を登録するために必要なトークンを確認します。
  - 画面左上の「レンチ(Admin area)」アイコン)＞「Overview」＞「Runners」を選択します。
  - 「Use the following registration token during setup」に記載のトークンをコピーします。

- GitLab Runnerを登録します。
  - SSHでアクセスします。
    ```
    $ ssh -F .ssh/ssh.config nop-ci
    ```
  - gitlab-runnerコマンドを起動します。
    ```
    $ docker exec -it gitlab-runner gitlab-runner register
    ```
  - 対話式で情報を入力します。
    - http://<CIサーバのIPアドレス>/gitlabを入力します。以下に例を示します。
      ```
      Please enter the gitlab-ci coordinator URL (e.g. https://gitlab.com/):
      http://10.0.1.9/gitlab
      ```
    - ブラウザから確認したトークンを入力します。以下に例を示します。
      ```
      Please enter the gitlab-ci token for this runner:
      fhEsBxUScX3bWAWLfCWz
      ```
    - 説明を入力します。改行のみで問題ないです。
      ```
      Please enter the gitlab-ci description for this runner:
      [cc4d40bad12f]:
      ```
    - タグを入力します。改行のみで問題ないです。
      ```
      Please enter the gitlab-ci tags for this runner (comma separated):
      ```
    - executorの種類を入力します。`docker` と入力します。
      ```
      Please enter the executor: shell, docker, docker-ssh, parallels, ssh, virtualbox, docker+machine, docker-ssh+machine, custom, kubernetes:
      docker
      ```
    - CIで使用するDockerイメージのデフォルトを入力します。 `maven:3.6.2-jdk-8` と入力します。
      ```
      Please enter the default Docker image (e.g. ruby:2.6):
      maven:3.6.2-jdk-8
      ```
  - config.tomlを編集します。
    - viを起動します。
      ```
      $ sudo vi /data/gitlab-runner/config/config.toml
      ```
    - `clone_url = "http://1<CIサーバのIPアドレス>/gitlab"` を追記します。以下に例を示します。
      ```
      (中略)
      [[runners]]
      (中略)
        executor = "docker"
        clone_url = "http://10.0.1.9/gitlab" 
        [runners.custom_build_dir]
      (中略)
      ```

- GitLabにGitLabのCIコンポーネント(GitLab Runner)を登録されたことを確認します。
  - ブラウザでGitLabにアクセスします。
  - 画面左上の「レンチ(Admin area)」アイコン)＞「Overview」＞「Runners」を選択し、Runnerが存在することを確認します。
  - 登録した以外のRunnnerが存在する場合、使わないため消します。
- nablarch-example-webのパイプラインを変更します。
  - GibLabにnopユーザでログインします。
    - Username: nop
    - Password: pass456-
  - 「sample/nablarch-example-web」を選択します。
  - 画面中央にあるリポジトリのURLをコピーします。
  - 作業PCの適当な場所にgit cloneします。
    - ユーザ名/パスワードを聞かれるのでnopユーザを指定します。
    - 503エラーとなった場合は環境変数no_proxyにCIサーバのホストを設定します。
      ```
      $ export no_proxy=26.247.135.132
      ```
  - いくつか設定ファイルを変更していくので、IDEでnablarch-example-web(Mavenプロジェクト)を開きます。
  - ブランチを「develop」に切り替えます。
  - パイプラインのパラメータを変更します。
    ```
    nablarch-example-web/.gitlab-ci.yml
    ```
    - イメージの取得元と環境変数を修正します。
      ```
      image: <CIサーバのホスト>:19081/maven-jdk-11-with-sshpass-on-docker
      (中略)
      variables:
        SONAR_HOST_URL: <SonarQubeのURL>'
        DEMO_HOST: <Demoサーバのホスト>
        DEMO_PORT: <DemoサーバのSSHのポート番号>
        DEMO_USERNAME: <DemoサーバのSSHのユーザ名>
        DEMO_PASSWORD: <DemoサーバのSSHのパスワード>
      ```
      - [URLの仕組み](url.md)を参照し、環境に合わせて適切なURL指定を行ってください。
      - パラメータの設定は以下のような感じになります。  
        imageはNexusから取得するので、CIサーバのIPアドレスを指定してください。
        ```
        image: 10.0.1.93:19081/maven-jdk-11-with-sshpass-on-docker
        (中略)
        variables:
          SONAR_HOST_URL: 10.0.1.118
          DEMO_HOST: 10.0.1.88
          DEMO_PORT: 22
          DEMO_USERNAME: centos
          DEMO_PASSWORD: pass789-
        ```
  - パイプラインで使うMavenの設定を変更します。
    ```
    nablarch-example-web/ci/settings.xml
    ```
    - [URLの仕組み](url.md)を参照し、環境に合わせて適切なURL指定を行ってください。
    - パラメータの設定は以下のような感じになります。
      ```
      <?xml version="1.0" encoding="UTF-8"?>
      <settings>      
        <mirrors>
          <mirror>
            <!-- 中略 -->
            <url>http://10.0.1.93/nexus/repository/maven-public/</url>
            <!-- 中略 -->
          </mirror>
        </mirrors>
      
      </settings>
      ```
  - pushします。
- GitLabが変更を検知してジョブが実行されます。
  - CI結果（テスト、デプロイなど）はRocket.Chatに通知されます。
  - 「Deploy_Job」まで成功すると、デプロイされたアプリにアクセスできます。ブラウザでアクセスします。
    ```
    <DEMOサーバのホスト>/
    ```
    - ログインID: 10000001
    - パスワード: pass123-



# リカバリに備えてAMIを作成します


一通り、初期設定が完了したら、EC2インスタンスが故障した場合に備えて、
各EC2インスタンスのイメージを作成しておきます。

- AWSマネジメントコンソールでEC2にアクセスします。
- インスタンスを選択＞「アクション」＞「イメージ」＞「イメージの作成」を選択して、イメージを作成します。
