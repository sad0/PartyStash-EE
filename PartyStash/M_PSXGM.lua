--[[
Party Stash "grand marchand" (camp merchant), branch feature/grand-marchand (John 2026-10-23). Requires EEex and
M_PSTASH.lua (its engine stubs and item data). BGEE / BG2EE / EET, v2.6.6 and v2.7.3.

One merchant at the camp (SadoQoL's creature: StartStore("PSXCAMP", ...)) sells every item seen at the stores the
party already visited.
1. Discovery: each time a store opens, its items are recorded (best markup seen, stock) and copied into the camp
   store PSXCAMP, a real STO, through CInfGame::AddItemToStore: the vanilla buy flow (gold, room, stolen flags) works
   unchanged. Infinite stock, except uniques (stock 1 at the store where it was seen, or a named magic item): a unique
   bought once is gone. Critical / quest items are never copied. Stores visited before the install: read once per
   game from the loaded save (its BALDUR.SAV lists the stores it holds).
   Kept in the save: PSXGP_<RES> = lowest sell markup seen (%), PSXGF_<RES> = flags (1 seen with more than one in
   stock, 2 a unique already given to the camp), PSXGM_SCAN = the loaded save was scanned.
2. Price: the best markup seen, per item. The camp store's markup (STO +0x14) is switched to the item's own just
   around the engine's select + buy calls; reputation and charisma apply on top as the game does.
3. The page (PSXGM.menu) replaces the vanilla buy list of the camp store: category tree, 8 x 7 icon grid with pages,
   name search, "usable by the selected character" and "affordable" filters, wishlist first (Ctrl + click, global
   PSXW_<RES>, the same as M_PSXENG.lua), price in the tooltip. Selling stays on the vanilla panel ("Vanilla view")
   and its "Sell Marked" button.
Console: PSXGM.DEBUG = true   PSXGM_Rescan()   PSXGM_Catalog()
--]]

PSXGM = PSXGM or {}
local G = PSXGM
G.CAMP = 'PSXCAMP'
G.COLS, G.ROWS = 8, 7
G.DEBUG = G.DEBUG or false
G.page = G.page or 1
G.cat = G.cat or 'all'
G.expanded = G.expanded or {}
G.sort = G.sort or 'type'
G.qty = G.qty or 1
G.msg = G.msg or ''
G.queue = G.queue or {}
PSXGM_search = PSXGM_search or ''

local function log(...)
	if G.DEBUG then print('[PSXGM] ' .. string.format(...)) end
end

-- English UI strings; a translation can override them through PStash_Strings (keys gm_*).
G.EN = {
	gm_title = 'Camp merchant', gm_all = 'All', gm_weapons = 'Weapons', gm_armor = 'Armor', gm_equipment = 'Equipment',
	gm_potions = 'Potions', gm_scrolls = 'Scrolls', gm_gems = 'Gems', gm_ammo = 'Ammo', gm_misc = 'Misc',
	gm_bows = 'Bows', gm_crossbows = 'Crossbows', gm_slings = 'Slings', gm_daggers = 'Daggers',
	gm_short_swords = 'Short swords', gm_long_swords = 'Long swords', gm_bastard_swords = 'Bastard swords',
	gm_two_handed = 'Two-handed swords', gm_katanas = 'Katanas', gm_scimitars = 'Scimitars', gm_axes = 'Axes',
	gm_maces = 'Maces', gm_hammers = 'War hammers', gm_flails = 'Flails, morning stars', gm_clubs = 'Clubs',
	gm_staves = 'Quarterstaves', gm_spears = 'Spears', gm_halberds = 'Halberds', gm_fists = 'Fist weapons',
	gm_robes = 'Robes', gm_leather = 'Leather', gm_mail = 'Mail', gm_plate = 'Plate', gm_other_armor = 'Other armor',
	gm_shields = 'Shields', gm_helmets = 'Helmets', gm_bracers = 'Bracers, gauntlets',
	gm_rings = 'Rings', gm_amulets = 'Amulets', gm_belts = 'Belts', gm_boots = 'Boots', gm_cloaks = 'Cloaks',
	gm_wands = 'Wands', gm_bags = 'Bags',
	gm_arrows = 'Arrows', gm_bolts = 'Bolts', gm_bullets = 'Bullets', gm_darts = 'Darts',
	gm_search = 'Search', gm_usable = 'Usable', gm_affordable = 'Affordable', gm_sort = 'Sort: %s',
	gm_sort_type = 'Type', gm_sort_price = 'Price', gm_sort_name = 'Name',
	gm_buy = 'Buy', gm_done = 'Done', gm_vanilla = 'Sell / vanilla view', gm_back = 'Camp merchant',
	gm_price = '%d gp', gm_unique = 'Unique', gm_unlimited = 'Unlimited', gm_wished = 'Wishlist',
	gm_items = '%d items', gm_empty = 'Nothing here yet: visit stores to fill the camp merchant.',
	gm_no_gold = 'Not enough gold', gm_full = 'Backpack full: select another character', gm_cannot_buy = 'Cannot buy that now', gm_bought = 'Bought: %s x%d',
	gm_select = 'Click an item. Ctrl + click: wishlist. Right click: description.',
	gm_total = 'Total: %d gp',
	gm_skin = 'Board: %s', gm_skin_1 = 'pinned notices', gm_skin_2 = 'painted',
}
local function T(key, ...)
	local s = (PStash_Strings and PStash_Strings[key]) or G.EN[key] or key
	if select('#', ...) > 0 then return string.format(s, ...) end
	return s
end
PSXGM_T = T

-- Infinity_IsMenuOnStack returns 1 / nil, not booleans.
local function onStack(name) return Infinity_IsMenuOnStack(name) and true or false end

local function ctrlDown()
	return EEex_Key_IsDown(EEex_Key_GetFromName('Left Ctrl')) or EEex_Key_IsDown(EEex_Key_GetFromName('Right Ctrl'))
end

local function getG(name) return EEex_GameState_GetGlobalInt(name) end
local function setG(name, v) EEex_GameState_SetGlobalInt(name, v) end

-- Wishlist: the same globals as M_PSXENG.lua (PSXW_<RES>).
local function isWished(res)
	if PSXEng_IsWished then return PSXEng_IsWished(res) end
	return res ~= nil and res ~= '' and getG('PSXW_' .. res) == 1
end
local function toggleWish(res)
	if PSXEng_ToggleWish then return PSXEng_ToggleWish(res) end
	setG('PSXW_' .. res, isWished(res) and 0 or 1)
end

-----------------------
-- Engine access      --
-----------------------

local function readRes(addr)
	local out = {}
	for i = 0, 7 do
		local b = EEex_ReadU8(addr + i)
		if b == 0 then break end
		out[#out + 1] = string.char(b)
	end
	return string.upper(table.concat(out))
end

G.scratch = G.scratch or nil
local function resRef(res, offset)
	G.scratch = G.scratch or EEex_Malloc(64) -- [0] store resref, [16] item resref, [32] int err
	local buf = G.scratch + (offset or 0)
	res = string.upper(res)
	for i = 0, 7 do EEex_WriteU8(buf + i, i < #res and string.byte(res, i + 1) or 0) end
	return buf
end

local function gamePtr() return EEex_UDToPtr(EEex_EngineGlobal_CBaldurChitin.m_pObjectGame) end

-- CStore layout (BGEE 2.7.3, CStore::GetItemBuyValue): the STO header is copied at +0: +0x08 type, +0x10 flags,
-- +0x14 sell markup (what the player pays, %). Inventory entries (CStoreFileItem, STO layout): +0x00 resref,
-- +0x0A..0x0E 3 usages, +0x10 flags (1 identified, 4 stolen), +0x14 stock, +0x18 infinite.
local STO_TYPE, STO_FLAGS, STO_SELL = 0x08, 0x10, 0x14
local FI_USE1, FI_FLAGS, FI_STOCK, FI_INF = 0x0A, 0x10, 0x14, 0x18

local function storeEntries(storePtr)
	local out = {}
	EEex_Utility_IterateCPtrList(EEex_PtrToUD(storePtr, 'CStore').m_lInventory, function(data)
		local ptr = type(data) == 'number' and data or EEex_UDToPtr(data)
		out[#out + 1] = { ptr = ptr, res = readRes(ptr), flags = EEex_ReadU32(ptr + FI_FLAGS),
			stock = EEex_ReadU32(ptr + FI_STOCK), inf = EEex_ReadU32(ptr + FI_INF),
			u = { EEex_ReadU16(ptr + FI_USE1), EEex_ReadU16(ptr + FI_USE1 + 2), EEex_ReadU16(ptr + FI_USE1 + 4) } }
	end)
	return out
end

-- Runs fn(storePtr) on a server store (loaded from the save when it was visited), released after.
local function withStore(res, fn)
	if not (PStash_Ready and PStash_Ready()) then return nil end
	local game = gamePtr()
	PStash_Eng_DemandServerStore(game, resRef(res), 0)
	local ok, a, b = pcall(function()
		local p = PStash_Eng_GetServerStore(game, resRef(res))
		if p == 0 then return nil end
		return fn(p)
	end)
	PStash_Eng_ReleaseServerStore(game, resRef(res))
	if not ok then print('[PSXGM] ' .. res .. ': ' .. tostring(a)) return nil end
	return a, b
end

-- The store open in the store screen: (CStore*, resref) or nil.
local function openStore()
	if storeScreen == nil or e:GetActiveEngine() ~= storeScreen then return nil end
	local ok, p, res = pcall(function()
		-- the EEex view of the screen (the global storeScreen is the engine's own binding, without fields)
		local s = EEex_EngineGlobal_CBaldurChitin.m_pEngineStore.m_pStore
		if s == nil then return nil end
		return EEex_UDToPtr(s), string.upper(s.m_resRef:get())
	end)
	if ok and p and p ~= 0 then return p, res end
end
G.openStore = openStore

local function atCamp()
	local _, res = openStore()
	return res == G.CAMP
end
PSXGM_AtCamp = atCamp

-----------------------
-- Item data          --
-----------------------

G.info = G.info or {}
-- PStash_ItemInfo + the armor animation (ITM +0x22) and the names as text.
local function itemInfo(res)
	local c = G.info[res]
	if c ~= nil then return c or nil end
	local pi = PStash_ItemInfo and PStash_ItemInfo(res)
	if not pi then G.info[res] = false return nil end
	c = setmetatable({}, { __index = pi })
	pcall(function()
		local p = EEex_UDToPtr(EEex_Resource_Demand(res, 'ITM'))
		c.anim = string.char(EEex_ReadU8(p + 0x22), EEex_ReadU8(p + 0x23))
	end)
	c.anim = c.anim or ''
	c.idText = Infinity_FetchString(pi.idName) or ''
	c.unidText = Infinity_FetchString(pi.unidName) or ''
	G.info[res] = c
	return c
end

local function questItem(info, res)
	local P = PStash or {}
	if info.critical then return true end
	if P.NOT_QUEST and P.NOT_QUEST[res] then return false end
	return (P.KEEP and P.KEEP[res]) or (P.QUEST and P.QUEST[res]) or false
end

-- Never sold at the camp: quest / critical items, gold, the Party Stash bag itself.
local function excluded(info, res)
	return questItem(info, res) or info.type == 33 or res == 'PSTASH'
end

-- A named magic item: its identified name is not its unidentified one with a "+N" (Varscona +2 vs Long Sword,
-- not Long Sword +1). Ammo, potions, scrolls, gems and anything stackable never count.
local NOT_NAMED = { [5] = true, [9] = true, [11] = true, [14] = true, [24] = true, [31] = true, [34] = true }
local function namedItem(info)
	if not info.magical and info.enchant == 0 then return false end
	if NOT_NAMED[info.type] or info.stack > 1 then return false end
	local id = string.lower(info.idText):gsub('%s*%+%s*%d+%s*$', ''):gsub('^%s+', ''):gsub('%s+$', '')
	local unid = string.lower(info.unidText):gsub('^%s+', ''):gsub('%s+$', '')
	return id ~= '' and unid ~= '' and id ~= unid
end
G.namedItem = namedItem

-- Engine functions of our own, through the same fixed-target stubs as M_PSTASH.lua (PStash.buildStub). Same bytes
-- on BGEE / BG2EE / EET of each build (checked 2026-10-23). The game's Lua has no io library: the save file is read
-- with the engine's own C runtime (_wfopen, fread, fseek, fclose) and dimmResolveFileName ("home:/..." -> real path).
-- CStore::AddItem: CInfGame::AddItemToStore only takes bags (STO type 5) and pays the item's sale value.
local FILE_FUNCS = {
	['2.7.3.0'] = { ResolveFileName = 0x1404058F0, wfopen = 0x14050FAA0, fread = 0x14050F354, fseek = 0x14050FD20,
		fclose = 0x14050F060, StoreAddItem = 0x14024F650 },
	['2.6.6.0'] = { ResolveFileName = 0x140404A50, wfopen = 0x14050EAC0, fread = 0x14050E374, fseek = 0x14050ED40,
		fclose = 0x14050E080, StoreAddItem = 0x14024F3F0 },
}
local FILE_PROLOGUE = {
	ResolveFileName = { { 0x40, 0x53, 0x48, 0x83, 0xEC, 0x20, 0x41, 0xB8 }, 1 },
	wfopen = { { 0x41, 0xB8, 0x40, 0x00, 0x00, 0x00, 0xE9 }, 2 },
	fread = { { 0x48, 0x83, 0xEC, 0x38, 0x4C, 0x89, 0x4C, 0x24 }, 4 },
	fseek = { { 0x48, 0x63, 0xD2, 0xE9 }, 3 },
	fclose = { { 0x48, 0x89, 0x5C, 0x24, 0x10, 0x48, 0x89, 0x4C }, 1 },
	StoreAddItem = { { 0x40, 0x53, 0x55, 0x56, 0x48, 0x83, 0xEC, 0x70 }, 2 }, -- CStore::AddItem(this, CItem&)
}

local function fileReady()
	if G.fileReady ~= nil then return G.fileReady end
	G.fileReady = false
	local build = PStash_Build and PStash_Build()
	local t = build and FILE_FUNCS[build]
	if not t or not (PStash and PStash.buildStub) then return false end
	for name, pro in pairs(FILE_PROLOGUE) do
		for i, b in ipairs(pro[1]) do
			if EEex_ReadU8(t[name] + i - 1) ~= b then print('[PSXGM] ' .. name .. ': unknown bytes') return false end
		end
	end
	for name, pro in pairs(FILE_PROLOGUE) do
		if not _G['PStash_Eng_GM_' .. name] then PStash.buildStub('GM_' .. name, t[name], pro[2]) end
	end
	G.fileReady = true
	return true
end

-----------------------
-- Camp store         --
-----------------------

local function gpKey(res) return 'PSXGP_' .. res end
local function gfKey(res) return 'PSXGF_' .. res end
local function bestMarkup(res) return getG(gpKey(res)) end
PSXGM_BestMarkup = bestMarkup

local function isUnique(info, res)
	return namedItem(info) or EEex_BAnd(getG(gfKey(res)), 1) == 0
end

local function findEntry(storePtr, res)
	for _, it in ipairs(storeEntries(storePtr)) do if it.res == res then return it end end
end

-- A CItem for AddItemToStore (the engine copies it; ours is destroyed right after).
-- CItem(CResRef, useCount1, useCount2, useCount3, wear, flags) through the binding's manual overload.
local function makeItem(res, u)
	local it = EEex_NewUD('CItem')
	local rr = EEex_NewUD('CResRef')
	rr:set(res)
	it:Construct_Overload_Manual(rr, u[1], u[2], u[3], 0, 1)
	return it
end
G.makeItem = makeItem

-- Puts one more entry in the camp store (the server store, kept and saved by the engine).
local function addToCamp(campPtr, res, u)
	local ok, err = pcall(function()
		if not fileReady() then error('engine build not supported') end
		local it = makeItem(res, u)
		if PStash_Eng_GM_StoreAddItem(campPtr, EEex_UDToPtr(it)) % 256 == 0 then error('refused') end
	end)
	if not ok then print('[PSXGM] add ' .. res .. ': ' .. tostring(err)) return nil end
	return findEntry(campPtr, res)
end

-- Makes the camp store sell `res`. Returns 1 when an entry was added.
local function campOffer(campPtr, res, info, u)
	local unique = isUnique(info, res)
	local e = findEntry(campPtr, res)
	if e then
		if not unique and e.inf == 0 then -- first seen as a unique, now found in stock elsewhere
			EEex_Write32(e.ptr + FI_INF, 1)
			EEex_Write32(e.ptr + FI_STOCK, math.max(1, info.stack))
		end
		return 0
	end
	if unique and EEex_BAnd(getG(gfKey(res)), 2) ~= 0 then return 0 end -- sold once already
	e = addToCamp(campPtr, res, u)
	if not e then return 0 end
	EEex_Write32(e.ptr + FI_FLAGS, EEex_BOr(EEex_ReadU32(e.ptr + FI_FLAGS), 1)) -- identified, as at a store
	if unique then
		EEex_Write32(e.ptr + FI_STOCK, 1)
		EEex_Write32(e.ptr + FI_INF, 0)
		setG(gfKey(res), EEex_BOr(getG(gfKey(res)), 2))
	else
		EEex_Write32(e.ptr + FI_STOCK, math.max(1, info.stack))
		EEex_Write32(e.ptr + FI_INF, 1)
	end
	log('camp + %s%s', res, unique and ' (unique)' or '')
	return 1
end

-- Records a store's items and offers them at the camp. Returns the number of new camp entries.
local function discover(storePtr, storeRes)
	if storeRes == G.CAMP or storeRes == 'PSTASH' then return 0 end
	local typ, flags, markup = EEex_ReadU32(storePtr + STO_TYPE), EEex_ReadU32(storePtr + STO_FLAGS),
		EEex_ReadU32(storePtr + STO_SELL)
	-- containers / bags (type 5) and stores that sell nothing (flag bit 0 "user can buy") are not merchants
	if typ == 5 or EEex_BAnd(flags, 1) == 0 then return 0 end
	local seen = {}
	for _, it in ipairs(storeEntries(storePtr)) do
		local info = it.res ~= '' and itemInfo(it.res)
		if info and not excluded(info, it.res) and not seen[it.res] then
			seen[it.res] = it
			local best = bestMarkup(it.res)
			if best == 0 or markup < best then setG(gpKey(it.res), math.max(1, markup)) end
			if it.inf ~= 0 or it.stock > 1 or info.stack > 1 then setG(gfKey(it.res), EEex_BOr(getG(gfKey(it.res)), 1)) end
		end
	end
	local added = withStore(G.CAMP, function(camp)
		local n = 0
		for res, it in pairs(seen) do n = n + campOffer(camp, res, itemInfo(res), it.u) end
		return n
	end) or 0
	log('store %s: %d items, markup %d, %d new at the camp', storeRes, (function() local k = 0 for _ in pairs(seen) do k = k + 1 end return k end)(), markup, added)
	if added > 0 then G.dirty = true end
	return added
end
G.discover = discover

-----------------------
-- Stores before the install: the loaded save's BALDUR.SAV
-----------------------

local function writeCStr(addr, s)
	for i = 1, #s do EEex_WriteU8(addr + i - 1, string.byte(s, i)) end
	EEex_WriteU8(addr + #s, 0)
end
local function readCStr(addr, max)
	local out = {}
	for i = 0, (max or 1024) - 1 do
		local b = EEex_ReadU8(addr + i)
		if b == 0 then break end
		out[#out + 1] = string.char(b)
	end
	return table.concat(out)
end
-- UTF-8 -> NUL-terminated UTF-16LE at addr.
local function writeWStr(addr, s)
	local o, i, n = addr, 1, #s
	local function put(u) EEex_WriteU16(o, u) o = o + 2 end
	while i <= n do
		local c = string.byte(s, i)
		local cp, len
		if c < 0x80 then cp, len = c, 1
		elseif c < 0xE0 then cp, len = c % 0x20, 2
		elseif c < 0xF0 then cp, len = c % 0x10, 3
		else cp, len = c % 0x08, 4 end
		for k = 1, len - 1 do cp = cp * 64 + (string.byte(s, i + k) or 0x80) % 64 end
		if cp >= 0x10000 then
			cp = cp - 0x10000
			put(0xD800 + math.floor(cp / 1024)) put(0xDC00 + cp % 1024)
		else put(cp) end
		i = i + len
	end
	put(0)
end

-- Store resrefs held by the save file at `alias` ("home:/save/<name>/BALDUR.SAV"); nil when it cannot be read.
-- Entries: u32 name length, name, u32 size, u32 compressed size, zlib data: only the names are read.
local function savStores(alias)
	if not fileReady() then return nil end
	local buf = EEex_Malloc(0x1000)
	local out
	local ok, err = pcall(function()
		writeCStr(buf, alias)
		local path = readCStr(PStash_Eng_GM_ResolveFileName(buf), 1024)
		writeWStr(buf, path)
		writeWStr(buf + 0x900, 'rb')
		local f = PStash_Eng_GM_wfopen(buf, buf + 0x900)
		if f == 0 then return end
		local function read(n)
			if n > 0x800 or PStash_Eng_GM_fread(buf + 0x800, 1, n, f) ~= n then return nil end
			local s = {}
			for i = 0, n - 1 do s[#s + 1] = string.char(EEex_ReadU8(buf + 0x800 + i)) end
			return table.concat(s)
		end
		local function u32at(s, i)
			local a, b, c, d = string.byte(s, i, i + 3)
			return a + b * 256 + c * 65536 + d * 16777216
		end
		if read(8) == 'SAV V1.0' then
			out = {}
			while true do
				local h = read(4)
				if not h then break end
				local nl = u32at(h, 1)
				local name = nl > 0 and read(nl)
				local sz = name and read(8)
				if not sz then break end
				local stem = string.upper(name:gsub('%z.*$', '')):match('^(.-)%.STO$')
				if stem then out[#out + 1] = stem end
				if PStash_Eng_GM_fseek(f, u32at(sz, 5), 1) ~= 0 then break end -- SEEK_CUR past the data
			end
		end
		PStash_Eng_GM_fclose(f)
	end)
	EEex_Free(buf)
	if not ok then print('[PSXGM] save read: ' .. tostring(err)) return nil end
	return out
end
G.savStores = savStores

-- The loaded save's BALDUR.SAV ("home:/<save dir>/<save name>/BALDUR.SAV") as store resrefs, or nil.
-- The folder follows the campaign (BGEE: SoD saves in sodsave/, BP in bpsave/; the same save name can be in both).
local CAMPAIGN_DIR = { SOD = 'sodsave', BP = 'bpsave' }
local function loadedSaveStores()
	local game = EEex_EngineGlobal_CBaldurChitin.m_pObjectGame
	local name = game.m_sSaveGame.m_pchData:get()
	if not name or name == '' then return nil end
	local ok, camp = pcall(function() return game.m_sCurrentCampaign.m_pchData:get() end)
	local dir = CAMPAIGN_DIR[ok and string.upper(camp or '') or ''] or 'save'
	for _, dir in ipairs({ dir, 'mp' .. dir }) do
		local out = savStores('home:/' .. dir .. '/' .. name .. '/BALDUR.SAV')
		if out then return out, dir .. '/' .. name end
	end
end
G.loadedSaveStores = loadedSaveStores

function PSXGM_Rescan()
	local stores, where = loadedSaveStores()
	if not stores then print('[PSXGM] the loaded save could not be read') return 0 end
	local n = 0
	for _, res in ipairs(stores) do
		n = n + (withStore(res, function(p) return discover(p, res) end) or 0)
	end
	print(string.format('[PSXGM] %s: %d stores, %d new camp items', where, #stores, n))
	return n
end

-----------------------
-- Categories         --
-----------------------

local function types(...)
	local s = {}
	for _, t in ipairs({ ... }) do s[t] = true end
	return function(info) return s[info.type] == true end
end
-- Large swords (20) split by proficiency (BG EE: 89 bastard, 90 long, 93 two-handed, 94 katana, 95 scimitar).
local function sword(profs, extra)
	local p = {}
	for _, v in ipairs(profs) do p[v] = true end
	return function(info) return (info.type == 20 and p[info.prof] == true) or (extra and info.type == extra) end
end
local function armorAnim(pred) return function(info) return info.type == 2 and pred(info.anim) end end

G.TREE = {
	{ key = 'all', label = 'gm_all' },
	{ key = 'weap', label = 'gm_weapons', children = {
		{ key = 'w_bow', label = 'gm_bows', match = types(15) },
		{ key = 'w_xbow', label = 'gm_crossbows', match = types(27) },
		{ key = 'w_sling', label = 'gm_slings', match = types(18) },
		{ key = 'w_dagger', label = 'gm_daggers', match = types(16) },
		{ key = 'w_short', label = 'gm_short_swords', match = types(19) },
		{ key = 'w_long', label = 'gm_long_swords', match = function(i) return i.type == 20 and not (i.prof == 89 or i.prof == 93 or i.prof == 94 or i.prof == 95) end },
		{ key = 'w_bastard', label = 'gm_bastard_swords', match = sword({ 89 }, 69) },
		{ key = 'w_2h', label = 'gm_two_handed', match = sword({ 93 }, 57) },
		{ key = 'w_katana', label = 'gm_katanas', match = sword({ 94 }) },
		{ key = 'w_scim', label = 'gm_scimitars', match = sword({ 95 }) },
		{ key = 'w_axe', label = 'gm_axes', match = types(25) },
		{ key = 'w_mace', label = 'gm_maces', match = types(17) },
		{ key = 'w_hammer', label = 'gm_hammers', match = types(21) },
		{ key = 'w_flail', label = 'gm_flails', match = types(22, 23) },
		{ key = 'w_club', label = 'gm_clubs', match = types(44) },
		{ key = 'w_staff', label = 'gm_staves', match = types(26) },
		{ key = 'w_spear', label = 'gm_spears', match = types(29) },
		{ key = 'w_halb', label = 'gm_halberds', match = types(30) },
		{ key = 'w_fist', label = 'gm_fists', match = types(28) },
	} },
	{ key = 'arm', label = 'gm_armor', children = {
		{ key = 'a_robe', label = 'gm_robes', match = armorAnim(function(a) return a:sub(2, 2) == 'W' end) },
		{ key = 'a_leather', label = 'gm_leather', match = armorAnim(function(a) return a == '2A' end) },
		{ key = 'a_mail', label = 'gm_mail', match = armorAnim(function(a) return a == '3A' end) },
		{ key = 'a_plate', label = 'gm_plate', match = armorAnim(function(a) return a == '4A' end) },
		{ key = 'a_other', label = 'gm_other_armor', match = function(i)
			return (i.type == 2 and not (i.anim:sub(2, 2) == 'W' or i.anim == '2A' or i.anim == '3A' or i.anim == '4A'))
				or (i.type >= 60 and i.type <= 68) end },
		{ key = 'a_shield', label = 'gm_shields', match = types(12, 41, 47, 49, 53) },
		{ key = 'a_helm', label = 'gm_helmets', match = types(7, 72) },
		{ key = 'a_bracer', label = 'gm_bracers', match = types(6, 73) },
	} },
	{ key = 'equip', label = 'gm_equipment', children = {
		{ key = 'e_ring', label = 'gm_rings', match = types(10) },
		{ key = 'e_amulet', label = 'gm_amulets', match = types(1) },
		{ key = 'e_belt', label = 'gm_belts', match = types(3) },
		{ key = 'e_boots', label = 'gm_boots', match = types(4) },
		{ key = 'e_cloak', label = 'gm_cloaks', match = types(32) },
		{ key = 'e_wand', label = 'gm_wands', match = types(35) },
		{ key = 'e_bag', label = 'gm_bags', match = types(36) },
	} },
	{ key = 'pot', label = 'gm_potions', match = types(9) },
	{ key = 'scr', label = 'gm_scrolls', match = types(11) },
	{ key = 'gem', label = 'gm_gems', match = types(34) },
	{ key = 'ammo', label = 'gm_ammo', children = {
		{ key = 'm_arrow', label = 'gm_arrows', match = types(5) },
		{ key = 'm_bolt', label = 'gm_bolts', match = types(31) },
		{ key = 'm_bullet', label = 'gm_bullets', match = types(14) },
		{ key = 'm_dart', label = 'gm_darts', match = types(24) },
	} },
	{ key = 'misc', label = 'gm_misc' },
}

-- Leaves in tree order: { node, parent, order }.
G.leaves, G.nodes = {}, {}
do
	local order = 0
	for _, top in ipairs(G.TREE) do
		G.nodes[top.key] = top
		if top.match then order = order + 1 G.leaves[#G.leaves + 1] = { node = top, parent = top, order = order } end
		for _, c in ipairs(top.children or {}) do
			order = order + 1
			c.parent = top
			G.nodes[c.key] = c
			G.leaves[#G.leaves + 1] = { node = c, parent = top, order = order }
		end
	end
end

-- The leaf an item belongs to (nil = Misc), cached per resref.
G.leafOf = G.leafOf or {}
local function leafOf(info, res)
	local l = G.leafOf[res]
	if l ~= nil then return l or nil end
	for _, lf in ipairs(G.leaves) do
		if lf.node.match(info) then G.leafOf[res] = lf return lf end
	end
	G.leafOf[res] = false
end

local function inCategory(key, info, res)
	if key == 'all' then return true end
	local lf = leafOf(info, res)
	if key == 'misc' then return lf == nil end
	if not lf then return false end
	return lf.node.key == key or lf.parent.key == key
end

-- Tree rows for the list: top nodes, the expanded one's children indented.
G.treeRows = G.treeRows or {}
local function buildTree()
	local rows = {}
	for _, top in ipairs(G.TREE) do
		local mark = top.children and (G.expanded[top.key] and '- ' or '+ ') or '  '
		rows[#rows + 1] = { key = top.key, text = mark .. T(top.label), depth = 0 }
		if top.children and G.expanded[top.key] then
			for _, c in ipairs(top.children) do rows[#rows + 1] = { key = c.key, text = '      ' .. T(c.label), depth = 1 } end
		end
	end
	-- refilled in place: the menu's list keeps the table it was given
	for i = #G.treeRows, 1, -1 do G.treeRows[i] = nil end
	for i, r in ipairs(rows) do G.treeRows[i] = r end
end
buildTree()
PSXGM_treeVar = PSXGM_treeVar or 1

function PSXGM_TreeClick()
	local r = G.treeRows[PSXGM_treeVar]
	if not r then return end
	local node = G.nodes[r.key]
	if node.children then
		local open = not (G.expanded[r.key] and G.cat == r.key)
		G.expanded = {}
		G.expanded[r.key] = open or nil
	end
	G.cat, G.page = r.key, 1
	buildTree()
	G.dirty = true
end
function PSXGM_TreeText(row)
	local r = G.treeRows[row]
	if not r then return '' end
	return r.text
end
function PSXGM_TreeSelected(row) local r = G.treeRows[row] return r ~= nil and r.key == G.cat end

-----------------------
-- Usable by          --
-----------------------

-- ITM 0x1E "unusable by" bits (copy of M_PSTASH.lua's rules: class, race, alignment, kit, minimum stats).
local CLASS_BIT = { [1] = 0x40000, [2] = 0x800, [3] = 0x80, [4] = 0x400000, [5] = 0x40, [6] = 0x100000,
	[7] = 0x2000, [8] = 0x4000, [9] = 0x20000, [10] = 0x10000, [11] = 0x40000000, [12] = 0x200000, [13] = 0x80000,
	[14] = 0x100, [15] = 0x200, [16] = 0x1000, [17] = 0x8000, [18] = 0x400, [19] = 0x40000, [20] = 0x20000000,
	[21] = 0x40000000 }
local RACE_BIT = { [1] = 0x8000000, [2] = 0x800000, [3] = 0x2000000, [4] = 0x1000000, [5] = 0x4000000,
	[6] = 0x10000000, [7] = 0x80000000 }
G.kits = G.kits or {}
local function kitUnusable(kitId)
	if not kitId or kitId < 0x4000 then return nil end
	if G.kits[kitId] == nil then
		G.kits[kitId] = false
		pcall(function()
			local t = EEex_Resource_Load2DA('KITLIST')
			local u = tonumber(EEex_Resource_GetAt2DALabels(t, 'UNUSABLE', tostring(kitId - 0x4000)))
			if u then
				G.kits[kitId] = { math.floor(u / 0x1000000) % 256, math.floor(u / 0x10000) % 256,
					math.floor(u / 0x100) % 256, u % 256 }
			end
		end)
	end
	return G.kits[kitId] or nil
end

local function usableBy(sp, info)
	if not sp then return true end
	local ai, f = sp.m_typeAI, info.unusable
	local function has(bit) return bit ~= nil and EEex_BAnd(f, bit) ~= 0 end
	if has(CLASS_BIT[ai.m_Class]) or has(RACE_BIT[ai.m_Race]) then return false end
	local law, moral = math.floor(ai.m_Alignment / 16), ai.m_Alignment % 16
	if (law == 3 and has(0x1)) or (moral == 3 and has(0x2)) or (moral == 1 and has(0x4)) or (moral == 2 and has(0x8))
		or (law == 1 and has(0x10)) or (law == 2 and has(0x20)) then
		return false
	end
	local kit = kitUnusable(EEex_Sprite_GetStat(sp, 152))
	if kit and (EEex_BAnd(info.kit[1], kit[1]) ~= 0 or EEex_BAnd(info.kit[2], kit[2]) ~= 0
		or EEex_BAnd(info.kit[3], kit[3]) ~= 0 or EEex_BAnd(info.kit[4], kit[4]) ~= 0) then
		return false
	end
	local function st(n) return EEex_Sprite_GetStat(sp, n) end
	if st(36) < info.minStr or (st(36) == 18 and info.minStr == 18 and st(37) < info.minStrEx) then return false end
	return st(38) >= info.minInt and st(40) >= info.minDex and st(39) >= info.minWis and st(41) >= info.minCon
		and st(42) >= info.minCha
end
G.usableBy = usableBy

local function selectedSprite()
	local ok, sp = pcall(EEex_Sprite_GetSelected)
	if ok and sp then return sp end
	return EEex_Sprite_GetInPortrait(0)
end

-----------------------
-- Grid view          --
-----------------------

local function entryRes(en) return en and en.item and string.upper(en.item.res or '') or '' end
local function cleanLabel(s)
	s = tostring(s or '')
	if s:sub(1, 2) == '* ' then s = s:sub(3) end
	-- the engine's label ends with the stock: "Name<no-break space> (1)" (U+00A0 = bytes 194 160)
	s = s:gsub('%s*%(%d+%)%s*$', '')
	return (s:gsub('\194\160', ' '):gsub('%s+$', ''))
end
local function partyGold()
	local ok, g = pcall(function() return game:GetPartyGold() end)
	return ok and tonumber(g) or 0
end

-- What the item costs here: the engine's price at the camp markup, scaled to the best markup seen.
local function priceOf(en, res, campMk)
	local v = tonumber(en.value) or 0
	local best = bestMarkup(res)
	if best <= 0 or campMk <= 0 then return v end
	return math.floor(v * best / campMk + 0.5)
end

local function campMarkup()
	local p = openStore()
	return p and EEex_ReadU32(p + STO_SELL) or 100
end

G.view = G.view or {}
G.wishV = G.wishV or 0
local function viewKey()
	local sp = selectedSprite()
	return table.concat({ tostring(store and store.storeItems), G.cat, PSXGM_search or '', tostring(G.usable),
		tostring(G.afford), G.sort, G.afford and partyGold() or 0, G.usable and sp and sp.m_id or 0, G.wishV }, '|')
end

local function rebuild()
	local list = store and store.storeItems or {}
	local out, sp, gold, campMk = {}, selectedSprite(), partyGold(), campMarkup()
	local q = string.lower(PSXGM_search or ''):gsub('^%s+', ''):gsub('%s+$', '')
	for i, en in ipairs(list) do
		local res = entryRes(en)
		local info = res ~= '' and itemInfo(res)
		if info then
			local name = cleanLabel(en.label)
			local price = priceOf(en, res, campMk)
			if inCategory(G.cat, info, res)
				and (q == '' or string.find(string.lower(name), q, 1, true))
				and (not G.usable or usableBy(sp, info))
				and (not G.afford or price <= gold) then
				local lf = leafOf(info, res)
				out[#out + 1] = { en = en, row = i, res = res, info = info, name = name, price = price,
					wish = isWished(res), unique = en.item.count ~= 0xFFFF and isUnique(info, res),
					order = lf and lf.order or 999, usable = usableBy(sp, info) }
			end
		end
	end
	local mode = G.sort
	table.sort(out, function(a, b)
		if a.wish ~= b.wish then return a.wish end
		if mode == 'price' then
			if a.price ~= b.price then return a.price > b.price end
		elseif mode == 'type' then
			if a.order ~= b.order then return a.order < b.order end
			if a.price ~= b.price then return a.price > b.price end
		end
		if a.name ~= b.name then return a.name < b.name end
		return a.row < b.row
	end)
	G.view = out
	G.pages = math.max(1, math.ceil(#out / (G.COLS * G.ROWS)))
	G.page = math.max(1, math.min(G.page, G.pages))
	G.key = viewKey()
	G.dirty = false
end

local function view()
	if G.dirty or G.key ~= viewKey() then rebuild() end
	return G.view
end

local function cell(i)
	return view()[(G.page - 1) * G.COLS * G.ROWS + i + 1]
end
G.cell = cell

local function selected()
	if not G.sel then return nil end
	for _, c in ipairs(view()) do if c.res == G.sel then return c end end
end

function PSXGM_CellIcon(i) local c = cell(i) return c and c.en.item.icon or nil end
function PSXGM_CellCount(i)
	local c = cell(i)
	if not c then return nil end
	local s = c.en.item.stackSize
	return (s and s > 1) and s or nil
end
function PSXGM_CellTint(i)
	local c = cell(i)
	if not c then return nil end
	if c.res == G.sel then return 'PSTASHOR' end
	return c.en.item.tint
end
function PSXGM_CellGrey(i) local c = cell(i) return c ~= nil and not c.usable end
function PSXGM_CellWished(i) local c = cell(i) return c ~= nil and c.wish end
function PSXGM_CellUnique(i) local c = cell(i) return c ~= nil and c.unique end
function PSXGM_CellTip(i)
	local c = cell(i)
	if not c then return '' end
	local s = c.name .. '\n' .. T('gm_price', c.price)
	if c.unique then s = s .. '  (' .. T('gm_unique') .. ')' end
	if c.wish then s = s .. '\n* ' .. T('gm_wished') end
	return s
end
function PSXGM_CellClick(i)
	local c = cell(i)
	if not c then return end
	if ctrlDown() then
		toggleWish(c.res)
		G.wishV = G.wishV + 1
		return
	end
	if G.sel ~= c.res then G.qty = 1 end
	G.sel, G.msg = c.res, ''
end
function PSXGM_CellDesc(i)
	local c = cell(i)
	if c then showItemDescription(c.en.item, 1) end
end
function PSXGM_Wheel()
	local d = (scrollDirection or 0)
	if d == 0 then return end
	PSXGM_Page(d > 0 and -1 or 1)
end
function PSXGM_Page(d) view() G.page = math.max(1, math.min(G.pages or 1, G.page + d)) end
function PSXGM_PageText() view() return string.format('%d / %d', G.page, G.pages or 1) end
function PSXGM_CountText()
	local n = #view()
	if n == 0 and G.cat == 'all' and PSXGM_search == '' then return T('gm_empty') end
	return T('gm_items', n)
end
function PSXGM_CanPage(d)
	view()
	return (d < 0 and G.page > 1) or (d > 0 and G.page < (G.pages or 1))
end

function PSXGM_ToggleUsable() G.usable = not G.usable G.page = 1 end
function PSXGM_ToggleAfford() G.afford = not G.afford G.page = 1 end
function PSXGM_FilterText(which)
	return T(which == 'usable' and 'gm_usable' or 'gm_affordable')
end
-- ROUNDBUT frame: 2 = on, 0 = off.
function PSXGM_FilterFrame(which)
	local on = (which == 'usable' and G.usable) or (which == 'afford' and G.afford)
	return on and 2 or 0
end
local SORTS = { 'type', 'price', 'name' }
function PSXGM_NextSort()
	for k, s in ipairs(SORTS) do
		if s == G.sort then G.sort = SORTS[k % #SORTS + 1] break end
	end
	G.page = 1
end
function PSXGM_SortText() return T('gm_sort', T('gm_sort_' .. G.sort)) end

-- Page background (John 2026-10-23): 1 = notice board assembled from pieces (PSXGMBA), 2 = the same redrawn by
-- SwarmUI (PSXGMBB, the default: John 2026-10-23). Kept in Baldur.lua (per player, not per save).
function PSXGM_Skin()
	if not G.skin then
		local ok, v = pcall(Infinity_GetINIValue, 'Party Stash', 'Camp Merchant Board', 2)
		G.skin = (ok and tonumber(v) == 1) and 1 or 2
	end
	return G.skin
end
function PSXGM_NextSkin()
	G.skin = PSXGM_Skin() == 1 and 2 or 1
	pcall(Infinity_SetINIValue, 'Party Stash', 'Camp Merchant Board', G.skin)
end
function PSXGM_SkinText() return T('gm_skin', T('gm_skin_' .. PSXGM_Skin())) end

-- Selected item panel.
function PSXGM_SelIcon() local c = selected() return c and c.en.item.icon or nil end
function PSXGM_SelName() local c = selected() return c and c.name or T('gm_select') end
function PSXGM_SelInfo()
	local c = selected()
	if not c then return '' end
	return T('gm_price', c.price) .. '\n' .. (c.unique and T('gm_unique') or T('gm_unlimited'))
end
function PSXGM_SelDesc() local c = selected() if c then showItemDescription(c.en.item, 1) end end
local function maxQty(c)
	if not c then return 1 end
	if c.unique then return 1 end
	return 99
end
function PSXGM_Qty(d)
	local c = selected()
	G.qty = math.max(1, math.min(maxQty(c), (G.qty or 1) + d))
end
function PSXGM_QtyText() return tostring(G.qty or 1) end
function PSXGM_TotalText()
	local c = selected()
	if not c then return '' end
	return T('gm_total', c.price * (G.qty or 1))
end
function PSXGM_GoldText() return T('gm_price', partyGold()) end
function PSXGM_MsgText() return G.msg or '' end
function PSXGM_CanBuy()
	local c = selected()
	return c ~= nil and c.price * (G.qty or 1) <= partyGold()
end

-----------------------
-- Buying             --
-----------------------

local function rowOf(res)
	for i, en in ipairs(store and store.storeItems or {}) do
		if entryRes(en) == res then return i - 1, en end
	end
end

-- A free backpack slot on the character buying (the store screen's selected one).
local function freeSlot()
	local sp = selectedSprite()
	if not sp then return false end
	for i = 18, 32 do if not sp.m_equipment.m_items:get(i) then return true end end
	return false
end

local function clearSelection()
	for i, en in ipairs(store and store.storeItems or {}) do
		if en.highlight == 1 then storeScreen:SelectStoreItem(i - 1, false) end
	end
end

-- Buys `qty` of `res` through the engine (select + Buy), the camp markup set to the item's best one meanwhile.
function PSXGM_Buy(res, qty)
	local campPtr, campRes = openStore()
	if not campPtr or campRes ~= G.CAMP then return 0 end
	res = string.upper(res or G.sel or '')
	qty = qty or G.qty or 1
	local saved = EEex_ReadU32(campPtr + STO_SELL)
	local best = bestMarkup(res)
	local bought, why = 0, nil
	local ok, err = pcall(function()
		if best > 0 then EEex_Write32(campPtr + STO_SELL, best) end
		clearSelection()
		while bought < qty do
			local row, en = rowOf(res)
			if not row then break end
			local n = math.min(qty - bought, math.max(1, tonumber(en.maxCount) or 1))
			storeScreen:SelectStoreItem(row, true)
			if n > 1 then storeScreen:SetStoreItemCount(row, n) end
			if not storeScreen:IsBuyItemButtonClickable() then
				storeScreen:SelectStoreItem(row, false)
				if partyGold() < priceOf(en, res, saved) * n then why = T('gm_no_gold')
				elseif not freeSlot() then why = T('gm_full')
				else why = T('gm_cannot_buy') end
				break
			end
			storeScreen:OnBuyItemButtonClick()
			bought = bought + n
		end
	end)
	EEex_Write32(campPtr + STO_SELL, saved)
	pcall(function() storeScreen:UpdateBuySellPanel() end)
	if not ok then print('[PSXGM] buy error: ' .. tostring(err)) why = T('gm_cannot_buy') end
	local c = itemInfo(res)
	G.msg = why or T('gm_bought', c and c.idText or res, bought)
	if bought > 0 and isUnique(c, res) then G.sel = nil end
	G.dirty = true
	log('buy %s x%d -> %d (%s)', res, qty, bought, tostring(why))
	return bought
end
function PSXGM_BuySelected() if G.sel then PSXGM_Buy(G.sel, G.qty) end end

-----------------------
-- Page open / close  --
-----------------------

function PSXGM_Vanilla()
	G.vanilla = true
	if Infinity_IsMenuOnStack('PSXGM_PAGE') then Infinity_PopMenu('PSXGM_PAGE') end
end
function PSXGM_Back()
	G.vanilla = false
	pcall(function() storeScreen:UpdateBuySellPanel() end)
end
function PSXGM_Done()
	G.vanilla = false
	if Infinity_IsMenuOnStack('PSXGM_PAGE') then Infinity_PopMenu('PSXGM_PAGE') end
	pcall(function() storeScreen:OnMainDoneButtonClick() end)
end
function PSXGM_OnOpen()
	G.dirty, G.msg = true, ''
	PSXGM_search = PSXGM_search or ''
end
function PSXGM_ShowBack()
	return G.vanilla == true and atCamp() and onStack('STORE_BUYSELL')
end

local function syncMenus()
	local p, res = openStore()
	local buysell = p ~= nil and onStack('STORE_BUYSELL')
	local want = buysell and res == G.CAMP and not G.vanilla
	local shown = onStack('PSXGM_PAGE')
	if want and not shown then Infinity_PushMenu('PSXGM_PAGE') elseif shown and not want then Infinity_PopMenu('PSXGM_PAGE') end
	local wantBack = buysell and res == G.CAMP and G.vanilla == true
	local backShown = onStack('PSXGM_BACK')
	if wantBack and not backShown then Infinity_PushMenu('PSXGM_BACK') elseif backShown and not wantBack then Infinity_PopMenu('PSXGM_BACK') end
end

-- Tick (PSXGM_TICK's enabled check, every frame; throttled).
function PSXGM_Tick()
	local now = Infinity_GetClockTicks()
	if G.next and now < G.next then return false end
	G.next = now + 100
	local p, res = openStore()
	if p then
		if p ~= G.visitPtr then
			G.visitPtr, G.visitRes, G.vanilla, G.sel = p, res, false, nil
			if res ~= G.CAMP and not storeScreen:IsContainer() then
				local ok, err = pcall(discover, p, res)
				if not ok then print('[PSXGM] discover error: ' .. tostring(err)) end
			end
		end
	else
		G.visitPtr = nil
		if worldScreen ~= nil and e:GetActiveEngine() == worldScreen and G.scanFor ~= G.gameId then
			G.scanFor = G.gameId
			if getG('PSXGM_SCAN') == 0 then
				setG('PSXGM_SCAN', 1)
				local ok, err = pcall(PSXGM_Rescan)
				if not ok then print('[PSXGM] save scan error: ' .. tostring(err)) end
			end
		end
	end
	pcall(syncMenus)
	return false
end

-- The camp catalog: { total, unique, infinite, sample = 'RES ...' } (a long print crashed the game: no listing).
function PSXGM_Catalog(maxSample)
	local out = { total = 0, unique = 0, infinite = 0 }
	local sample = {}
	withStore(G.CAMP, function(camp)
		for _, it in ipairs(storeEntries(camp)) do
			out.total = out.total + 1
			if it.inf ~= 0 then out.infinite = out.infinite + 1 else out.unique = out.unique + 1 end
			if #sample < (maxSample or 10) then
				sample[#sample + 1] = string.format('%s %d%% %s', it.res, bestMarkup(it.res), it.inf ~= 0 and 'inf' or 'x' .. it.stock)
			end
		end
	end)
	out.sample = table.concat(sample, ', ')
	return out
end

-- The store screen rebuilds store.storeItems on each change: the tick menu is pushed from there too, so it runs at
-- a store even when it was not on the stack (the world screen pushes it otherwise).
local function pushTick()
	if Infinity_IsMenuOnStack('PSXGM_TICK') then return end
	local eng = e:GetActiveEngine()
	if (worldScreen ~= nil and eng == worldScreen) or (storeScreen ~= nil and eng == storeScreen) then
		Infinity_PushMenu('PSXGM_TICK')
	end
end
G.pushTick = pushTick

-- The page menu is PSXGM_PAGE, not PSXGM: the engine makes a global of each menu's name (a number), which
-- overwrote this module's table (John 2026-10-23: the tree and the search broke).

-- Chains onto the `store` proxy of M_PSXENG.lua (made first), or makes a plain one.
local function hookStoreTable()
	if type(store) ~= 'table' then return false end
	if PSXEng_HookStore then pcall(PSXEng_HookStore) end
	local mt = getmetatable(store)
	if mt and mt.__psxgm then return true end
	local function onWrite(k, v)
		if k == 'storeItems' then G.dirty = true pcall(pushTick) end
	end
	if mt and mt.__psx then
		local orig = mt.__newindex
		mt.__newindex = function(t, k, v) orig(t, k, v) onWrite(k, v) end
		mt.__psxgm = true
		return true
	end
	if mt then return false end
	local data = {}
	for k, v in pairs(store) do data[k] = v end
	for k in pairs(data) do store[k] = nil end
	setmetatable(store, {
		__psxgm = true,
		__index = data,
		__newindex = function(_, k, v) data[k] = v onWrite(k, v) end,
		__pairs = function() return next, data, nil end,
	})
	return true
end
G.hookStoreTable = hookStoreTable

if not G.pushWrapped then
	G.pushWrapped = true
	local push = Infinity_PushMenu
	Infinity_PushMenu = function(...)
		local m = ...
		local r = table.pack(push(...))
		if m ~= 'PSXGM_TICK' then pcall(pushTick) end
		return table.unpack(r, 1, r.n)
	end
end

if not G.listenersAdded then
	G.listenersAdded = true
	EEex_Menu_AddMainFileLoadedListener(function()
		EEex_Menu_LoadFile('PSXGM')
		G.hooked = hookStoreTable()
	end)
	EEex_Menu_AddAfterMainFileReloadedListener(function()
		G.hooked = hookStoreTable()
		pcall(pushTick)
	end)
	EEex_GameState_AddInitializedListener(function()
		G.gameId = (G.gameId or 0) + 1 -- new game or load: the save scan runs again if PSXGM_SCAN is 0
		G.info, G.leafOf = {}, {}
		pcall(pushTick)
	end)
end
