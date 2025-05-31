local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = {
    WalkSpeed = 16,
    ShootDelay = 0.5,
    InitialPosition = Vector3.new(180, 17, -148),
    TweenTarget = Vector3.new(1361, 17, -22451),
    TweenDuration = 5,
    Waypoints = {
        Vector3.new(1373, 17, -22454),
        Vector3.new(1428, 17, -22457),
        Vector3.new(1383, 17, -22485),
        Vector3.new(1382, 17, -22417),
        Vector3.new(1470, 17, -22416),
        Vector3.new(1471, 17, -22485),
        Vector3.new(1504, 17, -22487),
        Vector3.new(1508, 17, -22420)
    }
}

local function SmoothTeleport(character, targetPosition)
    local rootPart = character:WaitForChild("HumanoidRootPart")
    local tweenInfo = TweenInfo.new(
        Config.TweenDuration,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.InOut
    )
    
    local tween = TweenService:Create(rootPart, tweenInfo, {CFrame = CFrame.new(targetPosition)})
    tween:Play()
    tween.Completed:Wait()
end

local function Initialize()
    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local rootPart = character:WaitForChild("HumanoidRootPart")
    
    humanoid.WalkSpeed = Config.WalkSpeed
    
    local function walkTo(targetPosition)
        local direction = (targetPosition - rootPart.Position).Unit
        rootPart.CFrame = CFrame.lookAt(rootPart.Position, rootPart.Position + direction * Vector3.new(1,0,1))
        humanoid:MoveTo(targetPosition)
        
        local startTime = os.time()
        while (rootPart.Position - targetPosition).Magnitude > 4 and os.time() - startTime < 30 do
            RunService.Heartbeat:Wait()
        end
    end
    
    walkTo(Config.InitialPosition)
    task.wait(5)
    
    SmoothTeleport(character, Config.TweenTarget)
    task.wait(1)
    
    return character, humanoid, rootPart
end

local function MainLoop(character, humanoid, rootPart)
    local Remote = ReplicatedStorage:WaitForChild("Network"):WaitForChild("Instancing_InvokeCustomFromClient")

    local function walkTo(targetPosition)
        local direction = (targetPosition - rootPart.Position).Unit
        rootPart.CFrame = CFrame.lookAt(rootPart.Position, rootPart.Position + direction * Vector3.new(1,0,1))
        humanoid:MoveTo(targetPosition)
        
        local startTime = os.time()
        while (rootPart.Position - targetPosition).Magnitude > 4 and os.time() - startTime < 30 do
            Remote:InvokeServer("BasketballEvent", "InfiniteShoot", 1)
            task.wait(Config.ShootDelay)
        end
    end

    while true do
        for _, waypoint in ipairs(Config.Waypoints) do
            walkTo(waypoint)
        end
    end
end

local character, humanoid, rootPart = Initialize()
MainLoop(character, humanoid, rootPart)
