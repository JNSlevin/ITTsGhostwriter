local GW = {
    name = "Ghostwriter",
    version = 0.1
}
worldName = GetWorldName()
local chat = LibChatMessage("Ghostwriter", "GW")
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

notecount = 0
-- thanks ghostbane for this first function <3

function GetGuildColor(i)
    local r, g, b = GetChatCategoryColor(_G["CHAT_CATEGORY_GUILD_" .. tostring(i)])
    local colorObject = ZO_ColorDef:New(r, g, b)

    return {
        rgb = {r, g, b},
        hex = colorObject:ToHex()
    }
end
function GW.HandleClickEvent(rawLink, mouseButton, linkText, linkStyle, linkType, guildId, ...)
    local gIndex = GetGuildIndex(guildId)
    if linkType == "guild" then
        -- MAIN_MENU_KEYBOARD:ShowScene("guildHome")
        if mouseButton == MOUSE_BUTTON_INDEX_LEFT then
            MAIN_MENU_KEYBOARD:ShowScene("guildHome")
            zo_callLater(
                function()
                    GUILD_SELECTOR:SelectGuildByIndex(gIndex)
                end,
                1
            )

            return true
        end
        if mouseButton == MOUSE_BUTTON_INDEX_MIDDLE then
            zo_callLater(
                function()
                    GUILD_SELECTOR:SelectGuildByIndex(gIndex)
                end,
                1
            )
            MAIN_MENU_KEYBOARD:ShowScene("guildRecruitmentKeyboard")
            -- MAIN_MENU_KEYBOARD:ToggleSceneGroup("guildsSceneGroup", "guildRecruitmentKeyboard")
            zo_callLater(
                function()
                    GUILD_RECRUITMENT_KEYBOARD:ShowApplicationsList()
                end,
                1
            )

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
function GetNotingPermission(guildId)
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
function GetChatMessagePermission(guildId)
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
function GetMailingPermission(guildId)
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
function writePermissionNote(guildId, playerName, perm)
    local index = GetGuildMemberIndexFromDisplayName(guildId, playerName)
    local name, note, rankIndex, _, _ = GetGuildMemberInfo(guildId, index)
    local link = CreateGuildLink(guildId)
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

    --[[ if perm == mailing then
        contents = string.gsub(note, "|cGW(.-)|r", MAIL_PATTERN)
    end
    if perm == chatting then
        contents = string.gsub(note, "|cGW(.-)|r", CHAT_PATTERN)
    end
    if perm == all then
        contents = string.gsub(note, "|cGW(.-)|r", NOTE_MAIL_AND_CHAT_PATTERN)
    end ]]
    SetGuildMemberNote(guildId, index, contents)
end
function LGRSetupGuilds()
    for i = 1, GetNumGuilds() do
        -- local gIndex = GetGuildIndex(i)
        local guildId = GetGuildId(i)
        if GetNotingPermission(guildId) == true then
            table.insert(LGRGuilds, guildId)
        end
    end
    --d(LGRGuilds)
end
-- TODO: saveguard cooldown
function writeMail(name, subject, body)
    -- local count = i

    RequestOpenMailbox()
    SendMail(name, subject, body)
    CloseMailbox()
    --[[  if m <= total then
        count = count - 1
    end ]]
end
function writeNote(guildId, memberIndex, note)
    local displayName, noteContents = GetGuildMemberInfo(guildId, i)
    local count = i

    SetGuildMemberNote(guildId, memberIndex, note)

    if i <= total then
        count = count + 1
    end
end

function OnNoteChanged(_, guildId, displayName, note)
    notecount = notecount + 1
    if count <= total then
        zo_callLater(
            function()
                writeNote(i)
            end,
            8000
        )
    elseif count > total then
        chat:Print("Finished writing notes for " .. link)
    end
end
EVENT_MANAGER:RegisterForEvent(GW.name, EVENT_GUILD_MEMBER_NOTE_CHANGED, OnNoteChanged)

function OnMailSent()
    if count <= total then
        zo_callLater(
            function()
                writeMail(i)
            end,
            8000
        )
    elseif count > total then
        chat:Print("Finished writing notes for " .. link)
    end
end
-- EVENT_MANAGER:RegisterForEvent(GW.name, EVENT_MAIL_SEND_SUCCESS, OnMailSent)
function CreateGuildLink(guildId)
    alliance = GetGuildAlliance(guildId)
    guildIdNum = tonumber(guildId)
    name = GetGuildName(guildId)
    allianceIcon = {}
    if alliance == 1 then
        allianceIcon = "|t24:24:/esoui/art/journal/gamepad/gp_questtypeicon_guild.dds|t"
    elseif alliance == 2 then
        allianceIcon = "|t16:16/esoui/art/stats/alliancebadge_ebonheart.dds|t"
    elseif alliance == 3 then
        allianceIcon = "|t24:24:/esoui/art/guild/guildhistory_indexicon_guild_down.dds|t"
    end

    local numg = 0
    for gi = 1, GetNumGuilds() do
        local gcheck = GetGuildId(gi)
        if (guildId == gcheck) then
            numg = gi
        end
        color = GetGuildColor(numg)
    end
    guildLink = "|c" .. color.hex .. "[|H1:guild::" .. guildId .. "|h " .. name .. " ]|h|r"

    return guildLink
end

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
