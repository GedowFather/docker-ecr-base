FROM alpine:latest

#
# Nginx
#
RUN apk --update add --no-cache nginx && \
    adduser -D -g 'www' www && \
    mkdir /www /run/nginx && \
    chown -R www:www /var/lib/nginx /www

VOLUME ["/var/cache/nginx"]

EXPOSE 80

ADD nginx/nginx.conf /etc/nginx/
ADD nginx/index.html /www/

#
# Rails
#
ENV RUN_PACKAGES="ruby ruby-dev libxml2-dev libxslt-dev" \
    DEV_PACKAGES="build-base linux-headers"

WORKDIR /app

ADD rails .

RUN apk add --update --no-cache $RUN_PACKAGES && \
    apk add --update --virtual build-dependencies --no-cache $DEV_PACKAGES && \
    gem install bundler --no-document && \
    bundle config build.nokogiri --use-system-libraries && \
    bundle install -j4 --path vendor/bundle/ --without development test && \
    apk del build-dependencies

