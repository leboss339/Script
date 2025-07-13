local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

-- Ajoute l'ESP pour un joueur
local function createESP(player)
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")
    if root and not root:FindFirstChild("ESPBox") then
        local box = Instance.new("BoxHandleAdornment")
        box.Name = "ESPBox"
        box.Adornee = root
        box.AlwaysOnTop = true
        box.ZIndex = 10
        box.Size = Vector3.new(4,6,2)
        box.Color3 = Color3.new(1,0,0)
        box.Transparency = 0.5
        box.Parent = root
    end
    if head and not head:FindFirstChild("ESPNameTag") then
        local tag = Instance.new("BillboardGui")
        tag.Name = "ESPNameTag"
        tag.Adornee = head
        tag.Size = UDim2.new(0,100,0,30)
        tag.StudsOffset = Vector3.new(0,2,0)
        tag.AlwaysOnTop = true
        tag.Parent = head

        local text = Instance.new("TextLabel")
        text.Size = UDim2.new(1,0,1,0)
        text.BackgroundTransparency = 1
        text.Text = player.Name
        text.TextColor3 = Color3.new(1,1,1)
        text.TextStrokeTransparency = 0
        text.Font = Enum.Font.SourceSansBold
        text.TextScaled = true
        text.Parent = tag
    end
end

-- Supprime l'ESP d'un joueur
local function removeESP(player)
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if root then
        local box = root:FindFirstChild("ESPBox")
        if box then box:Destroy() end
    end
    local head = char:FindFirstChild("Head")
    if head then
        local tag = head:FindFirstChild("ESPNameTag")
        if tag then tag:Destroy() end
    end
end

-- Gestion des joueurs
local function onCharacterAdded(player, character)
    if player ~= localPlayer then
        wait(0.1)
        createESP(player)
    end
end

local function onPlayerAdded(player)
    player.CharacterAdded:Connect(function(char)
        onCharacterAdded(player, char)
    end)
    if player.Character then
        onCharacterAdded(player, player.Character)
    end
end

for _, p in ipairs(Players:GetPlayers()) do
    if p ~= localPlayer then
        onPlayerAdded(p)
    end
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(removeESP)
