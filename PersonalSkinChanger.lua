script_name('PersonalSkinChanger')
script_author('dmitriyewich, https://vk.com/dmitriyewichmods')
script_description("The usual fakeskin on hooks, mimgui. Sets an individual skin by player's nickname. Any time server changes skin, you will have skin you installed. When unlinking a skin, the skin that was before binding is returned.")
script_url("https://vk.com/dmitriyewichmods")
script_dependencies("ffi", "encoding", "mimgui", "vkeys", "samp.events", 'windows.message')
script_properties('work-in-pause')
script_version('2.1')
script_version_number(210)

local lffi, ffi = pcall(require, 'ffi')
local lmemory, memory = pcall(require, 'memory')
local lvk, vk = pcall(require, 'vkeys')
local limgui, imgui = pcall(require, 'mimgui') -- https://github.com/THE-FYP/mimgui
assert(limgui, 'Library \'mimgui\' not found. Download: https://github.com/THE-FYP/mimgui')
local lwm, wm = pcall(require, 'windows.message')
local lsampev, sampev = pcall(require, 'samp.events') -- https://github.com/THE-FYP/SAMP.Lua
assert(lsampev, 'Library \'SAMP.Lua\' not found. Download: https://github.com/THE-FYP/SAMP.Lua')
local lencoding, encoding = pcall(require, 'encoding')
encoding.default = 'CP1251'
u8 = encoding.UTF8
CP1251 = encoding.CP1251

local lpedfuncs, pedfuncs = pcall(ffi.load, 'PedFuncs.asi')

ffi.cdef[[
	int Ext_GetPedRemap(uint32_t, int index);
	void Ext_SetPedRemap(uint32_t, int index, int num);
]]

changelog = [[
		v0.1
	- Релиз.
		v0.2
	- Почему-то хук менял только скин локального игрока, добавил другой, теперь заменяет скины других игроков.
		v0.3
	- Теперь не надо умирать\спавниться.
	- Скин меняется сразу после привязки.(Но после отвязки скина всё так же необходимо умиреть\заспавниться\сменить зону стрима)
		v0.4
	- Hotfix
		v0.5
	- Незанятые иды можно узнать в текстовом файле в группе вк(или по кнопке в конце истории изменений).
	- Вместо них добавлен предпросмотр стандартных скинов и новых скинов, которые вы привязали.
		v0.6
	- Переведен конфиг на json, проблемы с точкой в нике нет.
	- Сделал сортировку новых скинов по возрастанию ида.
		v0.7
	- Добавлено автообновление(по умолчанию выключено), и мелкие дополнения\исправления. {FFFFFF- Если вы не хотите получать обновление в настройках отключите эту функцию.
		v0.8
	- Перевел скрипт на mimgui}.
	- Мелкие фиксы, улучшения.
		v0.9
	- Ребрендинг.
	- Теперь скрипт называется PersonalSkinChanger}(всместо Очередной фейкскин).
	- При отсутвии необходимых библиотек скрипт сам их скачает.
	- Мелкие фиксы, улучшения.
		v1.0
	- При отвязки скина возвращается скин который был до привязки.
	- Добавил в настройки смену команды активации скрипта.
	- Мелкие фиксы.
		v1.0.1
	- Микрофиксы
		v1.0.2
	- Микрофиксы.
	- Появились новые зависимости LFS и ZipLua, они нужны чтобы распаковать архив mimgui-v1.7.0.zip(скачивается напрямую с гитхаба), если не установлен mimgui.
		v1.0.3
	- Микрофиксы.
		v1.0.4
	- Микрофиксы. -Изменение ссылки на обновление.
	- Проверка идет с github.
	- Так же изменено имя файла.
	- После обновления старая версия с названием фала fskin.lua удалиться автоматически.
		v1.0.4.1
	- Исправление кодировки после переезда на github. Микрофиксы.
		v1.0.5
	- Добавлено отображение текущего/последнего скина при наведении на инпут ид скина.
	- Добавлена функция смены скина без привзяки - /(ваша команда активации окна PSC(по умолчанию /fskin)) (ID) (IDskin).
	- Добавлено закрытие окна PSC на ESC.
		v1.1
	- Изменен стиль, добавлены альтернативные стили, можно изменить в настройках. Добавлено гендерное разделение стандартных скинов.
	- Добавлен новый вид предпросмотра скинов(переключить можно в Настройки - Предпросмотр скинов).
	- Добавлен хук на подмену скина в инвентаре аризоны, ид одежды так же меняется(включается в настройках).
		v1.1.1
	- Фикс удаления скина.
	- Добавлена коллизия для нового вида предпросмотра.
		v1.1.2
	- Микрофиксы
		v1.1.3-pre-release
	- Незначительно изменен вид предпросмотра скинов.
	- Изменен способ нового предпросмотра скинов(теперь не падает).
	- Добавлен автоматический предпросмотр.
	- Добавлено вращение скина при предпросмотре(настраиваемо).
	- Добавлена зависимость copas и requests для загрузки картинок(лого и других в будущем без скачивания).
		v2.0
	- Рефакторинг кода.
	- Удалены зависимости fAwesome5, fa-icons, lfs, ziplib, copas, requests, effil. Т.е из глобального удалены авто-обновление и подгрузка картинок.
	- Изменен метод смены скина, теперь меняется не отпралением RPC о смене, а через память(спасибо plugin-sdk).
	- Изменен метод добавления новых скинов, теперь необходимо активировать чекбокс возде ввода ID скина, чтобы добавить новый скин, в противном случае при нестандартном иде ничего не произойдет. Так же новые скины можно добавить в конфиге в категории newskins. Id скина CJ 0!.
	- Изменен метод предпросмотра скина при текстдраве и создании скина. Оба следуют за окном, созданный скин поворачивается на камеру.
	- Добавлена категория "Дополнительные функции": Смени стиля походки, смена стиля боя, Assistant for PedFuncs. Не забудьте ввести ник(ну или не вводите, если хотите себе изменить)
	- Добавлен Assistant for PedFuncs для предпросмотра.
	- Skinslast меняется на серверный если сработал хук о спавне, появлении в зоне стрима, смене скина. Вроде работает, гы.
	- TODO настройки, одежда cj, замена на текстдраве,
	- Мелкие графические изменения.
		v2.1
	- Добавлены три дополнительные функции:
		Проигрование анимаций(и в предпросмотр тоже)(при случайном наведении может не закрыться, попробую исправить)
		Прозрачность и скорость поворота скина(до смены скина или спавна). Анимацию поворота можно отключить.
		Сохрание ремапа для PedFuncs(если он есть и скин привязан к нику).
	- Микрофиксы
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

local function neatJSON(value, opts) -- https://github.com/Phrogz/NeatJSON
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

	-- indexed by object, then by indent level
	local function memoize()
		local memo = setmetatable({},{_mode='k'})
		return function(o,indent)
			if o==nil then
				return indent..(opts.lua and 'nil' or 'null')
			elseif o~=o then --test for NaN
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
	return (neatJSON(config, { wrap = 40, short = true, sort = true, aligned = true, arrayPadding = 1, afterComma = 1, beforeColon1 = 1 }))
end

local config = {}

if doesFileExist("moonloader/config/PersonalSkinChanger.json") then
    local f = io.open("moonloader/config/PersonalSkinChanger.json")
    config = decodeJson(f:read("*a"))
    f:close()
else
   config = {
		["skins"] =	{
			["Name_Nick"] = 250,
			["Nick_Name"] = 23;
		},
        ["settings"] = {
			["language"] = "RU",
			["preview_method"] = "createchar",
			["cmd"] = "fskin";
        },
        ["skinslast"] = {
            ["Name_Nick"] = 250;
        },
        ["newskins"] = {313, 314},
        ["pedfuncs"] = {
            ["Name_Nick"] = {["index0"] = 1, ["index1"] = -1, ["index2"] = -1, ["index3"] = -1, ["index4"] = -1, ["index5"] = -1, ["index6"] = -1, ["index7"] = -1};
        },
	}
    savejson(convertTableToJsonString(config), "moonloader/config/PersonalSkinChanger.json")
end

function NameModel(x)
	local testNameModel = {
		[0] = "cj", [1] = "truth", [2] = "maccer", [3] = "andre", [4] = "bbthin", [5] = "bb", [6] = "emmet", [7] = "male01", [8] = "janitor", [9] = "bfori",
		[10] = "bfost", [11] = "vbfycrp", [12] = "bfyri", [13] = "bfyst", [14] = "bmori", [15] = "bmost", [16] = "bmyap", [17] = "bmybu", [18] = "bmybe",
		[19] = "bmydj", [20] = "bmyri", [21] = "bmycr", [22] = "bmyst", [23] = "wmybmx", [24] = "wbdyg1", [25] = "wbdyg2", [26] = "wmybp", [27] = "wmycon",
		[28] = "bmydrug", [29] = "wmydrug", [30] = "hmydrug", [31] = "dwfolc", [32] = "dwmolc1", [33] = "dwmolc2", [34] = "dwmylc1", [35] = "hmogar", [36] = "wmygol1",
		[37] = "wmygol2", [38] = "hfori", [39] = "hfost", [40] = "hfyri", [41] = "hfyst", [42] = "jethro", [43] = "hmori", [44] = "hmost", [45] = "hmybe", [46] = "hmyri",
		[47] = "hmycr", [48] = "hmyst", [49] = "omokung", [50] = "wmymech", [51] = "bmymoun", [52] = "wmymoun", [53] = "ofori", [54] = "ofost", [55] = "ofyri", [56] = "ofyst",
		[57] = "omori", [58] = "omost", [59] = "omyri", [60] = "omyst", [61] = "wmyplt", [62] = "wmopj", [63] = "bfypro", [64] = "hfypro", [65] = "kendl", [66] = "bmypol1",
		[67] = "bmypol2", [68] = "wmoprea", [69] = "sbfyst", [70] = "wmosci", [71] = "wmysgrd", [72] = "swmyhp1", [73] = "swmyhp2", [74] = "-", [75] = "swfopro", [76] = "wfystew",
		[77] = "swmotr1", [78] = "wmotr1", [79] = "bmotr1", [80] = "vbmybox", [81] = "vwmybox", [82] = "vhmyelv", [83] = "vbmyelv", [84] = "vimyelv", [85] = "vwfypro",
		[86] = "ryder3", [87] = "vwfyst1", [88] = "wfori", [89] = "wfost", [90] = "wfyjg", [91] = "wfyri", [92] = "wfyro", [93] = "wfyst", [94] = "wmori", [95] = "wmost",
		[96] = "wmyjg", [97] = "wmylg", [98] = "wmyri", [99] = "wmyro", [100] = "wmycr", [101] = "wmyst", [102] = "ballas1", [103] = "ballas2", [104] = "ballas3", [105] = "fam1",
		[106] = "fam2", [107] = "fam3", [108] = "lsv1", [109] = "lsv2", [110] = "lsv3", [111] = "maffa", [112] = "maffb", [113] = "mafboss", [114] = "vla1", [115] = "vla2",
		[116] = "vla3", [117] = "triada", [118] = "triadb", [119] = "sindaco", [120] = "triboss", [121] = "dnb1", [122] = "dnb2", [123] = "dnb3", [124] = "vmaff1",
		[125] = "vmaff2", [126] = "vmaff3", [127] = "vmaff4", [128] = "dnmylc", [129] = "dnfolc1", [130] = "dnfolc2", [131] = "dnfylc", [132] = "dnmolc1", [133] = "dnmolc2",
		[134] = "sbmotr2", [135] = "swmotr2", [136] = "sbmytr3", [137] = "swmotr3", [138] = "wfybe", [139] = "bfybe", [140] = "hfybe", [141] = "sofybu", [142] = "sbmyst", [143] = "sbmycr",
		[144] = "bmycg", [145] = "wfycrk", [146] = "hmycm", [147] = "wmybu", [148] = "bfybu", [149] = "smokev", [150] = "wfybu", [151] = "dwfylc1", [152] = "wfypro", [153] = "wmyconb",
		[154] = "wmybe", [155] = "wmypizz", [156] = "bmobar", [157] = "cwfyhb", [158] = "cwmofr", [159] = "cwmohb1", [160] = "cwmohb2", [161] = "cwmyfr", [162] = "cwmyhb1",
		[163] = "bmyboun", [164] = "wmyboun", [165] = "wmomib", [166] = "bmymib", [167] = "wmybell", [168] = "bmochil", [169] = "sofyri", [170] = "somyst", [171] = "vwmybjd",
		[172] = "vwfycrp", [173] = "sfr1", [174] = "sfr2", [175] = "sfr3", [176] = "bmybar", [177] = "wmybar", [178] = "wfysex", [179] = "wmyammo", [180] = "bmytatt",
		[181] = "vwmycr", [182] = "vbmocd", [183] = "vbmycr", [184] = "vhmycr", [185] = "sbmyri", [186] = "somyri", [187] = "somybu", [188] = "swmyst", [189] = "wmyva",
		[190] = "copgrl3", [191] = "gungrl3", [192] = "mecgrl3", [193] = "nurgrl3", [194] = "crogrl3", [195] = "gangrl3", [196] = "cwfofr", [197] = "cwfohb",
		[198] = "cwfyfr1", [199] = "cwfyfr2", [200] = "cwmyhb2", [201] = "dwfylc2", [202] = "dwmylc2", [203] = "omykara", [204] = "wmykara", [205] = "wfyburg",
		[206] = "vwmycd", [207] = "vhfypro", [208] = "suzie", [209] = "omonood", [210] = "omoboat", [211] = "wfyclot", [212] = "vwmotr1", [213] = "vwmotr2",
		[214] = "vwfywai", [215] = "sbfori", [216] = "swfyri", [217] = "wmyclot", [218] = "sbfost", [219] = "sbfyri", [220] = "sbmocd", [221] = "sbmori",
		[222] = "sbmost", [223] = "shmycr", [224] = "sofori", [225] = "sofost", [226] = "sofyst", [227] = "somobu", [228] = "somori", [229] = "somost",
		[230] = "swmotr5", [231] = "swfori", [232] = "swfost", [233] = "swfyst", [234] = "swmocd", [235] = "swmori", [236] = "swmost", [237] = "shfypro",
		[238] = "sbfypro", [239] = "swmotr4", [240] = "swmyri", [241] = "smyst", [242] = "smyst2", [243] = "sfypro", [244] = "vbfyst2", [245] = "vbfypro",
		[246] = "vhfyst3", [247] = "bikera", [248] = "bikerb", [249] = "bmypimp", [250] = "swmycr", [251] = "wfylg", [252] = "wmyva2", [253] = "bmosec",
		[254] = "bikdrug", [255] = "wmych", [256] = "sbfystr", [257] = "swfystr", [258] = "heck1", [259] = "heck2", [260] = "bmycon", [261] = "wmycd1",
		[262] = "bmocd", [263] = "vwfywa2", [264] = "wmoice", [265] = "tenpen", [266] = "pulaski", [267] = "hern", [268] = "dwayne", [269] = "smoke", [270] = "sweet",
		[271] = "ryder", [272] = "forelli", [273] = "tbone", [274] = "laemt1", [275] = "lvemt1", [276] = "sfemt1", [277] = "lafd1", [278] = "lvfd1", [279] = "sffd1",
		[280] = "lapd1", [281] = "sfpd1", [282] = "lvpd1", [283] = "csher", [284] = "lapdm1", [285] = "swat", [286] = "fbi", [287] = "army", [288] = "dsher", [289] = "zero",
		[290] = "rose", [291] = "paul", [292] = "cesar", [293] = "ogloc", [294] = "wuzimu", [295] = "torino", [296] = "jizzy", [297] = "maddogg", [298] = "cat",
		[299] = "claude", [300] = "lapdna", [301] = "sfpdna", [302] = "lvpdna", [303] = "lapdpc", [304] = "lapdpd", [305] = "lvpdpc", [306] = "wfyclpd", [307] = "vbfycpd",
		[308] = "wfyclem", [309] = "wfycllv", [310] = "csherna", [311] = "dsherna";
	}
	for i = 0, #testNameModel do
		if x == i then
			return testNameModel[i]
		end
	end
    return 'None'

end

local ui_meta = { -- by Cosmo https://www.blast.hk/threads/111268/
    __index = function(self, v)
        if v == "switch" then
            local switch = function()
                if self.process and self.process:status() ~= "dead" then
                    return false
                end
                self.timer = os.clock()
                self.state = not self.state

                self.process = lua_thread.create(function()
                    local bringFloatTo = function(from, to, start_time, duration)
                        local timer = os.clock() - start_time
                        if timer >= 0.00 and timer <= duration then
                            local count = timer / (duration / 100)
                            return count * ((to - from) / 100)
                        end
                        return (timer > duration) and to or from
                    end

                    while true do wait(0)
                        local a = bringFloatTo(0.00, 1.00, self.timer, self.duration)
                        self.alpha = self.state and a or 1.00 - a
                        if a == 1.00 then break end
                    end
                end)
                return true
            end
            return switch
        end

        if v == "alpha" then
            return self.state and 1.00 or 0.00
        end
    end
}

local menu = { state = false, duration = 0.5 }
setmetatable(menu, ui_meta)

function main()
	repeat wait(0) until memory.read(0xC8D4C0, 4, false) == 9
	repeat wait(0) until isSampfuncsLoaded()
    repeat wait(0) until isSampAvailable()

	sampRegisterChatCommand(config.settings.cmd, chat_command)
	sampSetClientCommandDescription(config.settings.cmd, (string.format(u8:decode'Активация/деактивация окна %s, /%s id IdSkin(смена скина без привязки), Файл: %s', thisScript().name, config.settings.cmd, thisScript().filename)))


	-- while true do wait(0)

	-- end
	wait(-1)
end

function chat_command(arg)
	if arg == nil or arg == "" then
		menu.switch()
	end
	if arg:find('^(%d+)$') then
		local skinID = arg:match('^(%d+)$')
		setCharModelId(PLAYER_PED, skinID)
	end
	if arg:find('^(%d+)%s(%d+)$') then
		local id, skinID = arg:match('^(%d+)%s(%d+)$')
		local res, ped = sampGetCharHandleBySampPlayerId(id)
		if res then
			setCharModelId(ped, skinID)
		end
	end
end

function Standart()
	imgui.SwitchContext()
	local style = imgui.GetStyle()
	local colors = style.Colors
	local clr = imgui.Col
	local ImVec4 = imgui.ImVec4
	local ImVec2 = imgui.ImVec2

    style.WindowPadding = ImVec2(15, 15)
	style.WindowRounding = 4.7
    style.WindowBorderSize = 1.7
	style.WindowMinSize = ImVec2(1.5, 1.5)
	style.WindowTitleAlign = ImVec2(0.5, 0.5)
	style.ChildRounding = 4.7
	style.ChildBorderSize = 1
	style.PopupRounding = 4.7
	style.PopupBorderSize  = 1
	style.FramePadding = ImVec2(5, 5)
	style.FrameRounding = 4.7
	style.FrameBorderSize  = 1.0
	style.ItemSpacing = ImVec2(2, 7)
	style.ItemInnerSpacing = ImVec2(8, 6)
	style.ScrollbarSize = 9.0
	style.ScrollbarRounding = 4.7
	style.GrabMinSize = 15.0
	style.GrabRounding = 4.7
	style.IndentSpacing = 25.0
	style.ButtonTextAlign = ImVec2(0.5, 0.5)
	style.SelectableTextAlign = ImVec2(0.5, 0.5)
	style.TouchExtraPadding = ImVec2(0.00, 0.00)
	style.TabBorderSize = 1
	style.TabRounding = 4

	colors[clr.Text] = ImVec4(1.00, 1.00, 1.00, 1.00)
	colors[clr.TextDisabled] = ImVec4(0.50, 0.50, 0.50, 1.00)
	colors[clr.WindowBg] = ImVec4(0.15, 0.15, 0.15, 1.00)
	colors[clr.ChildBg] = ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[clr.PopupBg] = ImVec4(0.19, 0.19, 0.19, 0.92)
	colors[clr.Border] = ImVec4(0.19, 0.19, 0.19, 1.0)
	colors[clr.BorderShadow] = ImVec4(0.00, 0.00, 0.00, 1.0)
	colors[clr.FrameBg] = ImVec4(0.05, 0.05, 0.05, 0.54)
	colors[clr.FrameBgHovered] = ImVec4(0.19, 0.19, 0.19, 0.54)
	colors[clr.FrameBgActive] = ImVec4(0.20, 0.22, 0.23, 1.00)
	colors[clr.TitleBg] = ImVec4(0.00, 0.00, 0.00, 1.00)
	colors[clr.TitleBgActive] = ImVec4(0.06, 0.06, 0.06, 1.00)
	colors[clr.TitleBgCollapsed] = ImVec4(0.00, 0.00, 0.00, 1.00)
	colors[clr.MenuBarBg] = ImVec4(0.14, 0.14, 0.14, 1.00)
	colors[clr.ScrollbarBg] = ImVec4(0.05, 0.05, 0.05, 0.54)
	colors[clr.ScrollbarGrab] = ImVec4(0.34, 0.34, 0.34, 0.54)
	colors[clr.ScrollbarGrabHovered] = ImVec4(0.40, 0.40, 0.40, 0.54)
	colors[clr.ScrollbarGrabActive] = ImVec4(0.56, 0.56, 0.56, 0.54)
	colors[clr.CheckMark] = ImVec4(0.33, 0.67, 0.86, 1.00)
	colors[clr.SliderGrab] = ImVec4(0.34, 0.34, 0.34, 0.54)
	colors[clr.SliderGrabActive] = ImVec4(0.56, 0.56, 0.56, 0.54)
	colors[clr.Button] = ImVec4(0.05, 0.05, 0.05, 0.54)
	colors[clr.ButtonHovered] = ImVec4(0.19, 0.19, 0.19, 0.54)
	colors[clr.ButtonActive] = ImVec4(0.20, 0.22, 0.23, 1.00)
	colors[clr.Header] = ImVec4(0.05, 0.05, 0.05, 0.52)
	colors[clr.HeaderHovered] = ImVec4(0.19, 0.19, 0.19, 0.36)
	colors[clr.HeaderActive] = ImVec4(0.20, 0.22, 0.23, 0.33)
	colors[clr.Separator] = ImVec4(0.28, 0.28, 0.28, 0.29)
	colors[clr.SeparatorHovered] = ImVec4(0.44, 0.44, 0.44, 0.29)
	colors[clr.SeparatorActive] = ImVec4(0.40, 0.44, 0.47, 1.00)
	colors[clr.ResizeGrip] = ImVec4(0.28, 0.28, 0.28, 0.29)
	colors[clr.ResizeGripHovered] = ImVec4(0.44, 0.44, 0.44, 0.29)
	colors[clr.ResizeGripActive] = ImVec4(0.40, 0.44, 0.47, 1.00)
	colors[clr.Tab]  = ImVec4(0.00, 0.00, 0.00, 0.52)
	colors[clr.TabHovered] = ImVec4(0.14, 0.14, 0.14, 1.00)
	colors[clr.TabActive] = ImVec4(0.20, 0.20, 0.20, 0.36)
	colors[clr.TabUnfocused] = ImVec4(0.00, 0.00, 0.00, 0.52)
	colors[clr.TabUnfocusedActive] = ImVec4(0.14, 0.14, 0.14, 1.00)
	colors[clr.PlotLines] = ImVec4(1.00, 0.00, 0.00, 1.00)
	colors[clr.PlotLinesHovered] = ImVec4(1.00, 0.00, 0.00, 1.00)
	colors[clr.PlotHistogram] = ImVec4(1.00, 0.00, 0.00, 1.00)
	colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.00, 0.00, 1.00)
	colors[clr.TextSelectedBg] = ImVec4(0.20, 0.22, 0.23, 1.00)
	colors[clr.DragDropTarget] = ImVec4(0.33, 0.67, 0.86, 1.00)
	colors[clr.NavHighlight] = ImVec4(1.00, 0.00, 0.00, 1.00)
	colors[clr.NavWindowingHighlight]  = ImVec4(1.00, 0.00, 0.00, 0.70)
	colors[clr.NavWindowingDimBg] = ImVec4(1.00, 0.00, 0.00, 0.20)
	colors[clr.ModalWindowDimBg] = ImVec4(1.00, 0.00, 0.00, 0.35)
end


imgui.OnInitialize(function()

	Standart()

	logo = imgui.CreateTextureFromFileInMemory(_logo, #_logo)

	close_window = imgui.CreateTextureFromFileInMemory(_close, #_close)

	imgui.GetIO().IniFilename = nil

end)

local peshPed

local butTutor = imgui.new.bool(false)
local but_succses = imgui.new.bool(false)
local but_cmd = imgui.new.bool(false)
local but_pedfuncs = imgui.new.bool(false)

local preview_method = imgui.new.bool(config.settings.preview_method == "createchar" and true or false)

local nick = imgui.new.char[128]('')
local idskin = imgui.new.char[128]('')
local cmdbuffer = imgui.new.char[128]('')

local combo = imgui.new.int(0)

local RwSkinAlpha = imgui.new.float(255.0)
local Rotation_speed = imgui.new.float(9.0)

local speed = imgui.new.float(47.74)
local rotation = imgui.new.float(0)
local auto = imgui.new.bool(false)

local combo_test = imgui.new.int(0)
local test_table = {"ts", "Test1", "Test2"}
local test_new = imgui.new['const char*'][#test_table](test_table)

local combo_fightstyle = imgui.new.int(0)
local fightstyle = {"Streetstyle", "Boxing", "KungFu", "MuayThai"}
local fightstyleTable = imgui.new['const char*'][#fightstyle](fightstyle)

local combo_walkstyle = imgui.new.int(0)
local walkstyle = {"(M)CJ", "(M)Man", "(M)Shuffle", "(M)Oldman", "(M)Gang1", "(M)Gang2", "(M)Oldfatman", "(M)Fatman", "(M)Drunkman", "(M)Blindman", "(M)SWAT", "(M)Jogger", "(W)Woman", "(W)Shopping", "(W)Busywoman", "(W)Sexywoman", "(W)PRO", "(W)Oldwoman", "(W)Fatwoman", "(W)Jogwoman", "(W)Oldfatwoman"}
local walkstyleTable = imgui.new['const char*'][#walkstyle](walkstyle)

local checkbox_newskin = imgui.new.bool(false)

local checkbox_fAngle = imgui.new.bool(false)

local ImageButton_color = imgui.ImVec4(1,1,1,1)

local GenderBySkin = 'all'
local male_button = imgui.new.bool(false)
local female_button = imgui.new.bool(false)

local button_skin = {}
for i = 0, 311 do
	button_skin[i] = imgui.new.bool(false)
end

local button_skin_new = {}
for i = 1, #config.newskins do
	button_skin_new[i] = imgui.new.bool(false)
end

local index = 0

local main_frame = imgui.OnFrame(
    function() return menu.alpha > 0.00 end,
    function(self)
        self.HideCursor = not menu.state
        imgui.PushStyleVarFloat(imgui.StyleVar.Alpha, menu.alpha)
		local wposX, wposY = convertGameScreenCoordsToWindowScreenCoords(147, 220)
		imgui.SetNextWindowPos(imgui.ImVec2(wposX, wposY), imgui.Cond.Appearing, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(400, 460), imgui.Cond.Appearing)
        imgui.Begin("##My window", _, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)

			imgui.PushStyleVarFloat(imgui.StyleVar.FrameBorderSize, 0.0)
			imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.00, 0.00, 0.00, 0.0))
			imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.0, 0.0, 0.0, 0.0))
			imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.76, 0.76, 0.76, 1.00))
			imgui.SetCursorPosX(imgui.GetContentRegionAvail().x+4)
			imgui.SetCursorPosY(imgui.GetCursorPosY() - 12)
			if imgui.ImageButton(close_window, imgui.ImVec2(16, 16), _,  _, 1, imgui.ImVec4(0,0,0,0), ImageButton_color) then
				menu.switch()
			end
			if imgui.IsItemHovered() then
				ImageButton_color = imgui.ImVec4(1,1,1,0.5)
			else
				ImageButton_color = imgui.ImVec4(1,1,1,1)
			end
			imgui.PopStyleColor(3)
			imgui.PopStyleVar()

			imgui.SetCursorPosX(imgui.GetCursorPosX() + 0)
			imgui.SetCursorPosY(imgui.GetCursorPosY() - 22)
			if config.settings.language == "RU" then imgui.Text("RU") else imgui.TextDisabled("RU") end
			if imgui.IsItemClicked(0) then
				config.settings.language = "RU"
				savejson(convertTableToJsonString(config), "moonloader/config/PersonalSkinChanger.json")
			end
			imgui.SameLine(nil, 0)
			imgui.Text("|")
			imgui.SameLine(nil, 0)
			if config.settings.language == "EN" then imgui.Text("EN") else imgui.TextDisabled("EN") end
			if imgui.IsItemClicked(0) then
				config.settings.language = "EN"
				savejson(convertTableToJsonString(config), "moonloader/config/PersonalSkinChanger.json")
			end

			imgui.Separator()
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 374) / 2)
			imgui.Image(logo, imgui.ImVec2(374, 28), _, _, imgui.ImVec4(1,1,1,0.874))
			if imgui.IsItemHovered() then
				imgui.BeginTooltip()
				imgui.PushTextWrapPos(600)
				imgui.TextUnformatted(config.settings.language == "RU" and 'by dmitriyewich aka Valgard Dmitriyewich.\nРаспространение допускается только с указанием автора или ссылки на пост в VK/GitHub' or 'by dmitriyewich aka Valgard Dmitriyewich.\nDistribution is allowed only with the indication of the author or a link to the post in the VK/GitHub')
				imgui.PopTextWrapPos()
				imgui.EndTooltip()
			end
			imgui.Separator()

			imgui.SetCursorPosY(imgui.GetCursorPosY() + 5)
			imgui.Text(config.settings.language == "RU" and ' Введите ник' or '  Enter name')
			imgui.SameLine()
			imgui.PushItemWidth(147)
			imgui.SetCursorPosY(imgui.GetCursorPosY() - 4)
			imgui.SetCursorPosX(94)
			imgui.InputTextWithHint('##Введите ник3', 'Nick_Name', nick, ffi.sizeof(nick) - 1, imgui.InputTextFlags.AutoSelectAll)
			imgui.PopItemWidth()
			imgui.TutorialHint('but_nick1', config.settings.language == "RU" and 'Введите Nickname!' or 'Enter Nickname!', butTutor, true)
			imgui.SameLine()
			imgui.SetCursorPosX(243)
			imgui.Text('ID skin')
			imgui.SameLine()
			imgui.PushItemWidth(47)
			imgui.InputTextWithHint('##ID skin', '250', idskin, ffi.sizeof(idskin) - 1, imgui.InputTextFlags.CharsDecimal + imgui.InputTextFlags.AutoSelectAll)
			imgui.PopItemWidth()
			imgui.TutorialHint('but_id2', config.settings.language == "RU" and 'Введите ID!' or 'Enter ID!', butTutor, true)
			if ffi.string(nick) ~= '' then
				if imgui.IsItemHovered() then
					local result, pped = sampGetPlayerHandleByNickname(ffi.string(nick))
					if result then
						local skin_id = getCharModel(pped)
						local last_skin_id = config.skinslast[ffi.string(nick)] and config.skinslast[ffi.string(nick)] or 'None'
						imgui.BeginTooltip()
						imgui.PushTextWrapPos(600)
						imgui.TextUnformatted((config.settings.language == "RU" and 'Текущий скин: ' or 'Current skin: ').. skin_id ..'('.. NameModel(skin_id).. (config.settings.language == "RU" and ')\nПоследний скин: ' or ')\nLast skin: ') .. last_skin_id..'('.. NameModel(last_skin_id).. ')')
						imgui.PopTextWrapPos()
						imgui.EndTooltip()
					end
				end
			end
			imgui.SameLine()
			imgui.SetCursorPosY(imgui.GetCursorPosY() - 7)
			imgui.Text('NEW\nSKIN')

			imgui.SameLine()
			imgui.SetCursorPosY(imgui.GetCursorPosY() + 7)

			imgui.Checkbox("##1", checkbox_newskin)
			if imgui.IsItemHovered() then
				imgui.BeginTooltip()
				imgui.PushTextWrapPos(600)
					imgui.TextUnformatted((config.settings.language == "RU" and 'Активируйте, чтобы изменить на нестандартный ID skin.\nВАЖНО! Вы должны быть уверены, что ID принадлежит скину!' or "Activate to change to non-standard skin ID.\nIMPORTANTLY! You need to be sure that ID belongs to skin!"))
				imgui.PopTextWrapPos()
				imgui.EndTooltip()
			end

			local SkinsRaius = {} -- функция получение идов и ников игроков в радиусе от игрока
			local myPosX, myPosY, myPosZ = getCharCoordinates(PLAYER_PED)
			for _, ped in ipairs(getAllChars()) do
				local result, id = sampGetPlayerIdByCharHandle(ped)
				if result and getDistanceBetweenCoords3d(myPosX, myPosY, myPosZ, getCharCoordinates(ped)) < 25 --[[Радиус действия, по умолчанию - 25 метров]] then
					table.insert(SkinsRaius, tostring(sampGetPlayerNickname(id)))
					SkinsRaiusTable = imgui.new['const char*'][#SkinsRaius](SkinsRaius)
				end
			end

			imgui.SetCursorPosX((imgui.GetWindowWidth() - 202 - imgui.CalcTextSize(config.settings.language == "RU" and ' Ближайший игрок' or '  Nearest player').x) / 2)
			imgui.Text(config.settings.language == "RU" and ' Ближайший игрок' or '   Nearest player')
			imgui.SameLine()
			imgui.SetCursorPosY(108)
			imgui.SetCursorPosX(156)
			imgui.PushItemWidth(200)

			imgui.PushStyleColor(imgui.Col.HeaderHovered, imgui.ImVec4(0.29, 0.29, 0.29, 0.47))
			if imgui.Combo('##Ближайший игрок', combo, SkinsRaiusTable, #SkinsRaius) then -- выбор игрока в радиусе от игрока
				for i = 0, #SkinsRaius do
					if combo[0] == i then
						nickcombo = SkinsRaius[i + 1]
						imgui.StrCopy(nick, ''..nickcombo)
					end
				end
			end
			imgui.PopStyleColor(1)
			imgui.PopItemWidth()

			imgui.SetCursorPosX((imgui.GetWindowWidth() - 370) / 2)
			if imgui.Button(config.settings.language == "RU" and 'Привязать скин к нику' or 'Attach skin to nickname', imgui.ImVec2(370, 30)) then
				if ffi.string(nick) ~= '' and ffi.string(idskin) ~= '' then
					if checkbox_newskin[0] then
						if not checktable(config.newskins, tonumber(ffi.string(idskin))) then
							config.newskins[#config.newskins+1] = tonumber(ffi.string(idskin))
							button_skin_new[#button_skin_new+1] = imgui.new.bool(false)
						end
						table.sort(config.newskins)
					end
					if not config.skinslast[ffi.string(nick)] then
						local res_b, ped_b = sampGetPlayerHandleByNickname(ffi.string(nick))
						if res_b then
							local modelId = getCharModel(ped_b)
							config.skinslast[ffi.string(nick)] = tonumber(modelId) -- запоминание начального скина до привязки
						end
					end
					if lpedfuncs and config.pedfuncs[''..ffi.string(nick)] == nil then
						config.pedfuncs[''..ffi.string(nick)] = {}
					end
					config.skins[ffi.string(nick)] = tonumber(ffi.string(idskin)) -- запоминание привязанного ника к иду
					savejson(convertTableToJsonString(config), "moonloader/config/PersonalSkinChanger.json") -- сохранение в конфиг json привязанного ника к иду
					lua_thread.create(function()
						but_succses[0] = true
						wait(1574)
						but_succses[0] = false
					end)
					for k, v in pairs(config.skins) do
						local res_bb, ped_bb = sampGetPlayerHandleByNickname(k)
						setCharModelId(ped_bb, v)
					end
				else
					lua_thread.create(function()
						butTutor[0] = true
						wait(1574)
						butTutor[0] = false
					end)
				end
			end
			imgui.TutorialHint('but_succses1', (ffi.string(nick))..' - '..(ffi.string(idskin))..(config.settings.language == "RU" and ' успешно сохранено' or ' successfully saved'), but_succses, true)

			if imgui.CollapsingHeader((config.settings.language == "RU" and 'Привязанные скины' or 'Attached skins')) then
				imgui.SetCursorPosY(imgui.GetCursorPosY() - 7)
				for q, w in pairs(config.skins) do
					imgui.CenterText(""..q.. ' - skinID: '..w)
					if imgui.IsItemClicked(1) then -- ПКМ - Отвязать скин от ника
						for k, v in pairs(config.skinslast) do
							local res, ped = sampGetPlayerHandleByNickname(k)
							setCharModelId(ped, v)
						end
						config.skins[q] = nil
						config.skinslast[q] = nil
						config.pedfuncs[q] = nil
						savejson(convertTableToJsonString(config), "moonloader/config/PersonalSkinChanger.json")
					end
					if imgui.IsItemHovered() then
						local last_skin_id = config.skinslast[q] and config.skinslast[q] or 'None'
						imgui.BeginTooltip()
						imgui.PushTextWrapPos(600)
						imgui.TextUnformatted((config.settings.language == "RU" and 'ЛКМ - Скопировать ник\nПКМ - Отвязать скин от ника\nПри отвязке вернется последний скин перед привязкой.\nПоследний скин: ' or 'LMB - Copy nickname\nRMB - Unattach skin from the nickname\nWhen unattended, the last skin before binding will be returned.\nLast skin: ') .. last_skin_id..'('.. NameModel(last_skin_id).. ')')
						imgui.PopTextWrapPos()
						imgui.EndTooltip()
					end
					if imgui.IsItemClicked(0) then
						setClipboardText(q)
					end
				end
			end
			imgui.SetCursorPosY(imgui.GetCursorPosY() - 5)
			imgui.Separator()

			if imgui.CollapsingHeader((config.settings.language == "RU" and 'Предпросмотр скинов' or 'Preview of skins')) then
				if not preview_method[0] and sampTextdrawIsExists(2048) then
					local box, color, sizeX, sizeY = sampTextdrawGetBoxEnabledColorAndSize(2048)
					if box and color == 0xFFFFFF00 and sizeX == 274.0 and sizeY == 274.0 then
						local mainWinPos = imgui.GetWindowPos()
						local gposX, gposY = convertWindowScreenCoordsToGameScreenCoords(mainWinPos.x, mainWinPos.y)
						sampTextdrawSetPos(2048, gposX+50, gposY-25)
					end
				end
				imgui.SetCursorPosY(imgui.GetCursorPosY() + 3)
				imgui.SetCursorPosX(177 - imgui.CalcTextSize((config.settings.language == "RU" and 'Текстдрав  ' or 'TextDraw  ')).x)
				imgui.Text((config.settings.language == "RU" and 'Текстдрав  ' or 'TextDraw  '))
				imgui.SameLine()
				imgui.SetCursorPosX(175)
				imgui.SetCursorPosY(imgui.GetCursorPosY() - 3)
				if imgui.ToggleButton("##ToggleButton1212", preview_method) then
					config.settings.preview_method = preview_method[0] and "createchar" or "textdraw"
					savejson(convertTableToJsonString(config), "moonloader/config/PersonalSkinChanger.json")
					delete_spawnCharFunc()
					if sampTextdrawIsExists(2048) then
						sampTextdrawDelete(2048)
					end
				end
				imgui.SameLine()
				imgui.SetCursorPosY(imgui.GetCursorPosY() + 3)
				imgui.Text((config.settings.language == "RU" and ' Создание скина' or ' Creating skin'))
				imgui.SetCursorPosY(imgui.GetCursorPosY() - 3)
				if preview_method[0] and preview_skin and doesCharExist(peshPed) then
					imgui.SetCursorPosY(imgui.GetCursorPosY() + 5)
					imgui.Text((auto[0] and (config.settings.language == "RU" and '  Авто-вращение' or "  Auto-rotation") or (config.settings.language == "RU" and 'Ручное вращение' or "  Manual rotation")))
					imgui.SameLine()
					imgui.SetCursorPosY(imgui.GetCursorPosY() - 5)
					imgui.SetCursorPosX(121)
					imgui.Checkbox("##auto3223", auto)
					imgui.SameLine()
					imgui.PushItemWidth(174)
					imgui.SetCursorPosX(153)
					imgui.SliderFloat(auto[0] and "##auto32" or "##auto33", auto[0] and speed or rotation, 0, auto[0] and 100 or 360, auto[0] and "%f" or "%f°")
					imgui.PopItemWidth()
					imgui.SameLine()
					imgui.SetCursorPosX(329)
					if imgui.SmallButton("Reset##1") then
						if auto[0] then
							speed[0] = 47.74
						else
							rotation[0] = 0
						end
					end
					local mainWinPos = imgui.GetWindowPos()
					local atX, atY, atZ = getActiveCameraCoordinates()
					local posX, posY, posZ = convertScreenCoordsToWorld3D(mainWinPos.x + 547, mainWinPos.y + 547, 3.0)
					local angle = getHeadingFromVector2d(atX - posX, atY - posY)
					setCharHeading(peshPed, (auto[0] and (angle + speed[0] * os.clock() ) or (angle + rotation[0])))
					setCharCoordinates(peshPed, posX, posY, posZ)
					imgui.AnimationIFP(peshPed)
					if lpedfuncs then
						imgui.PedFuncs(peshPed, false)
					end

				end


				if imgui.BeginTabBar('Tabs') then
					if imgui.BeginTabItem((config.settings.language == "RU" and 'Стандартные скины##' or "Standard skins##")) then
						imgui.SetCursorPosX((imgui.GetWindowWidth() - 325) / 2)
						if imgui.SelectButton((config.settings.language == "RU" and 'Мужские скины' or "Men's skins"), male_button, imgui.ImVec2(150, 33)) then
							if male_button[0] then
								GenderBySkin = 'male'
								female_button[0] = false
							else
								GenderBySkin = 'all'
								female_button[0] = false
								male_button[0] = false
							end

						end
						imgui.SameLine()

						if imgui.SelectButton((config.settings.language == "RU" and 'Женские скины' or "Women's Skins"), female_button, imgui.ImVec2(150, 33)) then
							if female_button[0] then
								GenderBySkin = 'female'
								male_button[0] = false
							else
								GenderBySkin = 'all'
								female_button[0] = false
								male_button[0] = false
							end
						end
						local tbl_skin = getGenderBySkinId(GenderBySkin)
						table.sort(tbl_skin)
						local standartskin = 1
						for i = 1, #tbl_skin do
							if imgui.SelectButton(''..tbl_skin[i], button_skin[tbl_skin[i]], imgui.ImVec2(35, 35)) then
								if button_skin[tbl_skin[i]][0] then
									for index = 1, #tbl_skin do
										if tbl_skin[i] == tbl_skin[index] then goto continue end
										button_skin[tbl_skin[index]][0] = false
										::continue::
									end

									if preview_method[0] then
										spawnCharFunc(tbl_skin[i], imgui.GetWindowPos().x, imgui.GetWindowPos().y)
									else
										textdraw_skin(tbl_skin[i])
									end
								else
									if preview_skin then
										delete_spawnCharFunc()
									end
									if sampTextdrawIsExists(2048) then
										sampTextdrawDelete(2048)
									end
								end
							end
							if imgui.IsItemHovered() then
								imgui.BeginTooltip()
								imgui.PushTextWrapPos(600)
									imgui.TextUnformatted((config.settings.language == "RU" and 'Название модели: ' or "Model name: ")..NameModel(tbl_skin[i]))
								imgui.PopTextWrapPos()
								imgui.EndTooltip()
							end
							if standartskin % 10 ~= 0 and standartskin ~= #tbl_skin then
								imgui.SameLine()
							end
							standartskin = standartskin + 1
						end
						imgui.EndTabItem()
					else
						GenderBySkin = 'all'
						female_button[0] = false
						male_button[0] = false
					end

					if imgui.BeginTabItem((config.settings.language == "RU" and 'Новые скины##1' or "New skins##1")) then
						local tbl_newskin = config.newskins
						table.sort(tbl_newskin)
						local newskin = 1
						for i = 1, #tbl_newskin do
							if imgui.SelectButton(''..tbl_newskin[i], button_skin_new[i], imgui.ImVec2(35, 35)) then
								if button_skin_new[i][0] then
									for index = 1, #button_skin_new do
										if i == index then goto continue end
											button_skin_new[index][0] = false
										::continue::
									end
									if preview_method[0] then
										spawnCharFunc(tbl_newskin[i], imgui.GetWindowPos().x, imgui.GetWindowPos().y)
									else
										textdraw_skin(tbl_newskin[i])
									end
								else
									if preview_skin then
										delete_spawnCharFunc()
									end
									if sampTextdrawIsExists(2048) then
										sampTextdrawDelete(2048)
									end
								end
							end
							if newskin % 10 ~= 0 and newskin ~= #tbl_newskin then
								imgui.SameLine()
							end
							newskin = newskin + 1
						end
					end
					imgui.EndTabBar()
				end
			end
			if  imgui.IsItemDeactivated() then
				delete_spawnCharFunc()
				Deactivated_sb()
			end
			imgui.Separator()

			if imgui.CollapsingHeader((config.settings.language == "RU" and 'Дополнительные функции' or 'Additional functions')) then
				local res_add, ped_add = sampGetPlayerHandleByNickname(ffi.string(nick))
				if ped_add == nil then ped_add = PLAYER_PED end
				imgui.AnimationIFP(ped_add)
				imgui.SetCursorPosY(imgui.GetCursorPosY() + 4)
				imgui.Text(config.settings.language == "RU" and 'Выберите стиль ' or 'Choose style ')
				imgui.SameLine()
				imgui.PushItemWidth(90)
				imgui.SetCursorPosY(imgui.GetCursorPosY() - 4)
				imgui.SetCursorPosX(111)
				imgui.PushStyleColor(imgui.Col.HeaderHovered, imgui.ImVec4(0.29, 0.29, 0.29, 0.47))
				imgui.Combo('##Fightstyle', combo_fightstyle, fightstyleTable, #fightstyle)
				imgui.PopStyleColor(1)
				imgui.PopItemWidth()
				imgui.SameLine()
				imgui.SetCursorPosX(203)
				if imgui.Button(config.settings.language == "RU" and 'Применить: '..(fightstyle[combo_fightstyle[0]+1]) or 'Apply style: '..(fightstyle[combo_fightstyle[0]+1]), imgui.ImVec2(189, 25)) then
					local fightstyle_ap = {["Boxing"] = {5,6}, ["KungFu"] = {6,6}, ["MuayThai"] = {7,7}, ["Streetstyle"] = {15,15}}
					local byte_fstyle = fightstyle_ap[""..(fightstyle[combo_fightstyle[0]+1])]
					memory.setint8(getCharPointer(ped_add)+0x72D, byte_fstyle[1], false)
					memory.setint8(getCharPointer(ped_add)+0x72E, byte_fstyle[2], false)
				end

				imgui.SetCursorPosY(imgui.GetCursorPosY() + 4)
				imgui.Text(config.settings.language == "RU" and 'Выберите стиль ' or 'Choose style ')
				imgui.SameLine()
				imgui.PushItemWidth(90)
				imgui.SetCursorPosY(imgui.GetCursorPosY() - 4)
				imgui.SetCursorPosX(111)
				imgui.PushStyleColor(imgui.Col.HeaderHovered, imgui.ImVec4(0.29, 0.29, 0.29, 0.47))
				imgui.Combo('##Walkstyle', combo_walkstyle, walkstyleTable, #walkstyle)
				imgui.PopStyleColor(1)
				imgui.PopItemWidth()
				imgui.SameLine()
				imgui.SetCursorPosX(203)
				if imgui.Button(config.settings.language == "RU" and 'Применить: '..(walkstyle[combo_walkstyle[0]+1]) or 'Apply style: '..(walkstyle[combo_walkstyle[0]+1]), imgui.ImVec2(189, 25)) then
					local walkstyle_ap = {"player", 'man', 'shuffle', 'oldman', 'gang1', 'gang2', 'oldfatman', 'fatman', 'drunkman', 'blindman', 'swat', 'jogger', 'woman', 'shopping', 'busywoman', 'sexywoman', 'pro', 'oldwoman', 'fatwoman', 'jogwoman', 'oldfatwoman'}
					local byte_fstyle =
					setAnimGroupForChar(ped_add, walkstyle_ap[combo_walkstyle[0]+1])
				end
				if lpedfuncs then
					imgui.PedFuncs(ped_add, true)
				end
				imgui.Text((config.settings.language == "RU" and 'Прозрачность  ' or 'Transparency  '))
				imgui.SameLine()
				imgui.PushItemWidth(230)
				imgui.SetCursorPosX(152)
				if imgui.SliderFloat("##SetRwObjectAlpha", RwSkinAlpha, 0, 255, "%.1f") then
					SetRwObjectAlpha(ped_add, RwSkinAlpha[0])
				end
				imgui.PopItemWidth()
				--
				imgui.SetCursorPosY(imgui.GetCursorPosY() + 4)
				imgui.Text((config.settings.language == "RU" and 'Скорость поворота  ' or 'Rotation speed  '))
				if imgui.IsItemHovered() then
					imgui.BeginTooltip()
					imgui.PushTextWrapPos(600)
					imgui.TextUnformatted(config.settings.language == "RU" and 'Стандартная скорость: CJ: 9, C быстрым поворотом): 15, Остальные: 7.5' or 'Standard speed: CJ: 9, With quick turn): 15, Other: 7.5')
					imgui.PopTextWrapPos()
					imgui.EndTooltip()
				end
				imgui.SameLine()

				imgui.SetCursorPosY(imgui.GetCursorPosY() - 4)
				imgui.SetCursorPosX(152)
				imgui.PushItemWidth(204)
				Rotation_speed[0] = memory.getfloat(getCharPointer(ped_add) + 0x560)
				if imgui.SliderFloat("##Rotation_speed12", Rotation_speed, 0, 35, "%.1f") then
					memory.setfloat(getCharPointer(ped_add) + 0x560, Rotation_speed[0])
				end
				imgui.PopItemWidth()
				if imgui.IsItemHovered() then
					imgui.BeginTooltip()
					imgui.PushTextWrapPos(600)
					imgui.TextUnformatted(config.settings.language == "RU" and 'CTRL + LMB ввести значение вручную' or 'CTRL + LMB to enter value manually')
					imgui.PopTextWrapPos()
					imgui.EndTooltip()
				end
				imgui.SameLine()
				if imgui.Checkbox("##checkbox_fAngle1", checkbox_fAngle) then
					if checkbox_fAngle[0] then
						memory.fill(0x5E4DA1, 0xEB, 0x1)
						memory.fill(0x5E4DF6, 0xEB, 0x1)
					else
						memory.fill(0x5E4DA1, 0x75, 0x1)
						memory.fill(0x5E4DF6, 0x75, 0x1)
					end
				end
				if imgui.IsItemHovered() then
					imgui.BeginTooltip()
					imgui.PushTextWrapPos(600)
					imgui.TextUnformatted(config.settings.language == "RU" and 'Активируйте, чтобы убрать анимацию поворота скина.\nДеактивируйте, чтобы вернуть анимацию.' or 'Activate to remove skin rotation animation.\nDeactivate to return animation.')
					imgui.PopTextWrapPos()
					imgui.EndTooltip()
				end

			end

			imgui.Separator()

			if imgui.CollapsingHeader((config.settings.language == "RU" and 'Настройки' or 'Settings')) then
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 230) / 2)
				imgui.PushItemWidth(100)
				imgui.InputTextWithHint('##Введите команду', config.settings.cmd, cmdbuffer, ffi.sizeof(cmdbuffer) - 1, imgui.InputTextFlags.AutoSelectAll)
				imgui.TutorialHint('but_nick1', config.settings.language == "RU" and 'Поле ввода пустое или содержит символ "/"\nВведите команду без "/"' or 'Input field is empty or contains "/" symbol\nEnter command without "/"', but_cmd, true)
					if imgui.IsItemHovered() then
						imgui.BeginTooltip()
						imgui.PushTextWrapPos(600)
							imgui.TextUnformatted(config.settings.language == "RU" and 'Чтобы изменить команду активации\nвведите команду без "/"' or 'To change activation command\nenter command without "/"')
						imgui.PopTextWrapPos()
						imgui.EndTooltip()
					end
				imgui.PopItemWidth()
				imgui.SameLine()
				if imgui.Button((config.settings.language == "RU" and 'Сохранить команду' or "Save the command"), imgui.ImVec2(130, 0)) then
					sampUnregisterChatCommand(config.settings.cmd)
					config.settings.cmd = ffi.string(cmdbuffer)
					sampRegisterChatCommand(config.settings.cmd, chat_command)
					sampSetClientCommandDescription(config.settings.cmd, (string.format(u8:decode'Активация/деактивация окна %s, /%s id IdSkin(смена скина без привязки), Файл: %s', thisScript().name, config.settings.cmd, thisScript().filename)))
					savejson(convertTableToJsonString(config), "moonloader/config/PersonalSkinChanger.json")
					if ffi.string(cmdbuffer) == nil or ffi.string(cmdbuffer) == '' or ffi.string(cmdbuffer) == ' ' or ffi.string(cmdbuffer):find('/.+') then
						lua_thread.create(function()
							but_cmd[0] = true
							wait(2074)
							but_cmd[0] = false
						end)
						config.settings.cmd = 'fskin'
						savejson(convertTableToJsonString(config), "moonloader/config/PersonalSkinChanger.json")
					end
				end
			end

			imgui.Separator()

			if not menu.state then
				if preview_skin then
					delete_spawnCharFunc()
				end
				if sampTextdrawIsExists(2048) then
					sampTextdrawDelete(2048)
				end
				Deactivated_sb()
			end

        imgui.End()
        imgui.PopStyleVar()
    end
)

function imgui.AnimationIFP(handle)
	imgui.Text((config.settings.language == "RU" and 'Анимации  ' or 'Animations  '))
	imgui.SameLine()
	imgui.SetCursorPosY(imgui.GetCursorPosY() + 1)
	if imgui.SmallButton("Reset##anim1") then
		clearCharTasks(handle)
	end
	imgui.SameLine()
	imgui.SetCursorPosY(imgui.GetCursorPosY() - 1)
	imgui.PushStyleColor(imgui.Col.HeaderHovered, imgui.ImVec4(0.29, 0.29, 0.29, 0.47))

	if imgui.BeginMenu((config.settings.language == "RU" and 'Список анимаций  ' or 'List of animations  '), true) then
		local anims = loadGameAnims()
		for k, aList in pairs(anims) do
			if imgui.BeginMenu(k.."##"..k, true) then
				for i, v in ipairs(aList) do
					if imgui.BeginMenu(v.."##"..i, true) then
						if imgui.MenuItemBool((config.settings.language == "RU" and 'Один раз##' or 'Once##')..i, "", false, true) then
							playanimationNow(handle, k, v, false, false)
						end
						if imgui.MenuItemBool((config.settings.language == "RU" and 'Заморозить##' or 'Freeze##')..i, "", false, true) then
							playanimationNow(handle, k, v, false, true)
						end
						if imgui.MenuItemBool((config.settings.language == "RU" and 'Зациклить##' or 'Loop##')..i, "", false, true) then
							playanimationNow(handle, k, v, true, false)
						end
						imgui.Separator()
						if imgui.MenuItemBool((config.settings.language == "RU" and 'Скопировать название##' or 'Copy the name##')..i, "", false, true) then
							local text = string.format("%s, %s", k:upper(), v:upper())
							setClipboardText(text)
						end
						imgui.EndMenu()
					end
				end
			imgui.EndMenu()
			end

		end
	imgui.EndMenu()
	end
	imgui.PopStyleColor(1)
end

function playanimationNow(ped, ifp, anim, loop, freeze)
	if doesCharExist(ped) then
		if not hasAnimationLoaded(ifp) then
			requestAnimation(ifp)
			loadAllModelsNow()
		end
		taskPlayAnimSecondary(ped, anim, ifp, 4.0, loop, true, true, freeze, -1)
	end
end

function imgui.PedFuncs(handle, addr_bool)
	if lpedfuncs then
		if pedfuncs.Ext_GetPedRemap(getCharPointer(handle), index) <= -1 then
			pedfuncs.Ext_SetPedRemap(getCharPointer(handle), index, -1)
		end
		local remap = pedfuncs.Ext_GetPedRemap(getCharPointer(handle), index)
		imgui.SetCursorPosY(imgui.GetCursorPosY() + 4)
		-- local model_Id = getCharModel(handle)
		imgui.Text("Assistant for PedFuncs  ")
		imgui.SameLine()
		imgui.SetCursorPosY(imgui.GetCursorPosY() - 4)
		if imgui.Button("/\\", imgui.ImVec2(25, 25)) then
			if index >= 0 and index <= 8 then
				index = index + 1
				if index <= 0 or index > 8 then
					index = 0
				end
			end
		end
		imgui.SameLine()
		imgui.Text((config.settings.language == "RU" and " index: " or " index: ") ..index)
		if imgui.IsItemHovered() then
			imgui.BeginTooltip()
			imgui.PushTextWrapPos(600)
				imgui.TextUnformatted(config.settings.language == "RU" and 'Переключение между текстурами, например, bmydj_remap на neckcross_remap1.\nВсего доступно для изменения текстур: 8' or 'Switching between textures, e.g. bmydj_remap to neckcross_remap.\nTotal available for changing textures: 8')
			imgui.PopTextWrapPos()
			imgui.EndTooltip()
		end
		imgui.SameLine()
		if imgui.Button("\\/", imgui.ImVec2(25, 25)) then
			if index >= 0 and index <= 8 then
				index = index - 1
				if index <= 0 or index > 8 then
					index = 0
				end
			end
		end
		imgui.SameLine()
		imgui.SetCursorPosX(imgui.GetCursorPosX() + 4)
		if imgui.Button("-", imgui.ImVec2(25, 25)) then
			pedfuncs.Ext_SetPedRemap(getCharPointer(handle), index, remap - 1)
		end

		imgui.SameLine()
		imgui.Text((config.settings.language == "RU" and " remap: " or " remap: ")..remap)
		if imgui.IsItemHovered() then
			imgui.BeginTooltip()
			imgui.PushTextWrapPos(600)
				imgui.TextUnformatted(config.settings.language == "RU" and 'Отсчет начинается с конца, например, bmydj_remap0 равен bmydj_remap(последний) в .txd' or 'Counting goes from end, example, bmydj_remap0 is equal to bmydj_remap(last) in .txd')
			imgui.PopTextWrapPos()
			imgui.EndTooltip()
		end
		imgui.SameLine()
		if imgui.Button("+", imgui.ImVec2(25, 25)) then
			pedfuncs.Ext_SetPedRemap(getCharPointer(handle), index, remap + 1)
		end
		if not preview_skin and not doesCharExist(peshPed) and addr_bool then
			imgui.SetCursorPosY(imgui.GetCursorPosY() + 4)
			imgui.Text("Привязка текстур  ")
			imgui.SameLine()
			imgui.SetCursorPosY(imgui.GetCursorPosY() - 4)
			imgui.SetCursorPosX(152)
			if imgui.Button(config.settings.language == "RU" and ('Привязать к нику index: '..index.." remap: "..remap) or ('Attach to nickname index: '..index.." remap: "..remap), imgui.ImVec2(230, 25)) then
				local mynick_pedfuncs = sampGetPlayerNickname(memory.getuint16(sampGetPlayerPoolPtr() + 4, true))
				local nick_pedfuncs = ffi.string(nick) == "" and mynick_pedfuncs or ffi.string(nick)
				if config.pedfuncs[''..nick_pedfuncs] ~= nil then
					config.pedfuncs[''..nick_pedfuncs]['index'..index] = tonumber(remap)
				-- config.pedfuncs[""..nick_pedfuncs] = {"F"}
					savejson(convertTableToJsonString(config), "moonloader/config/PersonalSkinChanger.json")
					else
					lua_thread.create(function()
						but_pedfuncs[0] = true
						wait(2074)
						but_pedfuncs[0] = false
					end)
				end

			end
			imgui.TutorialHint('but_pedfuncs1', config.settings.language == "RU" and 'Скин должен быть привязан к нику!' or 'Skin must be attached to the nickname!', but_pedfuncs, true)
		end
		-- print()
	end
end


function imgui.TutorialHint(str_id, text, bool, hideOnClick) -- https://www.blast.hk/threads/13380/post-657559
    local p_orig = imgui.GetCursorPos()
    if hideOnClick == nil then hideOnClick = true end

    imgui.SameLine(nil, 0)
    local size = imgui.GetItemRectSize()
    local scrPos = imgui.GetCursorScreenPos()
    local DL = imgui.GetWindowDrawList()
    local center = imgui.ImVec2( scrPos.x - (size.x / 2), scrPos.y + (size.y / 2) )

    if bool[0] then
        local a = imgui.ImVec2( center.x - 8, center.y - size.y - 1 )
        local b = imgui.ImVec2( center.x + 8, center.y - size.y - 1)
        local c = imgui.ImVec2( center.x, center.y - size.y + 7 )
        DL:AddTriangleFilled(a, b, c, imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabActive]))
        imgui.SetNextWindowPos(imgui.ImVec2(center.x, center.y - size.y - 3), imgui.Cond.Always, imgui.ImVec2(0.5, 1.0))
        imgui.PushStyleColor(imgui.Col.WindowBg, imgui.GetStyle().Colors[imgui.Col.PopupBg])
        imgui.PushStyleColor(imgui.Col.Border, imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabActive])
        imgui.Begin('##' .. str_id, _, imgui.WindowFlags.Tooltip + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoTitleBar)
            local width = imgui.GetWindowWidth()
            for line in text:gmatch('[^\r\n]+') do
                local len = imgui.CalcTextSize(line).x
                imgui.SetCursorPosX(width / 2 - ( len / 2 ))
                imgui.Text(line)
            end

            if hideOnClick and imgui.IsMouseClicked(0) then
                local wp = imgui.GetWindowPos()
                local ws = imgui.GetWindowSize()
                local m = imgui.GetMousePos()
                if m.x >= wp.x and m.y >= wp.y and m.x <= wp.x + ws.x and m.y <= wp.y + ws.y then
                    bool[0] = not bool[0]
                end
            end
        imgui.End()
        imgui.PopStyleColor(2)
    end

    imgui.SetCursorPos(p_orig)
end

function Deactivated_sb()
	for i = 1, #button_skin do
		button_skin[i][0] = false
	end
	for i = 1, #button_skin_new do
		button_skin_new[i][0] = false
	end
	GenderBySkin = 'all'
	female_button[0] = false
	male_button[0] = false
end

function imgui.SelectButton(name, bool, size) -- by CaJlaT, minimal edited dmitriyewich
	if bool[0] then
		imgui.PushStyleColor(imgui.Col.Button, imgui.GetStyle().Colors[imgui.Col.ButtonActive])
		imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.GetStyle().Colors[imgui.Col.ButtonHovered])
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.GetStyle().Colors[imgui.Col.Button])
	else
		imgui.PushStyleColor(imgui.Col.Button, imgui.GetStyle().Colors[imgui.Col.Button])
		imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.GetStyle().Colors[imgui.Col.ButtonHovered])
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.GetStyle().Colors[imgui.Col.ButtonActive])
	end
	if not size then size = imgui.ImVec2(0, 0) end
	local result = imgui.Button(name, size)
	imgui.PopStyleColor(3)
	if result then bool[0] = not bool[0] end
	return result
end

function imgui.ToggleButton(str_id, bool) -- https://www.blast.hk/threads/13380/post-230475

	local rBool = false

	if LastActiveTime == nil then
	LastActiveTime = {}
	end
	if LastActive == nil then
	LastActive = {}
	end

	local function ImSaturate(f)
	return f < 0.0 and 0.0 or (f > 1.0 and 1.0 or f)
	end

	local p = imgui.GetCursorScreenPos()
	local draw_list = imgui.GetWindowDrawList()

	local height = imgui.GetTextLineHeightWithSpacing() * 1.0

	local width = height * 2.2
	local radius = height * 0.50

	local ANIM_SPEED = 0.15

	if imgui.InvisibleButton(str_id, imgui.ImVec2(width, height)) then
	bool[0] = not bool[0]
	rBool = true
	LastActiveTime[tostring(str_id)] = os.clock()
	LastActive[str_id] = true
	end

	local t = bool[0] and 1.0 or 0.0

	if LastActive[str_id] then
	local time = os.clock() - LastActiveTime[tostring(str_id)]
	if time <= ANIM_SPEED then
		local t_anim = ImSaturate(time / ANIM_SPEED)
		t = bool[0] and t_anim or 1.0 - t_anim
	else
		LastActive[str_id] = false
	end
	end

	local col_bg
	if imgui.IsItemHovered() then
	col_bg = imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.FrameBgHovered])
	else
	col_bg = imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.FrameBg])
	end

	draw_list:AddRectFilled(p, imgui.ImVec2(p.x + width, p.y + height), col_bg, height * 0.5)
	draw_list:AddCircleFilled(imgui.ImVec2(p.x + radius + t * (width - radius * 2.0), p.y + radius), radius - 1.5, imgui.ColorConvertFloat4ToU32(bool[0] and imgui.GetStyle().Colors[imgui.Col.DragDropTarget] or imgui.GetStyle().Colors[imgui.Col.DragDropTarget]))

	return rBool
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


function onWindowMessage(msg, wparam, lparam)
	if msg == wm.WM_KEYDOWN and wparam == 0x1B and menu.state then
		menu.switch()
		consumeWindowMessage(true, false)
	end
end

if lsampev then
	function sampev.onPlayerStreamIn(playerId, team, model, position, rotation, color, fightingStyle)
		for k, v in pairs(config.skins) do
			if k == sampGetPlayerNickname(playerId) then
				local res_set, ped_set = sampGetPlayerHandleByNickname(k)
				if res_set then
					config.skinslast[k] = skinId
					savejson(convertTableToJsonString(config), "moonloader/config/PersonalSkinChanger.json")
					setCharModelId(ped_set, v)
					SetPedRemap(k, ped_set)
				end
			end
		end
	end

	function sampev.onSetSpawnInfo(team, skin, _unused, position, rotation, weapons, ammo)
		for k, v in pairs(config.skins) do
			local res_set, ped_set = sampGetPlayerHandleByNickname(k)
			if res_set and team ~= 0 then
				setCharModelId(ped_set, v)
				SetPedRemap(k, ped_set)
			end
		end
	end

	function sampev.onSetPlayerSkin(playerId, skinId)
		for k, v in pairs(config.skins) do
			if k == sampGetPlayerNickname(playerId) then
				local res_set, ped_set = sampGetPlayerHandleByNickname(k)
				if res_set then
					config.skinslast[k] = skinId
					savejson(convertTableToJsonString(config), "moonloader/config/PersonalSkinChanger.json")
					setCharModelId(ped_set, v)
					SetPedRemap(k, ped_set)
				end
			end
		end
	end
end

function SetPedRemap(nick, handle_p)
	if lpedfuncs and config.pedfuncs[''..nick] ~= nil then
		lua_thread.create(function() wait(1)
			for index, remap in pairs(config.pedfuncs[''..nick]) do
				local index = index:gsub("(index)", "")
				pedfuncs.Ext_SetPedRemap(getCharPointer(handle_p), tonumber(index), tonumber(remap))
			end
		end)
	end
end

function SetRwObjectAlpha(handle, alpha) -- by seven.
    local pedEn = getCharPointer(handle)
    if pedEn ~= 0 then
        ffi.cast("void (__thiscall *)(int, int)", 0x5332C0)(pedEn, alpha)
    end
end

function checkskin(modelId)
	local checkskin_tbl = {}
	local hash = {}
	for i = 0, 311 do
		if isModelAvailable(i) and isModelInCdimage(i) then
			checkskin_tbl[i] = true
		end
	end
	for i = 1, #config.newskins do
		if isModelAvailable(i) and isModelInCdimage(i) then
			checkskin_tbl[config.newskins[i]] = true
		end
	end
	if checkskin_tbl[modelId] == nil then return false end
	return checkskin_tbl[modelId]
end

function setCharModelId(pedHandle, modelId) -- by dmitriyewich
	lua_thread.create(function() wait(1)
		local charPtr = getCharPointer(pedHandle)
		local modelId = tonumber(modelId)

		if charPtr >= 1 and checkskin(modelId) then
			if not hasModelLoaded(modelId) then
				requestModel(modelId)
				loadAllModelsNow()
			end
			ffi.cast("void (__thiscall *)(int, int)", 0x5E4880)(charPtr, modelId)
			clearCharTasks(pedHandle)
			markModelAsNoLongerNeeded(modelID)
		end
	end)
end

function delete_spawnCharFunc()
	if doesCharExist(peshPed) then
		deleteChar(peshPed)
	-- else
		-- local resX, resY = getScreenResolution()
		-- for k, v in ipairs(getAllChars()) do
			-- local res, id = sampGetPlayerIdByCharHandle(v)
			-- if not res then
				-- local my_pos = {getActiveCameraCoordinates()}
				-- local other_pos = {convertScreenCoordsToWorld3D(resX / 3.5, resY / 1.6, 2.5)}
				-- if getDistanceBetweenCoords3d(my_pos[1], my_pos[2], my_pos[3], other_pos[1], other_pos[2], other_pos[3]) < 4.0 and isCharOnScreen(v) then
					-- deleteChar(v)
					-- preview_skin = false
				-- end
			-- end
		-- end
	end
end

function spawnCharFunc(modelID, w, h)
	if doesCharExist(peshPed) then
		delete_spawnCharFunc()
	end
	requestModel(modelID)
	loadAllModelsNow()
	local posX, posY, posZ = convertScreenCoordsToWorld3D(w + 547, h + 474, 3.0)
	peshPed = createChar(24, modelID, posX, posY, posZ)
	setCharCollision(peshPed, false)
	freezeCharPosition(peshPed, true)
	preview_skin = true
	taskPlayAnimNonInterruptable(peshPed, NULL, NULL, 1, true, false, false, false, -1)
	markModelAsNoLongerNeeded(modelID)
end

function sampGetPlayerHandleByNickname(nick) -- https://www.blast.hk/threads/13380/post-164090, minimal editing dmitriyewich
    local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
    if tostring(nick) == sampGetPlayerNickname(myid) then return true, PLAYER_PED end
    for i = 0, 1000 do if sampIsPlayerConnected(i) and sampGetPlayerNickname(i) == tostring(nick) then
		local result, ped = sampGetCharHandleBySampPlayerId(i)
		return true, ped end
	end
	return false
end

function getGenderBySkinId(gender) -- by Quasper, minimal editing dmitriyewich
	local male = {0, 1, 2, 3, 4, 5, 6, 7, 8, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 32, 33, 34, 35, 36, 37, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 57, 58, 59, 60, 61, 62, 66, 67, 68, 70, 71, 72, 73, 78, 79, 80, 81, 82, 83, 84, 86, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 132, 133, 134, 135, 136, 137, 142, 143, 144, 146, 147, 149, 153, 154, 155, 156, 158, 159, 160, 161, 162, 163, 164, 165, 166, 167, 168, 170, 171, 173, 174, 175, 176, 177, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 200, 202, 203, 204, 206, 208, 209, 210, 212, 213, 217, 220, 221, 222, 223, 227, 228, 229, 230, 234, 235, 236, 239, 240, 241, 242, 247, 248, 249, 250, 252, 253, 254, 255, 258, 259, 260, 261, 262, 264, 265, 266, 267, 268, 269, 270, 271, 272, 273, 274, 275, 276, 277, 278, 279, 280, 281, 282, 283, 284, 285, 286, 287, 288, 289, 290, 291, 292, 293, 294, 295, 296, 297, 299, 300, 301, 302, 303, 304, 305, 310, 311}
	local female = {9, 10, 11, 12, 13, 31, 38, 39, 40, 41, 53, 54, 55, 56, 63, 64, 65, 69, 75, 76, 77, 85, 87, 88, 89, 90, 91, 92, 93, 129, 130, 131, 138, 139, 140, 141, 145, 148, 150, 151, 152, 157, 169, 172, 178, 190, 191, 192, 193, 194, 195, 196, 197, 198, 199, 201, 205, 207, 211, 214, 215, 216, 218, 219, 224, 225, 226, 231, 232, 233, 237, 238, 243, 244, 245, 246, 251, 256, 257, 263, 298, 306, 307, 308, 309}
	if gender == "female" then return female end
	if gender == "male" then return male end
	if gender == "all" then
		for i=1,#female do
			male[#male+1] = female[i]
		end

		return male
	end
	local what = {0}
	return what
end

function checktable(t, str)
	for k, v in pairs(t) do
		if v == str then return true end
	end
	return false
end

function textdraw_skin(arg)
	arg = tonumber(arg)
	sampTextdrawCreate(2048, "Test", 150.0, 150.0)
	sampTextdrawSetStyle(2048, 5)
	sampTextdrawSetBoxColorAndSize(2048, false, 0xFFFFFF00, 274.0, 274.0)
	sampTextdrawSetModelRotationZoomVehColor(2048, tonumber(arg), 0.0, 0.0, 0.0, 0.95, 0, 0)
	sampTextdrawSetShadow(2048, _, 0x00)
	setTextDrawBeforeFade(true)
	local mainWinPos = imgui.GetWindowPos()
	local gposX, gposY = convertWindowScreenCoordsToGameScreenCoords(mainWinPos.x, mainWinPos.y)
	sampTextdrawSetPos(2048, gposX+50, gposY-25)
end

function onScriptTerminate(s, q)
    if s == thisScript() then
		if sampTextdrawIsExists(2048) then
			sampTextdrawDelete(2048)
		end
		delete_spawnCharFunc()
	end
end

function loadGameAnims()
	return {
        ['Attractors'] = {
                'Stepsit_in',
                'Stepsit_loop',
                'Stepsit_out'
        },

        ['BAR'] = {
                'Barcustom_get',
                'Barcustom_loop',
                'Barcustom_order',
                'BARman_idle',
                'Barserve_bottle',
                'Barserve_give',
                'Barserve_glass',
                'Barserve_in',
                'Barserve_loop',
                'Barserve_order',
                'dnk_stndF_loop',
                'dnk_stndM_loop'
        },

        ['BASEBALL'] = {
                'Bat_1',
                'Bat_2',
                'Bat_3',
                'Bat_4',
                'Bat_block',
                'Bat_Hit_1',
                'Bat_Hit_2',
                'Bat_Hit_3',
                'Bat_IDLE',
                'Bat_M',
                'BAT_PART'
        },

        ['BD_FIRE'] = {
                'BD_Fire1',
                'BD_Fire2',
                'BD_Fire3',
                'BD_GF_Wave',
                'BD_Panic_01',
                'BD_Panic_02',
                'BD_Panic_03',
                'BD_Panic_04',
                'BD_Panic_Loop',
                'Grlfrd_Kiss_03',
                'M_smklean_loop',
                'Playa_Kiss_03',
                'wash_up'
        },

        ['BEACH'] = {
                'bather',
                'Lay_Bac_Loop',
                'ParkSit_M_loop',
                'ParkSit_W_loop',
                'SitnWait_loop_W'
        },

        ['benchpress'] = {
                'gym_bp_celebrate',
                'gym_bp_down',
                'gym_bp_getoff',
                'gym_bp_geton',
                'gym_bp_up_A',
                'gym_bp_up_B',
                'gym_bp_up_smooth'
        },

        ['BF_injection'] = {
                'BF_getin_LHS',
                'BF_getin_RHS',
                'BF_getout_LHS',
                'BF_getout_RHS'
        },

        ['BIKED'] = {
                'BIKEd_Back',
                'BIKEd_drivebyFT',
                'BIKEd_drivebyLHS',
                'BIKEd_drivebyRHS',
                'BIKEd_Fwd',
                'BIKEd_getoffBACK',
                'BIKEd_getoffLHS',
                'BIKEd_getoffRHS',
                'BIKEd_hit',
                'BIKEd_jumponL',
                'BIKEd_jumponR',
                'BIKEd_kick',
                'BIKEd_Left',
                'BIKEd_passenger',
                'BIKEd_pushes',
                'BIKEd_Ride',
                'BIKEd_Right',
                'BIKEd_shuffle',
                'BIKEd_Still'
        },

        ['BIKEH'] = {
                'BIKEh_Back',
                'BIKEh_drivebyFT',
                'BIKEh_drivebyLHS',
                'BIKEh_drivebyRHS',
                'BIKEh_Fwd',
                'BIKEh_getoffBACK',
                'BIKEh_getoffLHS',
                'BIKEh_getoffRHS',
                'BIKEh_hit',
                'BIKEh_jumponL',
                'BIKEh_jumponR',
                'BIKEh_kick',
                'BIKEh_Left',
                'BIKEh_passenger',
                'BIKEh_pushes',
                'BIKEh_Ride',
                'BIKEh_Right',
                'BIKEh_Still'
        },

        ['BIKELEAP'] = {
                'bk_blnce_in',
                'bk_blnce_out',
                'bk_jmp',
                'bk_rdy_in',
                'bk_rdy_out',
                'struggle_cesar',
                'struggle_driver',
                'truck_driver',
                'truck_getin'
        },

        ['BIKES'] = {
                'BIKEs_Back',
                'BIKEs_drivebyFT',
                'BIKEs_drivebyLHS',
                'BIKEs_drivebyRHS',
                'BIKEs_Fwd',
                'BIKEs_getoffBACK',
                'BIKEs_getoffLHS',
                'BIKEs_getoffRHS',
                'BIKEs_hit',
                'BIKEs_jumponL',
                'BIKEs_jumponR',
                'BIKEs_kick',
                'BIKEs_Left',
                'BIKEs_passenger',
                'BIKEs_pushes',
                'BIKEs_Ride',
                'BIKEs_Right',
                'BIKEs_Snatch_L',
                'BIKEs_Snatch_R',
                'BIKEs_Still'
        },

        ['BIKEV'] = {
                'BIKEv_Back',
                'BIKEv_drivebyFT',
                'BIKEv_drivebyLHS',
                'BIKEv_drivebyRHS',
                'BIKEv_Fwd',
                'BIKEv_getoffBACK',
                'BIKEv_getoffLHS',
                'BIKEv_getoffRHS',
                'BIKEv_hit',
                'BIKEv_jumponL',
                'BIKEv_jumponR',
                'BIKEv_kick',
                'BIKEv_Left',
                'BIKEv_passenger',
                'BIKEv_pushes',
                'BIKEv_Ride',
                'BIKEv_Right',
                'BIKEv_Still'
        },

        ['BIKE_DBZ'] = {
                'Pass_Driveby_BWD',
                'Pass_Driveby_FWD',
                'Pass_Driveby_LHS',
                'Pass_Driveby_RHS'
        },

        ['BLOWJOBZ'] = {
                'BJ_COUCH_START_W',
                'BJ_COUCH_LOOP_W',
                'BJ_COUCH_END_W',
                'BJ_COUCH_START_P',
                'BJ_COUCH_LOOP_P',
                'BJ_COUCH_END_P',
                'BJ_STAND_START_W',
                'BJ_STAND_LOOP_W',
                'BJ_STAND_END_W',
                'BJ_STAND_START_P',
                'BJ_STAND_LOOP_P',
                'BJ_STAND_END_P'
        },

        ['BMX'] = {
                'BMX_back',
                'BMX_bunnyhop',
                'BMX_drivebyFT',
                'BMX_driveby_LHS',
                'BMX_driveby_RHS',
                'BMX_fwd',
                'BMX_getoffBACK',
                'BMX_getoffLHS',
                'BMX_getoffRHS',
                'BMX_jumponL',
                'BMX_jumponR',
                'BMX_Left',
                'BMX_pedal',
                'BMX_pushes',
                'BMX_Ride',
                'BMX_Right',
                'BMX_sprint',
                'BMX_still'
        },

        ['BOMBER'] = {
                'BOM_Plant',
                'BOM_Plant_2Idle',
                'BOM_Plant_Crouch_In',
                'BOM_Plant_Crouch_Out',
                'BOM_Plant_In',
                'BOM_Plant_Loop'
        },

        ['BOX'] = {
                'boxhipin',
                'boxhipup',
                'boxshdwn',
                'boxshup',
                'bxhipwlk',
                'bxhwlki',
                'bxshwlk',
                'bxshwlki',
                'bxwlko',
                'catch_box'
        },

        ['BSKTBALL'] = {
                'BBALL_def_jump_shot',
                'BBALL_def_loop',
                'BBALL_def_stepL',
                'BBALL_def_stepR',
                'BBALL_Dnk',
                'BBALL_Dnk_Gli',
                'BBALL_Dnk_Gli_O',
                'BBALL_Dnk_Lnch',
                'BBALL_Dnk_Lnch_O',
                'BBALL_Dnk_Lnd',
                'BBALL_Dnk_O',
                'BBALL_idle',
                'BBALL_idle2',
                'BBALL_idle2_O',
                'BBALL_idleloop',
                'BBALL_idleloop_O',
                'BBALL_idle_O',
                'BBALL_Jump_Cancel',
                'BBALL_Jump_Cancel_O',
                'BBALL_Jump_End',
                'BBALL_Jump_Shot',
                'BBALL_Jump_Shot_O',
                'BBALL_Net_Dnk_O',
                'BBALL_pickup',
                'BBALL_pickup_O',
                'BBALL_react_miss',
                'BBALL_react_score',
                'BBALL_run',
                'BBALL_run_O',
                'BBALL_SkidStop_L',
                'BBALL_SkidStop_L_O',
                'BBALL_SkidStop_R',
                'BBALL_SkidStop_R_O',
                'BBALL_walk',
                'BBALL_WalkStop_L',
                'BBALL_WalkStop_L_O',
                'BBALL_WalkStop_R',
                'BBALL_WalkStop_R_O',
                'BBALL_walk_O',
                'BBALL_walk_start',
                'BBALL_walk_start_O'
        },

        ['BUDDY'] = {
                'buddy_crouchfire',
                'buddy_crouchreload',
                'buddy_fire',
                'buddy_fire_poor',
                'buddy_reload'
        },

        ['BUS'] = {
                'BUS_close',
                'BUS_getin_LHS',
                'BUS_getin_RHS',
                'BUS_getout_LHS',
                'BUS_getout_RHS',
                'BUS_jacked_LHS',
                'BUS_open',
                'BUS_open_RHS',
                'BUS_pullout_LHS'
        },

        ['CAMERA'] = {
                'camcrch_cmon',
                'camcrch_idleloop',
                'camcrch_stay',
                'camcrch_to_camstnd',
                'camstnd_cmon',
                'camstnd_idleloop',
                'camstnd_lkabt',
                'camstnd_to_camcrch',
                'piccrch_in',
                'piccrch_out',
                'piccrch_take',
                'picstnd_in',
                'picstnd_out',
                'picstnd_take'
        },

        ['CAR'] = {
                'Fixn_Car_Loop',
                'Fixn_Car_Out',
                'flag_drop',
                'Sit_relaxed',
                'Tap_hand',
                'Tyd2car_bump',
                'Tyd2car_high',
                'Tyd2car_low',
                'Tyd2car_med',
                'Tyd2car_TurnL',
                'Tyd2car_TurnR'
        },

        ['CARRY'] = {
                'crry_prtial',
                'liftup',
                'liftup05',
                'liftup105',
                'putdwn',
                'putdwn05',
                'putdwn105'
        },

        ['CAR_CHAT'] = {
                'carfone_in',
                'carfone_loopA',
                'carfone_loopA_to_B',
                'carfone_loopB',
                'carfone_loopB_to_A',
                'carfone_out',
                'CAR_Sc1_BL',
                'CAR_Sc1_BR',
                'CAR_Sc1_FL',
                'CAR_Sc1_FR',
                'CAR_Sc2_FL',
                'CAR_Sc3_BR',
                'CAR_Sc3_FL',
                'CAR_Sc3_FR',
                'CAR_Sc4_BL',
                'CAR_Sc4_BR',
                'CAR_Sc4_FL',
                'CAR_Sc4_FR',
                'car_talkm_in',
                'car_talkm_loop',
                'car_talkm_out'
        },

        ['CASINO'] = {
                'cards_in',
                'cards_loop',
                'cards_lose',
                'cards_out',
                'cards_pick_01',
                'cards_pick_02',
                'cards_raise',
                'cards_win',
                'dealone',
                'manwinb',
                'manwind',
                'Roulette_bet',
                'Roulette_in',
                'Roulette_loop',
                'Roulette_lose',
                'Roulette_out',
                'Roulette_win',
                'Slot_bet_01',
                'Slot_bet_02',
                'Slot_in',
                'Slot_lose_out',
                'Slot_Plyr',
                'Slot_wait',
                'Slot_win_out',
                'wof'
        },

        ['CHAINSAW'] = {
                'CSAW_1',
                'CSAW_2',
                'CSAW_3',
                'CSAW_G',
                'CSAW_Hit_1',
                'CSAW_Hit_2',
                'CSAW_Hit_3',
                'csaw_part',
                'IDLE_csaw',
                'WEAPON_csaw',
                'WEAPON_csawlo'
        },

        ['CHOPPA'] = {
                'CHOPPA_back',
                'CHOPPA_bunnyhop',
                'CHOPPA_drivebyFT',
                'CHOPPA_driveby_LHS',
                'CHOPPA_driveby_RHS',
                'CHOPPA_fwd',
                'CHOPPA_getoffBACK',
                'CHOPPA_getoffLHS',
                'CHOPPA_getoffRHS',
                'CHOPPA_jumponL',
                'CHOPPA_jumponR',
                'CHOPPA_Left',
                'CHOPPA_pedal',
                'CHOPPA_Pushes',
                'CHOPPA_ride',
                'CHOPPA_Right',
                'CHOPPA_sprint',
                'CHOPPA_Still'
        },

        ['CLOTHES'] = {
                'CLO_Buy',
                'CLO_In',
                'CLO_Out',
                'CLO_Pose_Hat',
                'CLO_Pose_In',
                'CLO_Pose_In_O',
                'CLO_Pose_Legs',
                'CLO_Pose_Loop',
                'CLO_Pose_Out',
                'CLO_Pose_Out_O',
                'CLO_Pose_Shoes',
                'CLO_Pose_Torso',
                'CLO_Pose_Watch'
        },

        ['COACH'] = {
                'COACH_inL',
                'COACH_inR',
                'COACH_opnL',
                'COACH_opnR',
                'COACH_outL',
                'COACH_outR'
        },

        ['COLT45'] = {
                '2guns_crouchfire',
                'colt45_crouchfire',
                'colt45_crouchreload',
                'colt45_fire',
                'colt45_fire_2hands',
                'colt45_reload',
                'sawnoff_reload'
        },

        ['COP_AMBIENT'] = {
                'Copbrowse_in',
                'Copbrowse_loop',
                'Copbrowse_nod',
                'Copbrowse_out',
                'Copbrowse_shake',
                'Coplook_in',
                'Coplook_loop',
                'Coplook_nod',
                'Coplook_out',
                'Coplook_shake',
                'Coplook_think',
                'Coplook_watch'
        },

        ['COP_DVBYZ'] = {
                'COP_Dvby_B',
                'COP_Dvby_FT',
                'COP_Dvby_L',
                'COP_Dvby_R'
        },

        ['CRACK'] = {
                'Bbalbat_Idle_01',
                'Bbalbat_Idle_02',
                'crckdeth1',
                'crckdeth2',
                'crckdeth3',
                'crckdeth4',
                'crckidle1',
                'crckidle2',
                'crckidle3',
                'crckidle4'
        },

        ['CRIB'] = {
                'CRIB_Console_Loop',
                'CRIB_Use_Switch',
                'PED_Console_Loop',
                'PED_Console_Loose',
                'PED_Console_Win'
        },

        ['DAM_JUMP'] = {
                'DAM_Dive_Loop',
                'DAM_Land',
                'DAM_Launch',
                'Jump_Roll',
                'SF_JumpWall'
        },

        ['DANCING'] = {
                'bd_clap',
                'bd_clap1',
                'dance_loop',
                'DAN_Down_A',
                'DAN_Left_A',
                'DAN_Loop_A',
                'DAN_Right_A',
                'DAN_Up_A',
                'dnce_M_a',
                'dnce_M_b',
                'dnce_M_c',
                'dnce_M_d',
                'dnce_M_e'
        },

        ['DEALER'] = {
                'DEALER_DEAL',
                'DEALER_IDLE',
                'DEALER_IDLE_01',
                'DEALER_IDLE_02',
                'DEALER_IDLE_03',
                'DRUGS_BUY',
                'shop_pay'
        },

        ['DILDO'] = {
                'DILDO_1',
                'DILDO_2',
                'DILDO_3',
                'DILDO_block',
                'DILDO_G',
                'DILDO_Hit_1',
                'DILDO_Hit_2',
                'DILDO_Hit_3',
                'DILDO_IDLE'
        },

        ['DODGE'] = {
                'Cover_Dive_01',
                'Cover_Dive_02',
                'Crushed',
                'Crush_Jump'
        },

        ['DOZER'] = {
                'DOZER_Align_LHS',
                'DOZER_Align_RHS',
                'DOZER_getin_LHS',
                'DOZER_getin_RHS',
                'DOZER_getout_LHS',
                'DOZER_getout_RHS',
                'DOZER_Jacked_LHS',
                'DOZER_Jacked_RHS',
                'DOZER_pullout_LHS',
                'DOZER_pullout_RHS'
        },

        ['DRIVEBYS'] = {
                'Gang_DrivebyLHS',
                'Gang_DrivebyLHS_Bwd',
                'Gang_DrivebyLHS_Fwd',
                'Gang_DrivebyRHS',
                'Gang_DrivebyRHS_Bwd',
                'Gang_DrivebyRHS_Fwd',
                'Gang_DrivebyTop_LHS',
                'Gang_DrivebyTop_RHS'
        },

        ['FAT'] = {
                'FatIdle',
                'FatIdle_armed',
                'FatIdle_Csaw',
                'FatIdle_Rocket',
                'FatRun',
                'FatRun_armed',
                'FatRun_Csaw',
                'FatRun_Rocket',
                'FatSprint',
                'FatWalk',
                'FatWalkstart',
                'FatWalkstart_Csaw',
                'FatWalkSt_armed',
                'FatWalkSt_Rocket',
                'FatWalk_armed',
                'FatWalk_Csaw',
                'FatWalk_Rocket',
                'IDLE_tired'
        },

        ['FIGHT_B'] = {
                'FightB_1',
                'FightB_2',
                'FightB_3',
                'FightB_block',
                'FightB_G',
                'FightB_IDLE',
                'FightB_M',
                'HitB_1',
                'HitB_2',
                'HitB_3'
        },

        ['FIGHT_C'] = {
                'FightC_1',
                'FightC_2',
                'FightC_3',
                'FightC_block',
                'FightC_blocking',
                'FightC_G',
                'FightC_IDLE',
                'FightC_M',
                'FightC_Spar',
                'HitC_1',
                'HitC_2',
                'HitC_3'
        },

        ['FIGHT_D'] = {
                'FightD_1',
                'FightD_2',
                'FightD_3',
                'FightD_block',
                'FightD_G',
                'FightD_IDLE',
                'FightD_M',
                'HitD_1',
                'HitD_2',
                'HitD_3'
        },

        ['FIGHT_E'] = {
                'FightKick',
                'FightKick_B',
                'Hit_fightkick',
                'Hit_fightkick_B'
        },

        ['FINALE'] = {
                'FIN_Climb_In',
                'FIN_Cop1_ClimbOut2',
                'FIN_Cop1_Loop',
                'FIN_Cop1_Stomp',
                'FIN_Hang_L',
                'FIN_Hang_Loop',
                'FIN_Hang_R',
                'FIN_Hang_Slip',
                'FIN_Jump_On',
                'FIN_Land_Car',
                'FIN_Land_Die',
                'FIN_LegsUp',
                'FIN_LegsUp_L',
                'FIN_LegsUp_Loop',
                'FIN_LegsUp_R',
                'FIN_Let_Go'
        },

        ['FINALE2'] = {
                'FIN_Cop1_ClimbOut',
                'FIN_Cop1_Fall',
                'FIN_Cop1_Loop',
                'FIN_Cop1_Shot',
                'FIN_Cop1_Swing',
                'FIN_Cop2_ClimbOut',
                'FIN_Switch_P',
                'FIN_Switch_S'
        },

        ['FLAME'] = {
                'FLAME_fire'
        },

        ['Flowers'] = {
                'Flower_attack',
                'Flower_attack_M',
                'Flower_Hit'
        },

        ['FOOD'] = {
                'EAT_Burger',
                'EAT_Chicken',
                'EAT_Pizza',
                'EAT_Vomit_P',
                'EAT_Vomit_SK',
                'FF_Dam_Bkw',
                'FF_Dam_Fwd',
                'FF_Dam_Left',
                'FF_Dam_Right',
                'FF_Die_Bkw',
                'FF_Die_Fwd',
                'FF_Die_Left',
                'FF_Die_Right',
                'FF_Sit_Eat1',
                'FF_Sit_Eat2',
                'FF_Sit_Eat3',
                'FF_Sit_In',
                'FF_Sit_In_L',
                'FF_Sit_In_R',
                'FF_Sit_Look',
                'FF_Sit_Loop',
                'FF_Sit_Out_180',
                'FF_Sit_Out_L_180',
                'FF_Sit_Out_R_180',
                'SHP_Thank',
                'SHP_Tray_In',
                'SHP_Tray_Lift',
                'SHP_Tray_Lift_In',
                'SHP_Tray_Lift_Loop',
                'SHP_Tray_Lift_Out',
                'SHP_Tray_Out',
                'SHP_Tray_Pose',
                'SHP_Tray_Return'
        },

        ['Freeweights'] = {
                'gym_barbell',
                'gym_free_A',
                'gym_free_B',
                'gym_free_celebrate',
                'gym_free_down',
                'gym_free_loop',
                'gym_free_pickup',
                'gym_free_putdown',
                'gym_free_up_smooth'
        },

        ['GANGS'] = {
                'DEALER_DEAL',
                'DEALER_IDLE',
                'drnkbr_prtl',
                'drnkbr_prtl_F',
                'DRUGS_BUY',
                'hndshkaa',
                'hndshkba',
                'hndshkca',
                'hndshkcb',
                'hndshkda',
                'hndshkea',
                'hndshkfa',
                'hndshkfa_swt',
                'Invite_No',
                'Invite_Yes',
                'leanIDLE',
                'leanIN',
                'leanOUT',
                'prtial_gngtlkA',
                'prtial_gngtlkB',
                'prtial_gngtlkC',
                'prtial_gngtlkD',
                'prtial_gngtlkE',
                'prtial_gngtlkF',
                'prtial_gngtlkG',
                'prtial_gngtlkH',
                'prtial_hndshk_01',
                'prtial_hndshk_biz_01',
                'shake_cara',
                'shake_carK',
                'shake_carSH',
                'smkcig_prtl',
                'smkcig_prtl_F'
        },

        ['GHANDS'] = {
                'gsign1',
                'gsign1LH',
                'gsign2',
                'gsign2LH',
                'gsign3',
                'gsign3LH',
                'gsign4',
                'gsign4LH',
                'gsign5',
                'gsign5LH',
                'LHGsign1',
                'LHGsign2',
                'LHGsign3',
                'LHGsign4',
                'LHGsign5',
                'RHGsign1',
                'RHGsign2',
                'RHGsign3',
                'RHGsign4',
                'RHGsign5'
        },

        ['GHETTO_DB'] = {
                'GDB_Car2_PLY',
                'GDB_Car2_SMO',
                'GDB_Car2_SWE',
                'GDB_Car_PLY',
                'GDB_Car_RYD',
                'GDB_Car_SMO',
                'GDB_Car_SWE'
        },

        ['goggles'] = {
                'goggles_put_on'
        },

        ['GRAFFITI'] = {
                'graffiti_Chkout',
                'spraycan_fire'
        },

        ['GRAVEYARD'] = {
                'mrnF_loop',
                'mrnM_loop',
                'prst_loopa'
        },

        ['GRENADE'] = {
                'WEAPON_start_throw',
                'WEAPON_throw',
                'WEAPON_throwu'
        },

        ['GYMNASIUM'] = {
                'GYMshadowbox',
                'gym_bike_celebrate',
                'gym_bike_fast',
                'gym_bike_faster',
                'gym_bike_getoff',
                'gym_bike_geton',
                'gym_bike_pedal',
                'gym_bike_slow',
                'gym_bike_still',
                'gym_jog_falloff',
                'gym_shadowbox',
                'gym_tread_celebrate',
                'gym_tread_falloff',
                'gym_tread_getoff',
                'gym_tread_geton',
                'gym_tread_jog',
                'gym_tread_sprint',
                'gym_tread_tired',
                'gym_tread_walk',
                'gym_walk_falloff',
                'Pedals_fast',
                'Pedals_med',
                'Pedals_slow',
                'Pedals_still'
        },

        ['HAIRCUTS'] = {
                'BRB_Beard_01',
                'BRB_Buy',
                'BRB_Cut',
                'BRB_Cut_In',
                'BRB_Cut_Out',
                'BRB_Hair_01',
                'BRB_Hair_02',
                'BRB_In',
                'BRB_Loop',
                'BRB_Out',
                'BRB_Sit_In',
                'BRB_Sit_Loop',
                'BRB_Sit_Out'
        },

        ['HEIST9'] = {
                'CAS_G2_GasKO',
                'swt_wllpk_L',
                'swt_wllpk_L_back',
                'swt_wllpk_R',
                'swt_wllpk_R_back',
                'swt_wllshoot_in_L',
                'swt_wllshoot_in_R',
                'swt_wllshoot_out_L',
                'swt_wllshoot_out_R',
                'Use_SwipeCard'
        },

        ['INT_HOUSE'] = {
                'BED_In_L',
                'BED_In_R',
                'BED_Loop_L',
                'BED_Loop_R',
                'BED_Out_L',
                'BED_Out_R',
                'LOU_In',
                'LOU_Loop',
                'LOU_Out',
                'wash_up'
        },

        ['INT_OFFICE'] = {
                'FF_Dam_Fwd',
                'OFF_Sit_2Idle_180',
                'OFF_Sit_Bored_Loop',
                'OFF_Sit_Crash',
                'OFF_Sit_Drink',
                'OFF_Sit_Idle_Loop',
                'OFF_Sit_In',
                'OFF_Sit_Read',
                'OFF_Sit_Type_Loop',
                'OFF_Sit_Watch'
        },

        ['INT_SHOP'] = {
                'shop_cashier',
                'shop_in',
                'shop_lookA',
                'shop_lookB',
                'shop_loop',
                'shop_out',
                'shop_pay',
                'shop_shelf'
        },

        ['JST_BUISNESS'] = {
                'girl_01',
                'girl_02',
                'player_01',
                'smoke_01'
        },

        ['KART'] = {
                'KART_getin_LHS',
                'KART_getin_RHS',
                'KART_getout_LHS',
                'KART_getout_RHS'
        },

        ['KISSING'] = {
                'BD_GF_Wave',
                'gfwave2',
                'GF_CarArgue_01',
                'GF_CarArgue_02',
                'GF_CarSpot',
                'GF_StreetArgue_01',
                'GF_StreetArgue_02',
                'gift_get',
                'gift_give',
                'Grlfrd_Kiss_01',
                'Grlfrd_Kiss_02',
                'Grlfrd_Kiss_03',
                'Playa_Kiss_01',
                'Playa_Kiss_02',
                'Playa_Kiss_03'
        },

        ['KNIFE'] = {
                'KILL_Knife_Ped_Damage',
                'KILL_Knife_Ped_Die',
                'KILL_Knife_Player',
                'KILL_Partial',
                'knife_1',
                'knife_2',
                'knife_3',
                'Knife_4',
                'knife_block',
                'Knife_G',
                'knife_hit_1',
                'knife_hit_2',
                'knife_hit_3',
                'knife_IDLE',
                'knife_part',
                'WEAPON_knifeidle'
        },

        ['LAPDAN1'] = {
                'LAPDAN_D',
                'LAPDAN_P'
        },

        ['LAPDAN2'] = {
                'LAPDAN_D',
                'LAPDAN_P'
        },

        ['LAPDAN3'] = {
                'LAPDAN_D',
                'LAPDAN_P'
        },

        ['LOWRIDER'] = {
                'F_smklean_loop',
                'lrgirl_bdbnce',
                'lrgirl_hair',
                'lrgirl_hurry',
                'lrgirl_idleloop',
                'lrgirl_idle_to_l0',
                'lrgirl_l0_bnce',
                'lrgirl_l0_loop',
                'lrgirl_l0_to_l1',
                'lrgirl_l12_to_l0',
                'lrgirl_l1_bnce',
                'lrgirl_l1_loop',
                'lrgirl_l1_to_l2',
                'lrgirl_l2_bnce',
                'lrgirl_l2_loop',
                'lrgirl_l2_to_l3',
                'lrgirl_l345_to_l1',
                'lrgirl_l3_bnce',
                'lrgirl_l3_loop',
                'lrgirl_l3_to_l4',
                'lrgirl_l4_bnce',
                'lrgirl_l4_loop',
                'lrgirl_l4_to_l5',
                'lrgirl_l5_bnce',
                'lrgirl_l5_loop',
                'M_smklean_loop',
                'M_smkstnd_loop',
                'prtial_gngtlkB',
                'prtial_gngtlkC',
                'prtial_gngtlkD',
                'prtial_gngtlkE',
                'prtial_gngtlkF',
                'prtial_gngtlkG',
                'prtial_gngtlkH',
                'RAP_A_Loop',
                'RAP_B_Loop',
                'RAP_C_Loop',
                'Sit_relaxed',
                'Tap_hand'
        },

        ['MD_CHASE'] = {
                'Carhit_Hangon',
                'Carhit_Tumble',
                'donutdrop',
                'Fen_Choppa_L1',
                'Fen_Choppa_L2',
                'Fen_Choppa_L3',
                'Fen_Choppa_R1',
                'Fen_Choppa_R2',
                'Fen_Choppa_R3',
                'Hangon_Stun_loop',
                'Hangon_Stun_Turn',
                'MD_BIKE_2_HANG',
                'MD_BIKE_Jmp_BL',
                'MD_BIKE_Jmp_F',
                'MD_BIKE_Lnd_BL',
                'MD_BIKE_Lnd_Die_BL',
                'MD_BIKE_Lnd_Die_F',
                'MD_BIKE_Lnd_F',
                'MD_BIKE_Lnd_Roll',
                'MD_BIKE_Lnd_Roll_F',
                'MD_BIKE_Punch',
                'MD_BIKE_Punch_F',
                'MD_BIKE_Shot_F',
                'MD_HANG_Lnd_Roll',
                'MD_HANG_Loop'
        },

        ['MD_END'] = {
                'END_SC1_PLY',
                'END_SC1_RYD',
                'END_SC1_SMO',
                'END_SC1_SWE',
                'END_SC2_PLY',
                'END_SC2_RYD',
                'END_SC2_SMO',
                'END_SC2_SWE'
        },

        ['MEDIC'] = {
                'CPR'
        },

        ['MISC'] = {
                'bitchslap',
                'BMX_celebrate',
                'BMX_comeon',
                'bmx_idleloop_01',
                'bmx_idleloop_02',
                'bmx_talkleft_in',
                'bmx_talkleft_loop',
                'bmx_talkleft_out',
                'bmx_talkright_in',
                'bmx_talkright_loop',
                'bmx_talkright_out',
                'bng_wndw',
                'bng_wndw_02',
                'Case_pickup',
                'door_jet',
                'GRAB_L',
                'GRAB_R',
                'Hiker_Pose',
                'Hiker_Pose_L',
                'Idle_Chat_02',
                'KAT_Throw_K',
                'KAT_Throw_O',
                'KAT_Throw_P',
                'PASS_Rifle_O',
                'PASS_Rifle_Ped',
                'PASS_Rifle_Ply',
                'pickup_box',
                'Plane_door',
                'Plane_exit',
                'Plane_hijack',
                'Plunger_01',
                'Plyrlean_loop',
                'plyr_shkhead',
                'Run_Dive',
                'Scratchballs_01',
                'SEAT_LR',
                'Seat_talk_01',
                'Seat_talk_02',
                'SEAT_watch',
                'smalplane_door',
                'smlplane_door'
        },

        ['MTB'] = {
                'MTB_back',
                'MTB_bunnyhop',
                'MTB_drivebyFT',
                'MTB_driveby_LHS',
                'MTB_driveby_RHS',
                'MTB_fwd',
                'MTB_getoffBACK',
                'MTB_getoffLHS',
                'MTB_getoffRHS',
                'MTB_jumponL',
                'MTB_jumponR',
                'MTB_Left',
                'MTB_pedal',
                'MTB_pushes',
                'MTB_Ride',
                'MTB_Right',
                'MTB_sprint',
                'MTB_still'
        },

        ['MUSCULAR'] = {
                'MscleWalkst_armed',
                'MscleWalkst_Csaw',
                'Mscle_rckt_run',
                'Mscle_rckt_walkst',
                'Mscle_run_Csaw',
                'MuscleIdle',
                'MuscleIdle_armed',
                'MuscleIdle_Csaw',
                'MuscleIdle_rocket',
                'MuscleRun',
                'MuscleRun_armed',
                'MuscleSprint',
                'MuscleWalk',
                'MuscleWalkstart',
                'MuscleWalk_armed',
                'Musclewalk_Csaw',
                'Musclewalk_rocket'
        },

        ['NEVADA'] = {
                'NEVADA_getin',
                'NEVADA_getout'
        },

        ['ON_LOOKERS'] = {
                'lkaround_in',
                'lkaround_loop',
                'lkaround_out',
                'lkup_in',
                'lkup_loop',
                'lkup_out',
                'lkup_point',
                'panic_cower',
                'panic_hide',
                'panic_in',
                'panic_loop',
                'panic_out',
                'panic_point',
                'panic_shout',
                'Pointup_in',
                'Pointup_loop',
                'Pointup_out',
                'Pointup_shout',
                'point_in',
                'point_loop',
                'point_out',
                'shout_01',
                'shout_02',
                'shout_in',
                'shout_loop',
                'shout_out',
                'wave_in',
                'wave_loop',
                'wave_out'
        },

        ['OTB'] = {
                'betslp_in',
                'betslp_lkabt',
                'betslp_loop',
                'betslp_out',
                'betslp_tnk',
                'wtchrace_cmon',
                'wtchrace_in',
                'wtchrace_loop',
                'wtchrace_lose',
                'wtchrace_out',
                'wtchrace_win'
        },

        ['PARACHUTE'] = {
                'FALL_skyDive',
                'FALL_SkyDive_Accel',
                'FALL_skyDive_DIE',
                'FALL_SkyDive_L',
                'FALL_SkyDive_R',
                'PARA_decel',
                'PARA_decel_O',
                'PARA_float',
                'PARA_float_O',
                'PARA_Land',
                'PARA_Land_O',
                'PARA_Land_Water',
                'PARA_Land_Water_O',
                'PARA_open',
                'PARA_open_O',
                'PARA_Rip_Land_O',
                'PARA_Rip_Loop_O',
                'PARA_Rip_O',
                'PARA_steerL',
                'PARA_steerL_O',
                'PARA_steerR',
                'PARA_steerR_O'
        },

        ['PARK'] = {
                'Tai_Chi_in',
                'Tai_Chi_Loop',
                'Tai_Chi_Out'
        },

        ['PAULNMAC'] = {
                'Piss_in',
                'Piss_loop',
                'Piss_out',
                'PnM_Argue1_A',
                'PnM_Argue1_B',
                'PnM_Argue2_A',
                'PnM_Argue2_B',
                'PnM_Loop_A',
                'PnM_Loop_B',
                'wank_in',
                'wank_loop',
                'wank_out'
        },

        ['ped'] = {
                'abseil',
                'ARRESTgun',
                'ATM',
                'BIKE_elbowL',
                'BIKE_elbowR',
                'BIKE_fallR',
                'BIKE_fall_off',
                'BIKE_pickupL',
                'BIKE_pickupR',
                'BIKE_pullupL',
                'BIKE_pullupR',
                'bomber',
                'CAR_alignHI_LHS',
                'CAR_alignHI_RHS',
                'CAR_align_LHS',
                'CAR_align_RHS',
                'CAR_closedoorL_LHS',
                'CAR_closedoorL_RHS',
                'CAR_closedoor_LHS',
                'CAR_closedoor_RHS',
                'CAR_close_LHS',
                'CAR_close_RHS',
                'CAR_crawloutRHS',
                'CAR_dead_LHS',
                'CAR_dead_RHS',
                'CAR_doorlocked_LHS',
                'CAR_doorlocked_RHS',
                'CAR_fallout_LHS',
                'CAR_fallout_RHS',
                'CAR_getinL_LHS',
                'CAR_getinL_RHS',
                'CAR_getin_LHS',
                'CAR_getin_RHS',
                'CAR_getoutL_LHS',
                'CAR_getoutL_RHS',
                'CAR_getout_LHS',
                'CAR_getout_RHS',
                'car_hookertalk',
                'CAR_jackedLHS',
                'CAR_jackedRHS',
                'CAR_jumpin_LHS',
                'CAR_LB',
                'CAR_LB_pro',
                'CAR_LB_weak',
                'CAR_LjackedLHS',
                'CAR_LjackedRHS',
                'CAR_Lshuffle_RHS',
                'CAR_Lsit',
                'CAR_open_LHS',
                'CAR_open_RHS',
                'CAR_pulloutL_LHS',
                'CAR_pulloutL_RHS',
                'CAR_pullout_LHS',
                'CAR_pullout_RHS',
                'CAR_Qjacked',
                'CAR_rolldoor',
                'CAR_rolldoorLO',
                'CAR_rollout_LHS',
                'CAR_rollout_RHS',
                'CAR_shuffle_RHS',
                'CAR_sit',
                'CAR_sitp',
                'CAR_sitpLO',
                'CAR_sit_pro',
                'CAR_sit_weak',
                'CAR_tune_radio',
                'CLIMB_idle',
                'CLIMB_jump',
                'CLIMB_jump2fall',
                'CLIMB_jump_B',
                'CLIMB_Pull',
                'CLIMB_Stand',
                'CLIMB_Stand_finish',
                'cower',
                'Crouch_Roll_L',
                'Crouch_Roll_R',
                'DAM_armL_frmBK',
                'DAM_armL_frmFT',
                'DAM_armL_frmLT',
                'DAM_armR_frmBK',
                'DAM_armR_frmFT',
                'DAM_armR_frmRT',
                'DAM_LegL_frmBK',
                'DAM_LegL_frmFT',
                'DAM_LegL_frmLT',
                'DAM_LegR_frmBK',
                'DAM_LegR_frmFT',
                'DAM_LegR_frmRT',
                'DAM_stomach_frmBK',
                'DAM_stomach_frmFT',
                'DAM_stomach_frmLT',
                'DAM_stomach_frmRT',
                'DOOR_LHinge_O',
                'DOOR_RHinge_O',
                'DrivebyL_L',
                'DrivebyL_R',
                'Driveby_L',
                'Driveby_R',
                'DRIVE_BOAT',
                'DRIVE_BOAT_back',
                'DRIVE_BOAT_L',
                'DRIVE_BOAT_R',
                'Drive_L',
                'Drive_LO_l',
                'Drive_LO_R',
                'Drive_L_pro',
                'Drive_L_pro_slow',
                'Drive_L_slow',
                'Drive_L_weak',
                'Drive_L_weak_slow',
                'Drive_R',
                'Drive_R_pro',
                'Drive_R_pro_slow',
                'Drive_R_slow',
                'Drive_R_weak',
                'Drive_R_weak_slow',
                'Drive_truck',
                'DRIVE_truck_back',
                'DRIVE_truck_L',
                'DRIVE_truck_R',
                'Drown',
                'DUCK_cower',
                'endchat_01',
                'endchat_02',
                'endchat_03',
                'EV_dive',
                'EV_step',
                'facanger',
                'facgum',
                'facsurp',
                'facsurpm',
                'factalk',
                'facurios',
                'FALL_back',
                'FALL_collapse',
                'FALL_fall',
                'FALL_front',
                'FALL_glide',
                'FALL_land',
                'FALL_skyDive',
                'Fight2Idle',
                'FightA_1',
                'FightA_2',
                'FightA_3',
                'FightA_block',
                'FightA_G',
                'FightA_M',
                'FIGHTIDLE',
                'FightShB',
                'FightShF',
                'FightSh_BWD',
                'FightSh_FWD',
                'FightSh_Left',
                'FightSh_Right',
                'flee_lkaround_01',
                'FLOOR_hit',
                'FLOOR_hit_f',
                'fucku',
                'gang_gunstand',
                'gas_cwr',
                'getup',
                'getup_front',
                'gum_eat',
                'GunCrouchBwd',
                'GunCrouchFwd',
                'GunMove_BWD',
                'GunMove_FWD',
                'GunMove_L',
                'GunMove_R',
                'Gun_2_IDLE',
                'GUN_BUTT',
                'GUN_BUTT_crouch',
                'Gun_stand',
                'handscower',
                'handsup',
                'HitA_1',
                'HitA_2',
                'HitA_3',
                'HIT_back',
                'HIT_behind',
                'HIT_front',
                'HIT_GUN_BUTT',
                'HIT_L',
                'HIT_R',
                'HIT_walk',
                'HIT_wall',
                'Idlestance_fat',
                'idlestance_old',
                'IDLE_armed',
                'IDLE_chat',
                'IDLE_csaw',
                'Idle_Gang1',
                'IDLE_HBHB',
                'IDLE_ROCKET',
                'IDLE_stance',
                'IDLE_taxi',
                'IDLE_tired',
                'Jetpack_Idle',
                'JOG_femaleA',
                'JOG_maleA',
                'JUMP_glide',
                'JUMP_land',
                'JUMP_launch',
                'JUMP_launch_R',
                'KART_drive',
                'KART_L',
                'KART_LB',
                'KART_R',
                'KD_left',
                'KD_right',
                'KO_shot_face',
                'KO_shot_front',
                'KO_shot_stom',
                'KO_skid_back',
                'KO_skid_front',
                'KO_spin_L',
                'KO_spin_R',
                'pass_Smoke_in_car',
                'phone_in',
                'phone_out',
                'phone_talk',
                'Player_Sneak',
                'Player_Sneak_walkstart',
                'roadcross',
                'roadcross_female',
                'roadcross_gang',
                'roadcross_old',
                'run_1armed',
                'run_armed',
                'run_civi',
                'run_csaw',
                'run_fat',
                'run_fatold',
                'run_gang1',
                'run_left',
                'run_old',
                'run_player',
                'run_right',
                'run_rocket',
                'Run_stop',
                'Run_stopR',
                'Run_Wuzi',
                'SEAT_down',
                'SEAT_idle',
                'SEAT_up',
                'SHOT_leftP',
                'SHOT_partial',
                'SHOT_partial_B',
                'SHOT_rightP',
                'Shove_Partial',
                'Smoke_in_car',
                'sprint_civi',
                'sprint_panic',
                'Sprint_Wuzi',
                'swat_run',
                'Swim_Tread',
                'Tap_hand',
                'Tap_handP',
                'turn_180',
                'Turn_L',
                'Turn_R',
                'WALK_armed',
                'WALK_civi',
                'WALK_csaw',
                'Walk_DoorPartial',
                'WALK_drunk',
                'WALK_fat',
                'WALK_fatold',
                'WALK_gang1',
                'WALK_gang2',
                'WALK_old',
                'WALK_player',
                'WALK_rocket',
                'WALK_shuffle',
                'WALK_start',
                'WALK_start_armed',
                'WALK_start_csaw',
                'WALK_start_rocket',
                'Walk_Wuzi',
                'WEAPON_crouch',
                'woman_idlestance',
                'woman_run',
                'WOMAN_runbusy',
                'WOMAN_runfatold',
                'woman_runpanic',
                'WOMAN_runsexy',
                'WOMAN_walkbusy',
                'WOMAN_walkfatold',
                'WOMAN_walknorm',
                'WOMAN_walkold',
                'WOMAN_walkpro',
                'WOMAN_walksexy',
                'WOMAN_walkshop',
                'XPRESSscratch'
        },

        ['PLAYER_DVBYS'] = {
                'Plyr_DrivebyBwd',
                'Plyr_DrivebyFwd',
                'Plyr_DrivebyLHS',
                'Plyr_DrivebyRHS'
        },

        ['PLAYIDLES'] = {
                'shift',
                'shldr',
                'stretch',
                'strleg',
                'time'
        },

        ['POLICE'] = {
                'CopTraf_Away',
                'CopTraf_Come',
                'CopTraf_Left',
                'CopTraf_Stop',
                'COP_getoutcar_LHS',
                'Cop_move_FWD',
                'crm_drgbst_01',
                'Door_Kick',
                'plc_drgbst_01',
                'plc_drgbst_02'
        },

        ['POOL'] = {
                'POOL_ChalkCue',
                'POOL_Idle_Stance',
                'POOL_Long_Shot',
                'POOL_Long_Shot_O',
                'POOL_Long_Start',
                'POOL_Long_Start_O',
                'POOL_Med_Shot',
                'POOL_Med_Shot_O',
                'POOL_Med_Start',
                'POOL_Med_Start_O',
                'POOL_Place_White',
                'POOL_Short_Shot',
                'POOL_Short_Shot_O',
                'POOL_Short_Start',
                'POOL_Short_Start_O',
                'POOL_Walk',
                'POOL_Walk_Start',
                'POOL_XLong_Shot',
                'POOL_XLong_Shot_O',
                'POOL_XLong_Start',
                'POOL_XLong_Start_O'
        },

        ['POOR'] = {
                'WINWASH_Start',
                'WINWASH_Wash2Beg'
        },

        ['PYTHON'] = {
                'python_crouchfire',
                'python_crouchreload',
                'python_fire',
                'python_fire_poor',
                'python_reload'
        },

        ['QUAD'] = {
                'QUAD_back',
                'QUAD_driveby_FT',
                'QUAD_driveby_LHS',
                'QUAD_driveby_RHS',
                'QUAD_FWD',
                'QUAD_getoff_B',
                'QUAD_getoff_LHS',
                'QUAD_getoff_RHS',
                'QUAD_geton_LHS',
                'QUAD_geton_RHS',
                'QUAD_hit',
                'QUAD_kick',
                'QUAD_Left',
                'QUAD_passenger',
                'QUAD_reverse',
                'QUAD_ride',
                'QUAD_Right'
        },

        ['QUAD_DBZ'] = {
                'Pass_Driveby_BWD',
                'Pass_Driveby_FWD',
                'Pass_Driveby_LHS',
                'Pass_Driveby_RHS'
        },

        ['RAPPING'] = {
                'Laugh_01',
                'RAP_A_IN',
                'RAP_A_Loop',
                'RAP_A_OUT',
                'RAP_B_IN',
                'RAP_B_Loop',
                'RAP_B_OUT',
                'RAP_C_Loop'
        },

        ['RIFLE'] = {
                'RIFLE_crouchfire',
                'RIFLE_crouchload',
                'RIFLE_fire',
                'RIFLE_fire_poor',
                'RIFLE_load'
        },

        ['RIOT'] = {
                'RIOT_ANGRY',
                'RIOT_ANGRY_B',
                'RIOT_challenge',
                'RIOT_CHANT',
                'RIOT_FUKU',
                'RIOT_PUNCHES',
                'RIOT_shout'
        },

        ['ROB_BANK'] = {
                'CAT_Safe_End',
                'CAT_Safe_Open',
                'CAT_Safe_Open_O',
                'CAT_Safe_Rob',
                'SHP_HandsUp_Scr'
        },

        ['ROCKET'] = {
                'idle_rocket',
                'RocketFire',
                'run_rocket',
                'walk_rocket',
                'WALK_start_rocket'
        },

        ['RUSTLER'] = {
                'Plane_align_LHS',
                'Plane_close',
                'Plane_getin',
                'Plane_getout',
                'Plane_open'
        },

        ['RYDER'] = {
                'RYD_Beckon_01',
                'RYD_Beckon_02',
                'RYD_Beckon_03',
                'RYD_Die_PT1',
                'RYD_Die_PT2',
                'Van_Crate_L',
                'Van_Crate_R',
                'Van_Fall_L',
                'Van_Fall_R',
                'Van_Lean_L',
                'Van_Lean_R',
                'VAN_PickUp_E',
                'VAN_PickUp_S',
                'Van_Stand',
                'Van_Stand_Crate',
                'Van_Throw'
        },

        ['SCRATCHING'] = {
                'scdldlp',
                'scdlulp',
                'scdrdlp',
                'scdrulp',
                'sclng_l',
                'sclng_r',
                'scmid_l',
                'scmid_r',
                'scshrtl',
                'scshrtr',
                'sc_ltor',
                'sc_rtol'
        },

        ['SHAMAL'] = {
                'SHAMAL_align',
                'SHAMAL_getin_LHS',
                'SHAMAL_getout_LHS',
                'SHAMAL_open'
        },

        ['SHOP'] = {
                'ROB_2Idle',
                'ROB_Loop',
                'ROB_Loop_Threat',
                'ROB_Shifty',
                'ROB_StickUp_In',
                'SHP_Duck',
                'SHP_Duck_Aim',
                'SHP_Duck_Fire',
                'SHP_Gun_Aim',
                'SHP_Gun_Duck',
                'SHP_Gun_Fire',
                'SHP_Gun_Grab',
                'SHP_Gun_Threat',
                'SHP_HandsUp_Scr',
                'SHP_Jump_Glide',
                'SHP_Jump_Land',
                'SHP_Jump_Launch',
                'SHP_Rob_GiveCash',
                'SHP_Rob_HandsUp',
                'SHP_Rob_React',
                'SHP_Serve_End',
                'SHP_Serve_Idle',
                'SHP_Serve_Loop',
                'SHP_Serve_Start',
                'Smoke_RYD'
        },

        ['SHOTGUN'] = {
                'shotgun_crouchfire',
                'shotgun_fire',
                'shotgun_fire_poor'
        },

        ['SILENCED'] = {
                'CrouchReload',
                'SilenceCrouchfire',
                'Silence_fire',
                'Silence_reload'
        },

        ['SKATE'] = {
                'skate_idle',
                'skate_run',
                'skate_sprint'
        },

        ['SMOKING'] = {
                'F_smklean_loop',
                'M_smklean_loop',
                'M_smkstnd_loop',
                'M_smk_drag',
                'M_smk_in',
                'M_smk_loop',
                'M_smk_out',
                'M_smk_tap'
        },

        ['SNIPER'] = {
                'WEAPON_sniper'
        },

        ['SPRAYCAN'] = {
                'spraycan_fire',
                'spraycan_full'
        },

        ['STRIP'] = {
                'PLY_CASH',
                'PUN_CASH',
                'PUN_HOLLER',
                'PUN_LOOP',
                'strip_A',
                'strip_B',
                'strip_C',
                'strip_D',
                'strip_E',
                'strip_F',
                'strip_G',
                'STR_A2B',
                'STR_B2A',
                'STR_B2C',
                'STR_C1',
                'STR_C2',
                'STR_C2B',
                'STR_Loop_A',
                'STR_Loop_B',
                'STR_Loop_C'
        },

        ['SUNBATHE'] = {
                'batherdown',
                'batherup',
                'Lay_Bac_in',
                'Lay_Bac_out',
                'ParkSit_M_IdleA',
                'ParkSit_M_IdleB',
                'ParkSit_M_IdleC',
                'ParkSit_M_in',
                'ParkSit_M_out',
                'ParkSit_W_idleA',
                'ParkSit_W_idleB',
                'ParkSit_W_idleC',
                'ParkSit_W_in',
                'ParkSit_W_out',
                'SBATHE_F_LieB2Sit',
                'SBATHE_F_Out',
                'SitnWait_in_W',
                'SitnWait_out_W'
        },

        ['SWAT'] = {
                'gnstwall_injurd',
                'JMP_Wall1m_180',
                'Rail_fall',
                'Rail_fall_crawl',
                'swt_breach_01',
                'swt_breach_02',
                'swt_breach_03',
                'swt_go',
                'swt_lkt',
                'swt_sty',
                'swt_vent_01',
                'swt_vent_02',
                'swt_vnt_sht_die',
                'swt_vnt_sht_in',
                'swt_vnt_sht_loop',
                'swt_wllpk_L',
                'swt_wllpk_L_back',
                'swt_wllpk_R',
                'swt_wllpk_R_back',
                'swt_wllshoot_in_L',
                'swt_wllshoot_in_R',
                'swt_wllshoot_out_L',
                'swt_wllshoot_out_R'
        },

        ['SWEET'] = {
                'ho_ass_slapped',
                'LaFin_Player',
                'LaFin_Sweet',
                'plyr_hndshldr_01',
                'sweet_ass_slap',
                'sweet_hndshldr_01',
                'Sweet_injuredloop'
        },

        ['SWIM'] = {
                'Swim_Breast',
                'SWIM_crawl',
                'Swim_Dive_Under',
                'Swim_Glide',
                'Swim_jumpout',
                'Swim_Tread',
                'Swim_Under'
        },

        ['SWORD'] = {
                'sword_1',
                'sword_2',
                'sword_3',
                'sword_4',
                'sword_block',
                'Sword_Hit_1',
                'Sword_Hit_2',
                'Sword_Hit_3',
                'sword_IDLE',
                'sword_part'
        },

        ['TANK'] = {
                'TANK_align_LHS',
                'TANK_close_LHS',
                'TANK_doorlocked',
                'TANK_getin_LHS',
                'TANK_getout_LHS',
                'TANK_open_LHS'
        },

        ['TATTOOS'] = {
                'TAT_ArmL_In_O',
                'TAT_ArmL_In_P',
                'TAT_ArmL_In_T',
                'TAT_ArmL_Out_O',
                'TAT_ArmL_Out_P',
                'TAT_ArmL_Out_T',
                'TAT_ArmL_Pose_O',
                'TAT_ArmL_Pose_P',
                'TAT_ArmL_Pose_T',
                'TAT_ArmR_In_O',
                'TAT_ArmR_In_P',
                'TAT_ArmR_In_T',
                'TAT_ArmR_Out_O',
                'TAT_ArmR_Out_P',
                'TAT_ArmR_Out_T',
                'TAT_ArmR_Pose_O',
                'TAT_ArmR_Pose_P',
                'TAT_ArmR_Pose_T',
                'TAT_Back_In_O',
                'TAT_Back_In_P',
                'TAT_Back_In_T',
                'TAT_Back_Out_O',
                'TAT_Back_Out_P',
                'TAT_Back_Out_T',
                'TAT_Back_Pose_O',
                'TAT_Back_Pose_P',
                'TAT_Back_Pose_T',
                'TAT_Back_Sit_In_P',
                'TAT_Back_Sit_Loop_P',
                'TAT_Back_Sit_Out_P',
                'TAT_Bel_In_O',
                'TAT_Bel_In_T',
                'TAT_Bel_Out_O',
                'TAT_Bel_Out_T',
                'TAT_Bel_Pose_O',
                'TAT_Bel_Pose_T',
                'TAT_Che_In_O',
                'TAT_Che_In_P',
                'TAT_Che_In_T',
                'TAT_Che_Out_O',
                'TAT_Che_Out_P',
                'TAT_Che_Out_T',
                'TAT_Che_Pose_O',
                'TAT_Che_Pose_P',
                'TAT_Che_Pose_T',
                'TAT_Drop_O',
                'TAT_Idle_Loop_O',
                'TAT_Idle_Loop_T',
                'TAT_Sit_In_O',
                'TAT_Sit_In_P',
                'TAT_Sit_In_T',
                'TAT_Sit_Loop_O',
                'TAT_Sit_Loop_P',
                'TAT_Sit_Loop_T',
                'TAT_Sit_Out_O',
                'TAT_Sit_Out_P',
                'TAT_Sit_Out_T'
        },

        ['TEC'] = {
                'TEC_crouchfire',
                'TEC_crouchreload',
                'TEC_fire',
                'TEC_reload'
        },

        ['TRAIN'] = {
                'tran_gtup',
                'tran_hng',
                'tran_ouch',
                'tran_stmb'
        },

        ['TRUCK'] = {
                'TRUCK_ALIGN_LHS',
                'TRUCK_ALIGN_RHS',
                'TRUCK_closedoor_LHS',
                'TRUCK_closedoor_RHS',
                'TRUCK_close_LHS',
                'TRUCK_close_RHS',
                'TRUCK_getin_LHS',
                'TRUCK_getin_RHS',
                'TRUCK_getout_LHS',
                'TRUCK_getout_RHS',
                'TRUCK_jackedLHS',
                'TRUCK_jackedRHS',
                'TRUCK_open_LHS',
                'TRUCK_open_RHS',
                'TRUCK_pullout_LHS',
                'TRUCK_pullout_RHS',
                'TRUCK_Shuffle'
        },

        ['UZI'] = {
                'UZI_crouchfire',
                'UZI_crouchreload',
                'UZI_fire',
                'UZI_fire_poor',
                'UZI_reload'
        },

        ['VAN'] = {
                'VAN_close_back_LHS',
                'VAN_close_back_RHS',
                'VAN_getin_Back_LHS',
                'VAN_getin_Back_RHS',
                'VAN_getout_back_LHS',
                'VAN_getout_back_RHS',
                'VAN_open_back_LHS',
                'VAN_open_back_RHS'
        },

        ['VENDING'] = {
                'VEND_Drink2_P',
                'VEND_Drink_P',
                'vend_eat1_P',
                'VEND_Eat_P',
                'VEND_Use',
                'VEND_Use_pt2'
        },

        ['VORTEX'] = {
                'CAR_jumpin_LHS',
                'CAR_jumpin_RHS',
                'vortex_getout_LHS',
                'vortex_getout_RHS'
        },

        ['WAYFARER'] = {
                'WF_Back',
                'WF_drivebyFT',
                'WF_drivebyLHS',
                'WF_drivebyRHS',
                'WF_Fwd',
                'WF_getoffBACK',
                'WF_getoffLHS',
                'WF_getoffRHS',
                'WF_hit',
                'WF_jumponL',
                'WF_jumponR',
                'WF_kick',
                'WF_Left',
                'WF_passenger',
                'WF_pushes',
                'WF_Ride',
                'WF_Right',
                'WF_Still'
        },

        ['WEAPONS'] = {
                'SHP_1H_Lift',
                'SHP_1H_Lift_End',
                'SHP_1H_Ret',
                'SHP_1H_Ret_S',
                'SHP_2H_Lift',
                'SHP_2H_Lift_End',
                'SHP_2H_Ret',
                'SHP_2H_Ret_S',
                'SHP_Ar_Lift',
                'SHP_Ar_Lift_End',
                'SHP_Ar_Ret',
                'SHP_Ar_Ret_S',
                'SHP_G_Lift_In',
                'SHP_G_Lift_Out',
                'SHP_Tray_In',
                'SHP_Tray_Out',
                'SHP_Tray_Pose'
        },

        ['WUZI'] = {
                'cs_dead_guy',
                'cs_plyr_pt1',
                'cs_plyr_pt2',
                'cs_wuzi_pt1',
                'cs_wuzi_pt2',
                'walkstart_idle_01',
                'wuzi_follow',
                'wuzi_greet_plyr',
                'wuzi_greet_wuzi',
                'wuzi_grnd_chk',
                'wuzi_stand_loop',
                'wuzi_walk'
		}
	}
end

_close ="\x89\x50\x4E\x47\x0D\x0A\x1A\x0A\x00\x00\x00\x0D\x49\x48\x44\x52\x00\x00\x00\x21\x00\x00\x00\x21\x08\x06\x00\x00\x00\x57\xE4\xC2\x6F\x00\x00\x00\x09\x70\x48\x59\x73\x00\x00\x06\xEC\x00\x00\x06\xEC\x01\x1E\x75\x38\x35\x00\x00\x04\xE8\x69\x54\x58\x74\x58\x4D\x4C\x3A\x63\x6F\x6D\x2E\x61\x64\x6F\x62\x65\x2E\x78\x6D\x70\x00\x00\x00\x00\x00\x3C\x3F\x78\x70\x61\x63\x6B\x65\x74\x20\x62\x65\x67\x69\x6E\x3D\x22\xEF\xBB\xBF\x22\x20\x69\x64\x3D\x22\x57\x35\x4D\x30\x4D\x70\x43\x65\x68\x69\x48\x7A\x72\x65\x53\x7A\x4E\x54\x63\x7A\x6B\x63\x39\x64\x22\x3F\x3E\x20\x3C\x78\x3A\x78\x6D\x70\x6D\x65\x74\x61\x20\x78\x6D\x6C\x6E\x73\x3A\x78\x3D\x22\x61\x64\x6F\x62\x65\x3A\x6E\x73\x3A\x6D\x65\x74\x61\x2F\x22\x20\x78\x3A\x78\x6D\x70\x74\x6B\x3D\x22\x41\x64\x6F\x62\x65\x20\x58\x4D\x50\x20\x43\x6F\x72\x65\x20\x36\x2E\x30\x2D\x63\x30\x30\x36\x20\x37\x39\x2E\x64\x61\x62\x61\x63\x62\x62\x2C\x20\x32\x30\x32\x31\x2F\x30\x34\x2F\x31\x34\x2D\x30\x30\x3A\x33\x39\x3A\x34\x34\x20\x20\x20\x20\x20\x20\x20\x20\x22\x3E\x20\x3C\x72\x64\x66\x3A\x52\x44\x46\x20\x78\x6D\x6C\x6E\x73\x3A\x72\x64\x66\x3D\x22\x68\x74\x74\x70\x3A\x2F\x2F\x77\x77\x77\x2E\x77\x33\x2E\x6F\x72\x67\x2F\x31\x39\x39\x39\x2F\x30\x32\x2F\x32\x32\x2D\x72\x64\x66\x2D\x73\x79\x6E\x74\x61\x78\x2D\x6E\x73\x23\x22\x3E\x20\x3C\x72\x64\x66\x3A\x44\x65\x73\x63\x72\x69\x70\x74\x69\x6F\x6E\x20\x72\x64\x66\x3A\x61\x62\x6F\x75\x74\x3D\x22\x22\x20\x78\x6D\x6C\x6E\x73\x3A\x78\x6D\x70\x3D\x22\x68\x74\x74\x70\x3A\x2F\x2F\x6E\x73\x2E\x61\x64\x6F\x62\x65\x2E\x63\x6F\x6D\x2F\x78\x61\x70\x2F\x31\x2E\x30\x2F\x22\x20\x78\x6D\x6C\x6E\x73\x3A\x64\x63\x3D\x22\x68\x74\x74\x70\x3A\x2F\x2F\x70\x75\x72\x6C\x2E\x6F\x72\x67\x2F\x64\x63\x2F\x65\x6C\x65\x6D\x65\x6E\x74\x73\x2F\x31\x2E\x31\x2F\x22\x20\x78\x6D\x6C\x6E\x73\x3A\x70\x68\x6F\x74\x6F\x73\x68\x6F\x70\x3D\x22\x68\x74\x74\x70\x3A\x2F\x2F\x6E\x73\x2E\x61\x64\x6F\x62\x65\x2E\x63\x6F\x6D\x2F\x70\x68\x6F\x74\x6F\x73\x68\x6F\x70\x2F\x31\x2E\x30\x2F\x22\x20\x78\x6D\x6C\x6E\x73\x3A\x78\x6D\x70\x4D\x4D\x3D\x22\x68\x74\x74\x70\x3A\x2F\x2F\x6E\x73\x2E\x61\x64\x6F\x62\x65\x2E\x63\x6F\x6D\x2F\x78\x61\x70\x2F\x31\x2E\x30\x2F\x6D\x6D\x2F\x22\x20\x78\x6D\x6C\x6E\x73\x3A\x73\x74\x45\x76\x74\x3D\x22\x68\x74\x74\x70\x3A\x2F\x2F\x6E\x73\x2E\x61\x64\x6F\x62\x65\x2E\x63\x6F\x6D\x2F\x78\x61\x70\x2F\x31\x2E\x30\x2F\x73\x54\x79\x70\x65\x2F\x52\x65\x73\x6F\x75\x72\x63\x65\x45\x76\x65\x6E\x74\x23\x22\x20\x78\x6D\x70\x3A\x43\x72\x65\x61\x74\x6F\x72\x54\x6F\x6F\x6C\x3D\x22\x41\x64\x6F\x62\x65\x20\x50\x68\x6F\x74\x6F\x73\x68\x6F\x70\x20\x32\x32\x2E\x34\x20\x28\x57\x69\x6E\x64\x6F\x77\x73\x29\x22\x20\x78\x6D\x70\x3A\x43\x72\x65\x61\x74\x65\x44\x61\x74\x65\x3D\x22\x32\x30\x32\x31\x2D\x30\x38\x2D\x31\x33\x54\x31\x39\x3A\x30\x30\x3A\x34\x30\x2B\x30\x33\x3A\x30\x30\x22\x20\x78\x6D\x70\x3A\x4D\x6F\x64\x69\x66\x79\x44\x61\x74\x65\x3D\x22\x32\x30\x32\x31\x2D\x30\x38\x2D\x31\x33\x54\x31\x39\x3A\x30\x37\x2B\x30\x33\x3A\x30\x30\x22\x20\x78\x6D\x70\x3A\x4D\x65\x74\x61\x64\x61\x74\x61\x44\x61\x74\x65\x3D\x22\x32\x30\x32\x31\x2D\x30\x38\x2D\x31\x33\x54\x31\x39\x3A\x30\x37\x2B\x30\x33\x3A\x30\x30\x22\x20\x64\x63\x3A\x66\x6F\x72\x6D\x61\x74\x3D\x22\x69\x6D\x61\x67\x65\x2F\x70\x6E\x67\x22\x20\x70\x68\x6F\x74\x6F\x73\x68\x6F\x70\x3A\x43\x6F\x6C\x6F\x72\x4D\x6F\x64\x65\x3D\x22\x33\x22\x20\x78\x6D\x70\x4D\x4D\x3A\x49\x6E\x73\x74\x61\x6E\x63\x65\x49\x44\x3D\x22\x78\x6D\x70\x2E\x69\x69\x64\x3A\x32\x31\x36\x36\x32\x61\x65\x62\x2D\x64\x66\x61\x32\x2D\x62\x35\x34\x31\x2D\x62\x30\x64\x37\x2D\x63\x66\x32\x39\x35\x34\x32\x34\x66\x37\x32\x35\x22\x20\x78\x6D\x70\x4D\x4D\x3A\x44\x6F\x63\x75\x6D\x65\x6E\x74\x49\x44\x3D\x22\x78\x6D\x70\x2E\x64\x69\x64\x3A\x32\x31\x36\x36\x32\x61\x65\x62\x2D\x64\x66\x61\x32\x2D\x62\x35\x34\x31\x2D\x62\x30\x64\x37\x2D\x63\x66\x32\x39\x35\x34\x32\x34\x66\x37\x32\x35\x22\x20\x78\x6D\x70\x4D\x4D\x3A\x4F\x72\x69\x67\x69\x6E\x61\x6C\x44\x6F\x63\x75\x6D\x65\x6E\x74\x49\x44\x3D\x22\x78\x6D\x70\x2E\x64\x69\x64\x3A\x32\x31\x36\x36\x32\x61\x65\x62\x2D\x64\x66\x61\x32\x2D\x62\x35\x34\x31\x2D\x62\x30\x64\x37\x2D\x63\x66\x32\x39\x35\x34\x32\x34\x66\x37\x32\x35\x22\x3E\x20\x3C\x78\x6D\x70\x4D\x4D\x3A\x48\x69\x73\x74\x6F\x72\x79\x3E\x20\x3C\x72\x64\x66\x3A\x53\x65\x71\x3E\x20\x3C\x72\x64\x66\x3A\x6C\x69\x20\x73\x74\x45\x76\x74\x3A\x61\x63\x74\x69\x6F\x6E\x3D\x22\x63\x72\x65\x61\x74\x65\x64\x22\x20\x73\x74\x45\x76\x74\x3A\x69\x6E\x73\x74\x61\x6E\x63\x65\x49\x44\x3D\x22\x78\x6D\x70\x2E\x69\x69\x64\x3A\x32\x31\x36\x36\x32\x61\x65\x62\x2D\x64\x66\x61\x32\x2D\x62\x35\x34\x31\x2D\x62\x30\x64\x37\x2D\x63\x66\x32\x39\x35\x34\x32\x34\x66\x37\x32\x35\x22\x20\x73\x74\x45\x76\x74\x3A\x77\x68\x65\x6E\x3D\x22\x32\x30\x32\x31\x2D\x30\x38\x2D\x31\x33\x54\x31\x39\x3A\x30\x30\x3A\x34\x30\x2B\x30\x33\x3A\x30\x30\x22\x20\x73\x74\x45\x76\x74\x3A\x73\x6F\x66\x74\x77\x61\x72\x65\x41\x67\x65\x6E\x74\x3D\x22\x41\x64\x6F\x62\x65\x20\x50\x68\x6F\x74\x6F\x73\x68\x6F\x70\x20\x32\x32\x2E\x34\x20\x28\x57\x69\x6E\x64\x6F\x77\x73\x29\x22\x2F\x3E\x20\x3C\x2F\x72\x64\x66\x3A\x53\x65\x71\x3E\x20\x3C\x2F\x78\x6D\x70\x4D\x4D\x3A\x48\x69\x73\x74\x6F\x72\x79\x3E\x20\x3C\x2F\x72\x64\x66\x3A\x44\x65\x73\x63\x72\x69\x70\x74\x69\x6F\x6E\x3E\x20\x3C\x2F\x72\x64\x66\x3A\x52\x44\x46\x3E\x20\x3C\x2F\x78\x3A\x78\x6D\x70\x6D\x65\x74\x61\x3E\x20\x3C\x3F\x78\x70\x61\x63\x6B\x65\x74\x20\x65\x6E\x64\x3D\x22\x72\x22\x3F\x3E\xCF\x38\xDC\x53\x00\x00\x04\x73\x49\x44\x41\x54\x58\x85\xC5\x97\x4B\x6F\x1B\x55\x14\xC7\x03\x02\x04\xE2\x0B\xC0\x9E\x25\xAB\x0A\xE8\x86\x45\x58\x20\x40\x15\x12\xB1\x33\x1E\x3F\xE2\x47\xD3\xD4\x6E\x43\x1B\x52\x1A\xE2\xF8\x3D\x63\x8F\x5F\xB1\xF3\x7E\xB6\x85\x0F\xC5\x82\x47\x85\xC4\x02\x54\x21\xB1\x8A\xED\x48\x14\x55\xE8\x72\xFE\xD7\x3E\xCE\x9D\x71\xC6\x8F\xA4\x6A\x17\x47\xE3\x99\xB9\x73\xCE\xCF\xFF\x7B\xEE\x39\xF7\x4E\x09\x21\xA6\x5E\xB6\xBD\x74\x00\x57\x08\x5D\xF7\x5C\xF1\xF9\xBD\x4B\x9A\xDF\x73\x4D\xD3\xB4\xB7\x2E\x1B\x04\x3E\x66\xF5\xD9\x2F\x66\x75\xCF\x5D\xF8\x9E\x9A\x9A\x7A\xC5\x15\x82\x06\xBF\xE3\x0F\xCE\xFE\x19\x8A\x06\x4E\x6E\x7F\x9D\x78\x1A\x9B\x8F\xB6\xF5\x80\xF6\x17\x3D\xFF\xE8\xA2\x00\xBA\x3E\xF3\xBE\x1E\xF0\xFD\x11\x9D\x8F\xB4\x6F\x2D\xDE\x7C\x1A\x0A\x07\x5B\xE4\xF3\x89\x67\xCE\xF3\xEE\x00\x04\x05\x7A\xC3\x1F\xD0\x7E\x5C\x5A\xBE\xF3\xAC\x52\x2B\x09\x58\xB5\x6E\x89\x54\x66\x55\xD0\x47\x1D\x7A\xFF\xF1\xE4\x00\x9E\x2B\xFE\x80\xAF\x95\x4C\x7F\x27\x6A\xEB\x65\xE9\x0F\x7E\x97\xBF\xBD\xFB\x8C\x62\xFD\x12\x8B\xC5\xDE\xB4\x43\x04\x66\x3E\x0D\x47\x82\x1D\x15\x00\x1F\xD6\x1B\x15\x91\x2F\x64\x84\x3F\x38\x19\x08\x03\x64\xF3\x29\xB1\xDE\xAC\x4A\x3F\x2A\x48\x24\x36\xD7\xA6\x98\x9F\xDB\x21\xFC\x9E\x60\x3C\x71\xA3\x0F\xC1\x00\x70\xD0\xD8\xA8\x89\x82\x99\x1B\x1B\x84\x01\x72\x46\x5A\x34\x37\xEB\xF2\x7B\x15\x04\xFE\xE3\xB7\x16\x3A\x14\x33\xE6\x84\xB8\x16\xB9\x3E\xD7\x56\x55\x60\x00\x38\xDA\xD8\x5A\x17\x66\x31\x4F\x20\xBE\xA1\x20\x0C\x50\x30\x33\x62\x73\xBB\x21\xBF\x53\x41\x58\x0D\x52\xA2\xE5\xF3\x79\xBF\xB2\x41\x20\x63\xF5\x90\xF6\x53\x72\x6D\xC5\xA6\x02\x03\xC0\xE1\xD6\x4E\x53\x14\x2D\xC3\x15\x84\x01\x8C\x62\x4E\x6C\xEF\x6E\xC8\xF1\x2A\x08\xAB\x91\x4C\xAF\x50\x9E\xF9\x7E\xE6\x55\x62\x73\xE2\xF5\x7B\x3F\xD0\x83\x5A\x3B\xD3\x9B\x47\x56\x81\x01\xE0\x78\x67\x6F\x53\x58\x65\x73\x00\x84\x01\x4C\x2B\x2F\x76\xF7\xB7\xE4\x38\x15\x84\xD5\xC8\x19\x19\x81\x18\x88\xE5\x5A\x27\xE0\x18\x83\x30\x58\x55\x81\x01\x10\x60\xEF\x60\x5B\x94\xAB\xA5\x3E\x88\x04\x08\xFA\x5A\xA5\xB2\x21\xF6\x0F\x77\xE4\x7B\x15\x84\xD5\x28\x98\x59\x09\xE0\x54\xD1\xAD\xB8\x48\x90\x82\x91\xB5\xA9\xC0\x00\x08\x74\x70\xB4\x2B\xAA\x35\x4B\x82\x00\xC0\xAA\x9A\xE2\xF0\x78\x4F\x3E\x57\x41\x58\x0D\x4C\xD1\x79\x00\xAE\x10\x7D\x90\x80\xAF\x63\x98\x79\xE9\x84\x55\x60\x00\x04\x3C\x7E\x78\x40\x12\x93\xCC\xCD\x9A\xFC\x0D\x53\x41\x58\x0D\x24\x34\x7C\xB9\x25\xF4\xA8\x72\x2B\x41\xCC\x52\x41\x3A\x53\x55\x38\x7A\xB0\x2F\x83\x3E\xFC\xFE\xA8\x6F\xB8\xC7\x73\x80\xB0\x1A\x48\xE4\x61\x00\x23\x21\x54\x90\xA2\x55\xE8\x43\x20\x08\x82\x3D\x78\x74\x28\x83\x3F\xFA\xE1\x58\x5E\x71\xAF\x42\x94\x2A\xE6\x48\x80\xB1\x20\xCE\x72\xC4\xD7\x29\x59\xC6\x80\x12\x0C\x82\x2B\x2B\x81\xF7\x56\x65\x70\x05\x5D\x0A\x82\x41\x68\x09\x9E\xA2\xD0\x40\x11\xCE\x7C\xCC\x3B\x82\xAA\x53\x51\xA7\x3A\x83\xB1\xE3\x96\xF9\x89\x21\x72\xF9\x34\x2D\xCF\xA2\xB0\x60\xF4\x6F\x61\xB8\x07\x1C\x6A\x0B\x0C\x4B\xF1\xB9\x43\x30\x40\x3A\x97\x94\x75\xBF\x0C\xA3\xC0\xA8\x15\xB8\xDA\x9A\x5E\xBD\x2C\x2B\x6E\x36\x97\x12\xFA\xF3\x9A\x0E\x06\xC8\xE4\xD6\x7A\x1D\xD0\x92\x57\xE7\xEF\x6E\x4F\x00\x40\x45\x96\x66\x58\x96\x54\xBB\x74\x62\xF6\x01\xF2\x5D\x80\xEA\x7A\xF7\x5F\x9E\x05\x54\xED\x2C\x78\xD7\xBA\x7D\x22\x97\xCF\x5C\x7C\x89\xAA\x00\x1C\x88\x03\xD4\x7A\x57\xCC\x3F\xEA\x00\x8C\xF3\x41\x5A\xA3\x6A\xBB\x1F\x05\x32\x04\x40\x93\x53\xA0\xFE\x3B\xEE\x82\xD2\x39\xF6\x18\x45\xEC\x31\xF4\x53\x82\xED\x14\xA8\xD7\xA0\x41\xB1\x71\x03\x64\xCB\x15\xD2\xE3\x97\xED\x1E\x40\x27\x95\x5D\xB5\xB5\x74\xB6\xC6\x46\xD7\xB9\xD1\x03\xC0\xEE\x88\x0B\x5A\x9E\x56\x45\x83\x9A\x5E\xB3\x67\x2A\x10\xFC\xA0\x3B\x8F\x6C\x60\xD4\x5E\xAF\xEA\x3D\x00\x75\x87\x35\xB0\xCB\x52\x00\x6C\x05\x0D\x20\xD4\xF4\x9C\xC1\xCF\xF2\xC8\x12\xE9\xEC\x9A\x7B\x2B\xC7\xB6\x9C\x5E\x3E\x49\xA6\x56\xFA\x00\xE7\xED\x37\xD1\xE2\xA9\x12\xDA\x00\x9C\x20\xC8\x81\x7E\xFE\x28\xFB\x4A\xB6\x55\x8A\x41\xCB\xF7\xF7\x78\x3C\xFE\xBA\x0D\x82\xB6\x5A\x9F\xC5\xE6\x23\x27\x4E\x00\x15\xA4\x3B\xAF\xE7\x03\x38\x41\x50\x27\xCE\x03\x60\xA3\x58\x2D\x3A\x8B\x68\x36\x08\x7A\x90\x48\x2C\xDE\xFC\xC7\x0D\x42\xCE\x67\x60\x38\x80\x0D\x84\x24\x87\xF4\x6E\xFE\x12\x8B\x0B\xA7\x14\x73\xC1\xA1\x84\xE7\x93\x70\x34\xD4\xBA\x2C\xC0\xB8\x20\xB4\xA9\xEE\x90\xFA\x5E\x1B\x04\xE6\x87\x92\xF2\xF1\xBD\xFB\x4B\xFF\xA9\x83\xD3\x99\xE4\xC4\x00\x4E\x10\x67\x9E\xDD\xBB\xBF\x2C\xFC\x21\xED\x37\xC3\x30\x5E\x1D\x58\x1D\xF4\xD1\x7B\x34\xE7\xBF\x86\x69\x3B\x7E\xFB\x4E\xE2\xDF\xF9\x1B\xD1\x13\x02\xFB\x1B\x2A\x4D\x0A\xC0\x46\xFB\xCF\x0F\x91\x84\xD1\xEB\x91\x16\xCE\x1A\x38\xF4\xD0\xF9\xE5\x31\x8E\x87\xAE\x75\x62\x7A\x7A\xFA\x35\x24\xA9\xA6\x7B\xBF\xA1\xB3\xC8\x4C\x38\x1C\x7E\xFB\xA2\x00\x0E\x9F\x5E\x1C\x76\xE8\xFA\x25\x2B\x30\xB4\x62\xBE\x68\xFB\x1F\xF7\x5C\xF7\xCB\x56\x46\x99\xC0\x00\x00\x00\x00\x49\x45\x4E\x44\xAE\x42\x60\x82"

_logo ="\x89\x50\x4E\x47\x0D\x0A\x1A\x0A\x00\x00\x00\x0D\x49\x48\x44\x52\x00\x00\x01\x76\x00\x00\x00\x1C\x08\x06\x00\x00\x00\x75\x46\x94\xED\x00\x00\x01\x26\x69\x43\x43\x50\x41\x64\x6F\x62\x65\x20\x52\x47\x42\x20\x28\x31\x39\x39\x38\x29\x00\x00\x28\xCF\x63\x60\x60\x32\x70\x74\x71\x72\x65\x12\x60\x60\xC8\xCD\x2B\x29\x0A\x72\x77\x52\x88\x88\x8C\x52\x60\x3F\xCF\xC0\xC6\xC0\xCC\x00\x06\x89\xC9\xC5\x05\x8E\x01\x01\x3E\x20\x76\x5E\x7E\x5E\x2A\x03\x06\xF8\x76\x8D\x81\x11\x44\x5F\xD6\x05\x99\xC5\x40\x1A\xE0\x4A\x2E\x28\x2A\x01\xD2\x7F\x80\xD8\x28\x25\xB5\x38\x99\x81\x81\xD1\x00\xC8\xCE\x2E\x2F\x29\x00\x8A\x33\xCE\x01\xB2\x45\x92\xB2\xC1\xEC\x0D\x20\x76\x51\x48\x90\x33\x90\x7D\x04\xC8\xE6\x4B\x87\xB0\xAF\x80\xD8\x49\x10\xF6\x13\x10\xBB\x08\xE8\x09\x20\xFB\x0B\x48\x7D\x3A\x98\xCD\xC4\x01\x36\x07\xC2\x96\x01\xB1\x4B\x52\x2B\x40\xF6\x32\x38\xE7\x17\x54\x16\x65\xA6\x67\x94\x28\x18\x5A\x5A\x5A\x2A\x38\xA6\xE4\x27\xA5\x2A\x04\x57\x16\x97\xA4\xE6\x16\x2B\x78\xE6\x25\xE7\x17\x15\xE4\x17\x25\x96\xA4\xA6\x00\xD5\x42\xDC\x07\x06\x82\x10\x85\xA0\x10\xD3\x00\x6A\xB4\xD0\x64\xA0\x32\x00\xC5\x03\x84\xF5\x39\x10\x1C\xBE\x8C\x62\x67\x10\x62\x08\x90\x5C\x5A\x54\x06\x65\x32\x32\x19\x13\xE6\x23\xCC\x98\x23\xC1\xC0\xE0\xBF\x94\x81\x81\xE5\x0F\x42\xCC\xA4\x97\x81\x61\x81\x0E\x03\x03\xFF\x54\x84\x98\x9A\x21\x03\x83\x80\x3E\x03\xC3\xBE\x39\x00\xC0\xC6\x4F\xFD\x19\x3A\x36\x5C\x00\x00\x00\x09\x70\x48\x59\x73\x00\x00\x0B\x13\x00\x00\x0B\x13\x01\x00\x9A\x9C\x18\x00\x00\x0A\x3E\x69\x54\x58\x74\x58\x4D\x4C\x3A\x63\x6F\x6D\x2E\x61\x64\x6F\x62\x65\x2E\x78\x6D\x70\x00\x00\x00\x00\x00\x3C\x3F\x78\x70\x61\x63\x6B\x65\x74\x20\x62\x65\x67\x69\x6E\x3D\x22\xEF\xBB\xBF\x22\x20\x69\x64\x3D\x22\x57\x35\x4D\x30\x4D\x70\x43\x65\x68\x69\x48\x7A\x72\x65\x53\x7A\x4E\x54\x63\x7A\x6B\x63\x39\x64\x22\x3F\x3E\x20\x3C\x78\x3A\x78\x6D\x70\x6D\x65\x74\x61\x20\x78\x6D\x6C\x6E\x73\x3A\x78\x3D\x22\x61\x64\x6F\x62\x65\x3A\x6E\x73\x3A\x6D\x65\x74\x61\x2F\x22\x20\x78\x3A\x78\x6D\x70\x74\x6B\x3D\x22\x41\x64\x6F\x62\x65\x20\x58\x4D\x50\x20\x43\x6F\x72\x65\x20\x37\x2E\x30\x2D\x63\x30\x30\x30\x20\x37\x39\x2E\x31\x33\x35\x37\x63\x39\x65\x2C\x20\x32\x30\x32\x31\x2F\x30\x37\x2F\x31\x34\x2D\x30\x30\x3A\x33\x39\x3A\x35\x36\x20\x20\x20\x20\x20\x20\x20\x20\x22\x3E\x20\x3C\x72\x64\x66\x3A\x52\x44\x46\x20\x78\x6D\x6C\x6E\x73\x3A\x72\x64\x66\x3D\x22\x68\x74\x74\x70\x3A\x2F\x2F\x77\x77\x77\x2E\x77\x33\x2E\x6F\x72\x67\x2F\x31\x39\x39\x39\x2F\x30\x32\x2F\x32\x32\x2D\x72\x64\x66\x2D\x73\x79\x6E\x74\x61\x78\x2D\x6E\x73\x23\x22\x3E\x20\x3C\x72\x64\x66\x3A\x44\x65\x73\x63\x72\x69\x70\x74\x69\x6F\x6E\x20\x72\x64\x66\x3A\x61\x62\x6F\x75\x74\x3D\x22\x22\x20\x78\x6D\x6C\x6E\x73\x3A\x78\x6D\x70\x3D\x22\x68\x74\x74\x70\x3A\x2F\x2F\x6E\x73\x2E\x61\x64\x6F\x62\x65\x2E\x63\x6F\x6D\x2F\x78\x61\x70\x2F\x31\x2E\x30\x2F\x22\x20\x78\x6D\x6C\x6E\x73\x3A\x70\x68\x6F\x74\x6F\x73\x68\x6F\x70\x3D\x22\x68\x74\x74\x70\x3A\x2F\x2F\x6E\x73\x2E\x61\x64\x6F\x62\x65\x2E\x63\x6F\x6D\x2F\x70\x68\x6F\x74\x6F\x73\x68\x6F\x70\x2F\x31\x2E\x30\x2F\x22\x20\x78\x6D\x6C\x6E\x73\x3A\x64\x63\x3D\x22\x68\x74\x74\x70\x3A\x2F\x2F\x70\x75\x72\x6C\x2E\x6F\x72\x67\x2F\x64\x63\x2F\x65\x6C\x65\x6D\x65\x6E\x74\x73\x2F\x31\x2E\x31\x2F\x22\x20\x78\x6D\x6C\x6E\x73\x3A\x78\x6D\x70\x4D\x4D\x3D\x22\x68\x74\x74\x70\x3A\x2F\x2F\x6E\x73\x2E\x61\x64\x6F\x62\x65\x2E\x63\x6F\x6D\x2F\x78\x61\x70\x2F\x31\x2E\x30\x2F\x6D\x6D\x2F\x22\x20\x78\x6D\x6C\x6E\x73\x3A\x73\x74\x45\x76\x74\x3D\x22\x68\x74\x74\x70\x3A\x2F\x2F\x6E\x73\x2E\x61\x64\x6F\x62\x65\x2E\x63\x6F\x6D\x2F\x78\x61\x70\x2F\x31\x2E\x30\x2F\x73\x54\x79\x70\x65\x2F\x52\x65\x73\x6F\x75\x72\x63\x65\x45\x76\x65\x6E\x74\x23\x22\x20\x78\x6D\x6C\x6E\x73\x3A\x73\x74\x52\x65\x66\x3D\x22\x68\x74\x74\x70\x3A\x2F\x2F\x6E\x73\x2E\x61\x64\x6F\x62\x65\x2E\x63\x6F\x6D\x2F\x78\x61\x70\x2F\x31\x2E\x30\x2F\x73\x54\x79\x70\x65\x2F\x52\x65\x73\x6F\x75\x72\x63\x65\x52\x65\x66\x23\x22\x20\x78\x6D\x6C\x6E\x73\x3A\x74\x69\x66\x66\x3D\x22\x68\x74\x74\x70\x3A\x2F\x2F\x6E\x73\x2E\x61\x64\x6F\x62\x65\x2E\x63\x6F\x6D\x2F\x74\x69\x66\x66\x2F\x31\x2E\x30\x2F\x22\x20\x78\x6D\x6C\x6E\x73\x3A\x65\x78\x69\x66\x3D\x22\x68\x74\x74\x70\x3A\x2F\x2F\x6E\x73\x2E\x61\x64\x6F\x62\x65\x2E\x63\x6F\x6D\x2F\x65\x78\x69\x66\x2F\x31\x2E\x30\x2F\x22\x20\x78\x6D\x70\x3A\x43\x72\x65\x61\x74\x6F\x72\x54\x6F\x6F\x6C\x3D\x22\x41\x64\x6F\x62\x65\x20\x50\x68\x6F\x74\x6F\x73\x68\x6F\x70\x20\x32\x32\x2E\x35\x20\x28\x57\x69\x6E\x64\x6F\x77\x73\x29\x22\x20\x78\x6D\x70\x3A\x43\x72\x65\x61\x74\x65\x44\x61\x74\x65\x3D\x22\x32\x30\x32\x31\x2D\x31\x32\x2D\x30\x38\x54\x30\x30\x3A\x30\x33\x3A\x35\x39\x2B\x30\x33\x3A\x30\x30\x22\x20\x78\x6D\x70\x3A\x4D\x65\x74\x61\x64\x61\x74\x61\x44\x61\x74\x65\x3D\x22\x32\x30\x32\x31\x2D\x31\x32\x2D\x30\x38\x54\x30\x30\x3A\x30\x38\x3A\x33\x38\x2B\x30\x33\x3A\x30\x30\x22\x20\x78\x6D\x70\x3A\x4D\x6F\x64\x69\x66\x79\x44\x61\x74\x65\x3D\x22\x32\x30\x32\x31\x2D\x31\x32\x2D\x30\x38\x54\x30\x30\x3A\x30\x38\x3A\x33\x38\x2B\x30\x33\x3A\x30\x30\x22\x20\x70\x68\x6F\x74\x6F\x73\x68\x6F\x70\x3A\x43\x6F\x6C\x6F\x72\x4D\x6F\x64\x65\x3D\x22\x33\x22\x20\x64\x63\x3A\x66\x6F\x72\x6D\x61\x74\x3D\x22\x69\x6D\x61\x67\x65\x2F\x70\x6E\x67\x22\x20\x78\x6D\x70\x4D\x4D\x3A\x49\x6E\x73\x74\x61\x6E\x63\x65\x49\x44\x3D\x22\x78\x6D\x70\x2E\x69\x69\x64\x3A\x37\x38\x30\x35\x37\x36\x38\x62\x2D\x62\x36\x37\x39\x2D\x31\x38\x34\x66\x2D\x62\x64\x31\x31\x2D\x66\x61\x31\x36\x36\x37\x64\x63\x65\x61\x61\x33\x22\x20\x78\x6D\x70\x4D\x4D\x3A\x44\x6F\x63\x75\x6D\x65\x6E\x74\x49\x44\x3D\x22\x61\x64\x6F\x62\x65\x3A\x64\x6F\x63\x69\x64\x3A\x70\x68\x6F\x74\x6F\x73\x68\x6F\x70\x3A\x66\x62\x30\x64\x61\x35\x38\x37\x2D\x37\x33\x32\x64\x2D\x39\x33\x34\x31\x2D\x61\x64\x34\x64\x2D\x34\x39\x36\x39\x33\x63\x66\x61\x39\x34\x39\x36\x22\x20\x78\x6D\x70\x4D\x4D\x3A\x4F\x72\x69\x67\x69\x6E\x61\x6C\x44\x6F\x63\x75\x6D\x65\x6E\x74\x49\x44\x3D\x22\x78\x6D\x70\x2E\x64\x69\x64\x3A\x65\x33\x63\x35\x65\x38\x64\x61\x2D\x36\x35\x32\x64\x2D\x38\x33\x34\x32\x2D\x39\x30\x33\x37\x2D\x62\x32\x64\x65\x39\x33\x66\x66\x66\x65\x30\x61\x22\x20\x74\x69\x66\x66\x3A\x4F\x72\x69\x65\x6E\x74\x61\x74\x69\x6F\x6E\x3D\x22\x31\x22\x20\x74\x69\x66\x66\x3A\x58\x52\x65\x73\x6F\x6C\x75\x74\x69\x6F\x6E\x3D\x22\x37\x32\x30\x30\x30\x30\x2F\x31\x30\x30\x30\x30\x22\x20\x74\x69\x66\x66\x3A\x59\x52\x65\x73\x6F\x6C\x75\x74\x69\x6F\x6E\x3D\x22\x37\x32\x30\x30\x30\x30\x2F\x31\x30\x30\x30\x30\x22\x20\x74\x69\x66\x66\x3A\x52\x65\x73\x6F\x6C\x75\x74\x69\x6F\x6E\x55\x6E\x69\x74\x3D\x22\x32\x22\x20\x65\x78\x69\x66\x3A\x43\x6F\x6C\x6F\x72\x53\x70\x61\x63\x65\x3D\x22\x36\x35\x35\x33\x35\x22\x20\x65\x78\x69\x66\x3A\x50\x69\x78\x65\x6C\x58\x44\x69\x6D\x65\x6E\x73\x69\x6F\x6E\x3D\x22\x33\x37\x34\x22\x20\x65\x78\x69\x66\x3A\x50\x69\x78\x65\x6C\x59\x44\x69\x6D\x65\x6E\x73\x69\x6F\x6E\x3D\x22\x32\x38\x22\x3E\x20\x3C\x70\x68\x6F\x74\x6F\x73\x68\x6F\x70\x3A\x54\x65\x78\x74\x4C\x61\x79\x65\x72\x73\x3E\x20\x3C\x72\x64\x66\x3A\x42\x61\x67\x3E\x20\x3C\x72\x64\x66\x3A\x6C\x69\x20\x70\x68\x6F\x74\x6F\x73\x68\x6F\x70\x3A\x4C\x61\x79\x65\x72\x4E\x61\x6D\x65\x3D\x22\x50\x65\x72\x73\x6F\x6E\x61\x6C\x20\x53\x6B\x69\x6E\x20\x43\x68\x61\x6E\x67\x65\x72\x22\x20\x70\x68\x6F\x74\x6F\x73\x68\x6F\x70\x3A\x4C\x61\x79\x65\x72\x54\x65\x78\x74\x3D\x22\x50\x65\x72\x73\x6F\x6E\x61\x6C\x20\x53\x6B\x69\x6E\x20\x43\x68\x61\x6E\x67\x65\x72\x22\x2F\x3E\x20\x3C\x2F\x72\x64\x66\x3A\x42\x61\x67\x3E\x20\x3C\x2F\x70\x68\x6F\x74\x6F\x73\x68\x6F\x70\x3A\x54\x65\x78\x74\x4C\x61\x79\x65\x72\x73\x3E\x20\x3C\x78\x6D\x70\x4D\x4D\x3A\x48\x69\x73\x74\x6F\x72\x79\x3E\x20\x3C\x72\x64\x66\x3A\x53\x65\x71\x3E\x20\x3C\x72\x64\x66\x3A\x6C\x69\x20\x73\x74\x45\x76\x74\x3A\x61\x63\x74\x69\x6F\x6E\x3D\x22\x63\x72\x65\x61\x74\x65\x64\x22\x20\x73\x74\x45\x76\x74\x3A\x69\x6E\x73\x74\x61\x6E\x63\x65\x49\x44\x3D\x22\x78\x6D\x70\x2E\x69\x69\x64\x3A\x65\x33\x63\x35\x65\x38\x64\x61\x2D\x36\x35\x32\x64\x2D\x38\x33\x34\x32\x2D\x39\x30\x33\x37\x2D\x62\x32\x64\x65\x39\x33\x66\x66\x66\x65\x30\x61\x22\x20\x73\x74\x45\x76\x74\x3A\x77\x68\x65\x6E\x3D\x22\x32\x30\x32\x31\x2D\x31\x32\x2D\x30\x38\x54\x30\x30\x3A\x30\x33\x3A\x35\x39\x2B\x30\x33\x3A\x30\x30\x22\x20\x73\x74\x45\x76\x74\x3A\x73\x6F\x66\x74\x77\x61\x72\x65\x41\x67\x65\x6E\x74\x3D\x22\x41\x64\x6F\x62\x65\x20\x50\x68\x6F\x74\x6F\x73\x68\x6F\x70\x20\x32\x32\x2E\x35\x20\x28\x57\x69\x6E\x64\x6F\x77\x73\x29\x22\x2F\x3E\x20\x3C\x72\x64\x66\x3A\x6C\x69\x20\x73\x74\x45\x76\x74\x3A\x61\x63\x74\x69\x6F\x6E\x3D\x22\x73\x61\x76\x65\x64\x22\x20\x73\x74\x45\x76\x74\x3A\x69\x6E\x73\x74\x61\x6E\x63\x65\x49\x44\x3D\x22\x78\x6D\x70\x2E\x69\x69\x64\x3A\x61\x36\x62\x62\x36\x61\x33\x61\x2D\x63\x32\x62\x33\x2D\x33\x35\x34\x32\x2D\x62\x35\x38\x64\x2D\x32\x39\x32\x63\x36\x38\x32\x64\x36\x30\x38\x66\x22\x20\x73\x74\x45\x76\x74\x3A\x77\x68\x65\x6E\x3D\x22\x32\x30\x32\x31\x2D\x31\x32\x2D\x30\x38\x54\x30\x30\x3A\x30\x38\x3A\x33\x38\x2B\x30\x33\x3A\x30\x30\x22\x20\x73\x74\x45\x76\x74\x3A\x73\x6F\x66\x74\x77\x61\x72\x65\x41\x67\x65\x6E\x74\x3D\x22\x41\x64\x6F\x62\x65\x20\x50\x68\x6F\x74\x6F\x73\x68\x6F\x70\x20\x32\x32\x2E\x35\x20\x28\x57\x69\x6E\x64\x6F\x77\x73\x29\x22\x20\x73\x74\x45\x76\x74\x3A\x63\x68\x61\x6E\x67\x65\x64\x3D\x22\x2F\x22\x2F\x3E\x20\x3C\x72\x64\x66\x3A\x6C\x69\x20\x73\x74\x45\x76\x74\x3A\x61\x63\x74\x69\x6F\x6E\x3D\x22\x63\x6F\x6E\x76\x65\x72\x74\x65\x64\x22\x20\x73\x74\x45\x76\x74\x3A\x70\x61\x72\x61\x6D\x65\x74\x65\x72\x73\x3D\x22\x66\x72\x6F\x6D\x20\x61\x70\x70\x6C\x69\x63\x61\x74\x69\x6F\x6E\x2F\x76\x6E\x64\x2E\x61\x64\x6F\x62\x65\x2E\x70\x68\x6F\x74\x6F\x73\x68\x6F\x70\x20\x74\x6F\x20\x69\x6D\x61\x67\x65\x2F\x70\x6E\x67\x22\x2F\x3E\x20\x3C\x72\x64\x66\x3A\x6C\x69\x20\x73\x74\x45\x76\x74\x3A\x61\x63\x74\x69\x6F\x6E\x3D\x22\x64\x65\x72\x69\x76\x65\x64\x22\x20\x73\x74\x45\x76\x74\x3A\x70\x61\x72\x61\x6D\x65\x74\x65\x72\x73\x3D\x22\x63\x6F\x6E\x76\x65\x72\x74\x65\x64\x20\x66\x72\x6F\x6D\x20\x61\x70\x70\x6C\x69\x63\x61\x74\x69\x6F\x6E\x2F\x76\x6E\x64\x2E\x61\x64\x6F\x62\x65\x2E\x70\x68\x6F\x74\x6F\x73\x68\x6F\x70\x20\x74\x6F\x20\x69\x6D\x61\x67\x65\x2F\x70\x6E\x67\x22\x2F\x3E\x20\x3C\x72\x64\x66\x3A\x6C\x69\x20\x73\x74\x45\x76\x74\x3A\x61\x63\x74\x69\x6F\x6E\x3D\x22\x73\x61\x76\x65\x64\x22\x20\x73\x74\x45\x76\x74\x3A\x69\x6E\x73\x74\x61\x6E\x63\x65\x49\x44\x3D\x22\x78\x6D\x70\x2E\x69\x69\x64\x3A\x37\x38\x30\x35\x37\x36\x38\x62\x2D\x62\x36\x37\x39\x2D\x31\x38\x34\x66\x2D\x62\x64\x31\x31\x2D\x66\x61\x31\x36\x36\x37\x64\x63\x65\x61\x61\x33\x22\x20\x73\x74\x45\x76\x74\x3A\x77\x68\x65\x6E\x3D\x22\x32\x30\x32\x31\x2D\x31\x32\x2D\x30\x38\x54\x30\x30\x3A\x30\x38\x3A\x33\x38\x2B\x30\x33\x3A\x30\x30\x22\x20\x73\x74\x45\x76\x74\x3A\x73\x6F\x66\x74\x77\x61\x72\x65\x41\x67\x65\x6E\x74\x3D\x22\x41\x64\x6F\x62\x65\x20\x50\x68\x6F\x74\x6F\x73\x68\x6F\x70\x20\x32\x32\x2E\x35\x20\x28\x57\x69\x6E\x64\x6F\x77\x73\x29\x22\x20\x73\x74\x45\x76\x74\x3A\x63\x68\x61\x6E\x67\x65\x64\x3D\x22\x2F\x22\x2F\x3E\x20\x3C\x2F\x72\x64\x66\x3A\x53\x65\x71\x3E\x20\x3C\x2F\x78\x6D\x70\x4D\x4D\x3A\x48\x69\x73\x74\x6F\x72\x79\x3E\x20\x3C\x78\x6D\x70\x4D\x4D\x3A\x44\x65\x72\x69\x76\x65\x64\x46\x72\x6F\x6D\x20\x73\x74\x52\x65\x66\x3A\x69\x6E\x73\x74\x61\x6E\x63\x65\x49\x44\x3D\x22\x78\x6D\x70\x2E\x69\x69\x64\x3A\x61\x36\x62\x62\x36\x61\x33\x61\x2D\x63\x32\x62\x33\x2D\x33\x35\x34\x32\x2D\x62\x35\x38\x64\x2D\x32\x39\x32\x63\x36\x38\x32\x64\x36\x30\x38\x66\x22\x20\x73\x74\x52\x65\x66\x3A\x64\x6F\x63\x75\x6D\x65\x6E\x74\x49\x44\x3D\x22\x78\x6D\x70\x2E\x64\x69\x64\x3A\x65\x33\x63\x35\x65\x38\x64\x61\x2D\x36\x35\x32\x64\x2D\x38\x33\x34\x32\x2D\x39\x30\x33\x37\x2D\x62\x32\x64\x65\x39\x33\x66\x66\x66\x65\x30\x61\x22\x20\x73\x74\x52\x65\x66\x3A\x6F\x72\x69\x67\x69\x6E\x61\x6C\x44\x6F\x63\x75\x6D\x65\x6E\x74\x49\x44\x3D\x22\x78\x6D\x70\x2E\x64\x69\x64\x3A\x65\x33\x63\x35\x65\x38\x64\x61\x2D\x36\x35\x32\x64\x2D\x38\x33\x34\x32\x2D\x39\x30\x33\x37\x2D\x62\x32\x64\x65\x39\x33\x66\x66\x66\x65\x30\x61\x22\x2F\x3E\x20\x3C\x2F\x72\x64\x66\x3A\x44\x65\x73\x63\x72\x69\x70\x74\x69\x6F\x6E\x3E\x20\x3C\x2F\x72\x64\x66\x3A\x52\x44\x46\x3E\x20\x3C\x2F\x78\x3A\x78\x6D\x70\x6D\x65\x74\x61\x3E\x20\x3C\x3F\x78\x70\x61\x63\x6B\x65\x74\x20\x65\x6E\x64\x3D\x22\x72\x22\x3F\x3E\x2A\x5B\x1F\xE9\x00\x00\x04\xF8\x49\x44\x41\x54\x78\xDA\xED\x9D\xE1\xB1\xAB\x20\x10\x85\xD3\x42\x5A\xB0\x05\x5B\xB0\x85\xB4\x90\x16\x68\xC1\x16\x6C\x21\x2D\xD8\x02\x2D\xD0\x82\x2D\xF0\x6E\xDE\xF3\xDD\x61\x08\x0A\x2C\x67\x11\xCD\x32\x73\xFE\xDC\x31\x80\xBB\x87\x2F\x08\xC4\x7B\xB3\xD6\xDE\x44\x22\x91\x48\x74\x1D\x49\x10\x44\x22\x91\x48\xC0\x2E\x12\x89\x44\x22\x01\xBB\x48\x24\x12\x89\x9A\x00\xFB\xF0\x23\x45\xD4\x70\x5B\x4B\x61\x3D\x0F\x86\x7A\xEE\x88\x7A\x00\x75\xF5\x4E\x3D\xFD\x2D\xB1\xFC\x5C\xDB\xB9\xF5\xE4\x5E\xEF\xE7\x27\xF2\xD9\x21\xF7\x33\x94\x02\xCE\x49\x72\x9F\x03\x9E\x7A\xAC\x7F\x7F\x16\x7A\x8C\x2D\x9F\x0C\xF1\xEB\xA9\xF9\xF6\xAE\x7F\x52\xEE\x37\xA3\xAD\xE2\x98\x32\xFA\xEC\x30\xAE\x51\xC0\xFE\xFE\x20\xB5\xCC\x4E\xC7\x4B\xEA\x51\xA0\x7A\xE0\xFD\x01\xD4\xF5\xF2\xEA\x99\x32\x60\xFB\x5B\x12\xAE\x0F\xF5\x51\x27\xB6\xA5\xB6\xEE\x1D\x0C\x76\xAE\x9C\xA8\x48\xBB\xC6\xAB\xAB\x2F\xE8\x8F\xAA\x91\x4F\x86\xF8\xBD\xA8\xF9\xF6\xAE\x9F\x0B\xFA\xAA\x13\x3F\x57\x14\xD3\x86\xC6\x3E\x8C\x6B\x67\x05\x7B\xD7\x18\xD8\x3B\x60\x72\x43\x7D\xD2\xEF\x59\x05\x18\xEC\x66\xA3\xFD\xFE\x22\x60\xEF\x28\x7D\x0E\xB4\x39\x7A\x33\x3E\x84\x57\xE1\xF9\x64\x88\xDF\x5C\x19\xEC\x24\x3F\x22\x62\xDA\xD0\xD8\xEF\xBE\x19\xEC\xBA\x82\x79\xC9\xFD\x61\xEC\x93\xDE\x33\x79\x0E\x08\xDE\xF5\xEC\xB4\x3F\x5E\x00\xEC\x9A\xD2\xE7\xF5\x91\x7C\x71\xAE\x5B\x7C\x58\xAC\x79\x40\x78\x15\x96\xCF\xB3\x83\xBD\xC4\x8F\x88\x98\x36\x32\xF6\xA1\x5C\x6B\x05\xEC\x66\xED\x4C\x8A\x9E\x8D\x81\x7D\x8C\x24\x37\xE5\xDE\x4C\x62\x9F\x96\xAD\x75\xC7\x4C\xB0\x8F\x5E\x9D\x6E\xFB\xCB\x05\xC0\x3E\x12\xC1\x3E\xED\x3D\x66\x3B\xF5\x6C\xE5\xCE\x64\x7A\x15\x92\xCF\xC4\xF8\xE5\xF8\x70\xF1\xD6\x7B\xB9\xC1\x4E\xF6\x23\x22\xA6\x28\x16\xB5\xC4\xB5\x52\xB0\x93\x93\x8C\x82\x03\xA5\x1E\xCE\xFE\x20\x07\xC2\x4E\x72\x9F\x85\x60\x77\x67\xA5\x93\xFF\x59\x7F\x43\xA8\x11\xB0\xB3\xE6\x24\x10\x03\x83\xEE\x23\x57\x3E\xC1\x3E\x1C\x03\x4F\x29\xDC\x60\x27\xFB\x11\x11\xD3\x23\xC7\x3E\x17\xD7\x04\xEC\xE7\x04\xFB\xC7\xAC\x34\x15\x04\xEB\x8E\x79\x68\x63\xD0\x84\x36\xCE\xBE\x08\xEC\xB3\x17\x97\xA1\x22\xD8\xC9\xF9\x6C\x11\x32\x39\x60\x2F\xF5\x23\x22\xA6\x02\xF6\x4F\xB0\x23\x97\x19\xA2\xA5\xE2\x3A\x62\xB5\x13\x18\x05\x60\xFF\x6B\xF8\xFF\xB3\xAB\x0C\xB0\xBF\x42\xB3\xD2\x40\x5B\xF7\x6F\x39\x15\x63\xFF\x1D\x63\xB4\xB9\x1B\x7E\x60\xB0\x93\xF2\x79\x00\x64\xC8\x63\x8C\xC3\x8F\x88\x98\x66\x6C\xAC\xCF\xB1\xFB\x6B\x85\x6B\xA7\xDA\x3C\x6D\x18\xEC\x73\x05\xB0\x6F\x6D\xDA\xE9\x75\xD3\x6F\x48\x88\xD5\x7D\xE7\x78\x55\x17\x5B\x5F\x3E\x19\xD8\x93\x72\xB2\xC6\xC4\xEC\x9D\x74\x60\x02\x7B\x71\x3E\xCF\x0E\x76\x84\x1F\x11\x31\x15\xB0\x0B\xD8\x8F\x04\xBB\x0A\xCC\x2C\xDD\x0D\x23\x45\x88\x55\xB7\x63\x5C\xFD\x25\x60\xF7\xDB\x98\xB8\xE0\x89\xCE\xE7\x05\xC0\x5E\xEC\x47\x44\x4C\x05\xEC\x02\xF6\x43\xC1\xEE\xAC\x49\x2E\xC4\x58\xE9\xBD\x01\x17\x18\x14\xDD\x95\xC1\x6E\xC3\xE7\xD2\x97\x4A\x33\xF6\xE2\x7C\x5E\x00\xEC\xC5\x7E\x44\xC4\x54\xC0\xFE\x09\xF6\xD9\xD2\x7F\x32\x9B\x5D\x4F\x0A\x14\xBD\xCF\x7C\x6C\xA6\x58\xDC\x2B\x05\xE6\x23\xC0\xBE\xFE\xBD\x8F\x19\x37\xD0\x86\x7F\x56\x38\xB4\x3F\xA2\xF7\x36\x9F\x0E\x00\x3B\x6B\x4E\xBC\xF5\x5D\xD2\xAC\xBD\x14\xEC\xD4\x7C\x72\x82\x7D\x8D\x7B\xC9\x58\x9D\x63\x60\x47\xF9\x11\x11\xD3\x0C\xB0\x3F\x33\x7D\x76\x18\xD7\xD8\x4F\xC5\x1C\xB9\x7B\x1C\x08\xC2\x8B\x69\x36\x59\x15\xEC\x29\xC6\x0D\xB4\x31\x12\xBE\xF9\xCD\x91\x60\xE7\xCC\x49\xE0\x48\x9D\x0D\x9D\xCE\xA8\x01\x76\x4A\x3E\x99\x4E\xB3\xBC\xFB\x30\x95\x9E\x18\x4B\x39\x15\x83\xF2\x23\x22\xA6\xC8\xFB\x6B\x85\x6B\x57\x07\x7B\x68\x63\x6C\xB8\x02\xD8\x1D\xE3\xEA\x44\xB0\x1B\xE2\x63\xDD\xE3\xA2\x60\xF7\xE3\xA1\x28\x27\x63\x50\x60\xCF\xCD\x67\xCD\x63\x8A\x4C\x60\x87\xF8\x11\x11\xD3\x13\x82\x3D\xCA\xB5\x56\xC0\x9E\xB3\xA4\x33\x64\x26\x76\x08\x3C\xF2\x6D\x1D\x9D\xEA\x18\x1E\xFB\xC9\x8F\xAE\x36\xFD\x67\xF0\x7A\x0F\x04\xF6\xF3\xAC\x70\x4E\x99\x00\xB9\x7B\x14\xF8\x84\x23\x27\x26\x74\x8F\x36\xE1\x2C\xBB\xFD\x7C\xEB\xDE\xBC\x13\x8B\x21\x77\xD0\xA7\xE4\x93\x71\x8C\xCD\x35\xC0\x8E\xF4\x23\x22\xA6\xC8\xA5\xA6\x56\xB8\xD6\x0A\xD8\x73\xCA\x8B\x90\xD8\x17\x61\xED\x18\xB5\x51\x87\xDA\xD0\x55\x91\x35\x51\xBD\x03\xF6\xC9\x33\xC0\x10\x91\xFF\xD3\xFA\x7B\xE1\xFD\x99\x03\x7C\x92\x9A\x93\xDF\xF7\xC1\x04\x36\x53\x75\x82\x97\xA0\x10\x4A\xC9\x67\xED\x4D\x4F\x06\xB0\xC3\xFC\x88\x88\x29\xE3\x26\xFD\x61\x5C\x3B\x23\xD8\x17\xE2\x37\xF6\x12\x5B\x43\xB5\x79\x2F\x78\x6A\x06\xEC\xCE\x3D\xBE\x02\xA6\xDD\x3C\x2B\x1C\x99\x25\xBB\x05\xF1\x1E\x8B\x9E\xE8\x13\xEE\x9C\xA8\x1D\xE8\x84\xEE\x9D\xD5\xAB\xB1\x7C\x9E\x1D\xEC\x68\x3F\x82\xC6\x48\x0B\x60\x87\x72\xED\x8C\x60\xB7\x96\xF0\x82\xA2\xC0\xD1\x29\x1D\x31\xCF\xA9\xC0\xEE\x83\x29\xF7\x08\x63\x04\xA8\x88\x37\xCF\x29\x82\x47\xB8\x73\x62\x12\x06\x8B\x71\x66\xF4\x8F\x1A\x5E\xDD\xCB\xE7\x05\xC0\x0E\xF5\x23\x68\x8C\xA8\x46\xC6\x3E\x8C\x6B\x67\x05\xFB\x44\xFC\xC6\x9E\xB7\x60\x63\xB7\x7F\xD8\x90\x0D\xAD\xC2\x35\x44\x05\x38\xAE\x36\xA5\x00\x3A\x52\xC7\xE6\x00\x24\xE6\x4E\x13\x3C\x82\xCC\x89\x4A\xD9\x18\xDE\xB8\x56\x6D\xCC\xE6\x53\xCA\x88\xCC\x67\x66\xFC\x0E\xF1\x61\x04\xEC\x50\x3F\x82\xC6\xC8\x83\xD9\x67\xD5\xB9\x46\x01\x7B\xE7\xAC\x7D\x75\x37\x29\x52\xA4\x48\x91\xD2\x54\xB1\xF2\xCF\xAC\x45\x22\x91\x48\xFE\x99\xB5\x48\x24\x12\x89\x04\xEC\x22\x91\x48\x24\x12\xB0\x8B\x44\x22\x91\x08\xAA\x3F\x1A\x33\xEB\x27\x4D\x93\xD9\xFA\x00\x00\x00\x00\x49\x45\x4E\x44\xAE\x42\x60\x82"

-- Licensed under the MIT License
-- Copyright (c) 2021, dmitriyewich <https://github.com/dmitriyewich/Personal-Skin-Changer>
