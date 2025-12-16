local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local box = remotes:WaitForChild("MysteryBoxEvent")
local spinreq = remotes:WaitForChild("SpinRequestEvent")
local spinpriz = remotes:WaitForChild("SpinWheelPrizeEvent")
local rebirth = remotes:WaitForChild("RebirthConfirmEvent")
local UpgradeEvent = remotes:WaitForChild("UpgradeEvent")
local AddValueEvent = remotes:FindFirstChild("AddValueEvent")

local Cash = LocalPlayer:WaitForChild("Cash")
local SpawnTier = LocalPlayer:WaitForChild("SpawnTier")
local MaxBlocks = LocalPlayer:WaitForChild("MaxBlocks")
local SpawnRate = LocalPlayer:WaitForChild("SpawnRate")
local AutoMerge = LocalPlayer:WaitForChild("AutoMerge")
local CashRate = LocalPlayer:WaitForChild("CashRate")
local LuckyMerge = LocalPlayer:WaitForChild("LuckyMerge")

-- levels
local MaxLevels = {
    SpawnTierLevel = 90,
    MaxBlocksLevel = 21,
    SpawnRateLevel = 30,
    AutoMergeLevel = 21,
    CashRateLevel = 25,
    LuckyMergeLevel = 41
}

local Upgrades = {
    {name = "SpawnTierLevel", value = SpawnTier, baseCost = 125, multiplier = 2},
    {name = "MaxBlocksLevel", value = MaxBlocks, baseCost = 600, multiplier = 3},
    {name = "SpawnRateLevel", value = SpawnRate, baseCost = 300, multiplier = 2.4},
    {name = "AutoMergeLevel", value = AutoMerge, baseCost = 100000000, multiplier = 4},
    {name = "CashRateLevel", value = CashRate, baseCost = 15000, multiplier = 3.4},
    {name = "LuckyMergeLevel", value = LuckyMerge, baseCost = 3000, multiplier = 5}
}

local Window = Rayfield:CreateWindow({
    Name = "chikiwaa v2",
    LoadingTitle = "chikiwaa script",
    LoadingSubtitle = "by Rsl",
})

local Tab = Window:CreateTab("autofarm", "rewind")
local purchasetab = Window:CreateTab("purchase")
local misc = Window:CreateTab("misc", "settings")

local boxfarming = false
local spinfarming = false
local rebirthfarming = false
local autobuy = false
local targetPlayer = nil

-- Logic Functions
local function calculateCost(baseCost, multiplier, level)
    local cost = baseCost * multiplier ^ (level - 1)
    if baseCost == 125 then
        return math.floor(cost + 0.5)
    end
    return math.floor((cost + 0.5) / 10) * 10
end

local function tryBuyUpgrade(upgrade)
    local currentLevel = upgrade.value.Value
    local maxLevel = MaxLevels[upgrade.name]
    if currentLevel >= maxLevel then return false end

    local cost = calculateCost(upgrade.baseCost, upgrade.multiplier, currentLevel)
    if Cash.Value >= cost then
        UpgradeEvent:FireServer(upgrade.name, currentLevel + 1, cost)
        return true
    end
    return false
end

-- Toggles
Tab:CreateToggle({
    Name = "Mystery Box Farm",
    CurrentValue = false,
    Flag = "Toggle1",
    Callback = function(Value)
        boxfarming = Value
        task.spawn(function()
            while boxfarming do
                box:FireServer()
                task.wait(0.5)
            end
        end)
    end,
})

Tab:CreateToggle({
    Name = "Spin Farm",
    CurrentValue = false,
    Flag = "Toggle2",
    Callback = function(Value)
        spinfarming = Value
        task.spawn(function()
            while spinfarming do
                spinreq:FireServer()
                task.wait(0.5)
                spinpriz:FireServer(1)
                task.wait(1)
            end
        end)
    end,
})

Tab:CreateToggle({
    Name = "Rebirth Farm",
    CurrentValue = false,
    Flag = "Toggle3",
    Callback = function(Value)
        rebirthfarming = Value
        task.spawn(function()
            local rebritharg = {0, 50000, 150}
            while rebirthfarming do
                 rebirth:FireServer(unpack(rebritharg))
                task.wait(0.5)
            end
        end)
    end,
})

Tab:CreateButton({
    Name = "Infinite Money (If Vulnerable)",
    Callback = function()
        if AddValueEvent then
            AddValueEvent:FireServer("Cash", 1e30)
        else
            Rayfield:Notify({Title = "Error", Content = "AddValueEvent not found in ReplicatedStorage", Duration = 5})
        end
    end,
})

-- Purchase Tab
purchasetab:CreateToggle({
    Name = "Auto Buy All Upgrades",
    CurrentValue = false,
    Flag = "AutoBuy",
    Callback = function(Value)
        autobuy = Value
        task.spawn(function()
            while autobuy do
                for _, upgrade in ipairs(Upgrades) do
                    if not autobuy then break end
                    tryBuyUpgrade(upgrade)
                end
                task.wait(0.5)
            end
        end)
    end,
})

-- Misc Tab
local playerList = {}
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then table.insert(playerList, p.Name) end
end

misc:CreateDropdown({
    Name = "Select Player",
    Options = playerList,
    CurrentOption = "none",
    Flag = "tpdd",
    Callback = function(selectedName)
        targetPlayer = Players:FindFirstChild(selectedName)
    end,
})

misc:CreateButton({
    Name = "Teleport to Player",
    Callback = function()
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame
        else
            Rayfield:Notify({Title = "TP Error", Content = "Target or your character is invalid", Duration = 3})
        end
    end
})
