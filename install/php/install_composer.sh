#!/bin/bash

# nginx php mysql

apt -y install unzip  wget

wget https://getcomposer.org/download/1.8.0/composer.phar -O  /usr/bin/composer

chmod +x /usr/bin/composer
# 更改国内镜像
/usr/bin/composer config -g repo.packagist composer https://packagist.phpcomposer.com
mkdir -p /root/.config/composer/
cat >/root/.config/composer/config.json << EOF
{
    "config": {},
    "repositories": {
        "packagist": {
            "type": "composer",
            "url": "https://packagist.phpcomposer.com"
        }
    }
}
EOF

cat >/root/.config/composer/composer.json <<EOF
{
    "name": "laravel/laravel",
    "description": "The Laravel Framework.",
    "keywords": ["framework", "laravel"],
    "license": "MIT",
    "type": "project",
    "require": {
        "php": ">=5.5.9",
        "laravel/framework": "5.6.*"
    },
    "config": {
        "preferred-install": "dist"
    },
    "repositories": {
        "packagist": {
            "type": "composer",
            "url": "https://packagist.phpcomposer.com"
        }
    }
}
EOF

rm -fr /root/$0
