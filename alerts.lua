local chat = LibChatMessage("Ghostwriter", "GW") -- long and short tag to identify who is printing the message
local chat = chat:SetTagColor("04B4AE")
-- Ghostwriter = {}
local GW = {
    name = "Ghostwriter",
    version = 0.1
}

worldName = GetWorldName()

function NoteAlert(_, guildId, displayName, note)
    local name = GetGuildName(guildId)
    LibGuildRoster:Refresh()

    -- if db.generalSettings.alerts == true then
    chat:Print("Membernote updated for |cffffff" .. ZO_LinkHandler_CreateDisplayNameLink(displayName) .. "|r in |cffffff" .. CreateGuildLink(guildId))
    -- end
    if Ghostwriter.Vars.guilds[guildId].settings.autobackup == true then
        Ghostwriter.Vars.savednotes[worldName][guildId][displayName] = note
        LibGuildRoster:Refresh()
    end
end
-- EVENT_GUILD_MEMBER_NOTE_CHANGED (number eventCode, number guildId, string displayName, string note)

local function ApplicationAlert(_, guildId, numApplications)
    LibGuildRoster:Refresh()
    -- local _, level, cp, _, _, _, _, playerName, _, _, message = GetGuildFinderAccountApplicationInfo(i)
    local lvl, cp, _, _, playerName, _, _, message = GetGuildFinderGuildApplicationInfoAt(guildId, i)
    -- level,  championPoints,  Alliance alliance,  classId,  accountName,  characterName,  achievementPoints,  applicationMessage
    local name = CreateGuildLink(guildId)
    local nEmpty = 0
    local threshhold = Ghostwriter.Vars.guilds[guildId].settings.applicationThreshhold
    local overThreshhold = 0
    -- chat:Print("started")
    for i = 1, numApplications do
        local lvl, cp, _, _, playerName, _, _, message = GetGuildFinderGuildApplicationInfoAt(guildId, i)
        chat:Print(message .. playerName)
        if message == "" then
            nEmpty = nEmpty + 1
        end
        if lvl == 50 and cp >= threshhold then
            overThreshhold = overThreshhold + 1
        end
        -- return nEmpty

        -- chat:Print("first thing done")
    end
    --[[  for i = 1, numApplications do
        -- chat:Print("name = " .. playerName .. " lvl = " .. lvl .. " cp = " .. cp)
        if lvl == 50 and cp >= threshhold then
            overThreshhold = overThreshhold + 1
        end
        -- chat:Print("name = " .. playerName .. " lvl = " .. lvl .. " cp = " .. cp)
    end ]]
    chat:Print(
        "You have |cffffff" ..
            numApplications ..
                "|r open Applications in " ..
                    name ..
                        ". There are currently|cffffff " .. nEmpty .. "|r empty applications and |cffffff" .. overThreshhold .. "|r over |cffffff" .. threshhold .. "|r CP!"
    )
end
--EVENT_GUILD_FINDER_GUILD_NEW_APPLICATIONS (number eventCode, number guildId, number numApplications)
-- SLASH_COMMANDS["/app"] = ApplicationAlert

local function MailAlert()
    LibGuildRoster:Refresh()
    chat:Print("Mail sent")
end

local function MailAlert2()
    LibGuildRoster:Refresh()
    chat:Print("Mail not sent")
end

-----------
--EVENTS
-----------
EVENT_MANAGER:RegisterForEvent(GW.name, EVENT_MAIL_SEND_SUCCESS, MailAlert)
EVENT_MANAGER:RegisterForEvent(GW.name, EVENT_MAIL_SEND_FAILED, MailAlert2)
EVENT_MANAGER:RegisterForEvent(GW.name, EVENT_GUILD_MEMBER_NOTE_CHANGED, NoteAlert)
EVENT_MANAGER:RegisterForEvent(GW.name, EVENT_GUILD_FINDER_GUILD_NEW_APPLICATIONS, ApplicationAlert)
