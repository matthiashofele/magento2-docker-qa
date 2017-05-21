#!/usr/bin/env bash

# Install magento

# Installing m2 should be as asy as running this line
# scripts/m2init magento:install --no-interaction
# in the current version of Magento DevBox this command
# will unfortunately fail.

# Installing magento 2 'manually'
scripts/m2init magento:download --no-interaction
scripts/m2init magento:setup --no-interaction

# Setup magento 2 for testing
cd /var/www/magento2
chmod +x bin/magento
cp /home/magento2/conf/install-config-mysql.php ./dev/tests/integration/etc/

./bin/magento dev:tests:run unit
./bin/magento dev:tests:run integration
