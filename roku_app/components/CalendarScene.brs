sub init()
    print "CalendarScene init() called"
    m.top.backgroundcolor = "0x000000"

    ' Get UI elements
    m.statusLabel = m.top.findNode("statusLabel")
    m.agendaContainer = m.top.findNode("agendaContainer")

    ' Get day group nodes (only 5 days now)
    m.dayGroups = []
    for i = 0 to 4
        dayGroup = m.top.findNode("day" + i.ToStr())
        if dayGroup <> invalid then
            m.dayGroups.Push(dayGroup)
            print "Found dayGroup " + i.ToStr()
        else
            print "ERROR: Could not find day" + i.ToStr()
        end if
    end for

    ' Test status label
    if m.statusLabel <> invalid then
        m.statusLabel.text = "RokuCal Agenda - Loading..."
        print "Status label initialized"
    else
        print "ERROR: Status label not found"
    end if

    ' Load calendar data
    testNetworkAndLoad()
end sub

sub testNetworkAndLoad()
    loadCalendarData()
end sub

sub updateStatus(message as String)
    if m.statusLabel <> invalid then
        m.statusLabel.text = message
    end if
    print "Status: " + message
end sub

sub loadCalendarData()
    updateStatus("Connecting to calendar API...")

    ' Create network task
    m.networkTask = CreateObject("roSGNode", "NetworkTask")
    if m.networkTask = invalid then
        updateStatus("Network unavailable - using sample data")
        loadSampleData()
        return
    end if

    ' Set up observers
    m.networkTask.observeField("response", "onNetworkResponse")
    m.networkTask.observeField("error", "onNetworkError")

    ' Set API URL and start task
    m.networkTask.apiUrl = "https://YOUR_SERVER_IP/calendar_api.php"
    m.networkTask.control = "RUN"

    updateStatus("Request sent - waiting for response...")
end sub

sub onNetworkResponse()
    response = m.networkTask.response
    updateStatus("Got " + Len(response).ToStr() + " chars - processing...")
    processApiResponse(response)
end sub

sub onNetworkError()
    updateStatus("API unavailable - using sample data")
    loadSampleData()
end sub

sub processApiResponse(response)
    try
        jsonData = ParseJson(response)
        if jsonData <> invalid and jsonData.success = true then
            updateStatus("Found " + jsonData.events.Count().ToStr() + " events")
            displayAgendaEvents(jsonData.events)
        else
            updateStatus("No events found - using sample data")
            loadSampleData()
        end if
    catch e
        updateStatus("Error processing response - using sample data")
        loadSampleData()
    end try
end sub

function dateToISO(dt as Object) as String
    isoStr = dt.GetYear().ToStr() + "-"
    if dt.GetMonth() < 10 then isoStr = isoStr + "0"
    isoStr = isoStr + dt.GetMonth().ToStr() + "-"
    if dt.GetDayOfMonth() < 10 then isoStr = isoStr + "0"
    isoStr = isoStr + dt.GetDayOfMonth().ToStr()
    return isoStr
end function

sub loadSampleData()
    ' Create sample events for the next 5 days starting today
    now = CreateObject("roDateTime")
    now.ToLocalTime()

    sampleEvents = []

    ' Today - 5 events
    todayStr = dateToISO(now)
    sampleEvents.Push({title: "Morning Meeting", start: todayStr + "T09:00:00Z"})
    sampleEvents.Push({title: "Dentist Appointment", start: todayStr + "T10:30:00Z"})
    sampleEvents.Push({title: "Lunch with Team", start: todayStr + "T12:00:00Z"})
    sampleEvents.Push({title: "Project Review", start: todayStr + "T14:00:00Z"})
    sampleEvents.Push({title: "Evening Yoga", start: todayStr + "T18:30:00Z"})

    ' Tomorrow
    tomorrow = CreateObject("roDateTime")
    tomorrow.FromSeconds(now.AsSeconds() + 86400)
    tomorrowStr = dateToISO(tomorrow)
    sampleEvents.Push({title: "Doctor Appointment", start: tomorrowStr + "T14:30:00Z"})

    ' Day 2
    day2 = CreateObject("roDateTime")
    day2.FromSeconds(now.AsSeconds() + (2 * 86400))
    day2Str = dateToISO(day2)
    sampleEvents.Push({title: "Grocery Shopping", start: day2Str + "T10:00:00Z"})
    sampleEvents.Push({title: "Gym Session", start: day2Str + "T18:00:00Z"})

    ' Day 3
    day3 = CreateObject("roDateTime")
    day3.FromSeconds(now.AsSeconds() + (3 * 86400))
    day3Str = dateToISO(day3)
    sampleEvents.Push({title: "Conference Call", start: day3Str + "T15:00:00Z"})

    ' Day 4
    day4 = CreateObject("roDateTime")
    day4.FromSeconds(now.AsSeconds() + (4 * 86400))
    day4Str = dateToISO(day4)
    sampleEvents.Push({title: "Family Dinner", start: day4Str + "T18:00:00Z"})

    updateStatus("Showing sample events (API unavailable)")
    displayAgendaEvents(sampleEvents)
end sub

sub displayAgendaEvents(events)
    now = CreateObject("roDateTime")
    now.ToLocalTime()

    ' Display 5 days starting from today
    for dayOffset = 0 to 4
        currentDay = CreateObject("roDateTime")
        currentDay.FromSeconds(now.AsSeconds() + (dayOffset * 86400))

        if dayOffset < m.dayGroups.Count() and m.dayGroups[dayOffset] <> invalid then
            displayDayAgenda(m.dayGroups[dayOffset], currentDay, events)
        end if
    end for

    updateStatus("Agenda loaded - " + events.Count().ToStr() + " events")
end sub

sub displayDayAgenda(dayGroup, dayDate, events)
    ' Clear existing content (keep only the background rectangle)
    while dayGroup.getChildCount() > 1
        dayGroup.removeChildIndex(dayGroup.getChildCount() - 1)
    end while

    ' Get month names for display
    monthNames = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN",
                  "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]

    ' Day info section (left side)
    dayNames = ["SUNDAY", "MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY"]
    dayOfWeek = dayDate.GetDayOfWeek()
    dayName = dayNames[dayOfWeek]
    monthName = monthNames[dayDate.GetMonth() - 1]

    ' Day name (larger) - adjusted for smaller height
    dayNameLabel = CreateObject("roSGNode", "Label")
    dayNameLabel.width = 200
    dayNameLabel.height = 60
    dayNameLabel.translation = [10, 5]
    dayNameLabel.text = dayName
    dayNameLabel.horizAlign = "center"
    dayNameLabel.vertAlign = "center"
    dayNameLabel.font = "font:MediumBoldSystemFont"
    dayNameLabel.color = "0xFFFF00"
    dayGroup.appendChild(dayNameLabel)

    ' Date (month and day number)
    dateLabel = CreateObject("roSGNode", "Label")
    dateLabel.width = 200
    dateLabel.height = 60
    dateLabel.translation = [10, 70]
    dateLabel.text = monthName + " " + dayDate.GetDayOfMonth().ToStr()
    dateLabel.horizAlign = "center"
    dateLabel.vertAlign = "center"
    dateLabel.font = "font:MediumBoldSystemFont"
    dateLabel.color = "0xFFFFFF"
    dayGroup.appendChild(dateLabel)

    ' Separator line
    separator = CreateObject("roSGNode", "Rectangle")
    separator.width = 4
    separator.height = 140
    separator.translation = [220, 0]
    separator.color = "0xFFFFFF"
    dayGroup.appendChild(separator)


    ' Filter events for this day - convert to ISO format YYYY-MM-DD
    dayStr = dateToISO(dayDate)
    dayEvents = []

    for each event in events
        if event.start <> invalid then
            eventDate = Left(event.start, 10)
            if eventDate = dayStr then
                dayEvents.Push(event)
            end if
        end if
    end for

    ' Display events - up to 3 per row, then wrap to second row
    eventX = 240
    eventY = 10
    eventsPerRow = 3
    eventWidth = 310
    eventHeight = 50
    rowHeight = 60

    if dayEvents.Count() = 0 then
        ' Show "No events" message
        noEventsLabel = CreateObject("roSGNode", "Label")
        noEventsLabel.width = 300
        noEventsLabel.height = 140
        noEventsLabel.translation = [eventX, 0]
        noEventsLabel.text = "No events scheduled"
        noEventsLabel.horizAlign = "left"
        noEventsLabel.vertAlign = "center"
        noEventsLabel.font = "font:MediumBoldSystemFont"
        noEventsLabel.color = "0x888888"
        dayGroup.appendChild(noEventsLabel)
    else
        for i = 0 to dayEvents.Count() - 1
            event = dayEvents[i]

            ' Calculate position - wrap to second row after 3 events
            currentRow = Int(i / eventsPerRow)
            currentCol = i MOD eventsPerRow
            posX = eventX + (currentCol * (eventWidth + 10))
            posY = eventY + (currentRow * rowHeight)

            ' Extract start time from ISO format (e.g., "2024-11-19T09:00:00Z" -> "9:00")
            timeStr = ""
            if Len(event.start) >= 16 then
                hourMinute = Mid(event.start, 12, 5)  ' Extract "09:00"
                hour = Val(Left(hourMinute, 2))
                minute = Mid(hourMinute, 4, 2)
                if hour = 0 then
                    timeStr = "12:" + minute + "a"
                else if hour < 12 then
                    timeStr = hour.ToStr() + ":" + minute + "a"
                else if hour = 12 then
                    timeStr = "12:" + minute + "p"
                else
                    timeStr = (hour - 12).ToStr() + ":" + minute + "p"
                end if
            end if

            ' Event background - yellow only
            eventRect = CreateObject("roSGNode", "Rectangle")
            eventRect.width = eventWidth
            eventRect.height = eventHeight
            eventRect.translation = [posX, posY]
            eventRect.color = "0xFFFF00"  ' Yellow
            dayGroup.appendChild(eventRect)

            ' Event text - time + title
            eventLabel = CreateObject("roSGNode", "Label")
            eventLabel.width = eventWidth - 10
            eventLabel.height = eventHeight
            eventLabel.translation = [posX + 5, posY]
            eventLabel.text = timeStr + " " + event.title
            eventLabel.font = "font:SmallBoldSystemFont"
            eventLabel.color = "0x000000"  ' Black text on yellow
            eventLabel.vertAlign = "center"
            eventLabel.horizAlign = "left"
            dayGroup.appendChild(eventLabel)
        end for
    end if
end sub