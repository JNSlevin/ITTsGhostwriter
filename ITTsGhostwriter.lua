local GW =
    ITTsGhostwriter or
    {
        name = "ITTsGhostwriter",
        version = 1.0,
        variableVersion = 194
    }
ITTsGhostwriter = GW
GW.COLOR = "CCA21A"
--------
--Libs--
--------
local LAM = LibAddonMenu2
local libCM = LibCustomMenu
local chat = LibChatMessage("ITTsGhostwriter", "GW") -- long and short tag to identify who is printing the message
-- local chat = chat:SetTagColor(GW.COLOR)

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
local GWadvertisement = ("\n\n\nSent via |cffffffITT's|c" .. GW.COLOR .. "Ghostwriter|r")

local worldName = GetWorldName()
local st = {}
local db = {}
local id = {}

local guildTable = {}
local guildTableValues = {}
GW.ChatReady = false
local dateTable = {
    "DD.MM.YY",
    "DD.MM.YYYY",
    "MM/DD/YY",
    "MM/DD/YYYY",
    "YY-MM-DD",
    "YYYY-MM-DD",
    "DD-MM-YY",
    "DD-MM-YYYY",
    "DD/MM/YY",
    "DD/MM/YYYY"
}
local dateValues = {
    "%d.%m.%y",
    "%d.%m.%Y",
    "%m/%d/%y",
    "%m/%d/%Y",
    "%y-%m-%d",
    "%Y-%m-%d",
    "%d-%m-%y",
    "%d-%m-%Y",
    "%d/%m/%y",
    "%d/%m/%Y"
}
local dateTooltips = {
    "31.03.21",
    "31.03.2021",
    "03/31/21",
    "03/31/2021",
    "21-31-03",
    "2021-31-03",
    "31-03-21",
    "31-03-2021",
    "31/03/21",
    "31/03/2021"
}
-----------------
--OnAddonLoaded--
-----------------
function GW.OnAddOnLoaded(event, addonName)
    if addonName ~= GW.name then
        return
    end
    GW.Initialize()
end
-----------
--Methods--
-----------

function GW.BackupNotes(guildId)
    -- local numGuilds = GetNumGuilds()

    -- local name = GetGuildName(GetGuildId(guildId))
    -- local id = GetGuildId(guildId)
    local numMembers = GetNumGuildMembers(guildId)
    -- local color = GW.GetGuildColor(guildId)
    local link = GW.CreateGuildLink(guildId)
    if GW.GetPermission_Note(guildId) == false then
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
        chat:Print("Notebackup for " .. link .. " successful!")
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
        local color = GW.GetGuildColor(i)
        local gIndex = GW.GetGuildIndex(id)
        local link = GW.CreateGuildLink(id)

        local guildDefaults = {
            ["messageBody"] = "Welcome %PLAYER% to %GUILD% do we get cake?",
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
    -- local guilds = st.guilds[guildId]
    local date = os.date(st.guilds[guildId].settings.dateFormat)
    local index = GetGuildMemberIndexFromDisplayName(guildId, playerName)
    local name, _, _, status, offlinetime = GetGuildMemberInfo(guildId, index)
    local gIndex = GW.GetGuildIndex(guildId)
    -- local note = GetPermissionsFromMemberNote(guildId)

    -- if GuildPermissions(guildId) == true then
    if GW.GetPermission_Chat(guildId) == true then
        if st.guilds[guildId].settings.messageEnabled == true then
            local template = zo_strformat(st.guilds[guildId].settings.messageBody)
            -- local template = "test"
            if not template or template == "" then
                return
            end

            local formattedMessage = string.gsub(template, "%%PLAYER%%", playerName)
            local eformat = string.gsub(formattedMessage, "%%GUILD%%", guildName)
            local fformat = string.gsub(eformat, "%%DATE%%", date)

            if IsChatSystemAvailableForCurrentPlatform() == true and GW.ChatReady == true then
                if index ~= nil then
                    if st.generalSettings.offlinecheck == false then
                        if CanWriteGuildChannel(_G["CHAT_CHANNEL_GUILD_" .. gIndex]) == true then
                            StartChatInput(fformat, _G["CHAT_CHANNEL_GUILD_" .. gIndex])
                        end
                    end

                    if st.generalSettings.offlinecheck == true then
                        if status ~= PLAYER_STATUS_OFFLINE then
                            if CanWriteGuildChannel(_G["CHAT_CHANNEL_GUILD_" .. gIndex]) == true then
                                StartChatInput(fformat, _G["CHAT_CHANNEL_GUILD_" .. gIndex])
                            end
                        else
                            chat:Print("|cffffff" .. ZO_LinkHandler_CreateDisplayNameLink(playerName) .. "|r is offline")
                        end
                    end
                end
            end
        end
    end
    if GW.GetPermission_Note(guildId) == true then
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
                    GW.writeNote(guildId, index, fm)
                end
            else
                if name == playerName then
                    GW.writeNote(guildId, index, GWData[worldName].guilds.savedNotes[guildId][playerName])
                end
            end
        end
    end
    if GW.GetPermission_Mail(guildId) == true then
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
                GW.writeMail(playerName, msubject, mbody)
            end
        end
    end
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
            GW_button:SetEnabled(not GW.shouldHideFor[self.guildId])
        end
    )
end

------------------
---LibCustomMenu--
------------------
local function BackupSpecificNote(guildId, playerName)
    local playerLink = ZO_LinkHandler_CreateDisplayNameLink(playerName)
    local memberIndex = GetGuildMemberIndexFromDisplayName(guildId, playerName)
    local name, note, rankIndex = GetGuildMemberInfo(guildId, memberIndex)
    if note == GWData[worldName].guilds.savedNotes[guildId][playerName] then
        chat:Print("Note for |cffffff" .. playerLink .. "|r in " .. GW.CreateGuildLink(guildId) .. " is already saved!")
    elseif GWData[worldName].guilds.savedNotes[guildId][playerName] ~= note or GWData[worldName].guilds.savedNotes[guildId][playerName] == nil then
        GWData[worldName].guilds.savedNotes[guildId][playerName] = note
        chat:Print("Saved note for |cffffff" .. playerLink .. "|r in " .. GW.CreateGuildLink(guildId) .. "!")
    end
    LibGuildRoster:Refresh()
end

local function RetrieveSpecificNote(guildId, playerName)
    local playerLink = ZO_LinkHandler_CreateDisplayNameLink(playerName)
    local memberIndex = GetGuildMemberIndexFromDisplayName(guildId, playerName)
    local name, note, rankIndex = GetGuildMemberInfo(guildId, memberIndex)
    if note == GWData[worldName].guilds.savedNotes[guildId][playerName] then
        chat:Print(
            "Member note in backup for: |cffffff" .. playerLink .. "|r in " .. GW.CreateGuildLink(guildId) .. "is the same as the current note"
        )
    else
        SetGuildMemberNote(guildId, memberIndex, GWData[worldName].guilds.savedNotes[guildId][playerName])
    end
end

local function AddPlayerContextMenuEntry(playerName, rawName)
    local numGuilds = GetNumGuilds()

    local contextEntries = {}

    for i = 1, GetNumGuilds() do
        local guildId = GetGuildId(i)
        local link = GW.CreateGuildLink(guildId)
        -- local color = GW.GetGuildColor(i)

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
    AddCustomSubMenuItem("ITTs |c" .. GW.COLOR .. "Ghostwriter|r Invite to:", contextEntries)
end
libCM:RegisterPlayerContextMenu(AddPlayerContextMenuEntry, libCM.CATEGORY_LATE)
local function AddGuildRosterMenuEntry(control, button, upInside)
    local data = ZO_ScrollList_GetData(control)
    local guildId = GUILD_ROSTER_MANAGER:GetGuildId()
    -- local guildName = GUILD_ROSTER_MANAGER:GetGuildName()
    -- local guildAlliance = GUILD_ROSTER_MANAGER:GetGuildAlliance()
    -- local note = GetPermissionsFromMemberNote(guildId)
    -- local displayName = ZO_KeyboardGuildRosterRowDisplayName_OnMouseEnter()
    local entries = {
        {
            label = "Backup Note",
            callback = function()
                BackupSpecificNote(guildId, data.displayName)
            end,
            visible = GW.GetPermission_Note(guildId)
        },
        {
            label = "Retrieve Note",
            callback = function()
                RetrieveSpecificNote(guildId, data.displayName)
            end,
            visible = GW.GetPermission_Note(guildId)
        },
        {
            label = "Initiate welcome sequence",
            callback = function()
                OnMemberJoin(_, guildId, data.displayName)
            end,
            visible = function()
                if GW.GetPermission_Note(guildId) == true or GW.GetPermission_Mail(guildId) == true or GW.GetPermission_Chat(guildId) == true then
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
    if GW.GetPermission_Note(guildId) == true or GW.GetPermission_Mail(guildId) == true or GW.GetPermission_Chat(guildId) == true then
        AddCustomSubMenuItem("ITTs |c" .. GW.COLOR .. "Ghostwriter|r", entries)
    end
end

libCM:RegisterGuildRosterContextMenu(AddGuildRosterMenuEntry, libCM.CATEGORY_LATE)

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
            -- guildFilter = {525912}, needs to be in player activated
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
                    if GWData[worldName].guilds.savedNotes[guildId][GetDisplayName()] ~= nil then
                        if note ~= "" then
                            if GWData[worldName].guilds.savedNotes[guildId][data.displayName] == "" then
                                -- "|cFFBF00|t24:24:esoui/art/miscellaneous/check_icon_32.dds:inheritcolor|t|r"
                                return "|c585858|t24:24:esoui/art/miscellaneous/check_icon_32.dds:inheritcolor|t|r"
                            elseif GWData[worldName].guilds.savedNotes[guildId][data.displayName] ~= "" then
                                if GWData[worldName].guilds.savedNotes[guildId][data.displayName] == note then
                                    return "|c00ff00|t24:24:esoui/art/miscellaneous/check_icon_32.dds:inheritcolor|t|r"
                                elseif GWData[worldName].guilds.savedNotes[guildId][data.displayName] ~= note then
                                    return "|cFFBF00|t24:24:esoui/art/miscellaneous/check_icon_32.dds:inheritcolor|t|r"
                                end
                            end
                        elseif note == "" then
                            if GWData[worldName].guilds.savedNotes[guildId][data.displayName] == nil then
                                return ""
                            else
                                if GWData[worldName].guilds.savedNotes[guildId][data.displayName] ~= "" then
                                    return "|cFF0000|t24:24:esoui/art/miscellaneous/check_icon_32.dds:inheritcolor|t|r"
                                elseif GWData[worldName].guilds.savedNotes[guildId][data.displayName] == "" then
                                    return ""
                                end
                            end
                        else
                            return ""
                        end
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

local function MailPreview()
    return st.guilds[st.selectedGuild].settings.mailBody
end
local function NotePreview()
    return st.guilds[st.selectedGuild].settings.mail.noteBody
end
local function makeITTDescription()
    local ITTDTitle = WINDOW_MANAGER:CreateControl("ITTsGhostwriterSettingsLogoTitle", ITTs_GhostwriterSettingsLogo, CT_LABEL)
    ITTDTitle:SetFont("$(BOLD_FONT)|$(KB_18)|soft-shadow-thin")
    ITTDTitle:SetText("|Cfcba03INDEPENDENT TRADING TEAM")
    ITTDTitle:SetDimensions(240, 31)
    ITTDTitle:SetHorizontalAlignment(1)
    ITTDTitle:SetAnchor(TOP, ITTs_GhostWriterSettingsLogo, BOTTOM, 0, 40)

    local ITTDLabel = WINDOW_MANAGER:CreateControl("ITTsGhostwriterSettingsLogoTitleServer", ITTsGhostwriterSettingsLogoTitle, CT_LABEL)
    ITTDLabel:SetFont("$(MEDIUM_FONT)|$(KB_16)|soft-shadow-thick")
    ITTDLabel:SetText("|C646464PC EU")
    ITTDLabel:SetDimensions(240, 21)
    ITTDLabel:SetHorizontalAlignment(1)
    ITTDLabel:SetAnchor(TOP, ITTsGhostwriterSettingsLogoTitle, BOTTOM, 0, -5)

    ITT_HideMePlsGW:SetHidden(true)
end

--* Call function after Menu has been created to prevent using the getFunc
local lamPanelCreationInitDone = false
local function LAMControlsCreatedCallbackFunc(pPanel)
    -- d("hello2")
    if pPanel ~= GW.GWSettingsPanel then
        return
    end
    if lamPanelCreationInitDone == true then
        return
    end
    --Do stuff here
    -- d("hello")

    --! Works but Map Pins will break the menu *sadpanda*
    --[[ ITTGW_LAM_Editbox_MailText:SetHeight(550)
    ITTGW_LAM_Editbox_MailText.container:SetHeight(550)
    ITTGW_LAM_Editbox_MailText.label:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
    ITTGW_LAM_Editbox_MailText.container:SetAnchor(BOTTOMRIGHT, control, BOTTOMRIGHT, 0, 25) ]]
    makeITTDescription()
    lamPanelCreationInitDone = true
end
-- TODO: change one saves for all of them?
--! its all fucked ¯\_(ツ)_/¯
--*update not fucked anymore thank you siri :D
function GW.CreateSettingsWindow()
    id = {}
    local _desc = true
    local text = {}
    local selectedGuildId = guildTableValues[1]
    local selectedDateFormat = dateValues[1]
    local color = GW.GetGuildColor(1)
    GW.GWSettingsPanel =
        LAM:RegisterAddonPanel(
        "GhostwriterOptions",
        {
            type = "panel",
            name = "ITT's |c" .. GW.COLOR .. "Ghostwriter|r",
            author = "JN Slevin",
            version = tostring(GW.version),
            registerForRefresh = true,
            registerForDefaults = false,
            website = "https://github.com/JNSlevin/ITTs-Ghostwriter"
        }
    )

    --[[  local panelData = {
        type = "panel",
        name = "ITT's |c" .. GW.COLOR .. "Ghostwriter|r",
        author = "JN Slevin",
        version = tostring(GW.version),
        registerForRefresh = true,
        registerForDefaults = false,
        website = "https://github.com/JNSlevin/ITTs-Ghostwriter"
    } ]]
    -- LAM:RegisterAddonPanel("GhostwriterOptions", panelData)

    local optionsData = {
        [1] = {
            type = "header",
            name = "|c" .. GW.COLOR .. "Ghostwriter|r Settings"
        },
        [2] = {
            type = "description",
            title = "Setup |c" .. GW.COLOR .. "Ghostwriter|r",
            text = "Please visit the Website (linked in the description). \n\n|cff0000The addon will not work and all guilds pecific settings will be disabled without setup!",
            enableLinks = true,
            width = "full" --or "half" (optional)
        },
        [3] = {
            type = "texture",
            image = "/esoui/art/guild/sectiondivider_left.dds",
            imageWidth = 510, --max of 250 for half width, 510 for full
            imageHeight = 5 --max of 100
        },
        [4] = {
            type = "header",
            name = "General Settings"
        },
        [5] = {
            type = "checkbox",
            name = "Check for online status",
            default = false,
            disabled = false,
            width = "full",
            tooltip = "Will not paste the chatmessage if the invited member is offline",
            getFunc = function()
                return st.generalSettings.offlinecheck
            end,
            setFunc = function(value)
                st.generalSettings.offlinecheck = value
            end,
            d
        },
        [6] = {
            type = "checkbox",
            name = "Include offline mode check",
            default = false,
            disabled = false,
            width = "full",
            tooltip = "Will include the term |cffffffOfflinemode|r in the note if the member is offline for longer than 2 weeks",
            getFunc = function()
                return st.generalSettings.offlinemodecheck
            end,
            setFunc = function(value)
                st.generalSettings.offlinemodecheck = value
            end,
            d
        },
        [7] = {
            type = "checkbox",
            name = "Enable backup button in Guildroster",
            default = false,
            disabled = false,
            width = "full",
            isDangerous = true,
            tooltip = "Will add a button to the guildroster to backup all notes in the selected guild (will be disabled if you do not have the correct permissions!",
            warning = "This will backup your notes upon loading into the game and if any note is changed in your guild! ",
            getFunc = function()
                return st.generalSettings.backupButton
            end,
            setFunc = function(newValue)
                st.generalSettings.backupButton = newValue
                HideBackupButton()
                EnableBackupButton()
            end
        },
        [8] = {
            type = "submenu",
            name = "Guild Settings",
            icon = "/esoui/art/tutorial/guildhistory_indexicon_guild_up.dds",
            controls = {
                [1] = {
                    type = "description",
                    --title = "My Title",	--(optional)
                    title = nil, --(optional)
                    text = "Here you can edit the settings for each guild! First choose the guild in the dropdown below, then edit the templates or turn settings on / off!\n\nThe current placeholders are: \n|c" ..
                        GW.COLOR ..
                            "%DATE%|r\t-\twill be replaced by the current date (in the format you chose below)!\n|c" ..
                                GW.COLOR ..
                                    "%PLAYER%|r\t-\twill be replaced by the account name of the player!\n|c" ..
                                        GW.COLOR .. "%GUILD%|r\t-\twill be replaced by the guilds name!",
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
                            GW.GetPermission_Note(st.selectedGuild) == true or GW.GetPermission_Mail(st.selectedGuild) == true or
                                GW.GetPermission_Chat(st.selectedGuild) == true
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
                    image = "/esoui/art/campaign/campaignbrowser_listdivider_right.dds",
                    imageWidth = 510, --max of 250 for half width, 510 for full
                    imageHeight = 5 --max of 100
                },
                [8] = {
                    type = "checkbox",
                    name = "Message Enabled",
                    default = false,
                    disabled = function()
                        if GW.GetPermission_Chat(st.selectedGuild) == true then
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
                        if GW.GetPermission_Note(st.selectedGuild) == true then
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
                    tooltip = "This message will be pasted in your chat!\n\nMaximum is " .. MAX_TEXT_CHAT_INPUT_CHARACTERS .. " Characters!",
                    isExtraWide = true,
                    isMultiline = true,
                    maxChars = MAX_TEXT_CHAT_INPUT_CHARACTERS,
                    disabled = function()
                        if GW.GetPermission_Chat(st.selectedGuild) == true then
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
                    tooltip = "This is the note you will set once a new member joins\n\nMaximum is 256 Characters!",
                    width = "half",
                    isExtraWide = true,
                    isMultiline = true,
                    disabled = function()
                        if GW.GetPermission_Note(st.selectedGuild) == true then
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
                        NotePreview()
                        st.guilds[st.selectedGuild].settings.noteBody = text
                    end
                },
                [12] = {
                    type = "texture",
                    image = "/esoui/art/campaign/campaignbrowser_listdivider_right.dds",
                    imageWidth = 510, --max of 250 for half width, 510 for full
                    imageHeight = 5 --max of 100
                },
                [13] = {
                    type = "checkbox",
                    name = "Mail Enabled",
                    default = false,
                    disabled = function()
                        if GW.GetPermission_Mail(st.selectedGuild) == true then
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
                [14] = {
                    type = "editbox",
                    name = "MailSubject",
                    tooltip = "This is the subject of the mail\n\nMaximum is " .. MAIL_MAX_SUBJECT_CHARACTERS .. " Characters",
                    isExtraWide = true,
                    isMultiline = false,
                    reference = "GW_SubjectWindow",
                    maxChars = MAIL_MAX_SUBJECT_CHARACTERS,
                    disabled = function()
                        if GW.GetPermission_Mail(st.selectedGuild) == true then
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
                [15] = {
                    type = "editbox",
                    name = "MailBody",
                    tooltip = "This is the mail!\n\nMaximum is " .. MAIL_MAX_BODY_CHARACTERS .. " Characters!",
                    isExtraWide = true,
                    isMultiline = true,
                    reference = "ITTGW_LAM_Editbox_MailText",
                    maxChars = MAIL_MAX_BODY_CHARACTERS,
                    disabled = function()
                        if GW.GetPermission_Mail(st.selectedGuild) == true then
                            return false
                        else
                            return true
                        end
                    end,
                    getFunc = function()
                        return st.guilds[st.selectedGuild].settings.mailBody
                    end,
                    setFunc = function(text)
                        MailPreview()
                        st.guilds[st.selectedGuild].settings.mailBody = text
                    end
                },
                [16] = {
                    type = "description",
                    title = "",
                    text = [[ ]]
                },
                [17] = {
                    type = "submenu",
                    name = "Mail Preview",
                    icon = "/esoui/art/miscellaneous/search_icon.dds",
                    reference = "GW_MailPreview",
                    controls = {
                        [1] = {
                            type = "description",
                            title = "",
                            text = MailPreview
                        }
                    }
                },
                [18] = {
                    type = "submenu",
                    name = "|cffffffBackup options",
                    reference = "GW_BackupOptions",
                    disabled = function()
                        if GW.GetPermission_Note(st.selectedGuild) == true then
                            return false
                        else
                            return true
                        end
                    end,
                    controls = {
                        [1] = {
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
                        }
                    }
                }
            }
        },
        [9] = {
            type = "submenu",
            name = "Changelog",
            icon = "/esoui/art/help/help_tabicon_feedback_up.dds",
            controls = {
                [1] = {
                    type = "description",
                    title = "Changelog current Version",
                    text = "Initially released"
                }
            }
        },
        [10] = {
            type = "description",
            title = "",
            text = [[ ]]
        },
        [11] = {
            type = "description",
            title = "",
            text = [[ ]]
        },
        [12] = {
            type = "texture",
            image = "ITTsGhostwriter/itt-logo.dds",
            imageWidth = "192",
            imageHeight = "192",
            reference = "ITTs_GhostwriterSettingsLogo"
        },
        [13] = {
            type = "checkbox",
            name = "HideMePls",
            getFunc = function()
                return false
            end,
            setFunc = function(value)
                return false
            end,
            default = false,
            disabled = true,
            reference = "ITT_HideMePlsGW"
        }
    }
    CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", LAMControlsCreatedCallbackFunc)
    LAM:RegisterOptionControls("GhostwriterOptions", optionsData)
end

----------------------
---OnPlayerActivated--
----------------------
local function OnPlayerActivated()
    GetGuilds()
    GW.SetupGuilds()
    firstLoad()
    GW.myGuildColumn:SetGuildFilter(GW.GuildsWithPermisson)
    GW.ChatReady = true
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
            GW.LoginAlert()
        end,
        1500
    )

    GW.RosterRow()
    ITTsGhostwriter.CreateSettingsWindow()
    EVENT_MANAGER:UnregisterForEvent(GW.name, EVENT_ADD_ON_LOADED)
    EVENT_MANAGER:RegisterForEvent(GW.name, EVENT_GUILD_MEMBER_ADDED, OnMemberJoin)
end
----------
--Events--
----------
EVENT_MANAGER:RegisterForEvent(GW.name, EVENT_ADD_ON_LOADED, ITTsGhostwriter.OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(GW.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
