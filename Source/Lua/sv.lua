local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP","")

MySQL.createCommand(
    'vRP/create_UchanE_tow_table',
    [[
        CREATE TABLE IF NOT EXISTS `UchanE_tow` (
        `user_id` int(11) NOT NULL,
        `name` varchar(100) DEFAULT NULL,
        `tow` decimal(20,0) NOT NULL DEFAULT 0,
        `updated` datetime DEFAULT NULL,
        PRIMARY KEY (`user_id`),
        CONSTRAINT `fk_UchanE_tow_users` FOREIGN KEY (`user_id`) REFERENCES `vrp_users` (`id`) ON UPDATE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
    ]]
)
MySQL.createCommand("vRP/check_user_UchanE_tow", "SELECT id, name FROM vrp_users WHERE id = @user_id")
MySQL.createCommand("vRP/create_UchanE_tow", "INSERT INTO UchanE_tow(user_id, name, tow, updated) VALUES(@user_id, @name, 0, NOW())")
MySQL.createCommand("vRP/get_UchanE_tow", "SELECT tow FROM UchanE_tow WHERE user_id = @user_id")
MySQL.createCommand("vRP/update_UchanE_tow", 
"INSERT INTO UchanE_tow (user_id, name, tow, updated) VALUES (@user_id, @name, @tow, NOW()) ON DUPLICATE KEY UPDATE tow = @tow, updated = NOW()"
)
MySQL.createCommand("vRP/plate_UchanE_tow", "SELECT user_id, registration FROM vrp_user_identities WHERE registration = @registration")

function SetTow(player, choice)
    local source = player
    local user_id = vRP.getUserId({source})
    local name = GetPlayerName(source)
    if vRP.hasPermission({user_id, Config.Tow_SV.Per.Tow}) then
        vRP.prompt({source, "고유번호", "", function(source, target_id)
            if not target_id or target_id == "" or not tonumber(target_id) then
                vRPclient.notify(source, {"고유번호는 숫자로 입력해주세요."})
                return
            end
            target_id = tonumber(target_id)
            MySQL.query("vRP/check_user_UchanE_tow", {user_id = target_id}, function(rows)
                if #rows > 0 then
                    MySQL.query("vRP/get_UchanE_tow", {user_id = target_id}, function(tow_rows)
                        local current_tow = tonumber(tow_rows[1] and tow_rows[1].tow or 0)
                        if current_tow == 1 then
                            vRPclient.notify(source, {"해당 고유번호는 이미 압류 상태입니다."})
                            return
                        elseif current_tow == 0 then
                            current_tow = current_tow + 1
                            MySQL.execute("vRP/update_UchanE_tow", {user_id = target_id, name = rows[1].name, tow = current_tow})
                            vRPclient.notify(source, {"해당 고유번호를 압류에 성공하였습니다."})
                            SendToDiscord_Tow(
                                0xFF0000,
                                "압류",
                                "🚧 압류 유저: **" .. name .. "#" .. user_id .. "**\n\n" ..
                                "🚧 상대 유저: **" .. rows[1].name .. "#" .. target_id .. "**\n\n"
                            )
                            TriggerClientEvent(
                                'chat:addMessage', 
                                -1, 
                                {
                                    template = '<span style="text-shadow: 1px 1px rgb(0, 0, 0, .7), 0 0 1px rgb(0, 0, 0, .7), 1px -1px 1px rgb(0, 0, 0, .7), -1px 1px 1px rgb(0, 0, 0, .7), -1px -1px 1px rgb(0, 0, 0, .7); font-weight: bold; font-size: 14px; border-radius: 3px; padding: 5px 13px; background: linear-gradient(to bottom, rgb(255, 154, 24) 0%, rgba(255, 154, 24, .0) 100%); margin: 0 10px 0 0;">압류 공지</span><span style="color: rgb(255, 154, 24)">{0} <span style="color: rgb(255, 0, 0)">"압류" </span>하였습니다.</span></div>',
                                    args = { name .. "#" .. user_id .. "님이 " .. rows[1].name .. "#" .. target_id .. "님의 차량을"}
                                }
                            )
                        end
                    end)
                else
                    vRPclient.notify(source, {"해당 고유번호의 유저가 존재하지 않습니다."})
                end
            end)
        end})
    else
        vRPclient.notify(source, {"~r~권한이 없습니다."})
    end
end

function SetTow_Return(player, choice)
    local source = player
    local user_id = vRP.getUserId({source})
    local name = GetPlayerName(source)
    if vRP.hasPermission({user_id, Config.Tow_SV.Per.Tow}) then
        vRP.prompt({source, "고유번호", "", function(source, target)
            local target = target
            local target_id = vRP.getUserId({target})
            local target_name = GetPlayerName(target)
            if not target_id or target_id == "" or not tonumber(target_id) then
                vRPclient.notify(source, {"고유번호는 숫자로 입력해주세요."})
                return
            end
            target_id = tonumber(target_id)
            MySQL.query("vRP/check_user_UchanE_tow", {user_id = target_id}, function(rows)
                if #rows > 0 then
                    MySQL.query("vRP/get_UchanE_tow", {user_id = target_id}, function(rows)
                        local current_tow = tonumber(rows[1] and rows[1].tow or 0)
                        if current_tow == 0 then
                            vRPclient.notify(source, {"해당 고유번호는 압류 상태가 아닙니다."})
                            return
                        elseif current_tow == 1 then
                            current_tow = current_tow - 1
                            MySQL.execute("vRP/update_UchanE_tow", {user_id = target_id, name = rows[1].name, tow = current_tow})
                            vRPclient.notify(source, {"해당 고유번호를 압류 해제에 성공하였습니다."})
                            SendToDiscord_Tow(
                                0x00FF00, 
                                "압류 해제",
                                "🚧 압류 해제 유저: **" .. name .. "#" .. user_id .. "**\n\n" ..
                                "🚧 상대 유저: **" .. target_name .. "#" .. target_id .. "**\n\n"
                            )
                            TriggerClientEvent(
                                'chat:addMessage', 
                                -1, 
                                {
                                    template = '<span style="text-shadow: 1px 1px rgb(0, 0, 0, .7), 0 0 1px rgb(0, 0, 0, .7), 1px -1px 1px rgb(0, 0, 0, .7), -1px 1px 1px rgb(0, 0, 0, .7), -1px -1px 1px rgb(0, 0, 0, .7); font-weight: bold; font-size: 14px; border-radius: 3px; padding: 5px 13px; background: linear-gradient(to bottom, rgb(255, 154, 24) 0%, rgba(255, 154, 24, .0) 100%); margin: 0 10px 0 0;">압류 공지</span><span style="color: rgb(255, 154, 24)">{0} <span style="color: rgb(0, 255, 0)">"압류 해제" </span>하였습니다.</span></div>',
                                    args = { name .. "#" .. user_id .. "님이 " .. target_name .. "#" .. target_id .. "님의 차량을"}
                                }
                            )
                        end
                    end)
                else
                    vRPclient.notify(source, {"해당 고유번호의 유저가 존재하지 않습니다."})
                end
            end)
        end})
    else
        vRPclient.notify(source, {"~r~권한이 없습니다."})
    end
end

function Plate_Lookup(player, choice)
    local source = player
    local user_id = vRP.getUserId({source})
    local name = GetPlayerName(source)
    if vRP.hasPermission({user_id, Config.Tow_SV.Per.Tow}) then
        vRP.prompt({source, "번호판", "", function(source, target_plate)
            if not target_plate or target_plate == "" then
                vRPclient.notify(source, {"유효한 번호판을 입력해주세요."})
                return
            end
            MySQL.query("vRP/plate_UchanE_tow", {registration = target_plate}, function(rows)
                if #rows > 0 then
                    local user = rows[1]
                    vRPclient.notify(source, {"번호판:" .. target_plate .. "\n소유자 고유번호:" .. user.user_id .. "번"})
                    TriggerClientEvent("pNotify:SendNotification", player, 
                        {
                            text = "번호판: " .. target_plate .. "<br><br>고유번호: " .. user.user_id .. "번", type = "success", queue = "global", timeout = 15000, layout = "centerleft"
                        }
                    )
                    SendToDiscord_Tow(
                        0xFF0000, 
                        "번호판 조회",
                        "🚧 번호판 조회 유저: **" .. name .. "#" .. user_id .. "**\n\n" ..
                        "🚧 상대 번호판: **" .. target_plate .. " - 상대 고유번호: " .. user.user_id .. "**\n\n"
                    )
                else
                    vRPclient.notify(source, {"해당 번호판의 정보를 찾을 수 없습니다."})
                end
            end)
        end})
    else
        vRPclient.notify(source, {"~r~권한이 없습니다."})
    end
end


function SetTow_Return_Auto(player, choice)
    local source = player
    local user_id = vRP.getUserId({source})
    local name = GetPlayerName(source)
    local Tow_Per = vRP.getUsersByPermission({Config.Tow_SV.Per.Tow})
    if vRP.hasPermission({user_id, Config.Tow_SV.Per.Citizen}) then
        local target_id = user_id
        if target_id then
            if #Tow_Per <= 0 then 
                MySQL.query("vRP/get_UchanE_tow", {user_id = target_id}, function(rows)
                    local current_tow = tonumber(rows[1] and rows[1].tow or 0)
                    if current_tow == 0 then
                        vRPclient.notify(source, {"압류 상태가 아닙니다."})
                        return
                    elseif current_tow == 1 then
                        local SetTow_Pay = Config.Tow_SV.Return_Auto.Pay
                        local Tow_id = Config.Tow_SV.Return_Auto.Tow_id
                        if vRP.tryDepositToCompany({user_id, Tow_id, SetTow_Pay}) then
                            current_tow = current_tow - 1
                            MySQL.execute("vRP/update_UchanE_tow", {user_id = user_id, name = name, tow = current_tow})
                            vRPclient.notify(source, {"압류 해제에 성공하였습니다. 비용:" .. format_num(SetTow_Pay)})
                            SendToDiscord_Tow(
                                0x00FF00, 
                                "자동 압류 해제",
                                "🚧 유저: **" .. name .. "#" .. target_id .. "**\n\n" ..
                                "🚧 지불 금액: **" .. format_num(SetTow_Pay) .. "**원"
                            )
                            TriggerClientEvent(
                                'chat:addMessage', 
                                -1, 
                                {
                                    template = '<span style="text-shadow: 1px 1px rgb(0, 0, 0, .7), 0 0 1px rgb(0, 0, 0, .7), 1px -1px 1px rgb(0, 0, 0, .7), -1px 1px 1px rgb(0, 0, 0, .7), -1px -1px 1px rgb(0, 0, 0, .7); font-weight: bold; font-size: 14px; border-radius: 3px; padding: 5px 13px; background: linear-gradient(to bottom, rgb(255, 154, 24) 0%, rgba(255, 154, 24, .0) 100%); margin: 0 10px 0 0;">압류 공지</span><span style="color: rgb(255, 154, 24)">{0} <span style="color: rgb(0, 255, 0)">"자동 압류 해제" </span>하였습니다.</span></div>',
                                    args = { name .. "#" .. user_id .. "님이 " .. format_num(SetTow_Pay) .. "원을 지급하고"}
                                }
                            )
                        else
                            vRPclient.notify(source, {"~r~압류 해제 비용이 부족합니다."})
                        end
                    end
                end)
            else
                vRPclient.notify(source, {"~r~현재 출근중인 렉카 직원이 있습니다.\n\n~y~현재 직원 인원수: "..#Tow_Per.."명"})
            end
        else
            vRPclient.notify(source, {"~r~해당 유저는 오프라인입니다."})
        end
    else
        vRPclient.notify(source, {"~r~권한이 없습니다."})
    end
end

RegisterNetEvent("UchanE_Tow_Auto:SV")
AddEventHandler("UchanE_Tow_Auto:SV", function()
    local user_id = vRP.getUserId({source})
    if vRP.hasPermission({user_id, Config.Tow_SV.Per.Citizen}) then
        SetTow_Return_Auto(player, choice)
    else
        vRPclient.notify(player,{"~r~자동 압류 해제 권한이 없습니다."})
    end
end)

function SendToDiscord_Tow(color, name, message, footer)
    local embed = {
        color = color,
        title = name,
        description = message,
        url = Config.Tow_SV.Etc.Discord.WebHook_IMG,
        footer = {
            text = footer,
            icon_url = Config.Tow_SV.Etc.Discord.WebHook_IMG 
        },
        thumbnail = {
            url = Config.Tow_SV.Etc.Discord.WebHook_IMG
        },
        fields = {
            {
                name = Config.Tow_SV.Etc.Discord.Fields_Name,
                value = Config.Tow_SV.Etc.Discord.Fields_value,
                inline = true
            },
            {
                name = "**시간**",
                value = os.date("%Y년 %m월 %d일 %H시 %M분 %S초"), 
                inline = true
            }
        }
    }
    local json_data = json.encode({embeds = {embed}})
    PerformHttpRequest(
        Config.Tow_SV.Etc.Discord.WebHook,
        function(err, text, headers)
        end,
        "POST",
        json_data,
        {["Content-Type"] = "application/json"}
    )
end

function TowMenu(player, choice)
    local user_id = vRP.getUserId({player})
    local menu = {}
    menu.name = "압류 메뉴"
    menu.css = {top = "75px", header_color = "rgba(255, 255, 255, 0)"}
    menu.onclose = function(player) vRP.openMainMenu({player}) end

    if vRP.hasPermission({user_id, Config.Tow_SV.Per.Tow}) then
        menu["[A] 압류"] = {SetTow}
        menu["[B] 압류 해제"] = {SetTow_Return}
        menu["[C] 번호판 조회"] = {Plate_Lookup}
    end

    if vRP.hasPermission({user_id, Config.Tow_SV.Per.Citizen}) then
        menu["[D] 자동 압류 해제"] = {SetTow_Return_Auto}
    end

    vRP.openMenu({player, menu})
end

vRP.registerMenuBuilder({
    "main",
    function(add, data)
        local user_id = vRP.getUserId({data.player})
        if user_id ~= nil then
            local choices = {}

                choices["압류 메뉴"] = {TowMenu}

            add(choices)
        end
    end
})

local desiredResourceName = Config.Tow_SV.Etc.ResourceName

AddEventHandler(
    'onResourceStart',
    function(resourceName)
        if (GetCurrentResourceName() ~= desiredResourceName) then
            os.exit()
            return
        end
        print("[INFO] " .. desiredResourceName .. " 리소스가 성공적으로 시작되었습니다.")
        MySQL.query('vRP/create_UchanE_tow_table', {})
    end
)