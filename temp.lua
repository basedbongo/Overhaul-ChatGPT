-- Optimized Rayfield Interface Suite
-- Original by Sirius, shlex, iRay
-- Optimized by ChatGPT

local RayfieldLibrary = {
    Flags = {},
    Theme = {
        Default = {
            TextColor = Color3.fromRGB(240, 240, 240),
            Background = Color3.fromRGB(25, 25, 25),
            Topbar = Color3.fromRGB(34, 34, 34),
            Shadow = Color3.fromRGB(20, 20, 20),
            NotificationBackground = Color3.fromRGB(20, 20, 20),
            NotificationActionsBackground = Color3.fromRGB(230, 230, 230)
        }
    }
}

-- Services
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

-- UI Initialization
local Rayfield = game:GetObjects("rbxassetid://138479981673371")[1]
Rayfield.Enabled = false
Rayfield.Parent = CoreGui

-- Function to optimize setting UI colors
local function ApplyTheme(element, theme)
    element.BackgroundColor3 = theme.Background or element.BackgroundColor3
    element.TextColor3 = theme.TextColor or element.TextColor3
end

-- Optimized Notification System
function RayfieldLibrary:Notify(data)
    task.spawn(function()
        local notification = Rayfield.Notifications.Template:Clone()
        notification.Parent = Rayfield.Notifications
        notification.Title.Text = data.Title or "Notification"
        notification.Description.Text = data.Content or "Message"
        notification.Visible = true
        TweenService:Create(notification, TweenInfo.new(0.6), {BackgroundTransparency = 0.45}):Play()
        task.wait(data.Duration or 3)
        notification:Destroy()
    end)
end

-- Optimized Configuration Save/Load
local function SaveConfig()
    local data = {}
    for key, value in pairs(RayfieldLibrary.Flags) do
        data[key] = value.Type == "ColorPicker" and {R = value.Color.R * 255, G = value.Color.G * 255, B = value.Color.B * 255} or value.CurrentValue
    end
    writefile("RayfieldConfig.json", HttpService:JSONEncode(data))
end

local function LoadConfig()
    if not isfile("RayfieldConfig.json") then return end
    local data = HttpService:JSONDecode(readfile("RayfieldConfig.json"))
    for key, value in pairs(data) do
        if RayfieldLibrary.Flags[key] then
            if RayfieldLibrary.Flags[key].Type == "ColorPicker" then
                RayfieldLibrary.Flags[key]:Set(Color3.fromRGB(value.R, value.G, value.B))
            else
                RayfieldLibrary.Flags[key]:Set(value)
            end
        end
    end
end

-- Cleanup Function
function RayfieldLibrary:Cleanup()
    for _, instance in pairs(CoreGui:GetChildren()) do
        if instance.Name == "Rayfield" then
            instance:Destroy()
        end
    end
end

return RayfieldLibrary
