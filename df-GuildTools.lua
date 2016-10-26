local frame = CreateFrame("FRAME")
frame:RegisterEvent("ADDON_LOADED")

local function init(self)
	SLASH_DFGT_TS1 = '/ts'
	SLASH_DFGT_TSR1 = '/tsr'
	SLASH_DFGT_PG1 = '/pg'
	
	L = {};
	O = {};
	L["name"] = "[df Guild Tools]"
	O["errColor"] = "|cFFFF0000"
	O["textColor"] = "|cFF00FF00"

	if GetLocale() == "deDE" then
		locale_de()
	else
		locale_us()
	end
end

local function onevent(self, event, ...)
	if event == "ADDON_LOADED" and select(1,...) == "df-GuildTools" then
		init()
	end
end

frame:SetScript("OnEvent", onevent)

function create_warning(code)
	print(O["textColor"], L["name"], O["errColor"], L[code]);
end

function ts3(channel)
	local guild_info_section = read_from_guild_info("[TeamSpeak3]")
	local is_in_a_raid_group = UnitInRaid("player")
	if not is_in_a_raid_group then
		create_warning("not_in_a_raid_group")
	end
	if guild_info_section and is_in_a_raid_group then
		SendChatMessage("===== TeamSpeak 3 =====", channel)
		SendChatMessage(guild_info_section, channel)
	end
end

function partner_guild()
	local guild_info_section = read_from_guild_info("[PartnerGuild]")
	if guild_info_section then
		SetWhoToUI(1)
		SendWho("g-\"" .. guild_info_section .. "\"")
	end
end

function read_from_guild_info(section)
	if not IsInGuild() then
		create_warning("not_in_a_guild")
		return nil
	end
	local guild_info_text = GetGuildInfoText()
	if not guild_info_text then
		create_warning("cannot_read_guild_info")
		return nil
	end
	local guild_info_section_begin, guild_info_section_end = strfind(guild_info_text, section, 1, true)
	if not guild_info_section_begin then
		create_warning("cannot_find_section", section)
		return nil
	end
	local next_section_begin, next_section_end = strfind(guild_info_text, "[", guild_info_section_end, true)
	local guild_info_section
	if not next_section_begin then
		guild_info_section = strsub(guild_info_text, guild_info_section_end + 2)
	else
		guild_info_section = strsub(guild_info_text, guild_info_section_end + 2, next_section_begin + 2)
	end
	return guild_info_section
end

function SlashCmdList.DFGT_TS(msg, editbox)
	ts3("RAID");
end

function SlashCmdList.DFGT_TSR(msg, editbox)
	ts3("RAID_WARNING");
end

function SlashCmdList.DFGT_PG(msg, editbox)
	partner_guild()
end