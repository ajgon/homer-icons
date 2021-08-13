FROM alpine:3.14

ENV VERSION=1.14.0

WORKDIR /usr/src

RUN apk add --no-cache git imagemagick libc6-compat nodejs npm openssh-client zip

RUN wget https://github.com/cli/cli/releases/download/v${VERSION}/gh_${VERSION}_linux_amd64.tar.gz \
 && tar -xzvf gh_${VERSION}_linux_amd64.tar.gz \
 && mv gh_${VERSION}_linux_amd64/bin/gh /usr/bin \
 && rm -rf gh_${VERSION}_linux_amd64*

RUN npm install -g svgo

RUN echo -e "[user]\n    name = Deploy Bot\n    email = bot@deploy.com" > /root/.gitconfig \
 && mkdir -p /root/.ssh \
 && ssh-keyscan -H github.com > /root/.ssh/known_hosts > /root/.ssh/known_hosts

COPY entrypoint.sh /usr/bin/entrypoint.sh

WORKDIR /icons

ENTRYPOINT ["entrypoint.sh"]
