FROM magento/magento2devbox-web

COPY conf/ /home/magento2/conf/
COPY bin/qa.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/*

ENTRYPOINT ["/usr/local/bin/qa.sh"]
