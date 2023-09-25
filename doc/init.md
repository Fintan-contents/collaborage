アプリの初期設定
================================

ここでは、チーム開発環境をスムーズに使い始めるために、最低限の初期設定を行います。
ここに記載していない設定項目はプロジェクトで自由にカスタマイズしてください。

- [Redmine](#redmine)
- [Rocket.Chat](#rocketchat)
- [SonarQube](#sonarqube)
- [Nexus](#nexus)
- [Subversion](#subversion)
- [GitBucket](#gitbucket)
- [Jenkins](#jenkins)
- [GitLab](#gitlab)


## Redmine


- ブラウザでアクセスします。
  ```
  <CQサーバのホスト>/redmine
  ```
- ブラウザでアクセスしたURLをブックマークしておきます。
- ログインします。
  - 画面右上の「ログイン」を選択します。
    - ログインID: admin
    - パスワード: admin
  - パスワード変更が求められるので、パスワードを変更します。
- かんばん用のトラッカー(StoryとTask)を追加します。
  - 画面左上の「管理」＞「トラッカー」＞「新しいトラッカーを作成」を選択します。
    - 名前: Story
    - デフォルトのステータス: New
    - ワークフローをここからコピー: 空欄のまま
  - 「このトラッカーにワークフローが定義されていません(編集)」を選択します。
    - ロール: すべて
    - 「編集」を選択します。
      - New/In Progress/Resolved/Feedback/Closed/Rejectedの組み合わせを全部チェックします。
      - 保存します。
  - 画面右の「トラッカー」＞「新しいトラッカーを作成」を選択します。
    - 名前: Task
    - デフォルトのステータス: New
    - ワークフローをここからコピー: Story
- かんばんの設定をします。
  - 画面右の「プラグイン」＞Redmine Backlogsの「設定」を選択します。
    - ストーリーに利用するトラッカー: Story
    - デフォルトのストーリートラッカー: Story
    - タスクとして利用のトラッカー: Task
    - 適用します。
- ロールと権限の設定をします。
  - 画面右の「ロールと権限」＞「Manager」を選択します。
    - 権限＞Backlogsを全部チェックします。
    - 保存します。
  - Developerも同様に設定します。
- ユーザによるアカウント登録を無効にします。
  - 画面左上の「管理」＞「設定」＞「認証」タブを選択します。
    - ユーザによるアカウント登録: 無効
    - 保存します。


## Rocket.Chat


- ブラウザでアクセスします。
  ```
  <CQサーバのホスト>/rocketchat
  ```
- ブラウザでアクセスしたURLをブックマークしておきます。
- ワークスペースを登録します。
  - 管理者情報を登録します。
    - 氏名、ユーザー名、メール、パスワードを入力します。
  - 組織情報を登録します。
    - 組織名、組織の種類、組織の業種、組織の規模、国を登録します。
    - 組織名:(半角スペース)
    - 組織の種類:非営利
    - 組織の業種:その他
    - 組織の規模:1-10 People
    - 国:全世界
  - サーバーを登録します。
    - ニュースとイベントの情報を受け取る:OFF
    - 使用とプライバシーポリシーに同意します:OFF
    - 「スタンドアロンとして続行」を選択します。
  - スタンドアロンサーバーの確認をします。
    - 「確認」を選択します
- 登録フォームを無効にします。
  - 画面左上のプルダウン＞「workspace」＞画面左の下の方にある「設定」＞画面中央部分に表示される「アカウント」＞画面下にある登録を下向きの矢印を選択して表示します。
    - 登録フォーム: 無効
    - 変更を保存します。
- CI結果をチャットに通知するための設定を行います。
  - Jenkinsを使う場合
    - Jenkins用のユーザを追加します。
      - ユーザの追加方法は[ここ](dev.md#rocketchatでのユーザ追加)を見てください。
        - 名前/ユーザ名: jenkins
        - パスワードの変更が必要: チェックを外します。
        - ロール: bot
        - デフォルトのチャンネルに参加: チェックを外します。
        - ようこそメールを送信: チェックを外します。
        - 保存します。
    - Jenkins用のチャンネルを追加します。
      - ホーム画面の「Create channels」の「channelの作成」を選択します。
        - 名前: jenkins
        - プライベート: OFF
        - ユーザを選択:
          - jenkins
        - 作ります。
  - GitLabを使う場合
    - GitLab用のチャンネルを作成します。
      - ホーム画面の「Create channels」の「channelの作成」を選択します。
        - 名前: gitlab
        - プライベート: OFF
        - ユーザを選択: 
          - rocket.cat
        - 作ります。
    - GitLabから通知を受け取るWebHook URLを作成します。
      - 画面左上のプルダウン＞「Workspace」＞「統合」＞「新規」を選択します。
        - 有効: ON
        - 名前 (オプション): gitlab
        - 投稿先チャンネル: #gitlab
        - 投稿者:rocket.cat
        - スクリプトが有効: ON
        - Script: `https://docs.rocket.chat/use-rocket.chat/workspace-administration/integrations/gitlab` の内容をコピペします。
        - 画面の一番下まで移動して、変更を保存します。
        - 変更を保存すると「Webhook URL」「Token」が出現します。
        - 「Webhook URL」の「クリップボードへコピー」を選択して、URLをコピーします。後ほどGitLabに設定します。


## SonarQube


- ブラウザでアクセスします。
  ```
  <CQサーバのホスト>/sonarqube
  ```
- ブラウザでアクセスしたURLをブックマークしておきます。
- ログインします。
  - Login: admin
  - Password: admin
    - パスワード変更が求められるので、パスワードを変更します。


## Subversion

- SSHでアクセスします。
  ```
    $ ssh -F .ssh/ssh.config nop-cq
  ```
- ユーザを作成します。
  - ID: root
  - パスワード: pass123-
  ```
    $ docker exec -t subversion htpasswd -bc /etc/apache2/svn-davsvn-htpasswd/davsvn.htpasswd root pass123-
  ```
- ユーザに権限を付与します。
  - `/data/svn/repo/conf/authz` を開きます。
    ```
    sudo vi /data/svn/repo/conf/authz
    ```
  - 以下を追記します。
    ```
    [/]
    root = rw
    ```
- アプリを操作するディレクトリに移動します。
  ```
  cd /home/ec2-user/nop/docker/cq
  ```
- Subversionを再起動します。
  ```
  docker compose restart subversion
  ```

## Nexus


- ブラウザでアクセスします。
  ```
  <CIサーバのホスト>/nexus
  ```
- ブラウザでアクセスしたURLをブックマークしておきます。
- ログインします。
  - 画面右上の「Sign in」を選択します。
    - ログインID: admin
    - パスワード: 
      - 作業場所で以下のコマンドを実行し、パスワードを取得します。
        ```
        $ ssh -F .ssh/ssh.config nop-ci "cd nop/docker/ci; ./nexus-password.sh"
        <ここにパスワードが出力されます>
        $
        ```
  - パスワードを変更します。
    - ログイン後に変更を求められるのでそのまま変更します。
      - 画面右上の「admin」を選択します。
      - 「Change password」ボタンを選択します。
      - パスワードを変更します。
  - 匿名ユーザーのアクセスを許可します。
    - Enable anonymous access を選択
    - 「Next」を選択します。
- ログアウトして、変更したパスワードで入りなおします。
  - 画面右上の「Sign out」を選択します。
- Realms の設定を変更します。
  - 画面左上の「歯車(Server administration and configuration)」アイコン＞「Security」＞「Realms」を選択します。
    - 「Docker Bearer Token Realm」 を Active に変更します。
    - Saveします。
- プロキシ環境下の場合はプロキシを設定します。
  - 画面左上の「歯車(Server administration and configuration)」アイコン＞画面左のSystemの「HTTP」を選択します。
    - HTTP proxy: チェックしてプロキシを設定します。
    - HTTPS proxy: チェックしてプロキシを設定します。
    - プロキシ情報はネットワーク管理者に確認してください。
    - Saveします。
- Maven/Dockerリポジトリを追加します。
  - 画面左上の「歯車(Server administration and configuration)」アイコン＞「Repositorites」＞「CreateRepository」を選択します。
    - リポジトリを作成します。
      - seasar
        - Recipe: maven2(proxy)
        - Name: seasar
        - Proxy > Remote storage: http://maven.seasar.org/maven2
      - clojars
        - Recipe: maven2(proxy)
        - Name: clojars
        - Proxy > Remote storage: https://clojars.org/repo
      - sonatype
        - Recipe: maven2(proxy)
        - Name: sonatype
        - Proxy > Remote storage: https://oss.sonatype.org/content/repositories/snapshots/
    - 追加したリポジトリをmaven-publicグループに追加します。
      - リポジトリ一覧から「maven-public」を選択します
      - Group > Member Repositories > Members: 追加したリポジトリを指定します。
      - Saveします。
    - リポジトリ一覧に戻ってDocker Hub、GitLab CIで使用するイメージの配置場所、公開用のグループを作成します。
      - docker-hub
        - Recipe: docker(proxy)
        - Name: docker-hub
        - Proxy > Remote storage: https://registry-1.docker.io
      - docker-hosted(hosted)
        - Recipe: docker(hosted)
        - Name: docker-hosted
        - Repository Connectors > HTTP: 19081
        - Allow anonymous docker pull:チェック
      - docker-public(グループ)
        - Recipe: docker(group)
        - Name: docker-public
        - Repository Connectors > HTTPS: 18444
        - Group > Member repositories > Members: docker-hub, docker-hosted


## GitBucket


- ブラウザでアクセスします。
  ```
  <CIサーバのホスト>/gitbucket
  ```
- ブラウザでアクセスしたURLをブックマークしておきます。
- ログインします。
  - 画面右上の「Sign in」を選択します。
    - Username: root
    - Password: root
- パスワードを変更します。
  - 画面右上のプルダウン(＋の右となり)＞「Account Settings」
    - Password (input to change password): 新しいパスワード
    - Saveします。
  - ログアウトして、変更したパスワードで入りなおします。
    - 画面右上のプルダウン(＋の右となり)＞「Sign out」


## Jenkins


- ブラウザでアクセスします
  ```
  <CIサーバのホスト>/jenkins
  ```
- ブラウザでアクセスしたURLをブックマークしておきます。
- ロックを解除します
  - パスワードを取得します
    - 作業場所で以下のコマンドを実行し、パスワードを取得します。
      ```
      $ ssh -F .ssh/ssh.config nop-ci "cd nop/docker/ci; ./jenkins-password.sh"
      <ここにパスワードが出力されます>
      $ 
      ```
  - Administrator password: 取得したパスワードを貼り付けます。 
- オフラインの場合は「Configure Proxy」を選択します。
  - サーバーからパスワードまで入力します。
    - プロキシ情報はネットワーク管理者に確認してください。
  - 対象外ホスト: Jenkinsからアクセスする可能性がある「proxy(docker composeのサービス名)」と「CQサーバのプライベートIP」をカンマ区切りで指定します。
    - 例: proxy,192.0.2.2
    - 指定内容は[URLの仕組み](url.md)を参照してください。
- プラグインをインストールします。
  - 「Select plugins to install」を選択します。
  - 以下のプラグインを選択し、「install」を選択します。
    - Pipeline
    - Pipeline: Stage View Plugin
    - Git
    - NodeJS
  - インストールが終わるまで待ちます。
  - 失敗したら、全部入るまで「Retry」を続けます。
- 管理者を登録します。
  - 全部の項目を入力します。
  - Save and Finishします。
- インスタンス設定を登録します。
  - Jenkins URL: ブラウザでアクセスしたURLを指定します。
  - Save and Finishします。
- Jenkinsをスタートします。
- 画面上部に赤い数字が表示された場合は確認します。
  - 画面上部の「赤い数字」を選択します。プラグインのロードエラーが出た場合は解消します。新しいバージョンの話しであれば無視します。
    - ![jenkins-plugins-errors](images/jenkins-plugins-errors.png)
  - プラグインのロードエラーを解消します。
    - 「赤い数字」＞「Correct」を選択します。
    - 画面左の「アップデートセンター」を選択します。
      - ![jenkins-plugins-errors-correct](images/jenkins-plugins-errors-correct.png)
    - 画面一番下の「インストール完了後、ジョブがなければJenkinsを再起動する」をチェックします。
    - Jenkinsの再起動を待ちます。
    - ログインします。
    - プラグインのロードエラーが出ていなければ問題解消です。
- Mavenを設定します。
  - ロゴを選択してトップページを表示します。
  - 画面左の「Jenkinsの管理」＞「Tools」を選択します。
  - 画面の下の方にあるMavenを設定します。
    - 「Maven追加」を選択します。
      - 名前: mvn3
    - Saveします。
- NodeJSを設定します。
  - ロゴを選択してトップページを表示します。
  - 画面左の「Jenkinsの管理」＞「Tools」を選択します。
  - 画面の下の方にあるNodeJSを設定します。
    - 「NodeJS追加」を選択します。
      - 名前: nodeJS18
  - 自動インストール
    - チェックあり
    - バージョン: NodeJS 18.17.0
  - Saveします。
- RocketChat Notifierプラグインを入れます。
  - ロゴを選択してトップページに移動します。
  - 画面左の「Jenkinsの管理」＞「Plugins」＞「Available Plugins」タブを選択します。
  - 画面右のフィルターに「rocket]と入力するなどして、「RocketChat Notifier」を選択します。
  - 「Install without restart」を選択します。
  - しばらくすると「成功」が表示されます。
- CI結果をチャットに通知するための設定を行います。
  - ロゴを選択してトップページに移動します。
  - 画面左の「Jenkinsの管理」＞「System」を選択します。
  - 画面一番下のGlobal RocketChat Notifier Settingsを指定します。
    - Rocket Server URL: Rocket.ChatのURLを指定します。
      - [URLの仕組み](url.md)を参照し、環境に合わせて適切なURL指定を行ってください。
      - 例: http://192.0.2.2/rocketchat/
    - Login Username/Login password/Channel: 先ほど作成したユーザ/チャンネルを指定します。
    - Build Server URL: JenkinsのURLを指定します。
      - こちらはブラウザでアクセスする場合と同じURLを指定します。
      - 例: https://nop-ci.adc-tis.com/jenkins
    - Test Connectionします。Successと表示されればOKです。Rocket.Chatのチャンネルにメッセージが届いています。
      - メッセージのリンクをクリックしてJenkinsへ移動できることを確認します。
  - 保存します。
- ログインせずにCI結果を見れるようにします。
  - ロゴを選択してトップページに移動します。
  - 画面左の「Jenkinsの管理」＞「security」を選択します。
    - 権限管理＞ログイン済みユーザーに許可＞Allow anonymous read accessをチェックします。
    - 保存します。


## GitLab


- ブラウザでアクセスします。
  ```
  <CIサーバのホスト>/gitlab
  ```
- ブラウザでアクセスしたURLをブックマークしておきます。
- ログインします。
  - Username or email: root
    - パスワード:
      - 作業場所で以下のコマンドを実行し、パスワードを取得します。
        ```
        $ ssh -F .ssh/ssh.config nop-ci "cd nop/docker/ci; ./gitlab-password.sh"
        # WARNING: This value is valid only in the following conditions
        #          1. If provided manually (either via `GITLAB_ROOT_PASSWORD` environment variable or via `gitlab_rails['initial_root_password']` setting in `gitlab.rb`, it was provided before database was seeded for the first time (usually, the first reconfigure run).
        #          2. Password hasn't been changed manually, either via UI or via command line.
        #
        #          If the password shown here doesn't work, you must reset the admin password following https://docs.gitlab.com/ee/security/reset_user_password.html#reset-your-root-password.

        Password: <ここにパスワードが出力されます>

        # NOTE: This file will be automatically deleted in the first reconfigure run after 24 hours.
        $
        ```
- パスワードを変更します。
  - 右上のユーザー画像＞「Edit Profile」＞画面左側の「password」を選択します。
    - パスワードを変更します。
- 自動的にログアウトするので、変更したパスワードで入りなおします。
- サインインページのユーザ登録(Register)を無効化します。
  - 画面左上のアイコン（MainMenu）＞「Admin」＞「Settings」を選択します
      - Sign-up Restrictions＞Sign-up enabled: OFF
      - Expandした領域の「Save Changes」からSaveします。
- CI結果をチャットに通知するための通信許可設定を行います。
  - 画面左上のアイコン（MainMenu）＞「Admin」＞「Settings」＞「Network」を選択します
    - Outbound requests＞Allow requests to the local network from webhooks and integrations: ON
    - Expandした領域の「Save Changes」からSaveします。
- ビルドしたプロジェクトをDemoサーバにデプロイする際に必要なコマンドを組み込んだDockerイメージを作るため、sshでアクセスします。
  ```
  $ ssh -F .ssh/ssh.config nop-ci
  ```
- Nexusに証明書を登録することなくCIで使用するDockerイメージをPush/Pullできるように、設定を行います。
  - SSHでアクセスします。
    ```
    $ ssh -F .ssh/ssh.config nop-cq
    ```
  - /etc/docker/daemon.json を編集します。
    ```
    $ sudo vi /etc/docker/daemon.json
    ```
  - Nexusに証明書を登録することなくCIで使用するDockerイメージをPush/Pullできるように、設定を行います。
    ```
    {
      "insecure-registries": ["<NexusのホストのIPアドレス>:19081"]
    }
    ```
    - 設定例を示します。
      ```
      {
        "insecure-registries": ["192.0.2.3:19081"]
      }
      ```
  - Dockerで起動しているアプリを停止し、Dockerを再起動します。
    - アプリを操作するディレクトリに移動します。
      ```
      $ cd ~/nop/docker/ci/
      ```
    - アプリを停止します。
      ```
      $ docker compose stop
      ```
    - Dockerを再起動します。
      ```
      $ sudo systemctl restart docker
      ```
  - CIサーバにNexusへの認証情報を保存するためにDockerで一度ログインします。
    ```
    $ docker login -u admin -p <変更したパスワード> <NexusのホストのIPアドレス>:19081
    ```
    - 例を示します。
      ```
      $ docker login -u admin -p pass123- 192.0.2.3:19081
      ```
- Dockerfileが存在するディレクトリに移動します。
  ```
  $ cd ~/nop/docker/ci/dockerfiles/maven-jdk-17-with-sshpass-on-docker/
  ```
- プロキシ環境下の場合は、イメージのビルドのためにプロキシ設定を行います。
  - Dockerfileを開きます。
    ```
    $ vi Dockerfile
    ```
  - `FROM` 命令の下に、 `/etc/apt/apt.conf` の生成を追記します。  
    プロキシのURLは、プロキシ情報はネットワーク管理者に確認してください。  
    以下に例を示します。
    ```
    FROM maven:3.9.3-amazoncorretto-17-debian
    RUN echo "Acquire::http::proxy \"http://192.0.2.1:3128\";\nAcquire::https::proxy \"http://192.0.2.1:3128\";" > /etc/apt/apt.conf
    ```
- GitLabのCIでビルドする際に使用するDockerイメージを作成します。
  ```
  $ docker build -t <CIサーバのIPアドレス>:19081/maven-jdk-17-with-sshpass-on-docker .
  ```
  - 例を示します。
    ```
    $ docker build -t 192.0.2.3:19081/maven-jdk-17-with-sshpass-on-docker .
    ```
- NexusにDockerイメージをpush作成します。
  ```
  $ docker push <CIサーバのIPアドレス>:19081/maven-jdk-17-with-sshpass-on-docker
  ```
  - 例を示します。
    ```
    $ docker push 192.0.2.3:19081/maven-jdk-17-with-sshpass-on-docker
    ```
- `~/nop/docker/ci/dockerfiles/maven-jdk-8-with-sshpass-on-docker/` 、`~/nop/docker/ci/dockerfiles/maven-jdk-11-with-sshpass-on-docker/`に存在するDockerfileも同様にビルドとpushをします。



これで初期設定は終わりです。
少し休憩したら、[開発準備](dev.md)へ進みましょう。
