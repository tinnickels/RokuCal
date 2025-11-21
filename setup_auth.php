<?php
require_once 'vendor/autoload.php';

use Google\Client;
use Google\Service\Calendar;

$client = new Client();
$client->setApplicationName('RokuCal');
$client->setScopes(Calendar::CALENDAR_READONLY);
$client->setAuthConfig('credentials.json');
$client->setAccessType('offline');
$client->setPrompt('select_account consent');
$client->setRedirectUri('http://localhost:8080');

$authUrl = $client->createAuthUrl();
printf("Open the following link in your browser:\n%s\n", $authUrl);
printf("After authorizing, you'll be redirected to localhost:8080\n");
printf("Copy the 'code' parameter from the URL and paste it here.\n");
print 'Enter verification code: ';
$authCode = trim(fgets(STDIN));

$accessToken = $client->fetchAccessTokenWithAuthCode($authCode);
$client->setAccessToken($accessToken);

if (array_key_exists('error', $accessToken)) {
    throw new Exception(join(', ', $accessToken));
}

if (!file_exists(dirname(__FILE__).'/token.json')) {
    file_put_contents(dirname(__FILE__).'/token.json', json_encode($client->getAccessToken()));
    print("Credentials saved to token.json\n");
}
?>