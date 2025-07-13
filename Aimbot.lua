--[[
  BF HUB – Aimbot with Dynamic Camera Aim
  - Constant lock on head within radius
  - FOV forced to 80
  - Auto-rotate camera toward enemy head
  - First-person enforced
  - Discord link copied on startup
  - Confirmation message on successful load
--]]

-- Wait until game loads
repeat task.wait() until game:IsLoaded()

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Settings
local LOCK_RADIUS = 350
local TARGET = nil

-- Force first-person view with FOV 80
Camera.FieldOfView = 80
LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson

-- Copy Discord link
pcall(function()
    setclipboard("https://discord.gg/NpEt7Zc6")
end)

-- Notify success
pcall(function()
    game.StarterGui:SetCore("SendNotification", {
        Title = "BF HUB",
        Text  = "Script loaded successfully ✅ Discord copied",
        Duration = 5
    })
end)

-- Find closest head in radius
local function getLockedTarget()
    local closest, minDist = nil, math.huge
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local head = plr.Character:FindFirstChild("Head")
            local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
            if head and humanoid and humanoid.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local point2D = Vector2.new(screenPos.X, screenPos.Y)
                    local dist = (point2D - center).Magnitude
                    if dist < LOCK_RADIUS and dist < minDist then
                        closest = head
                        minDist = dist
                    end
                end
            end
        end
    end

    return closest
end

-- Lock camera constantly to head
RunService.RenderStepped:Connect(function()
    TARGET = getLockedTarget() or TARGET
    if TARGET and TARGET.Parent then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, TARGET.Position)
    else
        TARGET = nil
    end
end)
