#!/bin/bash

# 1. 清理并创建项目目录
rm -rf my-wordpress-project
mkdir my-wordpress-project
cd my-wordpress-project

# 2. 创建基本目录结构
mkdir -p public/wp-content/{plugins,themes,uploads}

# 3. 创建必要的配置文件
touch .gitignore
touch composer.json
touch Procfile
touch app.json
touch public/.htaccess
touch public/wp-config.php
touch README.md

# 4. 写入composer.json
cat > composer.json << 'EOF'
{
  "name": "your-name/wordpress-heroku",
  "description": "WordPress on Heroku with Azure MySQL",
  "require": {
    "php": ">=7.4",
    "ext-gd": "*",
    "ext-mbstring": "*",
    "johnpbloch/wordpress": "^6.0",
    "composer/installers": "^2.0",
    "wpackagist-plugin/jetpack": "^12.0",
    "wpackagist-plugin/wp-mail-smtp": "^3.0"
  },
  "extra": {
    "wordpress-install-dir": "public",
    "installer-paths": {
      "public/wp-content/plugins/{$name}/": ["type:wordpress-plugin"],
      "public/wp-content/themes/{$name}/": ["type:wordpress-theme"]
    }
  },
  "repositories": [
    {
      "type": "composer",
      "url": "https://wpackagist.org"
    }
  ],
  "config": {
    "allow-plugins": {
      "johnpbloch/wordpress-core-installer": true,
      "composer/installers": true
    }
  }
}
EOF

# 5. 写入.gitignore
cat > .gitignore << 'EOF'
.DS_Store
.env
*.log
.htaccess
sitemap.xml
sitemap.xml.gz
public/wp-config.php
public/wp-content/advanced-cache.php
public/wp-content/backup-db/
public/wp-content/backups/
public/wp-content/blogs.dir/
public/wp-content/cache/
public/wp-content/upgrade/
public/wp-content/uploads/
public/wp-content/mu-plugins/
public/wp-content/wp-cache-config.php
public/wp-content/plugins/hello.php
public/wp-content/themes/twenty*/
vendor/
.idea/
*.iml
EOF

# 6. 写入wp-config.php
cat > public/wp-config.php << 'EOF'
<?php
// 数据库配置
define('DB_NAME', 'wordpress');
define('DB_USER', 'kikisql');
define('DB_PASSWORD', ''); // 需要替换为实际密码
define('DB_HOST', 'kikisql.mysql.database.azure.com:3306');
define('DB_CHARSET', 'utf8mb4');
define('DB_COLLATE', '');

// 认证密钥设置
define('AUTH_KEY',         'put your unique phrase here');
define('SECURE_AUTH_KEY',  'put your unique phrase here');
define('LOGGED_IN_KEY',    'put your unique phrase here');
define('NONCE_KEY',        'put your unique phrase here');
define('AUTH_SALT',        'put your unique phrase here');
define('SECURE_AUTH_SALT', 'put your unique phrase here');
define('LOGGED_IN_SALT',   'put your unique phrase here');
define('NONCE_SALT',       'put your unique phrase here');

$table_prefix = 'wp_';

define('WP_DEBUG', true);

if (!defined('ABSPATH')) {
    define('ABSPATH', dirname(__FILE__) . '/');
}

require_once(ABSPATH . 'wp-settings.php');
EOF

# 7. 写入.htaccess
cat > public/.htaccess << 'EOF'
# BEGIN WordPress
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteBase /
RewriteRule ^index\.php$ - [L]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.php [L]
</IfModule>
# END WordPress
EOF

# 8. 写入Procfile
echo "web: vendor/bin/heroku-php-apache2 public/" > Procfile

# 9. 初始化Git仓库
git init
git add .
git commit -m "Initial WordPress setup"

# 10. 安装依赖
composer install

# 11. 设置适当的权限
chmod -R 755 public
chmod -R 755 vendor

# 12. 创建环境变量文件
cat > .env << 'EOF'
DB_NAME=wordpress
DB_USER=kikisql
DB_PASSWORD=your_password_here
DB_HOST=kikisql.mysql.database.azure.com
DB_PORT=3306
WP_DEBUG=true
WP_HOME=http://localhost:8000
WP_SITEURL=http://localhost:8000
EOF

# 13. 创建数据库测试文件
cat > db-test.php << 'EOF'
<?php
$host = 'kikisql.mysql.database.azure.com';
$username = 'kikisql';
$password = ''; // 需要填入实际密码
$database = 'wordpress';
$port = 3306;

$conn = mysqli_init();
mysqli_options($conn, MYSQLI_OPT_SSL_VERIFY_SERVER_CERT, true);
mysqli_ssl_set($conn, NULL, NULL, NULL, NULL, NULL);

if (!mysqli_real_connect($conn, $host, $username, $password, $database, $port)) {
    die('连接失败: ' . mysqli_connect_error());
}
echo "数据库连接成功！\n";
mysqli_close($conn);
EOF