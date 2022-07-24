# Git Server

![](https://git-scm.herokuapp.com/images/logos/2color-lightbg@2x.png)

## Intro

This is a simple git server

## To build

```shell
docker build -t git-server .
```

## Start git daemon

Create a volume to preserve the data
```shell
docker volume create git_data
```

Start the container:
```shell
docker container run -d -p 2222:22 \
   --name git-server \
   -v git_data:/git/data \
   git-server
```

Or start the container and create a initial user

```shell
docker container run -d -p 2222:22 \
   -e GIT_CLIENT_USER=my_user \
   -e GIT_CLIENT_PUBKEY=$GIT_CLIENT_PUBKEY \
   -e GIT_CLIENT_REPO=my_repo \
   -e BASE64_ENCODED_PUBKEY=true \
   --name git-server \
   -v git_data:/git/data \
   git-server
```
> When the BASE64_ENCODED_PUBKEY=true. You need to encode your public key:

```
export GIT_CLIENT_PUBKEY=`cat ~/.ssh/id_rsa.pub | base64 -w0`
```

## Setup a repo

Add a user:
```shell
docker exec git-server sh add_git_user.sh `whoami` "`cat ~/.ssh/id_rsa.pub`"
```

Initialize a new repo `my_repo`:
```shell
ssh localhost -p 2222 "init my_repo.git"
```

## To Use

Create a repository named `my_repo`
```shell
mkdir ~/my_repo && cd ~/my_repo
git init
echo "## README" > README.md
git add .
git commit -m 'Add files'
```

Add remote to your git repository:
```shell
git remote add origin ssh://localhost:2222/~/my_repo.git
```

And push:
```shell
git push -u origin master
```

## Maintenance

Arquitetura Team
- Juan Enciso (juan.enciso@unicred.com.br)
