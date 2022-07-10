local config = {
    x = 0.085,
    y = 0.965,
    scale = 0.35,

    Keybind = 20, -- https://docs.fivem.net/docs/game-references/controls/
    customKeybind = true, --如果您启用此功能，则玩家可以通过他们的设置而不是上面的 Keybind 来绑定密钥。

    enableBlueCircle = true, --这将使蓝色圆圈向您显示您的声音可以到达的距离。
    makeHudSmallerWhileSpeaking = true, --当你说话时，这将使平视显示器变小一点。

    changeSpeakingDistance = true, -- 这将根据您选择的内容改变您的语音距离。 除非您还想关闭听力并将整个脚本仅用作 hud，否则不建议将其关闭。
    changeHearingDistance = false, -- 这将根据您的选择改变您的听力距离。 建议关闭。

    ranges = {
        {distance = 2.0, name = "🔈 2米按[N]聊天|按[Z]调范围"},
        {distance = 10.0, name = "🔉 10米按[N]聊天|按[Z]调范围"},
        {distance = 20.0, name = "🔊 20米按[N]聊天|按[Z]调范围"}
    }
}

-- 除非您知道自己在做什么，否则不要更改配置下方的任何内容
local keybindUsed = false
local isTalking = false
local CurrentChosenDistance = 2
local CurrentDistanceValue = config.ranges[CurrentChosenDistance].distance
local CurrentDistanceName = config.ranges[CurrentChosenDistance].name

function text(text, scale)
    SetTextFont(1)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextOutline()
    SetTextJustification(0)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(config.x, config.y)
end

if config.customKeybind then
    RegisterCommand("+voiceDistance", function()
        keybindUsed = true
        keybindUsed = false
    end, false)
    RegisterCommand("-voiceDistance", function()
        keybindUsed = false
    end, false)
    RegisterKeyMapping("+voiceDistance", "Change Voice Proximity", "keyboard", "z")
end

-- 检查玩家是否在说话
if config.makeHudSmallerWhileSpeaking then
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(50)
            if NetworkIsPlayerTalking(PlayerId()) then
                isTalking = true
            else
                isTalking = false
            end
        end
    end)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        --改变声音
        if IsControlJustPressed(0, config.Keybind) or keybindUsed then
            if CurrentChosenDistance == #config.ranges then
                CurrentChosenDistance = 1
            else
                CurrentChosenDistance = CurrentChosenDistance + 1
            end
            CurrentDistanceValue = config.ranges[CurrentChosenDistance].distance
            CurrentDistanceName = config.ranges[CurrentChosenDistance].name
            if config.changeSpeakingDistance then
                MumbleSetAudioInputDistance(CurrentDistanceValue)
            end
            if config.changeHearingDistance then
                MumbleSetAudioOutputDistance(CurrentDistanceValue)
            end
        end

        -- Blue circle
        if config.enableBlueCircle then
            if IsControlPressed(1, config.Keybind) or keybindUsed then
                local pedCoords = GetEntityCoords(PlayerPedId())
                DrawMarker(1, pedCoords.x, pedCoords.y, pedCoords.z - 1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, CurrentDistanceValue * 2.0, CurrentDistanceValue * 2.0, 1.0, 40, 140, 255, 150, false, false, 2, false, nil, nil, false)
            end
        end

        -- HUD
        if config.makeHudSmallerWhileSpeaking and isTalking then
            text(CurrentDistanceName, config.scale / 1.2)
        else
            text(CurrentDistanceName, config.scale)
        end
    end
end)
