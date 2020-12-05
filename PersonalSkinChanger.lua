script_name('PersonalSkinChanger')
script_version('1.0.4.1')
script_author('dmitriyewich, https://vk.com/dmitriyewichmods')
script_properties('work-in-pause')

require "moonloader"
local dlstatus = require "moonloader".download_status
local limgui, imgui = pcall(require, 'mimgui') -- https://github.com/THE-FYP/mimgui
local lffi, ffi = pcall(require, 'ffi') assert(lffi, 'Library \'ffi\' not found.')
local lfaicons, faicons = pcall(require, 'fa-icons')
local lsampev, sampev = pcall(require, 'samp.events') -- https://github.com/THE-FYP/SAMP.Lua
local lfa, fa = pcall(require, 'fAwesome5') -- https://www.blast.hk/threads/19292/post-335148
local llfs, lfs = pcall(require, 'lfs')
local lziplib, ziplib = pcall(ffi.load, string.format("%s/lib/ziplib.dll",getWorkingDirectory())) 
local lencoding, encoding = pcall(require, 'encoding') assert(lencoding, 'Library \'encoding\' not found.')

encoding.default = 'CP1251'
u8 = encoding.UTF8
CP1251 = encoding.CP1251

ffi.cdef[[
    int zip_extract(const char *zipname, const char *dir,int *func, void *arg);
]]

local new = imgui.new

local updlink = 'https://raw.githubusercontent.com/dmitriyewich/Personal-Skin-Changer/main/update.json'
local invalidID = 'https://raw.githubusercontent.com/dmitriyewich/Personal-Skin-Changer/main/invalidID.txt' -- незанятые иды

changelog = [[
	{FFFFFF}v0.1
{ccccd3}Релиз.
	{FFFFFF}v0.2 
{ccccd3}Почему-то хук менял только скин локального игрока, добавил другой, теперь заменяет скины других игроков.
	{FFFFFF}v0.3
{ccccd3}Теперь не надо умирать\спавниться. Скин меняется сразу после привязки. (Но после отвязки скина всё так же необходимо умиреть\заспавниться\сменить зону стрима)
	{FFFFFF}v0.4
{ccccd3}Hotfix 
	{FFFFFF}v0.5
{ccccd3}Незанятые иды можно узнать в текстовом файле в группе вк(или по кнопке в конце истории изменений). Вместо них добавлен предпросмотр стандартных скинов и новых скинов, которые вы привязали.
	{FFFFFF}v0.6
{ccccd3}Переведен конфиг на json, проблемы с точкой в нике нет. Сделал сортировку новых скинов по возрастанию ида. 
	{FFFFFF}v0.7
{ccccd3}Добавлено автообновление(по умолчанию выключено), и мелкие дополнения\исправления. {FFFFFF}Если вы не хотите получать обновление в настройках отключите эту функцию.
	{FFFFFF}v0.8
{ccccd3}Перевел скрипт на {FFFFFF}mimgui{ccccd3}. Мелкие фиксы, улучшения.
	{FFFFFF}v0.9
{ccccd3}Ребрендинг. Теперь скрипт называется {FFFFFF}PersonalSkinChanger{ccccd3}(всместо Очередной фейкскин). При отсутвии необходимых библиотек скрипт сам их скачает. Мелкие фиксы, улучшения.	
	{FFFFFF}v1.0
{ccccd3}При отвязки скина возвращается скин который был до привязки. Добавил в настройки смену команды активации скрипта. Мелкие фиксы.
	{FFFFFF}v1.0.1
{ccccd3}Микрофиксы
	{FFFFFF}v1.0.2 
{ccccd3}Микрофиксы. Появились новые зависимости LFS и ZipLua, они нужны чтобы распаковать архив mimgui-v1.7.0.zip(скачивается напрямую с гитхаба), если не установлен mimgui.	
	{FFFFFF}v1.0.3 
{ccccd3}Микрофиксы.
	{FFFFFF}v1.0.4 
{ccccd3}Микрофиксы. Изменение ссылки на обновление. Проверка идет с github. Так же изменено имя файла. После обновления старая версия с названием фала fskin.lua удалиться автоматически. 
	{FFFFFF}v1.0.4.1
{ccccd3}Микрофиксы. Исправление кодировки.
]]

local function isarray(t, emptyIsObject)
	if type(t)~='table' then return false end
	if not next(t) then return not emptyIsObject end
	local len = #t
	for k,_ in pairs(t) do
		if type(k)~='number' then
			return false
		else
			local _,frac = math.modf(k)
			if frac~=0 or k<1 or k>len then
				return false
			end
		end
	end
	return true
end

local function map(t,f)
	local r={}
	for i,v in ipairs(t) do r[i]=f(v) end
	return r
end

local keywords = {["and"]=1,["break"]=1,["do"]=1,["else"]=1,["elseif"]=1,["end"]=1,["false"]=1,["for"]=1,["function"]=1,["goto"]=1,["if"]=1,["in"]=1,["local"]=1,["nil"]=1,["not"]=1,["or"]=1,["repeat"]=1,["return"]=1,["then"]=1,["true"]=1,["until"]=1,["while"]=1}

local function neatJSON(value, opts)
	opts = opts or {}
	if opts.wrap==nil  then opts.wrap = 80 end
	if opts.wrap==true then opts.wrap = -1 end
	opts.indent         = opts.indent         or "  "
	opts.arrayPadding  = opts.arrayPadding  or opts.padding      or 0
	opts.objectPadding = opts.objectPadding or opts.padding      or 0
	opts.afterComma    = opts.afterComma    or opts.aroundComma  or 0
	opts.beforeComma   = opts.beforeComma   or opts.aroundComma  or 0
	opts.beforeColon   = opts.beforeColon   or opts.aroundColon  or 0
	opts.afterColon    = opts.afterColon    or opts.aroundColon  or 0
	opts.beforeColon1  = opts.beforeColon1  or opts.aroundColon1 or opts.beforeColon or 0
	opts.afterColon1   = opts.afterColon1   or opts.aroundColon1 or opts.afterColon  or 0
	opts.beforeColonN  = opts.beforeColonN  or opts.aroundColonN or opts.beforeColon or 0
	opts.afterColonN   = opts.afterColonN   or opts.aroundColonN or opts.afterColon  or 0

	local colon  = opts.lua and '=' or ':'
	local array  = opts.lua and {'{','}'} or {'[',']'}
	local apad   = string.rep(' ', opts.arrayPadding)
	local opad   = string.rep(' ', opts.objectPadding)
	local comma  = string.rep(' ',opts.beforeComma)..','..string.rep(' ',opts.afterComma)
	local colon1 = string.rep(' ',opts.beforeColon1)..colon..string.rep(' ',opts.afterColon1)
	local colonN = string.rep(' ',opts.beforeColonN)..colon..string.rep(' ',opts.afterColonN)

	local build -- set lower
	local function rawBuild(o,indent)
		if o==nil then
			return indent..'null'
		else
			local kind = type(o)
			if kind=='number' then
				local _,frac = math.modf(o)
				return indent .. string.format( frac~=0 and opts.decimals and ('%.'..opts.decimals..'f') or '%g', o)
			elseif kind=='boolean' or kind=='nil' then
				return indent..tostring(o)
			elseif kind=='string' then
				return indent..string.format('%q', o):gsub('\\\n','\\n')
			elseif isarray(o, opts.emptyTablesAreObjects) then
				if #o==0 then return indent..array[1]..array[2] end
				local pieces = map(o, function(v) return build(v,'') end)
				local oneLine = indent..array[1]..apad..table.concat(pieces,comma)..apad..array[2]
				if opts.wrap==false or #oneLine<=opts.wrap then return oneLine end
				if opts.short then
					local indent2 = indent..' '..apad;
					pieces = map(o, function(v) return build(v,indent2) end)
					pieces[1] = pieces[1]:gsub(indent2,indent..array[1]..apad, 1)
					pieces[#pieces] = pieces[#pieces]..apad..array[2]
					return table.concat(pieces, ',\n')
				else
					local indent2 = indent..opts.indent
					return indent..array[1]..'\n'..table.concat(map(o, function(v) return build(v,indent2) end), ',\n')..'\n'..(opts.indentLast and indent2 or indent)..array[2]
				end
			elseif kind=='table' then
				if not next(o) then return indent..'{}' end

				local sortedKV = {}
				local sort = opts.sort or opts.sorted
				for k,v in pairs(o) do
					local kind = type(k)
					if kind=='string' or kind=='number' then
						sortedKV[#sortedKV+1] = {k,v}
						if sort==true then
							sortedKV[#sortedKV][3] = tostring(k)
						elseif type(sort)=='function' then
							sortedKV[#sortedKV][3] = sort(k,v,o)
						end
					end
				end
				if sort then table.sort(sortedKV, function(a,b) return a[3]<b[3] end) end
				local keyvals
				if opts.lua then
					keyvals=map(sortedKV, function(kv)
						if type(kv[1])=='string' and not keywords[kv[1]] and string.match(kv[1],'^[%a_][%w_]*$') then
							return string.format('%s%s%s',kv[1],colon1,build(kv[2],''))
						else
							return string.format('[%q]%s%s',kv[1],colon1,build(kv[2],''))
						end
					end)
				else
					keyvals=map(sortedKV, function(kv) return string.format('%q%s%s',kv[1],colon1,build(kv[2],'')) end)
				end
				keyvals=table.concat(keyvals, comma)
				local oneLine = indent.."{"..opad..keyvals..opad.."}"
				if opts.wrap==false or #oneLine<opts.wrap then return oneLine end
				if opts.short then
					keyvals = map(sortedKV, function(kv) return {indent..' '..opad..string.format('%q',kv[1]), kv[2]} end)
					keyvals[1][1] = keyvals[1][1]:gsub(indent..' ', indent..'{', 1)
					if opts.aligned then
						local longest = math.max(table.unpack(map(keyvals, function(kv) return #kv[1] end)))
						local padrt   = '%-'..longest..'s'
						for _,kv in ipairs(keyvals) do kv[1] = padrt:format(kv[1]) end
					end
					for i,kv in ipairs(keyvals) do
						local k,v = kv[1], kv[2]
						local indent2 = string.rep(' ',#(k..colonN))
						local oneLine = k..colonN..build(v,'')
						if opts.wrap==false or #oneLine<=opts.wrap or not v or type(v)~='table' then
							keyvals[i] = oneLine
						else
							keyvals[i] = k..colonN..build(v,indent2):gsub('^%s+','',1)
						end
					end
					return table.concat(keyvals, ',\n')..opad..'}'
				else
					local keyvals
					if opts.lua then
						keyvals=map(sortedKV, function(kv)
							if type(kv[1])=='string' and not keywords[kv[1]] and string.match(kv[1],'^[%a_][%w_]*$') then
								return {table.concat{indent,opts.indent,kv[1]}, kv[2]}
							else
								return {string.format('%s%s[%q]',indent,opts.indent,kv[1]), kv[2]}
							end
						end)
					else
						keyvals = {}
						for i,kv in ipairs(sortedKV) do
							keyvals[i] = {indent..opts.indent..string.format('%q',kv[1]), kv[2]}
						end
					end
					if opts.aligned then
						local longest = math.max(table.unpack(map(keyvals, function(kv) return #kv[1] end)))
						local padrt   = '%-'..longest..'s'
						for _,kv in ipairs(keyvals) do kv[1] = padrt:format(kv[1]) end
					end
					local indent2 = indent..opts.indent
					for i,kv in ipairs(keyvals) do
						local k,v = kv[1], kv[2]
						local oneLine = k..colonN..build(v,'')
						if opts.wrap==false or #oneLine<=opts.wrap or not v or type(v)~='table' then
							keyvals[i] = oneLine
						else
							keyvals[i] = k..colonN..build(v,indent2):gsub('^%s+','',1)
						end
					end
					return indent..'{\n'..table.concat(keyvals, ',\n')..'\n'..(opts.indentLast and indent2 or indent)..'}'
				end
			end
		end
	end

	local function memoize()
		local memo = setmetatable({},{_mode='k'})
		return function(o,indent)
			if o==nil then
				return indent..(opts.lua and 'nil' or 'null')
			elseif o~=o then 
				return indent..(opts.lua and '0/0' or '"NaN"')
			elseif o==math.huge then
				return indent..(opts.lua and '1/0' or '9e9999')
			elseif o==-math.huge then
				return indent..(opts.lua and '-1/0' or '-9e9999')
			end
			local byIndent = memo[o]
			if not byIndent then
				byIndent = setmetatable({},{_mode='k'})
				memo[o] = byIndent
			end
			if not byIndent[indent] then
				byIndent[indent] = rawBuild(o,indent)
			end
			return byIndent[indent]
		end
	end

	build = memoize()
	return build(value,'')
end
 
function savejson(table, path)
    local f = io.open(path, "w")
    f:write(table)
    f:close()
end
function convertTableToJsonString(config)
    return (neatJSON(config, {sort = true, wrap = 40}))
end 	
local config = {}
local updatestatustest = ''
local updatestatusonof = ''
local saveskintext = ''
local changecmdtext = ''
if doesFileExist("moonloader/config/PersonalSkinChanger.json") then
    local f = io.open("moonloader/config/PersonalSkinChanger.json")
    config = decodeJson(f:read("*a"))
    f:close()
else
   config = {
		["skins"] =	{ 
			["Name_Nick"] = "313",
			["Nick_Name"] = "314";
		},
        ["settings"] = {
            ["autoupdate"] = false,
			["changelog"] = true,
			["cmd"] = "fskin";
        },
        ["skinslast"] = { -- ид скина до привязки, пока такой костыль
            ["Name_Nick"] = 313;
        }
	}
    savejson(convertTableToJsonString(config), "moonloader/config/PersonalSkinChanger.json")
end

function sampGetPlayerIdByNickname(nick)
    local _, myid = sampGetPlayerIdByCharHandle(playerPed)
    if tostring(nick) == sampGetPlayerNickname(myid) then return myid end
    for i = 0, 1000 do if sampIsPlayerConnected(i) and sampGetPlayerNickname(i) == tostring(nick) then return i end end
end

if limgui then
local TBDonHomka = {}
local fonts = {}
local fontsArray = {}
local fontSize = new.int(0)

TBDonHomka._SETTINGS = {
    HotKey = {
        noKeysMessage = "No"
    }
}

local fa_font = nil
local fa_glyph_ranges = imgui.new.ImWchar[3](fa.min_range, fa.max_range, 0)
local function loadIconicFont(fontSize)
	-- Load iconic font in merge mode
	local config = imgui.ImFontConfig()
	config.MergeMode = true
	config.PixelSnapH = true
	local iconRanges = imgui.new.ImWchar[3](faicons.min_range, faicons.max_range, 0)
	imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(faicons.get_font_data_base85(), fontSize, config, iconRanges)
end

function apply_custom_style()					 
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
	style.WindowRounding = 5.0
	style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
	style.FrameRounding = 4.0
	style.ItemSpacing = imgui.ImVec2(12, 8)
	style.ItemInnerSpacing = imgui.ImVec2(8, 6) 
	style.IndentSpacing = 25.0
	style.ScrollbarSize = 13.0
	style.ScrollbarRounding = 9.0
	style.GrabMinSize = 5.0
	style.GrabRounding = 3.0
	style.WindowBorderSize = 0.0
	style.WindowPadding = imgui.ImVec2(4.0, 4.0)
	style.FramePadding = imgui.ImVec2(5, 5)
	style.ButtonTextAlign = imgui.ImVec2(0.5, 0.35)
	style.WindowMinSize = imgui.ImVec2(0, 0)

	colors[clr.Text] = ImVec4(0.80, 0.80, 0.83, 1.00)
	colors[clr.TextDisabled] = ImVec4(0.24, 0.23, 0.29, 1.00)
	colors[clr.WindowBg] = ImVec4(0.06, 0.05, 0.07, 1.00)
	colors[clr.PopupBg] = ImVec4(0.07, 0.07, 0.09, 1.00)												
	colors[clr.Border] = ImVec4(0.80, 0.80, 0.83, 0.88)
	colors[clr.BorderShadow] = ImVec4(0.92, 0.91, 0.88, 0.00)
	colors[clr.FrameBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
	colors[clr.FrameBgHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
	colors[clr.FrameBgActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
	colors[clr.TitleBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
	colors[clr.TitleBgActive] = ImVec4(0.07, 0.07, 0.09, 1.00)
	colors[clr.TitleBgCollapsed] = ImVec4(1.00, 0.98, 0.95, 0.75)
	colors[clr.MenuBarBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
	colors[clr.ScrollbarBg] = ImVec4(0.02, 0.02, 0.02, 0.53)
	colors[clr.ScrollbarGrab] = ImVec4(0.80, 0.80, 0.83, 0.31)
	colors[clr.ScrollbarGrabHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
	colors[clr.ScrollbarGrabActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
	colors[clr.CheckMark] = ImVec4(0.98, 0.26, 0.26, 1.00)
	colors[clr.SliderGrab] = ImVec4(0.28, 0.28, 0.28, 1.00)
	colors[clr.SliderGrabActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
	colors[clr.Button] = ImVec4(0.10, 0.09, 0.12, 1.00)
	colors[clr.ButtonHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
	colors[clr.ButtonActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
	colors[clr.Header] = ImVec4(0.10, 0.09, 0.12, 1.00)
	colors[clr.HeaderHovered] = ImVec4(0.56, 0.56, 0.58, 1.000)
	colors[clr.HeaderActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
	colors[clr.Separator] = colors[clr.Border]
	colors[clr.SeparatorHovered] = ImVec4(0.26, 0.59, 0.98, 0.78)
	colors[clr.SeparatorActive] = ImVec4(0.26, 0.59, 0.98, 1.00)
	colors[clr.ResizeGrip] = ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[clr.ResizeGripHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
	colors[clr.ResizeGripActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
	colors[clr.PlotLines] = ImVec4(0.40, 0.39, 0.38, 0.63)
	colors[clr.PlotLinesHovered] = ImVec4(0.25, 1.00, 0.00, 1.00)
	colors[clr.PlotHistogram] = ImVec4(0.40, 0.39, 0.38, 0.63)
	colors[clr.PlotHistogramHovered] = ImVec4(0.25, 1.00, 0.00, 1.00)
	colors[clr.TextSelectedBg] = ImVec4(0.25, 1.00, 0.00, 0.43)
end

imgui.OnInitialize(function() -- Called once
	apply_custom_style() -- применим кастомный стиль
	-- Find all installed fonts
	local search, file = findFirstFile(getFolderPath(0x14) .. '\\*.ttf')
	while file do
		table.insert(fonts, file)
		file = findNextFile(search)
	end
	fontsArray = imgui.new['const char*'][#fonts](fonts)

	-- Disable ini config. By default it is saved to moonloader/config/mimgui/%scriptfilename%.ini
	imgui.GetIO().IniFilename = nil

	-- Add font with icons
	fontSize[0] = imgui.GetIO().Fonts.ConfigData.Data[0].SizePixels
	loadIconicFont(fontSize[0])

	-- All icons string
	local icons = {}
	for k, v in pairs(faicons) do
		icons[#icons + 1] = v
	end
	iconsText = table.concat(icons, '\t')
	
	logo = imgui.CreateTextureFromFileInMemory(_logo, #_logo)

    TBDonHomka._SETTINGS.ToggleButton = {
        scale = 1.0,
        AnimSpeed = 0.13,
        colors = {
            imgui.GetStyle().Colors[imgui.Col.ButtonActive], -- Enable circle
            imgui.ImVec4(150 / 255, 150 / 255, 150 / 255, 1.0), -- Disable circle
            imgui.GetStyle().Colors[imgui.Col.FrameBgHovered], -- Enable rect
            imgui.ImVec4(100 / 255, 100 / 255, 100 / 255, 180 / 255) -- Disable rect
        }
    }
end)

_logo ="\x89\x50\x4E\x47\x0D\x0A\x1A\x0A\x00\x00\x00\x0D\x49\x48\x44\x52\x00\x00\x01\x86\x00\x00\x00\x19\x08\x06\x00\x00\x00\x35\xC7\x89\xC7\x00\x00\x01\x26\x69\x43\x43\x50\x41\x64\x6F\x62\x65\x20\x52\x47\x42\x20\x28\x31\x39\x39\x38\x29\x00\x00\x28\xCF\x63\x60\x60\x32\x70\x74\x71\x72\x65\x12\x60\x60\xC8\xCD\x2B\x29\x0A\x72\x77\x52\x88\x88\x8C\x52\x60\x3F\xCF\xC0\xC6\xC0\xCC\x00\x06\x89\xC9\xC5\x05\x8E\x01\x01\x3E\x20\x76\x5E\x7E\x5E\x2A\x03\x06\xF8\x76\x8D\x81\x11\x44\x5F\xD6\x05\x99\xC5\x40\x1A\xE0\x4A\x2E\x28\x2A\x01\xD2\x7F\x80\xD8\x28\x25\xB5\x38\x99\x81\x81\xD1\x00\xC8\xCE\x2E\x2F\x29\x00\x8A\x33\xCE\x01\xB2\x45\x92\xB2\xC1\xEC\x0D\x20\x76\x51\x48\x90\x33\x90\x7D\x04\xC8\xE6\x4B\x87\xB0\xAF\x80\xD8\x49\x10\xF6\x13\x10\xBB\x08\xE8\x09\x20\xFB\x0B\x48\x7D\x3A\x98\xCD\xC4\x01\x36\x07\xC2\x96\x01\xB1\x4B\x52\x2B\x40\xF6\x32\x38\xE7\x17\x54\x16\x65\xA6\x67\x94\x28\x18\x5A\x5A\x5A\x2A\x38\xA6\xE4\x27\xA5\x2A\x04\x57\x16\x97\xA4\xE6\x16\x2B\x78\xE6\x25\xE7\x17\x15\xE4\x17\x25\x96\xA4\xA6\x00\xD5\x42\xDC\x07\x06\x82\x10\x85\xA0\x10\xD3\x00\x6A\xB4\xD0\x64\xA0\x32\x00\xC5\x03\x84\xF5\x39\x10\x1C\xBE\x8C\x62\x67\x10\x62\x08\x90\x5C\x5A\x54\x06\x65\x32\x32\x19\x13\xE6\x23\xCC\x98\x23\xC1\xC0\xE0\xBF\x94\x81\x81\xE5\x0F\x42\xCC\xA4\x97\x81\x61\x81\x0E\x03\x03\xFF\x54\x84\x98\x9A\x21\x03\x83\x80\x3E\x03\xC3\xBE\x39\x00\xC0\xC6\x4F\xFD\x19\x3A\x36\x5C\x00\x00\x00\x09\x70\x48\x59\x73\x00\x00\x0B\x13\x00\x00\x0B\x13\x01\x00\x9A\x9C\x18\x00\x00\x06\x6E\x69\x54\x58\x74\x58\x4D\x4C\x3A\x63\x6F\x6D\x2E\x61\x64\x6F\x62\x65\x2E\x78\x6D\x70\x00\x00\x00\x00\x00\x3C\x3F\x78\x70\x61\x63\x6B\x65\x74\x20\x62\x65\x67\x69\x6E\x3D\x22\xEF\xBB\xBF\x22\x20\x69\x64\x3D\x22\x57\x35\x4D\x30\x4D\x70\x43\x65\x68\x69\x48\x7A\x72\x65\x53\x7A\x4E\x54\x63\x7A\x6B\x63\x39\x64\x22\x3F\x3E\x20\x3C\x78\x3A\x78\x6D\x70\x6D\x65\x74\x61\x20\x78\x6D\x6C\x6E\x73\x3A\x78\x3D\x22\x61\x64\x6F\x62\x65\x3A\x6E\x73\x3A\x6D\x65\x74\x61\x2F\x22\x20\x78\x3A\x78\x6D\x70\x74\x6B\x3D\x22\x41\x64\x6F\x62\x65\x20\x58\x4D\x50\x20\x43\x6F\x72\x65\x20\x36\x2E\x30\x2D\x63\x30\x30\x32\x20\x37\x39\x2E\x31\x36\x34\x33\x35\x32\x2C\x20\x32\x30\x32\x30\x2F\x30\x31\x2F\x33\x30\x2D\x31\x35\x3A\x35\x30\x3A\x33\x38\x20\x20\x20\x20\x20\x20\x20\x20\x22\x3E\x20\x3C\x72\x64\x66\x3A\x52\x44\x46\x20\x78\x6D\x6C\x6E\x73\x3A\x72\x64\x66\x3D\x22\x68\x74\x74\x70\x3A\x2F\x2F\x77\x77\x77\x2E\x77\x33\x2E\x6F\x72\x67\x2F\x31\x39\x39\x39\x2F\x30\x32\x2F\x32\x32\x2D\x72\x64\x66\x2D\x73\x79\x6E\x74\x61\x78\x2D\x6E\x73\x23\x22\x3E\x20\x3C\x72\x64\x66\x3A\x44\x65\x73\x63\x72\x69\x70\x74\x69\x6F\x6E\x20\x72\x64\x66\x3A\x61\x62\x6F\x75\x74\x3D\x22\x22\x20\x78\x6D\x6C\x6E\x73\x3A\x78\x6D\x70\x3D\x22\x68\x74\x74\x70\x3A\x2F\x2F\x6E\x73\x2E\x61\x64\x6F\x62\x65\x2E\x63\x6F\x6D\x2F\x78\x61\x70\x2F\x31\x2E\x30\x2F\x22\x20\x78\x6D\x6C\x6E\x73\x3A\x78\x6D\x70\x4D\x4D\x3D\x22\x68\x74\x74\x70\x3A\x2F\x2F\x6E\x73\x2E\x61\x64\x6F\x62\x65\x2E\x63\x6F\x6D\x2F\x78\x61\x70\x2F\x31\x2E\x30\x2F\x6D\x6D\x2F\x22\x20\x78\x6D\x6C\x6E\x73\x3A\x73\x74\x45\x76\x74\x3D\x22\x68\x74\x74\x70\x3A\x2F\x2F\x6E\x73\x2E\x61\x64\x6F\x62\x65\x2E\x63\x6F\x6D\x2F\x78\x61\x70\x2F\x31\x2E\x30\x2F\x73\x54\x79\x70\x65\x2F\x52\x65\x73\x6F\x75\x72\x63\x65\x45\x76\x65\x6E\x74\x23\x22\x20\x78\x6D\x6C\x6E\x73\x3A\x70\x68\x6F\x74\x6F\x73\x68\x6F\x70\x3D\x22\x68\x74\x74\x70\x3A\x2F\x2F\x6E\x73\x2E\x61\x64\x6F\x62\x65\x2E\x63\x6F\x6D\x2F\x70\x68\x6F\x74\x6F\x73\x68\x6F\x70\x2F\x31\x2E\x30\x2F\x22\x20\x78\x6D\x6C\x6E\x73\x3A\x64\x63\x3D\x22\x68\x74\x74\x70\x3A\x2F\x2F\x70\x75\x72\x6C\x2E\x6F\x72\x67\x2F\x64\x63\x2F\x65\x6C\x65\x6D\x65\x6E\x74\x73\x2F\x31\x2E\x31\x2F\x22\x20\x78\x6D\x70\x3A\x43\x72\x65\x61\x74\x6F\x72\x54\x6F\x6F\x6C\x3D\x22\x41\x64\x6F\x62\x65\x20\x50\x68\x6F\x74\x6F\x73\x68\x6F\x70\x20\x32\x31\x2E\x31\x20\x28\x57\x69\x6E\x64\x6F\x77\x73\x29\x22\x20\x78\x6D\x70\x3A\x43\x72\x65\x61\x74\x65\x44\x61\x74\x65\x3D\x22\x32\x30\x32\x30\x2D\x31\x30\x2D\x32\x31\x54\x30\x33\x3A\x31\x38\x3A\x31\x39\x2B\x30\x33\x3A\x30\x30\x22\x20\x78\x6D\x70\x3A\x4D\x65\x74\x61\x64\x61\x74\x61\x44\x61\x74\x65\x3D\x22\x32\x30\x32\x30\x2D\x31\x30\x2D\x32\x31\x54\x30\x33\x3A\x31\x38\x3A\x31\x39\x2B\x30\x33\x3A\x30\x30\x22\x20\x78\x6D\x70\x3A\x4D\x6F\x64\x69\x66\x79\x44\x61\x74\x65\x3D\x22\x32\x30\x32\x30\x2D\x31\x30\x2D\x32\x31\x54\x30\x33\x3A\x31\x38\x3A\x31\x39\x2B\x30\x33\x3A\x30\x30\x22\x20\x78\x6D\x70\x4D\x4D\x3A\x49\x6E\x73\x74\x61\x6E\x63\x65\x49\x44\x3D\x22\x78\x6D\x70\x2E\x69\x69\x64\x3A\x63\x66\x63\x35\x66\x38\x63\x33\x2D\x37\x32\x31\x36\x2D\x63\x36\x34\x62\x2D\x39\x33\x37\x65\x2D\x65\x64\x30\x34\x38\x62\x63\x30\x35\x61\x61\x61\x22\x20\x78\x6D\x70\x4D\x4D\x3A\x44\x6F\x63\x75\x6D\x65\x6E\x74\x49\x44\x3D\x22\x61\x64\x6F\x62\x65\x3A\x64\x6F\x63\x69\x64\x3A\x70\x68\x6F\x74\x6F\x73\x68\x6F\x70\x3A\x39\x61\x34\x32\x35\x62\x39\x34\x2D\x61\x36\x62\x65\x2D\x61\x35\x34\x61\x2D\x62\x66\x36\x66\x2D\x32\x63\x32\x33\x33\x63\x31\x30\x64\x32\x39\x36\x22\x20\x78\x6D\x70\x4D\x4D\x3A\x4F\x72\x69\x67\x69\x6E\x61\x6C\x44\x6F\x63\x75\x6D\x65\x6E\x74\x49\x44\x3D\x22\x78\x6D\x70\x2E\x64\x69\x64\x3A\x34\x62\x36\x65\x36\x34\x65\x34\x2D\x65\x63\x38\x62\x2D\x37\x65\x34\x64\x2D\x61\x63\x66\x65\x2D\x65\x38\x31\x38\x66\x33\x34\x36\x65\x64\x61\x32\x22\x20\x70\x68\x6F\x74\x6F\x73\x68\x6F\x70\x3A\x43\x6F\x6C\x6F\x72\x4D\x6F\x64\x65\x3D\x22\x33\x22\x20\x64\x63\x3A\x66\x6F\x72\x6D\x61\x74\x3D\x22\x69\x6D\x61\x67\x65\x2F\x70\x6E\x67\x22\x3E\x20\x3C\x78\x6D\x70\x4D\x4D\x3A\x48\x69\x73\x74\x6F\x72\x79\x3E\x20\x3C\x72\x64\x66\x3A\x53\x65\x71\x3E\x20\x3C\x72\x64\x66\x3A\x6C\x69\x20\x73\x74\x45\x76\x74\x3A\x61\x63\x74\x69\x6F\x6E\x3D\x22\x63\x72\x65\x61\x74\x65\x64\x22\x20\x73\x74\x45\x76\x74\x3A\x69\x6E\x73\x74\x61\x6E\x63\x65\x49\x44\x3D\x22\x78\x6D\x70\x2E\x69\x69\x64\x3A\x34\x62\x36\x65\x36\x34\x65\x34\x2D\x65\x63\x38\x62\x2D\x37\x65\x34\x64\x2D\x61\x63\x66\x65\x2D\x65\x38\x31\x38\x66\x33\x34\x36\x65\x64\x61\x32\x22\x20\x73\x74\x45\x76\x74\x3A\x77\x68\x65\x6E\x3D\x22\x32\x30\x32\x30\x2D\x31\x30\x2D\x32\x31\x54\x30\x33\x3A\x31\x38\x3A\x31\x39\x2B\x30\x33\x3A\x30\x30\x22\x20\x73\x74\x45\x76\x74\x3A\x73\x6F\x66\x74\x77\x61\x72\x65\x41\x67\x65\x6E\x74\x3D\x22\x41\x64\x6F\x62\x65\x20\x50\x68\x6F\x74\x6F\x73\x68\x6F\x70\x20\x32\x31\x2E\x31\x20\x28\x57\x69\x6E\x64\x6F\x77\x73\x29\x22\x2F\x3E\x20\x3C\x72\x64\x66\x3A\x6C\x69\x20\x73\x74\x45\x76\x74\x3A\x61\x63\x74\x69\x6F\x6E\x3D\x22\x73\x61\x76\x65\x64\x22\x20\x73\x74\x45\x76\x74\x3A\x69\x6E\x73\x74\x61\x6E\x63\x65\x49\x44\x3D\x22\x78\x6D\x70\x2E\x69\x69\x64\x3A\x63\x66\x63\x35\x66\x38\x63\x33\x2D\x37\x32\x31\x36\x2D\x63\x36\x34\x62\x2D\x39\x33\x37\x65\x2D\x65\x64\x30\x34\x38\x62\x63\x30\x35\x61\x61\x61\x22\x20\x73\x74\x45\x76\x74\x3A\x77\x68\x65\x6E\x3D\x22\x32\x30\x32\x30\x2D\x31\x30\x2D\x32\x31\x54\x30\x33\x3A\x31\x38\x3A\x31\x39\x2B\x30\x33\x3A\x30\x30\x22\x20\x73\x74\x45\x76\x74\x3A\x73\x6F\x66\x74\x77\x61\x72\x65\x41\x67\x65\x6E\x74\x3D\x22\x41\x64\x6F\x62\x65\x20\x50\x68\x6F\x74\x6F\x73\x68\x6F\x70\x20\x32\x31\x2E\x31\x20\x28\x57\x69\x6E\x64\x6F\x77\x73\x29\x22\x20\x73\x74\x45\x76\x74\x3A\x63\x68\x61\x6E\x67\x65\x64\x3D\x22\x2F\x22\x2F\x3E\x20\x3C\x2F\x72\x64\x66\x3A\x53\x65\x71\x3E\x20\x3C\x2F\x78\x6D\x70\x4D\x4D\x3A\x48\x69\x73\x74\x6F\x72\x79\x3E\x20\x3C\x70\x68\x6F\x74\x6F\x73\x68\x6F\x70\x3A\x54\x65\x78\x74\x4C\x61\x79\x65\x72\x73\x3E\x20\x3C\x72\x64\x66\x3A\x42\x61\x67\x3E\x20\x3C\x72\x64\x66\x3A\x6C\x69\x20\x70\x68\x6F\x74\x6F\x73\x68\x6F\x70\x3A\x4C\x61\x79\x65\x72\x4E\x61\x6D\x65\x3D\x22\x50\x65\x72\x73\x6F\x6E\x61\x6C\x20\x53\x6B\x69\x6E\x20\x43\x68\x61\x6E\x67\x65\x72\x22\x20\x70\x68\x6F\x74\x6F\x73\x68\x6F\x70\x3A\x4C\x61\x79\x65\x72\x54\x65\x78\x74\x3D\x22\x50\x65\x72\x73\x6F\x6E\x61\x6C\x20\x53\x6B\x69\x6E\x20\x43\x68\x61\x6E\x67\x65\x72\x22\x2F\x3E\x20\x3C\x2F\x72\x64\x66\x3A\x42\x61\x67\x3E\x20\x3C\x2F\x70\x68\x6F\x74\x6F\x73\x68\x6F\x70\x3A\x54\x65\x78\x74\x4C\x61\x79\x65\x72\x73\x3E\x20\x3C\x2F\x72\x64\x66\x3A\x44\x65\x73\x63\x72\x69\x70\x74\x69\x6F\x6E\x3E\x20\x3C\x2F\x72\x64\x66\x3A\x52\x44\x46\x3E\x20\x3C\x2F\x78\x3A\x78\x6D\x70\x6D\x65\x74\x61\x3E\x20\x3C\x3F\x78\x70\x61\x63\x6B\x65\x74\x20\x65\x6E\x64\x3D\x22\x72\x22\x3F\x3E\xBB\xF2\x07\x5F\x00\x00\x07\x12\x49\x44\x41\x54\x78\xDA\xED\x5D\xED\x75\xAE\x20\x0C\xEE\x0A\xAE\xE0\x0A\xAE\xC0\x0A\xEF\x0A\xAE\xC0\x0A\xAE\xE0\x0A\xAE\xC0\x0A\xAE\xC0\x0A\xAC\xC0\x6D\x7B\xB0\xB5\x96\x84\x04\x83\xDA\x73\xC3\x39\xF9\xD3\x2A\x95\x87\x24\x0F\xF9\xD0\xBE\xC5\x18\xDF\x54\x54\x54\x54\x54\x54\x36\x51\x10\x54\x54\x54\x54\x54\x40\x62\xE8\xDF\xC5\x54\xC8\xF0\xA6\x43\xC7\x85\xE3\x5D\xE7\xBA\x8C\x1E\xF6\x8A\x4C\x15\x96\xBD\x62\xA9\xE3\xA0\x13\x3F\x88\xC1\xC6\x73\x63\x79\x97\x97\xC2\xAA\xA3\xA1\x03\x9B\xDF\x25\x10\xF4\xD0\xAA\x73\x43\x49\x75\x4C\x38\x61\x23\xA4\x6B\x46\x45\xED\x3F\x26\x86\xF4\x83\x35\x9E\x1F\x93\x42\xAB\x43\x58\x51\x6B\x0F\x2D\x1F\xFA\xEC\x34\xAA\xFD\xC2\xF1\x45\x20\xD6\xDC\xF0\x4A\x10\xFF\x37\x31\xB8\x28\x33\x8C\xC0\xA9\x66\x51\x83\xD6\x91\x4E\xB7\x67\x86\x57\x14\x3F\x71\x9C\x05\xEC\xFA\x93\x54\x14\xCD\xC7\x44\x7E\x4D\x7C\x24\x85\x18\x56\xA4\xB6\xF0\x71\xFA\x98\x80\x13\xC8\x94\xE6\x33\x12\x04\x53\x39\x8F\x2F\x85\xC2\x29\x3D\x61\x01\x42\xF4\x9C\xB4\xC4\x21\x44\xF7\x19\x83\x72\x69\xAE\x0E\xB8\xDF\x70\x89\x16\x39\x49\x1B\xE4\x39\x4D\x2D\xA1\x23\xF7\xBA\x86\x06\x90\xC3\x72\x4E\x58\x6F\xBA\x68\x91\x34\xD3\xB8\x9B\xCB\x51\xD6\x5D\x38\x20\x39\x2A\x16\xC8\x3C\x0E\x59\xAF\x38\xBE\x85\x88\x6B\x4D\xBF\xDF\xDB\xB5\x45\xB2\x07\x13\x17\xCF\xDA\xEB\x05\xF4\xB5\x39\xFE\xC9\xEE\x37\x1F\x12\x00\xBB\x9F\x12\xAE\x1D\x73\x7D\xB7\xF8\x48\x0A\x31\x38\x82\xD2\x99\x82\x71\x4C\x12\x91\xC7\xC9\x79\x66\xE0\x24\xCA\x09\xAB\x17\x28\x2D\xC1\x0C\xD1\x3F\xAE\xB3\x00\x96\x13\xB0\x79\x1D\xA2\x94\xC7\x61\x09\x7B\x36\x51\x30\x22\xDE\x0B\x3E\x9F\x00\x29\x0C\x15\xCE\x60\xBF\xAF\x9E\x30\x9F\x25\x3A\xD2\x90\x31\xA0\xDC\x75\x5D\x61\x7F\xD0\x3D\x92\xC6\x37\x1D\x7E\x20\xA7\x60\x08\xF7\x3A\xE8\x59\xB8\xFA\x77\xB5\xBE\xB6\xC6\x3F\xED\x3F\x37\x35\x17\x88\xEB\xBB\xCD\x47\x8A\x10\x03\xC0\xB2\x4E\x20\x3F\x7C\x5C\xF4\xD9\xE2\xF8\x70\x70\xE4\xB5\xA1\x74\x27\x94\xEA\x98\x19\x27\xBB\x15\x51\x4E\x76\x1A\x0F\x38\x49\x05\x62\x64\x64\x2F\x8C\x16\x0C\xB6\x8F\x04\x87\x30\x72\xF1\x02\x8C\x6B\x05\x0E\x04\xBF\x9E\x8F\x78\x02\x8D\x50\x24\x2B\x8D\x2F\x90\x42\x62\x91\xCD\x4E\x5F\xCC\x59\xFD\xBB\x41\x5F\xC5\xF1\x4F\xFA\x55\x9B\x76\xB7\x0C\xBB\xBF\xC5\x47\x4A\x45\x0C\x96\x49\x0C\x2B\xA1\x05\xF6\x45\x58\x34\x36\xCF\x84\x6D\x48\x26\x4C\xF6\xE9\x9E\x63\x38\xBD\x1C\x4E\x04\x36\x13\x29\x94\xC2\xF3\x11\xC9\xEF\x5A\x66\xC8\xDF\x09\x18\xA6\xE1\x90\xD5\x03\x89\x61\x4B\x25\xD9\x9A\x76\x69\x24\x14\xEF\x80\xF4\x89\xE3\xA4\xFF\x18\x8E\x09\x22\x2E\x69\x62\x08\x67\x6B\x80\x9B\x1E\x4B\x38\xFA\x1B\xF4\x55\x1C\x7F\xA4\xA3\x6B\x9F\xE2\xCC\xA5\xE4\x02\x60\xC3\x8F\xF2\x91\x14\x62\xF0\xE9\x8F\x41\xE2\x4A\x0E\xAF\x56\xD1\x53\xD8\xDF\xD5\xCE\x93\x31\x72\x0B\x28\x0B\x7A\x7A\x4A\x0E\xC3\x03\xD1\x82\xA7\x86\xA9\x69\x3D\x39\x23\xED\x19\x8C\xBF\x66\x9E\x41\x2A\xEF\xFA\xEB\x79\x1E\x40\x0C\x1D\x33\x9A\xFB\xCA\xE7\x72\x1C\x53\x92\xC0\x75\x3C\x02\xC4\x10\x09\xE9\x29\x77\x02\xBF\x5C\xEA\x6C\x15\xDE\xA3\xD6\xC4\x70\x56\x5F\x45\xF1\x07\x88\x6A\xC5\x0E\x28\xBB\x7B\x66\x49\x9B\x6A\xE5\x23\x5B\x75\x25\x85\x9A\x87\x4D\x4C\xEB\x24\x1C\x52\x72\x28\x81\x48\x0C\x1B\xD3\xBF\x90\xA2\x59\x7F\xDC\x78\x6A\xBE\x9A\xA0\x54\x96\x19\x0A\xAE\xB5\x86\x86\x9C\xC0\x39\xCE\xF0\x32\x62\x38\xD9\x4D\x13\x72\x04\x01\xEC\x3D\x39\xD5\xD0\x80\x18\xE2\xFE\x39\x85\x89\xC1\x60\xC5\xE3\x46\xC4\x60\x0B\x27\xDD\xAB\xF5\x55\x14\xFF\x4C\xB4\x10\x28\x69\xB9\xB4\x96\xEE\x8C\x4D\x5D\xE5\x23\x5B\x10\x83\xCF\x38\x50\x56\xDE\x8B\xB1\xE8\xED\x84\x98\x93\x52\x8D\xC1\x33\x4E\xA0\x5B\x78\xD8\x71\x0A\x8F\x0C\x96\x5E\x0A\x6B\x2C\x15\x8A\x38\x86\xE6\x32\x4E\xD1\x32\xE7\xB8\x9A\x18\xBA\x58\x7E\x19\x8B\x64\xF4\x0C\x47\x31\xD7\x3A\x5E\x82\x63\x0A\xC0\xCF\x86\x8B\x88\xC1\x36\x26\x86\xEA\x1C\x79\x23\x7D\x15\xC5\x3F\x73\xFF\x04\x3C\xF7\x22\xD4\x35\x76\xB9\x8F\x94\x22\x86\xAF\x96\x27\x62\xFE\x4C\x6A\xD1\x9C\xE1\x04\xE6\xF2\x07\x72\xA9\x0D\xFF\x2C\xA3\x1E\xE3\x90\xE2\xF6\xCC\x21\x06\xA0\x3B\xA5\x07\x4E\x0E\xEE\x29\xC4\x70\x88\xD0\xA6\xC8\x7F\x09\xD3\x57\x3A\x32\xD3\x88\x18\x5E\xC0\x1A\x42\x5A\x63\x6B\x62\x58\xFE\x02\x31\x08\xEA\xAB\x28\xFE\x94\xE7\x27\xFA\x51\xFB\x54\x1F\x19\xA5\xBA\x92\x6E\x62\x43\xAA\x33\xB7\x92\xAD\x66\x1B\xF9\xE5\x0A\x3D\x44\x3C\x26\x0E\x31\x14\x3A\x9F\x66\x86\xA1\xCD\x48\xD4\x61\x19\xF3\xDC\x42\x0C\x00\x51\xEC\x8B\x7C\x33\x12\x09\x0E\x15\x8E\x2C\x94\x0A\xDB\x95\xC4\x60\x90\x42\x77\xC8\x44\x47\x67\x88\xA1\x2B\xA5\x7A\x19\xF3\x0C\x17\x13\x83\x94\xBE\x8A\xE2\x2F\x44\x0C\xCB\x93\x7D\xE4\x5D\xC4\x00\x55\xCA\x67\xE6\xA2\x8F\x85\xF1\xF5\x44\xEE\xCF\xEE\xBA\x90\x5C\x61\x63\x47\xC4\x59\x53\xDA\xE7\x3C\x23\x95\x54\xF3\x3E\x88\x21\x9E\xBE\xD6\xDD\x5A\xD7\x52\x94\x75\x63\x2A\xC9\x70\x3A\x69\x00\x9C\x4C\xC1\x91\xCD\x11\x6E\x53\xED\xA4\x89\x61\xB7\x27\x94\x83\xC9\xD9\xAE\xA4\xF5\x6C\x9D\x21\x7E\xBF\x3C\xD8\x5F\x51\x7C\x16\xD6\x57\x51\xFC\x19\xA9\xA4\x80\xA4\x6E\xEC\x93\x7D\xE4\x5D\xC4\xE0\x5A\xCC\x03\x74\xFD\x2C\xC8\x7C\x4B\xA4\xBD\xE0\x03\x15\x68\x7A\x6E\x98\x0E\x30\xBA\x65\xAC\x71\xAE\x24\x86\xDA\x02\xAE\x79\x00\x31\xB8\x9D\xB1\x50\x88\x77\x64\x12\x83\x2D\xB4\x21\xBA\x16\xC4\x50\xE8\x54\x93\x24\x86\xB1\x94\xCA\x60\xE8\xAC\xBB\x88\x18\x24\xF5\x55\x14\x7F\xA0\xF8\x3C\x64\x30\x37\xC8\x73\xD8\x27\xFB\xC8\x47\x13\x43\x4A\x11\x4C\x9C\x79\x00\x23\xB0\x88\x41\xFB\x88\xB7\x36\x0E\x85\xEE\xA6\x5C\x64\xB1\x30\x6A\x2D\xEC\x0E\x2E\x82\xD1\x18\xC2\xE9\x0B\x2A\x48\x85\x52\x7A\xAC\x66\x3F\xD3\x3D\x53\x85\xEE\xF4\xC0\xE9\xFE\x05\xA4\x3B\xA0\xF4\x60\x47\x74\x14\x50\x8A\x61\x6E\x41\x0C\x44\xE7\x24\x61\x83\x50\x5D\xC6\x21\x58\x8E\x91\xD0\x8E\x2D\x4D\x0C\x0D\xF4\x55\x14\xFF\x08\x77\x4A\x8D\x8C\x03\x84\x7D\xB2\x8F\xBC\x8B\x18\x4A\xEF\x46\xD8\x9D\x81\x3B\x2E\x78\x44\x46\x9F\x81\xEA\xFD\x14\xCB\xEF\x68\x0C\x04\xA5\xDA\x72\x95\xA5\xDC\x77\x55\x0F\x7B\x81\x1C\x0C\x35\x57\x4B\x4C\xC3\x8C\x02\xFB\x19\x6A\x74\x89\x40\x82\x5B\x7A\x01\xEB\x32\x9B\x84\x1C\xC5\xD8\x82\x18\x08\xCE\x49\xC2\x06\x29\x69\x13\x47\xC0\xF2\x53\xB7\x1B\x13\x83\xB4\xBE\x8A\xE3\x8F\xE8\xA5\xDF\x75\x4E\x6D\xA9\x69\x0F\xF8\x07\xF3\x54\x1F\xF9\xC8\xE2\x33\xB7\x30\x4B\x2C\xB8\xAD\x85\xDF\x53\xC7\xCC\x54\xAA\x58\xAA\x55\xD4\x9E\x1C\x10\xE5\x34\x85\xD3\xD7\xC0\x3C\xA1\x7B\xA1\xFD\xAC\x21\x86\x58\x89\xED\xDE\xD9\x75\x15\x8E\xE2\x45\x24\x5D\x11\x62\x28\xE8\x91\x48\xAA\x0E\x89\x86\x38\x58\xBE\x0A\x29\x92\x53\xC4\xD0\x48\x5F\x9B\xE0\x1F\xCF\x7D\xAD\xD6\x47\xB9\x4F\x59\xB4\xF0\x91\xBF\xFE\x83\x5B\xE0\x84\x48\x44\x65\x5C\xCE\x2E\x1A\x98\x27\x20\x85\x2B\x0F\xA4\x78\xFA\xF8\xFD\x45\xD5\x39\x0A\x7C\xF8\x6E\xF7\x37\x67\x86\x81\x19\x22\x56\x1E\xCB\xAB\x03\x51\xCD\x9C\xE6\xEA\x01\xEC\x4D\x61\x1D\x1E\x99\xF3\xCC\x7E\x9E\xE9\xAE\x19\x23\xAF\x95\xDA\x17\x52\x88\xBF\xD6\x46\xC4\x36\xA4\x67\xD9\xB0\x98\x0B\x8E\x8E\xF5\x1E\x01\x92\xA6\x30\x6F\x42\x03\x49\x11\xB1\xF4\x95\x8B\x67\xE9\xFA\x46\xFA\xDA\x14\xFF\x44\x94\x1C\x2C\x73\x5F\x32\x7D\xA2\x8F\xFC\x41\x0C\x23\x94\xCB\x3B\xD9\x52\xE8\x2A\x25\xEC\x16\x0D\xCD\x33\x21\x4E\x24\x27\x23\xD2\x95\x34\x67\xAE\xB7\x11\xF8\x5C\x2E\xA2\xA8\xB9\xB9\xB6\xB4\xD2\x50\x81\xD5\x58\x08\xA5\x73\xF7\x0C\x08\x0E\x13\xC1\x01\x43\x73\x0E\x67\xF7\x52\x20\x25\x32\xEE\x52\x7D\x39\x8C\x4D\x0D\x5E\x00\x31\xD4\x60\x31\x95\xFE\x5E\x85\x0E\x88\xFF\xF3\xAB\xF8\xDD\xB3\x9F\xD3\xFB\x2D\x1D\x52\xFA\xDC\x04\x19\xCF\x9B\xF4\xF5\x12\xFC\x77\x3E\x64\x01\x74\xF2\x85\x90\xE5\xE3\x7C\xE4\xAF\x54\xD2\x93\x46\xCC\x7C\x86\x42\xC7\xDF\x1C\xBA\x97\x3A\x74\xFC\x1D\xBB\x3A\x46\x0C\x2A\x2A\x2A\x2A\x2A\x2A\x4A\x0C\x2A\x2A\x2A\x2A\x2A\x3F\xE5\x1F\xE9\x56\xBF\x6D\xDC\xA8\x24\x96\x00\x00\x00\x00\x49\x45\x4E\x44\xAE\x42\x60\x82"

function imgui.ButtonDisabled(...)
    imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.10, 0.10, 0.10, 1.00/2) )
    imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.10, 0.10, 0.10, 1.00/2))
    imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.10, 0.10, 0.10, 1.00/2))
    imgui.PushStyleColor(imgui.Col.Text, imgui.GetStyle().Colors[imgui.Col.TextDisabled])
		local result = imgui.Button(...)
    imgui.PopStyleColor(4)
    return result
end

function imgui.CenterText(text) -- by https://www.blast.hk/threads/13380/post-291217
    local width = imgui.GetWindowWidth()
    local style = imgui.GetStyle()
    local render_text = function(text_)
        for w in text_:gmatch('[^\r\n]+') do
            local textsize = w:gsub('{.-}', '')
            local text_width = imgui.CalcTextSize(textsize)
            imgui.SetCursorPosX( width / 2 - text_width .x / 2 )
            local text, colors_, m = {}, {}, 1
            w = w:gsub('{(......)}', '{%1FF}')
            while w:find('{........}') do
                local n, k = w:find('{........}')
                w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
            end
            if text[0] then
                for i = 0, #text do
                    imgui.TextColored(colors_[i] or colors[1], (text[i]))
                    imgui.SameLine(nil, 0)
                end
                imgui.NewLine()
            else
                imgui.Text(w)
            end
        end
    end
    render_text(text)
end

function imgui.Linkk(link)
    if status_hovered then
        local p = imgui.GetCursorScreenPos()
        imgui.TextColored(imgui.ImVec4(0, 0.5, 1, 1), link)
        imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x, p.y + imgui.CalcTextSize(link).y), imgui.ImVec2(p.x + imgui.CalcTextSize(link).x, p.y + imgui.CalcTextSize(link).y), imgui.GetColorU32(imgui.ImVec4(0, 0.5, 1, 1)))
    else
        imgui.TextColored(imgui.ImVec4(0, 0.3, 0.8, 1), link)
    end
    if imgui.IsItemClicked() then os.execute('explorer '..link)
    elseif imgui.IsItemHovered() then
        status_hovered = true else status_hovered = false
    end
end

-- https://github.com/juliettef/imgui_markdown/blob/master/imgui_markdown.h#L230
local function imgui_text_wrapped(clr, text)
    if clr then imgui.PushStyleColor(ffi.C.ImGuiCol_Text, clr) end

    text = ffi.new('char[?]', #text + 1, text)
    local text_end = text + ffi.sizeof(text) - 1
    local pFont = imgui.GetFont()

    local scale = 1.0
    local endPrevLine = pFont:CalcWordWrapPositionA(scale, text, text_end, imgui.GetContentRegionAvail().x)
    imgui.TextUnformatted(text, endPrevLine)

    while endPrevLine < text_end do
        text = endPrevLine
        if text[0] == 32 then text = text + 1 end
        endPrevLine = pFont:CalcWordWrapPositionA(scale, text, text_end, imgui.GetContentRegionAvail().x)
        if text == endPrevLine then
            endPrevLine = endPrevLine + 1
        end
        imgui.TextUnformatted(text, endPrevLine)
    end

    if clr then imgui.PopStyleColor() end
end

-- https://blast.hk/threads/13380/post-231049
local function split(str, delim, plain)
	local tokens, pos, i, plain = {}, 1, 1, not (plain == false)
	repeat
		local npos, epos = string.find(str, delim, pos, plain)
		tokens[i] = string.sub(str, pos, npos and npos - 1)
		pos = epos and epos + 1
		i = i + 1
	until not pos
	return tokens
end

-- https://fishlake-scripts.ru/threads/8/post-24
local function imgui_text_color(text, wrapped)
	local style = imgui.GetStyle()
	local colors = style.Colors

	text = text:gsub('{(%x%x%x%x%x%x)}', '{%1FF}')
	local render_func = wrapped and imgui_text_wrapped or function(clr, text)
		if clr then imgui.PushStyleColor(ffi.C.ImGuiCol_Text, clr) end
		imgui.TextUnformatted(text)
		if clr then imgui.PopStyleColor() end
	end

	local color = colors[ffi.C.ImGuiCol_Text]
	for _, w in ipairs(split(text, '\n')) do
		local start = 1
		local a, b = w:find('{........}', start)
		while a do
			local t = w:sub(start, a - 1)
			if #t > 0 then
				render_func(color, t)
				imgui.SameLine(nil, 0)
			end

			local clr = w:sub(a + 1, b - 1)
			if clr:upper() == 'STANDART' then color = colors[ffi.C.ImGuiCol_Text]
			else
				clr = tonumber(clr, 16)
				if clr then
					local r = bit.band(bit.rshift(clr, 24), 0xFF)
					local g = bit.band(bit.rshift(clr, 16), 0xFF)
					local b = bit.band(bit.rshift(clr, 8), 0xFF)
					local a = bit.band(clr, 0xFF)
					color = imgui.ImVec4(r / 255, g / 255, b / 255, a / 255)
				end
			end

			start = b + 1
			a, b = w:find('{........}', start)
		end
		imgui.NewLine()
		if #w >= start then
			imgui.SameLine(nil, 0)
			render_func(color, w:sub(start))
		end
	end
end

main_window = imgui.new.bool(false) -- основное окно, по-умолчанию выключено
local autoupdateState = config.settings.autoupdate -- автообновление
local autoupdateStatev = imgui.new.bool(config.settings.autoupdate) -- тоже автообновление
changelog_window_state = imgui.new.bool(false) -- окно истории изменений
local nick = imgui.new.char[128]('')
local idskin = imgui.new.char[128]('')
local cmdbuffer = imgui.new.char[128](config.settings.cmd)
local combo = imgui.new.int(0)
fAlpha = 0.00

imgui.OnFrame(function() return main_window[0] and isSampfuncsLoaded() and isSampLoaded() and not isPauseMenuActive() and not sampIsScoreboardOpen() end,
function(one)
	imgui.PushStyleVarFloat(imgui.StyleVar.Alpha, fAlpha)
	local sizeX, sizeY = getScreenResolution()
	imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 1.3, sizeY / 1.7), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))    
  	imgui.SetNextWindowSize(imgui.ImVec2(400, 460), imgui.Cond.FirstUseEver)
	imgui.Begin(fa.ICON_FA_ID_BADGE .. ' ##mimgui ', main_window, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove)
	imgui.Separator()
	imgui.SetCursorPosX((imgui.GetWindowWidth() - 374) / 2)  
	imgui.Image(logo, imgui.ImVec2(374, 28))
	if imgui.IsItemHovered() then
		imgui.BeginTooltip()
		imgui.PushTextWrapPos(600)
		imgui.TextUnformatted(fa.ICON_FA_COPYRIGHT .. "dmitriyewich aka Валерий Дмитриевич.\nРаспространение допускается только с указанием автора или ссылки на пост в вк")
		imgui.PopTextWrapPos()
		imgui.EndTooltip()
	end	
	imgui.Separator()
	imgui.Text(' Введите ник')
	imgui.SameLine()
	imgui.PushItemWidth(174)
	local buffer_size = ffi.sizeof(nick)
	imgui.InputTextWithHint('##Введите ник3', 'Nick_Name', nick, ffi.sizeof(nick) - 1, imgui.InputTextFlags.AutoSelectAll)
	imgui.PopItemWidth()
	imgui.SameLine()
	imgui.Text('ID skin')
	imgui.SameLine()
	imgui.PushItemWidth(47)
	imgui.InputTextWithHint('##ID skin', '74', idskin, ffi.sizeof(idskin) - 1, imgui.InputTextFlags.CharsDecimal + imgui.InputTextFlags.AutoSelectAll)
	imgui.PopItemWidth()
	local allChars, SkinsRaius = getAllChars(), {}	-- функция получение идов и ников игроков в радиусе от игрока
	local radius = 25 --Радиус действия, по умолчанию - 25 метров
    local myPosX, myPosY, myPosZ = getCharCoordinates(PLAYER_PED)
    for _, ped in ipairs(allChars) do
        local result, id = sampGetPlayerIdByCharHandle(ped)
        if result and getDistanceBetweenCoords3d(myPosX, myPosY, myPosZ, getCharCoordinates(ped)) < radius then
            table.insert(SkinsRaius, tostring(sampGetPlayerNickname(id)))
			SkinsRaiusTable = imgui.new['const char*'][#SkinsRaius](SkinsRaius)
        end
    end
	imgui.PushItemWidth(200)
	imgui.Text(' Ближайший игрок')
	imgui.SameLine()
	if imgui.Combo('##Ближайший игрок', combo, SkinsRaiusTable, #SkinsRaius) then -- выбор игрока в радиусе от игрока
		for i = 0, #SkinsRaius do
			if combo[0] == i then
					nickcombo = SkinsRaius[i + 1]
					imgui.StrCopy(nick, ''..nickcombo)
			end
		end
	end
	imgui.SameLine()
	imgui.TextQuestion(fa.ICON_FA_QUESTION .. " ", "Выбрав ник он автоматически вставится в окно ввода ника\nНики выводятся из игроков находящихся в радиусе 25 метров")	
	imgui.PopItemWidth()		
	imgui.SetCursorPosX((imgui.GetWindowWidth() - 370) / 2)
	if imgui.Button('Привязать скин к имени', imgui.ImVec2(370, 30)) then
		config.skins[ffi.string(nick)] = ffi.string(idskin) -- запоминание привязанного ника к иду
		if ffi.string(nick) ~= nil and ffi.string(idskin) ~= nil then
			if not config.skinslast[ffi.string(nick)] then
				if ffi.string(nick) == sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))) then
					modelId = getCharModel(PLAYER_PED)
					config.skinslast[ffi.string(nick)] = modelId -- запоминание начального скина у игрока до привязки
				end
				if ffi.string(nick) ~= sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))) then
					nameid = sampGetPlayerIdByNickname(ffi.string(nick))
					result, pped = sampGetCharHandleBySampPlayerId(nameid)
					if result then
						mid = getCharModel(pped)
						config.skinslast[ffi.string(nick)] = mid -- запоминание начального скина у другого игрока до привязки
					end
				end
			end
			savejson(convertTableToJsonString(config), "moonloader/config/PersonalSkinChanger.json") -- сохранение в конфиг json привязанного ника к иду			
			lua_thread.create(function() saveskintext = ""..(ffi.string(nick))..' - '..(ffi.string(idskin))..' успешно сохранено'; wait(2574); saveskintext = ''; end)
			for k, v in pairs(config.skins) do
				local nametoid = sampGetPlayerIdByNickname(k)
				changeSkin(nametoid, v)
			end
		else
			lua_thread.create(function() saveskintext = 'Введи свой никнейм или другого игрока и ID скина!'; wait(2574); saveskintext = ''; end)	
		end	
	end
	imgui.CenterText(""..saveskintext)
	if imgui.CollapsingHeader('Привязанные скины') then
		for q, w in pairs(config.skins) do
			imgui.CenterText(""..q.. ' - Скин: '..w)
			if imgui.IsItemClicked(1) then -- ПКМ - Отвязать скин от ника
				config.skins[q] = nil
			for k, v in pairs(config.skinslast) do
				local nametoid = sampGetPlayerIdByNickname(k)
				changeSkin(nametoid, v)
			end		
				config.skinslast[q] = nil
			for k, v in pairs(config.skins) do
				local nametoid = sampGetPlayerIdByNickname(k)
				changeSkin(nametoid, v)
			end				
				savejson(convertTableToJsonString(config), "moonloader/config/PersonalSkinChanger.json")				
			end 			
			if imgui.IsItemHovered() then
				imgui.BeginTooltip()
				imgui.PushTextWrapPos(600)
				imgui.TextUnformatted("ЛКМ - Скопировать ник\nПКМ - Отвязать скин от ника\nПри отвязке вернется последний скин перед привязкой.")
				imgui.PopTextWrapPos()
				imgui.EndTooltip()
			end
			if imgui.IsItemClicked(0) then
				imgui.LogToClipboard()
				imgui.LogText(q)
				imgui.LogFinish()
			end 
		end
	end	
	
	if imgui.CollapsingHeader('Предпросмотр скинов') then
		if imgui.CollapsingHeader('Стандартные скины') then
		local standartskin = 1 
			for i = 1, 311, 1 do
				if isModelInCdimage(i) then
					if imgui.Button(""..i, imgui.ImVec2(31.5, 30)) then
						testtextdraw(i)		
					end					
				else
					imgui.ButtonDisabled(""..i, imgui.ImVec2(31.5, 30))
				end	
				if standartskin % 9 ~= 0 and standartskin ~= 311 then
					imgui.SameLine()
				end
				standartskin = standartskin + 1				
			end		
		end
		
		if imgui.CollapsingHeader('Новые скины') then
		listedNotDuplicate = {}
		notduplicate = {}
		for _, v in pairs(config.skins) do
			if not listedNotDuplicate[v] then
				table.insert(notduplicate, v)
				listedNotDuplicate[v] = true
			end      
		end
		table.sort(notduplicate)		
			if imgui.IsItemHovered() then
				imgui.BeginTooltip()
				imgui.PushTextWrapPos(600)
					imgui.TextUnformatted("Добавляются при привязке скина к нику\nНезанятые иды можно посмотреть по кнопке в истории изменений\n" .. fa.ICON_FA_BOLT .. "Необходимо учесть, что без Open Limit Adjuster или fastman92 limit adjuster под скины можно использовать только с 1 по 799 ид(которые не заняты)")
				imgui.PopTextWrapPos()
				imgui.EndTooltip()
			end
		local newskin = 1
		for k, v in pairs(notduplicate) do
			if tonumber(v) >= 312 then 
				index = tonumber(v)
				
					if isModelInCdimage(index) then
						if imgui.Button(""..index, imgui.ImVec2(30, 30)) then
							testtextdraw(index)
						end
					else
						imgui.ButtonDisabled(""..index, imgui.ImVec2(30, 30))
					end	
					if newskin % 9 ~= 0 then
						imgui.SameLine()
					end
					newskin = newskin + 1				
				end
			end
			imgui.Text('')
		end
	end	
	
	if imgui.CollapsingHeader('Настройки') then
		if config.settings.autoupdate == true then updatestatusonof = 'Включено' else updatestatusonof = 'Выключено' end
		imgui.SetCursorPosX((imgui.GetWindowWidth() - 200) / 2)		
		imgui.Text(string.format("Автообновление: %s", updatestatusonof))
		imgui.SameLine()
		if TBDonHomka.ToggleButton("Test2##2", autoupdateStatev) then 
			config.settings.autoupdate = not config.settings.autoupdate
			if config.settings.autoupdate then 
				config.settings.autoupdate = true
				savejson(convertTableToJsonString(config), "moonloader/config/PersonalSkinChanger.json")
				autoupdate(updlink,'##nil',updlink)		
			else 
				config.settings.autoupdate = false
				updatestatustest = ''					
				savejson(convertTableToJsonString(config), "moonloader/config/PersonalSkinChanger.json")	
			end 
		end
		
		local buffer_size = ffi.sizeof(cmdbuffer)
		imgui.SetCursorPosX((imgui.GetWindowWidth() - 230) / 2)
		imgui.PushItemWidth(100)
		if imgui.InputText('', cmdbuffer, buffer_size - 1, imgui.InputTextFlags.AutoSelectAll) then
			config.settings.cmd = ffi.string(cmdbuffer)
            -- savejson(convertTableToJsonString(config), "moonloader/config/PersonalSkinChanger.json")	
        end
			if imgui.IsItemHovered() then
				imgui.BeginTooltip()
				imgui.PushTextWrapPos(600)
					imgui.TextUnformatted('Чтобы изменить команду активации\nвведите команду без "/"')
				imgui.PopTextWrapPos()
				imgui.EndTooltip()
			end		
		imgui.PopItemWidth() 
        imgui.SameLine()
        if imgui.Button('Сохранить команду', imgui.ImVec2(130, 0)) then
			config.settings.cmd = ffi.string(cmdbuffer)
			savejson(convertTableToJsonString(config), "moonloader/config/PersonalSkinChanger.json")
			sampUnregisterChatCommand('fskin')
			sampRegisterChatCommand(config.settings.cmd, function() main_window[0] = not main_window[0] end)
        if ffi.string(cmdbuffer) == nil or ffi.string(cmdbuffer) == '' or ffi.string(cmdbuffer) == ' ' or ffi.string(cmdbuffer):find('/.+') then
				changecmdtext = 'Поле ввода пустое или содержит символ "/"\nВведите команду без "/" '
				config.settings.cmd = 'fskin'
				savejson(convertTableToJsonString(config), "moonloader/config/PersonalSkinChanger.json")
			else
				changecmdtext = ''
			end
        end
		imgui.CenterText(""..changecmdtext)
		imgui.SetCursorPosX((imgui.GetWindowWidth() - 325) / 2)
		if imgui.Button('История\nизменений', imgui.ImVec2(100, 0)) then
			changelog_window_state[0] = not changelog_window_state[0]
		end
		imgui.SameLine()
		if imgui.Button('Проверить\nобновление', imgui.ImVec2(100, 0)) then
			autoupdate(updlink,'##nil',updlink)
		end	
			if imgui.IsItemHovered() then
				imgui.BeginTooltip()
				imgui.PushTextWrapPos(600)
					imgui.TextUnformatted("Нужно будет заново прописать команду активации скрипта")
				imgui.PopTextWrapPos()
				imgui.EndTooltip()
			end				
		imgui.SameLine()
		if imgui.Button('Перезапустить\nскрипт', imgui.ImVec2(100, 0)) then
			savejson(convertTableToJsonString(config), "moonloader/config/PersonalSkinChanger.json")
			thisScript():reload()
		end
			if imgui.IsItemHovered() then
				imgui.BeginTooltip()
				imgui.PushTextWrapPos(600)
					imgui.TextUnformatted("Нужно будет заново прописать команду активации скрипта")
				imgui.PopTextWrapPos()
				imgui.EndTooltip()
			end		
	end
	imgui.Separator()
	imgui.CenterText(""..updatestatustest)
		if imgui.IsItemClicked(0) then
			autoupdate(updlink,'##nil',updlink)
		end 			
		if imgui.IsItemHovered() then
			imgui.BeginTooltip()
			imgui.PushTextWrapPos(600)
			imgui.TextUnformatted("ЛКМ - Проверить обновления\nПКМ - Открыть группу в вк")
			imgui.PopTextWrapPos()
			imgui.EndTooltip()
		end		
		if imgui.IsItemClicked(1) then
			os.execute('explorer "https://vk.com/dmitriyewichmods"') -- открытие браузера с этой ссылкой
		end
			-- imgui.PopStyleColor()
		if not main_window[0] then 
			fAlpha = 0.00
		end
	imgui.End()
end)

	function Alpha()
		lua_thread.create(function()
			if main_window[0] or changelog_window_state[0] then 
				fAlpha = 0.00		
					repeat
						fAlpha = fAlpha + 0.05
						wait(7)
					until( fAlpha >= 1.00 )
				
			end
			if not main_window[0] then 
				fAlpha = 0.00
			end	
		end)	
	end
	
imgui.OnFrame(function() return changelog_window_state[0] and isSampfuncsLoaded() and isSampLoaded() and not isPauseMenuActive() and sampIsChatVisible() and not sampIsScoreboardOpen() end,
function(two)
	imgui.PushStyleVarFloat(imgui.StyleVar.Alpha, fAlpha)
	local sizeX, sizeY = getScreenResolution()
	imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))    
    imgui.SetNextWindowSize(imgui.ImVec2(400, 460), imgui.Cond.FirstUseEver, imgui.NoResize) 
	imgui.Begin(fa.ICON_FA_NEWSPAPER .. '##2', changelog_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse, imgui.WindowFlags.AlwaysUseWindowPadding) --  + imgui.WindowFlags.NoScrollbar
	imgui.SetCursorPosX((imgui.GetWindowWidth() - 374) / 2)  
	imgui.Image(logo, imgui.ImVec2(374, 28))
	-- imgui.SetScrollY(imgui.GetScrollMaxY())
	-- imgui.TextWrapped(''..changelog)
	imgui_text_color(''..changelog, true)
    if imgui.Link(fa.ICON_FA_LINK .. "Незанятые иды", "Файл откроется в браузере, ничего скачиваться не будет") then
        os.execute(('explorer.exe "%s"'):format(invalidID))
    end
	if changelog_window_state[0] == false then config.settings.changelog = false; savejson(convertTableToJsonString(config), "moonloader/config/PersonalSkinChanger.json"); end
	imgui.End()
end)	
function imgui.Link(label, description)
    local size = imgui.CalcTextSize(label)
    local p = imgui.GetCursorScreenPos()
    local p2 = imgui.GetCursorPos()
    local result = imgui.InvisibleButton(label, size)
    imgui.SetCursorPos(p2)
    if imgui.IsItemHovered() then
        if description then
            imgui.BeginTooltip()
            imgui.PushTextWrapPos(600)
            imgui.TextUnformatted(description)
            imgui.PopTextWrapPos()
            imgui.EndTooltip()
        end
        imgui.TextColored(imgui.ImVec4(0, 0.5, 1, 1), label)
    else
        imgui.TextColored(imgui.ImVec4(0, 0.3, 0.8, 1), label)
    end
    return result
end

function imgui.TextQuestion(label, description)
    imgui.TextDisabled(label)
    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
            imgui.PushTextWrapPos(600)
                imgui.TextUnformatted(description)
            imgui.PopTextWrapPos()
        imgui.EndTooltip()
    end
end

LastActiveTime = {}
LastActive = {}
TBDonHomka.ToggleButton = function(str_id, bool) --Toggle Button: by DonHomka mimgui_addons
	local rBool = false

	local function ImSaturate(f)
		return f < 0.0 and 0.0 or (f > 1.0 and 1.0 or f)
	end
	
	local p = imgui.GetCursorScreenPos()
	local draw_list = imgui.GetWindowDrawList()

	local height = imgui.GetTextLineHeightWithSpacing() * TBDonHomka._SETTINGS.ToggleButton.scale
	local width = height * 1.2
	local radius = height * 0.50

	if imgui.InvisibleButton(str_id, imgui.ImVec2(width + radius, height)) then
		bool[0] = not bool[0]
		rBool = true
		LastActiveTime[tostring(str_id)] = os.clock()
		LastActive[tostring(str_id)] = true
	end

	local t = bool[0] and 1.0 or 0.0

	if LastActive[tostring(str_id)] then
		local time = os.clock() - LastActiveTime[tostring(str_id)]
		if time <= TBDonHomka._SETTINGS.ToggleButton.AnimSpeed then
			local t_anim = ImSaturate(time / TBDonHomka._SETTINGS.ToggleButton.AnimSpeed)
			t = bool[0] and t_anim or 1.0 - t_anim
		else
			LastActive[tostring(str_id)] = false
		end
	end

	local col_bg = imgui.ColorConvertFloat4ToU32(TBDonHomka._SETTINGS.ToggleButton.colors[bool[0] and 3 or 4])

	draw_list:AddRectFilled(imgui.ImVec2(p.x + (radius * 0.65), p.y + (height / 6)), imgui.ImVec2(p.x + (radius * 0.65) + width, p.y + (height - (height / 6))), col_bg, 10.0)
	draw_list:AddCircleFilled(imgui.ImVec2(p.x + (radius * 1.3) + t * (width - (radius * 1.3)), p.y + radius), radius - 1.0, imgui.ColorConvertFloat4ToU32(TBDonHomka._SETTINGS.ToggleButton.colors[bool[0] and  1 or 2]))

	return rBool
end
end

function main()
	if not isSampfuncsLoaded() or not isSampLoaded() then return end
	while not isSampAvailable() do wait(0) end
	checklibs()
	if config.settings.autoupdate then
		autoupdate(updlink,'##nil',updlink)
	end	
	if config.settings.cmd == 'fskin' then
		sampRegisterChatCommand('fskin', function() main_window[0] = not main_window[0]; Alpha() end)
	else
		sampUnregisterChatCommand('fskin')
		sampRegisterChatCommand(config.settings.cmd, function() main_window[0] = not main_window[0]; Alpha() end)
	end	
	sampSetClientCommandDescription(config.settings.cmd, (string.format(u8:decode"Активация/деактивация окна %s, Файл: %s", thisScript().name, thisScript().filename)))
	
	if config.settings.changelog == true then 
		changelog_window_state[0] = true
	else
		changelog_window_state[0] = false
	end
	wait(-1)
end

function changeSkin(id, skinId)
	bs = raknetNewBitStream()
	if id == -1 then _, id = sampGetPlayerIdByCharHandle(PLAYER_PED) end
	raknetBitStreamWriteInt32(bs, id)
	raknetBitStreamWriteInt32(bs, skinId)
	raknetEmulRpcReceiveBitStream(153, bs)
	raknetDeleteBitStream(bs)
end

function testtextdraw(arg)
	arg = tonumber(arg)
	sampTextdrawCreate(2048, "Test", 150.0, 150.0)
	sampTextdrawSetStyle(2048, 5)
	sampTextdrawSetBoxColorAndSize(2048, true, 0xFFFFFF00, 250.0, 250.0)
	sampTextdrawSetStyle(2048, 5) 
	sampTextdrawSetModelRotationZoomVehColor(2048, tonumber(arg), 0.0, 0.0, 0.0, 1.0, 0, 0)
	lua_thread.create(function()
		wait(1574)
		sampTextdrawDelete(2048)
	end)
end

if lsampev then
	function sampev.onPlayerStreamIn(playerId, team, model, position, rotation, color, fightingStyle)
		for k,v in pairs(config.skins) do
			local nametoid = sampGetPlayerIdByNickname(k)
			if playerId == nametoid then
			model = v
			end
		end	
		return {playerId, team, model, position, rotation, color, fightingStyle}	
	end
	function sampev.onSetSpawnInfo(team, skin, _unused, position, rotation, weapons, ammo)
		for k,v in pairs(config.skins) do
		local nametoid = sampGetPlayerIdByNickname(k)	
			if team ~= 0 then
			changeSkin(nametoid, v)
			end		
		end
	-- return {team, skin, _unused, position, rotation, weapons, ammo}
	end
	function sampev.onSetPlayerSkin(playerId, skinId)                                              
		for k,v in pairs(config.skins) do
			local nametoid = sampGetPlayerIdByNickname(k)
			if playerId == nametoid then
				skinId = v
			end		
		end
		return {playerId, skinId}
	end
end
function onScriptTerminate(LuaScript, quitGame)
    if LuaScript == thisScript() and not quitGame then
        showCursor(false, false)
    end
end

function autoupdate(json_url, prefix, url)
	updatestatustest = 'Проверяю обновление.'
	local dlstatus = require('moonloader').download_status
	local json = getWorkingDirectory() .. '\\'..thisScript().name..'-version.json'
	if doesFileExist(json) then os.remove(json) end
	int_json_download = downloadUrlToFile(json_url, json,
	  function(id, status, p1, p2)
		if status == dlstatus.STATUSEX_ENDDOWNLOAD and int_json_download == id then
		  if doesFileExist(json) then
			local f = io.open(json, 'r')
			if f then
			  local info = decodeJson(f:read('*a'))
			  updatelink = info.updateurl
			  updateversion = info.latest
			  f:close()
			  os.remove(json)
			  if updateversion ~= thisScript().version then
				lua_thread.create(function(prefix)
				  local dlstatus = require('moonloader').download_status
				  updatestatustest = 'Обнаружено обновление. \nПытаюсь обновиться c '..thisScript().version..' на '..updateversion	
				  wait(574)
				  int_scr_download = downloadUrlToFile(updatelink, thisScript().path,
					function(id3, status1, p13, p23)
					  if status1 == dlstatus.STATUS_ENDDOWNLOADDATA and int_scr_download == id3 then
						updatestatustest = 'Загрузка обновления завершена.'	
						updatestatustest = 'Обновление завершено!.'
						config.settings.changelog = true
						savejson(convertTableToJsonString(config), "moonloader/config/PersonalSkinChanger.json")
						goupdatestatus = true
						if doesFileExist("moonloader/config/fskin.lua") then
							lua_thread.create(function() wait(500) thisScript():unload() end) -- удалить в 1.0.5
							os.remove(getWorkingDirectory() .. '\\fskin.lua') -- удалить в 1.0.5
							script.load(getWorkingDirectory() .. '\\PersonalSkinChanger.lua') -- удалить в 1.0.5
						else
							lua_thread.create(function() wait(500) thisScript():reload() end)
						end
					  end
					  if status1 == dlstatus.STATUSEX_ENDDOWNLOAD and int_scr_download == id3 then
						if goupdatestatus == nil then
						  updatestatustest = 'Обновление прошло неудачно. \nЗапускаю устаревшую версию.'
						  update = false
						end
					  end
					end
				  )
				  end, prefix
				)
			  else
				update = false
				updatestatustest = 'Обновление не требуется.\nТекущая версия '..thisScript().version
			  end
			end
		  else
			updatestatustest = 'Не могу проверить обновление. \nВозможно, что-то блокирует соединение с сервером. \nЕсли у вас есть !0AntiStealerByDarkP1xel32.ASI то удалите его и попробуйте снова.'
			update = false
		  end
		end
	  end
	)
end

if lziplib then
	function zipextract(script_name)
		
		file_path = getWorkingDirectory() .. "\\" .. script_name ..".zip"

		if doesFileExist(file_path) then
			print("Распаковка архива: " .. script_name)
			local extract_des = string.format("%s\\%s",getWorkingDirectory(),script_name)
			ziplib.zip_extract(file_path,extract_des,nil,nil)
			MoveFiles(extract_des,getWorkingDirectory().."\\lib")
			os.remove(file_path)
			print("Распаковка прошла успешно, распакован архив: " .. script_name)
		else
			print("Файлы не найдет, перезапустите скрипт.")
		end
	end
end

if llfs then 
	function MoveFiles(main_dir,dest_dir)
		for f in lfs.dir(main_dir) do
			local main_file = main_dir .. "\\" .. f

			if doesDirectoryExist(main_file) and f ~= "." and f ~= ".." then
				MoveFiles(main_file,dest_dir .. "\\" .. f)
			end

			if doesFileExist(main_file) then
				dest_file = dest_dir .. "/" .. f
				if not doesDirectoryExist(dest_dir) then
					lfs.mkdir(dest_dir)
				end
				
				if doesFileExist(dest_file) then
					os.remove(dest_file)
				end
				if doesFileExist(dest_file) then
					os.remove(main_file)
					print("Невозможно удалить файл " .. dest_file)
				else
					os.rename(main_file,dest_file)
				end
				
			end
		end
		lfs.rmdir(main_dir)
	end
end

function checklibs()
	if not lsampev or not limgui or not lfaicons or not lfa or not llfs or not lziplib then	  
		lua_thread.create(function()
			print('Подгрузка необходимых библиотек..')
			if not lziplib then
				downloadFile('ziplib', getWorkingDirectory()..'\\lib\\ziplib.dll', 'https://github.com/dmitriyewich/Personal-Skin-Changer/raw/main/lib/ziplib.dll')
				while not doesFileExist(getWorkingDirectory()..'\\lib\\ziplib.dll') do wait(0) end
				reloadScripts()
			else
				wait(0)
			end
			if not llfs then
				downloadFile('lfs.dll', getWorkingDirectory()..'\\lib\\lfs.dll', 'https://github.com/dmitriyewich/Personal-Skin-Changer/raw/main/lib/lfs.dll')
				while not doesFileExist(getWorkingDirectory()..'\\lib\\lfs.dll') do wait(0) end
				reloadScripts()
			else
				wait(0)
			end
			if not lsampev then
				--samp.lua
				downloadFile('samp-lua-v2.2.0', getWorkingDirectory()..'\\samp-lua-v2.2.0.zip', 'https://github.com/THE-FYP/SAMP.Lua/releases/download/v2.2.0/samp-lua-v2.2.0.zip')
				while not doesFileExist(getWorkingDirectory()..'\\samp-lua-v2.2.0.zip') do wait(0) end
				zipextract("samp-lua-v2.2.0")
				wait(1000)
				reloadScripts()
			else
				wait(0)
			end
			if not lfaicons then
				--fa-icons
				downloadFile('fa-icons', getWorkingDirectory()..'\\lib\\fa-icons.lua', 'https://gitlab.com/THE-FYP/lua-fa-icons-4/-/raw/master/fa-icons.lua?inline=false')
				while not doesFileExist(getWorkingDirectory()..'\\lib\\fa-icons.lua') do wait(0) end			
				downloadFile('fontawesome-webfont', getWorkingDirectory()..'\\resource\\fonts\\fontawesome-webfont.ttf', 'https://github.com/onface/font-awesome/raw/master/fonts/fontawesome-webfont.ttf')
				while not doesFileExist(getWorkingDirectory()..'\\resource\\fonts\\fontawesome-webfont.ttf') do wait(0) end
				reloadScripts()
			end
			if not lfa then
				--fAwesome5
				downloadFile('fAwesome5', getWorkingDirectory()..'\\lib\\fAwesome5.lua', 'https://www.dropbox.com/s/arnejom9vn3igfa/fAwesome5.lua?dl=1')
				while not doesFileExist(getWorkingDirectory()..'\\lib\\fa-icons.lua') do wait(0) end			
				downloadFile('fa-solid-900', getWorkingDirectory()..'\\resource\\fonts\\fa-solid-900.ttf', 'https://github.com/FortAwesome/Font-Awesome/raw/master/webfonts/fa-solid-900.ttf')
				while not doesFileExist(getWorkingDirectory()..'\\resource\\fonts\\fa-solid-900.ttf') do wait(0) end
				reloadScripts()
			end
				--mimgui
			if not limgui then
				downloadFile('mimgui-v1.7.0.zip', getWorkingDirectory()..'\\mimgui-v1.7.0.zip', 'https://github.com/THE-FYP/mimgui/releases/download/v1.7.0/mimgui-v1.7.0.zip')
				while not doesFileExist(getWorkingDirectory()..'\\mimgui-v1.7.0.zip') do wait(0) end
				zipextract("mimgui-v1.7.0")
				wait(1000)
				reloadScripts()
			else
				wait(0)
			end
			print('Подгрузка библиотек успешно завершена. Перезагрузка скриптов...')
			wait(1000)
			reloadScripts()
		end)
		return false
	end
	return true
end

function downloadFile(name, path, link)
	if not doesFileExist(path) then
		print('Скачивание файла {006AC2}«'..name..'»')
		downloadUrlToFile(link, path, function(id, status, p1, p2)
			if status == dlstatus.STATUSEX_ENDDOWNLOAD then
				if doesFileExist(path) then
					print('Файл {006AC2}«'..name..'»{FFFFFF} загружен!')
				else
					print('Не удалось загрузить файл {006AC2}«'..name..'»')
				end
			end
		end)
	end
end
