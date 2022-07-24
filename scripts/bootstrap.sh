#!/bin/sh

maybe_build_key(){
    if [ -f "/git/data/keys/ssh_host_$1_key" ]
    then
        echo "Found $1 Key...Done"
    else
        echo "Generating $1 Key..."
        ssh-keygen -q -N '' -t $1 -f /git/data/keys/ssh_host_$1_key
        cat /git/data/keys/ssh_host_$1_key.pub
        echo "Generating $1 Key...Done"
    fi
}

echo "Checking for Keys..."
for t in rsa dsa ecdsa ed25519; do
    maybe_build_key $t
done
echo "Checking for Keys...Completed"


link_file(){
    echo "Linking /git/data/users/git_$1..."
    if [ ! -f "/git/data/users/git_$1" ]
    then
        cp /etc/$1 /git/data/users/git_$1
    fi
    ln -sf /git/data/users/git_$1 /etc/$1
    echo "Linking /git/data/users/git_$1...Complete"
}

echo "Setup userdata..."
for f in passwd group shadow; do
    link_file $f
done
echo "Setup userdata...Complete"

if [ ! -z "$GIT_CLIENT_USER" ] && [ ! -z "$GIT_CLIENT_PUBKEY" ]; then
  if [ ! -d "/git/data/users/$GIT_CLIENT_USER" ]; then
    echo "Create initial user $GIT_CLIENT_USER ..."
    if [ ! -z "$BASE64_ENCODED_PUBKEY" ]; then
      echo $GIT_CLIENT_PUBKEY > /tmp/id_rsa.pub.base64
      base64 -d /tmp/id_rsa.pub.base64 > /tmp/id_rsa.pub
    else
      echo $GIT_CLIENT_PUBKEY > /tmp/id_rsa.pub
    fi
    /git/add_git_user.sh $GIT_CLIENT_USER "`cat /tmp/id_rsa.pub`"
    if [ ! -z "$GIT_CLIENT_REPO" ]; then
      if [ ! -d "/git/data/users/$GIT_CLIENT_USER/${GIT_CLIENT_REPO}.git" ]; then
         echo "Creating repo ${GIT_CLIENT_REPO}.git ..."
         git init --bare /git/data/users/$GIT_CLIENT_USER/${GIT_CLIENT_REPO}.git
         chown -R $GIT_CLIENT_USER:$GIT_CLIENT_USER /git/data/users/$GIT_CLIENT_USER/${GIT_CLIENT_REPO}.git
      fi
    fi
  fi
fi

echo "Starting syslogd..."
/sbin/syslogd &

echo "Starting sshd..."
/usr/sbin/sshd &&
    tail -F /var/log/*
