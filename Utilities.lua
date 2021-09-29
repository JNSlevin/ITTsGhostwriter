local GW = {
    name = "ITTsGhostwriter",
    version = 0.4
}
worldName = GetWorldName()
local chat = LibChatMessage("ITTsGhostwriter", "GW")
local chat = chat:SetTagColor(GW_COLOR)
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

LGRGuilds = {}
GWshouldHideFor = {}

------------------
--CutomGuildLink--
------------------

function GetGuildColor(i)
    local r, g, b = GetChatCategoryColor(_G["CHAT_CATEGORY_GUILD_" .. tostring(i)])
    local colorObject = ZO_ColorDef:New(r, g, b)

    return {
        rgb = {r, g, b},
        hex = colorObject:ToHex()
    }
end
function CreateGuildLink(guildId)
    alliance = GetGuildAlliance(guildId)
    gIndex = GetGuildIndex(guildId)
    name = GetGuildName(guildId)
    color = GetGuildColor(gIndex)

    guildLink = "|c" .. color.hex .. "[|H1:gwguild::" .. guildId .. "|h " .. name .. " ]|h|r"

    return guildLink
end
function GW.HandleClickEvent(rawLink, mouseButton, linkText, linkStyle, linkType, guildId, ...)
    local gIndex = GetGuildIndex(guildId)
    if linkType == "gwguild" then
        -- MAIN_MENU_KEYBOARD:ShowScene("guildHome")
        if mouseButton == MOUSE_BUTTON_INDEX_LEFT then
            MAIN_MENU_KEYBOARD:ShowScene("guildHome")
            zo_callLater(
                function()
                    GUILD_SELECTOR:SelectGuildByIndex(gIndex)
                end,
                200
            )

            return true
        end

        if mouseButton == MOUSE_BUTTON_INDEX_MIDDLE then
            zo_callLater(
                function()
                    GUILD_SELECTOR:SelectGuildByIndex(gIndex)
                end,
                200
            )
            if DoesPlayerHaveGuildPermission(guildId, GUILD_PERMISSION_MANAGE_APPLICATIONS) == true then
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
        --TODO: Context Menu
        if mouseButton == MOUSE_BUTTON_INDEX_RIGHT then
            AddCustomMenuItem(
                "test",
                function()
                    CHAT_ROUTER:AddDebugMessage("my Func")
                end
            )
            return true
        end
    end
end
LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_MOUSE_UP_EVENT, GW.HandleClickEvent)

-------------------------
--CheckCustomPermission--
-------------------------

function GetGWNotingPermission(guildId)
    local playerName = GetUnitDisplayName("player")
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
function GetGWChatPermission(guildId)
    local playerName = GetUnitDisplayName("player")
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
function GetGWMailingPermission(guildId)
    local playerName = GetUnitDisplayName("player")
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
function GuildPermissions(guildId)
    if
        DoesPlayerHaveGuildPermission(guildId, "GUILD_PERMISSION_GUILD_PERMISSION_BANK_WITHDRAW_GOLD") and
            DoesPlayerHaveGuildPermission(guildId, "GUILD_PERMISSION_OFFICER_CHAT_WRITE") and
            DoesPlayerHaveGuildPermission(guildID, "GUILD_PERMISSION_DESCRIPTION_EDIT")
     then
        return true
    else
        return false
    end
end

function LGRSetupGuilds()
    for i = 1, GetNumGuilds() do
        -- local gIndex = GetGuildIndex(i)
        local guildId = GetGuildId(i)
        if GetGWNotingPermission(guildId) == true then
            table.insert(LGRGuilds, guildId)
            GWshouldHideFor[guildId] = false
        else
            GWshouldHideFor[guildId] = true
        end
    end
    --d(LGRGuilds)
end

--------------
--Automation--
--------------
noteCount = 0
mailCount = 0
function writeMail(name, subject, body)
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

function writeNote(guildId, memberIndex, note)
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

function GetGuildIndex(guildId)
    local numg = 0

    for gi = 1, GetNumGuilds() do
        local gcheck = GetGuildId(gi)
        local idNum = tonumber(guildId)
        if (idNum == gcheck) then
            numg = gi
            return numg
        end
    end
end
