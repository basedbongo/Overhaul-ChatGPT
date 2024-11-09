--[[



    Made by speakingheademoji



]]

local ESPLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/MIM-104/Overhaul/refs/heads/main/EspLib.lua"))()
local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/MIM-104/Overhaul/refs/heads/main/Rayfield.lua"))()

local Lighting = game:GetService("Lighting")
local uis = game:GetService("UserInputService")
local rs = game:GetService("RunService")
local vim = game:GetService("VirtualInputManager")
local http = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

local function hasGun(character)
    for _, tool in pairs(character:GetChildren()) do
        if tool:IsA("Tool") and tool:FindFirstChild("Muzzle") then
            return true
        end
    end
    return false
end

local function isTarget(otherPlayer)
    return true
end

local function loadDex()
    local dexScript = game:HttpGet("https://raw.githubusercontent.com/MIM-104/Overhaul/refs/heads/main/dex.lua")
    
    if dexScript then
        if dexScript then
            return loadstring(dexScript)()
        else
            warn("Failed to load dex.lua: loadstring returned nil.")
        end
    else
        warn("Failed to retrieve dex.lua from the URL.")
    end
end

local Window = Rayfield:CreateWindow({
    Name = "SCP: Roleplay Closeted Hub",
    DisableRayfieldPrompts = true,
    LoadingTitle = "SCP: Roleplay",
    LoadingSubtitle = "by speakingheademoji",
    ConfigurationSaving = {
        Enabled = false,
        FolderName = "hub",
        FileName = "hub configs"
    },
})

--[[



    COMBAT TAB



]]

local combatTab = Window:CreateTab("Combat", "6035078889")

combatTab:CreateSection("Hitbox Expander")

local hitboxExpanderValue = 1
local hitboxExpanderEnabled = false
local hitboxExpanderTransparency = 0
local selectedBodyPart = ""
local previousBodyPart = ""

local function UpdatePlayerHitbox(player, reset, partName)
    local character = player.Character
    if character and character:FindFirstChild("Humanoid") ~= nil then
        if character:FindFirstChild(partName) and character[partName]:IsA("BasePart") then
			local bodyPart = character:FindFirstChild(partName)
			bodyPart.Transparency = hitboxExpanderTransparency
			if bodyPart:FindFirstChildOfClass("Decal") ~= nil then
				bodyPart:FindFirstChildOfClass("Decal"):Destroy()
			end
            if reset or character.Humanoid.Health <= 0 then
                bodyPart.Size = Vector3.new(1, 1, 1)
				bodyPart.Massless = false
            else
				bodyPart.Massless = true
                bodyPart.Size = Vector3.new(hitboxExpanderValue, hitboxExpanderValue, hitboxExpanderValue)
            end
        end
    end
end

task.spawn(function()
    while task.wait(0.1) do
        if hitboxExpanderEnabled then
            for _, player in pairs(game.Players:GetPlayers()) do
                local char = player.Character
                if char and char ~= game.Players.LocalPlayer.Character then
					UpdatePlayerHitbox(player, true, previousBodyPart)
                    if isTarget(player) then
                        UpdatePlayerHitbox(player, false, selectedBodyPart)
                    else
                        UpdatePlayerHitbox(player, true, selectedBodyPart)
                    end
                end
            end
        else
            for _, player in pairs(game.Players:GetPlayers()) do
                local char = player.Character
                if char and char ~= game.Players.LocalPlayer.Character then
                    UpdatePlayerHitbox(player, true, selectedBodyPart)
                end
            end
        end
    end
end)

local hitboxToggle = combatTab:CreateToggle({
    Name = "Head Hitbox Expander Toggle",
    CurrentValue = false,
    Flag = "HeadHitboxToggle",
    Callback = function(Value)
        hitboxExpanderEnabled = Value
    end
})

local hitboxSlider = combatTab:CreateSlider({
    Name = "Hitbox Size",
    Range = {1, 10},
    Increment = 0.1,
    Suffix = "",
    CurrentValue = 1,
    Flag = "HeadHitboxSlider",
    Callback = function(Value)
        hitboxExpanderValue = Value
    end
})

local bodyPartDropdown = combatTab:CreateDropdown({
    Name = "Body Part Selector",
    Options = {
        "Head", "UpperTorso", "LowerTorso", "LeftUpperArm", 
        "LeftLowerArm", "RightUpperArm", "RightLowerArm", "LeftHand", "RightHand", 
        "LeftUpperLeg", "LeftLowerLeg", "RightUpperLeg", "RightLowerLeg", 
        "LeftFoot", "RightFoot"
    },
    CurrentOption = {""},
    MultipleOptions = false,
    Flag = "BodyPartDropdownFlag",
    Callback = function(Option)
        previousBodyPart = selectedBodyPart
        selectedBodyPart = Option[1]
    end
})

local hitboxTransparency = combatTab:CreateSlider({
    Name = "Hitbox Transparency",
    Range = {0, 1},
    Increment = 0.01,
    Suffix = "",
    CurrentValue = 0,
    Flag = "hitboxExpanderTransparencyToggle",
    Callback = function(Value)
        hitboxExpanderTransparency = Value
    end
})

combatTab:CreateSection("ESP")

local ESP = combatTab:CreateToggle({
Name = "ESP",
CurrentValue = false,
Flag = "espToggleFlag",
Callback = function(Value)
    if Value then
        ESPLib:Toggle(true)
    else
        ESPLib:Toggle(false)
    end
end
})

local ESPBoxes = combatTab:CreateToggle({
Name = "Boxes",
CurrentValue = false,
Flag = "espBoxesFlag",
Callback = function(Value)
    if Value then
        ESPLib.Boxes = true
    else
        ESPLib.Boxes = false
    end
end
})

local ESPTracers = combatTab:CreateToggle({
Name = "Tracers",
CurrentValue = false,
Flag = "espTracersFlag",
Callback = function(Value)
    if Value then
        ESPLib.Tracers = true
    else
        ESPLib.Tracers = false
    end
end
})

local ESPNames = combatTab:CreateToggle({
Name = "Names",
CurrentValue = false,
Flag = "espNamesFlag",
Callback = function(Value)
    if Value then
        ESPLib.Names = true
    else
        ESPLib.Names = false
    end
end
})

local ESPFaceCamera = combatTab:CreateToggle({
Name = "Face Camera",
CurrentValue = false,
Flag = "espCameraFlag",
Callback = function(Value)
    if Value then
        ESPLib.FaceCamera = true
    else
        ESPLib.FaceCamera = false
    end
end
})

local ESPTeamColor = combatTab:CreateToggle({
    Name = "Team Colour",
    CurrentValue = true,
    Flag = "espTeamColourFlag",
    Callback = function(Value)
        if Value then
            ESPLib.TeamColor = true
        else
            ESPLib.TeamColor = false
        end
    end
})

local ESPColorPicker = combatTab:CreateColorPicker({
    Name = "ESP Colour Picker",
    Color = Color3.fromRGB(255, 170, 0),
    Flag = "espColourPickerFlag",
    Callback = function(Value)
        ESPLib.Color = Value
    end
})

combatTab:CreateSection("Other")

local Destroy = combatTab:CreateButton({
    Name = "Destroy Gui",
    Callback = function()
		ESPLib:Toggle(false)
		hitboxExpanderEnabled = false
		for i, v in pairs(game.Players:GetPlayers()) do
            if v ~= game.Players.LocalPlayer then
                if v.Character ~= nil then
                    if selectedBodyPart ~= "" and selectedBodyPart ~= nil then
                        v.Character[selectedBodyPart].Size = Vector3.new(1, 1, 1)
                        v.Character[selectedBodyPart].Massless = false
                        v.Character[selectedBodyPart].Transparency = 0
                    end
                end
            end
        end
        Rayfield:Destroy()
    end
})
