#!/bin/sh

if [ -n "$SVN_REPO" ]; then
test ! -d "/var/svn/$SVN_REPO" && svnadmin create /var/svn/$SVN_REPO && chgrp -R apache /var/svn/$SVN_REPO && chmod -R 775 /var/svn/$SVN_REPO
echo "Creating the repository: $SVN_REPO into /var/svn/"
else
test ! -d "/var/svn/testrepo" && svnadmin create /var/svn/testrepo && chgrp -R apache /var/svn/testrepo && chmod -R 775 /var/svn/testrepo
echo "Warning: SVN_REPO variable not defined, starting with svn default repository: testrepo into /var/svn/"
fi

httpd -D FOREGROUND