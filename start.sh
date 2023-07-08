#!/bin/bash

shib-keygen -h ${DOMAIN_SP}

sed -i "s|DOMAIN_SP_ENV|${DOMAIN_SP}|g" /etc/nginx/nginx.conf

sed -i "s|DOMAIN_SP_ENV|${DOMAIN_SP}|g; \
    s|DOMAIN_IDP_ENV|${DOMAIN_IDP}|g" /etc/shibboleth/shibboleth2.xml

/etc/init.d/shibd start
/etc/init.d/supervisor start
/etc/init.d/php8.1-fpm start
/etc/init.d/nginx start

echo 'Ready to serve...'
tail -f /var/log/shibboleth/shibd.log -f /var/log/nginx/error.log