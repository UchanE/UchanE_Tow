vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP", "")

Citizen.CreateThread(function()
    Citizen.Wait(100)
    while true do
        local ped = PlayerPedId()
        local pp = GetEntityCoords(ped)
        local closestDist = 1000
        local closestPoint = nil
        
        for i, point in ipairs(Config.Tow_CL) do
            local dist = #(pp - point['joinCoords'])
            if dist < closestDist then
                closestDist = dist
                closestPoint = point
            end
        end
        
        if closestDist < 20 then
            if not inCircle then
                DrawTxt(closestPoint['joinCoords'].x, closestPoint['joinCoords'].y, closestPoint['joinCoords'].z + 0.6, closestPoint.Text1, 255, 154, 24, 125, 10)
                DrawTxt(closestPoint['joinCoords'].x, closestPoint['joinCoords'].y, closestPoint['joinCoords'].z + 0.4, closestPoint.Text2, 255, 154, 24, 125, 10)
            end
            DrawMarker(1, closestPoint['joinCoords'].x, closestPoint['joinCoords'].y, closestPoint['joinCoords'].z - 1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 3.0, 3.0, 0.3, 255, 154, 24, 125, 0, 0, 0)
            if closestDist < (1.5) then
                inCircle = true
                DrawMarker(1, closestPoint['joinCoords'].x, closestPoint['joinCoords'].y, closestPoint['joinCoords'].z - 0.5, 0.0, 0.0, 0.0, 0.0, 180.0, 0, 3.0, 3.0, 0.3, 255, 154, 24, 125, 1, 0, 0)
                DrawTxt(pp.x, pp.y, pp.z + 1.0, closestPoint.Text3, 255, 255, 255, 125, 1.5)
                if IsControlJustReleased(1, 51) then
                    TriggerServerEvent(closestPoint.Trigger)
                end
            else
                if inCircle then
                    inCircle = false
                end
            end
        else
            Citizen.Wait(1000)
        end
        Citizen.Wait(0)
    end
end)

function DrawTxt(x, y, z, text)
    RegisterFontFile('SCDream5') 
    local fontid = RegisterFontId('SCDream5') 
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)
    local scale = (1/dist)*2
    local fov = (1/GetGameplayCamFov())*100
    local scale = scale*fov

    if onScreen then
        SetTextScale(0.0*scale, 0.9*scale)
        SetTextFont(fontId)
        SetTextProportional(1)
        SetTextColour(255, 154, 24, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x,_y)
    end
end