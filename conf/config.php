<?php

// Place all app configs here
date_default_timezone_set($_ENV['TIMEZONE']);

// Application name
define('APP_NAME', $_ENV['APP_NAME']);

// Content file server (Use CDN here if you have one) - used for serving images, css, js files
define('CDN_DOMAIN', $_ENV['CDN_DOMAIN']);

// EVE SDE table name
define('EVE_DUMP', $_ENV['EVE_DUMP']);

// Enable Tripwire API?
define('TRIPWIRE_API', $_ENV['TRIPWIRE_API'] == 'true');

// EVE API userAgent
define('USER_AGENT', $_ENV['USER_AGENT']);

// EVE SSO info
define('EVE_SSO_CLIENT', $_ENV['EVE_SSO_CLIENT']);
define('EVE_SSO_SECRET', $_ENV['EVE_SSO_SECRET']);
define('EVE_SSO_REDIRECT', $_ENV['EVE_SSO_REDIRECT']);
