# ------------------------------------------------------
#                       Dockerfile
# ------------------------------------------------------
# image:    hubot
# name:     minddocdev/hubot
# repo:     https://github.com/mind-doc/hubot
# Requires: node:alpine
# authors:  development@minddoc.com
# ------------------------------------------------------

FROM node:lts-alpine

LABEL maintainer="development@minddoc.com"

# Install hubot dependencies
RUN apk update\
 && apk upgrade\
 && apk add jq git\
 && npm install -g yo generator-hubot@next\
 && rm -rf /var/cache/apk/*

# Create hubot user with privileges
RUN addgroup -g 501 hubot\
 && adduser -D -h /hubot -u 501 -G hubot hubot
ENV HOME /home/hubot
WORKDIR $HOME
COPY entrypoint.sh ./
RUN chown -R hubot:hubot .
USER hubot

# Install hubot version HUBOT_VERSION
ENV HUBOT_NAME "robot"
ENV HUBOT_OWNER "MindDoc <development@minddoc.com>"
ENV HUBOT_DESCRIPTION "A robot may not harm humanity, or, by inaction, allow humanity to come to harm"
RUN yo hubot\
 --adapter="botframework"\
 --owner="$HUBOT_OWNER"\
 --name="$HUBOT_NAME"\
 --description="$HUBOT_DESCRIPTION"\
 --defaults

ARG BOTBUILDER="3.15.0"
ARG HUBOT_VERSION="^3.3.2"
ARG HUBOT_BOTFRAMEWORK="https://github.com/Microsoft/BotFramework-Hubot.git"
ARG HUBOT_DIAGNOSTICS="^1.0.0"
ARG HUBOT_GOOGLE_IMAGES="^0.2.7"
ARG HUBOT_GOOGLE_TRANSLATE="^0.2.1"
ARG HUBOT_HELP="^1.0.1"
ARG HUBOT_HEROKU_KEEPALIVE="^1.0.3"
ARG HUBOT_MAPS="0.0.3"
ARG HUBOT_REDIS_BRAIN="^1.0.0"
ARG HUBOT_RULES="^1.0.0"
ARG HUBOT_SCRIPTS="^2.17.2"

# https://github.com/hubotio/hubot/issues/1260
RUN cat package.json\
|jq --arg BOTBUILDER             "$BOTBUILDER"             '.dependencies.botbuilder               = $BOTBUILDER'\
|jq --arg HUBOT_VERSION          "$HUBOT_VERSION"          '.dependencies.hubot                    = $HUBOT_VERSION'\
|jq --arg HUBOT_BOTFRAMEWORK     "$HUBOT_BOTFRAMEWORK"     '.dependencies."hubot-framework"        = $HUBOT_BOTFRAMEWORK'\
|jq --arg HUBOT_DIAGNOSTICS      "$HUBOT_DIAGNOSTICS"      '.dependencies."hubot-diagnostics"      = $HUBOT_DIAGNOSTICS'\
|jq --arg HUBOT_GOOGLE_IMAGES    "$HUBOT_GOOGLE_IMAGES"    '.dependencies."hubot-google-images"    = $HUBOT_GOOGLE_IMAGES'\
|jq --arg HUBOT_GOOGLE_TRANSLATE "$HUBOT_GOOGLE_TRANSLATE" '.dependencies."hubot-google-translate" = $HUBOT_GOOGLE_TRANSLATE'\
|jq --arg HUBOT_HELP             "$HUBOT_HELP"             '.dependencies."hubot-help"             = $HUBOT_HELP'\
|jq --arg HUBOT_HEROKU_KEEPALIVE "$HUBOT_HEROKU_KEEPALIVE" '.dependencies."hubot-heroku-keepalive" = $HUBOT_HEROKU_KEEPALIVE'\
|jq --arg HUBOT_MAPS             "$HUBOT_MAPS"             '.dependencies."hubot-maps"             = $HUBOT_MAPS'\
|jq --arg HUBOT_REDIS_BRAIN      "$HUBOT_REDIS_BRAIN"      '.dependencies."hubot-redis-brain"      = $HUBOT_REDIS_BRAIN'\
|jq --arg HUBOT_RULES            "$HUBOT_RULES"            '.dependencies."hubot-rules"            = $HUBOT_RULES'\
|jq --arg HUBOT_SCRIPTS          "$HUBOT_SCRIPTS"          '.dependencies."hubot-scripts"          = $HUBOT_SCRIPTS'\
 > /tmp/package.json\
 && mv /tmp/package.json .

EXPOSE 80

ENTRYPOINT ["./entrypoint.sh"]

CMD ["--name", "$HUBOT_NAME", "--adapter", "botframework" ]
