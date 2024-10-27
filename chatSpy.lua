Config = {
    enabled = true,
    spyOnMyself = true,
    public = false,
    publicItalics = true
}

PrivateProperties = {
    Color = Color3.fromRGB(0, 255, 255),
    Font = Enum.Font.SourceSansBold,
    TextSize = 18
}

local player = game.Players.LocalPlayer
local saymsg =
    game:GetService("ReplicatedStorage"):WaitForChild("DefaultChatSystemChatEvents"):WaitForChild("SayMessageRequest")
local getmsg =
    game:GetService("ReplicatedStorage"):WaitForChild("DefaultChatSystemChatEvents"):WaitForChild(
    "OnMessageDoneFiltering"
)
local instance = (_G.chatSpyInstance or 0) + 1
_G.chatSpyInstance = instance

local function onChatted(p, msg)
    if _G.chatSpyInstance == instance then
        if p == player and msg:lower():sub(1, 4) == "/spy" then
            Config.enabled = not Config.enabled
            task.wait(0.3)
            game.StarterGui:SetCore("ChatMakeSystemMessage", PrivateProperties)
        elseif Config.enabled and (Config.spyOnMyself == true or p ~= player) then
            msg = msg:gsub("[\n\r]", ""):gsub("\t", " "):gsub("[ ]+", " ")
            local hidden = true
            local conn =
                getmsg.OnClientEvent:Connect(
                function(packet, channel)
                    if
                        packet.SpeakerUserId == p.UserId and packet.Message == msg:sub(#msg - #packet.Message + 1) and
                            (channel == "All" or
                                (channel == "Team" and Config.public == false and
                                    game.Players[packet.FromSpeaker].Team == player.Team))
                     then
                        hidden = false
                    end
                end
            )
            task.wait(1)
            conn:Disconnect()
            if hidden and Config.enabled then
                if Config.public then
                    saymsg:FireServer(
                        (Config.publicItalics and "/me " or "") .. "{SPY} [" .. p.Name .. "]: " .. msg,
                        "All"
                    )
                else
                    game.StarterGui:SetCore("ChatMakeSystemMessage", PrivateProperties)
                end
            end
        end
    end
end

for _, p in ipairs(game.Players:GetPlayers()) do
    p.Chatted:Connect(
        function(msg)
            onChatted(p, msg)
        end
    )
end

game.Players.PlayerAdded:Connect(
    function(p)
        p.Chatted:Connect(
            function(msg)
                onChatted(p, msg)
            end
        )
    end
)

game.StarterGui:SetCore("ChatMakeSystemMessage", PrivateProperties)
local chatFrame = player.PlayerGui.Chat.Frame
chatFrame.ChatChannelParentFrame.Visible = true
chatFrame.ChatBarParentFrame.Position =
    chatFrame.ChatChannelParentFrame.Position + UDim2.new(UDim.new(), chatFrame.ChatChannelParentFrame.Size.Y)
