# FROM debian:jessie
# Use Alpine Linux as our base image so that we minimize the overall size our final container, and minimize the surface area of packages that could be out of date.
FROM alpine:3.8@sha256:621c2f39f8133acb8e64023a94dbdf0d5ca81896102b9e57c0dc184cadaf5528

# Install pygments (for syntax highlighting) 
# RUN apt-get -qq update \
# 	&& DEBIAN_FRONTEND=noninteractive apt-get -qq install -y --no-install-recommends python-pygments git ca-certificates asciidoc libstdc++6 gcc-4.9 curl \
# 	&& rm -rf /var/lib/apt/lists/*



# Download and install hugo
ENV HUGO_VERSION 0.56.3

ENV HUGO_BINARY hugo_extended_${HUGO_VERSION}_Linux-64bit.tar.gz

ADD https://github.com/spf13/hugo/releases/download/v${HUGO_VERSION}/${HUGO_BINARY} /tmp/hugo.tar.gz
RUN tar -xf /tmp/hugo.tar.gz -C /tmp \
  && mkdir -p /usr/local/sbin \
  && mv /tmp/hugo /usr/local/sbin/hugo \
  && mkdir /usr/share/blog

# RUN curl -sL -o /tmp/hugo.tar.gz \
#     https://github.com/spf13/hugo/releases/download/v${HUGO_VERSION}/${HUGO_BINARY} && \
#     # tar -xvzf /tmp/hugo.tar.gz -C /usr/local/bin && \
#     # chmod +x /usr/local/bin/hugo && \
#     dpkg -i /tmp/hugo.tar.gz && \
#     rm /tmp/hugo.tar.gz && \
#     mkdir /usr/share/blog

RUN apk add --update git asciidoctor libc6-compat libstdc++ \
  && apk upgrade \
  && apk add --no-cache ca-certificates

WORKDIR /usr/share/blog

# Expose default hugo port
EXPOSE 1313

# Automatically build site
ONBUILD ADD site/ /usr/share/blog
ONBUILD RUN hugo -d /usr/share/nginx/html/

# By default, serve site
ENV HUGO_BASE_URL http://localhost:1313
CMD hugo server -b ${HUGO_BASE_URL} --bind=0.0.0.0
