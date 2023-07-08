FROM ubuntu:22.04
LABEL MAINTAINER="Pandu BA <pandu.asmoro@uii.ac.id>"

ARG DEBIAN_FRONTEND=noninteractive
ENV NGINX_VERSION=1.24.0

COPY start.sh /root/

RUN sed -i 's|archive.ubuntu.com|repo.ugm.ac.id|g' /etc/apt/sources.list \
    && apt update \
	&& apt upgrade -y \
    && apt install -y --no-install-recommends dialog apt-utils nano tzdata openssl ca-certificates wget curl gnupg gnupg2 ca-certificates lsb-release ubuntu-keyring php php-fpm \
    && echo Asia/Jakarta > /etc/timezone \
    && ln -sf /usr/share/zoneinfo/Asia/Jakarta /etc/localtime \
    && dpkg-reconfigure -f noninteractive tzdata \
	&& curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor | tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null \
	&& echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/ubuntu `lsb_release -cs` nginx" | tee /etc/apt/sources.list.d/nginx.list \
	&& apt update \
	&& apt install -y nginx=${NGINX_VERSION}-1~jammy supervisor shibboleth-sp-common shibboleth-sp-utils \
	&& wget https://hg.nginx.org/pkg-oss/raw-file/default/build_module.sh \
	&& chmod a+x build_module.sh \
	&& yes "" | ./build_module.sh -v ${NGINX_VERSION} https://github.com/openresty/headers-more-nginx-module.git \
	&& apt install /build-module-artifacts/nginx-module-headersmore_1.24.0+1.0-1~jammy_amd64.deb \
	&& yes "" | ./build_module.sh -v ${NGINX_VERSION} https://github.com/nginx-shib/nginx-http-shibboleth.git \
	&& apt install /build-module-artifacts/nginx-module-shibboleth_1.24.0+1.0-1~jammy_amd64.deb \
	&& openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/nginx-selfsigned.key -out /etc/nginx/nginx-selfsigned.crt -subj "/C=ID/O=Federasi ID/CN=federasi.id" \
	&& mkdir -p /var/www/html \
	&& chown -R www-data.www-data /var/www/html \
	&& chmod a+x /root/start.sh

COPY shibboleth2.xml /etc/shibboleth/
COPY shibboleth.conf /etc/supervisor/conf.d/
COPY shib_fastcgi_params /etc/nginx/
COPY nginx.conf /etc/nginx/
COPY index.php /var/www/html/

WORKDIR /var/www/html
EXPOSE 443
ENTRYPOINT ["sh", "/root/start.sh"]