#!/usr/bin/env bash

# Original m2 entrypoint
#bash /usr/local/bin/entrypoint.sh

#set timeout 10

# Install magento

scripts/m2init magento:install --no-interaction

cd /var/www/magento2
cp /home/magento2/conf/install-config-mysql.php /var/www/magento2/dev/tests/integration/etc/
chmod +x /var/www/magento2/bin/magento
./bin/magento dev:tests:run unit
