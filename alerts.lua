local GW =
    ITTsGhostwriter or
    {
        name = "ITTsGhostwriter",
        version = 1.0,
        variableVersion = 194
    }
ITTsGhostwriter = GW

local chat = LibChatMessage("ITTsGhostwriter", "GW") -- long and short tag to identify who is printing the message
local chat = chat:SetTagColor(GW_COLOR)
-- ITTsGhostwriter = {}

local displayName = GetDisplayName()
local worldName = GetWorldName()

function GW.NoteAlert(_, guildId, playerName, note)
    local name = GetGuildName(guildId)
    LibGuildRoster:Refresh()
    GW.GetPermission_Note(guildId)
    GW.GetPermission_Mail(guildId)
    GW.GetPermission_Chat(guildId)
    if not GWSettings[worldName][displayName]["$AccountWide"].guilds[guildId].settings.noteAlert then
        return
    else
        if DoesPlayerHaveGuildPermission(guildId, GUILD_PERMISSION_NOTE_EDIT) == true then
            if GWSettings[worldName][displayName]["$AccountWide"].guilds[guildId].settings.noteAlert == true then
                chat:Print(
                    "Membernote updated for |cffffff" ..
                        ZO_LinkHandler_CreateDisplayNameLink(playerName) .. "|r in |cffffff" .. GW.CreateGuildLink(guildId)
                )
                -- end
                if GWSettings[worldName][displayName]["$AccountWide"].guilds[guildId].settings.autobackup == true then
                    GWData[worldName].guilds.savedNotes[guildId][playerName] = note
                    LibGuildRoster:Refresh()
                end
            end
        end
    end
end

function GW.LoginAlert()
    for g = 1, GetNumGuilds() do
        local guildId = GetGuildId(g)

        GW.ApplicationAlert(_, guildId)
    end
end
function GW.ApplicationAlert(_, guildId)
    LibGuildRoster:Refresh()
    local lvl, cp, _, _, playerName, _, _, message = GetGuildFinderGuildApplicationInfoAt(guildId, i)
    -- level,  championPoints,  Alliance alliance,  classId,  accountName,  characterName,  achievementPoints,  applicationMessage
    local name = GW.CreateGuildLink(guildId)
    local numApplications = GetGuildFinderNumGuildApplications(guildId)
    local nEmpty = 0
    local threshold = GWSettings[worldName][displayName]["$AccountWide"].guilds[guildId].settings.applicationThreshold
    local overthreshold = 0
    -- chat:Print("started")
    if DoesPlayerHaveGuildPermission(guildId, GUILD_PERMISSION_MANAGE_APPLICATIONS) == true then
        if numApplications > 0 then
            for i = 1, numApplications do
                local lvl, cp, _, _, playerName, _, _, message = GetGuildFinderGuildApplicationInfoAt(guildId, i)

                if message == "" then
                    nEmpty = nEmpty + 1
                end
                if lvl == 50 and cp >= threshold then
                    overthreshold = overthreshold + 1
                end
            end
            if GWSettings[worldName][displayName]["$AccountWide"].guilds[guildId].settings.applicationAlert == true then
                if numApplications ~= 0 then
                    if threshold < 1 then
                        chat:Print("You have |cffffff" .. numApplications .. "|r open Applications (|cffffff" .. nEmpty .. "|r empty) in " .. name)
                    else
                        chat:Print(
                            "You have |cffffff" ..
                                numApplications ..
                                    "|r open Applications (|cffffff" ..
                                        nEmpty .. "|r empty and |cffffff" .. overthreshold .. "|r over |cffffff" .. threshold .. "|r CP) in " .. name
                        )
                    end
                end
            end
        end
    end
end

-----------
--EVENTS
-----------

EVENT_MANAGER:RegisterForEvent(GW.name, EVENT_GUILD_MEMBER_NOTE_CHANGED, GW.NoteAlert)
EVENT_MANAGER:RegisterForEvent(GW.name, EVENT_GUILD_FINDER_GUILD_NEW_APPLICATIONS, GW.ApplicationAlert)
