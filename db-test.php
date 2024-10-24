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
