function SetPlayerPedExpression(expression, saveToKvp)
    local emote = EmoteData[expression]
    if emote and emote.category == Category.EXPRESSIONS then
        SetFacialIdleAnimOverride(PlayerPedId(), emote.anim, 0)
        if Config.PersistentExpression and saveToKvp then SetResourceKvp("expression", emote.anim) end
    else
        ClearFacialIdleAnimOverride(PlayerPedId())
        DeleteResourceKvp("expression")
    end
end

if Config.ExpressionsEnabled then
    RegisterCommand('mood', function(_source, args, _raw)
        local expression = FirstToUpper(string.lower(args[1]))
        local emote = EmoteData[expression]
        if emote and emote.category == Category.EXPRESSIONS then
            SetPlayerPedExpression(EmoteData[expression].anim, true)
        elseif expression == "Reset" then
            ClearFacialIdleAnimOverride(PlayerPedId())
            DeleteResourceKvp("expression")
        else
            EmoteChatMessage("'" .. expression .. "' is not a valid mood")
        end
    end, false)

    TriggerEvent('chat:addSuggestion', '/mood', Translate('mood'),
        { { name = "expression", help = Translate('moodhelp') } })
    TriggerEvent('chat:addSuggestion', '/moods', Translate('moods2'))


    local function LoadPersistentExpression()
        local expression = GetResourceKvpString("expression")
        if expression then
            Wait(2500)
            SetPlayerPedExpression(expression, false)
        end
    end

    if Config.PersistentExpression then
        AddEventHandler('playerSpawned', LoadPersistentExpression)
        RegisterNetEvent('QBCore:Client:OnPlayerLoaded', LoadPersistentExpression)
        RegisterNetEvent('esx:playerLoaded', LoadPersistentExpression)
    end

    AddEventHandler('onResourceStart', function(resource)
        if resource == GetCurrentResourceName() then
            LoadPersistentExpression()
        end
    end)
end
