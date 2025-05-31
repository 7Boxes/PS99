local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = {
    WalkSpeed = 16,
    ShootDelay = 0.5,
    Waypoints = {
        {
            Vector3.new(1373, 17, -22454),
            Vector3.new(1428, 17, -22457),
            Vector3.new(1383, 17, -22485)
        },
        {
            Vector3.new(1382, 17, -22417),
            Vector3.new(1470, 17, -22416)
        },
        {
            Vector3.new(1471, 17, -22485),
            Vector3.new(1428, 17, -22457)
        },
        {
            Vector3.new(1504, 17, -22487),
            Vector3.new(1508, 17, -22420)
        }
    },
    ShootArgs = {
        "BasketballEvent",
        "InfiniteShoot",
        1
    }
}

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")
local Network = ReplicatedStorage:WaitForChild("Network")
local Remote = Network:WaitForChild("Instancing_InvokeCustomFromClient")

humanoid.WalkSpeed = Config.WalkSpeed

local function walkTo(targetPosition)
    local beam = Instance.new("Part")
    beam.Size = Vector3.new(1, 1, (rootPart.Position - targetPosition).Magnitude)
    beam.Position = (rootPart.Position + targetPosition)/2
    beam.Anchored = true
    beam.CanCollide = false
    beam.Transparency = 0.7
    beam.Color = Color3.new(1, 0, 0)
    beam.Parent = workspace
    game:GetService("Debris"):AddItem(beam, 5)
    
    local direction = (targetPosition - rootPart.Position).Unit
    rootPart.CFrame = CFrame.lookAt(rootPart.Position, rootPart.Position + direction * Vector3.new(1,0,1))
    
    humanoid:MoveTo(targetPosition)
    
    local startTime = os.time()
    while (rootPart.Position - targetPosition).Magnitude > 4 and os.time() - startTime < 30 do
        Remote:InvokeServer(unpack(Config.ShootArgs))
        task.wait(Config.ShootDelay)
    end
    
    task.wait(0.5)
end

walkTo(Config.Waypoints[1][1])

while true do
    for i, path in ipairs(Config.Waypoints) do
        walkTo(path[2])
        walkTo(path[1])
    end
end
