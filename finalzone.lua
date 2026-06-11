-- this script will get you to the final zone, you'll need to manually switch worlds.
-- send your new bot a few stat pets as the script only farms.
-- this script wont open eggs or upgrade anything, but it will get a decent loadout to final zone.
-- this is barebones, not the fastest, made for others to build upon.

-- configs (this script is heavily condensed)
local rs, ws, lp = game:GetService("ReplicatedStorage"), game:GetService("Workspace"), game:GetService("Players").LocalPlayer
local ts = game:GetService("TweenService")
local map = ws:WaitForChild("Map", 5)
local things = ws:WaitForChild("__THINGS", 5)
local breakables, orbs = things:WaitForChild("Breakables", 5), things:WaitForChild("Orbs", 5)
local main = things:WaitForChild("ZoneEggs", 5):WaitForChild("Main", 5)
local eggs = rs:WaitForChild("__DIRECTORY", 5):WaitForChild("Eggs", 5):WaitForChild("Zone Eggs", 5)
local net = rs:WaitForChild("Network", 5)

while task.wait(1) do
    local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    local hum = lp.Character and lp.Character:FindFirstChildWhichIsA("Humanoid")
    if not hrp or not hum then continue end

    local lowZ, highZ = math.huge, 0
    for _, z in ipairs(map:GetChildren()) do
        local n = tonumber(string.match(z.Name, "^(%d+)%s*|"))
        if n then
            highZ = math.max(highZ, n)
            local hud = z:FindFirstChild("INTERACT") and z.INTERACT:FindFirstChild("Gate") and z.INTERACT.Gate:FindFirstChild("GateHUD")
            if hud and hud:IsA("SurfaceGui") and hud.Enabled then lowZ = math.min(lowZ, n) end
        end
    end

    local bestZ = (lowZ == math.huge) and highZ or (lowZ - 1)
    local aZone, nZone = nil, nil
    for _, z in ipairs(map:GetChildren()) do 
        local n = tonumber(string.match(z.Name, "^(%d+)%s*|"))
        if n == bestZ then aZone = z end
        if n == lowZ then nZone = z end
    end

    local bz = aZone and aZone:FindFirstChild("INTERACT") and aZone.INTERACT:FindFirstChild("BREAK_ZONES") and aZone.INTERACT.BREAK_ZONES:FindFirstChild("BREAK_ZONE")
    
    local tEgg, eName = (bestZ == 1 and main:FindFirstChild("1 - Egg Capsule")), nil
    if bestZ > 1 and bz and bz:IsA("BasePart") then
        local d = math.huge
        for _, c in ipairs(main:GetChildren()) do
            local p = (c:IsA("Model") and c.PrimaryPart and c.PrimaryPart.Position) or (c:IsA("BasePart") and c.Position) or (c:FindFirstChildWhichIsA("BasePart", true) and c:FindFirstChildWhichIsA("BasePart", true).Position)
            if p and (bz.Position - p).Magnitude < d then d, tEgg = (bz.Position - p).Magnitude, c end
        end
    end

    if tEgg then
        local id = string.match(tEgg.Name, "^(%d+)%s*-")
        if id then
            local pref = id .. " | "
            for _, i in ipairs(eggs:GetDescendants()) do if string.sub(i.Name, 1, #pref) == pref then eName = string.sub(i.Name, #pref + 1); break end end
        end
    end

    local hasCost = tEgg and tEgg:FindFirstChild("PriceHUD") and tEgg.PriceHUD:FindFirstChild("PriceHUD") and tEgg.PriceHUD.PriceHUD:FindFirstChild("Gold Coins") and tEgg.PriceHUD.PriceHUD["Gold Coins"]:FindFirstChild("Amount")
    
    if tEgg and eName and not hasCost then
        local tCF = (tEgg:IsA("Model") and tEgg.PrimaryPart and tEgg.PrimaryPart.CFrame) or (tEgg:IsA("BasePart") and tEgg.CFrame) or (tEgg:FindFirstChildWhichIsA("BasePart", true) and tEgg:FindFirstChildWhichIsA("BasePart", true).CFrame)
        if tCF then hrp.CFrame = tCF + Vector3.new(0, 5, 0) end
        if net:FindFirstChild("Eggs_RequestUnlock") then pcall(function() net.Eggs_RequestUnlock:InvokeServer(eName) end) end
    end

    local nHUD = nZone and nZone:FindFirstChild("INTERACT") and nZone.INTERACT:FindFirstChild("Gate") and nZone.INTERACT.Gate:FindFirstChild("GateHUD")
    local nStr = nZone and string.match(nZone.Name, "|%s*(.+)$")

    if nHUD and nHUD:FindFirstChild("Buy") and nHUD.Buy:FindFirstChild("GreyGradient") and bz then
        hrp.CFrame = bz.CFrame + Vector3.new(0, 5, 0)
        
        while nHUD.Buy:FindFirstChild("GreyGradient") do
            local bList = {}
            for _, b in ipairs(breakables:GetChildren()) do
                local bp = b:FindFirstChildWhichIsA("BasePart", true)
                if bp then table.insert(bList, {o = b, d = (hrp.Position - bp.Position).Magnitude}) end
            end
            
            table.sort(bList, function(a, b) return a.d < b.d end)
            
            for i = 1, math.min(20, #bList) do
                if net:FindFirstChild("Breakables_PlayerDealDamage") then pcall(function() net.Breakables_PlayerDealDamage:FireServer(bList[i].o.Name) end) end
            end
            
            for _, o in ipairs(orbs:GetChildren()) do
                if not nHUD.Buy:FindFirstChild("GreyGradient") then break end
                local op = o:FindFirstChildWhichIsA("BasePart", true) or (o:IsA("BasePart") and o)
                if op then
                    local os = bz.CFrame:ToObjectSpace(op.CFrame)
                    if math.abs(os.X) <= bz.Size.X/2 and math.abs(os.Z) <= bz.Size.Z/2 then
                        local tw = ts:Create(hrp, TweenInfo.new((hrp.Position - op.Position).Magnitude / hum.WalkSpeed, Enum.EasingStyle.Linear), {CFrame = op.CFrame})
                        tw:Play(); tw.Completed:Wait()
                    end
                end
            end
            task.wait(0.1)
        end
        
        if nStr and net:FindFirstChild("Zones_RequestPurchase") then pcall(function() net.Zones_RequestPurchase:InvokeServer(nStr) end) end
    end
end
