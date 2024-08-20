# UchanE_Tow
```cs
 - 위치: vrp\modules\basic_garages.lua
```
```lua
MySQL.createCommand("vRP/get_UchanE_tow", "SELECT tow FROM UchanE_tow WHERE user_id = @user_id")

local choose = function(player, choice)
    local vname = kitems[choice]
    if vname then
        -- spawn vehicle
        local user_id = vRP.getUserId(player) -- Use player as the source
        if user_id ~= nil then
            local vehicle = vehicles[vname]
            if vehicle then
                MySQL.query("vRP/get_UchanE_tow", {user_id = user_id}, function(rows)
                    if #rows > 0 then
                    local current_tow = tonumber(rows[1].tow) 
                        if current_tow == 0 then
                            if vRP.CheckInventoryItem(user_id, 'driver', 1, "운전면허증") then
                                vRP.closeMenu(player)
                                vRPclient.spawnGarageVehicle(player, {veh_type, vname}) -- veh_type needs to be defined
                            else
                                vRPclient.notify(player, {"~r~운전면허가 없습니다. 운전면허를 발급하세요"})
                            end
                        else
                            vRPclient.notify(player, {"~r~압류중"})
                        end
                    else
                        vRPclient.notify(player, {"~r~압류 정보가 없습니다."})
                    end
                end)
            else
                vRPclient.notify(player, {"~r~차량 정보를 찾을 수 없습니다."})
            end
        else
            vRPclient.notify(player, {"~r~유효한 사용자 ID를 찾을 수 없습니다."})
        end
    else
        vRPclient.notify(player, {"~r~잘못된 차량 선택입니다."})
    end
end
```
# 문의: uchan_e(디스코드)
