
if type(getgenv) == "function" then
    local g = getgenv()
    local petViewerCleanup = rawget(g, "_1rzHubLitePetViewerCleanup")
    if type(petViewerCleanup) == "function" then
        pcall(petViewerCleanup)
        g._1rzHubLitePetViewerCleanup = nil
    end
    if rawget(g, "_1rzHubLite_Loaded") then return end
    g._1rzHubLite_Loaded = true
end

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local VIM = game:GetService("VirtualInputManager")
local CollectionService = game:GetService("CollectionService")
local CoreGui = game:GetService("CoreGui")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer


task.spawn(function()
    repeat task.wait() until CoreGui:FindFirstChild("RobloxPromptGui")
    local pg = CoreGui:FindFirstChild("RobloxPromptGui")
    local po = pg and pg:FindFirstChild("promptOverlay") or pg and pg:WaitForChild("promptOverlay", 30)
    if not po then return end
    po.ChildAdded:Connect(function(child)
        if child.Name == "ErrorPrompt" then
            task.spawn(function()
                while true do
                    pcall(function() TeleportService:Teleport(game.PlaceId, player) end)
                    task.wait(2)
                end
            end)
        end
    end)
end)

-- ============================================================
-- Config
-- ============================================================
local configFile = "1rzHubLiteConfig.json"
local defaultConfig = {
    -- Event
    autoCollectPresentRain = false,
    -- Chests
    selectedWorldChest = "Giant Chest",
    autoClaimWorldChest = false,
    selectedChest = "golden-chest",
    autoChestSummon = false,
    autoChest = false,
    -- Eggs
    selectedEgg = "",
    selectedRiftEgg = "",
    autoRiftEgg = false,
    autoRiftEggSpawn = false,
    autoHatch = false,
    noHatchAnim = false,
    autoSpamE = false,
    autoBounty = false,
    spawnRift = false,
    autoLuckEgg = false,
    -- Enchant
    autoEnchant = false,
    equippedTargetEnchant = "secret-hunter",
    equippedTargetEnchant2 = "",
    equippedTargetEnchantLevel = 0,
    equippedEnchantCurrency = "Auto (Secret=Crystals, Normal=Gems)",
    -- Game
    autoPlaytime = false,
    autoCollectCoins = false,
    autoBubble = false,
    selectedMysteryBox = "Mystery Box",
    autoOpenMystery = false,
    autoOpenMysteryDelay = 0.2,
    -- Minigames
    selectedClawDifficulty = "Insane",
    autoClaw = false,
    -- Quests
    autoGemGenie = false,
    optimisedGemGenie = false,
    gemGenieTargetItem = "Shadow Crystal",
    autoSeason = false,
    autoDailyHourlyChallenge = false,
    autoGlobalIncentive = false,
    autoClaimGlobalIncentive = false,
    -- Shrines
    DreamerShrineEnabled = false,
    DreamerShrineAmount = 1,
    shrineAuto = false,
    shrineLevel = 1,
    shrinePotion = "Lucky",
    shrineAmount = 10,
     -- Rebirth
    RebirthPetName = "Man Face Lord",
    AdminRebirthPetName = "Man Face Lord",
    RebirthVariants = { "Normal" },
    RebirthMachineEnabled = false,
    AdminRebirthMachineEnabled = false,
        -- Teams
    teamHatch = 1,
    teamBubble = 2,
    teamCurrency1 = 3,
    teamCurrency2 = 4,
    autoSwitchTeams = true,
    -- Other
    disableRendering = false,
}

local mainConfigFile = "1rzHubConfig.json"
local Config
local function loadConfig()
    -- Track which keys came from lite's own file so we don't overwrite them with main's stale value.
    local liteSet = {}
    if isfile and isfile(configFile) then
        local ok, data = pcall(function() return HttpService:JSONDecode(readfile(configFile)) end)
        if ok and type(data) == "table" then
            for k, v in pairs(defaultConfig) do
                if data[k] ~= nil and typeof(data[k]) == typeof(v) then
                    defaultConfig[k] = data[k]
                    liteSet[k] = true
                end
            end
        end
    end
    -- Fallback: seed missing keys from main 1rzHub config if present.
    if isfile and isfile(mainConfigFile) then
        local ok, data = pcall(function() return HttpService:JSONDecode(readfile(mainConfigFile)) end)
        if ok and type(data) == "table" then
            for k, v in pairs(defaultConfig) do
                if not liteSet[k] and data[k] ~= nil and typeof(data[k]) == typeof(v) then
                    defaultConfig[k] = data[k]
                end
            end
        end
    end
    return defaultConfig
end
local function saveConfig()
    if not writefile then return end
    pcall(function()
        writefile(configFile, HttpService:JSONEncode(Config))
    end)
end
Config = loadConfig()
for k, v in pairs(defaultConfig) do if Config[k] == nil then Config[k] = v end end


local Fluent
do
    local fluentFile = "Fluent.lua"
    local src
    if isfile and isfile(fluentFile) then
        src = readfile(fluentFile)
    else
        src = game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua")
        if writefile then pcall(writefile, fluentFile, src) end
    end
    Fluent = loadstring(src)()
end
_G.FluentLite = Fluent
local LocalData = require(ReplicatedStorage.Client.Framework.Services.LocalData)
local TimeUtil = require(ReplicatedStorage.Shared.Framework.Utilities.Math.Time)
local QuestUtil = require(ReplicatedStorage.Shared.Utils.Stats.QuestUtil)
local EnchantUtil, EnchantsData, PetsData, EggsData, RiftsData, BountyUtil, PowerupsData, ItemUtil
pcall(function() EnchantUtil = require(ReplicatedStorage.Shared.Utils.EnchantUtil) end)
pcall(function() EnchantsData = require(ReplicatedStorage.Shared.Data.Enchants) end)
pcall(function() PetsData = require(ReplicatedStorage.Shared.Data.Pets) end)
pcall(function() EggsData = require(ReplicatedStorage.Shared.Data.Eggs) end)
pcall(function() RiftsData = require(ReplicatedStorage.Shared.Data.Rifts) end)
pcall(function() BountyUtil = require(ReplicatedStorage.Shared.Utils.Stats.BountyUtil) end)
pcall(function() PowerupsData = require(ReplicatedStorage.Shared.Data.Powerups) end)
pcall(function() ItemUtil = require(ReplicatedStorage.Shared.Utils.Stats.ItemUtil) end)

local RemoteFolder = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote")
local remote = RemoteFolder:WaitForChild("RemoteEvent")
local remotefunction = RemoteFolder:WaitForChild("RemoteFunction")
-- ============================================================
-- Team switcher
-- ============================================================
local _currentTeam = nil
local function equipTeam(teamNumber)
    if type(teamNumber) ~= "number" or teamNumber < 1 or teamNumber > 10 then
        return false
    end
    local ok = pcall(function()
        remote:FireServer("EquipTeam", teamNumber)
    end)
    if ok then
        _currentTeam = teamNumber
        return true
    end
    return false
end

local function getCurrentTeam()
    return _currentTeam
end

-- Team name resolution (lets you pass "hatch", "bubble", "currency1", "currency2")
local function resolveTeamName(name)
    if type(name) == "number" then return name end
    if type(name) ~= "string" then return nil end
    local n = string.lower(name)
    if n == "hatch" or n == "hatching" then return Config.teamHatch end
    if n == "bubble" or n == "bubbling" then return Config.teamBubble end
    if n == "currency1" or n == "coins" or n == "coin" then return Config.teamCurrency1 end
    if n == "currency2" or n == "gems" or n == "gem" then return Config.teamCurrency2 end
    return nil
end

-- Switch to a named team (returns true on success)
local function switchToTeam(name)
    local n = resolveTeamName(name)
    if not n then return false end
    return equipTeam(n)
end

local HatchModule, originalPlay
pcall(function()
    HatchModule = require(ReplicatedStorage.Client.Effects.HatchEgg)
    originalPlay = HatchModule and HatchModule.Play or nil
end)


local function setHRPCFrame(cf)
    if typeof(cf) ~= "CFrame" or not player then return false end
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart", 5)
    if not hrp then return false end
    hrp.CFrame = cf
    return true
end

local cachedMaxHatch, lastMaxHatchAt = nil, 0
local function getMaxHatchAmount()
    if cachedMaxHatch and tick() - lastMaxHatchAt < 5 then return cachedMaxHatch end
    local m
    pcall(function()
        if LocalData:IsReady() then
            local d = LocalData:Get()
            m = d and (d.MaxHatch or d.HatchLimit or d.HatchAmount or (d.Upgrades and d.Upgrades.HatchAmount) or (d.Stats and d.Stats.MaxHatch))
        end
    end)
    if type(m) ~= "number" or m < 1 then m = 80 end
    cachedMaxHatch, lastMaxHatchAt = m, tick()
    return m
end

-- ============================================================
-- Hardcoded egg coordinates
-- Add: ["Egg Name"] = Vector3.new(X, Y, Z),
-- ============================================================
local EGG_COORDS = {
    -- ["Common Egg"]     = Vector3.new(0, 0, 0),
    -- ["Unique Egg"]     = Vector3.new(0, 0, 0),
    -- ["Rare Egg"]       = Vector3.new(0, 0, 0),
    -- ["Epic Egg"]       = Vector3.new(0, 0, 0),
    -- ["Legendary Egg"]  = Vector3.new(0, 0, 0),
    -- ["Secret Egg"]     = Vector3.new(0, 0, 0),
    -- ["Infinity Egg"]   = Vector3.new(0, 0, 0),
}

local INFINITY_EGG_SAVE_Y_OFFSET = 10
local EGG_SAVE_Y_OFFSET = 5

local function resolveEggPosition(name)
    if type(name) ~= "string" or name == "" then return nil end
    local c = EGG_COORDS[name]
    if not c then return nil end
    local yOff = (name == "Infinity Egg") and INFINITY_EGG_SAVE_Y_OFFSET or EGG_SAVE_Y_OFFSET
    return { X = c.X, Y = c.Y + yOff, Z = c.Z }
end

local function buildEggPickerList()
    local out = {}
    for name in pairs(EGG_COORDS) do
        table.insert(out, name)
    end
    table.sort(out, function(a, b) return string.lower(a) < string.lower(b) end)
    return out
end

local function getTrackedRowsForEgg(name)
    local c = EGG_COORDS[name]
    if not c then return {} end
    return { { name = name, position = c, key = "hardcoded", exact = true, loaded = true } }
end

-- Uniform Y offset added when teleporting so player lands above the egg, not inside it.
-- Tracker coords get a base offset first, then this final player-safe offset.
local TELEPORT_Y_OFFSET = 3
local function teleportToEggByName(name)
    local pos = resolveEggPosition(name)
    if not pos then return false end
    return setHRPCFrame(CFrame.new(pos.X, pos.Y + TELEPORT_Y_OFFSET, pos.Z))
end

local function fireHatch(egg)
    if type(egg) ~= "string" or egg == "" then return end
    pcall(function() remote:FireServer("HatchEgg", egg, getMaxHatchAmount()) end)
end

-- Quest helpers
local function getTaskRequirement(task)
    if not task then return 1 end
    if QuestUtil and type(QuestUtil.GetRequirement) == "function" then
        local ok, r = pcall(function() return QuestUtil:GetRequirement(task) end)
        if ok and type(r) == "number" then return r end
    end
    if type(task) == "table" then
        local a = tonumber(task.Amount or task.amount)
        if a then return a end
        if type(task.Item) == "table" then
            local ia = tonumber(task.Item.Amount or task.Item.amount)
            if ia then return ia end
        end
    end
    return 1
end
local function getTaskProgress(quest, idx)
    if not quest or not idx then return 0 end
    local best = 0
    if QuestUtil then
        pcall(function()
            if type(QuestUtil.GetTaskProgress) == "function" then
                local n = QuestUtil:GetTaskProgress(quest, idx)
                if type(n) == "number" and n > best then best = n end
            end
        end)
    end
    if quest.Progress and type(quest.Progress) == "table" then
        for _, k in ipairs({ idx, tostring(idx), tonumber(idx) }) do
            local v = quest.Progress[k]
            if type(v) == "number" and v > best then best = v end
        end
    end
    local row = quest.Tasks and quest.Tasks[idx]
    if type(row) == "table" then
        if row.Completed == true then
            best = math.max(best, getTaskRequirement(row))
        end
        for _, key in ipairs({"Progress", "Current", "Count", "Value"}) do
            local v = row[key]
            if type(v) == "number" and v > best then best = v end
        end
    end
    return best
end
local function orderedTaskIndices(tasks)
    if type(tasks) ~= "table" then return {} end
    if #tasks > 0 then
        local out = {}
        for i = 1, #tasks do out[i] = i end
        return out
    end
    local keys = {}
    for k in pairs(tasks) do
        local n = tonumber(k)
        if n and n >= 1 then table.insert(keys, n) end
    end
    table.sort(keys)
    return keys
end

local function effectiveTaskRow(td)
    if type(td) ~= "table" then return td end
    local item = td.Item
    if type(item) == "table" and type(item.Task) == "table" then return item.Task end
    if type(td.Task) == "table" then return td.Task end
    return td
end
local function taskTypeLooksLikeCollect(td)
    td = effectiveTaskRow(td)
    if type(td) ~= "table" then return false end
    local t = td.Type or td.type
    if type(t) == "string" then
        local l = string.lower(t)
        if l == "collect" or l == "coins" or l == "coin" then return true end
    end
    local item = td.Item
    if type(item) == "table" and (item.Type == "Currency") then
        return true
    end
    return false
end
local function collectCurrencyKey(td)
    td = effectiveTaskRow(td)
    if type(td) ~= "table" or type(td.Item) ~= "table" then return nil end
    if td.Item.Type ~= "Currency" then return nil end
    local c = td.Item.Currency
    if type(c) == "string" then return string.lower(c) end
    return nil
end
local function taskTypeLower(td)
    td = effectiveTaskRow(td)
    if type(td) ~= "table" then return "" end
    return string.lower(tostring(td.Type or td.type or ""))
end
local function looksLikeBubble(td)
    local t = taskTypeLower(td)
    return t == "bubble" or t == "bubbles" or string.find(t, "bubble", 1, true) ~= nil
end
local function looksLikeHatch(td)
    local t = taskTypeLower(td)
    if t == "hatchegggroup" then return false end
    return t == "hatch" or string.find(t, "hatch", 1, true) ~= nil
end
local function resolveHatchEgg(td)
    local row = effectiveTaskRow(td) or td
    if type(row) == "table" then
        local e = row.Egg or row.egg or row.EggName
        if type(e) == "string" and e ~= "" then return e end
        if type(row.Item) == "table" then
            local n = row.Item.Name or row.Item.Egg
            if type(n) == "string" and n ~= "" then return n end
        end
        if row.Rarity then
            if type(row.Rarity) == "string" and string.lower(row.Rarity) == "unique" then return "Void Egg" end
            return "Infinity Egg"
        end
    end
    return (type(Config.selectedEgg) == "string" and Config.selectedEgg ~= "") and Config.selectedEgg or "Common Egg"
end

-- Gem-cost shop item drain (for gems collect tasks at cap).
local gemShopCache = nil
local function buildGemShopCache()
    if type(gemShopCache) == "table" then return gemShopCache end
    local out = {}
    local ok, ShopsModule = pcall(function() return require(ReplicatedStorage.Shared.Data.Shops) end)
    if not ok or type(ShopsModule) ~= "table" then gemShopCache = out; return out end
    local function consider(shop, slot, item)
        if type(item) ~= "table" then return end
        local cost = item.Cost or (type(item.Item) == "table" and item.Item.Cost)
        if type(cost) ~= "table" then return end
        local cur = cost.Currency
        local amt = tonumber(cost.Amount)
        if type(cur) == "string" and string.lower(cur) == "gems" and amt and amt > 0 then
            table.insert(out, { shop = shop, slot = slot, amount = amt })
        end
    end
    for sn, sd in pairs(ShopsModule) do
        if type(sn) == "string" and type(sd) == "table" then
            for _, key in ipairs({"PermanentItems","RandomItems","Items","Slots"}) do
                if type(sd[key]) == "table" then
                    for slot, item in pairs(sd[key]) do consider(sn, slot, item) end
                end
            end
        end
    end
    table.sort(out, function(a, b) return a.amount < b.amount end)
    gemShopCache = out
    return out
end
local function getCoinsCount()
    local n = 0
    pcall(function()
        if LocalData:IsReady() then
            local d = LocalData:Get() or {}
            n = tonumber(d.Coins) or 0
        end
    end)
    return n
end
local function getGemsCount()
    local n = 0
    pcall(function()
        if LocalData:IsReady() then
            local d = LocalData:Get() or {}
            n = tonumber(d.Gems) or 0
            if n <= 0 and type(d.Currencies) == "table" then n = tonumber(d.Currencies.Gems) or 0 end
        end
    end)
    return n
end
local COIN_OVERFLOW_THRESHOLD = 4999000000000
local function hatchEggForSeconds(egg, seconds)
    local deadline = tick() + (seconds or 5)
    pcall(function() teleportToEggByName(egg) end)
    local lastTp = tick()
    while tick() < deadline do
        if tick() - lastTp >= 2 then
            pcall(function() teleportToEggByName(egg) end)
            lastTp = tick()
        end
        pcall(function() remote:FireServer("HatchEgg", egg, getMaxHatchAmount()) end)
        VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        VIM:SendKeyEvent(true, Enum.KeyCode.R, false, game)
        VIM:SendKeyEvent(false, Enum.KeyCode.R, false, game)
        task.wait(0.05)
    end
end
local function burnGemsViaShop(targetReduction, maxSeconds)
    local items = buildGemShopCache()
    if #items == 0 then return 0 end
    local start = getGemsCount()
    local stopAt = math.max(0, start - math.max(0, targetReduction or 0))
    local deadline = tick() + (maxSeconds or 30)
    while tick() < deadline do
        local cur = getGemsCount()
        if cur <= stopAt then break end
        local firedAny = false
        for i = #items, 1, -1 do
            local row = items[i]
            if cur >= row.amount then
                pcall(function() remote:FireServer("BuyShopItem", row.shop, row.slot, false) end)
                firedAny = true
                task.wait(0.08)
                cur = getGemsCount()
                if cur <= stopAt then break end
            end
        end
        if not firedAny then break end
        task.wait(0.05)
    end
    return start - getGemsCount()
end

local COIN_COLLECT_CF = CFrame.new(11, 15973, 45)
local GEM_COLLECT_CF = CFrame.new(2286, 3158, 850)
local function teleportToCollectSpot(currencyKey)
    return setHRPCFrame(currencyKey == "gems" and GEM_COLLECT_CF or COIN_COLLECT_CF)
end
local function spamGiantChest(seconds)
    local deadline = tick() + (seconds or 5)
    while tick() < deadline do
        pcall(function()
            remote:FireServer("ClaimChest", "Giant Chest", true)
            remote:FireServer("ClaimChest", "Giant Chest")
        end)
        task.wait(0.05)
    end
end
-- Pickup-range hook: forces StatsUtil:GetPickupRange to return >= 200 studs so the game's own
-- pickup system vacuums currency at the collect spot. Without this, parking + Golden Orb does
-- nothing because the range stays at the tiny default. Golden Orb just nudges the game to
-- re-read this after the hook installs.
local BGSI_LITE_PICKUP_RANGE_TARGET = 200
local _statsUtilForPickup
local function installPickupRangeHook()
    if not _statsUtilForPickup then
        pcall(function() _statsUtilForPickup = require(ReplicatedStorage.Shared.Utils.Stats.StatsUtil) end)
    end
    local StatsUtil = _statsUtilForPickup
    if type(StatsUtil) ~= "table" or type(StatsUtil.GetPickupRange) ~= "function" then return false end
    if rawget(StatsUtil, "_BGSI_LITE_GetPickupRangeOrig") == nil then
        StatsUtil._BGSI_LITE_GetPickupRangeOrig = StatsUtil.GetPickupRange
    end
    StatsUtil.GetPickupRange = function(self, playerData)
        local orig = StatsUtil._BGSI_LITE_GetPickupRangeOrig
        local base = orig(self, playerData)
        if type(base) ~= "number" or base ~= base then return base end
        local questPickupActive = _G.BGSI_Lite_GemGenieActive
            or _G.BGSI_Lite_SeasonActive
            or _G.BGSI_Lite_GlobalIncentiveActive
        if Config.autoCollectCoins == true or questPickupActive then
            return math.max(base, BGSI_LITE_PICKUP_RANGE_TARGET)
        end
        return base
    end
    return true
end
task.defer(function()
    for _ = 1, 40 do
        if installPickupRangeHook() then return end
        task.wait(0.5)
    end
    warn("[1rzHub Lite] Pickup range hook failed — StatsUtil not found.")
end)
-- Re-apply periodically in case the game replaces the function (StatsUtil sometimes gets re-required).
task.spawn(function()
    while task.wait(2) do pcall(installPickupRangeHook) end
end)

-- Fires Golden Orb (vacuum pickup) repeatedly to sweep up currency dropped at the collect spot.
local function spamGoldenOrb(times, gap)
    times = times or 4
    gap = gap or 0.4
    for _ = 1, times do
        pcall(function() remote:FireServer("UseGoldenOrb") end)
        task.wait(gap)
    end
end
local function runCoinCollectAssist(currencyKey, requiredAmount)
    teleportToCollectSpot(currencyKey)
    task.wait(0.15)
    if currencyKey == "gems" then
        local gemsNow = getGemsCount()
        local need = math.max(100000, tonumber(requiredAmount) or 0)
        if gemsNow > need then
            burnGemsViaShop(need, 60)
            teleportToCollectSpot(currencyKey)
            task.wait(0.15)
        end
    else
        local coins = getCoinsCount()
        if coins >= COIN_OVERFLOW_THRESHOLD then
            hatchEggForSeconds("Rainbow Egg", 4)
            teleportToCollectSpot(currencyKey)
            task.wait(0.15)
        end
    end
    -- Sweep currency with Golden Orbs while spamming chest claims (5s combined window).
    task.spawn(spamGoldenOrb, 4, 1)
    spamGiantChest(5)
end

-- Shared hatch task loop (gem genie / season / global incentive hatch tasks).
local function runHatchTaskLoop(getQuest, tIndex, requiredInit, shouldContinue)
    local lastTp = 0
    while shouldContinue() do
        local q = getQuest()
        if not q then break end
        local row = q.Tasks and q.Tasks[tIndex]
        local req = requiredInit
        if row then req = getTaskRequirement(row) end
        local prog = getTaskProgress(q, tIndex)
        if type(req) == "number" and prog >= req then break end
        if q.Completed then break end
        if type(row) == "table" and row.Completed then break end
        local egg = resolveHatchEgg(row or {})
        if tick() - lastTp >= 1 then
            pcall(function() teleportToEggByName(egg) end)
            lastTp = tick()
        end
        pcall(function() remote:FireServer("HatchEgg", egg, getMaxHatchAmount()) end)
        VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        VIM:SendKeyEvent(true, Enum.KeyCode.R, false, game)
        VIM:SendKeyEvent(false, Enum.KeyCode.R, false, game)
        task.wait(0)
    end
end
local function runBubbleTaskLoop(getQuest, tIndex, requiredInit, shouldContinue)
    setHRPCFrame(CFrame.new(78, 9, -110))
    task.wait(0.4)
    local lastTp = tick()
    while shouldContinue() do
        local q = getQuest()
        if not q then break end
        local row = q.Tasks and q.Tasks[tIndex]
        local req = requiredInit
        if row then req = getTaskRequirement(row) end
        local prog = getTaskProgress(q, tIndex)
        if type(req) == "number" and prog >= req then break end
        if tick() - lastTp >= 2 then
            setHRPCFrame(CFrame.new(78, 9, -110))
            lastTp = tick()
        end
        pcall(function() remote:FireServer("BlowBubble") end)
        task.wait(0.08)
    end
end
local function runCollectTaskLoop(getQuest, tIndex, requiredInit, shouldContinue, currencyKey)
    -- Park at the collect spot once, then keep sweeping with Golden Orbs + Giant Chest.
    teleportToCollectSpot(currencyKey)
    task.wait(0.2)
    local lastChest = 0
    local lastTp = tick()
    while shouldContinue() do
        local q = getQuest()
        if not q then break end
        local row = q.Tasks and q.Tasks[tIndex]
        local req = requiredInit
        if row then req = getTaskRequirement(row) end
        local prog = getTaskProgress(q, tIndex)
        if type(req) == "number" and prog >= req then break end
        local remaining = math.max(0, (req or 0) - prog)
        -- Re-park every 8s in case anything bumped us off.
        if tick() - lastTp >= 8 then
            teleportToCollectSpot(currencyKey)
            lastTp = tick()
        end
        -- Drain currency if at cap (won't tick collect progress otherwise).
        if currencyKey == "gems" then
            local g = getGemsCount()
            if g > math.max(100000, remaining) then
                burnGemsViaShop(remaining, 30)
                teleportToCollectSpot(currencyKey)
            end
        else
            if getCoinsCount() >= COIN_OVERFLOW_THRESHOLD then
                hatchEggForSeconds("Rainbow Egg", 4)
                teleportToCollectSpot(currencyKey)
            end
        end
        -- Pickup sweep: Golden Orb + Giant Chest spam in parallel.
        pcall(function() remote:FireServer("UseGoldenOrb") end)
        if tick() - lastChest >= 0.4 then
            pcall(function()
                remote:FireServer("ClaimChest", "Giant Chest", true)
                remote:FireServer("ClaimChest", "Giant Chest")
            end)
            lastChest = tick()
        end
        task.wait(1.2)
    end
end

-- Quest source flags (used to pause Auto Hatch / Auto Bounty)
_G.BGSI_Lite_GemGenieActive = false
_G.BGSI_Lite_SeasonActive = false
_G.BGSI_Lite_GlobalIncentiveActive = false
_G.BGSI_Lite_RiftEggActive = false
local function anyQuestSystemActive()
    return _G.BGSI_Lite_GemGenieActive
        or _G.BGSI_Lite_SeasonActive
        or _G.BGSI_Lite_GlobalIncentiveActive
end

-- Pause/restore helper (only touches Auto Hatch + Auto Bounty - the only hatch toggles in lite).
local prevAutoHatch, prevAutoBounty = false, false
local hatchPaused = false
local function pauseHatchesForQuest()
    if hatchPaused then return end
    hatchPaused = true
    prevAutoHatch = Config.autoHatch
    prevAutoBounty = Config.autoBounty
    Config.autoHatch = false
    Config.autoBounty = false
end
local function restoreHatchesAfterQuest()
    if not hatchPaused then return end
    hatchPaused = false
    Config.autoHatch = prevAutoHatch or Config.autoHatch
    Config.autoBounty = prevAutoBounty or Config.autoBounty
    prevAutoHatch, prevAutoBounty = false, false
end

-- ============================================================
-- Window
-- ============================================================
local Window = Fluent:CreateWindow({
    Title = "1rzHub Lite - BGSI",
    SubTitle = "free",
    TabWidth = 100,
    Size = UDim2.fromOffset(500, 300),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl,
})

-- ============================================================
-- Mobile UI floater (same image button as main 1rzHub).
-- ============================================================
do
    local MOBILE_UI_IMAGE_URL = "https://i.postimg.cc/yNJ4Y6z8/Geoff.png"
    local MOBILE_UI_CACHE_PNG = "1rzHubMobileUI.png"
    local MOBILE_UI_FALLBACK_ASSET = "rbxassetid://7229442422"
    local function isImageBytes(body)
        if type(body) ~= "string" or #body < 24 then return false end
        if string.sub(body, 1, 8) == "\137PNG\r\n\26\n" then return true end
        if string.sub(body, 1, 2) == "\255\216" then return true end
        return false
    end
    local function fetchImageBytes(url)
        local req = request or http_request or (syn and syn.request) or (http and http.request)
        if req then
            local ok, res = pcall(function()
                return req({
                    Url = url,
                    Method = "GET",
                    Headers = {
                        ["User-Agent"] = "Mozilla/5.0",
                        ["Accept"] = "image/*",
                    },
                })
            end)
            if ok and type(res) == "table" then
                local body = res.Body or res.body
                if type(body) == "string" and isImageBytes(body) then return body end
            end
        end
        local ok, body = pcall(function() return game:HttpGet(url) end)
        if ok and isImageBytes(body) then return body end
        return nil
    end
    local function getCustomAssetFn()
        local g = getcustomasset or getsynasset
        if type(g) == "function" then return g end
        if type(syn) == "table" then
            if type(syn.getcustomasset) == "function" then return syn.getcustomasset end
            if type(syn.getsynasset) == "function" then return syn.getsynasset end
        end
        return nil
    end
    local function resolveMobileUIImage()
        local canFS = writefile and isfile and readfile
        local getAsset = getCustomAssetFn()
        if not canFS then return MOBILE_UI_IMAGE_URL end
        if not isfile(MOBILE_UI_CACHE_PNG) then
            local bytes = fetchImageBytes(MOBILE_UI_IMAGE_URL)
            if bytes then pcall(writefile, MOBILE_UI_CACHE_PNG, bytes) end
        end
        if getAsset and isfile(MOBILE_UI_CACHE_PNG) then
            local ok, rid = pcall(getAsset, MOBILE_UI_CACHE_PNG)
            if ok and type(rid) == "string" and rid ~= "" then return rid end
        end
        return MOBILE_UI_FALLBACK_ASSET
    end

    -- Don't double-spawn if main already placed its own button.
    if not getgenv().LoadedMobileUI then
        getgenv().LoadedMobileUI = true
        local imageUrl = resolveMobileUIImage()
        local OpenUI = Instance.new("ScreenGui")
        OpenUI.Name = "OpenUI"
        OpenUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        OpenUI.Parent = CoreGui
        local ImageButton = Instance.new("ImageButton")
        ImageButton.Parent = OpenUI
        ImageButton.BackgroundColor3 = Color3.fromRGB(105, 105, 105)
        ImageButton.BackgroundTransparency = 0.8
        ImageButton.Position = UDim2.new(0.9, 0, 0.1, 0)
        ImageButton.Size = UDim2.new(0, 50, 0, 50)
        ImageButton.Image = imageUrl
        ImageButton.ImageTransparency = 0
        ImageButton.Draggable = true
        ImageButton.MouseButton1Click:Connect(function()
            -- Prefer main's toggle if both scripts are loaded; otherwise fall back to our Window.
            local toggle = getgenv()._1rzHubToggleFluent
            if type(toggle) == "function" then
                local ok = pcall(toggle)
                if ok then return end
            end
            pcall(function() Window:Minimize() end)
        end)
    end
    -- Always (re)bind the global toggle so the existing button — main's or ours — works for this Window.
    getgenv()._1rzHubToggleFluent = function() Window:Minimize() end
end

local MainTab = Window:AddTab({ Title = "Main", Icon = "home" })
local EggTab = Window:AddTab({ Title = "Eggs", Icon = "egg" })
local EventTab = Window:AddTab({ Title = "Event", Icon = "flower" })
local ChestTab = Window:AddTab({ Title = "Chests", Icon = "package" })
local GameTab = Window:AddTab({ Title = "Game", Icon = "gamepad" })
local TeamsTab = Window:AddTab({ Title = "Teams", Icon = "users" })
local MinigamesTab = Window:AddTab({ Title = "Minigames", Icon = "joystick" })
local EnchantTab = Window:AddTab({ Title = "Enchant", Icon = "wand-sparkles" })
local QuestsTab = Window:AddTab({ Title = "Quests", Icon = "scroll" })
local ShrineTab = Window:AddTab({ Title = "Shrines", Icon = "sparkles" })
local RebirthTab = Window:AddTab({ Title = "Rebirth", Icon = "repeat" })
local OtherTab = Window:AddTab({ Title = "Other", Icon = "workflow" })


MainTab:AddParagraph({
    Title = "1rzHub Lite",
    Content = "this is 1rzhub but lite (for the people who like em younger)"
})

Window:SelectTab(1)
Fluent:Notify({ Title = "1rzHub Lite", Content = "Loading...", Duration = 3 })

-- ============================================================
-- Debug HUD extras (selected egg, hatch stats, quest counters).
-- ============================================================
do
    local function liteDebugRoot()
        local pg = player and player:FindFirstChild("PlayerGui")
        local screenGui = pg and pg:FindFirstChild("ScreenGui")
        return screenGui and screenGui:FindFirstChild("_debug") or nil
    end

    local function liteDebugTags()
        local root = liteDebugRoot()
        return root and root:FindFirstChild("Tags") or nil
    end

    local function liteCloneDebugTag(tags, tagName, layoutOrder)
        local existing = tags:FindFirstChild(tagName)
        if existing then return existing:FindFirstChild("Label") end

        local template
        for _, child in ipairs(tags:GetChildren()) do
            if child:IsA("Frame") and child:FindFirstChild("Label") and not string.find(child.Name, "^BGSI_") then
                template = child
                break
            end
        end

        if template then
            local frame = template:Clone()
            frame.Name = tagName
            frame.LayoutOrder = layoutOrder
            frame.Parent = tags
            local label = frame:FindFirstChild("Label")
            if label and label:IsA("TextLabel") then
                label.Text = ""
                label.RichText = true
                return label
            end
        end

        local frame = Instance.new("Frame")
        frame.Name = tagName
        frame.BackgroundTransparency = 1
        frame.LayoutOrder = layoutOrder
        frame.Size = UDim2.fromOffset(220, 20)
        frame.Parent = tags

        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.GothamBold
        label.RichText = true
        label.Size = UDim2.fromScale(1, 1)
        label.Text = ""
        label.TextColor3 = Color3.new(1, 1, 1)
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextYAlignment = Enum.TextYAlignment.Center
        label.Parent = frame

        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.new(0, 0, 0)
        stroke.Thickness = 1
        stroke.Parent = label

        return label
    end

    local function liteFmtCommas(n)
        n = tonumber(n)
        if not n then return "-" end
        local s = tostring(math.floor(n))
        while true do
            local nextS, count = s:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
            s = nextS
            if count == 0 then break end
        end
        return s
    end

    local function liteFmtOneIn(unitChance)
        unitChance = tonumber(unitChance)
        if not unitChance or unitChance <= 0 then return "-" end
        local oneIn = 1 / unitChance
        local rounded = math.floor(oneIn + 0.5)
        if math.abs(oneIn - rounded) < 0.000001 then return liteFmtCommas(rounded) end
        return string.format("%.2f", oneIn)
    end

    local function liteResizeTag(label)
        if not label or not label.Parent then return end
        local frame = label.Parent
        local pg = player and player:FindFirstChild("PlayerGui")
        local screenGui = pg and pg:FindFirstChild("ScreenGui")
        local uiScale = screenGui and screenGui:FindFirstChild("UIScale")
        local scale = (uiScale and uiScale.Scale) or 1
        local width = math.max(130, math.floor((label.TextBounds.X / math.max(scale, 0.001)) + 20))
        local height = frame.Size.Y.Offset > 0 and frame.Size.Y.Offset or 20
        frame.Size = UDim2.fromOffset(width, height)
    end

    local function liteAddClickOverlay(label, name, callback)
        local frame = label and label.Parent
        if not frame or frame:FindFirstChild(name) then return end
        local button = Instance.new("TextButton")
        button.Name = name
        button.AutoButtonColor = false
        button.BackgroundTransparency = 1
        button.Position = UDim2.fromOffset(0, 0)
        button.Size = UDim2.fromScale(1, 1)
        button.Text = ""
        button.ZIndex = (label.ZIndex or 1) + 1
        button.Parent = frame
        button.MouseButton1Click:Connect(callback)
    end

    local function liteGetData()
        local data
        pcall(function()
            if LocalData and LocalData.IsReady and LocalData:IsReady() then
                data = LocalData:Get()
            end
        end)
        return type(data) == "table" and data or {}
    end

    local function liteFindNumeric(root, keys, depth)
        if type(root) ~= "table" or type(keys) ~= "table" then return nil end
        depth = tonumber(depth) or 0
        local wants = {}
        for _, key in ipairs(keys) do wants[string.lower(tostring(key))] = true end
        for k, v in pairs(root) do
            if type(k) == "string" and wants[string.lower(k)] then
                if type(v) == "number" then return v end
                if type(v) == "string" and tonumber(v) then return tonumber(v) end
            end
        end
        if depth <= 0 then return nil end
        for _, v in pairs(root) do
            if type(v) == "table" then
                local found = liteFindNumeric(v, keys, depth - 1)
                if type(found) == "number" then return found end
            end
        end
        return nil
    end

    local function liteAdditiveBuff(data, keys)
        local n = liteFindNumeric(data, keys, 6)
        return type(n) == "number" and n or 0
    end

    local XL_CHANCES_BY_RARITY_PERCENT = {
        Common = 0.0002,
        Unique = 0.00028571428571428574,
        Rare = 0.0013333333333333333,
        Epic = 0.004,
        Legendary = 0.05,
        Secret = 0.2,
    }
    local XL_CHANCE_ROWS = { "Legendary", "Epic", "Rare", "Unique", "Common" }
    local SUPER_LEGENDARY_BASE_PERCENT = 0.04
    local DISCOVERED_PREFIXES = {
        "",
        "Shiny ",
        "Mythic ",
        "Shiny Mythic ",
        "Mythic Shiny ",
        "XL ",
        "XL Shiny ",
        "XL Mythic ",
        "XL Shiny Mythic ",
        "XL Mythic Shiny ",
    }
    local RARITY_RANK = {
        Common = 1,
        Unique = 2,
        Rare = 3,
        Epic = 4,
        Legendary = 5,
        Mythic = 6,
        Secret = 7,
        Infinity = 8,
    }

    local function liteXLUnitChance(rarity, data)
        local basePercent = XL_CHANCES_BY_RARITY_PERCENT[rarity]
        if type(basePercent) ~= "number" then return nil, 0 end
        local add = liteAdditiveBuff(data, { "XLChance", "xl_chance", "xlpetchance", "xleggchance" })
        return (basePercent / 100) * math.max(0, 1 + add), add
    end

    local function liteSuperLegendaryUnitChance(data)
        local add = liteAdditiveBuff(data, { "SuperChance", "SuperLegendaryChance", "super_legendary_chance" })
        return (SUPER_LEGENDARY_BASE_PERCENT / 100) * math.max(0, 1 + add), add
    end

    local function liteDiscoveredPetCount(discovered, petName)
        if type(discovered) ~= "table" or type(petName) ~= "string" then return 0 end
        local total = 0
        for _, prefix in ipairs(DISCOVERED_PREFIXES) do
            local v = discovered[prefix .. petName]
            if type(v) == "number" then
                total = total + math.max(0, math.floor(v))
            elseif v == true then
                total = total + 1
            end
        end
        return total
    end

    local function liteEggPetRows(eggName)
        local rows = {}
        if type(eggName) ~= "string" or eggName == "" or type(PetsData) ~= "table" then return rows end
        for petName, petData in pairs(PetsData) do
            if type(petName) == "string" and type(petData) == "table" and petData.Egg == eggName then
                table.insert(rows, {
                    name = petName,
                    chance = tonumber(petData.Chance) or 0,
                    rank = RARITY_RANK[petData.Rarity] or 50,
                })
            end
        end
        table.sort(rows, function(a, b)
            if a.chance ~= b.chance then return a.chance > b.chance end
            if a.rank ~= b.rank then return a.rank < b.rank end
            return a.name < b.name
        end)
        return rows
    end

    task.spawn(function()
        local tags
        for _ = 1, 60 do
            tags = liteDebugTags()
            if tags then break end
            task.wait(1)
        end
        if not tags then return end

        local baseOrder = 1000
        local petRowMax = 64
        local xlRowMax = #XL_CHANCE_ROWS
        local tagToggle = liteCloneDebugTag(tags, "BGSI_Lite_ShowOthers", -10000)
        local tagSelected = liteCloneDebugTag(tags, "BGSI_Lite_SelectedEggHatched", baseOrder + 1)
        local petRows = {}
        for i = 1, petRowMax do
            petRows[i] = liteCloneDebugTag(tags, "BGSI_Lite_EggPetRow_" .. i, baseOrder + 1 + i)
            if petRows[i] then petRows[i].TextSize = math.max(7, math.floor((petRows[i].TextSize or 14) * 0.72)) end
        end

        local nextOrder = baseOrder + petRowMax + 2
        local tagSecrets = liteCloneDebugTag(tags, "BGSI_Lite_SecretsHatched", nextOrder); nextOrder = nextOrder + 1
        local tagGemGenie = liteCloneDebugTag(tags, "BGSI_Lite_GemGenieQuests", nextOrder); nextOrder = nextOrder + 1
        local tagRebirthFuses = liteCloneDebugTag(tags, "BGSI_Lite_RebirthFuses", nextOrder); nextOrder = nextOrder + 1
        local tagSeasonPass = liteCloneDebugTag(tags, "BGSI_Lite_SeasonPassQuests", nextOrder); nextOrder = nextOrder + 1
        local tagOldSailor = liteCloneDebugTag(tags, "BGSI_Lite_OldSailorQuests", nextOrder); nextOrder = nextOrder + 1
        local tagXLChance = liteCloneDebugTag(tags, "BGSI_Lite_XLChance", 8)
        local xlRows = {}
        for i = 1, xlRowMax do
            xlRows[i] = liteCloneDebugTag(tags, "BGSI_Lite_XLChanceRow_" .. i, 8 + i)
            if xlRows[i] then xlRows[i].TextSize = math.max(7, math.floor((xlRows[i].TextSize or 14) * 0.72)) end
        end
        local tagSuperLegendary = liteCloneDebugTag(tags, "BGSI_Lite_SuperLegendaryChance", 8 + xlRowMax + 1)

        local extraLabels = {
            tagSelected,
            tagSecrets,
            tagGemGenie,
            tagRebirthFuses,
            tagSeasonPass,
            tagOldSailor,
            tagXLChance,
            tagSuperLegendary,
        }
        local othersVisible = false
        local petRowsVisible = false
        local xlRowsVisible = false
        local petActiveCount = 0
        local xlActiveCount = 0

        local function setLabel(label, text)
            if not label then return end
            label.RichText = true
            label.Text = text
            liteResizeTag(label)
            task.defer(function() liteResizeTag(label) end)
        end

        local function applyVisibility()
            for _, label in ipairs(extraLabels) do
                if label and label.Parent then label.Parent.Visible = othersVisible end
            end
            for i, label in ipairs(petRows) do
                if label and label.Parent then
                    label.Parent.Visible = othersVisible and petRowsVisible and i <= petActiveCount
                end
            end
            for i, label in ipairs(xlRows) do
                if label and label.Parent then
                    label.Parent.Visible = othersVisible and xlRowsVisible and i <= xlActiveCount
                end
            end
        end

        local function updateToggleText()
            setLabel(tagToggle, othersVisible
                and '<stroke color="#000000" joins="round" thickness="2">Hide Others</stroke>'
                or '<stroke color="#000000" joins="round" thickness="2">Show Others</stroke>')
        end

        liteAddClickOverlay(tagToggle, "BGSI_Lite_ShowOthersClick", function()
            othersVisible = not othersVisible
            applyVisibility()
            updateToggleText()
        end)
        liteAddClickOverlay(tagSelected, "BGSI_Lite_SelectedEggClick", function()
            petRowsVisible = not petRowsVisible
            applyVisibility()
        end)
        liteAddClickOverlay(tagXLChance, "BGSI_Lite_XLChanceClick", function()
            xlRowsVisible = not xlRowsVisible
            applyVisibility()
        end)

        updateToggleText()
        applyVisibility()

        while true do
            task.wait(1)
            local data = liteGetData()
            local selectedEgg = tostring(Config.selectedEgg or "")
            local eggsOpened = type(data.EggsOpened) == "table" and data.EggsOpened or {}
            local questsCompleted = type(data.QuestsCompleted) == "table" and data.QuestsCompleted or {}

            local eggBase = selectedEgg ~= "" and selectedEgg:gsub("%s*Egg$", "") or "Selected Egg"
            local eggCount = selectedEgg ~= "" and tonumber(eggsOpened[selectedEgg]) or nil
            setLabel(tagSelected, string.format(
                '<stroke color="#000000" joins="round" thickness="2">%s Eggs Hatched <b><font color="#ffe942">%s</font></b> <font color="#888888">%s</font></stroke>',
                eggBase,
                liteFmtCommas(eggCount or 0),
                petRowsVisible and "v" or ">"
            ))

            local rows = liteEggPetRows(selectedEgg)
            local discovered = type(data.Discovered) == "table" and data.Discovered or {}
            petActiveCount = math.min(#rows, petRowMax)
            if selectedEgg == "" then
                petActiveCount = 1
                setLabel(petRows[1], '<stroke color="#000000" joins="round" thickness="1.5">  Select an egg to list pets.</stroke>')
            elseif #rows == 0 then
                petActiveCount = 1
                setLabel(petRows[1], '<stroke color="#000000" joins="round" thickness="1.5">  No PetsData rows for this egg.</stroke>')
            else
                for i = 1, petActiveCount do
                    setLabel(petRows[i], string.format(
                        '<stroke color="#000000" joins="round" thickness="1.5">  %s <b><font color="#cfe9ff">%s</font></b></stroke>',
                        rows[i].name,
                        liteFmtCommas(liteDiscoveredPetCount(discovered, rows[i].name))
                    ))
                end
            end
            for i = petActiveCount + 1, petRowMax do
                if petRows[i] then petRows[i].Text = "" end
            end

            setLabel(tagSecrets, string.format(
                '<stroke color="#000000" joins="round" thickness="2">Secrets Hatched <b><font color="#ff6bff">%s</font></b></stroke>',
                liteFmtCommas(data.SecretsHatched)
            ))
            setLabel(tagGemGenie, string.format(
                '<stroke color="#000000" joins="round" thickness="2">Gem Genie Quests <b><font color="#40e0ff">%s</font></b></stroke>',
                liteFmtCommas(data.GemGenieCompletions)
            ))
            setLabel(tagRebirthFuses, string.format(
                '<stroke color="#000000" joins="round" thickness="2">Rebirth Machine Fuses <b><font color="#7cff4f">%s</font></b></stroke>',
                liteFmtCommas(data.RebirthMachineFuses)
            ))

            local seasonTotal = 0
            for questId, count in pairs(questsCompleted) do
                if type(questId) == "string" and type(count) == "number" then
                    if questId:match("^daily%-challenge%-") or questId:match("^hourly%-challenge%-") then
                        seasonTotal = seasonTotal + count
                    end
                end
            end
            setLabel(tagSeasonPass, string.format(
                '<stroke color="#000000" joins="round" thickness="2">Season Pass Quests <b><font color="#ffa500">%s</font></b></stroke>',
                liteFmtCommas(seasonTotal)
            ))
            setLabel(tagOldSailor, string.format(
                '<stroke color="#000000" joins="round" thickness="2">Old Sailor Quests <b><font color="#4fd1c5">%s</font></b></stroke>',
                liteFmtCommas(questsCompleted["sailor-bounty"])
            ))

            local secretXL, xlAdd = liteXLUnitChance("Secret", data)
            local addText = (type(xlAdd) == "number" and xlAdd ~= 0) and (" +" .. tostring(math.floor(xlAdd * 100 + 0.5)) .. "%") or ""
            setLabel(tagXLChance, string.format(
                '<stroke color="#000000" joins="round" thickness="2">XL Chance (Secret%s) <b><font color="#b6f7ff">1/%s</font></b> <font color="#888888">%s</font></stroke>',
                addText,
                liteFmtOneIn(secretXL),
                xlRowsVisible and "v" or ">"
            ))
            xlActiveCount = 0
            for i, rarity in ipairs(XL_CHANCE_ROWS) do
                local chance = liteXLUnitChance(rarity, data)
                if type(chance) == "number" then
                    xlActiveCount = i
                    setLabel(xlRows[i], string.format(
                        '<stroke color="#000000" joins="round" thickness="1.5">  %s <b><font color="#cfe9ff">1/%s</font></b></stroke>',
                        rarity,
                        liteFmtOneIn(chance)
                    ))
                end
            end

            local superChance, superAdd = liteSuperLegendaryUnitChance(data)
            local superText = (type(superAdd) == "number" and superAdd ~= 0) and (" +" .. tostring(math.floor(superAdd * 100 + 0.5)) .. "%") or ""
            setLabel(tagSuperLegendary, string.format(
                '<stroke color="#000000" joins="round" thickness="2">Super Legendary Chance%s <b><font color="#ffd166">1/%s</font></b></stroke>',
                superText,
                liteFmtOneIn(superChance)
            ))

            applyVisibility()
        end
    end)
end

-- ============================================================
-- Eggs tab
-- ============================================================
do
    -- Lazy egg dropdown: show saved egg (or hint) until user clicks Load.
    local EGG_LOAD_HINT = "(Click 'Load egg list' below)"
    local EGG_LOCATION_HINT = "(Select an egg first)"
    local EGG_LOCATION_NONE = "(No tracked locations)"
    local initValues, initDefault
    if type(Config.selectedEgg) == "string" and Config.selectedEgg ~= "" then
        initValues = { Config.selectedEgg }
        initDefault = Config.selectedEgg
    else
        initValues = { EGG_LOAD_HINT }
        initDefault = EGG_LOAD_HINT
    end

    local eggDropdown, locationDropdown
    local locationLabelToKey = {}

    local function locationLabel(row)
        local pos = row and row.position
        local x = pos and pos.X or 0
        local y = pos and pos.Y or 0
        local z = pos and pos.Z or 0
        return string.format("X %.1f, Y %.1f, Z %.1f", x, y, z)
    end

    local function refreshLocationDropdown(force)
        if not locationDropdown then return end

        locationLabelToKey = {}
        local egg = Config.selectedEgg
        local values, defaultValue = {}, EGG_LOCATION_HINT
        if type(egg) ~= "string" or egg == "" or egg == EGG_LOAD_HINT then
            values = { EGG_LOCATION_HINT }
        else
            local rows = getTrackedRowsForEgg(egg, force == true)
            if #rows == 0 then
                values = { EGG_LOCATION_NONE }
                defaultValue = EGG_LOCATION_NONE
            else
                local priorities = type(Config.selectedEggLocationPriorities) == "table" and Config.selectedEggLocationPriorities or {}
                local selectedKey = priorities[egg]
                for i, row in ipairs(rows) do
                    local label = locationLabel(row, i)
                    locationLabelToKey[label] = row.key
                    table.insert(values, label)
                    if row.key == selectedKey then
                        defaultValue = label
                    end
                end
                if defaultValue == EGG_LOCATION_HINT then
                    defaultValue = values[1]
                end
            end
        end

        if locationDropdown.SetValues then locationDropdown:SetValues(values) end
        if locationDropdown.SetValue then pcall(function() locationDropdown:SetValue(defaultValue) end) end
    end

    local function refreshEggDropdown(force)
        local list = buildEggPickerList(force == true)
        if #list == 0 then
            Fluent:Notify({ Title = "Eggs", Content = "No tracked eggs found yet.", Duration = 4 })
            refreshLocationDropdown(force)
            return
        end

        if eggDropdown.SetValues then eggDropdown:SetValues(list) end
        if type(Config.selectedEgg) ~= "string" or Config.selectedEgg == "" or not table.find(list, Config.selectedEgg) then
            Config.selectedEgg = list[1]
            saveConfig()
        end
        if eggDropdown.SetValue then pcall(function() eggDropdown:SetValue(Config.selectedEgg) end) end
        refreshLocationDropdown(force)
    end

    eggDropdown = EggTab:AddDropdown("SelectEgg", {
        Title = "Select Egg",
        Values = initValues,
        Default = initDefault,
        Multi = false,
        Search = true,
        Callback = function(v)
            if v and v ~= EGG_LOAD_HINT then
                Config.selectedEgg = v
                saveConfig()
                refreshLocationDropdown(true)
            end
        end,
    })

    locationDropdown = EggTab:AddDropdown("SelectEggLocation", {
        Title = "Prioritised Location",
        Values = { EGG_LOCATION_HINT },
        Default = EGG_LOCATION_HINT,
        Multi = false,
        Search = true,
        Callback = function(v)
            local key = locationLabelToKey[v]
            local egg = Config.selectedEgg
            if not key or type(egg) ~= "string" or egg == "" then return end

            Config.selectedEggLocationPriorities = type(Config.selectedEggLocationPriorities) == "table" and Config.selectedEggLocationPriorities or {}
            Config.selectedEggLocationPriorities[egg] = key
            saveConfig()
        end,
    })

    EggTab:AddButton({
        Title = "Load egg list",
        Callback = function()
            refreshEggDropdown(true)
        end,
    })

    

    EggTab:AddSection("Hatch")

    EggTab:AddToggle("AutoHatch", {
        Title = "Auto Hatch",
        Default = Config.autoHatch,
        Callback = function(v) Config.autoHatch = v; saveConfig() end,
    })

    EggTab:AddToggle("NoHatchAnim", {
        Title = "No Hatch Animation",
        Default = Config.noHatchAnim,
        Callback = function(v)
            Config.noHatchAnim = v
            saveConfig()
            if not HatchModule then return end
            if v then
                HatchModule.Play = function(self, result)
                    if result and result.Pets then
                        local gui = player:WaitForChild("PlayerGui"):WaitForChild("ScreenGui")
                        if gui:FindFirstChild("Hatching") then gui.Hatching.Visible = false end
                        if gui:FindFirstChild("HUD") then gui.HUD.Visible = true end
                        self._hatching = false
                    end
                end
            else
                HatchModule.Play = originalPlay
            end
        end,
    })

    EggTab:AddToggle("AutoSpamE", {
        Title = "Auto Spam E",
        Default = Config.autoSpamE,
        Callback = function(v) Config.autoSpamE = v; saveConfig() end,
    })

    EggTab:AddSection("Bounty")
    EggTab:AddToggle("AutoBounty", {
        Title = "Auto Hatch Bounty Egg",
        Default = Config.autoBounty,
        Callback = function(v) Config.autoBounty = v; saveConfig() end,
    })
    EggTab:AddToggle("SpawnRift", {
        Title = "Spawn Rift for Bounty (every hour)",
        Default = Config.spawnRift,
        Callback = function(v) Config.spawnRift = v; saveConfig() end,
    })

    EggTab:AddSection("Admin Abuse")
    EggTab:AddToggle("AutoLuckEgg", {
        Title = "Auto Hatch 4x Egg (AA)",
        Default = Config.autoLuckEgg,
        Callback = function(v) Config.autoLuckEgg = v; saveConfig() end,
    })
end

-- AA egg (4x Luck 600M Egg): teleports to SummonedEgg.EggPlatformSpawn when an admin spawns one.
_G.BGSI_Lite_LuckEggActive = false
task.spawn(function()
    local lastTp = 0
    while true do
        task.wait(0)
        if Config.autoLuckEgg ~= true then
            if _G.BGSI_Lite_LuckEggActive then _G.BGSI_Lite_LuckEggActive = false end
            task.wait(BGSI_FEATURE_IDLE_WAIT or 0.85)
            continue
        end
        local summoned = workspace:FindFirstChild("SummonedEgg")
        local platform = summoned and summoned:FindFirstChild("EggPlatformSpawn")
        if not platform then
            if _G.BGSI_Lite_LuckEggActive then
                _G.BGSI_Lite_LuckEggActive = false
                lastTp = 0
            end
            task.wait(1)
            continue
        end
        _G.BGSI_Lite_LuckEggActive = true
        local char = player and player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then task.wait(0.2) continue end
        if tick() - lastTp >= 5 then
            local part = platform:IsA("BasePart") and platform or platform:FindFirstChildWhichIsA("BasePart", true)
            if part then
                pcall(function() hrp.CFrame = part.CFrame + Vector3.new(0, 3, -5) end)
                lastTp = tick()
            end
        end
        pcall(function() remote:FireServer("HatchEgg", "4x Luck 600M Egg", getMaxHatchAmount()) end)
    end
end)

-- Main Auto Hatch loop (single worker, simple, yields to quests).
-- TPs to selected egg every 10 seconds; fires HatchEgg every frame in between.
task.spawn(function()
    local lastTp = 0
    while true do
        task.wait(0)
        if Config.autoHatch ~= true then lastTp = 0; continue end
        if anyQuestSystemActive() or _G.BGSI_Lite_LuckEggActive or _G.BGSI_Lite_RiftEggActive then continue end
        local char = player and player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then continue end
        local egg = Config.selectedEgg
        if type(egg) ~= "string" or egg == "" then continue end
        if tick() - lastTp >= 10 then
            pcall(function() teleportToEggByName(egg) end)
            lastTp = tick()
        end
        fireHatch(egg)
    end
end)

-- Auto Spam E loop.
task.spawn(function()
    while true do
        task.wait(0)
        if Config.autoSpamE ~= true then continue end
        VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        VIM:SendKeyEvent(true, Enum.KeyCode.R, false, game)
        VIM:SendKeyEvent(false, Enum.KeyCode.R, false, game)
    end
end)

-- Bounty: get today's bounty egg. Tries every known shape of BountyUtil + LocalData fallback.
local function bountyEggFromQuest(q)
    if type(q) ~= "table" then return nil end
    if type(q.Egg) == "string" then return q.Egg end
    local t = q.Task
    if type(t) == "table" then
        if type(t.Egg) == "string" then return t.Egg end
        if type(t[1]) == "table" and type(t[1].Egg) == "string" then return t[1].Egg end
    end
    if type(q.Tasks) == "table" then
        for _, row in pairs(q.Tasks) do
            if type(row) == "table" then
                if type(row.Egg) == "string" then return row.Egg end
                if type(row.Item) == "table" and type(row.Item.Egg) == "string" then return row.Item.Egg end
            end
        end
    end
    if type(q.Rewards) == "table" then
        for _, r in ipairs(q.Rewards) do
            if type(r) == "table" and type(r.Egg) == "string" then return r.Egg end
        end
    end
    return nil
end
local _bountyWarnedNoUtil = false
local function getTodayBounty()
    if BountyUtil and type(BountyUtil.GetQuest) == "function" and type(BountyUtil.GetSeed) == "function" then
        for _, seedOff in ipairs({ 0, -1, 1 }) do
            local ok, q = pcall(function() return BountyUtil:GetQuest(BountyUtil:GetSeed() + seedOff) end)
            if ok then
                local egg = bountyEggFromQuest(q)
                if type(egg) == "string" and egg ~= "" then return egg end
            end
        end
    end
    -- Fallback: read from LocalData if the game tracks the current bounty quest there.
    local ok, d = pcall(function() return LocalData:IsReady() and LocalData:Get() or nil end)
    if ok and type(d) == "table" then
        for _, key in ipairs({ "Bounty", "BountyQuest", "DailyBounty" }) do
            local egg = bountyEggFromQuest(d[key])
            if type(egg) == "string" and egg ~= "" then return egg end
        end
    end
    if not BountyUtil and not _bountyWarnedNoUtil then
        _bountyWarnedNoUtil = true
        warn("[1rzHub Lite] BountyUtil module not found - Auto Bounty won't work in this game version.")
    end
    return nil
end

-- Bounty hatch loop.
task.spawn(function()
    local lastTp = 0
    while true do
        task.wait(0)
        if Config.autoBounty ~= true then continue end
        if anyQuestSystemActive() or _G.BGSI_Lite_LuckEggActive or _G.BGSI_Lite_RiftEggActive then continue end
        local egg = getTodayBounty()
        if not egg then task.wait(2) continue end
        local char = player and player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then continue end
        if tick() - lastTp >= 5 then
            pcall(function() teleportToEggByName(egg) end)
            lastTp = tick()
        end
        fireHatch(egg)
    end
end)

-- Spawn rift loop.
task.spawn(function()
    while true do
        if not Config.spawnRift then task.wait(2) continue end
        local egg = getTodayBounty()
        if egg then
            local worldName = (egg == "Mining Egg" or egg == "Neon Egg" or egg == "Cyber Egg") and "Minigame Paradise" or "The Overworld"
            pcall(function()
                remotefunction:InvokeServer("SummonRift", {
                    Type = "Egg", Name = egg, World = worldName, Time = 5, Luck = 5,
                })
            end)
        end
        task.wait(3600)
    end
end)

-- ============================================================
-- Event tab
-- ============================================================
do
    EventTab:AddSection("Present Rain")
    EventTab:AddToggle("AutoCollectPresentRain", {
        Title = "Auto Collect Present Rain",
        Default = Config.autoCollectPresentRain,
        Callback = function(v)
            Config.autoCollectPresentRain = v
            saveConfig()
        end,
    })
end

-- Present Rain collector: fires CollectPresentRain for every folder under Workspace.Markers.PresentRain.
local _presentRainFiredIds = {}
local function tryCollectPresentRain(inst)
    if not Config.autoCollectPresentRain then return end
    if not inst or typeof(inst) ~= "Instance" or not inst:IsA("Folder") then return end
    local id = inst.Name
    if type(id) ~= "string" or id == "" or _presentRainFiredIds[id] then return end
    _presentRainFiredIds[id] = true
    pcall(function() remote:FireServer("CollectPresentRain", id) end)
end
task.spawn(function()
    local markers = Workspace:WaitForChild("Markers", 600)
    if not markers then return end
    local folder = markers:WaitForChild("PresentRain", 600)
    if not folder then return end
    for _, ch in ipairs(folder:GetChildren()) do tryCollectPresentRain(ch) end
    folder.ChildAdded:Connect(function(ch)
        task.defer(function() tryCollectPresentRain(ch) end)
    end)
end)

-- ============================================================
-- Chests, rifts, potions, and small game helpers
-- ============================================================
local function liteData()
    local ok, data = pcall(function()
        return LocalData:IsReady() and LocalData:Get() or nil
    end)
    return ok and type(data) == "table" and data or nil
end

local function setDropdownValues(dropdown, values)
    if not dropdown then return end
    if dropdown.SetValues then
        dropdown:SetValues(values)
    elseif dropdown.Refresh then
        dropdown:Refresh(values, false)
    end
end

local function getRenderedChild(folderName)
    local rendered = Workspace:FindFirstChild("Rendered")
    return rendered and rendered:FindFirstChild(folderName) or nil
end

local function getModelPivot(model)
    if not model then return nil end
    local ok, cf = pcall(function() return model:GetPivot() end)
    if ok and typeof(cf) == "CFrame" then return cf end
    local part = model:IsA("BasePart") and model or model:FindFirstChildWhichIsA("BasePart", true)
    return part and part.CFrame or nil
end

do
    local function addUnique(list, seen, value)
        if type(value) == "string" and value ~= "" and not seen[value] then
            seen[value] = true
            table.insert(list, value)
        end
    end

    local function getWorldChestOptions()
        local list, seen = {}, {}
        local folder = getRenderedChild("Chests")
        if folder then
            for _, child in ipairs(folder:GetChildren()) do
                addUnique(list, seen, child.Name)
            end
        end
        for _, fallback in ipairs({ "Giant Chest", "Infinity Chest", "Ticket Chest", "Void Chest" }) do
            addUnique(list, seen, fallback)
        end
        table.sort(list)
        return list
    end

    local function getRiftChestOptions()
        local list, seen = {}, {}
        if type(RiftsData) == "table" then
            for id, cfg in pairs(RiftsData) do
                if type(cfg) == "table" and cfg.Type == "Chest" then
                    addUnique(list, seen, id)
                end
            end
        end
        local folder = getRenderedChild("Rifts")
        if folder then
            for _, child in ipairs(folder:GetChildren()) do
                local cfg = type(RiftsData) == "table" and RiftsData[child.Name] or nil
                if type(cfg) == "table" and cfg.Type == "Chest" then
                    addUnique(list, seen, child.Name)
                end
            end
        end
        for _, fallback in ipairs({ "golden-chest", "royal-chest", "super-chest", "dice-rift", "moon-chest" }) do
            addUnique(list, seen, fallback)
        end
        table.sort(list)
        return list
    end

    local function findRenderedModel(name, folders)
        if type(name) ~= "string" or name == "" then return nil end
        local target = string.lower(name)
        for _, folderName in ipairs(folders) do
            local folder = getRenderedChild(folderName)
            if folder then
                for _, child in ipairs(folder:GetChildren()) do
                    if string.lower(child.Name) == target then
                        return child
                    end
                end
            end
        end
        return nil
    end

    local function chestWorld(chestName)
        local cfg = type(RiftsData) == "table" and RiftsData[chestName] or nil
        if type(cfg) == "table" and type(cfg.World) == "string" then
            return cfg.World
        end
        return chestName == "dice-rift" and "Minigame Paradise" or "The Overworld"
    end

    local function summonChest(chestName)
        if type(chestName) ~= "string" or chestName == "" then return end
        if string.find(string.lower(chestName), "moon", 1, true) then
            pcall(function()
                remotefunction:InvokeServer("SummonMoonRift", { Type = "Chest", Time = 1 })
            end)
            return
        end
        pcall(function()
            remotefunction:InvokeServer("SummonRift", {
                Name = chestName,
                Type = "Chest",
                Time = 5,
                World = chestWorld(chestName),
            })
        end)
    end

    local function teleportToRiftChest(chestName)
        local chest = findRenderedModel(chestName, { "Rifts" })
        local cf = getModelPivot(chest)
        if cf then setHRPCFrame(cf + Vector3.new(0, 3, 0)) end
    end

    local function claimWorldChest(chestName)
        if type(chestName) ~= "string" or chestName == "" then return end
        pcall(function()
            remote:FireServer("ClaimChest", chestName, true)
            remote:FireServer("ClaimChest", chestName)
        end)
    end

    local worldChestOptions = getWorldChestOptions()
    if Config.selectedWorldChest == "Giant Chest" and table.find(worldChestOptions, Config.selectedChest) then
        Config.selectedWorldChest = Config.selectedChest
    end
    if not table.find(worldChestOptions, Config.selectedWorldChest) then
        Config.selectedWorldChest = worldChestOptions[1] or "Giant Chest"
    end

    local riftChestOptions = getRiftChestOptions()
    if not table.find(riftChestOptions, Config.selectedChest) then
        Config.selectedChest = riftChestOptions[1] or "golden-chest"
    end

    ChestTab:AddSection("Normal Chests")
    local worldChestDropdown = ChestTab:AddDropdown("SelectedWorldChest", {
        Title = "Select Chest",
        Values = worldChestOptions,
        Default = Config.selectedWorldChest,
        Multi = false,
        Search = true,
        Callback = function(v)
            Config.selectedWorldChest = v
            saveConfig()
        end,
    })
    ChestTab:AddToggle("AutoClaimWorldChest", {
        Title = "Auto Claim Chest",
        Default = Config.autoClaimWorldChest,
        Callback = function(v)
            Config.autoClaimWorldChest = v
            saveConfig()
        end,
    })

    ChestTab:AddSection("Rift Chests")
    local riftChestDropdown = ChestTab:AddDropdown("SelectedRiftChest", {
        Title = "Select Rift Chest",
        Values = riftChestOptions,
        Default = Config.selectedChest,
        Multi = false,
        Search = true,
        Callback = function(v)
            Config.selectedChest = v
            saveConfig()
        end,
    })
    ChestTab:AddButton({
        Title = "Refresh chest lists",
        Callback = function()
            setDropdownValues(worldChestDropdown, getWorldChestOptions())
            setDropdownValues(riftChestDropdown, getRiftChestOptions())
        end,
    })
    ChestTab:AddToggle("AutoChestSummon", {
        Title = "Auto Spawn Rift Chest",
        Default = Config.autoChestSummon,
        Callback = function(v)
            Config.autoChestSummon = v
            saveConfig()
        end,
    })
    ChestTab:AddToggle("AutoChest", {
        Title = "Auto Use Keys on Rift Chest",
        Default = Config.autoChest,
        Callback = function(v)
            Config.autoChest = v
            saveConfig()
        end,
    })

    task.spawn(function()
        while true do
            task.wait(Config.autoClaimWorldChest and 1 or 0.85)
            if Config.autoClaimWorldChest then
                claimWorldChest(Config.selectedWorldChest)
            end
        end
    end)

    task.spawn(function()
        local lastSummon = 0
        while true do
            task.wait(Config.autoChestSummon and 1 or 0.85)
            if Config.autoChestSummon and tick() - lastSummon >= 3600 then
                summonChest(Config.selectedChest)
                lastSummon = tick()
            end
        end
    end)

    task.spawn(function()
        local lastTp = 0
        while true do
            task.wait(Config.autoChest and 0.3 or 0.85)
            if Config.autoChest then
                if tick() - lastTp >= 3 then
                    teleportToRiftChest(Config.selectedChest)
                    lastTp = tick()
                end
                pcall(function()
                    remote:FireServer("UnlockRiftChest", Config.selectedChest, false)
                end)
            end
        end
    end)
end

do
    local function addUnique(list, seen, value)
        if type(value) == "string" and value ~= "" and not seen[value] then
            seen[value] = true
            table.insert(list, value)
        end
    end

    local function splitRiftLevel(id)
        local base, lvl = string.match(tostring(id or ""), "^(.-)%-(%d+)$")
        return base, tonumber(lvl)
    end

    local function normalizeRiftBase(id)
        local s = string.lower(tostring(id or ""))
        s = string.gsub(s, "%-all$", "")
        s = string.gsub(s, "%-rift$", "")
        return s
    end

    local function getRiftIds()
        local list, seen = {}, {}
        local hasRiftData = type(RiftsData) == "table" and next(RiftsData) ~= nil
        if type(RiftsData) == "table" then
            for id, cfg in pairs(RiftsData) do
                if type(cfg) == "table" and cfg.Type == "Egg" then
                    addUnique(list, seen, id)
                end
            end
        end
        local folder = getRenderedChild("Rifts")
        if folder then
            for _, rift in ipairs(folder:GetChildren()) do
                local cfg = hasRiftData and RiftsData[rift.Name] or nil
                if not hasRiftData or (type(cfg) == "table" and cfg.Type == "Egg") then
                    addUnique(list, seen, rift.Name)
                end
            end
        end
        local counts = {}
        for _, id in ipairs(list) do
            local base, lvl = splitRiftLevel(id)
            if base and lvl then counts[base] = (counts[base] or 0) + 1 end
        end
        for base, count in pairs(counts) do
            if count > 1 then addUnique(list, seen, base .. "-all") end
        end
        table.sort(list)
        return list
    end

    local function resolveRiftId(id)
        if type(id) ~= "string" or id == "" then return id end
        local aliasBase = string.match(id, "^(.-)%-all$")
        if not aliasBase then return id end
        local best, bestLevel, target = nil, -1, normalizeRiftBase(aliasBase)
        for _, candidate in ipairs(getRiftIds()) do
            local base, lvl = splitRiftLevel(candidate)
            if base and lvl and normalizeRiftBase(base) == target and lvl > bestLevel then
                best, bestLevel = candidate, lvl
            end
        end
        return best or id
    end

    local function riftEggName(riftId)
        if type(RiftsData) == "table" then
            local cfg = RiftsData[riftId]
            if type(cfg) == "table" and cfg.Type == "Egg" and type(cfg.Egg) == "string" then
                return cfg.Egg
            end
        end
        local cleaned = tostring(riftId or ""):gsub("%-rift%-?%d*$", ""):gsub("-", " ")
        return cleaned:gsub("(%a)([%w_']*)", function(first, rest)
            return first:upper() .. rest:lower()
        end) .. " Egg"
    end

    local function getRiftLuck(rift)
        local display = rift and rift:FindFirstChild("Display")
        local gui = display and display:FindFirstChild("SurfaceGui")
        local icon = gui and gui:FindFirstChild("Icon")
        local label = icon and icon:FindFirstChild("Luck")
        return label and (tonumber(tostring(label.Text):match("%d+")) or 0) or 0
    end

    local function bestRift(riftId)
        local folder = getRenderedChild("Rifts")
        if not folder then return nil end
        local target, best, bestLuck = string.lower(riftId or ""), nil, -1
        for _, rift in ipairs(folder:GetChildren()) do
            if string.lower(rift.Name) == target then
                local luck = getRiftLuck(rift)
                if luck > bestLuck then
                    best, bestLuck = rift, luck
                end
            end
        end
        return best
    end

    local function spawnRiftEgg()
        local selected = resolveRiftId(Config.selectedRiftEgg)
        if type(selected) ~= "string" or selected == "" then return end
        if string.find(string.lower(selected), "moon", 1, true) then
            pcall(function()
                remotefunction:InvokeServer("SummonMoonRift", { Type = "Egg", Time = 5, Luck = 5 })
            end)
            return
        end
        local egg = riftEggName(selected)
        local world = (egg == "Mining Egg" or egg == "Neon Egg" or egg == "Cyber Egg") and "Minigame Paradise" or "The Overworld"
        pcall(function()
            remotefunction:InvokeServer("SummonRift", {
                Type = "Egg",
                Name = egg,
                World = world,
                Time = 5,
                Luck = 5,
            })
        end)
    end

    local riftValues = getRiftIds()
    if Config.selectedRiftEgg == "" or not table.find(riftValues, Config.selectedRiftEgg) then
        Config.selectedRiftEgg = riftValues[1] or ""
    end

    local lastRiftSpawnAt = 0

    EggTab:AddSection("Rift Eggs")
    local riftDropdown = EggTab:AddDropdown("SelectRiftEgg", {
        Title = "Rift Egg",
        Values = #riftValues > 0 and riftValues or { "(No rifts found)" },
        Default = Config.selectedRiftEgg ~= "" and Config.selectedRiftEgg or "(No rifts found)",
        Multi = false,
        Search = true,
        Callback = function(v)
            if v and v ~= "(No rifts found)" then
                Config.selectedRiftEgg = v
                saveConfig()
            end
        end,
    })
    EggTab:AddButton({
        Title = "Refresh rift list",
        Callback = function()
            setDropdownValues(riftDropdown, getRiftIds())
        end,
    })
    EggTab:AddToggle("AutoRiftEgg", {
        Title = "Auto Hatch Rift Egg",
        Default = Config.autoRiftEgg,
        Callback = function(v)
            Config.autoRiftEgg = v
            if not v then _G.BGSI_Lite_RiftEggActive = false end
            saveConfig()
        end,
    })
    EggTab:AddToggle("AutoRiftEggSpawn", {
        Title = "Auto Spawn Rift Egg",
        Default = Config.autoRiftEggSpawn,
        Callback = function(v)
            Config.autoRiftEggSpawn = v
            if v then
                spawnRiftEgg()
                lastRiftSpawnAt = tick()
            end
            saveConfig()
        end,
    })

    task.spawn(function()
        while true do
            task.wait(Config.autoRiftEggSpawn and 1 or 0.85)
            if Config.autoRiftEggSpawn then
                local selected = tostring(Config.selectedRiftEgg or "")
                local interval = string.find(string.lower(selected), "moon", 1, true) and 14400 or 3600
                if tick() - lastRiftSpawnAt >= interval then
                    spawnRiftEgg()
                    lastRiftSpawnAt = tick()
                end
            end
        end
    end)

    task.spawn(function()
        local lastTp = 0
        while true do
            task.wait(Config.autoRiftEgg and 0 or 0.85)
            if not Config.autoRiftEgg then
                _G.BGSI_Lite_RiftEggActive = false
                continue
            end
            local riftId = resolveRiftId(Config.selectedRiftEgg)
            local rift = riftId and bestRift(riftId)
            _G.BGSI_Lite_RiftEggActive = rift ~= nil
            if not rift or anyQuestSystemActive() or _G.BGSI_Lite_LuckEggActive then continue end
            if tick() - lastTp >= 5 then
                local cf = getModelPivot(rift)
                if cf then setHRPCFrame(cf + Vector3.new(3, 5, 0)) end
                lastTp = tick()
            end
            fireHatch(riftEggName(riftId))
        end
    end)
end

do
    

    GameTab:AddSection("Thangs")
    GameTab:AddToggle("AutoPlaytime", {
        Title = "Claim Playtime",
        Default = Config.autoPlaytime,
        Callback = function(v) Config.autoPlaytime = v; saveConfig() end,
    })

    GameTab:AddSection("Coins and Bubbles")
    GameTab:AddToggle("AutoCollectCoins", {
        Title = "Auto Collect Coins/Pickups",
        Default = Config.autoCollectCoins,
        Callback = function(v)
            Config.autoCollectCoins = v
            pcall(installPickupRangeHook)
            saveConfig()
        end,
    })
    GameTab:AddToggle("AutoBubble", {
        Title = "Auto Bubble",
        Default = Config.autoBubble,
        Callback = function(v) Config.autoBubble = v; saveConfig() end,
    })

    GameTab:AddSection("Mystery Boxes")
    local function getMysteryBoxes()
        local list = {}
        if type(PowerupsData) == "table" then
            for name, data in pairs(PowerupsData) do
                if type(name) == "string" and type(data) == "table" and data.Type == "Gift" then
                    table.insert(list, name)
                end
            end
        end
        table.sort(list)
        if #list == 0 then list = { "Mystery Box", "Admin Mystery Box", "OG Mystery Box" } end
        return list
    end

    local mysteryDropdown = GameTab:AddDropdown("SelectedMysteryBox", {
        Title = "Select Box",
        Values = { Config.selectedMysteryBox ~= "" and Config.selectedMysteryBox or "Mystery Box" },
        Default = Config.selectedMysteryBox ~= "" and Config.selectedMysteryBox or "Mystery Box",
        Multi = false,
        Search = true,
        Callback = function(v)
            Config.selectedMysteryBox = v
            saveConfig()
        end,
    })
    GameTab:AddButton({
        Title = "Load Mystery Boxes",
        Callback = function()
            setDropdownValues(mysteryDropdown, getMysteryBoxes())
        end,
    })
    GameTab:AddToggle("AutoOpenMystery", {
        Title = "Auto Open Box",
        Default = Config.autoOpenMystery,
        Callback = function(v) Config.autoOpenMystery = v; saveConfig() end,
    })
    GameTab:AddInput("AutoOpenMysteryDelay", {
        Title = "Open Delay",
        Default = tostring(Config.autoOpenMysteryDelay),
        Numeric = true,
        Callback = function(v)
            local n = tonumber(v)
            if n then
                Config.autoOpenMysteryDelay = math.clamp(n, 0.1, 60)
                saveConfig()
            end
        end,
    })

    task.spawn(function()
        while true do
            task.wait(Config.autoPlaytime and 5 or 0.85)
            if Config.autoPlaytime then
                pcall(function() remote:FireServer("ClaimAllPlaytime") end)
            end
        end
    end)

    task.spawn(function()
        while true do
            task.wait(Config.autoCollectCoins and 2 or 0.85)
            if Config.autoCollectCoins then
                pcall(installPickupRangeHook)
                pcall(function() remote:FireServer("UseGoldenOrb") end)
            end
        end
    end)

    task.spawn(function()
        while true do
            task.wait(Config.autoBubble and 0.03 or 0.85)
            if Config.autoBubble then
                pcall(function() remote:FireServer("BlowBubble") end)
            end
        end
    end)

    task.spawn(function()
        local function claimGifts()
            local gifts = getRenderedChild("Gifts")
            if not gifts then return end
            for _, gift in ipairs(gifts:GetChildren()) do
                pcall(function() remote:FireServer("ClaimGift", gift.Name) end)
            end
        end
        while true do
            local delay = math.clamp(tonumber(Config.autoOpenMysteryDelay) or 0.2, 0.1, 60)
            task.wait(Config.autoOpenMystery and delay or 0.85)
            if Config.autoOpenMystery and type(Config.selectedMysteryBox) == "string" and Config.selectedMysteryBox ~= "" then
                pcall(function()
                    remote:FireServer("UseGift", Config.selectedMysteryBox, 50)
                end)
                claimGifts()
                task.wait()
                claimGifts()
            end
        end
    end)
end
-- ============================================================
-- Teams tab
-- ============================================================
do
    TeamsTab:AddSection("Team Assignments")
    TeamsTab:AddParagraph({
        Title = "How it works",
        Content = "Set which of your in-game teams (1–10) is used for hatching, bubbling, and each currency. The quest system will auto-switch when it needs to.",
    })

    -- Helper to create a numbered input for each team slot
    local function addTeamInput(flagName, title, configKey, default)
        TeamsTab:AddInput(flagName, {
            Title = title,
            Default = tostring(Config[configKey] or default),
            Placeholder = "1-10",
            Numeric = true,
            Callback = function(v)
                local n = tonumber(v)
                if n then
                    Config[configKey] = math.clamp(math.floor(n), 1, 10)
                    saveConfig()
                end
            end,
        })
    end

    addTeamInput("TeamHatchInput",     "Hatch Team Number",       "teamHatch",     1)
    addTeamInput("TeamBubbleInput",    "Bubble Team Number",      "teamBubble",    2)
    addTeamInput("TeamCurrency1Input", "Currency Team 1 (Coins)", "teamCurrency1", 3)
    addTeamInput("TeamCurrency2Input", "Currency Team 2 (Gems)",  "teamCurrency2", 4)

    TeamsTab:AddSection("Quick Switch")
    TeamsTab:AddParagraph({
        Title = "Manual switch",
        Content = "Tap a button to immediately equip that team.",
    })

    -- One button per team slot, using the configured number
    TeamsTab:AddButton({
        Title = "Equip Hatch Team",
        Callback = function()
            equipTeam(Config.teamHatch)
            Fluent:Notify({ Title = "Team", Content = "Equipped hatch team (" .. Config.teamHatch .. ")", Duration = 2 })
        end,
    })
    TeamsTab:AddButton({
        Title = "Equip Bubble Team",
        Callback = function()
            equipTeam(Config.teamBubble)
            Fluent:Notify({ Title = "Team", Content = "Equipped bubble team (" .. Config.teamBubble .. ")", Duration = 2 })
        end,
    })
    TeamsTab:AddButton({
        Title = "Equip Currency Team 1",
        Callback = function()
            equipTeam(Config.teamCurrency1)
            Fluent:Notify({ Title = "Team", Content = "Equipped currency team 1 (" .. Config.teamCurrency1 .. ")", Duration = 2 })
        end,
    })
    TeamsTab:AddButton({
        Title = "Equip Currency Team 2",
        Callback = function()
            equipTeam(Config.teamCurrency2)
            Fluent:Notify({ Title = "Team", Content = "Equipped currency team 2 (" .. Config.teamCurrency2 .. ")", Duration = 2 })
        end,
    })

    TeamsTab:AddSection("Auto Switching")
    TeamsTab:AddToggle("AutoSwitchTeams", {
        Title = "Auto Switch Teams for Quests",
        Default = Config.autoSwitchTeams,
        Callback = function(v)
            Config.autoSwitchTeams = v
            saveConfig()
        end,
    })
    TeamsTab:AddParagraph({
        Title = "Note",
        Content = "When enabled, quest tasks will auto-switch to the matching team before starting, and switch back to the hatch team when done.",
    })
end
-- ============================================================
-- Minigames tab
-- ============================================================
do
    local clawDifficulties = { "Easy", "Medium", "Hard", "Insane" }

    local function selectedClawDifficulty()
        local selected = tostring(Config.selectedClawDifficulty or "Insane")
        for _, difficulty in ipairs(clawDifficulties) do
            if selected == difficulty then
                return selected
            end
        end
        Config.selectedClawDifficulty = "Insane"
        return "Insane"
    end

    local function isMinigameHudVisible()
        return game:GetService("Players").LocalPlayer.PlayerGui
            .ScreenGui.MinigameHUD.Visible
    end

    local function startMinigamePacket()
        local remote = game.ReplicatedStorage:WaitForChild("Shared")
            :WaitForChild("Framework"):WaitForChild("Network")
            :WaitForChild("Remote"):WaitForChild("RemoteEvent")
        remote:FireServer("StartMinigame", "Robot Claw", selectedClawDifficulty())
    end

    local function skipCooldownPacket(...)
        local remote = game.ReplicatedStorage:WaitForChild("Shared")
            :WaitForChild("Framework"):WaitForChild("Network")
            :WaitForChild("Remote"):WaitForChild("RemoteEvent")
        remote:FireServer("SkipMinigameCooldown", ...)
    end

    local function onFinishMinigame(startGameFn, skipCooldownFn, items, ...)
        if not Config.autoClaw or not items then return end
        if type(items) ~= "table" then
            for _, arg in ipairs({ ... }) do
                if type(arg) == "table" then
                    items = arg
                    break
                end
            end
        end
        if type(items) ~= "table" then return end

        getgenv().collectAmount = getgenv().collectAmount + #items
        for _, item in pairs(items) do
            local name = item.Name
            if item.Level then
                name = item.Name .. " " .. item.Level
            end
            local amount = item.Amount or 1
            getgenv().collectedItems[name] = (getgenv().collectedItems[name] or 0) + amount
        end

        getgenv().isDoingMinigame = false
        if not getgenv().isDoingMinigame then
            startGameFn("Robot Claw")
            task.wait()
            skipCooldownFn()
        end
    end

    local function onStartMinigame(bonusItemsArg)
        if not Config.autoClaw or not bonusItemsArg then return end

        getgenv().isDoingMinigame = true
        getgenv().startCount = getgenv().startCount + 1

        local bonusItems = bonusItemsArg.BonusItems
        local remote = game:GetService("ReplicatedStorage")
            :WaitForChild("Shared"):WaitForChild("Framework")
            :WaitForChild("Network"):WaitForChild("Remote")
            :WaitForChild("RemoteEvent")

        for _, bonusItem in pairs(bonusItems) do
            if not Config.autoClaw then break end
            getgenv().spawnedAmount = getgenv().spawnedAmount + 1
            if bonusItem.Name:find("Dice") or bonusItem.Name:find("Golden") then
                remote:FireServer(unpack({ "GrabMinigameItem", bonusItem }))
                task.wait()
                getgenv().shouldBeCollectedAmount = getgenv().shouldBeCollectedAmount + 1
            end
        end

        if getgenv().tryCollectMultipleTimes then
            for i = 1, 9 do
                if not Config.autoClaw then break end
                for _, bonusItem in pairs(bonusItems) do
                    if not Config.autoClaw then break end
                    if bonusItem.Name:find("Dice") or bonusItem.Name:find("Golden") then
                        remote:FireServer(unpack({ "GrabMinigameItem", bonusItem }))
                        task.wait()
                    end
                end
            end
        end

        while Config.autoClaw do
            task.wait()
            if getgenv().isDoingMinigame then
                game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Framework")
                    :WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("RemoteEvent")
                    :FireServer("FinishMinigame")
                task.wait()
            else
                break
            end
        end
    end

    local function statusReporter()
        while true do
            task.wait(getgenv().reportTime)
            if Config.autoClaw then
                warn("IdiotHub AutoClaw")
                warn("[IdiotHub Robot Claw Report]: Ran", getgenv().startCount,
                    "times in the past " .. getgenv().reportTime .. " seconds.")
                warn("Items Collected:")
                for name, amount in pairs(getgenv().collectedItems) do
                    warn("  " .. name .. ": " .. amount)
                end
                getgenv().startCount = 0
                getgenv().collectedItems = {}
            end
        end
    end

    local function installClawHooks()
        getgenv().reportTime = getgenv().reportTime or 60
        getgenv().startCount = getgenv().startCount or 0
        getgenv().collectedItems = getgenv().collectedItems or {}
        getgenv().collectAmount = getgenv().collectAmount or 0
        getgenv().shouldBeCollectedAmount = getgenv().shouldBeCollectedAmount or 0
        getgenv().spawnedAmount = getgenv().spawnedAmount or 0
        getgenv().isDoingMinigame = getgenv().isDoingMinigame or false

        if not getgenv()._1rzHubLiteAutoClawReporterStarted then
            getgenv()._1rzHubLiteAutoClawReporterStarted = true
            task.spawn(statusReporter)
        end

        if not getgenv()._1rzHubLiteAutoClawInstalled then
            local remote = require(game:GetService("ReplicatedStorage")
                .Shared.Framework.Network.Remote)

            remote.Event("StartMinigame"):Connect(onStartMinigame)
            remote.Event("FinishMinigame"):Connect(function(...)
                onFinishMinigame(startMinigamePacket, skipCooldownPacket, ...)
            end)

            getgenv()._1rzHubLiteAutoClawInstalled = true
        end

        if not getgenv()._1rzHubLiteAutoClawTransitionHookedV2 and type(hookfunction) == "function" then
            pcall(function()
                local playTransition = require(game:GetService("ReplicatedStorage").Client.Gui.PlayTransition)
                if typeof(playTransition) == "function" then
                    local originalPlayTransition
                    originalPlayTransition = hookfunction(playTransition, function(...)
                        if isMinigameHudVisible() then return end
                        if typeof(originalPlayTransition) == "function" then
                            return originalPlayTransition(...)
                        end
                    end)
                    getgenv()._1rzHubLiteAutoClawTransitionHookedV2 = true
                end
            end)
        end
    end

    MinigamesTab:AddSection("Robot Claw")
    MinigamesTab:AddDropdown("ClawDifficulty", {
        Title = "Difficulty",
        Values = clawDifficulties,
        Default = selectedClawDifficulty(),
        Multi = false,
        Search = false,
        Callback = function(v)
            Config.selectedClawDifficulty = v
            saveConfig()
        end,
    })

    MinigamesTab:AddToggle("AutoClaw", {
        Title = "Auto Claw",
        Default = Config.autoClaw,
        Callback = function(v)
            Config.autoClaw = v
            saveConfig()
            installClawHooks()
            if v then
                getgenv().isDoingMinigame = false
                startMinigamePacket()
                task.wait()
                skipCooldownPacket()
            else
                getgenv().isDoingMinigame = false
            end
        end,
    })

    installClawHooks()
end

-- ============================================================
-- Enchant tab
-- ============================================================
do
    local function getEnchantOptions()
        local list = {}
        if type(EnchantsData) == "table" then
            for k in pairs(EnchantsData) do
                if type(k) == "string" and not k:lower():find("^super%-") then
                    table.insert(list, k)
                end
            end
            table.sort(list)
        end
        if #list == 0 then list = { "secret-hunter", "ultra-roller" } end
        return list
    end
    local enchantOptions = getEnchantOptions()
    local enchantWithNone = { "(None - single target)" }
    for _, v in ipairs(enchantOptions) do table.insert(enchantWithNone, v) end
    local currencyOptions = {
        "Auto (Secret=Crystals, Normal=Gems)",
        "Auto (Secret=Crystals, Normal=Reroll Orbs)",
        "Gems",
        "Reroll Orbs",
    }

    EnchantTab:AddSection("Auto Enchant Equipped Pets")
    EnchantTab:AddToggle("AutoEnchant", {
        Title = "Auto Enchant",
        Default = Config.autoEnchant,
        Callback = function(v) Config.autoEnchant = v; saveConfig() end,
    })
    EnchantTab:AddDropdown("TargetEnchant1", {
        Title = "Target Enchant 1",
        Values = enchantOptions,
        Default = Config.equippedTargetEnchant,
        Multi = false,
        Callback = function(v) if v then Config.equippedTargetEnchant = v; saveConfig() end end,
    })
    EnchantTab:AddDropdown("TargetEnchant2", {
        Title = "Target Enchant 2",
        Values = enchantWithNone,
        Default = (Config.equippedTargetEnchant2 ~= "" and Config.equippedTargetEnchant2) or "(None - single target)",
        Multi = false,
        Callback = function(v)
            if v then Config.equippedTargetEnchant2 = (v == "(None - single target)") and "" or v; saveConfig() end
        end,
    })
    EnchantTab:AddInput("TargetEnchantLevel", {
        Title = "Target Level (0 = any)",
        Default = tostring(Config.equippedTargetEnchantLevel or 0),
        Numeric = true,
        Callback = function(v)
            local n = tonumber(v)
            Config.equippedTargetEnchantLevel = (n and n >= 0) and n or 0
            saveConfig()
        end,
    })
    EnchantTab:AddDropdown("EnchantCurrency", {
        Title = "Currency",
        Values = currencyOptions,
        Default = Config.equippedEnchantCurrency,
        Multi = false,
        Callback = function(v) if v then Config.equippedEnchantCurrency = v; saveConfig() end end,
    })
end

-- Enchant helpers + loop.
local function normEnchantId(id)
    if type(id) ~= "string" then return "" end
    return string.lower(id):gsub("[%s_%-]", "")
end
-- Server auto-removes expired enchants from the slot; nothing to filter here.
-- When the outer loop's next pass sees the empty slot, it'll reroll to refresh the target.
local function getPetEnchantSlots(pet)
    local slots = {}
    local en = pet and (pet.Enchants or pet.Enchantments) or {}
    for i = 1, 2 do
        local e = en[i] or en[tostring(i)]
        if type(e) == "table" then
            local id = e.Id or e.ID or e.Name or e.Enchant or ""
            if id and id ~= "" then slots[i] = tostring(id) end
        end
    end
    return slots
end
local function slotWithEnchantId(pet, enchantId)
    if not enchantId or enchantId == "" or enchantId == "(None - single target)" then return nil end
    local want = normEnchantId(enchantId)
    local slots = getPetEnchantSlots(pet)
    for i = 1, 2 do
        if slots[i] and normEnchantId(slots[i]) == want then return i end
    end
    return nil
end
local function getEnchantDef(id)
    if not id or id == "" or type(EnchantsData) ~= "table" then return nil end
    local def = EnchantsData[id]
    if def then return def end
    local want = normEnchantId(id)
    for k, v in pairs(EnchantsData) do
        if type(k) == "string" and type(v) == "table" and normEnchantId(k) == want then return v end
    end
    return nil
end
local function isSecretEnchant(id)
    local def = getEnchantDef(id)
    if type(def) ~= "table" then return false end
    return def.Special == true or def.Secret == true
end
-- Max level the enchant rolls at. Secret/special enchants are typically 1 → ignore target level.
local function getEnchantMaxLevel(id)
    local def = getEnchantDef(id)
    if type(def) ~= "table" then return nil end
    if type(def.Levels) == "number" and def.Levels > 0 then return def.Levels end
    if type(def.Buffs) == "table" then
        local n = #def.Buffs
        if n > 0 then return n end
    end
    return nil
end
local function isSingleLevelEnchant(id)
    if isSecretEnchant(id) then return true end
    local m = getEnchantMaxLevel(id)
    return type(m) == "number" and m == 1
end

local function hasShadowCrystals()
    local ok, d = pcall(function() return LocalData:Get() end)
    if not ok or type(d) ~= "table" then return false end
    local function n(v) return type(v) == "number" and v > 0 end
    if type(d.Powerups) == "table" and n(d.Powerups["Shadow Crystal"]) then return true end
    if type(d.Currencies) == "table" and (n(d.Currencies["Shadow Crystals"]) or n(d.Currencies["ShadowCrystals"])) then return true end
    if n(d.ShadowCrystals) then return true end
    return false
end

-- If chasing Secret but no Shadow Crystals owned, fall back to the auto setting's non-secret currency
-- (Gems or Reroll Orbs) so the loop actually rerolls.
local function resolveEnchantCurrency(setting, chaseTarget)
    local secret = isSecretEnchant(chaseTarget)
    if secret and not hasShadowCrystals() then
        if setting == "Auto (Secret=Crystals, Normal=Reroll Orbs)" then return "Reroll Orbs" end
        return "Gems"
    end
    if setting == "Auto (Secret=Crystals, Normal=Gems)" then return secret and "Shadow Crystals" or "Gems" end
    if setting == "Auto (Secret=Crystals, Normal=Reroll Orbs)" then return secret and "Shadow Crystals" or "Reroll Orbs" end
    return setting
end

-- Level-aware slot match. For Secret/special enchants (1-level) target level is ignored;
-- otherwise must match id AND have level >= targetLevel (clamped to that enchant's actual max).
local function slotWithEnchantAtLevel(pet, enchantId, targetLevel)
    if not enchantId or enchantId == "" or enchantId == "(None - single target)" then return nil end
    local tl = tonumber(targetLevel) or 0
    if tl > 0 and isSingleLevelEnchant(enchantId) then tl = 0 end
    if tl <= 0 then return slotWithEnchantId(pet, enchantId) end
    local want = normEnchantId(enchantId)
    local en = pet and (pet.Enchants or pet.Enchantments) or {}
    for i = 1, 2 do
        local e = en[i] or en[tostring(i)]
        if type(e) == "table" then
            local id = e.Id or e.ID or e.Name or e.Enchant or ""
            if normEnchantId(id) == want then
                local lvl = tonumber(e.Level or e.Lv or e.Tier or e.Rank)
                local maxLv = getEnchantMaxLevel(id)
                local needLv = (maxLv and maxLv > 0) and math.min(tl, maxLv) or tl
                if lvl == nil or lvl >= needLv then return i end
            end
        end
    end
    return nil
end
-- Double enchant vulnerability: firing UseShadowCrystal with slot 1 locked on a non-Shiny pet
-- still writes a Secret enchant to slot 2 even though MaxEnchantSlots returns 1. Whitelisted
-- users can target 2 enchants on any pet, not just Shinies.
local DOUBLE_ENCHANT_WHITELIST = {
    ["humanbeingsarehumans"] = true,
    ["1rztrade"] = true,
    ["mopysik"] = true,
    ["1rzbgsi2"] = true,
    ["1rzbgsi"] = true,
    ["bgsigmer043920"] = true,
    ["degenbubbler05"] = true,
}
local _hasDualEnchant = type(player) == "userdata" and type(player.Name) == "string"
    and DOUBLE_ENCHANT_WHITELIST[player.Name:lower()] == true

local function canDualEnchant(pet)
    if not pet then return false end
    if _hasDualEnchant then return true end
    if EnchantUtil and type(EnchantUtil.GetMaxEnchantSlots) == "function" then
        local ok, slots = pcall(EnchantUtil.GetMaxEnchantSlots, EnchantUtil, pet)
        if ok and type(slots) == "number" then return slots >= 2 end
    end
    return pet.Shiny == true or pet.IsShiny == true
end
local function getEquippedPetIds()
    local ok, d = pcall(function() return LocalData:Get() end)
    if not ok or type(d) ~= "table" then return {} end
    if not d.Teams or not d.TeamEquipped then return {} end
    local team = d.Teams[d.TeamEquipped]
    return (team and type(team.Pets) == "table") and team.Pets or {}
end
local function getPetById(id)
    local ok, d = pcall(function() return LocalData:Get() end)
    if not ok or type(d) ~= "table" or type(d.Pets) ~= "table" then return nil end
    for _, p in ipairs(d.Pets) do if p.Id == id then return p end end
    return nil
end

local enchantRunning = false
local function runEnchantLoop()
    if enchantRunning then return end
    enchantRunning = true
    task.spawn(function()
        while Config.autoEnchant do
            local t1 = Config.equippedTargetEnchant or ""
            local t2 = Config.equippedTargetEnchant2 or ""
            local tLevel = tonumber(Config.equippedTargetEnchantLevel) or 0
            local currency = Config.equippedEnchantCurrency or "Auto (Secret=Crystals, Normal=Gems)"
            local hasT2 = t2 ~= "" and t2 ~= "(None - single target)"
            local petIds = getEquippedPetIds()
            for _, pid in ipairs(petIds) do
                if not Config.autoEnchant then break end
                local pet = getPetById(pid)
                if pet and pet.Super ~= true then
                    local dual = canDualEnchant(pet)
                    while Config.autoEnchant do
                        pet = getPetById(pid)
                        if not pet then break end
                        local s1 = slotWithEnchantAtLevel(pet, t1, tLevel)
                        local s2 = hasT2 and slotWithEnchantAtLevel(pet, t2, tLevel) or nil
                        local done = false
                        if hasT2 and dual then done = (s1 and s2) and true or false
                        elseif hasT2 then done = (s1 or s2) and true or false
                        else done = s1 ~= nil end
                        if done then break end
                        -- Lock whichever slot already has a target id (id-only — we'd reroll a low-level
                        -- target away otherwise). The OTHER slot is what gets rerolled.
                        local idS1 = slotWithEnchantId(pet, t1)
                        local idS2 = hasT2 and slotWithEnchantId(pet, t2) or nil
                        local lockedSlot = nil
                        local chase = t1
                        if hasT2 and dual then
                            if idS1 and not idS2 then lockedSlot = idS1; chase = t2 end
                            if idS2 and not idS1 then lockedSlot = idS2; chase = t1 end
                        end
                        local resolved = resolveEnchantCurrency(currency, chase)
                        if resolved == "Shadow Crystals" then
                            pcall(function() remote:FireServer("UseShadowCrystal", pid, lockedSlot) end)
                        elseif resolved == "Reroll Orbs" then
                            pcall(function() remotefunction:InvokeServer("RerollEnchants", pid, "Powerup", lockedSlot) end)
                        else
                            pcall(function() remotefunction:InvokeServer("RerollEnchants", pid, "Gems", lockedSlot) end)
                        end
                        task.wait(0.55)
                        if not Config.autoEnchant then break end
                        -- Double-check
                        pet = getPetById(pid)
                        if pet then
                            s1 = slotWithEnchantAtLevel(pet, t1, tLevel)
                            s2 = hasT2 and slotWithEnchantAtLevel(pet, t2, tLevel) or nil
                            local done2 = false
                            if hasT2 and dual then done2 = (s1 and s2) and true or false
                            elseif hasT2 then done2 = (s1 or s2) and true or false
                            else done2 = s1 ~= nil end
                            if done2 then break end
                        end
                        task.wait(0.2)
                    end
                end
                task.wait(0.05)
            end
            task.wait(0.3)
        end
        enchantRunning = false
    end)
end
if Config.autoEnchant then runEnchantLoop() end
-- Re-bind the toggle to call runEnchantLoop (callback above already saves; this watches the flag).
task.spawn(function()
    local was = false
    while true do
        task.wait(0.3)
        if Config.autoEnchant and not was then runEnchantLoop() end
        was = Config.autoEnchant
    end
end)

-- ============================================================
-- Quests tab (Gem Genie + Season Pass + Global Incentive)
-- ============================================================
do
    QuestsTab:AddSection("Gem Genie")

    local function getGemGenieItems()
        local out, seen = {}, {}
        local function add(n)
            if type(n) ~= "string" or n == "" or seen[n] then return end
            seen[n] = true
            table.insert(out, n)
        end
        -- Hardcoded from Shared.Data.Quests.GenieQuest LootPoolBuilder (place file).
        -- Includes low-weight items (Green Fragment 0.1, Rune Rock 0.5) that would need
        -- thousands of seed simulations to discover via the scan below.
        for _, n in ipairs({
            "Spin Ticket", "Reroll Orb", "Power Orb",
            "Lucky", "Speed", "Coins", "Mythic",
            "Royal Key", "Dream Shard",
            "Infinity Elixir", "Secret Elixir", "Egg Elixir",
            "Ultra Infinity Elixir", "Wonderland Elixir",
            "Rune Rock", "Green Fragment", "Shadow Crystal",
            "Mystery Box", -- bonus reward path when CompleteGenieQuest > -1
        }) do add(n) end
        -- Seed scan as backup discovery for items the game adds later.
        local ok, GenieQuest = pcall(function() return require(ReplicatedStorage.Shared.Data.Quests.GenieQuest) end)
        if ok and type(GenieQuest) == "function" then
            local pdataOk, pdata = pcall(function() return LocalData:Get() end)
            if pdataOk and type(pdata) == "table" then
                for i = 1, 1500 do
                    local okQ, q = pcall(GenieQuest, pdata, i)
                    if okQ and type(q) == "table" and type(q.Rewards) == "table" then
                        for _, r in ipairs(q.Rewards) do
                            if type(r) == "table" then
                                add(r.Name or r.Currency or r.Item)
                            end
                        end
                    end
                end
            end
        end
        table.sort(out)
        return out
    end

    local targetItems = getGemGenieItems()
    if not table.find(targetItems, Config.gemGenieTargetItem) then
        Config.gemGenieTargetItem = targetItems[1] or "Shadow Crystal"
        saveConfig()
    end
    QuestsTab:AddDropdown("GemGenieTarget", {
        Title = "Target Item",
        Values = targetItems,
        Default = Config.gemGenieTargetItem,
        Multi = false,
        Search = true,
        Callback = function(v) Config.gemGenieTargetItem = v; saveConfig() end,
    })
    QuestsTab:AddToggle("AutoGemGenie", {
        Title = "Auto Gem Genie",
        Default = Config.autoGemGenie,
        Callback = function(v) Config.autoGemGenie = v; saveConfig() end,
    })
    QuestsTab:AddToggle("OptimisedGemGenie", {
        Title = "Optimised mode (only hatch tasks, ignores selected item)",
        Default = Config.optimisedGemGenie,
        Callback = function(v) Config.optimisedGemGenie = v; saveConfig() end,
    })

    QuestsTab:AddSection("Season Pass")
    QuestsTab:AddToggle("AutoSeason", {
        Title = "Auto Claim Season Pass",
        Default = Config.autoSeason,
        Callback = function(v) Config.autoSeason = v; saveConfig() end,
    })
    QuestsTab:AddToggle("AutoDailyHourly", {
        Title = "Auto Season Pass Quests (daily/hourly)",
        Default = Config.autoDailyHourlyChallenge,
        Callback = function(v) Config.autoDailyHourlyChallenge = v; saveConfig() end,
    })

    QuestsTab:AddSection("Global Incentive")
    QuestsTab:AddToggle("AutoGlobalIncentive", {
        Title = "Auto Global Incentive Quests",
        Default = Config.autoGlobalIncentive,
        Callback = function(v) Config.autoGlobalIncentive = v; saveConfig() end,
    })
    QuestsTab:AddToggle("AutoClaimGlobalIncentive", {
        Title = "Auto Claim Global Incentive",
        Default = Config.autoClaimGlobalIncentive,
        Callback = function(v) Config.autoClaimGlobalIncentive = v; saveConfig() end,
    })
end

-- Season Pass claim loop.
task.spawn(function()
    while true do
        if Config.autoSeason then
            pcall(function() remote:FireServer("ClaimSeason") end)
        end
        task.wait(5)
    end
end)

-- Claim Global Incentive loop.
task.spawn(function()
    while true do
        if Config.autoClaimGlobalIncentive then
            pcall(function()
                remote:FireServer("ClaimGlobalIncentiveQuest")
                for i = 1, 10 do remote:FireServer("ClaimGlobalIncentives", i) end
            end)
        end
        task.wait(1)
    end
end)

-- Gem Genie quest runner.
local function getActiveGemGenieQuest()
    if not LocalData:IsReady() then return nil end
    local d = LocalData:Get()
    if not d then return nil end
    local gg = d.GemGenie
    if type(gg) == "table" then
        if type(gg.Quest) == "table" then
            local q = gg.Quest
            if (q.Completed == false or q.Completed == nil) and type(q.Tasks) == "table" and next(q.Tasks) then return q end
        end
        if type(gg.ActiveQuest) == "table" then
            local q = gg.ActiveQuest
            if (q.Completed == false or q.Completed == nil) then return q end
        end
    end
    if QuestUtil and type(QuestUtil.FindById) == "function" then
        local ok, q = pcall(function() return QuestUtil:FindById(d, "gem-genie") end)
        if ok and q and (q.Completed == false or q.Completed == nil) then return q end
    end
    return nil
end
local function findGenieOptionWithTarget(playerData, seed, target)
    local ok, GenieQuest = pcall(function() return require(ReplicatedStorage.Shared.Data.Quests.GenieQuest) end)
    if not ok or type(GenieQuest) ~= "function" then return nil end
    local function matches(reward)
        if type(reward) ~= "table" then return false end
        for _, v in pairs(reward) do
            if type(v) == "string" and string.lower(v) == string.lower(target) then return true end
        end
        if type(reward.Item) == "table" then
            for _, v in pairs(reward.Item) do
                if type(v) == "string" and string.lower(v) == string.lower(target) then return true end
            end
        end
        return false
    end
    for i = 1, 3 do
        local okQ, q = pcall(GenieQuest, playerData, seed + (i - 1))
        if okQ and type(q) == "table" and type(q.Rewards) == "table" then
            for _, r in ipairs(q.Rewards) do
                if matches(r) then return i, q end
            end
        end
    end
    return nil
end
local function findGenieOptionAllHatch(playerData, seed)
    local ok, GenieQuest = pcall(function() return require(ReplicatedStorage.Shared.Data.Quests.GenieQuest) end)
    if not ok or type(GenieQuest) ~= "function" then return nil end
    for i = 1, 3 do
        local okQ, q = pcall(GenieQuest, playerData, seed + (i - 1))
        if okQ and type(q) == "table" and type(q.Tasks) == "table" then
            local allHatch = true
            for _, t in pairs(q.Tasks) do
                if type(t) == "table" and not looksLikeHatch(t) then allHatch = false break end
            end
            if allHatch then return i, q end
        end
    end
    return nil
end

task.spawn(function()
    while true do
        if not Config.autoGemGenie then
            if _G.BGSI_Lite_GemGenieActive then
                _G.BGSI_Lite_GemGenieActive = false
                restoreHatchesAfterQuest()
            end
            task.wait(0.5)
            continue
        end
        local quest = getActiveGemGenieQuest()
        if not quest then
            -- No active quest — check cooldown, then reroll or start
            local ok, d = pcall(function() return LocalData:Get() end)
            if not ok or not d then task.wait(1) continue end
            local gg = d.GemGenie or {}
            local nextAt = tonumber(gg.Next) or 0
            local now = TimeUtil.now()
            if nextAt > now then
                _G.BGSI_Lite_GemGenieActive = false
                restoreHatchesAfterQuest()
                task.wait(1)
                continue
            end
            local seed = tonumber(gg.Seed) or 0
            local idx, _q
            if Config.optimisedGemGenie then
                idx, _q = findGenieOptionAllHatch(d, seed)
            else
                idx, _q = findGenieOptionWithTarget(d, seed, Config.gemGenieTargetItem or "")
            end
            if idx then
                pcall(function() remote:FireServer("StartGenieQuest", idx) end)
                task.wait(2)
            else
                pcall(function() remote:FireServer("RerollGenie") end)
                task.wait(0.5)
            end
            continue
        end

        -- Active quest -> run incomplete tasks
        _G.BGSI_Lite_GemGenieActive = true
        pauseHatchesForQuest()
        for _, ti in ipairs(orderedTaskIndices(quest.Tasks)) do
            if not Config.autoGemGenie then break end
            local td = quest.Tasks[ti]
            if type(td) == "table" then
                local req = getTaskRequirement(td)
                local prog = getTaskProgress(quest, ti)
                if prog < req then
                    local shouldContinue = function()
                        return Config.autoGemGenie == true
                    end
                    local getQuest = function() return getActiveGemGenieQuest() end
                    if taskTypeLooksLikeCollect(td) then
                        runCollectTaskLoop(getQuest, ti, req, shouldContinue, collectCurrencyKey(td))
                    elseif looksLikeHatch(td) then
                        runHatchTaskLoop(getQuest, ti, req, shouldContinue)
                    elseif looksLikeBubble(td) then
                        runBubbleTaskLoop(getQuest, ti, req, shouldContinue)
                    else
                        task.wait(0.5)
                    end
                end
            end
        end
        task.wait(0.5)
    end
end)

-- Season Pass quest runner (daily/hourly challenges)
local function getSeasonChallengeQuests()
    local out = {}
    if not LocalData:IsReady() then return out end
    local d = LocalData:Get()
    if not d then return out end
    local containers = { d.Quests, d.ActiveQuests, d.DailyChallenges, d.HourlyChallenges }
    local seen = {}
    for _, c in ipairs(containers) do
        if type(c) == "table" then
            for _, q in pairs(c) do
                if type(q) == "table" then
                    local qid = q.Id or q.ID
                    if type(qid) == "string" and (qid:match("^daily%-challenge%-%d+$") or qid:match("^hourly%-challenge%-%d+$")) then
                        if not seen[qid] and (q.Completed == false or q.Completed == nil) then
                            seen[qid] = true
                            table.insert(out, q)
                        end
                    end
                end
            end
        end
    end
    return out
end
local function findSeasonQuestById(qid)
    if not LocalData:IsReady() then return nil end
    local d = LocalData:Get()
    if QuestUtil and type(QuestUtil.FindById) == "function" then
        local ok, q = pcall(function() return QuestUtil:FindById(d, qid) end)
        if ok and q then return q end
    end
    for _, c in ipairs({ d and d.Quests, d and d.ActiveQuests }) do
        if type(c) == "table" then
            for _, q in pairs(c) do
                if type(q) == "table" and (q.Id == qid or q.ID == qid) then return q end
            end
        end
    end
    return nil
end

task.spawn(function()
    while true do
        if not Config.autoDailyHourlyChallenge then
            if _G.BGSI_Lite_SeasonActive then
                _G.BGSI_Lite_SeasonActive = false
                restoreHatchesAfterQuest()
            end
            task.wait(0.5)
            continue
        end
        if _G.BGSI_Lite_GemGenieActive then task.wait(0.5) continue end
        local quests = getSeasonChallengeQuests()
        if #quests == 0 then
            _G.BGSI_Lite_SeasonActive = false
            restoreHatchesAfterQuest()
            task.wait(2)
            continue
        end
        local hasIncomplete = false
        for _, q in ipairs(quests) do
            for _, ti in ipairs(orderedTaskIndices(q.Tasks)) do
                local td = q.Tasks[ti]
                if type(td) == "table" then
                    local req = getTaskRequirement(td)
                    local prog = getTaskProgress(q, ti)
                    if prog < req then hasIncomplete = true; break end
                end
            end
            if hasIncomplete then break end
        end
        if not hasIncomplete then
            _G.BGSI_Lite_SeasonActive = false
            restoreHatchesAfterQuest()
            task.wait(2)
            continue
        end
        _G.BGSI_Lite_SeasonActive = true
        pauseHatchesForQuest()
        for _, q in ipairs(quests) do
            if not Config.autoDailyHourlyChallenge then break end
            if _G.BGSI_Lite_GemGenieActive then break end
            local qid = q.Id or q.ID
            for _, ti in ipairs(orderedTaskIndices(q.Tasks)) do
                if not Config.autoDailyHourlyChallenge then break end
                if _G.BGSI_Lite_GemGenieActive then break end
                local td = q.Tasks[ti]
                if type(td) == "table" then
                    local req = getTaskRequirement(td)
                    local prog = getTaskProgress(q, ti)
                    if prog < req then
                        local shouldContinue = function()
                            return Config.autoDailyHourlyChallenge and not _G.BGSI_Lite_GemGenieActive
                        end
                        local getQuest = function() return findSeasonQuestById(qid) end
                        if taskTypeLooksLikeCollect(td) then
                            runCollectTaskLoop(getQuest, ti, req, shouldContinue, collectCurrencyKey(td))
                        elseif looksLikeHatch(td) then
                            runHatchTaskLoop(getQuest, ti, req, shouldContinue)
                        elseif looksLikeBubble(td) then
                            runBubbleTaskLoop(getQuest, ti, req, shouldContinue)
                        else
                            task.wait(0.5)
                        end
                    end
                end
            end
        end
        task.wait(0.5)
    end
end)

-- Global Incentive runner
local function getGlobalIncentiveQuests()
    local out = {}
    if not LocalData:IsReady() then return out end
    local d = LocalData:Get()
    if not d then return out end
    local seen = {}
    for _, c in ipairs({ d.Quests, d.ActiveQuests }) do
        if type(c) == "table" then
            for _, q in pairs(c) do
                if type(q) == "table" then
                    local qid = q.Id or q.ID
                    if type(qid) == "string" and qid:sub(1, 17) == "global-incentive-" then
                        if not seen[qid] and (q.Completed == false or q.Completed == nil) then
                            seen[qid] = true
                            table.insert(out, q)
                        end
                    end
                end
            end
        end
    end
    return out
end
local function findGlobalIncentiveQuestById(qid)
    if not LocalData:IsReady() then return nil end
    local d = LocalData:Get()
    if QuestUtil and type(QuestUtil.FindById) == "function" then
        local ok, q = pcall(function() return QuestUtil:FindById(d, qid) end)
        if ok and q then return q end
    end
    for _, c in ipairs({ d and d.Quests, d and d.ActiveQuests }) do
        if type(c) == "table" then
            for _, q in pairs(c) do
                if type(q) == "table" and (q.Id == qid or q.ID == qid) then return q end
            end
        end
    end
    return nil
end

task.spawn(function()
    while true do
        if not Config.autoGlobalIncentive then
            if _G.BGSI_Lite_GlobalIncentiveActive then
                _G.BGSI_Lite_GlobalIncentiveActive = false
                restoreHatchesAfterQuest()
            end
            task.wait(0.5)
            continue
        end
        if _G.BGSI_Lite_GemGenieActive or _G.BGSI_Lite_SeasonActive then task.wait(0.5) continue end
        local quests = getGlobalIncentiveQuests()
        if #quests == 0 then
            _G.BGSI_Lite_GlobalIncentiveActive = false
            restoreHatchesAfterQuest()
            task.wait(3)
            continue
        end
        local hasIncomplete = false
        for _, q in ipairs(quests) do
            for _, ti in ipairs(orderedTaskIndices(q.Tasks)) do
                local td = q.Tasks[ti]
                if type(td) == "table" then
                    local req = getTaskRequirement(td)
                    local prog = getTaskProgress(q, ti)
                    if prog < req then hasIncomplete = true; break end
                end
            end
            if hasIncomplete then break end
        end
        if not hasIncomplete then
            _G.BGSI_Lite_GlobalIncentiveActive = false
            restoreHatchesAfterQuest()
            task.wait(3)
            continue
        end
        _G.BGSI_Lite_GlobalIncentiveActive = true
        pauseHatchesForQuest()
        for _, q in ipairs(quests) do
            if not Config.autoGlobalIncentive then break end
            if _G.BGSI_Lite_GemGenieActive or _G.BGSI_Lite_SeasonActive then break end
            local qid = q.Id or q.ID
            for _, ti in ipairs(orderedTaskIndices(q.Tasks)) do
                if not Config.autoGlobalIncentive then break end
                if _G.BGSI_Lite_GemGenieActive or _G.BGSI_Lite_SeasonActive then break end
                local td = q.Tasks[ti]
                if type(td) == "table" then
                    local req = getTaskRequirement(td)
                    local prog = getTaskProgress(q, ti)
                    if prog < req then
                        local shouldContinue = function()
                            return Config.autoGlobalIncentive and not _G.BGSI_Lite_GemGenieActive and not _G.BGSI_Lite_SeasonActive
                        end
                        local getQuest = function() return findGlobalIncentiveQuestById(qid) end
                        if taskTypeLooksLikeCollect(td) then
                            runCollectTaskLoop(getQuest, ti, req, shouldContinue, collectCurrencyKey(td))
                        elseif looksLikeHatch(td) then
                            runHatchTaskLoop(getQuest, ti, req, shouldContinue)
                        elseif looksLikeBubble(td) then
                            runBubbleTaskLoop(getQuest, ti, req, shouldContinue)
                        else
                            task.wait(0.5)
                        end
                    end
                end
            end
        end
        task.wait(0.5)
    end
end)

-- ============================================================
-- Shrines tab
-- ============================================================
do
    ShrineTab:AddSection("Dream Fountain")
    ShrineTab:AddToggle("DreamShrine", {
        Title = "Auto Dreamer Fountain",
        Default = Config.DreamerShrineEnabled,
        Callback = function(v) Config.DreamerShrineEnabled = v; saveConfig() end,
    })
    ShrineTab:AddInput("DreamShrineAmount", {
        Title = "Amount",
        Default = tostring(Config.DreamerShrineAmount),
        Placeholder = "1-20",
        Numeric = true,
        Callback = function(v)
            local n = tonumber(v)
            if n then Config.DreamerShrineAmount = math.clamp(math.floor(n), 1, 20); saveConfig() end
        end,
    })

    ShrineTab:AddSection("Bubble Shrine")
    local potionTypes = { "Lucky", "Mythic", "Speed", "Tickets", "Coins" }
    local levels = { "1", "2", "3", "4", "5" }
    ShrineTab:AddDropdown("ShrinePotion", {
        Title = "Potion",
        Values = potionTypes,
        Default = Config.shrinePotion,
        Multi = false,
        Callback = function(v) Config.shrinePotion = v; saveConfig() end,
    })
    ShrineTab:AddDropdown("ShrineLevel", {
        Title = "Level",
        Values = levels,
        Default = tostring(Config.shrineLevel),
        Multi = false,
        Callback = function(v) Config.shrineLevel = tonumber(v) or 1; saveConfig() end,
    })
    ShrineTab:AddInput("ShrineAmount", {
        Title = "Amount",
        Default = tostring(Config.shrineAmount),
        Placeholder = "0-1000",
        Numeric = true,
        Callback = function(v)
            local n = tonumber(v)
            if n then Config.shrineAmount = math.clamp(math.floor(n), 0, 1000); saveConfig() end
        end,
    })
    ShrineTab:AddToggle("AutoShrine", {
        Title = "Auto Donate to Bubble Shrine",
        Default = Config.shrineAuto,
        Callback = function(v) Config.shrineAuto = v; saveConfig() end,
    })
end

-- Shrine loops
task.spawn(function()
    while true do
        if Config.DreamerShrineEnabled then
            pcall(function()
                remotefunction:InvokeServer("DonateToDreamerShrine", Config.DreamerShrineAmount or 1)
            end)
        end
        task.wait(5)
    end
end)
task.spawn(function()
    while true do
        if Config.shrineAuto then
            pcall(function()
                remotefunction:InvokeServer("DonateToShrine", {
                    Level = Config.shrineLevel,
                    Type = "Potion",
                    Name = Config.shrinePotion,
                    Amount = Config.shrineAmount,
                })
            end)
        end
        task.wait(5)
    end
end)

-- ============================================================
-- Webhook tab
-- ============================================================
local function parseThreshold(s)
    if not s or s == "" then return nil end
    local cleaned = string.upper(s):gsub("%s+", ""):gsub(",", "")
    local n, suffix = cleaned:match("^(%d+%.?%d*)([KMBTQ]?)$")
    if not n then return nil end
    local num = tonumber(n)
    if not num then return nil end
    if suffix == "K" then return num * 1e3 end
    if suffix == "M" then return num * 1e6 end
    if suffix == "B" then return num * 1e9 end
    if suffix == "T" then return num * 1e12 end
    if suffix == "Q" then return num * 1e15 end
    return num
end
local function parseWebhookURLs(s)
    local urls = {}
    if not s or s == "" then return urls end
    for u in string.gmatch(s, "([^,]+)") do
        u = u:match("^%s*(.-)%s*$")
        if u and u ~= "" then table.insert(urls, u) end
    end
    return urls
end
local function formatNumber(n)
    n = tonumber(n) or 0
    local suffixes = { "", "K", "M", "B", "T", "Q" }
    local idx = 1
    while n >= 1000 and idx < #suffixes do n = n / 1000; idx = idx + 1 end
    return string.format("%.1f%s", n, suffixes[idx])
end
local function formatCommas(n)
    n = tonumber(n) or 0
    local s = tostring(math.floor(n))
    while true do
        local r
        s, r = s:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
        if r == 0 then break end
    end
    return s
end
local statEmojis = {
    Bubbles = "🟣", Coins = "🪙", Gems = "💎",
    Snowflakes = "❄️", CircusTickets = "🎟️", GameTickets = "🎫",
    Tickets = "🎫", Pearls = "⚪", Clovers = "🍀",
}

local _StatsUtilMod, _WorldUtilMod
pcall(function() _StatsUtilMod = require(ReplicatedStorage.Shared.Utils.Stats.StatsUtil) end)
pcall(function() _WorldUtilMod = require(ReplicatedStorage.Shared.Utils.WorldUtil) end)

local function fmtLuckMult(n)
    if type(n) ~= "number" or n ~= n then return "—" end
    if math.abs(n) >= 1000 then return "x" .. formatNumber(n) end
    return "x" .. string.format("%.4g", n)
end

local function getPlayerCurrencies()
    local out = {
        Coins = 0, Gems = 0, Pearls = 0, Tickets = 0,
        LuckDisplay = "—", SecretLuckDisplay = "—", InfinityLuckDisplay = "—",
    }
    pcall(function()
        if not LocalData:IsReady() then return end
        local d = LocalData:Get() or {}
        out.Coins = tonumber(d.Coins) or 0
        out.Gems = tonumber(d.Gems) or 0
        out.Pearls = tonumber(d.Pearls) or 0
        out.Tickets = tonumber(d.Tickets or d.GameTickets or d.CircusTickets) or 0

        local world = "The Overworld"
        if _WorldUtilMod and type(_WorldUtilMod.GetPlayerWorld) == "function" then
            pcall(function() world = _WorldUtilMod:GetPlayerWorld(player) or world end)
        end
        if _StatsUtilMod then
            pcall(function()
                if type(_StatsUtilMod.GetLuckMultiplier) == "function" then
                    local m = _StatsUtilMod:GetLuckMultiplier(player, d, world, true)
                    if type(m) == "number" and m == m then
                        out.LuckDisplay = string.format("+%.2f%%", (m - 1) * 100)
                    end
                end
            end)
            pcall(function()
                if type(_StatsUtilMod.GetSecretLuck) == "function" then
                    local s = _StatsUtilMod:GetSecretLuck(d, nil)
                    if type(s) == "number" then out.SecretLuckDisplay = fmtLuckMult(s) end
                end
            end)
            pcall(function()
                if type(_StatsUtilMod.GetInfinityLuck) == "function" then
                    local eggArg = (world == "Christmas World") and "Aurora Egg" or nil
                    local inf = _StatsUtilMod:GetInfinityLuck(d, eggArg)
                    if type(inf) == "number" then out.InfinityLuckDisplay = fmtLuckMult(inf) end
                end
            end)
        end
    end)
    return out
end

local function getLeaderstats()
    local out = { BubblesBlown = 0, EggsHatched = 0 }
    if not player:FindFirstChild("leaderstats") then return out end
    for _, s in ipairs(player.leaderstats:GetChildren()) do
        if s.Name == "🟣 Bubbles" then out.BubblesBlown = s.Value
        elseif s.Name == "🥚 Hatches" then out.EggsHatched = s.Value end
    end
    return out
end
local function getEggsHatched() return getLeaderstats().EggsHatched end

-- Constants harvest for hidden pet chances (Pets data often shows 100 or 1 as a placeholder; Constants has the real odds).
local BGSI_ConstantsPetChances = {}
do
    local function chanceNum(v)
        if type(v) == "number" and v == v then return v end
        if type(v) == "string" then return tonumber(v) end
        return nil
    end
    local function harvest(tbl, depth, seen)
        if depth > 12 or type(tbl) ~= "table" or seen[tbl] then return end
        seen[tbl] = true
        local single = tbl.Pet; local ch = chanceNum(tbl.Chance)
        if type(single) == "string" and single ~= "" and ch then BGSI_ConstantsPetChances[single] = ch end
        if type(tbl.Pets) == "table" then
            for _, e in pairs(tbl.Pets) do
                if type(e) == "table" then
                    local pn = e.Pet or e.Name; local ec = chanceNum(e.Chance)
                    if type(pn) == "string" and pn ~= "" and ec then BGSI_ConstantsPetChances[pn] = ec end
                end
            end
        end
        if type(tbl.Name) == "string" and (type(single) ~= "string" or single == "") and ch then
            local t = tbl.Type
            if t ~= "Powerup" and t ~= "Potion" and t ~= "Egg" and type(tbl.Cost) ~= "table" then
                if not (type(tbl.Interval) == "number" and type(tbl.Pets) == "table") then
                    BGSI_ConstantsPetChances[tbl.Name] = ch
                end
            end
        end
        for _, v in pairs(tbl) do if type(v) == "table" then harvest(v, depth + 1, seen) end end
    end
    for _, getter in ipairs({
        function() return require(ReplicatedStorage.Shared.Framework.Constants) end,
        function() return require(ReplicatedStorage.Shared.Constants) end,
    }) do
        local ok, t = pcall(getter)
        if ok and type(t) == "table" then harvest(t, 0, {}) end
    end
end

local function resolveBaseChance(petName, petData)
    if type(petName) == "string" and BGSI_ConstantsPetChances[petName] then
        return BGSI_ConstantsPetChances[petName]
    end
    if type(petData) == "table" and type(petData.Chance) == "number" then return petData.Chance end
    return 100
end

local function getExistCount(displayName)
    if not remotefunction or type(displayName) ~= "string" or displayName == "" then return nil end
    local ok, res = pcall(function() return remotefunction:InvokeServer("GetExisting", displayName) end)
    if not ok then return nil end
    if type(res) == "number" then return math.floor(res) end
    if type(res) == "string" then
        local n = tonumber(res) or tonumber(res:match("%d+"))
        if n then return math.floor(n) end
    end
    return nil
end

local function buildExistLookupName(base, shiny, mythic, xl)
    if type(base) ~= "string" or base == "" then return base end
    local parts = {}
    if xl then table.insert(parts, "XL") end
    if shiny then table.insert(parts, "Shiny") end
    if mythic then table.insert(parts, "Mythic") end
    if #parts == 0 then return base end
    return table.concat(parts, " ") .. " " .. base
end

local function fetchPetImage(petData, shiny, mythic)
    local images = petData and petData.Images
    if type(images) ~= "table" then return nil end
    local selected
    if shiny and mythic then
        selected = images[4] or images.MythicShiny or images["Shiny Mythic"] or images.ShinyMythic
    elseif shiny then
        selected = images[2] or images.Shiny
    elseif mythic then
        selected = images[3] or images.Mythic
    else
        selected = images[1] or images.Normal
    end
    if not selected then
        for i = 1, 4 do if images[i] then selected = images[i]; break end end
        if not selected then selected = images.Normal or images.Shiny or images.Mythic end
    end
    if not selected then return nil end
    local assetId = string.match(tostring(selected), "rbxassetid://(%d+)") or tostring(tonumber(selected) or "")
    if assetId ~= "" then
        local url = ("https://thumbnails.roblox.com/v1/assets?assetIds=%s&size=420x420&format=Png"):format(assetId)
        local body
        pcall(function() body = game:HttpGet(url) end)
        if body and body ~= "" then
            local ok, data = pcall(function() return HttpService:JSONDecode(body) end)
            if ok and data and data.data and data.data[1] and data.data[1].imageUrl then
                return data.data[1].imageUrl
            end
        end
    end
    if type(selected) == "string" and selected:find("http") then return selected end
    return nil
end

local function fmtPercent(p)
    if p < 0.000001 then return string.format("%.2e%%", p)
    elseif p < 0.01 then return string.format("%.8f%%", p)
    else return string.format("%.6f%%", p) end
end
local function variantLabel(shiny, mythic, xl)
    if not shiny and not mythic and not xl then return nil end
    if xl then
        if shiny and mythic then return "SM XL" end
        if shiny then return "Shiny XL" end
        if mythic then return "Mythic XL" end
        return "XL"
    end
    if shiny and mythic then return "SM" end
    if shiny then return "Shiny" end
    if mythic then return "Mythic" end
    return nil
end
local function sanitizeDiscordUserId(raw)
    raw = tostring(raw or "")
    raw = raw:match("^%s*(.-)%s*$") or ""
    raw = raw:gsub("<@!?(%d+)>", "%1")
    raw = raw:gsub("%D", "")
    if #raw < 15 then return nil end
    return raw
end
local function sendDiscordWebhook(url, payload)
    local req = request or http_request or (syn and syn.request) or (http and http.request)
    if type(req) ~= "function" then return false end
    -- Inject ping mention if enabled.
    local mention = Config.webhookPingEnabled and sanitizeDiscordUserId(Config.webhookPingUserId) or nil
    if mention then
        payload.content = "<@" .. mention .. ">"
        payload.allowed_mentions = { users = { mention }, parse = {} }
    end
    local ok, res = pcall(function()
        return req({
            Url = url,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode(payload),
        })
    end)
    if ok and res then
        local sc = res.StatusCode
        if sc == nil or sc == 200 or sc == 204 then return true end
    end
    return false
end
local function sendWebhook(title, color, fields, imageUrl, titleHidden)
    if not Config.webhookEnabled or Config.webhookURL == "" then return end
    local urls = parseWebhookURLs(Config.webhookURL)
    for _, url in ipairs(urls) do
        local hide = Config.webhookHidePlayerName == true
        local useTitle = (hide and titleHidden) or title
        sendDiscordWebhook(url, {
            embeds = { {
                title = useTitle,
                color = color,
                fields = fields,
                thumbnail = imageUrl and { url = imageUrl } or nil,
                footer = { text = os.date("%Y-%m-%d %H:%M:%S") },
            } },
        })
        task.wait(0.1)
    end
end
_G.LiteSendWebhook = sendWebhook

do
    WebhookTab:AddToggle("WebhookEnabled", {
        Title = "Enable Webhook",
        Default = Config.webhookEnabled,
        Callback = function(v) Config.webhookEnabled = v; saveConfig() end,
    })
    WebhookTab:AddInput("WebhookURL", {
        Title = "Webhook URL(s)",
        Default = Config.webhookURL,
        Placeholder = "Discord webhook URL(s), comma-separated",
        Callback = function(v) Config.webhookURL = v; saveConfig() end,
    })
    WebhookTab:AddToggle("WebhookHideName", {
        Title = "Hide username in webhooks",
        Default = Config.webhookHidePlayerName,
        Callback = function(v) Config.webhookHidePlayerName = v; saveConfig() end,
    })

    WebhookTab:AddSection("Ping")
    WebhookTab:AddToggle("WebhookPingEnabled", {
        Title = "Ping User",
        Default = Config.webhookPingEnabled,
        Callback = function(v) Config.webhookPingEnabled = v; saveConfig() end,
    })
    WebhookTab:AddInput("WebhookPingUserId", {
        Title = "Discord User ID",
        Default = Config.webhookPingUserId,
        Placeholder = "right click user -> Copy User ID",
        Callback = function(v) Config.webhookPingUserId = v; saveConfig() end,
    })
end

    

-- Pet hatch webhook listener (matches main 1rzHub structure: User Info / Pet Info / Chance + image + exist count).
remote.OnClientEvent:Connect(function(command, data, ...)
    if not Config.webhookEnabled then return end
    local petsList
    if command == "HatchEgg" or command == "HatchPowerupEgg" or command == "ExclusiveHatch" then
        if type(data) == "table" then
            petsList = data.Pets or (data.Name and { data }) or nil
        end
    elseif command == "ItemsReceived" then
        if type(data) == "table" then
            petsList = {}
            for _, item in ipairs(data) do
                if type(item) == "table" and item.Type == "Pet" then table.insert(petsList, item) end
            end
            if #petsList == 0 then petsList = nil end
        end
    end
    if not petsList or type(petsList) ~= "table" or #petsList == 0 then return end

    for i, petInfo in ipairs(petsList) do
        if i > 1 then task.wait(0.1) end
        local name = petInfo.Name or (petInfo.Pet and petInfo.Pet.Name) or "Unknown"
        local petData = PetsData and PetsData[name] or {}
        local rarity = petData.Rarity or "Unknown"
        -- Lite always notifies on Secret only; Infinity uses the same path so it's allowed too.
        if rarity ~= "Secret" and rarity ~= "Infinity" then continue end
        local shiny = petInfo.Shiny or (petInfo.Pet and petInfo.Pet.Shiny) or false
        local mythic = petInfo.Mythic or (petInfo.Pet and petInfo.Pet.Mythic) or false
        local xl = petInfo.XL or (petInfo.Pet and petInfo.Pet.XL) or false
        if mythic and not (rarity == "Legendary" or rarity == "Secret" or rarity == "Infinity") then mythic = false end

        -- Color (matches main: special handling for Secret/Infinity + variant colors override)
        local color = 3447003
        if rarity == "Secret" then
            if shiny and mythic then color = 65280
            elseif mythic then color = 16753920
            elseif shiny then color = 16776960
            else color = 16711680 end
        elseif rarity == "Infinity" then
            if shiny and mythic then color = 65280
            elseif mythic then color = 16753920
            elseif shiny then color = 16776960
            else color = 10181046 end
        end

        -- User Info field
        local pdata = getPlayerCurrencies()
        local ls = getLeaderstats()
        local userInfo = string.format(
            "‌🟣 Current Bubbles: %s\n🪙 Coins: %s\n💎 Gems: %s\n🥚 Total Eggs: %s\n🍀 Luck: %s\n❓ Secret luck: %s\n♾️ Infinity luck: %s",
            formatNumber(ls.BubblesBlown),
            formatNumber(pdata.Coins),
            formatNumber(pdata.Gems),
            formatCommas(ls.EggsHatched),
            tostring(pdata.LuckDisplay),
            tostring(pdata.SecretLuckDisplay),
            tostring(pdata.InfinityLuckDisplay)
        )

        -- Pet Info: stat multiplier (xl=2x, shiny+mythic=2.25x, shiny=1.5x, mythic=1.75x)
        local mult = 1
        if xl then mult = 2 end
        if shiny and mythic then mult = mult * 2.25
        elseif shiny then mult = mult * 1.5
        elseif mythic then mult = mult * 1.75 end
        local statLines = {}
        if type(petData.Stats) == "table" then
            for k, v in pairs(petData.Stats) do
                local emoji = statEmojis[k] or ""
                table.insert(statLines, string.format("‌%s %s: +%s", emoji, k, formatCommas(math.floor(v * mult))))
            end
        end
        if petData.Tag and petData.Tag ~= "" then
            table.insert(statLines, "🏷️ Origins: " .. tostring(petData.Tag))
        end
        local petStatsStr = (#statLines > 0) and table.concat(statLines, "\n") or "No stats available"
        -- Exist count (variant-prefixed lookup) — appended to Pet Info field
        local lookup = buildExistLookupName(name, shiny, mythic, xl)
        local exist = getExistCount(lookup)
        petStatsStr = petStatsStr .. "\n\nExist: " .. (exist and formatCommas(exist) or "—")

        -- Chance
        local baseChance = resolveBaseChance(name, petData)
        local baseMult = 100 / baseChance
        local variantMult = 1
        if shiny then variantMult = variantMult * 40 end
        if mythic then variantMult = variantMult * 100 end
        if xl then variantMult = variantMult * 400 end
        local finalMult = baseMult * variantMult
        local finalPct = (1 / finalMult) * 100
        local normalOneIn = math.floor(baseMult)
        local normalPct = (1 / baseMult) * 100
        local basePart = string.format("Base: 1/%s (%s)", formatCommas(normalOneIn), fmtPercent(normalPct))
        local chanceText = basePart
        if variantMult > 1 then
            local vLab = variantLabel(shiny, mythic, xl) or "Variant"
            chanceText = string.format("%s | %s: 1/%s (%s)", basePart, vLab, formatCommas(math.floor(finalMult)), fmtPercent(finalPct))
        end

        local imageUrl = fetchPetImage(petData, shiny, mythic)

        -- Display rarity (Celestial / Infinity override)
        local displayRarity = rarity
        if petData.Celestial == true then displayRarity = "Celestial"
        elseif petData.Infinity == true then displayRarity = "Infinity" end

        local variantTitle = variantLabel(shiny, mythic, xl) or ""
        local function titleFor(who)
            if variantTitle ~= "" then
                return string.format("%s hatched a %s \"%s\" %s", who, variantTitle, displayRarity, name)
            end
            return string.format("%s hatched a \"%s\" %s", who, displayRarity, name)
        end
        local titleShow = titleFor(player.Name)
        local titleHide = titleFor("Player")

        sendWebhook(titleShow, color, {
            { name = "User Info", value = userInfo, inline = false },
            { name = "Pet Info", value = petStatsStr, inline = false },
            { name = "Chance", value = chanceText, inline = false },
        }, imageUrl, titleHide)
    end
end)

-- ============================================================
-- Rebirth tab
-- ============================================================
do
    local variantOptions = { "Normal", "Shiny", "Mythic", "Shiny Mythic" }
    local function normalizeVariants(raw)
        local out, seen = {}, {}
        local function add(v)
            if type(v) ~= "string" then return end
            for _, opt in ipairs(variantOptions) do
                if string.lower(opt) == string.lower(v) and not seen[opt] then
                    seen[opt] = true; table.insert(out, opt)
                end
            end
        end
        if type(raw) == "table" then
            for k, v in pairs(raw) do
                if type(k) == "number" then add(v)
                elseif v == true then add(k)
                elseif type(v) == "string" then add(v) end
            end
        elseif type(raw) == "string" then add(raw) end
        if #out == 0 then add("Normal") end
        return out
    end
    Config.RebirthVariants = normalizeVariants(Config.RebirthVariants)

    RebirthTab:AddInput("RebirthPet", {
        Title = "Pet Name(s)",
        Default = Config.RebirthPetName,
        Placeholder = "e.g. Man Face Lord",
        Callback = function(v) Config.RebirthPetName = v; saveConfig() end,
    })
    RebirthTab:AddInput("AdminRebirthPet", {
        Title = "Admin Pet Name(s)",
        Default = Config.AdminRebirthPetName,
        Placeholder = "e.g. Man Face Lord",
        Callback = function(v) Config.AdminRebirthPetName = v; saveConfig() end,
    })
    RebirthTab:AddDropdown("RebirthVariants", {
        Title = "Variant(s)",
        Values = variantOptions,
        Default = Config.RebirthVariants,
        Multi = true,
        Callback = function(v)
            Config.RebirthVariants = normalizeVariants(v)
            saveConfig()
        end,
    })
    RebirthTab:AddToggle("RebirthMachine", {
        Title = "Auto Rebirth Machine",
        Default = Config.RebirthMachineEnabled,
        Callback = function(v) Config.RebirthMachineEnabled = v; saveConfig() end,
    })
    RebirthTab:AddToggle("AdminRebirthMachine", {
        Title = "Auto Admin Rebirth Machine",
        Default = Config.AdminRebirthMachineEnabled,
        Callback = function(v) Config.AdminRebirthMachineEnabled = v; saveConfig() end,
    })
end

local function parsePetNames(s)
    local out = {}
    if not s or s == "" then return out end
    for n in string.gmatch(s, "([^,]+)") do
        local t = n:match("^%s*(.-)%s*$")
        if t and t ~= "" then table.insert(out, t) end
    end
    return out
end
local function fetchVariantPets(variant, petNameString)
    local out = {}
    local ok, d = pcall(function() return LocalData:Get() end)
    if not ok or type(d) ~= "table" or type(d.Pets) ~= "table" then return out end
    local lookup = {}
    for _, n in ipairs(parsePetNames(petNameString)) do lookup[n] = true end
    for _, p in ipairs(d.Pets) do
        if p.Id and lookup[p.Name] then
            local v = "Normal"
            local s = p.Shiny == true; local m = p.Mythic == true
            if s and m then v = "Shiny Mythic" elseif s then v = "Shiny" elseif m then v = "Mythic" end
            if v == variant then table.insert(out, p.Id) end
        end
    end
    return out
end
local function performRebirth(requiredCount, petNameString, actionName)
    local pets
    for _, variant in ipairs(Config.RebirthVariants or { "Normal" }) do
        local ids = fetchVariantPets(variant, petNameString)
        if #ids >= requiredCount then pets = ids; break end
    end
    if not pets then return end
    local selected = {}; local used = {}
    while #selected < requiredCount do
        local pick = pets[math.random(1, #pets)]
        if not used[pick] then used[pick] = true; table.insert(selected, pick) end
    end
    pcall(function() remotefunction:InvokeServer(actionName, selected) end)
end
local function isRebirthCooldownReady()
    local ok, d = pcall(function() return LocalData:Get() end)
    if not ok or not d then return false end
    local nxt = d.NextRebirthMachineUse
    if type(nxt) == "table" then nxt = nxt.NextRebirthMachineUse or nxt.Next or nxt.Value end
    if not nxt then return true end
    return TimeUtil.now() >= nxt
end
local function isAdminRebirthCooldownReady()
    local ok, d = pcall(function() return LocalData:Get() end)
    if not ok or not d then return false end
    local nxt = d.NextAdminRebirthMachineUse
    if type(nxt) == "table" then nxt = nxt.NextAdminRebirthMachineUse or nxt.Next or nxt.Value end
    if not nxt then return true end
    return TimeUtil.now() >= nxt
end
local function isAdminMachineAvailable()
    local ok, found = pcall(function()
        return workspace:FindFirstChild("AdminRebirthMachine", true) ~= nil
    end)
    return ok and found
end

task.spawn(function()
    while true do
        if Config.RebirthMachineEnabled and isRebirthCooldownReady() then
            performRebirth(5, Config.RebirthPetName, "UseRebirthMachine")
        end
        task.wait(0.5)
    end
end)
task.spawn(function()
    while true do
        if Config.AdminRebirthMachineEnabled and isAdminMachineAvailable() and isAdminRebirthCooldownReady() then
            performRebirth(4, Config.AdminRebirthPetName, "UseAdminRebirthMachine")
        end
        task.wait(0.5)
    end
end)
end
-- ============================================================
-- Other tab (optimization)
-- ============================================================
do
    OtherTab:AddSection("Performance")

    OtherTab:AddToggle("DisableRendering", {
        Title = "Disable 3D Rendering (AFK / save GPU)",
        Default = Config.disableRendering,
        Callback = function(v)
            Config.disableRendering = v
            saveConfig()
            pcall(function() RunService:Set3dRenderingEnabled(not v) end)
        end,
    })
    pcall(function() RunService:Set3dRenderingEnabled(not Config.disableRendering) end)
end

-- ============================================================
-- Done
-- ============================================================
Fluent:Notify({ Title = "1rzHub Lite", Content = "Loaded.", Duration = 3 })
