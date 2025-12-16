local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local box = remotes:WaitForChild("MysteryBoxEvent")
local spinreq = remotes:WaitForChild("SpinRequestEvent")si 
local spinpriz = remotes:WaitForChild("SpinWheelPrizeEvent")
local rebirth = remotes:WaitForChild("RebirthConfirmEvent")
local UpgradeEvent = remotes:WaitForChild("UpgradeEvent")
local AddValueEvent = remotes:FindFirstChild("AddValueEvent") -- optional
local Cash = LocalPlayer:WaitForChild("Cash")
local SpawnTier = LocalPlayer:WaitForChild("SpawnTier")
local MaxBlocks = LocalPlayer:WaitForChild("MaxBlocks")
local SpawnRate = LocalPlayer:WaitForChild("SpawnRate")
local AutoMerge = LocalPlayer:WaitForChild("AutoMerge")
local CashRate = LocalPlayer:WaitForChild("CashRate")
local LuckyMerge = LocalPlayer:WaitForChild("LuckyMerge")
local hrp = LocalPlayer.Character:WaitForChild("HumanoidRootPart")

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

-- window
local Window = Rayfield:CreateWindow({
    Name = "chikiwaa v2",
    LoadingTitle = "chikiwaa script",
    LoadingSubtitle = "by Rsl",
})

local Tab = Window:CreateTab("autofarm", "rewind")
local purchasetab = Window:CreateTab("purchase")


local boxfarming = false
local spinfarming = false
local rebirthfarming = false
local autobuy = false

--random bullshit
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

-- box
Tab:CreateToggle({
    Name = "mboxfarm",
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

-- spin
Tab:CreateToggle({
    Name = "spinfarm",
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

-- rebrith
Tab:CreateToggle({
    Name = "rebrithfarm",
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

-- infninite money
local moneyButton = Tab:CreateButton({
    Name = "infinite money",
    Callback = function()
        if AddValueEvent then
            AddValueEvent:FireServer("Cash", 1e30)
        end
    end,
})

-- buyall
local purchaseall = purchasetab:CreateButton({
    Name = "buyall",
    Callback = function()
        if autobuy then return end
        autobuy = true
        task.spawn(function()
            while autobuy do
                local didBuy = false
                for _, upgrade in ipairs(Upgrades) do
                    if tryBuyUpgrade(upgrade) then
                        didBuy = true
                        task.wait(0.05)
                    end
                end
                if not didBuy then break end
                task.wait(0.1)
            end
            autobuy = false
        end)
    end,
})

misc = Window:CreateTab("misc")
tp = misc:CreateDropdown({
    Name = "player tp",
    Options = (function()
         t = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                table.insert(t, p.Name)
            end
        end
        return t
    end)(),
    CurrentOption = "none",
    Flag = "tpdd",
    Callback = function(selectedName)
        target = Players:FindFirstChild(selectedName)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            hrp.CFrame = target.Character.HumanoidRootPart.CFrame
        end
    end,
})
tpbut = misc:CreateButton({
    Name = "teleport",
    callback = function()
    hrp.CFrame = target.Character.HumanoidRootPart.CFrame
    end
})
return Rayfield



