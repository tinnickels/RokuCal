sub init()
    m.top.functionName = "performNetworkCall"
end sub

sub performNetworkCall()
    apiUrl = m.top.apiUrl
    if apiUrl = "" or apiUrl = invalid then
        m.top.error = "No API URL provided"
        return
    end if

    request = CreateObject("roUrlTransfer")
    if request = invalid then
        m.top.error = "Cannot create network request"
        return
    end if

    request.SetUrl(apiUrl)
    request.SetCertificatesFile("common:/certs/ca-bundle.crt")

    response = request.GetToString()

    if response <> invalid then
        m.top.response = response
    else
        m.top.error = "Network request failed"
    end if
end sub