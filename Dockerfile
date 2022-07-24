FROM alpine:3.6

RUN apk add --no-cache openssh git

RUN apk add --no-cache --virtual config_editing sed \
    && sed -i /etc/ssh/sshd_config \
        -e 's/#PasswordAuthentication yes/PasswordAuthentication no/g' \
        -e 's/#AllowAgentForwarding yes/AllowAgentForwarding no/g' \
        -e 's/#AllowTcpForwarding yes/AllowTcpForwarding no/g' \
        -e 's|#HostKey /etc/ssh/|HostKey /git/data/keys/|g' \
    && apk del config_editing

RUN mkdir -p /git/data \
    && mkdir -p /git/data/keys \
    && mkdir -p /git/data/users

WORKDIR /git

## Copy configurations
COPY conf/skel /etc/skel

## Copy scripts
COPY scripts/add_git_user.sh ./
COPY scripts/del_git_user.sh ./
COPY scripts/bootstrap.sh ./

## Set permissions
RUN chmod +x ./add_git_user.sh
RUN chmod +x ./del_git_user.sh
RUN chmod +x ./bootstrap.sh

RUN touch /var/log/messages


EXPOSE 22
VOLUME /git/data

ENTRYPOINT ["/git/bootstrap.sh"]
