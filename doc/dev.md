プロジェクトの開発準備
================================

ここでは、[nablarch-example-web](https://github.com/nablarch/nablarch-example-web)を使って、
開発準備を一通り説明しています。
プロジェクトの開発準備の参考にしてください。

- グループを追加します
  - [Redmineでのグループ追加](#redmineでのグループ追加)
  - [GitBucketでのグループ追加](#gitbucketでのグループ追加)
  - [GitLabでのグループ追加](#gitlabでのグループ追加)
- ユーザを追加します
  - [Redmineでのユーザ追加](#redmineでのユーザ追加)
  - [Rocket.Chatでのユーザ追加](#rocketchatでのユーザ追加)
  - [GitBucketでのユーザ追加](#gitbucketでのユーザ追加)
  - [GitLabでのユーザ追加](#gitlabでのユーザ追加)
- プロジェクト(またはリポジトリ)を追加します
  - [Redmineでのプロジェクト追加](#redmineでのプロジェクト追加)
  - [GitBucketでのリポジトリ追加](#gitbucketでのリポジトリ追加)
  - [GitLabでのリポジトリ追加](#gitlabでのリポジトリ追加)
- CIを追加します
  - [JenkinsでのCI追加](#jenkinsでのci追加)
  - [ConcourseでのCI追加](#concourseでのci追加)

## グループを追加します


### Redmineでのグループ追加

#### 管理者

- 管理者でログインします。
- 画面左上の「管理」＞「グループ」＞「新しいグループ」を選択します。
  - 名前: sample
- 作成します。


### GitBucketでのグループ追加

#### 管理者

- 管理者でログインします。
- 画面右上の「＋」アイコン＞「New group」を選択します。
  - Group name: sample
- Create groupします。


### GitLabでのグループ追加

#### 管理者

- 管理者でログインします。
- 画面右上の「＋」アイコン＞「New group」を選択します。
  - Group path: sample
  - Group name: sample
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
- 画面左上のプルダウン＞「管理」＞「ユーザー」＞画面右の「＋」アイコンを選択します。
  - 必須項目を入力します。
  - パスワードの変更を要求: ON
- 作成します。

#### 開発メンバ

- 管理者が作成したユーザでログインします。
- チャンネル「#jenkins」「#concourse」に参加します。
  - 画面左の「その他のチャンネル...」を選択し、チャンネルを選択します。
    - 画面一番下の「参加」を選択します。


### GitBucketでのユーザ追加


#### 管理者

- 管理者でログインします。
- 画面右上のプルダウン(＋の右となり)＞「System Administration」＞「User management＞「New user」を選択します。
  - 必須項目を入力します。
  - Create userします。
- グループに追加します。
  - User managementの一覧からsampleの「Edit」を選択します。
    - 「Members」に作成したユーザを追加します。
    - Update groupします。

#### 開発メンバ

- 管理者が作成したユーザでログインします。


### GitLabでのユーザ追加


#### 管理者

- 管理者でログインします。
- 画面右上の「レンチ」(Admin area)アイコン＞「Overview」タブ＞「Users」タブ＞「New user」を選択します。
  - 必須項目を入力します。
- Create userします。
- 作成したユーザの「Edit」を選択し、パスワードを設定します。
    - Password/Password confirmationを指定します。
- Save changesします。
- グループに追加します。
  - 画面左上の「ハンバーガーメニュー」(三本線)＞「Groups」＞「sample as Owner」＞「Members」タブを選択します。
    - Add new member to sample: 作成したユーザ
    - role permissions: Guest->Master
      - 開発ユーザはDeveloperでよいのですが、初回のmasterリポジトリへのpushを行うにはMasterの必要があります。
    - Add to groupします。

#### 開発メンバ

- 管理者が作成したユーザでログインします。
  - 画面右上の「画像」＞「Sign out」を選択します。
  - ログインすると、パスワード変更が求められるので変更します。

## プロジェクト(またはリポジトリ)を追加します


### Redmineでのプロジェクト追加


#### 管理者

- 管理者でログインします。
- 画面左上の「プロジェクト」＞「新しいプロジェクト」を選択します。
  - 名前: nablarch-example-web
  - 識別子: nablarch-example-web
  - モジュール: BacklogsをONにします。
- 作成します。
- グループに追加します。
  - 画面左上の「管理」＞「グループ」＞「sample」＞「プロジェクト」タブ＞「プロジェクトの追加」を選択します。
    - プロジェクト: nablarch-example-web
    - ロール: Developer
    - 追加します。

#### 開発メンバ

- 管理者が作成したユーザでログインします。
  - 画面右上の「プロジェクトへ移動」プルダウンでnablarch-example-webに移動できます。


### GitBucketでのリポジトリ追加


#### 管理者

- 管理者でログインします。
- 画面右上の「＋」アイコン＞「New repository」を選択します。
  - Owner: sample
  - Repository name: nablarch-example-web
  - Private: ON
  - Initialize this repository with a README: OFF
    ※nablarch-example-web(既に存在するプロジェクト)を追加するのでREADME作成をOFFにしています。
      新しくリポジトリを作成する場合はREADME作成をONにして、git cloneから開発をスタートできます。
  - Create repositoryします。
- 作成したリポジトリにnablarch-example-webを追加します。
  - 作業PCの適当な場所で次のコマンドを実行します。
    ```
    $ git clone https://github.com/nablarch/nablarch-example-web.git
    $ cd nablarch-example-web/
    $ git remote rm origin
    $ git remote add origin <リポジトリのURL>
    $ git push -u origin master
    $ git checkout -b develop
    $ git push origin develop
    ```
    - <リポジトリのURL>は作成したリポジトリのページで確認します。
      - ![リポジトリのURL](images/gitbucket-repository-url.png)
    - ユーザ/パスワードを聞かれるので、作成したユーザを指定します。

#### 開発メンバ

- 管理者が作成したユーザでGitBucketにログインします。
  - 画面左の「sample/nablarch-example-web」からnablarch-example-webに移動できます。


### GitLabでのリポジトリ追加


#### 管理者

- 管理者でログインします。
- 画面右上の「＋」アイコン＞「New project」を選択します。
  - Project path: sample
  - Project name: nablarch-example-web
- Create projectします。
- オレンジ色でSSHに関するメッセージが表示されるので、「Don't show again」を選択します。
- 作成したリポジトリにnablarch-example-webを追加します。
  - 作業PCの適当な場所で次のコマンドを実行します。
    ```
    $ git clone https://github.com/nablarch/nablarch-example-web.git
    $ cd nablarch-example-web/
    $ git remote rm origin
    $ git remote add origin <リポジトリのURL>
    $ git push -u origin master
    $ git checkout -b develop
    $ git push origin develop
    ```
    - <リポジトリのURL>は作成したリポジトリのページで確認します。
      - ![リポジトリのURL](images/gitlab-repository-url.png)
    - ユーザ/パスワードを聞かれるので、作成したユーザを指定します。

#### 開発メンバ

- 管理者が作成したユーザでGitLabにログインします。
  - 「sample/nablarch-example-web」からnablarch-example-webに移動できます。

## CIを追加します


### JenkinsでのCI追加


#### 管理者

- パイプラインを準備します。
  - 作業場所でパイプラインをnablarch-example-webにコピーします。
    - Java 8でビルドする場合
      ```
      $ cp -r pipeline/jenkins/java8/* <nablarch-example-webへのパス>
      ```
    - Java 11でビルドする場合
      ```
      $ cp -r pipeline/jenkins/java11/* <nablarch-example-webへのパス>
      ```
  - いくつか設定ファイルを変更していくので、IDEでnablarch-example-web(Mavenプロジェクト)を開きます。
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
  - Executable Jarでデプロイするため、waitt-maven-pluginの設定を変更します。
    ```
    nablarch-example-web/pom.xml
    ```
    - waitt-maven-plugin/waitt-tomcat8のバージョン番号を1.2.1に変更します。1.2.1以上であれば変更しなくても大丈夫です。
      ```
      <plugin>
        <groupId>net.unit8.waitt</groupId>
        <artifactId>waitt-maven-plugin</artifactId>
        <version>1.2.1</version>
        <configuration>
          <servers>
            <server>
              <groupId>net.unit8.waitt.server</groupId>
              <artifactId>waitt-tomcat8</artifactId>
              <version>1.2.1</version>
            </server>
          </servers>
        </configuration>
      </plugin>
      ```
  - pushします。
- Java 11でビルドする場合は、JenkinsにJDKを追加します。
  - Jenkinsに管理者でログインします。
  - 「Jenkinsの管理」＞「Global Tool Configuration」を選択します。
  - 「JDK追加」をクリックします。入力欄が表示されます。
  - 「インストーラーの削除」をクリックし、「インストーラーの追加」プルダウン＞「*.zip/*.tar.gz展開」を選択します。
  - 各項目を入力します。
    - 名前: JDK11
    - 自動インストール: on
    - *.zip/*.tar.gz展開
      - ラベル: 空欄
      - アーカイブダウンロードURL: `https://qiita.com/boushi-bird@github/items/49627b6a355ea2dfa57a#インストールするjdkを設定する` を参考に入力します。  
        以下に例を示します。
        ```
        https://download.java.net/java/GA/jdk11/9/GPL/openjdk-11.0.2_linux-x64_bin.tar.gz
        ```
      - アーカイブを展開するサブディレクトリ: ユニークなディレクトリを指定します。  
        以下に例を示します。
        ```
        jdk-11.0.2
        ```
- Jenkinsにジョブを作成します。
  - Jenkinsに管理者でログインします。
  - Multibranch Pipelineを作成します。
    - Multibranch Pipelineにより、リポジトリのブランチを自動検知して、ジョブを自動で追加してくれます。
    - 「新しいジョブを作成してください。」を選択します。
    - Enter an item name: nablarch-example-web
    - 「Multibranch Pipeline」を選択します。
    - OKします。
  - 作成したジョブの設定を行います。
    - Branch Sources
      - 「Add source」プルダウン＞「Git」を選択します。
        - プロジェクトリポジトリ: リポジトリのURLを指定します。
          - [URLの仕組み](url.md)を参照し、環境に合わせて適切なURL指定を行ってください。
          - 例: http://proxy/gitbucket/git/sample/nablarch-example-web.git
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
      <DEMOサーバのホスト>/
      ```
      - ログインID: 10000001
      - パスワード: pass123-


### ConcourseでのCI追加


#### 管理者

- パイプラインを準備します。
  - 作業場所でパイプラインをnablarch-example-webにコピーします。
    ```
    $ cp -r pipeline/concourse/* <nablarch-example-webへのパス>
    ```
  - いくつか設定ファイルを変更していくので、IDEでnablarch-example-web(Mavenプロジェクト)を開きます。
  - パイプラインのパラメータを変更します。
    ```
    nablarch-example-web/ci/params.yml
    ```
    - [URLの仕組み](url.md)を参照し、環境に合わせて適切なURL指定を行ってください。
    - パラメータの設定は以下のような感じになります。
      ```
      git-project-url: http://proxy/gitlab/sample/nablarch-example-web.git

      docker-repo-host-port: nexus.repository:18444
      docker-repo-username: admin
      docker-repo-password: pass123-
      
      sonar-url: http://10.0.1.217/sonarqube
      
      chat-webhook-url: http://10.0.1.217/rocketchat/hooks/KMFduPo2KDqRLsAwp/RkL...
      
      demo-host: 10.0.1.121
      demo-port: 22
      demo-username: centos
      demo-password: pass789-
      ```
  - パイプラインで使うMavenの設定を変更します。
    ```
    nablarch-example-web/ci/settings.xml
    ```
    - Nexusのユーザ名/パスワードだけを変更します。
  - Executable Jarでデプロイするため、waitt-maven-pluginの設定を変更します。
    ```
    nablarch-example-web/pom.xml
    ```
    - waitt-maven-plugin/waitt-tomcat8のバージョン番号を1.2.1に変更します。1.2.1以上であれば変更しなくても大丈夫です。
      ```
      <plugin>
        <groupId>net.unit8.waitt</groupId>
        <artifactId>waitt-maven-plugin</artifactId>
        <version>1.2.1</version>
        <configuration>
          <servers>
            <server>
              <groupId>net.unit8.waitt.server</groupId>
              <artifactId>waitt-tomcat8</artifactId>
              <version>1.2.1</version>
            </server>
          </servers>
        </configuration>
      </plugin>
      ```
  - Mavenリポジトリにデプロイするため、distributionManagementの設定を追加します。
    ```
    nablarch-example-web/pom.xml
    ```
    - distributionManagementを追加します。このままコピペします。
      ```
      <distributionManagement>
        <repository>
          <id>private-release</id>
          <url>http://proxy/nexus/repository/maven-releases/</url>
        </repository>
        <snapshotRepository>
          <id>private-snapshot</id>
          <url>http://proxy/nexus/repository/maven-snapshots/</url>
        </snapshotRepository>
      </distributionManagement>
      ```
    - 一番外側のprojectタグの閉じタグの直前に入れておけば大丈夫です。
  - pushします。
- Concouseにパイプラインを設定します。
  - Concourseへのパイプライン設定はflyコマンドで行います。
  - Concourseにアクセスしてツールをダウンロードします。
    - インストールしたConcourseのトップページにアクセスします。
    - 作業マシンのOSと同じアイコン(画面中央にあります)を選択して、ツールをダウンロードします。
    - ツールにパスを通すか、nablarch-example-web/ciに置いて直接実行して使います。
  - flyコマンドでConcouseにログインします。パスを通してない場合は「fly」→「fly.exe」で実行してください。
    ```
    $ cd <nablarch-example-web/ciへのパス>
    $ fly -t main login -c <ConcourseのURL> -k
    ```
    - ConcourseのURLはブラウザでアクセスする場合と同じものを指定します。
    - username/passwordが聞かれるので、docker-composeの定義ファイルに指定したものを入力します。
      - 「target saved」と表示されればログイン成功です。
      - こんな感じになります。
        ```
        $ fly -t main login -c https://nop-ci.adc-tis.com/ -k
        logging in to team 'main'
        
        username: admin
        admin
        password: pass123-
        
        target saved
        ```
  - flyコマンドでパイプラインを設定します。
    ```
    $ fly -t main sp -p nablarch-example-web -c pipeline.yml -l params.yml
    ```
    - 「apply configuration? [yN]:」と聞かれるので「y」と答えます。
    - パイプラインを変更した場合はこのコマンドで更新します。
  - ブラウザでConcourseにアクセスしてCIを実行します。
    - Concourseがパイプラインを検知して、画面にパイプラインが表示されます。
    - 表示されない場合は画面を更新してください。
    - はじめは一時停止状態なので、画面左上の「メニュー」＞nablarch-example-webの「再生」アイコンを選択します。
      - ![ConcourseのUnpause](images/concourse-unpause.png)
  - 初回は大量の依存モジュールを落としてくるため、少し時間（5分～10分ぐらい）がかかります。
  - 「deploy-to-demo-develop」まで成功すると、デプロイされたアプリにアクセスできます。ブラウザでアクセスします。
    ```
    <DEMOサーバのホスト>/
    ```
    - ログインID: 10000001
    - パスワード: pass123-

これで開発準備は終わりです！
お疲れさまでしたー
