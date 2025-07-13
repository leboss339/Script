-- 🚀 Initialisation des services
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui          = game:GetService("CoreGui")
local Camera           = workspace.CurrentCamera
local LocalPlayer      = Players.LocalPlayer

-- 📐 FOV circulaire (radius = 300)
local FOV_RADIUS = 300
local TARGET_PART = "Head"

-- ⚪ Création du cercle FOV blanc, semi-transparent
local fovCircle = Drawing.new("Circle")
fovCircle.Radius       = FOV_RADIUS
fovCircle.Filled       = true
fovCircle.Color        = Color3.new(1, 1, 1)
fovCircle.Transparency = 0.5
fovCircle.NumSides     = 64
fovCircle.Thickness    = 1
fovCircle.Visible      = true

local function getScreenCenter()
    return Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
end

RunService.RenderStepped:Connect(function()
    fovCircle.Position = getScreenCenter()
end)

local function isInCircle(point, center)
    return (point - center).Magnitude <= FOV_RADIUS
end

local function getClosestHead()
    local bestHead, minDist = nil, math.huge
    local center = getScreenCenter()

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local head     = plr.Character:FindFirstChild(TARGET_PART)
            local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
            if head and humanoid and humanoid.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                local screenPt = Vector2.new(screenPos.X, screenPos.Y)
                if onScreen and isInCircle(screenPt, center) then
                    local dist = (screenPt - center).Magnitude
                    if dist < minDist then
                        bestHead, minDist = head, dist
                    end
                end
            end
        end
    end

    return bestHead
end

-- 🔫 RemoteEvent pour le tir (remplace par ton propre événement)
local ShootEvent = workspace:WaitForChild("ShootEvent")

-- Détection du « shoot » sur PC ou mobile (touch à droite de l’écran)
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end

    local isPCClick    = input.UserInputType == Enum.UserInputType.MouseButton1
    local isMobileTap  = input.UserInputType == Enum.UserInputType.Touch
    local screenWidth  = Camera.ViewportSize.X

    if isPCClick or (isMobileTap and input.Position.X > screenWidth/2) then
        local targetHead = getClosestHead()
        if targetHead then
            -- Envoi de la position de la tête au serveur
            ShootEvent:FireServer(targetHead.Position)
        end
    end
end)

-- 🧼 Nettoyage si le script est supprimé
CoreGui.AncestryChanged:Connect(function(_, parent)
    if not parent then
        fovCircle:Remove()
    end
end)
