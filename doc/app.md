シェルスクリプトでOSの初期設定～アプリのインストール
================================================================

ここでは、サーバが起動している前提で、OSの初期設定～アプリのインストールまで行います。

※作業場所のディレクトリを「nop」とします(「nop」はCollaborageのコードネームです)。

- 多段SSHを使って、踏み台サーバ経由でスクリプトファイルを各EC2インスタンスにコピーします。そして、各EC2インスタンス内でシェルスクリプトを実行します。多段SSHは[このあたり](https://www.google.co.jp/search?q=%E5%A4%9A%E6%AE%B5ssh&oq=%E5%A4%9A%E6%AE%B5ssh&gs_l=psy-ab.3..0i71k1l4.0.0.0.3362.0.0.0.0.0.0.0.0..0.0....0...1..64.psy-ab..0.0.0.vBzx5nON7hY)を参照してください。
- 多段SSHを準備します。
  - SSHの接続設定を修正します。
    ```
    nop/.ssh/ssh.config
    ```
  - 作業場所で各EC2インスタンスにアクセスできることを確認します。
    ```
    $ ssh -F .ssh/ssh.config nop-bastion
    $ ssh -F .ssh/ssh.config nop-cq
    $ ssh -F .ssh/ssh.config nop-ci
    $ ssh -F .ssh/ssh.config nop-demo
    ```
- シェルスクリプトのパラメータを修正します。
    ```
    nop/script/config/params.config
    ```
  - SNSで作成済みのトピックのARNが必要になります。
    - AWSマネジメントコンソールでSNSにアクセスし、トピックのARNを確認します。
      - ![SNSのトピックARN](images/aws-sns-topicarn.png)
- docker-composeの定義を変更します。アプリで画面から設定できないため、事前に定義ファイルに指定します。
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
  - Concourseを使用する場合は、Concourseの外部URLとログインに使用するユーザ名/パスワードを指定します。
    ```
    nop/docker/ci/docker-compose.yml
    ```
    - 「concourse-web」＞「environment」＞「CONCOURSE_XXXXXXXX」に指定します。
      ```
      concourse-web:
        container_name: concourse-web
        # 省略
        environment:
          # 省略
          CONCOURSE_EXTERNAL_URL: <ブラウザからConcourseにアクセスする場合のURL>
          CONCOURSE_BASIC_AUTH_USERNAME: <ユーザ名>
          CONCOURSE_BASIC_AUTH_PASSWORD: <パスワード>
          CONCOURSE_NO_REALLY_I_DONT_WANT_ANY_AUTH:
      ```
    - ConcourseのURLは「<ホスト>/」となります。Concourseはベースパスに対応していないため、URLはパス指定なしです。設定例を示します。
      ```
      CONCOURSE_EXTERNAL_URL: https://nop-ci.adc-tis.com/
      CONCOURSE_BASIC_AUTH_USERNAME: admin
      CONCOURSE_BASIC_AUTH_PASSWORD: pass123-
      ```
  - GitLabを使用する場合は、GitLabの外部URLを指定します。
    ```
    nop/docker/ci/docker-compose.yml
    ```
    - 「gitlab」＞「environment」＞「GITLAB_OMNIBUS_CONFIG」＞「external_url」に指定します。
      ```
      gitlab:
        container_name: gitlab
        # 省略
        environment:
          GITLAB_OMNIBUS_CONFIG: |
            external_url '<ブラウザからGitLabにアクセスする場合のURL>'
            gitlab_rails['time_zone'] = 'Tokyo'
            gitlab_rails['db_adapter'] = 'postgresql'
      ```
    - GitLabのURLは「<ホスト>/gitlab」となります。設定例を示します。
      ```
      external_url 'https://nop-ci.adc-tis.com/gitlab/'
      ```
- Concourseを使用する場合は、カーネルをバージョンアップします。
  - SSHでCIサーバに入って「[VagrantのCentOS7のカーネルを更新(yum)](http://qiita.com/reflet/items/b1d9f169dfdad69c4d35)」を参照して作業します。
  - 実際に作業した様子はこんな感じになります。
    ```
    $ sudo rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
    $ sudo rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-2.el7.elrepo.noarch.rpm
       :
    （省略）
       :
    $ sudo vi /etc/yum.repos.d/elrepo.repo
    （[elrepo-kernel]を有効にします。[elrepo-kernel]のenabled=0をenabled=1にします）
    $ rpm -qa kernel\* | sort
    kernel-3.10.0-514.16.1.el7.x86_64
    kernel-3.10.0-514.26.2.el7.x86_64
    kernel-tools-3.10.0-514.26.2.el7.x86_64
    kernel-tools-libs-3.10.0-514.26.2.el7.x86_64
    $ sudo yum -y remove \
    kernel-3.10.0-514.16.1.el7.x86_64 \
    kernel-3.10.0-514.26.2.el7.x86_64 \
    kernel-tools-3.10.0-514.26.2.el7.x86_64 \
    kernel-tools-libs-3.10.0-514.26.2.el7.x86_64
       :
    （省略）
       :
    完了しました!
    $ sudo yum -y update
       :
    （省略）
       :
    完了しました!
    $ sudo yum -y install kernel-ml.x86_64 \
    kernel-ml-devel.x86_64 \
    kernel-ml-headers.x86_64 \
    kernel-ml-tools.x86_64 \
    kernel-ml-tools-libs.x86_64
       :
    （省略）
       :
    完了しました!
    $ sudo awk -F\' '$1=="menuentry " {print $2}' /etc/grub2.cfg
    CentOS Linux (4.12.10-1.el7.elrepo.x86_64) 7 (Core)
    CentOS Linux (3.10.0-514.26.2.el7.x86_64) 7 (Core)
    CentOS Linux (0-rescue-8bd05758fdfc1903174c9fcaf82b71ca) 7 (Core)
    $ sudo grub2-set-default 0
    $ sudo grub2-mkconfig -o /boot/grub2/grub.cfg
    Generating grub configuration file ...
       :
    （省略）
       :
    done
    $ sudo reboot

    （再起動後）
    $ uname -r
    4.12.10-1.el7.elrepo.x86_64
    $ sudo yum remove kernel
       :
    （省略）
       :
    上記の処理を行います。よろしいでしょうか？ [y/N]y
       :
    （省略）
       :
    完了しました!
    $ rpm -qa kernel\* | sort
    kernel-ml-4.12.10-1.el7.elrepo.x86_64
    kernel-ml-devel-4.12.10-1.el7.elrepo.x86_64
    kernel-ml-headers-4.12.10-1.el7.elrepo.x86_64
    kernel-ml-tools-4.12.10-1.el7.elrepo.x86_64
    kernel-ml-tools-libs-4.12.10-1.el7.elrepo.x86_64
    ```
- 準備が出来ました。インストールします。
  ```
  $ ./install.sh
  # install started
     :
    省略
     :
  # install completed
  $ 
  ```
  - 「# install completed」と表示されて実行が終了すればインストール完了です。

アプリのインストールは終わりです。
