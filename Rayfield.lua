--[[
Rayfield Interface Suite
Optimized by ChatGPT
Original by Sirius, shlex, iRay, speakingheademoji
]]

local RayfieldLibrary = {
    Flags = {},
    Theme = {
        Default = {
            TextColor = Color3.fromRGB(240, 240, 240),
            Background = Color3.fromRGB(25, 25, 25),
            Topbar = Color3.fromRGB(34, 34, 34),
            Shadow = Color3.fromRGB(20, 20, 20),
            NotificationBackground = Color3.fromRGB(20, 20, 20),
            NotificationActionsBackground = Color3.fromRGB(230, 230, 230),
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

-- Cleaned up global variables
local Rayfield = game:GetObjects("rbxassetid://138479981673371")[1]
Rayfield.Enabled = false
Rayfield.Parent = CoreGui

local function PackColor(Color)
    return {R = Color.R * 255, G = Color.G * 255, B = Color.B * 255}
end    

local function UnpackColor(Color)
    return Color3.fromRGB(Color.R, Color.G, Color.B)
end

-- Optimized Configuration Save Function
local function SaveConfiguration()
    if not RayfieldLibrary.Flags then return end
    local Data = {}
    for FlagName, Flag in pairs(RayfieldLibrary.Flags) do
        Data[FlagName] = Flag.Type == "ColorPicker" and PackColor(Flag.Color) or Flag.CurrentValue
    end
    writefile("RayfieldConfig.txt", HttpService:JSONEncode(Data))
end

-- Optimized Notification System
function RayfieldLibrary:Notify(data)
    task.spawn(function()
        local newNotification = Rayfield.Notifications.Template:Clone()
        newNotification.Parent = Rayfield.Notifications
        newNotification.Title.Text = data.Title or "Unknown Title"
        newNotification.Description.Text = data.Content or "Unknown Content"
        newNotification.Visible = true
        TweenService:Create(newNotification, TweenInfo.new(0.6), {BackgroundTransparency = 0.45}):Play()
        task.wait(data.Duration or 3)
        newNotification:Destroy()
    end)
end

-- Optimized GUI Cleanup
function RayfieldLibrary:Cleanup()
    for _, v in pairs(CoreGui:GetChildren()) do
        if v.Name == "Rayfield" then
            v:Destroy()
        end
    end
end

return RayfieldLibrary
