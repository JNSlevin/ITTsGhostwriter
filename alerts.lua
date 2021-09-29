local chat = LibChatMessage("ITTsGhostwriter", "GW") -- long and short tag to identify who is printing the message
local chat = chat:SetTagColor(GW_COLOR)
-- ITTsGhostwriter = {}
local GW = {
    name = "ITTsGhostwriter",
    version = 0.1
}

worldName = GetWorldName()

local function NoteAlert(_, guildId, displayName, note)
    local name = GetGuildName(guildId)
    LibGuildRoster:Refresh()
    GetGWNotingPermission(guildId)
    GetGWMailingPermission(guildId)
    GetGWChatPermission(guildId)
    if DoesPlayerHaveGuildPermission(guildId, GUILD_PERMISSION_NOTE_EDIT) == true then
        if ITTsGhostwriter.Vars.guilds[guildId].settings.noteAlert == true then
            chat:Print(
                "Membernote updated for |cffffff" .. ZO_LinkHandler_CreateDisplayNameLink(displayName) .. "|r in |cffffff" .. CreateGuildLink(guildId)
            )
            -- end
            if ITTsGhostwriter.Vars.guilds[guildId].settings.autobackup == true then
                GWData[worldName].guilds.savedNotes[guildId][displayName] = note
                LibGuildRoster:Refresh()
            end
        end
    end
end

function LoginAlert()
    for g = 1, GetNumGuilds() do
        local guildId = GetGuildId(g)

        ApplicationAlert(_, guildId)
    end
end
function ApplicationAlert(_, guildId)
    LibGuildRoster:Refresh()
    local lvl, cp, _, _, playerName, _, _, message = GetGuildFinderGuildApplicationInfoAt(guildId, i)
    -- level,  championPoints,  Alliance alliance,  classId,  accountName,  characterName,  achievementPoints,  applicationMessage
    local name = CreateGuildLink(guildId)
    local numApplications = GetGuildFinderNumGuildApplications(guildId)
    local nEmpty = 0
    local threshold = ITTsGhostwriter.Vars.guilds[guildId].settings.applicationThreshold
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
            if ITTsGhostwriter.Vars.guilds[guildId].settings.applicationAlert == true then
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

EVENT_MANAGER:RegisterForEvent(GW.name, EVENT_GUILD_MEMBER_NOTE_CHANGED, NoteAlert)
EVENT_MANAGER:RegisterForEvent(GW.name, EVENT_GUILD_FINDER_GUILD_NEW_APPLICATIONS, ApplicationAlert)
