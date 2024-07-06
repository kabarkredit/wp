#!/bin/bash

# Fungsi untuk menampilkan cara penggunaan
usage() {
    echo "Usage: $0 --domain <domain>"
    exit 1
}

# Parsing argumen untuk mendapatkan domain
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --domain) DOMAIN="$2"; shift ;;
        *) usage ;;
    esac
    shift
done

# Validasi apakah domain diisi
if [ -z "$DOMAIN" ]; then
    echo "Error: Domain is not specified."
    usage
fi

# Tentukan path untuk file wp-config.php dan .htaccess
WP_CONFIG_PATH="/var/www/$DOMAIN/htdocs/wp-config.php"
HTACCESS_PATH="/var/www/$DOMAIN/htdocs/.htaccess"

# Periksa apakah situs EasyEngine ada untuk domain tersebut
echo "Checking if EasyEngine site exists for $DOMAIN..."
if ee site info $DOMAIN > /dev/null 2>&1; then
    echo "EasyEngine site exists. Proceeding with configuration..."
else
    echo "Site $DOMAIN does not exist in EasyEngine. Exiting..."
    exit 1
fi

# Tambahkan konfigurasi Multisite ke wp-config.php
echo "Adding Multisite configuration to wp-config.php..."
if grep -q "define('WP_ALLOW_MULTISITE', true);" $WP_CONFIG_PATH; then
    echo "Multisite configuration already present in wp-config.php. Skipping..."
else
    cat <<EOL >> $WP_CONFIG_PATH
define('WP_ALLOW_MULTISITE', true);
define('MULTISITE', true);
define('SUBDOMAIN_INSTALL', true);
define('DOMAIN_CURRENT_SITE', '$DOMAIN');
define('PATH_CURRENT_SITE', '/');
define('SITE_ID_CURRENT_SITE', 1);
define('BLOG_ID_CURRENT_SITE', 1);
EOL
    echo "Multisite configuration added to wp-config.php."
fi

# Tambahkan aturan rewrite ke .htaccess
echo "Adding rewrite rules to .htaccess..."
if grep -q "RewriteEngine On" $HTACCESS_PATH; then
    echo "Rewrite rules already present in .htaccess. Skipping..."
else
    cat <<EOL > $HTACCESS_PATH
RewriteEngine On
RewriteBase /
RewriteRule ^index\.php$ - [L]

# add a trailing slash to /wp-admin
RewriteRule ^wp-admin$ wp-admin/ [R=301,L]

RewriteCond %{REQUEST_FILENAME} -f [OR]
RewriteCond %{REQUEST_FILENAME} -d
RewriteRule ^ - [L]
RewriteRule ^(wp-(content|admin|includes).*) \$1 [L]
RewriteRule ^(.*\.php)\$ \$1 [L]
RewriteRule . index.php [L]
EOL
    echo "Rewrite rules added to .htaccess."
fi

echo "Multisite configuration for $DOMAIN is complete."
