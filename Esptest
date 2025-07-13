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
        local gui = head:FindFirstChild("ESPNameTag")
        if gui then gui:Destroy() end
    end
end

local function onCharacterAdded(player, character)
    wait(0.1)
    if player ~= localPlayer then
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

for _, p in pairs(Players:GetPlayers()) do
    if p ~= localPlayer then
        onPlayerAdded(p)
    end
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(removeESP)
