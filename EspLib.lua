local ESP = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera
local enabled = false
local useTeamColors = false
local showNames = false
local showDistance = false
local showTracers = false

local playerESPInstances = {}

local function updateESPColors(player, espData)
    local color = (player.Team and useTeamColors) and player.Team.TeamColor.Color or Color3.fromRGB(255, 255, 255)
    if espData.highlight then espData.highlight.FillColor = color end
    if espData.textLabel then espData.textLabel.TextColor3 = color end
    if espData.tracer then espData.tracer.Color = color end
end

local function createESP(player)
    local espData = {}

    local function addHighlight(character)
        local highlight = Instance.new("Highlight")
        highlight.Adornee = character
        highlight.FillTransparency = 0.7
        highlight.OutlineTransparency = 0.3
        highlight.Parent = character
        espData.highlight = highlight
        updateESPColors(player, espData)
    end

    local function addBillboardGui(character)
        local head = character:FindFirstChild("Head")
        if not head then return end

        local billboardGui = Instance.new("BillboardGui")
        billboardGui.Adornee = head
        billboardGui.Size = UDim2.new(0, 200, 0, 50)
        billboardGui.StudsOffset = Vector3.new(0, 2.5, 0)
        billboardGui.AlwaysOnTop = true
        billboardGui.Parent = character

        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.TextStrokeTransparency = 0.5
        textLabel.TextSize = 14
        textLabel.Font = Enum.Font.SourceSansBold
        textLabel.Parent = billboardGui

        espData.billboardGui = billboardGui
        espData.textLabel = textLabel
        updateESPColors(player, espData)
    end

    local function addTracer()
        local tracer = Drawing.new("Line")
        tracer.Visible = false
        tracer.Thickness = 1.5
        tracer.Transparency = 1
        espData.tracer = tracer
        updateESPColors(player, espData)
    end

    local function updateESP()
        if not espData.textLabel or not espData.tracer then return end

        local character = player.Character
        local head = character and character:FindFirstChild("Head")
        local localHead = localPlayer.Character and localPlayer.Character:FindFirstChild("Head")

        if head and localHead then
            local headPosition, onScreen = camera:WorldToViewportPoint(head.Position)
            local distance = (localHead.Position - head.Position).Magnitude
            espData.textLabel.Text = (showNames and player.Name or "") .. (showDistance and ("\n" .. math.floor(distance) .. " studs") or "")

            if enabled and showTracers and onScreen then
                espData.tracer.Visible = true
                espData.tracer.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                espData.tracer.To = Vector2.new(headPosition.X, headPosition.Y)
            else
                espData.tracer.Visible = false
            end
        else
            espData.tracer.Visible = false
        end
    end

    local function onCharacterAdded(character)
        removeESP(player)  -- Ensure cleanup before adding new ESP
        addHighlight(character)
        addBillboardGui(character)
        addTracer()
        espData.updateConnection = RunService.RenderStepped:Connect(updateESP)
    end

    player.CharacterAdded:Connect(onCharacterAdded)
    if player.Character then
        onCharacterAdded(player.Character)
    end

    playerESPInstances[player] = espData
end

local function removeESP(player)
    local espData = playerESPInstances[player]
    if espData then
        if espData.highlight then espData.highlight:Destroy() end
        if espData.billboardGui then espData.billboardGui:Destroy() end
        if espData.tracer then espData.tracer:Remove() end
        if espData.updateConnection then espData.updateConnection:Disconnect() end
    end
    playerESPInstances[player] = nil
end

function ESP:Toggle(state)
    enabled = state
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer then
            if enabled then
                createESP(player)
            else
                removeESP(player)
            end
        end
    end
end

function ESP:ToggleTeamColor(state)
    useTeamColors = state
    for player, espData in pairs(playerESPInstances) do
        updateESPColors(player, espData)
    end
end

function ESP:ToggleNames(state)
    showNames = state
end

function ESP:ToggleDistance(state)
    showDistance = state
end

function ESP:ToggleTracers(state)
    showTracers = state
    for _, espData in pairs(playerESPInstances) do
        if espData.tracer then
            espData.tracer.Visible = showTracers and enabled
        end
    end
end

function ESP:Init()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer then
            createESP(player)
        end
    end
    Players.PlayerAdded:Connect(function(player)
        if player ~= localPlayer then
            createESP(player)
        end
    end)
    Players.PlayerRemoving:Connect(removeESP)
end

return ESP
