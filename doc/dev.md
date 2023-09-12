プロジェクトの開発準備
================================

ここでは、[ECLIPSE STARTER FOR JAKARTA EE](https://start.jakarta.ee/)を使って、
開発準備を一通り説明しています。
プロジェクトの開発準備の参考にしてください。

- グループを追加します
  - [Redmineでのグループ追加](#redmineでのグループ追加)
  - [Subversionでのグループ追加](#subversionでのグループ追加)
  - [GitBucketでのグループ追加](#gitbucketでのグループ追加)
  - [GitLabでのグループ追加](#gitlabでのグループ追加)
- ユーザを追加します
  - [Redmineでのユーザ追加](#redmineでのユーザ追加)
  - [Rocket.Chatでのユーザ追加](#rocketchatでのユーザ追加)
  - [SonarQubeでのユーザ追加](#sonarqubeでのユーザ追加)
  - [Subversionでのユーザ追加](#subversionでのユーザ追加)
  - [GitBucketでのユーザ追加](#gitbucketでのユーザ追加)
  - [GitLabでのユーザ追加](#gitlabでのユーザ追加)
- プロジェクト(またはリポジトリ)を追加します
  - [Redmineでのプロジェクト追加](#redmineでのプロジェクト追加)
  - [GitBucketでのリポジトリ追加](#gitbucketでのリポジトリ追加)
  - [GitLabでのリポジトリ追加](#gitlabでのリポジトリ追加)
- CIを追加します
  - [JenkinsでのCI追加](#jenkinsでのci追加)
  - [GitLabでのCI追加](#gitlabでのci追加)

## グループを追加します


### Redmineでのグループ追加

#### 管理者

- 管理者でログインします。
- 画面左上の「管理」＞「グループ」＞「新しいグループ」を選択します。
  - 名前: sample
- 作成します。

### Subversionでのグループ追加

#### 管理者
- SSHでアクセスします。
  ```
    $ ssh -F .ssh/ssh.config nop-cq
  ```
- グループを作成します。
  - `/data/svn/repo/conf/authz` を開きます。
    ```
    sudo vi /data/svn/repo/conf/authz
    ```
  - グループを追加し、権限設定を行います。  
    `[groups]` にグループ定義を行い、 `[/]` にリポジトリ全体に対する権限設定を記載します。
    ```
    (中略)
    [groups]
    (中略)
    sample = 
    (中略)
    [/]
    (中略)
    @sample = rw
    ```
- アプリを操作するディレクトリに移動します。
  ```
  cd /home/ec2-user/nop/docker/cq
  ```
- Subversionを再起動します。
  ```
  docker compose restart subversion
  ```


### GitBucketでのグループ追加

#### 管理者

- 管理者でログインします。
- 画面右上の「＋」アイコン＞「New group」を選択します。
  - Group name: sample
- Create groupします。


### GitLabでのグループ追加

#### 管理者

- 管理者でログインします。
- 画面左上のアイコン（MainMenu）＞「Admin」＞画面右側の「New Group」を選択します
  - Group name: sample
  - URL (Optional): sample
- Create groupします。

## ユーザを追加します

### Redmineでのユーザ追加

#### 管理者

- 管理者でログインします。
- 画面左上の「管理」＞「ユーザー」＞「新しいユーザー」を選択します。
  - 必須項目を入力します。
  - 次回ログイン時にパスワード変更を強制: ON
- 作成します。
- グループに追加します。
  - 「グループ」タブを選択します。
    - sampleをチェックし、保存します。

#### 開発メンバ

- 管理者が作成したユーザでログインします。


### Rocket.Chatでのユーザ追加


#### 管理者

- 管理者でログインします。
- 画面左上のプルダウン＞「Workspace」＞「ユーザー」＞画面右の「新規」を選択します。
  - 必須項目を入力します。
  - パスワードの変更を要求: ON
- 作成します。

#### 開発メンバ

- 管理者が作成したユーザでログインします。
- チャンネル「#jenkins」「#gitlab」に参加します。
  - 画面左の「Join rooms」の「Open directory」を選択し、チャンネルを選択します。
    - 画面一番下の「join」を選択します。


### SonarQubeでのユーザ追加

#### 管理者

- 管理者でログインします。
- 「Administrarion」＞「Security」＞画面右の「Create User」を選択します。
  - 必須項目を入力します。
- 作成します。

#### 開発メンバ

- 管理者が作成したユーザでログインします。

### Subversionでのユーザ追加

#### 管理者
- SSHでアクセスします。
  ```
    $ ssh -F .ssh/ssh.config nop-cq
  ```
- ユーザを作成します。  
   htpasswdコマンドの実行時、[アプリの初期設定 Subversion](init.md#subversion)と同じオプション(cオプション)を付けると、既存ユーザが消えます。注意してください。
  - ID: nop
  - パスワード: pass456-  
    ```
    docker exec -t subversion htpasswd -b /etc/apache2/svn-davsvn-htpasswd/davsvn.htpasswd nop pass456-
    ```
- ユーザに権限を付与するため、グループに追加します。
  - `/data/svn/repo/conf/authz` を開きます。
    ```
    sudo vi /data/svn/repo/conf/authz
    ```
  - 作成したユーザをグループに追加します。
    ```
    (中略)
    [groups]
    (中略)
    sample = nop
    (中略)
    ```
- アプリを操作するディレクトリに移動します。
  ```
  cd /home/ec2-user/nop/docker/cq
  ```
- Subversionを再起動します。
  ```
  docker compose restart subversion
  ```

#### 開発メンバ

- 任意のSVNクライアント(TortoiseSVN等)でアクセスします。  
  (ブラウザを使用した場合、プロトコルが強制的に変更されアクセスできないことがありますので、SVNクライアントの使用をお勧めします。)
  ```
  <CQサーバのホスト>/svn/repo/
  ```
- 管理者が作成したユーザでログインします。


### GitBucketでのユーザ追加


#### 管理者

- 管理者でログインします。
- 画面右上のプルダウン(＋の右となり)＞「System Administration」＞「User management＞「New user」を選択します。
  - 必須項目を入力します。
  - Create userします。
- グループに追加します。
  - User managementの一覧で「Include group accounts」にチェックを入れ、sampleの「Edit」を選択します。
    - 「Members」に作成したユーザを追加します。
    - Update groupします。

#### 開発メンバ

- 管理者が作成したユーザでログインします。


### GitLabでのユーザ追加


#### 管理者

- 管理者でログインします。
- 画面左上のアイコン（MainMenu）＞「Admim」＞「Overview」＞「Users」タブ＞「New user」を選択します。
  - 必須項目を入力します。
- Create userします。
- 作成したユーザの「Edit」を選択し、パスワードを設定します。
    - Password/Password confirmationを指定します。
- Save changesします。
- グループに追加します。
  - 画面左上のアイコン（MainMenu）＞「Admim」＞「Overview」タブ＞「Groups」＞「sample」＞を選択します。
    - 「Manage access」を選択します。
    - 「Invite members」を選択します
      - Username or email address: 作成したユーザ
        - Usernameを入力すると候補のユーザーが表示されるので選択します。
      - Select a role: Maintainer
          - 開発ユーザはDeveloperでよいのですが、初回のmasterリポジトリへのpushを行うにはMaintainerの必要があります。
      - invite します。

#### 開発メンバ

- 管理者が作成したユーザでログインします。
  - 画面右上の「画像」＞「Sign out」を選択します。
  - ログインすると、パスワード変更が求められるので変更します。

## プロジェクト(またはリポジトリ)を追加します


### Redmineでのプロジェクト追加


#### 管理者

- 管理者でログインします。
- 画面左上の「プロジェクト」＞「新しいプロジェクト」を選択します。
  - 名前: jakartaee-hello-world
  - 識別子: jakartaee-hello-world
  - モジュール: BacklogsをONにします。
- 作成します。
- 「チケットトラッキング」を選択します。
  - Story、Task をONにします。
  - 保存します。
- グループに追加します。
  - 画面左上の「管理」＞「グループ」＞「sample」＞「プロジェクト」タブ＞「プロジェクトの追加」を選択します。
    - プロジェクト: jakartaee-hello-world
    - ロール: Developer
    - 追加します。

#### 開発メンバ

- 管理者が作成したユーザでログインします。
  - 画面右上の「プロジェクトへ移動」プルダウンでjakartaee-hello-worldに移動できます。


### GitBucketでのリポジトリ追加


#### 管理者

- 管理者でログインします。
- 画面右上の「＋」アイコン＞「New repository」を選択します。
  - Owner: sample
  - Repository name: jakartaee-hello-world
  - Private: ON
  - Initialize this repository with an empty commit: ON
  - Create repositoryします。
- 作成したリポジトリにjakartaee-hello-worldを追加します。
  - 作業PCの適当な場所にjakartaee-hello-worldのプロジェクトを展開します。
    - [Eclipse starter for jakarta ee](https://start.jakarta.ee/) からプロジェクトテンプレートをダウンロードします。
      - 以下の設定でダウンロードします。
        - Jakarta EE version: Jakarta EE 10
        - Jakarta EE profile: Core Profile
        - Java SE version: Java SE 17
        - Runtime: Payara
        - Docker support: Yes
    - ダウンロードしたプロジェクトを展開します。
  - jakartaee-hello-world の直下で次のコマンドを実行します。
    ```
    $ git init
    $ git config --local user.name <作成したユーザのログインID>
    $ git config --local user.email <作成したユーザのメールアドレス>
    $ git remote add origin <リポジトリのURL>
    $ git add .
    $ git commit -m "first commit"
    $ git push -u origin master
    $ git checkout -b develop
    $ git push origin develop
    $ git checkout master
    $ git checkout -b push-docker-image
    $ git push origin push-docker-image
    ```
    - ```! [rejected]        master -> master (non-fast-forward)``` のようにpushがrejectされた場合以下のコマンドで push します。
      ```
      $ git fetch
      $ git merge --allow-unrelated-histories origin/master
      $ git push origin master
      ```
    - <リポジトリのURL>は作成したリポジトリのページで確認します。
    - ユーザ/パスワードを聞かれるので、作成したユーザを指定します。

#### 開発メンバ

- 管理者が作成したユーザでGitBucketにログインします。
  - 画面左の「sample/jakartaee-hello-world」jakartaee-hello-worldに移動できます。


### GitLabでのリポジトリ追加


#### 管理者

- 管理者でログインします。
- 画面左上のアイコン（MainMenu）＞「Admim」＞「Overview」＞「Project」タブ＞「New Project」を選択します。
  - Create Blank Projectを選択します。
    - Project name: jakartaee-hello-world
    - Project URL: sample
    - Initialize repository with a README：OFF
- Create projectします。
- 作成したリポジトリにjakartaee-hello-worldを追加します。
  - 作業PCの適当な場所にjakartaee-hello-worldのプロジェクトを展開します。
    - [Eclipse starter for jakarta ee](https://start.jakarta.ee/) からプロジェクトテンプレートをダウンロードします。
      - 以下の設定でダウンロードします。
        - Jakarta EE version: Jakarta EE 10
        - Jakarta EE profile: Core Profile
        - Java SE version: Java SE 17
        - Runtime: Payara
        - Docker support: Yes
    - ダウンロードしたプロジェクトを展開します。
  - jakartaee-hello-world の直下で次のコマンドを実行します。
    ```
    $ git init
    $ git config --local user.name <作成したユーザのログインID>
    $ git config --local user.email <作成したユーザのメールアドレス>
    $ git remote add origin <リポジトリのURL>
    $ git add .
    $ git commit -m "first commit"
    $ git push -u origin master
    $ git checkout -b develop
    $ git push origin develop
    $ git checkout master
    $ git checkout -b push-docker-image
    $ git push origin push-docker-image
    ```
    - <リポジトリのURL>は作成したリポジトリのページで確認します。
    - ユーザ/パスワードを聞かれるので、作成したユーザを指定します。

#### 開発メンバ

- 管理者が作成したユーザでGitBucketにログインします。
  - 「sample/jakartaee-hello-world」jakartaee-hello-worldに移動できます。

## CIを追加します


### JenkinsでのCI追加


#### 管理者

- パイプラインを準備します。
  - SonarQubeでトークンを生成します。
    - SonarQubeに管理者でログインします。
    - 画面右上の「A」アイコンをクリックし、My Accountを選択します。
    - 画面右上の「Security」を選択します。
    - 「Generate Tokens」で以下のように入力して「Generate」ボタンをクリックする
      - Name: ci
      - Type: Global Analysis Token
      - Expires in : No expiration
    - 生成されたトークンをコピーして保持します。
  - 作業場所でパイプラインをjakartaee-hello-worldにコピーします。
    ```
     $ cp -r pipeline/jenkins/java17/. <jakartaee-hello-worldへのパス>
    ```
  - いくつか設定ファイルを変更していくので、IDEでjakartaee-hello-world(Mavenプロジェクト)を開きます。
  - ブランチをdevelopに切り替えます。
  - pom.xmlを修正します。
    ```
    jakartaee-hello-world/pom.xml
    ```
    - dependencyを追加します。
      ```
      <dependency>
          <groupId>org.junit.jupiter</groupId>
          <artifactId>junit-jupiter-engine</artifactId>
          <version>5.3.2</version>
          <scope>test</scope>
      </dependency>
      ```
    - maven-jib-pluginを追加します。
      ```
            <plugin>
                <groupId>com.google.cloud.tools</groupId>
                <artifactId>jib-maven-plugin</artifactId>
                <version>3.3.2</version>
                <configuration>
                    <allowInsecureRegistries>true</allowInsecureRegistries>
                    <from>
                        <image>payara/server-web:6.2023.5-jdk17</image>
                    </from>
                    <extraDirectories>
                        <paths>
                            <path>
                                <from>target</from>
                                <into>/opt/payara/deployments/</into>
                                <includes>*.war</includes>
                            </path>
                        </paths>
                    </extraDirectories>
                    <container>
                        <creationTime>USE_CURRENT_TIMESTAMP</creationTime>
                    </container>
                </configuration>
            </plugin>
      ```
  - テストクラスを追加します。
    ```
    jakartaee-hello-world/src/test/java/org/eclipse/jakarta/hello/HelloTest.java
    ```
    ```java
    package org.eclipse.jakarta.hello;

    import org.junit.jupiter.api.Test;

    import static org.junit.jupiter.api.Assertions.assertEquals;

    class HelloTest {

        @Test
        void getHelloTest() {
            Hello actual = new Hello("hello");
            assertEquals("hello", actual.getHello());
        }
    }
    ```
  - mvnw関連ファイルを削除します。
    -  readme.mdを修正します。
      - コマンド `./mvnw` → `mvn` に変更します。
  - 次のファイル、ディレクトリを削除します。
    ```
    jakartaee-hello-world/mvnw
    jakartaee-hello-world/mvnw.cmd
    jakartaee-hello-world/.mvn
    ```
  - パイプラインのパラメータを変更します。
    ```
    jakartaee-hello-world/Jenkinsfile
    ```
    - 環境変数を修正します。
      ```
      environment {
        SONAR_HOST_URL = '<SonarQubeのURL>'
        SONAR_TOKEN = '<SonarQubeのトークン>'
        DEMO_HOST = '<Demoサーバのホスト>'
        DEMO_PORT = '<DemoサーバのSSHのポート番号>'
        DEMO_USERNAME = '<DemoサーバのSSHのユーザ名>'
        DEMO_PASSWORD = '<DemoサーバのSSHのパスワード>'
        PROJECT_KEY = "${JOB_NAME}".replaceAll("/", ":")
        CI_HOST = '<CIサーバのホスト>'
        NEXUS_USER = '<Nexusのユーザ名>'
        NEXUS_PASSWORD = '<Nexusのパスワード>'
      }
      ```
    - [URLの仕組み](url.md)を参照し、環境に合わせて適切なURL指定を行ってください。
    - こんな感じになります。
      ```
      environment {
        SONAR_HOST_URL = 'http://192.0.2.2/sonarqube'
        SONAR_TOKEN = 'SONARQUBE_TOKEN'
        DEMO_HOST = '192.0.2.4'
        DEMO_PORT = '22'
        DEMO_USERNAME = 'ec2-user'
        DEMO_PASSWORD = 'pass789-'
        PROJECT_KEY = "${JOB_NAME}".replaceAll("/", ":")
        CI_HOST = '192.0.2.5'
        NEXUS_USER = 'admin'
        NEXUS_PASSWORD = 'pass123-'
      }
      ```
- JenkinsにJDKを追加します。
  - Jenkinsに管理者でログインします。
  - 「Jenkinsの管理」＞「Tools」を選択します。
  - 「JDK追加」をクリックします。入力欄が表示されます。
  - 「インストーラーの削除」をクリックし、「インストーラーの追加」プルダウン＞「*.zip/*.tar.gz展開」を選択します。
  - 各項目を入力します。
    - 名前: JDK17
    - 自動インストール: on
    - *.zip/*.tar.gz展開
      - アーカイブダウンロードURL: `https://qiita.com/boushi-bird@github/items/49627b6a355ea2dfa57a#インストールするjdkを設定する` を参考に入力します。  
        以下に例を示します。
        ```
        https://download.oracle.com/java/17/archive/jdk-17.0.7_linux-x64_bin.tar.gz
        ```
      - アーカイブを展開するサブディレクトリ: 前述のサイトを参考にしてを指定します。  
        以下に例を示します。
        ```
        jdk-17.0.7
        ```
- Jenkinsにジョブを作成します。
  - Jenkinsに管理者でログインします。
  - Multibranch Pipelineを作成します。
    - Multibranch Pipelineにより、リポジトリのブランチを自動検知して、ジョブを自動で追加してくれます。
    - 「新規ジョブ作成」を選択します。
    - ジョブ名を入力: jakartaee-hello-world
    - 「Multibranch Pipeline」を選択します。
    - OKします。
  - 作成したジョブの設定を行います。
    - General
      - 表示名: jakartaee-hello-world
    - Branch Sources
      - 「Add source」プルダウン＞「Git」を選択します。
        - プロジェクトリポジトリ: リポジトリのURLを指定します。
          - [URLの仕組み](url.md)を参照し、環境に合わせて適切なURL指定を行ってください。
          - 例: http://proxy/gitbucket/git/sample/jakartaee-hello-world.git
        - 認証情報:
          - 「追加」プルダウン＞「Jenkins」を選択します。
            - GitBucketで作成したユーザのユーザ名とパスワードを指定します。
            - 追加します。
          - 追加した認証情報を選択します。
    - Scan Multibranch Pipeline Triggers
      - 他のビルドが起動していなければ定期的に起動: ON
        - 間隔: 5minute
    - 保存します。
  - Jenkinsがブランチを検知してジョブが実行されます。
    - 初回は大量の依存モジュールを落としてくるため、少し時間（5分～10分ぐらい）がかかります。
    - 「Deploy to demo」まで成功すると、デプロイされたアプリにアクセスできます。ブラウザでアクセスします。
      ```
      <DEMOサーバのホスト>/jakartaee-hello-world/rest/hello
      ```
  - nexusにdockerイメージをpushするパイプラインのサンプル（`jakartaee-hello-world:push-docker-image`）は同様の手順を実施します。
    - pushする前に不要なディレクトリ（`jakartaee-hello-world/ci/deploy-to-demo`）を削除します。

### GitLabでのCI追加


#### 管理者

- ビルド結果の通知設定を行います。
  - 管理者でログインします。
  - 画面左上の「Gitlab」(アイコン)＞「sample/jakartaee-hello-world」を選択します
  - 「Setting」＞「Webhook」を選択します
    - URL: Rocket.ChatのWebhook URLのプロトコルをHTTPに、ホスト名をCQサーバのURLにしたもの。以下に例を示します。
      ```
      http://192.0.2.2/rocketchat/hooks/ROCKET_CHAT_TOKEN
      ```
    - Secret token: Rocket.Chatのトークンを設定
    - pipeline events:ON
    - 「Add webhook」を選択します。
    - 「Project Hooks」から追加されたwebhookの「Test」＞「Pipeline events」を選択し、接続確認を行います。
- GitLabのCIコンポーネント(GitLab Runner)を登録します。
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
- CIコンポーネント(GitLab Runner)を登録するために必要なトークンを確認します。
  - 画面左上のアイコン（MainMenu）＞「Admin」＞「CI/CD」＞「Runners」を選択します。
  - 「Regiter an instance runner」を選択し、「Registration token」に記載のトークンをコピーします。

- GitLab Runnerを登録します。
  - 画面左上のアイコン（MainMenu）＞「Admim」＞「CI/CD」＞「Runners」を選択します。
    - 「New instance runner」を選択します。
    - runner の情報を設定します。
      - Operating systems: Linux
      - Configuration: Run untagged jobs を選択
      - 「Submit」を選択します。
    - 登録用のトークンが発行されるのでコピーします。
  - SSHでアクセスします。
    ```
    $ ssh -F .ssh/ssh.config nop-ci
    ```
  - CIサーバにNexusへの認証情報を保存するためにDockerで一度ログインします。
    ```
    $ docker login -u admin -p <変更したパスワード> <NexusのホストのIPアドレス>:19081
    ```
    - 例を示します。
      ```
      $ docker login -u admin -p pass123- 192.0.2.3:19081
      ```
  - gitlab-runnerコマンドを起動します。
    ```
    $ docker exec -it gitlab-runner gitlab-runner register
    ```
  - 対話式で情報を入力します。
    - http://\<CIサーバのIPアドレス\>/gitlabを入力します。以下に例を示します。
      ```
      Enter the GitLab instance URL (for example, https://gitlab.com/):
      http://192.0.2.3/gitlab
      ```
    - ブラウザから確認したトークンを入力します。以下に例を示します。
      ```
      Enter the registration token:
      <GITLAB_TOKEN>
      ```
    - ランナー名を入力します。改行のみで問題ないです。
      ```
      Enter a name for the runner. This is stored only in the local config.toml file:
      [xxxxxxxxxxxx]:
      ```
    - executorの種類を入力します。`docker` と入力します。
      ```
      Please enter the executor: shell, docker, docker-ssh, parallels, ssh, virtualbox, docker+machine, docker-ssh+machine, custom, kubernetes:
      docker
      ```
    - CIで使用するDockerイメージのデフォルトを入力します。 `maven:3.9.3-amazoncorretto-17-debian` と入力します。
      ```
      Please enter the default Docker image (e.g. ruby:2.6):
      maven:3.9.3-amazoncorretto-17-debian
      ```
  - config.tomlを編集します。
    - viを起動します。
      ```
      $ sudo vi /data/gitlab-runner/config/config.toml
      ```
    - `clone_url = "http://<CIサーバのIPアドレス>/gitlab"`、`pull_policy = ["if-not-present", "always"]` を追記します。以下に例を示します。
      ```
      (中略)
      [[runners]]
      (中略)
        executor = "docker"
        clone_url = "http://192.0.2.3/gitlab" 
        [runners.custom_build_dir]
      (中略)
        [runners.docker]
      (中略)
          shm_size = 0
          pull_policy= ["if-not-present", "always"]
      (中略)
      ```

- GitLabにGitLabのCIコンポーネント(GitLab Runner)を登録されたことを確認します。
  - ブラウザでGitLabにアクセスします。
  - 画面左上のアイコン（MainMenu）＞「Admin」＞「CI/CD」＞「Runners」を選択し、Runnerが存在することを確認します。
  - 登録した以外のRunnerが存在する場合、使わないため消します。

- パイプラインを準備します。
  - SonarQubeでトークンを生成します。
    - SonarQubeに管理者でログインします。
    - 画面右上の「A」アイコンをクリックし、My Accountを選択します。
    - 画面右上の「Security」を選択します。
    - 「Generate Tokens」で以下のように入力して「Generate」ボタンをクリックする
      - Name: ci
      - Type: Global Analysis Token
      - Expires in : No expiration
    - 生成されたトークンをコピーして保持します。
  - 作業場所でパイプラインをjakartaee-hello-worldにコピーします。
    ```
    $ cp -r pipeline/gitlab/java17/. <jakartaee-hello-worldへのパス>
    ```
  - いくつか設定ファイルを変更していくので、jakartaee-hello-world(Mavenプロジェクト)を開きます。
  - ブランチをdevelopに切り替えます。
  - pom.xmlを修正します。
    ```
    jakartaee-hello-world/pom.xml
    ```
    - dependencyを追加します。
      ```
      <dependency>
          <groupId>org.junit.jupiter</groupId>
          <artifactId>junit-jupiter-engine</artifactId>
          <version>5.3.2</version>
          <scope>test</scope>
      </dependency>
      ```
    - maven-jib-pluginを追加します。
      ```
            <plugin>
                <groupId>com.google.cloud.tools</groupId>
                <artifactId>jib-maven-plugin</artifactId>
                <version>3.3.2</version>
                <configuration>
                    <allowInsecureRegistries>true</allowInsecureRegistries>
                    <from>
                        <image>payara/server-web:6.2023.5-jdk17</image>
                    </from>
                    <extraDirectories>
                        <paths>
                            <path>
                                <from>target</from>
                                <into>/opt/payara/deployments/</into>
                                <includes>*.war</includes>
                            </path>
                        </paths>
                    </extraDirectories>
                    <container>
                        <creationTime>USE_CURRENT_TIMESTAMP</creationTime>
                    </container>
                </configuration>
            </plugin>
      ```
  - テストクラスを追加します。
    ```
    jakartaee-hello-world/src/test/java/org/eclipse/jakarta/hello/HelloTest.java
    ```
    ```
    package org.eclipse.jakarta.hello;

    import org.junit.jupiter.api.Test;

    import static org.junit.jupiter.api.Assertions.assertEquals;

    class HelloTest {

        @Test
        void getHelloTest() {
            Hello actual = new Hello("hello");
            assertEquals("hello", actual.getHello());
        }
    }
    ```
  - mvnw関連ファイルを削除します。
    -  readme.mdを修正します。
    - コマンド `./mvnw` → `mvn` に変更します。
  - 次のファイル、ディレクトリを削除します。
    ```
    jakartaee-hello-world/mvnw
    jakartaee-hello-world/mvnw.cmd
    jakartaee-hello-world/.mvn
    ```

  - パイプラインのパラメータを変更します。
    ```
    jakartaee-hello-world/.gitlab-ci.yml
    ```
    - 環境変数を修正します。
      ```
      image: <CIサーバのホスト>:19081/<イメージ名>
      (中略)
      variables:
        SONAR_HOST_URL: <SonarQubeのURL>
        SONAR_TOKEN: <SonarQubeのトークン>
        DEMO_HOST: <Demoサーバのホスト>
        DEMO_PORT: <DemoサーバのSSHのポート番号>
        DEMO_USERNAME: <DemoサーバのSSHのユーザ名>
        DEMO_PASSWORD: <DemoサーバのSSHのパスワード>
        CI_HOST: <CIサーバのホスト>
        NEXUS_USER: <Nexusのユーザ名>
        NEXUS_PASSWORD: <Nexusのパスワード>
      ```
       - [URLの仕組み](url.md)を参照し、環境に合わせて適切なURL指定を行ってください。
    - こんな感じになります。
      ```
      image: 192.0.2.3:19081/maven-jdk-17-with-sshpass-on-docker
      (中略)
      variables:
        SONAR_HOST_URL: 192.0.2.2
        SONAR_TOKEN: SONARQUBE_TOKEN
        DEMO_HOST: 192.0.2.4
        DEMO_PORT: 22
        DEMO_USERNAME: ec2-user
        DEMO_PASSWORD: pass789-
        CI_HOST: 192.0.2.3
        NEXUS_USER: admin
        NEXUS_PASSWORD: pass123-       
      ```
  - パイプラインのパラメータを変更します。
    ```
    jakartaee-hello-world/ci/settings.xml
    ```
    - MavenリポジトリのURLを修正します。
      ```
      <url>http://<CIサーバ>/nexus/repository/maven-public/</url>
      ```
    - [URLの仕組み](url.md)を参照し、環境に合わせて適切なURL指定を行ってください。
    - こんな感じになります。
      ```
      <url>http://192.0.2.3/nexus/repository/maven-public/</url>
      ```
  - pushします。
  - GitLabが変更を検知し、ビルドが実行されます。
  - nexusにdockerイメージをpushするパイプラインのサンプル（`jakartaee-hello-world:push-docker-image`）は同様の手順を実施します。。
    - pushする前に不要なディレクトリ（`jakartaee-hello-world/ci/deploy-to-demo`）を削除します。

これで開発準備は終わりです！
お疲れさまでしたー
