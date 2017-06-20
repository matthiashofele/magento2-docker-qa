#!/usr/bin/env bash

# Install magento

# Installing m2 should be as asy as running this line
# scripts/m2init magento:install --no-interaction
# in the current version of Magento DevBox this command
# will unfortunately fail.

# Installing magento 2 'manually'
scripts/m2init magento:download --no-interaction
scripts/m2init magento:setup \
 --magento-host=magento.local \
 --webserver-home-port='8080' \
 --no-interaction

# Setup magento 2 for testing
cd /var/www/magento2
chmod +x bin/magento
cp -R /home/magento2/conf/* ./

# Run unit and integration tests.
./bin/magento dev:tests:run unit
./bin/magento dev:tests:run integration

# Preparing functional tests
# First installing the composer dependencies of the testing framework
# See http://devdocs.magento.com/guides/v2.1/mtf/mtf_installation.html
cd /var/www/magento2/dev/tests/functional/
composer install

# Finalize magento2 installation for functional tests
php-fpm
unset FTP_PROXY
unset HTTPS_PROXY
unset HTTP_PROXY
unset ftp_proxy
unset http_proxy
unset https_proxy

chown -R magento2 /var/www/magento2/
/home/magento2/scripts/m2init magento:finalize --no-interaction

# Generate fixtures
# See: http://devdocs.magento.com/guides/v2.1/mtf/mtf_quickstart/mtf_quickstart_environment.html
cd /var/www/magento2/dev/tests/functional/utils
php generate.php

# Kick in the servers
chown -R magento2 /var/www/magento2/
service apache2 restart

# To Produce the file you can use the following statements.
# docker-compose exec db mysql -u root -proot magento2
: <<'sql'
SELECT scope, scope_id, path, value
FROM core_config_data
WHERE path IN (
 "cms/wysiwyg/enabled",
 "ms/wysiwyg/use_static_urls_in_catalog",
 "admin/security/admin_account_sharing",
 "admin/security/use_form_key",
 "admin/security/use_case_sensitive_login"
)
INTO OUTFILE '/tmp/core_config_data.csv'
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n';
sql
# docker cp magento2qa_db_1:/tmp/core_config_data.csv ./conf/

mysqlimport --fields-terminated-by=, \
 --columns=scope,scope_id,path,value \
 --local \
-h db -u root -proot \
 magento2 \
 /var/www/magento2/dev/tests/functional/core_config_data.csv

# Refreshing mageno index and cache
cd /var/www/magento2/
sudo -u magento2 bin/magento indexer:reindex
sudo -u magento2 bin/magento cache:flush

chown -R magento2 /var/www/magento2/

# Running the tests
cd /var/www/magento2/dev/tests/functional/
vendor/bin/phpunit
