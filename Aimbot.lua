-- 🚀 Initialisation des services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterPlayer = game:GetService("StarterPlayer")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- 🔒 Vue première personne forcée
StarterPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson

-- 🫥 Cache les bras
LocalPlayer.CharacterAdded:Connect(function(char)
    RunService.RenderStepped:Connect(function()
        for _, part in ipairs({"Left Arm", "Right Arm", "LeftHand", "RightHand"}) do
            local limb = char:FindFirstChild(part)
            if limb then
                limb.LocalTransparencyModifier = 1
            end
        end
    end)
end)

-- 📐 FOV ellipse (radius visuel ~300)
local FOV_WIDTH, FOV_HEIGHT = 300, 300
local TARGET_PART = "Head"

-- 🔲 Dessin ellipse
local fovEllipse = Drawing.new("Quad")
fovEllipse.Thickness = 2
fovEllipse.Filled = false
fovEllipse.Color = Color3.new(0, 1, 0)
fovEllipse.Transparency = 1
fovEllipse.Visible = true

local function getScreenCenter()
    return Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end

local function updateFOVPosition()
    local center = getScreenCenter()
    local halfW, halfH = FOV_WIDTH / 2, FOV_HEIGHT / 2
    fovEllipse.PointA = center + Vector2.new(-halfW, -halfH)
    fovEllipse.PointB = center + Vector2.new(halfW, -halfH)
    fovEllipse.PointC = center + Vector2.new(halfW, halfH)
    fovEllipse.PointD = center + Vector2.new(-halfW, halfH)
end

RunService.RenderStepped:Connect(updateFOVPosition)

-- 📍 Test si cible dans l'ellipse
local function isInEllipse(point, center)
    local dx = point.X - center.X
    local dy = point.Y - center.Y
    return (dx * dx) / (FOV_WIDTH * FOV_WIDTH / 4) + (dy * dy) / (FOV_HEIGHT * FOV_HEIGHT / 4) <= 1
end

-- 🔎 Recherche la tête la plus proche dans l'ellipse
local function getClosestHead()
    local bestPart
    local minDist = math.huge
    local center = getScreenCenter()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild(TARGET_PART) then
            local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local head = plr.Character[TARGET_PART]
                local screenPoint, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen and isInEllipse(Vector2.new(screenPoint.X, screenPoint.Y), center) then
                    local dist = (Vector2.new(screenPoint.X, screenPoint.Y) - center).Magnitude
                    if dist < minDist then
                        bestPart, minDist = head, dist
                    end
                end
            end
        end
    end
    return bestPart
end

-- 🎯 Ciblage persistant
local lockedTarget = nil

local function updateLock()
    local center = getScreenCenter()
    if lockedTarget and lockedTarget.Parent then
        local screenPoint, onScreen = Camera:WorldToViewportPoint(lockedTarget.Position)
        if onScreen and isInEllipse(Vector2.new(screenPoint.X, screenPoint.Y), center) then
            return lockedTarget
        end
    end
    lockedTarget = getClosestHead()
    return lockedTarget
end

-- 🔫 Suivi lors du tir (optionnel)
local shooting = false
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        shooting = true
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        shooting = false
    end
end)

-- 🔁 Boucle principale : aimbot
RunService.RenderStepped:Connect(function()
    local targetHead = updateLock()
    if targetHead then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetHead.Position)
    end
end)

-- 🧼 Supprime l’ellipse si le script est retiré
CoreGui.AncestryChanged:Connect(function(_, parent)
    if not parent then
        fovEllipse:Remove()
    end
end)
