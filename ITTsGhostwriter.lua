ITTsGhostwriter = {}
local GW = {
    name = "ITTsGhostwriter",
    version = 0.3,
    variableVersion = 194,
    dataVersion = 4
}
--------
--Libs--
--------
local LAM = LibAddonMenu2
local lib = LibCustomMenu
local libDialog = LibDialog
local chat = LibChatMessage("ITTsGhostwriter", "GW") -- long and short tag to identify who is printing the message
local GW_COLOR = "CCA21A"
local chat = chat:SetTagColor(GW_COLOR)
local guildRosterScene = SCENE_MANAGER:GetScene("guildRoster")
local fragment = ZO_SimpleSceneFragment:New(window)

-------------
-- Defaults--
-------------
local defaults = {
    generalSettings = {
        offlinecheck = true,
        offlinemodecheck = true,
        backupButton = false
    },
    guilds = {},
    firstload = true,
    selectedGuild = GetGuildId(1)
}

local dataDefaults = {}

-------------
--Variables--
-------------

local guildName = GetGuildName()
GWad = ("\n\n\nSent via |cffffffITT's|c" .. GW_COLOR .. "Ghostwriter|r")
local guildIds = {}
local settingsTable = {}
local worldName = GetWorldName()
local st = {}
local db = {}
local id = {}
local rankTable = {}
local rankTableValue = {}
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
function ITTsGhostwriter.OnAddOnLoaded(event, addonName)
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
    if GetGWNotingPermission(guildId) == false then
        chat:Print("You currently do not have Ghostwriter noting permissions for " .. link)
    else
        if not GWData[worldName].guilds then
            GWData[worldName].guilds = {}
        end
        if not GWData[worldName].guilds.savedNotes then
            GWData[worldName].guilds.savedNotes = {}
        end
        if not GWData[worldName].guilds.savedNotes[guildId] then
            GWData[worldName].guilds.savedNotes[guildId] = {}
        end
        for l = 1, numMembers do
            local playerName, note, rankIndex, _, _ = GetGuildMemberInfo(guildId, l)
            -- d("3")

            GWData[worldName].guilds.savedNotes[guildId][playerName] = note
            -- GWSettings.savedNotes[worldName].guilds[guildId][playerName] = note
        end
        chat:Print("Notebackup for " .. CreateGuildLink(guildId) .. " successful!")
    end
    LibGuildRoster:Refresh()
end
--! Setup guilds
local function GetGuilds()
    local numGuilds = GetNumGuilds()

    for i = 1, numGuilds do
        local id = GetGuildId(i)
        local name = GetGuildName(id)
        local numMembers = GetNumGuildMembers(id)
        local color = GetGuildColor(i)
        local gIndex = GetGuildIndex(id)
        local link = CreateGuildLink(id)

        local guildDefaults = {
            ["messageBody"] = "Welcome to %PLAYER% to %GUILD% do we get cake?",
            ["mailBody"] = "I am very happy to welcome you to my guild %PLAYER%\n cakes are to be deposited in our guildbank <3",
            ["mailEnabled"] = false,
            ["mailSubject"] = "Welcome to %GUILD%",
            ["messageEnabled"] = true,
            ["noteEnabled"] = false,
            ["noteBody"] = "%DATE%\n%PLAYER%\nhas brought cake",
            ["autobackup"] = false,
            ["dateFormat"] = "%d.%m.%y",
            ["applicationThreshold"] = 300,
            ["noteAlert"] = true,
            ["applicationAlert"] = true
        }

        -- d("2")
        --*Setup settings
        if not st.guilds[id] then
            st.guilds[id] = {}
        end
        if not st.guilds[id].settings then
            st.guilds[id].settings = ZO_DeepTableCopy(guildDefaults)
        end

        --*Setup Data
        if not GWData then
            GWData = {}
        end
        if not GWData[worldName] then
            GWData[worldName] = {}
        end
        if not GWData[worldName].guilds then
            GWData[worldName].guilds = {}
        end
        if not GWData[worldName].guilds.savedNotes then
            GWData[worldName].guilds.savedNotes = {}
        end
        if not GWData[worldName].guilds.savedNotes[id] then
            GWData[worldName].guilds.savedNotes[id] = {}
        end

        if not st.guilds[id].name then
            st.guilds[id].name = name
        end

        st.guilds[id].id = id

        guildTable[i] = link
        guildTableValues[i] = id
        --* autobackup on login
        for l = 1, numMembers do
            local playerName, note, rankIndex, _, _ = GetGuildMemberInfo(id, l)
            -- d("3")
            if st.guilds[id].settings.autobackup == true then
                GWData[worldName].guilds.savedNotes[id][playerName] = note
            end
        end
    end
end
local function OnMemberJoin(_, guildId, playerName)
    local guildName = GetGuildName(guildId)
    local guilds = st.guilds[guildId]
    local date = os.date(st.guilds[guildId].settings.dateFormat)
    local index = GetGuildMemberIndexFromDisplayName(guildId, playerName)
    local name, _, _, status, offlinetime = GetGuildMemberInfo(guildId, index)
    local gIndex = GetGuildIndex(guildId)
    -- local note = GetPermissionsFromMemberNote(guildId)

    -- if GuildPermissions(guildId) == true then
    if GetGWChatPermission(guildId) == true then
        if st.guilds[guildId].settings.messageEnabled == true then
            local template = zo_strformat(st.guilds[guildId].settings.messageBody)
            -- local template = "test"
            if not template or template == "" then
                return
            end

            local formattedMessage = string.gsub(template, "%%PLAYER%%", playerName)
            local eformat = string.gsub(formattedMessage, "%%GUILD%%", guildName)
            local fformat = string.gsub(eformat, "%%DATE%%", date)

            if index ~= nil then
                if st.generalSettings.offlinecheck == false then
                    StartChatInput(fformat, _G["CHAT_CHANNEL_GUILD_" .. gIndex])
                end
                if st.generalSettings.offlinecheck == true then
                    if status ~= PLAYER_STATUS_OFFLINE then
                        StartChatInput(fformat, _G["CHAT_CHANNEL_GUILD_" .. gIndex])
                    else
                        chat:Print("|cffffff" .. ZO_LinkHandler_CreateDisplayNameLink(playerName) .. "|r is offline")
                    end
                end
            end
        end
    end
    if GetGWNotingPermission(guildId) == true then
        if st.guilds[guildId].settings.noteEnabled == true then
            if GWData[worldName].guilds.savedNotes[guildId][playerName] == nil or GWData[worldName].guilds.savedNotes[guildId][playerName] == "" then
                local membernote = zo_strformat(st.guilds[guildId].settings.noteBody)
                if not membernote or membernote == "" then
                    return
                end

                local fm = string.gsub(membernote, "%%PLAYER%%", playerName)
                local fm = string.gsub(fm, "%%GUILD%%", guildName)
                local fm = string.gsub(fm, "%%DATE%%", date)
                if st.generalSettings.offlinemodecheck == true then
                    if offlinetime > 1209600 then -- 2 weeks
                        fm = (fm .. "\n" .. "|cffffffOfflinemode|r")
                    end
                end
                if name == playerName then
                    writeNote(guildId, index, fm)
                end
            else
                if name == playerName then
                    writeNote(guildId, index, GWData[worldName].guilds.savedNotes[guildId][playerName])
                end
            end
        end
    end
    if GetGWMailingPermission(guildId) == true then
        if st.guilds[guildId].settings.mailEnabled == true then
            local mailBody = zo_strformat(st.guilds[guildId].settings.mailBody)
            local mailSubject = zo_strformat(st.guilds[guildId].settings.mailSubject)

            if not mailBody or mailBody == "" then
                return
            end

            local mbody = string.gsub(mailBody, "%%PLAYER%%", playerName)
            local mbody = string.gsub(mbody, "%%GUILD%%", guildName)
            local mbody = string.gsub(mbody, "%%DATE%%", date)
            local msubject = string.gsub(mailSubject, "%%PLAYER%%", playerName)
            local msubject = string.gsub(msubject, "%%GUILD%%", guildName)
            local msubject = string.gsub(msubject, "%%DATE%%", date)
            -- local astody = mBody .. GWad

            if name == playerName then
                writeMail(playerName, msubject, mbody)
            end
        end
    end
    --[[ function MailFailed(_, reason)
        if reason == MAIL_SEND_RESULT_FAIL_MAILBOX_FULL then
            chat:Print("Inbox of |cffffff" .. ZO_LinkHandler_CreateDisplayNameLink(playerName) .. "|r is full")
        end
        if reason == MAIL_SEND_RESULT_MAIL_DISABLED then
            chat:Print(
                "Mailing is currently disabled on your account! Please check if you can access guildstores and/or banks, as well as if people get your whispers! If none of these things work you may have been |cff0000Socialbanned|r! Open a ticket to the ZOS support to remove it."
            )
        end
        if reason == MAIL_SEND_RESULT_FAIL_IGNORED then
            chat:Print("|cffffff" .. ZO_LinkHandler_CreateDisplayNameLink(playerName) .. "|r is ignoring you and is unable to receive mails from you.")
        end
    end
    function MailSuccess()
        chat:Print("Welcome mail sent to |cffffff" .. ZO_LinkHandler_CreateDisplayNameLink(playerName))
    end
    EVENT_MANAGER:RegisterForEvent(GW.name, EVENT_MAIL_SEND_FAILED, MailFailed)
    EVENT_MANAGER:RegisterForEvent(GW.name, EVENT_MAIL_SEND_SUCCESS, MailSuccess) ]]
end

local function firstLoad()
    --
    if st.firstload == true then
        chat:Print(
            "Thank you for downloading ITTsGhostwriter. Please visit the Website for setup help! You will need to setup first to make the addon useable"
        )
        st.firstload = false
    end
end

local function HideBackupButton()
    if st.generalSettings.backupButton == true then
        GW_button:SetHidden(false)
    else
        GW_button:SetHidden(true)
    end
end

local scene = SCENE_MANAGER:GetScene("guildRoster")
scene:RegisterCallback("StateChange", sceneChange)
local function EnableBackupButton()
    ZO_PreHook(
        GUILD_ROSTER_MANAGER,
        "OnGuildIdChanged",
        function(self)
            GW_button:SetEnabled(not GWshouldHideFor[self.guildId])
        end
    )
end

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
    AddCustomSubMenuItem("ITTs |c" .. GW_COLOR .. "Ghostwriter|r Invite to:", contextEntries)
end
lib:RegisterPlayerContextMenu(AddPlayerContextMenuEntry, lib.CATEGORY_LATE)
local function AddGuildRosterMenuEntry(control, button, upInside)
    local data = ZO_ScrollList_GetData(control)
    local guildId = GUILD_ROSTER_MANAGER:GetGuildId()
    local guildName = GUILD_ROSTER_MANAGER:GetGuildName()
    local guildAlliance = GUILD_ROSTER_MANAGER:GetGuildAlliance()
    if ITTDonationbot == true then

    -- p = GUILD_ROSTER_KEYBOARD.GuildRosterRow_OnMouseUp
    end
    -- local note = GetPermissionsFromMemberNote(guildId)
    -- local displayName = ZO_KeyboardGuildRosterRowDisplayName_OnMouseEnter()
    local entries = {
        {
            label = "Backup Note",
            callback = function()
                BackupSpecificNote(guildId, data.displayName)
            end,
            visible = GetGWNotingPermission(guildId)
        },
        {
            label = "Retrieve Note",
            callback = function()
                RetrieveSpecificNote(guildId, data.displayName)
            end,
            visible = GetGWNotingPermission(guildId)
        },
        {
            label = "Initiate welcome sequence",
            callback = function()
                OnMemberJoin(_, guildId, data.displayName)
            end,
            visible = function()
                if GetGWNotingPermission(guildId) == true or GetGWMailingPermission(guildId) == true or GetGWChatPermission(guildId) == true then
                    return true
                else
                    return false
                end
            end,
            disabled = function()
                if
                    st.guilds[guildId].settings.noteEnabled == true or st.guilds[guildId].settings.mailEnabled == true or
                        st.guilds[guildId].settings.chatEnabled == true
                 then
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
            --This only exists to add a seperator
        end
    )
    if
        GetGWNotingPermission(guildId) == true or GetGWMailingPermission(guildId) == true or GetGWChatPermission(guildId) == true --[[ or
            st.guilds[guildId].settings.noteEnabled == true or
            st.guilds[guildId].settings.mailEnabled == true or
            st.guilds[guildId].settings.chatEnabled == true ]]
     then
        AddCustomSubMenuItem("ITTs |c" .. GW_COLOR .. "Ghostwriter|r", entries)
    end
end

lib:RegisterGuildRosterContextMenu(AddGuildRosterMenuEntry, lib.CATEGORY_LATE)
function BackupSpecificNote(guildId, playerName)
    local playerLink = ZO_LinkHandler_CreateDisplayNameLink(playerName)
    local memberIndex = GetGuildMemberIndexFromDisplayName(guildId, playerName)
    local name, note, rankIndex = GetGuildMemberInfo(guildId, memberIndex)
    if note == GWData[worldName].guilds.savedNotes[guildId][playerName] then
        chat:Print("Note for |cffffff" .. playerLink .. "|r in " .. CreateGuildLink(guildId) .. " is already saved!")
    elseif GWData[worldName].guilds.savedNotes[guildId][playerName] ~= note or GWData[worldName].guilds.savedNotes[guildId][playerName] == nil then
        GWData[worldName].guilds.savedNotes[guildId][playerName] = note
        chat:Print("Saved note for |cffffff" .. playerLink .. "|r in " .. CreateGuildLink(guildId) .. "!")

    -- chat:Print("test")
    end
    LibGuildRoster:Refresh()
end

function RetrieveSpecificNote(guildId, playerName)
    local playerLink = ZO_LinkHandler_CreateDisplayNameLink(playerName)
    local memberIndex = GetGuildMemberIndexFromDisplayName(guildId, playerName)
    local name, note, rankIndex = GetGuildMemberInfo(guildId, memberIndex)
    if note == GWData[worldName].guilds.savedNotes[guildId][playerName] then
        chat:Print("Member note in backup for: |cffffff" .. playerLink .. "|r in " .. CreateGuildLink(guildId) .. "is the same as the current note")
    else
        SetGuildMemberNote(guildId, memberIndex, GWData[worldName].guilds.savedNotes[guildId][playerName])
    end
end
------------------
--LibGuildRoster--
------------------
function GW.RosterRow()
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
                    if GWData[worldName].guilds.savedNotes[guildId][data.displayName] ~= "" and note == "" then
                        return "|cFF0000|t24:24:esoui/art/miscellaneous/check_icon_32.dds:inheritcolor|t|r"
                    elseif GWData[worldName].guilds.savedNotes[guildId][data.displayName] == "" then
                        return "|c585858|t24:24:esoui/art/miscellaneous/check_icon_32.dds:inheritcolor|t|r"
                    elseif GWData[worldName].guilds.savedNotes[guildId][data.displayName] == note then
                        return "|c00ff00|t24:24:esoui/art/miscellaneous/check_icon_32.dds:inheritcolor|t|r"
                    else
                        return ""
                    end
                end
                --[[ OnMouseEnter = function(guildId, data, control)
                    InitializeTooltip(GWTooltip)
                    GWTooltip:SetDimensionConstraints(380, -1, 440, -1)
                    GWTooltip:ClearAnchors()
                    GWTooltip:SetAnchor(BOTTOMRIGHT, control, TOPLEFT, 100, 0)
                    GWTooltip_GetInfo(GWTooltip, data.displayName)
                end,
                OnMouseExit = function(guildId, data, control)
                    ClearTooltip(GWTooltip)
                end ]]
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
function ITTsGhostwriter.CreateSettingsWindow()
    id = {}
    local text = {}
    local selectedGuildId = guildTableValues[1]
    local selectedDateFormat = dateValues[1]
    local color = GetGuildColor(1)
    local panelData = {
        type = "panel",
        name = "ITT's |c" .. GW_COLOR .. "Ghostwriter|r",
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
            name = "|c" .. GW_COLOR .. "Ghostwriter|r Settings"
        },
        [2] = {
            type = "description",
            title = "Setup |c" .. GW_COLOR .. "Ghostwriter|r",
            text = "Please visit the Website (linked in the description). \n\n|cff0000The addon will not work and all guilds pecific settings will be disabled without setup!",
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
                return st.generalSettings.offlinecheck
            end,
            setFunc = function(value)
                st.generalSettings.offlinecheck = value
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
                return st.generalSettings.offlinemodecheck
            end,
            setFunc = function(value)
                st.generalSettings.offlinemodecheck = value
            end,
            d
        },
        [5] = {
            type = "submenu",
            name = "Guild Settings",
            icon = "/esoui/art/journal/gamepad/gp_questtypeicon_guild.dds",
            controls = {
                [1] = {
                    type = "description",
                    --title = "My Title",	--(optional)
                    title = nil, --(optional)
                    text = "Here you can edit the settings for each guild! First choose the guild in the dropdown below, then edit the templates or turn settings on / off!\n\nThe current placeholders are: \n|c" ..
                        GW_COLOR ..
                            "%DATE%|r\t-\twill be replaced by the current date (in the format you chose below)!\n|c" ..
                                GW_COLOR ..
                                    "%PLAYER%|r\t-\twill be replaced by the account name of the player!\n|c" ..
                                        GW_COLOR .. "%GUILD%|r\t-\twill be replaced by the guilds name!",
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
                        return st.selectedGuild
                    end,
                    setFunc = function(guildId)
                        selectedGuildId = guildId
                        st.selectedGuild = guildId
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
                            GetGWNotingPermission(st.selectedGuild) == true or GetGWMailingPermission(st.selectedGuild) == true or
                                GetGWChatPermission(st.selectedGuild) == true
                         then
                            return false
                        else
                            return true
                        end
                    end,
                    choicesValues = dateValues,
                    choicesTooltips = dateTooltips,
                    getFunc = function()
                        return st.guilds[st.selectedGuild].settings.dateFormat
                    end,
                    setFunc = function(dateFormat)
                        st.guilds[st.selectedGuild].settings.dateFormat = dateFormat
                    end,
                    width = "full"
                },
                [4] = {
                    type = "checkbox",
                    name = "Note alerts",
                    default = false,
                    disabled = function()
                        if DoesPlayerHaveGuildPermission(st.selectedGuild, GUILD_PERMISSION_NOTE_EDIT) == true then
                            return false
                        else
                            return true
                        end
                    end,
                    width = "full",
                    tooltip = "Will announce in the system chat if notes got changed in your guild (needs permission to edit notes)",
                    getFunc = function()
                        return st.guilds[st.selectedGuild].settings.noteAlert
                    end,
                    setFunc = function(value)
                        st.guilds[st.selectedGuild].settings.noteAlert = value
                    end
                },
                [5] = {
                    type = "checkbox",
                    name = "Application alerts",
                    default = false,
                    disabled = function()
                        if DoesPlayerHaveGuildPermission(st.selectedGuild, GUILD_PERMISSION_MANAGE_APPLICATIONS) == true then
                            return false
                        else
                            return true
                        end
                    end,
                    width = "half",
                    tooltip = "Will announce in the system chat if new applications are open in your guild (needs permission to manage applications)!",
                    getFunc = function()
                        return st.guilds[st.selectedGuild].settings.applicationAlert
                    end,
                    setFunc = function(value)
                        st.guilds[st.selectedGuild].settings.applicationAlert = value
                    end
                },
                [6] = {
                    type = "slider",
                    name = "Application threshold",
                    tooltip = "Set the minimum amount of CP for new applications to be shown in the system chat if a new application arrives.",
                    getFunc = function()
                        return st.guilds[st.selectedGuild].settings.applicationThreshold
                    end,
                    setFunc = function(number)
                        st.guilds[st.selectedGuild].settings.applicationThreshold = number
                    end,
                    width = "half",
                    disabled = function()
                        if st.guilds[st.selectedGuild].settings.applicationAlert == true then
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
                        if GetGWChatPermission(st.selectedGuild) == true then
                            return false
                        else
                            return true
                        end
                    end,
                    width = "half",
                    tooltip = "Will paste the below template in you chat for new members of you guild!",
                    getFunc = function()
                        return st.guilds[st.selectedGuild].settings.messageEnabled
                    end,
                    setFunc = function(value)
                        st.guilds[st.selectedGuild].settings.messageEnabled = value
                    end
                },
                [9] = {
                    type = "checkbox",
                    name = "Note Enabled",
                    default = false,
                    disabled = function()
                        if
                            GetGWNotingPermission(st.selectedGuild) == true or GetGWMailingPermission(st.selectedGuild) == true or
                                GetGWChatPermission(st.selectedGuild) == true
                         then
                            return false
                        else
                            return true
                        end
                    end,
                    width = "half",
                    tooltip = "Will set a note for the new player!",
                    getFunc = function()
                        return st.guilds[st.selectedGuild].settings.noteEnabled
                    end,
                    setFunc = function(value)
                        st.guilds[st.selectedGuild].settings.noteEnabled = value
                    end
                },
                [10] = {
                    type = "editbox",
                    name = "ChatMessage",
                    tooltip = "This message will be pasted in your chat!",
                    isExtraWide = true,
                    isMultiline = true,
                    disabled = function()
                        if GetGWChatPermission(st.selectedGuild) == true then
                            return false
                        else
                            return true
                        end
                    end,
                    width = "half",
                    getFunc = function()
                        return st.guilds[st.selectedGuild].settings.messageBody
                    end,
                    setFunc = function(text)
                        st.guilds[st.selectedGuild].settings.messageBody = text
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
                        if GetGWNotingPermission(st.selectedGuild) == true then
                            return false
                        else
                            return true
                        end
                    end,
                    maxChars = 256,
                    getFunc = function()
                        return st.guilds[st.selectedGuild].settings.noteBody
                    end,
                    setFunc = function(text)
                        st.guilds[st.selectedGuild].settings.noteBody = text
                    end
                },
                [12] = {
                    type = "checkbox",
                    name = "Mail Enabled",
                    default = false,
                    disabled = function()
                        if GetGWMailingPermission(st.selectedGuild) == true then
                            return false
                        else
                            return true
                        end
                    end,
                    width = "full",
                    tooltip = "Will send the below mail to the new member of your guild!",
                    getFunc = function()
                        return st.guilds[st.selectedGuild].settings.mailEnabled
                    end,
                    setFunc = function(value)
                        st.guilds[st.selectedGuild].settings.mailEnabled = value
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
                        if GetGWMailingPermission(st.selectedGuild) == true then
                            return false
                        else
                            return true
                        end
                    end,
                    getFunc = function()
                        return st.guilds[st.selectedGuild].settings.mailSubject
                    end,
                    setFunc = function(text)
                        st.guilds[st.selectedGuild].settings.mailSubject = text
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
                        if GetGWMailingPermission(st.selectedGuild) == true then
                            return false
                        else
                            return true
                        end
                    end,
                    getFunc = function()
                        return st.guilds[st.selectedGuild].settings.mailBody
                    end,
                    setFunc = function(text)
                        st.guilds[st.selectedGuild].settings.mailBody = text
                    end
                },
                [15] = {
                    type = "submenu",
                    name = "|cffffffBackup options",
                    disabled = function()
                        if GetGWNotingPermission(st.selectedGuild) == true then
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
                                BackupNotes(st.selectedGuild)
                            end,
                            width = "half",
                            warning = "This will replace every currently saved note in " ..
                                CreateGuildLink(st.selectedGuild) ..
                                    "! If you want to retrieve a note do so before you backup! \n\nAre you sure you want to proceed?"
                        },
                        [2] = {
                            type = "checkbox",
                            name = "AutoBackup",
                            default = false,
                            disabled = false,
                            width = "full",
                            isDangerous = true,
                            tooltip = "Will automatically backup member notes!!",
                            warning = "This will backup your notes upon loading into the game and if any note is changed in your guild! ",
                            getFunc = function()
                                return st.guilds[st.selectedGuild].settings.autobackup
                            end,
                            setFunc = function(newValue)
                                st.guilds[st.selectedGuild].settings.autobackup = newValue
                            end
                        },
                        [3] = {
                            type = "checkbox",
                            name = "Enable backup button in Guildroster",
                            default = false,
                            disabled = false,
                            width = "full",
                            isDangerous = true,
                            tooltip = "Will add a button to the guildroster to backup all notes in the selected guild",
                            warning = "This will backup your notes upon loading into the game and if any note is changed in your guild! ",
                            getFunc = function()
                                return st.generalSettings.backupButton
                            end,
                            setFunc = function(newValue)
                                st.generalSettings.backupButton = newValue
                                HideBackupButton()
                                EnableBackupButton()
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
        },
        [7] = {
            type = "description",
            title = "",
            text = [[ ]]
        },
        [8] = {
            type = "description",
            title = "",
            text = [[ ]]
        },
        [9] = {
            type = "texture",
            image = "ITTsGhostwriter/itt-logo.dds",
            imageWidth = "192",
            imageHeight = "192",
            reference = "GhostWriterITTSettingsLogo"
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
function GW.Initialize()
    ITTsGhostwriter.Vars = ZO_SavedVars:NewAccountWide("GWSettings", GW.variableVersion, nil, defaults, GetWorldName())
    st = ITTsGhostwriter.Vars

    HideBackupButton()
    EnableBackupButton()
    zo_callLater(
        function()
            LoginAlert()
        end,
        1500
    )

    GW.RosterRow()
    ITTsGhostwriter.CreateSettingsWindow()

    EVENT_MANAGER:RegisterForEvent(GW.name, EVENT_GUILD_MEMBER_ADDED, OnMemberJoin)

    EVENT_MANAGER:UnregisterForEvent(GW.name, EVENT_ADD_ON_LOADED)
end
----------
--Events--
----------
EVENT_MANAGER:RegisterForEvent(GW.name, EVENT_ADD_ON_LOADED, ITTsGhostwriter.OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(GW.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
