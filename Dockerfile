FROM alpine:3.14

ENV VERSION=1.14.0

ARG USER_ID=1000
ARG GROUP_ID=1000

RUN addgroup -g ${GROUP_ID} user \
 && adduser -u ${USER_ID} -G user -D user

WORKDIR /usr/src

RUN apk add --no-cache git imagemagick libc6-compat nodejs npm openssh-client zip

RUN wget https://github.com/cli/cli/releases/download/v${VERSION}/gh_${VERSION}_linux_amd64.tar.gz \
 && tar -xzvf gh_${VERSION}_linux_amd64.tar.gz \
 && mv gh_${VERSION}_linux_amd64/bin/gh /usr/bin \
 && rm -rf gh_${VERSION}_linux_amd64*

RUN npm install -g svgo

COPY entrypoint.sh /usr/bin/entrypoint.sh

USER user

RUN echo -e "[user]\n    name = Deploy Bot\n    email = bot@deploy.com" > /home/user/.gitconfig \
 && mkdir -p /home/user/.ssh \
 && ssh-keyscan -H github.com > /home/user/.ssh/known_hosts > /home/user/.ssh/known_hosts

WORKDIR /icons

ENTRYPOINT ["entrypoint.sh"]
