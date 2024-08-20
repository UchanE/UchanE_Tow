Config = Config or {}

Config.Tow_CL = {
    {
        ['joinCoords'] = vector3(234.03706359863,-840.91571044922,30.09666633606),
        Text1 = "압류 자동해제",
        Text2 = "돈을 지불하고 압류를 해제하세요.",
        Text3 = '~w~[~g~E~w~] 키를 눌러 상호작용',
        Trigger = "UchanE_Tow_Auto:SV" -- 트리거
    },
}

Config.Tow_SV = {

    Per = {
        Tow = "", -- 렉카 권한
        Citizen = "", -- 유저 권한
    },

    Return_Auto = {
        Tow_id = 1,  -- 렉카 공계 ID
        Pay = 100000000 -- 자동 압류 해제 금액 (렉카 공계에 들어감)
    },

    Etc = {

        Discord = {
            WebHook = "",
            WebHook_IMG = "",
            Fields_Name = "**UchanE SV**",
            Fields_value = "Version 1.0",
        },

        ResourceName = "UchanE_Tow"
    }

}