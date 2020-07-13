<?php

try {
    $mysql = new PDO(
        'mysql:host=trip_db;dbname=' . $_ENV['MYSQL_DATABASE'] . ';charset=utf8',
        $_ENV['MYSQL_USER'],
        $_ENV['MYSQL_PASSWORD'],
        Array(
            PDO::ATTR_PERSISTENT     => true
        )
    );
} catch (PDOException $error) {
    error_log($error->getMessage());
}
