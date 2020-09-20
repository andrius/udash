# vim:set ft=dockerfile:
FROM ruby:alpine3.12

LABEL maintainer="Andrius Kairiukstis <k@andrius.mobi>"

WORKDIR /app

COPY Gemfile* ./
COPY udash.rb .

RUN apk add --no-cache \
	    docker \
&&  bundle install \
&&  gem cleanup \
&&  rm -rf /usr/lib/ruby/gems/*/cache/* \
           /var/cache/apk/* \
           /tmp/* \
           /var/tmp/*

EXPOSE 4567

CMD ["bundle", "exec", "./udash.rb"]
