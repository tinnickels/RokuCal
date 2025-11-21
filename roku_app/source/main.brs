sub Main()
    showChannelSGScreen()
end sub

sub showChannelSGScreen()
    print "Creating screen..."
    screen = CreateObject("roSGScreen")
    m.port = CreateObject("roMessagePort")
    screen.setMessagePort(m.port)

    print "Creating scene..."
    scene = screen.CreateScene("CalendarScene")
    if scene = invalid then
        print "ERROR: Failed to create CalendarScene"
        return
    end if

    print "Showing screen..."
    screen.show()

    while(true)
        msg = wait(0, m.port)
        msgType = type(msg)
        if msgType = "roSGScreenEvent"
            if msg.isScreenClosed() then return
        end if
    end while
end sub