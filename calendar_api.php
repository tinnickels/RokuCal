<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET');
header('Access-Control-Allow-Headers: Content-Type');

require_once 'vendor/autoload.php';

use Google\Client;
use Google\Service\Calendar;

function getWeekBounds() {
    $today = new DateTime();
    $startOfCurrentWeek = clone $today;
    $startOfCurrentWeek->modify('monday this week')->setTime(0, 0, 0);

    $endOfNextWeek = clone $startOfCurrentWeek;
    $endOfNextWeek->modify('+13 days')->setTime(23, 59, 59);

    return [
        'start' => $startOfCurrentWeek->format('c'),
        'end' => $endOfNextWeek->format('c')
    ];
}

function getCalendarEvents() {
    try {
        $client = new Client();
        $client->setApplicationName('RokuCal');
        $client->setAuthConfig('credentials.json');
        $client->setAccessType('offline');
        $client->setScopes([Calendar::CALENDAR_READONLY]);

        if (file_exists('token.json')) {
            $accessToken = json_decode(file_get_contents('token.json'), true);
            $client->setAccessToken($accessToken);
        }

        if ($client->isAccessTokenExpired()) {
            if ($client->getRefreshToken()) {
                $client->fetchAccessTokenWithRefreshToken($client->getRefreshToken());
            } else {
                throw new Exception('No valid access token available');
            }
        }

        $service = new Calendar($client);
        $calendarId = 'primary';

        $bounds = getWeekBounds();

        $optParams = array(
            'maxResults' => 100,
            'orderBy' => 'startTime',
            'singleEvents' => true,
            'timeMin' => $bounds['start'],
            'timeMax' => $bounds['end'],
        );

        $results = $service->events->listEvents($calendarId, $optParams);
        $events = $results->getItems();

        $formattedEvents = [];

        foreach ($events as $event) {
            $start = $event->start->dateTime;
            if (empty($start)) {
                $start = $event->start->date;
            }

            $end = $event->end->dateTime;
            if (empty($end)) {
                $end = $event->end->date;
            }

            $formattedEvents[] = [
                'title' => $event->getSummary(),
                'start' => $start,
                'end' => $end,
                'description' => $event->getDescription() ?: '',
                'location' => $event->getLocation() ?: ''
            ];
        }

        return [
            'success' => true,
            'events' => $formattedEvents,
            'week_bounds' => $bounds
        ];

    } catch (Exception $e) {
        return [
            'success' => false,
            'error' => $e->getMessage()
        ];
    }
}

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    echo json_encode(getCalendarEvents());
} else {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
}
?>