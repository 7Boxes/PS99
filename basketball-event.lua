-- Basketball Event Script for PS99
-- Version: 1.2
-- Auto-execute compatible
-- GitHub: https://github.com/7Boxes/PS99

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Configuration
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

-- Wait for character to load
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Core Functions
local function SmoothTeleport(targetPosition)
    local tweenInfo = TweenInfo.new(
        Config.TweenDuration,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.InOut
    )
    local tween = TweenService:Create(rootPart, tweenInfo, {CFrame = CFrame.new(targetPosition)})
    tween:Play()
    tween.Completed:Wait()
end

local function WalkTo(targetPosition)
    local direction = (targetPosition - rootPart.Position).Unit
    rootPart.CFrame = CFrame.lookAt(rootPart.Position, rootPart.Position + direction * Vector3.new(1,0,1))
    humanoid:MoveTo(targetPosition)
    
    local startTime = os.time()
    while (rootPart.Position - targetPosition).Magnitude > 4 and os.time() - startTime < 30 do
        RunService.Heartbeat:Wait()
    end
end

-- Main Execution
humanoid.WalkSpeed = Config.WalkSpeed

-- Initialization Sequence
WalkTo(Config.InitialPosition)
task.wait(5)
SmoothTeleport(Config.TweenTarget)
task.wait(1)

-- Main Loop
local Remote = ReplicatedStorage:WaitForChild("Network"):WaitForChild("Instancing_InvokeCustomFromClient")

while true do
    for _, waypoint in ipairs(Config.Waypoints) do
        local direction = (waypoint - rootPart.Position).Unit
        rootPart.CFrame = CFrame.lookAt(rootPart.Position, rootPart.Position + direction * Vector3.new(1,0,1))
        humanoid:MoveTo(waypoint)
        
        local startTime = os.time()
        while (rootPart.Position - waypoint).Magnitude > 4 and os.time() - startTime < 30 do
            Remote:InvokeServer("BasketballEvent", "InfiniteShoot", 1)
            task.wait(Config.ShootDelay)
        end
    end
end
