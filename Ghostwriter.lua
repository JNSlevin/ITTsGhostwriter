Ghostwriter = {}
local GW = {
    name = "Ghostwriter",
    version = 0.1,
    variableVersion = 184
}
--------
--Libs--
--------
local LAM = LibAddonMenu2
local lib = LibCustomMenu
local chat = LibChatMessage("Ghostwriter", "GW") -- long and short tag to identify who is printing the message
local chat = chat:SetTagColor("04B4AE")
-------------
-- Defaults--
-------------
local defaults = {
    generalSettings = {
        offlinecheck = true,
        offlinemodecheck = true
    },
    guilds = {},
    savednotes = {},
    firstload = true,
    selectedGuild = GetGuildId(1)
}

-------------
--Variables--
-------------

local guildName = GetGuildName()
local guildIds = {}
local settingsTable = {}
local worldName = GetWorldName()
local db = {}
local id = {}
local guildTable = {}
local guildTableValues = {}
local dateTable = {
    "DD.MM.YY",
    "DD.MM.YYYY",
    "MM/DD/YY",
    "MM/DD/YYYY",
    "YY-MM-DD",
    "YYYY-MM-DD",
    "DD-MM-YY",
    "DD-MM-YYYY"
}
local dateValues = {
    "%d.%m.%y",
    "%d.%m.%Y",
    "%m/%d/%y",
    "%m/%d/%Y",
    "%y-%m-%d",
    "%Y-%m-%d",
    "%d-%m-%y",
    "%d-%m-%Y"
}
local dateTooltips = {
    "31.03.21",
    "31.03.2021",
    "03/31/21",
    "03/31/2021",
    "21-31-03",
    "2021-31-03",
    "31-03-21",
    "31-03-2021"
}
-----------------
--OnAddonLoaded--
-----------------
function Ghostwriter.OnAddOnLoaded(event, addonName)
    if addonName ~= GW.name then
        return
    end
    GW.Initialize()
end
-----------
--Methods--
-----------

function BackupNotes(guildId)
    -- local numGuilds = GetNumGuilds()

    -- local name = GetGuildName(GetGuildId(guildId))
    -- local id = GetGuildId(guildId)
    local numMembers = GetNumGuildMembers(guildId)
    -- local color = GetGuildColor(guildId)
    local link = CreateGuildLink(guildId)
    if GetNotingPermission(guildId) == false then
        chat:Print("You currently do not have Ghostwriter noting permissions for " .. link)
    else
        if not db.savednotes[worldName] then
            db.savednotes[worldName] = {}
        end
        if not db.savednotes[worldName][guildId] then
            db.savednotes[worldName][guildId] = {}
        end
        for l = 1, numMembers do
            local playerName, note, rankIndex, _, _ = GetGuildMemberInfo(guildId, l)
            -- d("3")
            if rankIndex >= 3 then
                db.savednotes[worldName][guildId][playerName] = note
            end
        end
        chat:Print("Notebackup for " .. CreateGuildLink(guildId) .. " successful!")
    end
    LibGuildRoster:Refresh()
end

local function GetGuilds()
    local numGuilds = GetNumGuilds()
    -- db.guilds = {}
    -- db.savednotes = {}

    for i = 1, numGuilds do
        local id = GetGuildId(i)
        local name = GetGuildName(id)
        local numMembers = GetNumGuildMembers(id)
        local color = GetGuildColor(i)
        local gIndex = GetGuildIndex(id)
        local link = CreateGuildLink(id)
        local guildDefaults = {
            ["messageBody"] = "Welcome to %PLAYER% to %GUILD% do we get cake?",
            ["mailBody"] = "I am very happy to welcome you to my guild %PLAYER%\n cakes are to be depositet in our guildbank <3",
            ["mailEnabled"] = false,
            ["mailSubject"] = "Welcome to %GUILD%",
            ["messageEnabled"] = true,
            ["noteEnabled"] = false,
            ["noteBody"] = "%DATE%\n%PLAYER%\nhas brought cake",
            ["autobackup"] = false,
            ["alerts"] = true,
            ["dateFormat"] = "%d.%m.%y",
            ["applicationThreshhold"] = 300,
            ["noteAlert"] = true,
            ["applicationAlert"] = true
        }

        -- d("2")
        if not db.guilds[id] then
            db.guilds[id] = {}
        end
        if not db.guilds[id].settings then
            db.guilds[id].settings = ZO_DeepTableCopy(guildDefaults)
        end

        -- d("2")
        --[[ local Vars = db.guilds[name]
        db.guilds[name] = (Vars ~= nil and Vars or {}) ]]
        if not db.savednotes[worldName] then
            db.savednotes[worldName] = {}
        end
        if not db.savednotes[worldName][id] then
            db.savednotes[worldName][id] = {}
        end

        if not db.guilds[id].name then
            db.guilds[id].name = name
        end

        db.guilds[id].id = id
        -- if GetNotingPermission(id) == true or GetMailingPermission(id) == true or GetChatMessagePermission(id) == true then

        guildTable[i] = link
        guildTableValues[i] = id

        for l = 1, numMembers do
            local playerName, note, rankIndex, _, _ = GetGuildMemberInfo(id, l)
            -- d("3")
            if rankIndex >= 3 and db.generalSettings.autobackup == true then
                db.savednotes[worldName][id][playerName] = note
            end
        end
    end
end
local function OnMemberJoin(_, guildId, playerName)
    local guildName = GetGuildName(guildId)
    local guilds = db.guilds[guildId]
    local date = os.date(db.generalSettings.dateFormat)
    local index = GetGuildMemberIndexFromDisplayName(guildId, playerName)
    local name, _, _, status, offlinetime = GetGuildMemberInfo(guildId, index)
    local gIndex = GetGuildIndex(guildId)
    -- local note = GetPermissionsFromMemberNote(guildId)

    -- if GuildPermissions(guildId) == true then
    if GetChatMessagePermission(guildId) == true then
        if db.guilds[guildId].settings.messageEnabled == true then
            local template = zo_strformat(db.guilds[guildId].settings.messageBody)
            -- local template = "test"
            if not template or template == "" then
                return
            end

            local formattedMessage = string.gsub(template, "%%PLAYER%%", playerName)
            local eformat = string.gsub(formattedMessage, "%%GUILD%%", guildName)
            local fformat = string.gsub(eformat, "%%DATE%%", date)

            if index ~= nil then
                if db.generalSettings.offlinecheck == false then
                    StartChatInput(fformat, _G["CHAT_CHANNEL_GUILD_" .. gIndex])
                end
                if db.guilds[guildId].settings.offlinecheck == true then
                    if status ~= PLAYER_STATUS_OFFLINE then
                        StartChatInput(fformat, _G["CHAT_CHANNEL_GUILD_" .. gIndex])
                    end
                end
            end
        end
    end
    if GetNotingPermission(guildId) == true then
        if db.guilds[guildId].settings.noteEnabled == true then
            if db.savednotes[worldName][guildId][playerName] == nil or db.savednotes[worldName][guildId][playerName] == "" then
                local membernote = zo_strformat(db.guilds[guildId].settings.noteBody)
                if not membernote or membernote == "" then
                    return
                end

                local fm = string.gsub(membernote, "%%PLAYER%%", playerName)
                local fm = string.gsub(fm, "%%GUILD%%", guildName)
                local fm = string.gsub(fm, "%%DATE%%", date)
                if db.generalSettings.offlinemodecheck == true then
                    if offlinetime > 1209600 then
                        fm = (fm .. "\n" .. "|cffffffOfflinemode|r")
                    end
                end
                if name == playerName then
                    SetGuildMemberNote(guildId, index, fm)
                end
            else
                if name == playerName then
                    SetGuildMemberNote(guildId, index, db.savednotes[worldName][guildId][playerName])
                end
            end
        end
    end
    if GetMailingPermission(guildId) == true then
        if db.guilds[guildId].settings.mailEnabled == true then
            local mailBody = zo_strformat(db.guilds[guildId].settings.mailBody)
            local mailSubject = zo_strformat(db.guilds[guildId].settings.mailSubject)
            if not mailBody or mailBody == "" then
                return
            end

            local mb = string.gsub(mailBody, "%%PLAYER%%", playerName)
            local mb = string.gsub(mb, "%%GUILD%%", guildName)
            local mb = string.gsub(mb, "%%DATE%%", date)
            local ms = string.gsub(mailSubject, "%%PLAYER%%", playerName)
            local ms = string.gsub(ms, "%%GUILD%%", guildName)
            local ms = string.gsub(ms, "%%DATE%%", date)

            if name == playerName then
                writeMail(playerName, mb, ms)
                --[[ RequestOpenMailbox()
                SendMail(playerName, Sfformat, fm)
                CloseMailbox() ]]
                chat:Print("Mail sent to: |cffffff" .. ZO_LinkHandler_CreateDisplayNameLink(playerName))
            --ZO_LinkHandler_CreateDisplayNameLink(displayName)
            end
        end
    end
end

local function firstLoad()
    if db.firstload == true then
        chat:Print(
            "Thank you for downloading Ghostwriter. Please visit the website https://github.com/JNSlevin/ITTs-Ghostwriter for setup help! You will need to setup first to make the addon useable"
        )
        db.firstload = false
    end
end

function NoteTest()
    writeNote(525912, 104, math.random(12, 9999))
end
SLASH_COMMANDS["/xxx"] = NoteTest
------------------
---LibCustomMenu--
------------------
local function AddPlayerContextMenuEntry(playerName, rawName)
    numGuilds = GetNumGuilds()

    local guildId = GetGuildId(i)
    local link = CreateGuildLink(guildId)

    local contextEntries = {}

    for i = 1, GetNumGuilds() do
        local guildId = GetGuildId(i)
        local link = CreateGuildLink(guildId)
        local color = GetGuildColor(i)

        local guildName = GetGuildName(guildId)

        contextEntries[i] = {
            label = link,
            callback = function()
                GuildInvite(guildId, playerName)
                chat:Print(playerName .. guildId)
            end,
            visible = DoesPlayerHaveGuildPermission(guildId, GUILD_PERMISSION_INVITE)
        }
    end
    AddCustomSubMenuItem("|c04B4AEGhostwriter|r Invite to:", contextEntries)
end
lib:RegisterPlayerContextMenu(AddPlayerContextMenuEntry, lib.CATEGORY_LATE)
local function AddGuildRosterMenuEntry(control, button, upInside)
    local data = ZO_ScrollList_GetData(control)
    local guildId = GUILD_ROSTER_MANAGER:GetGuildId()
    local guildName = GUILD_ROSTER_MANAGER:GetGuildName()
    local guildAlliance = GUILD_ROSTER_MANAGER:GetGuildAlliance()
    -- local note = GetPermissionsFromMemberNote(guildId)
    -- local displayName = ZO_KeyboardGuildRosterRowDisplayName_OnMouseEnter()
    local entries = {
        {
            label = "Backup Note",
            callback = function()
                BackupSpecificNote(guildId, data.displayName)
            end,
            visible = GetNotingPermission(guildId)
        },
        {
            label = "Retrieve Note",
            callback = function()
                RetrieveSpecificNote(guildId, data.displayName)
            end,
            visible = GetNotingPermission(guildId)
        },
        {
            label = "Initiate welcome sequence",
            callback = function()
                OnMemberJoin(_, guildId, data.displayName)
            end,
            visible = function()
                if GetNotingPermission(guildId) == true or GetMailingPermission(guildId) == true or GetChatMessagePermission(guildId) == true then
                    return true
                else
                    return false
                end
            end,
            disabled = function()
                if db.guilds[guildId].settings.noteEnabled == true or db.guilds[guildId].settings.mailEnabled == true or db.guilds[guildId].settings.chatEnabled == true then
                    return false
                else
                    return true
                end
            end
        }
    }
    AddCustomMenuItem(
        "-",
        function()
            CHAT_ROUTER:AddDebugMessage("my Func")
        end,
        ZO_ColorDef:New(1, 0.5, 0.2, 1)
    )
    if
        GetNotingPermission(guildId) == true or GetMailingPermission(guildId) == true or GetChatMessagePermission(guildId) == true --[[ or
            db.guilds[guildId].settings.noteEnabled == true or
            db.guilds[guildId].settings.mailEnabled == true or
            db.guilds[guildId].settings.chatEnabled == true ]]
     then
        AddCustomSubMenuItem("|c04B4AEGhostwriter|r", entries)
    end
end

lib:RegisterGuildRosterContextMenu(AddGuildRosterMenuEntry, lib.CATEGORY_LATE)
function BackupSpecificNote(guildId, playerName)
    local playerLink = ZO_LinkHandler_CreateDisplayNameLink(playerName)
    local memberIndex = GetGuildMemberIndexFromDisplayName(guildId, playerName)
    local name, note, rankIndex = GetGuildMemberInfo(guildId, memberIndex)
    if rankIndex <= 3 then
        -- elseif playerName ~= name or name == nil then
        chat:Print("Membernote for: |cffffff" .. playerLink .. "|r cannot be backupped")
    elseif note == db.savednotes[worldName][guildId][playerName] then
        chat:Print("Note for |cffffff" .. playerLink .. "|r in " .. CreateGuildLink(guildId) .. " is already saved!")
    elseif db.savednotes[worldName][guildId][playerName] ~= note or db.savednotes[worldName][guildId][playerName] == nil then
        db.savednotes[worldName][guildId][playerName] = note
        chat:Print("Saved note for |cffffff" .. playerLink .. "|r in " .. CreateGuildLink(guildId) .. "!")

    -- chat:Print("test")
    end
    LibGuildRoster:Refresh()
    -- chat:Print("SUCCESS! Saved note for |cffffff" .. playerLink .. " in " .. CreateGuildLink(guildId))
    -- chat:Print("SUCCESS! Saved note for |cffffff" .. playerLink .. " in " .. CreateGuildLink(guildId) .. "!")
end

function RetrieveSpecificNote(guildId, playerName)
    local playerLink = ZO_LinkHandler_CreateDisplayNameLink(playerName)
    local memberIndex = GetGuildMemberIndexFromDisplayName(guildId, playerName)
    local name, note, rankIndex = GetGuildMemberInfo(guildId, memberIndex)
    if rankIndex <= 3 then
        chat:Print("Membernote for: |cffffff" .. playerLink .. "|r in: " .. CreateGuildLink(guildId) .. "cannot be retrieved (Rank too high)")
    elseif note == db.savednotes[worldName][guildId][playerName] then
        chat:Print("Membernote in backup for: |cffffff" .. playerLink .. "|r in " .. CreateGuildLink(guildId) .. "is the same as the current note")
    else
        SetGuildMemberNote(guildId, memberIndex, db.savednotes[worldName][guildId][playerName])
    end
end
------------------
--LibGuildRoster--
------------------
function GW.RosterRow()
    -- local rosterNote = db.savednotes[worldName][id][playerName]
    -- local GetGuildMemberIndexFromDisplayName(guildId, string displa
    --[[     local guildId = {}
    local index = {}
    local me = GetPlayerGuildMemberIndex(guildId)
    local playerName, _, _, _, _ = GetGuildMemberInfo(guildId, index) ]]
    GW.myGuildColumn =
        LibGuildRoster:AddColumn(
        {
            key = "GW_Notes",
            disabled = false,
            width = 24,
            -- guildFilter = {525912},
            header = {
                title = "",
                align = TEXT_ALIGN_CENTER,
                tooltip = "Notebackups"
            },
            row = {
                align = TEXT_ALIGN_CENTER,
                data = function(guildId, data, index)
                    local _, note, rankIndex, _, _ = GetGuildMemberInfo(guildId, index)
                    local iName, iIndex = GetGuildInviteeInfo(guildId, 1)
                    local rankId = GetGuildRankId(guildId, rankIndex)
                    if rankIndex == nil then
                        --Shvegl
                        return ""
                    elseif rankIndex <= 3 and rankIndex > 0 then
                        return "|t18:18:/esoui/art/buttons/decline_down.dds|t"
                    elseif db.savednotes[worldName][guildId][data.displayName] == "" then
                        return ""
                    elseif db.savednotes[worldName][guildId][data.displayName] == note then
                        return "|t24:24:/esoui/art/guild/guildheraldry_indexicon_finalize_down.dds|t"
                    elseif rankIndex == 429496 then
                        return ""
                    else
                        return "|t24:24:/esoui/art/guild/guildheraldry_indexicon_finalize_disabled.dds|t"
                    end
                end
            }
        }
    )
end

----------------
--LAM Settings--
----------------

-- TODO: change one saves for all of them?
--! its all fucked ¯\_(ツ)_/¯
--*update not fucked anymore thank you siri :D
function Ghostwriter.CreateSettingsWindow()
    id = {}
    local text = {}
    local selectedGuildId = guildTableValues[1]
    local selectedDateFormat = dateValues[1]
    local color = GetGuildColor(1)
    local panelData = {
        type = "panel",
        name = "ITTs |c04B4AEGhostwriter",
        author = "JN Slevin",
        version = GW.version,
        registerForRefresh = true,
        registerForDefaults = false,
        website = "https://github.com/JNSlevin/ITTs-Ghostwriter"
    }

    LAM:RegisterAddonPanel("GhostwriterOptions", panelData)

    local optionsData = {
        [1] = {
            type = "header",
            name = "|c04B4AEGhostwriter|r Settings"
        },
        [2] = {
            type = "description",
            title = "Setup |c04B4AEGhostwriter|r",
            text = "Please visit the Website (linked in the " ..
                ZO_LinkHandler_CreateURLLink("https://www.esoui.com", "help") ..
                    " description above) for setup help. \n\n|cff0000The addon will not work and all guildspecific settings will be disabled without setup!",
            enableLinks = true,
            helpUrl = "https://www.esoui.com",
            width = "full" --or "half" (optional)
        },
        [3] = {
            type = "checkbox",
            name = "Check for Onlinestatus",
            default = false,
            disabled = false,
            width = "half",
            tooltip = "Will not paste the chatmessage if the invited member is offline",
            getFunc = function()
                return db.generalSettings.offlinecheck
            end,
            setFunc = function(value)
                db.generalSettings.offlinecheck = value
            end,
            d
        },
        [4] = {
            type = "checkbox",
            name = "Include Offlinemode check",
            default = false,
            disabled = false,
            width = "half",
            tooltip = "Will include the term |cffffffOfflinemode|r in the note if the member is offline for longer than 2 weeks",
            getFunc = function()
                return db.generalSettings.offlinemodecheck
            end,
            setFunc = function(value)
                db.generalSettings.offlinemodecheck = value
            end,
            d
        },
        [5] = {
            type = "submenu",
            name = "Guild Settings",
            icon = "/esoui/art/journal/gamepad/gp_questtypeicon_guild.dds",
            controls = {
                --[[                 [1] = {
                    type = "checkbox",
                    name = "Guildwide Settings",
                    default = false,
                    disabled = false,
                    tooltip = "Choose if you want to use the same setting for every guild you currently hold permissions in!",
                    getFunc = function()
                        return db.generalSettings.guildwideSettings
                    end,
                    setFunc = function(value)
                        db.generalSettings.guildwideSettings = value
                        -- DisableDropdown()
                    end,
                    width = "full" --or "full" (optional)
                }, ]]
                [1] = {
                    type = "description",
                    --title = "My Title",	--(optional)
                    title = nil, --(optional)
                    text = "Here you can edit the settings for each guild! First choose the guild in the dropdown below, then edit the templates or turn settings on / off!\n\nThe current placeholders are: \n|c04B4AE%DATE%|r\t-\twill be replaced by the current date (in the format you chose below)!\n|c04B4AE%PLAYER%|r\t-\twill be replaced by the account name of the player!\n|c04B4AE%GUILD%|r\t-\twill be replaced by the guilds name!",
                    width = "full" --or "half" (optional)
                },
                [2] = {
                    type = "dropdown",
                    name = "Choose Guild",
                    tooltip = "Choose the guild you'd like to change the settings for. (if you do not have the Ghostwriter permissions in a guild every setting will be disabled)",
                    choices = guildTable,
                    choicesValues = guildTableValues,
                    choicesTooltips = guildTableValues,
                    disabled = false,
                    getFunc = function()
                        return db.selectedGuild
                    end,
                    setFunc = function(guildId)
                        selectedGuildId = guildId
                        db.selectedGuild = guildId
                    end,
                    width = "full"
                },
                [3] = {
                    type = "dropdown",
                    name = "Choose date format",
                    tooltip = "Choose format of the date for the placeholder",
                    choices = dateTable,
                    disabled = function()
                        if
                            GetNotingPermission(db.selectedGuild) == true or GetMailingPermission(db.selectedGuild) == true or
                                GetChatMessagePermission(db.selectedGuild) == true
                         then
                            return false
                        else
                            return true
                        end
                    end,
                    choicesValues = dateValues,
                    choicesTooltips = dateTooltips,
                    getFunc = function()
                        return db.guilds[db.selectedGuild].settings.dateFormat
                    end,
                    setFunc = function(dateFormat)
                        db.guilds[db.selectedGuild].settings.dateFormat = dateFormat
                    end,
                    width = "full"
                },
                --[[                 [4] = {
                    type = "editbox",
                    name = "Application Threshhold",
                    tooltip = "Choose what your threshhold of champion points for applicants is",
                    isExtraWide = false,
                    isMultiline = false,
                    maxChars = 4,
                    width = "full",
                    textType = TEXT_TYPE_NUMERIC,
                    disabled = false,
                    getFunc = function()
                        return db.guilds[selectedGuildId].settings.applicationThreshhold
                    end,
                    setFunc = function(text)
                        db.guilds[selectedGuildId].settings.applicationThreshhold = text
                    end
                }, ]]
                [4] = {
                    type = "checkbox",
                    name = "Note alerts",
                    default = false,
                    disabled = function()
                        if DoesPlayerHaveGuildPermission(db.selectedGuild, GUILD_PERMISSION_NOTE_EDIT) == true then
                            return false
                        else
                            return true
                        end
                    end,
                    width = "full",
                    tooltip = "Will announce in the system chat if notes got changed in your guild (needs permission to edit notes)",
                    getFunc = function()
                        return db.guilds[db.selectedGuild].settings.noteAlert
                    end,
                    setFunc = function(value)
                        db.guilds[db.selectedGuild].settings.noteAlert = value
                    end
                },
                [5] = {
                    type = "checkbox",
                    name = "Application alerts",
                    default = false,
                    disabled = function()
                        if DoesPlayerHaveGuildPermission(db.selectedGuild, GUILD_PERMISSION_MANAGE_APPLICATIONS) == true then
                            return false
                        else
                            return true
                        end
                    end,
                    width = "half",
                    tooltip = "Will announce in the system chat if new applications are open in your guild (needs permission to manage applications)!",
                    getFunc = function()
                        return db.guilds[db.selectedGuild].settings.applicationAlert
                    end,
                    setFunc = function(value)
                        db.guilds[db.selectedGuild].settings.applicationAlert = value
                    end
                },
                [6] = {
                    type = "slider",
                    name = "Application Threshhold",
                    tooltip = "Set the minimum amount of CP for new applications to be shown in the system chat if a new application arrives.",
                    getFunc = function()
                        return db.guilds[db.selectedGuild].settings.applicationThreshhold
                    end,
                    setFunc = function(number)
                        db.guilds[db.selectedGuild].settings.applicationThreshhold = number
                    end,
                    width = "half",
                    disabled = function()
                        if
                            GetNotingPermission(db.selectedGuild) == true or GetMailingPermission(db.selectedGuild) == true or
                                GetChatMessagePermission(db.selectedGuild) == true
                         then
                            return false
                        else
                            return true
                        end
                    end,
                    min = 0,
                    max = 3600,
                    step = 50
                },
                [7] = {
                    type = "texture",
                    image = "/esoui/art/guild/sectiondivider_left.ddss",
                    imageWidth = 510, --max of 250 for half width, 510 for full
                    imageHeight = 5 --max of 100
                },
                [8] = {
                    type = "checkbox",
                    name = "Message Enabled",
                    default = false,
                    disabled = function()
                        if GetChatMessagePermission(db.selectedGuild) == true then
                            return false
                        else
                            return true
                        end
                    end,
                    width = "half",
                    tooltip = "Will paste the below template in you chat for new members of you guild!",
                    getFunc = function()
                        return db.guilds[db.selectedGuild].settings.messageEnabled
                    end,
                    setFunc = function(value)
                        db.guilds[db.selectedGuild].settings.messageEnabled = value
                    end,
                    d
                },
                [9] = {
                    type = "checkbox",
                    name = "Note Enabled",
                    default = false,
                    disabled = function()
                        if
                            GetNotingPermission(db.selectedGuild) == true or GetMailingPermission(db.selectedGuild) == true or
                                GetChatMessagePermission(db.selectedGuild) == true
                         then
                            return false
                        else
                            return true
                        end
                    end,
                    width = "half",
                    tooltip = "Will set a note for the new player!",
                    getFunc = function()
                        return db.guilds[db.selectedGuild].settings.noteEnabled
                    end,
                    setFunc = function(value)
                        db.guilds[db.selectedGuild].settings.noteEnabled = value
                    end
                },
                [10] = {
                    type = "editbox",
                    name = "ChatMessage",
                    tooltip = "This message will be pasted in your chat!",
                    isExtraWide = true,
                    isMultiline = true,
                    disabled = function()
                        if GetChatMessagePermission(db.selectedGuild) == true then
                            return false
                        else
                            return true
                        end
                    end,
                    width = "half",
                    getFunc = function()
                        return db.guilds[db.selectedGuild].settings.messageBody
                    end,
                    setFunc = function(text)
                        db.guilds[db.selectedGuild].settings.messageBody = text
                    end
                },
                [11] = {
                    type = "editbox",
                    name = "Note Template",
                    tooltip = "This is the note you will set once a new member joins",
                    width = "half",
                    isExtraWide = true,
                    isMultiline = true,
                    disabled = function()
                        if GetNotingPermission(db.selectedGuild) == true then
                            return false
                        else
                            return true
                        end
                    end,
                    maxChars = 256,
                    getFunc = function()
                        return db.guilds[db.selectedGuild].settings.noteBody
                    end,
                    setFunc = function(text)
                        db.guilds[db.selectedGuild].settings.noteBody = text
                    end
                },
                [12] = {
                    type = "checkbox",
                    name = "Mail Enabled",
                    default = false,
                    disabled = function()
                        if GetMailingPermission(db.selectedGuild) == true then
                            return false
                        else
                            return true
                        end
                    end,
                    width = "full",
                    tooltip = "Will send the below mail to the new member of your guild!",
                    getFunc = function()
                        return db.guilds[db.selectedGuild].settings.mailEnabled
                    end,
                    setFunc = function(value)
                        db.guilds[db.selectedGuild].settings.mailEnabled = value
                    end
                },
                [13] = {
                    type = "editbox",
                    name = "MailSubject",
                    tooltip = "This is the subject of the mail",
                    isExtraWide = true,
                    isMultiline = false,
                    maxChars = MAIL_MAX_SUBJECT_CHARACTERS,
                    disabled = function()
                        if GetMailingPermission(db.selectedGuild) == true then
                            return false
                        else
                            return true
                        end
                    end,
                    getFunc = function()
                        return db.guilds[db.selectedGuild].settings.mailSubject
                    end,
                    setFunc = function(text)
                        db.guilds[db.selectedGuild].settings.mailSubject = text
                    end
                },
                [14] = {
                    type = "editbox",
                    name = "MailBody",
                    tooltip = "This is the mail",
                    isExtraWide = true,
                    isMultiline = true,
                    maxChars = MAIL_MAX_BODY_CHARACTERS,
                    disabled = function()
                        if GetMailingPermission(db.selectedGuild) == true then
                            return false
                        else
                            return true
                        end
                    end,
                    getFunc = function()
                        return db.guilds[db.selectedGuild].settings.mailBody
                    end,
                    setFunc = function(text)
                        db.guilds[db.selectedGuild].settings.mailBody = text
                    end
                },
                [15] = {
                    type = "submenu",
                    name = "|cffffffBackup options",
                    disabled = function()
                        if GetNotingPermission(db.selectedGuild) == true then
                            return false
                        else
                            return true
                        end
                    end,
                    controls = {
                        [1] = {
                            type = "button",
                            name = "Backup notes",
                            tooltip = "Will backup all notes in the currently selected guild",
                            isDangerous = true,
                            func = function()
                                BackupNotes(db.selectedGuild)
                            end,
                            width = "half",
                            warning = "This will replace every currently saved note in " ..
                                CreateGuildLink(db.selectedGuild) .. "! If you want to retrieve a note do so before you backup! \n\nAre you sure you want to proceed?"
                        },
                        [2] = {
                            type = "checkbox",
                            name = "AutoBackup",
                            default = false,
                            disabled = false,
                            width = "full",
                            isDangerous = true,
                            tooltip = "Will automatically backup membernotes!!",
                            warning = "This will backup your notes upon loading into the game and if any note is changed in your guild! ",
                            getFunc = function()
                                return db.guilds[db.selectedGuild].autobackup
                            end,
                            setFunc = function(newValue)
                                db.guilds[db.selectedGuild].autobackup = newValue
                            end
                        }
                    }
                }
            }
        },
        [6] = {
            type = "submenu",
            name = "Changelog",
            controls = {
                [1] = {
                    type = "description",
                    title = "Changelog current Version",
                    text = "Initially released"
                }
            }
        }
    }

    LAM:RegisterOptionControls("GhostwriterOptions", optionsData)
end

----------------------
---OnPlayerActivated--
----------------------
local function OnPlayerActivated()
    GetGuilds()
    LGRSetupGuilds()
    firstLoad()
    GW.myGuildColumn:SetGuildFilter(LGRGuilds)
end

------------------------
---Initialize Function--
------------------------
-- TODO: no clue something is odd there, the debug messages wont get printed so my SVs are not there?!
function GW.Initialize()
    Ghostwriter.Vars = ZO_SavedVars:NewAccountWide("GWSettings", GW.variableVersion, nil, defaults, GetWorldName())
    db = Ghostwriter.Vars
    -- GetGuilds()

    zo_callLater(
        function()
            LoginAlert()
        end,
        500
    )

    GW.RosterRow()
    Ghostwriter.CreateSettingsWindow()

    EVENT_MANAGER:RegisterForEvent(GW.name, EVENT_GUILD_MEMBER_ADDED, OnMemberJoin)

    EVENT_MANAGER:UnregisterForEvent(GW.name, EVENT_ADD_ON_LOADED)
end
----------
--Events--
----------
EVENT_MANAGER:RegisterForEvent(GW.name, EVENT_ADD_ON_LOADED, Ghostwriter.OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(GW.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
