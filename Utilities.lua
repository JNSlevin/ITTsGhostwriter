local GW =
    ITTsGhostwriter or
    {
        name = "ITTsGhostwriter",
        version = 1.3,
        variableVersion = 194
    }
ITTsGhostwriter = GW

local worldName = GetWorldName()
local chat = LibChatMessage("ITTsGhostwriter", "GW")
-- local chat = chat:SetTagColor(GW.COLOR)
-----------
--CONSTANTS
-----------

local NOTE_PATTERN = "|cGWnote|r"
local MAIL_PATTERN = "|cGWmail|r"
local CHAT_PATTERN = "|cCWchat|r"
local NOTE_AND_MAIL_PATTERN = "|cGWnoma|r"
local NOTE_AND_CHAT_PATTERN = "|cGWnoch|r"
local MAIL_AND_CHAT_PATTERN = "|cGWmach|r"
local NOTE_MAIL_AND_CHAT_PATTERN = "|cGWxxxx|r"
--* LibGuildRoster needs one guildId to filter, if its nil it will show in all guilds, so the dummy guildId is added with a number that will most likely never be used by an actual guild
GW.GuildsWithPermisson = {999999999999999}
GW.shouldHideFor = {}

------------------
--CutomGuildLink--
------------------

function GW.GetGuildColor(i)
    local r, g, b = GetChatCategoryColor(_G["CHAT_CATEGORY_GUILD_" .. tostring(i)])
    local colorObject = ZO_ColorDef:New(r, g, b)

    return {
        rgb = {r, g, b},
        hex = colorObject:ToHex()
    }
end
function GW.CreateGuildLink(guildId)
    -- local alliance = GetGuildAlliance(guildId)
    local gIndex = GW.GetGuildIndex(guildId)
    local name = GetGuildName(guildId)
    local color = GW.GetGuildColor(gIndex)
    --[[ allianceIcon = {}
    if alliance == 1 then
        allianceIcon = "|t24:24:/esoui/art/journal/gamepad/gp_questtypeicon_guild.dds|t"
    elseif alliance == 2 then
        allianceIcon = "|t16:16/esoui/art/stats/alliancebadge_ebonheart.dds|t"
    elseif alliance == 3 then
        allianceIcon = "|t24:24:/esoui/art/guild/guildhistory_indexicon_guild_down.dds|t"
    end ]]
    local guildLink = "|c" .. color.hex .. "[|H1:gwguild::" .. guildId .. "|h " .. name .. " ]|h|r"

    return guildLink
end
function GW.HandleClickEvent(rawLink, mouseButton, linkText, linkStyle, linkType, guildId, ...)
    local gIndex = GW.GetGuildIndex(guildId)
    if linkType == "gwguild" then
        -- GUILD_SELECTOR:SelectGuildByIndex(gIndex)
        -- MAIN_MENU_KEYBOARD:ShowScene("guildHome")
        if mouseButton == MOUSE_BUTTON_INDEX_LEFT then
            GUILD_SELECTOR:SelectGuildByIndex(gIndex)
            MAIN_MENU_KEYBOARD:ShowScene("guildHome")

            return true
        end

        if mouseButton == MOUSE_BUTTON_INDEX_MIDDLE then
            --[[  zo_callLater(
                function()
                    GUILD_SELECTOR:SelectGuildByIndex(gIndex)
                end,
                200
            ) ]]
            if DoesPlayerHaveGuildPermission(guildId, GUILD_PERMISSION_MANAGE_APPLICATIONS) == true then
                GUILD_SELECTOR:SelectGuildByIndex(gIndex)
                MAIN_MENU_KEYBOARD:ShowScene("guildRecruitmentKeyboard")
                -- MAIN_MENU_KEYBOARD:ToggleSceneGroup("guildsSceneGroup", "guildRecruitmentKeyboard")
                zo_callLater(
                    function()
                        GUILD_RECRUITMENT_KEYBOARD:ShowApplicationsList()
                    end,
                    250
                )
            else
                zo_callLater(
                    function()
                        MAIN_MENU_KEYBOARD:ShowScene("guildRoster")
                    end,
                    50
                )
            end
            return true
        end

        if mouseButton == MOUSE_BUTTON_INDEX_RIGHT then
            ClearMenu()

            AddCustomMenuItem(
                "Show Guild Roster",
                function()
                    GUILD_SELECTOR:SelectGuildByIndex(gIndex)
                    MAIN_MENU_KEYBOARD:ShowScene("guildRoster")
                    --[[ zo_callLater(
                        function()
                            GUILD_SELECTOR:SelectGuildByIndex(gIndex)
                        end,
                        200
                    ) ]]
                end
            )
            AddCustomMenuItem(
                "Show Guild Ranks",
                function()
                    GUILD_SELECTOR:SelectGuildByIndex(gIndex)
                    MAIN_MENU_KEYBOARD:ShowScene("guildRanks")
                    --[[ zo_callLater(
                        function()
                            GUILD_SELECTOR:SelectGuildByIndex(gIndex)
                        end,
                        200
                    ) ]]
                end
            )
            if DoesPlayerHaveGuildPermission(guildId, GUILD_PERMISSION_MANAGE_APPLICATIONS) == true then
                AddCustomMenuItem(
                    "Show Guild Recruitment",
                    function()
                        GUILD_SELECTOR:SelectGuildByIndex(gIndex)
                        MAIN_MENU_KEYBOARD:ShowScene("guildRecruitmentKeyboard")
                        --[[ zo_callLater(
                        function()
                            GUILD_SELECTOR:SelectGuildByIndex(gIndex)
                        end,
                        200
                    ) ]]
                    end
                )
            end
            if DoesPlayerHaveGuildPermission(guildId, GUILD_PERMISSION_EDIT_HERALDRY) == true then
                AddCustomMenuItem(
                    "Show Guild Heraldry",
                    function()
                        GUILD_SELECTOR:SelectGuildByIndex(gIndex)
                        MAIN_MENU_KEYBOARD:ShowScene("guildHeraldry")
                        --[[ zo_callLater(
                        function()
                            GUILD_SELECTOR:SelectGuildByIndex(gIndex)
                        end,
                        200
                    ) ]]
                    end
                )
            end
            AddCustomMenuItem(
                "Show Guild History",
                function()
                    GUILD_SELECTOR:SelectGuildByIndex(gIndex)
                    MAIN_MENU_KEYBOARD:ShowScene("guildHistory")
                    --[[ zo_callLater(
                        function()
                            GUILD_SELECTOR:SelectGuildByIndex(gIndex)
                        end,
                        200
                    ) ]]
                end
            )
            ShowMenu()
            return true
        end
    end
end
LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_MOUSE_UP_EVENT, GW.HandleClickEvent)

-------------------------
--CheckCustomPermission--
-------------------------

function GW.GetPermission_Note(guildId)
    local playerName = GetDisplayName()
    local numMembers = GetNumGuildMembers(guildId)

    for i = 1, numMembers do
        local name, memberNote, rankIndex, _, _ = GetGuildMemberInfo(guildId, i)
        if playerName == name then
            if PlainStringFind(memberNote, NOTE_PATTERN) == true then
                return true
            elseif PlainStringFind(memberNote, NOTE_AND_MAIL_PATTERN) == true then
                return true
            elseif PlainStringFind(memberNote, NOTE_AND_CHAT_PATTERN) == true then
                return true
            elseif PlainStringFind(memberNote, NOTE_MAIL_AND_CHAT_PATTERN) == true then
                return true
            else
                return false
            end
        end
    end
end
function GW.GetPermission_Chat(guildId)
    local playerName = GetDisplayName()
    local numMembers = GetNumGuildMembers(guildId)

    for i = 1, numMembers do
        local name, memberNote, rankIndex, _, _ = GetGuildMemberInfo(guildId, i)
        if playerName == name then
            if PlainStringFind(memberNote, CHAT_PATTERN) == true then
                return true
            elseif PlainStringFind(memberNote, MAIL_AND_CHAT_PATTERN) == true then
                return true
            elseif PlainStringFind(memberNote, NOTE_AND_CHAT_PATTERN) == true then
                return true
            elseif PlainStringFind(memberNote, NOTE_MAIL_AND_CHAT_PATTERN) == true then
                return true
            else
                return false
            end
        end
    end
end
function GW.GetPermission_Mail(guildId)
    local playerName = GetDisplayName()
    local numMembers = GetNumGuildMembers(guildId)

    for i = 1, numMembers do
        local name, memberNote, rankIndex, _, _ = GetGuildMemberInfo(guildId, i)
        if playerName == name then
            if PlainStringFind(memberNote, MAIL_PATTERN) == true then
                return true
            elseif PlainStringFind(memberNote, NOTE_AND_MAIL_PATTERN) == true then
                return true
            elseif PlainStringFind(memberNote, MAIL_AND_CHAT_PATTERN) == true then
                return true
            elseif PlainStringFind(memberNote, NOTE_MAIL_AND_CHAT_PATTERN) == true then
                return true
            else
                return false
            end
        end
    end
end

--[[ function writePermissionNote(guildId, playerName, perm)
    local index = GetGuildMemberIndexFromDisplayName(guildId, playerName)
    local name, note, rankIndex, _, _ = GetGuildMemberInfo(guildId, index)
    local link = GW.CreateGuildLink(guildId)
    -- local contents = (identifier .. note)
    -- string.gsub(text, "|cGW(.-)|r", "|cGWnote|r")
    if name ~= playerName then
        chat:Print("Player not found in " .. link)
        return
    end
    if perm == noting then
        -- d("test")
        contents = string.gsub(note, "|cGW(.-)|r", NOTE_PATTERN)
        contents = (NOTE_PATTERN .. note)
    else
        -- contents = (NOTE_PATTERN .. note)
        contents = string.gsub(note, "|cGW(.-)|r", NOTE_PATTERN)
    end

    SetGuildMemberNote(guildId, index, contents)
end ]]
function GW.SetupGuilds()
    for i = 1, GetNumGuilds() do
        -- local gIndex = GetGuildIndex(i)
        local guildId = GetGuildId(i)
        if GW.GetPermission_Note(guildId) == true then
            table.insert(GW.GuildsWithPermisson, guildId)
            GW.shouldHideFor[guildId] = false
        else
            GW.shouldHideFor[guildId] = true
        end
    end
    --d(GW.GuildsWithPermisson)
end

--------------
--Automation--
--------------
local noteCount = 0
local mailCount = 0
function GW.writeMail(name, subject, body)
    local mailCount = mailCount + 1

    zo_callLater(
        function()
            RequestOpenMailbox()
            SendMail(name, subject, body)
            zo_callLater(
                function()
                    CloseMailbox()
                end,
                1000
            )
            mailCount = mailCount - 1
        end,
        5000 * mailCount
    )
end

function GW.writeNote(guildId, memberIndex, note)
    noteCount = noteCount + 1

    zo_callLater(
        function()
            SetGuildMemberNote(guildId, memberIndex, note)
            noteCount = noteCount - 1
        end,
        7000 * noteCount
    )
end

----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------

function GW.GetGuildIndex(guildId)
    local numg = 0

    for gi = 1, GetNumGuilds() do
        local gcheck = GetGuildId(gi)
        local idNum = tonumber(guildId)
        if (idNum == gcheck) then
            return gi
        end
    end
end
