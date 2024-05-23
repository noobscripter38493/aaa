--[[
_G.Autofarm = true
_G.Roll = true
_G.UsePotions = true
_G.Arena = false
_G.webhookUrl = "https://discord.com/api/webhooks/1242896565987835964/HhSEttEPjmdHWmw_eka9Tu0d_SrWIy3o5YRTA25aGnt4guJ8HFkMcpF_H8FHp1VrXu0H"
_G.Portals = _G.Portals or workspace.Portals
_G.PortalVis = function(bool)
    _G.Portals.Parent = bool and workspace or nil
end

_G.PortalVis(false)
loadstring(game:HttpGet("https://raw.githubusercontent.com/noobscripter38493/aaa/main/script.lua"))()
]]

if _G.Loaded then return end
_G.Loaded = true

local HttpS = game:GetService("HttpService")
local Players = game:GetService("Players")

game.CoreGui.DescendantAdded:Connect(function(d)
    if not d:IsA("TextLabel") or not d:FindFirstAncestor("RCTScrollContentView") then 
        return 
    end

    local Text = d.Text
    if Text:find("got") then
        local InServer
        for _, p in Players:GetPlayers() do
            if Text:find(p.Name) then
                InServer = true
                break
            end
        end

        if not InServer then return end

        Text = Text:split([[Gotham">]])[2]:split("<")[1]

        local chance = Text:split("in ")[2]:gsub("%p", "")
        if tonumber(chance) >= 500000 then
            request({
                Url = _G.webhookUrl,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpS:JSONEncode({
                    content = Text
                })
            })
        end
    end
end)

local workspace = workspace
local wait = task.wait
local spawn = task.spawn
local TweenS = game:GetService("TweenService")
local Remotes = game:GetService("ReplicatedStorage").Remotes
local RunS = game:GetService("RunService")
local plr = Players.LocalPlayer
local char = plr.Character
local hrp = char.HumanoidRootPart

for _, v in getconnections(plr.Idled) do
    v:Disable()
end

local UsePotion = Remotes.UsePotion
spawn(function()
    while true do wait()
        if _G.UsePotions then 
            UsePotion:FireServer("Speed Potion")
            UsePotion:FireServer("Luck Potion")
        end
    end
end)

local roll = Remotes.Roll
spawn(function()
    while true do wait()
        if _G.Roll then 
            roll:InvokeServer()
        end
    end
end)

for _, v in workspace:GetChildren() do
    if v.Name == "Table w/ Lantern" then 
       v:Destroy()
    end
end

local parts = {}
for _, part in char:GetDescendants() do
    if part:IsA("BasePart") and part.CanCollide then
        table.insert(parts, part)
    end
end

RunS.Stepped:Connect(function()
    for _, v in parts do
        v.CanCollide = false
    end
end)

local tweenParts = {}

local obbyPart = workspace.ObbyComplete
local Potions = workspace.Potions
for _, v in Potions:GetChildren() do
    if v:IsA("Part") then 
        tweenParts[v] = v 
    end
end

Potions.ChildAdded:Connect(function(v)
    tweenParts[v] = v
end)

local cdText = obbyPart.cooldown.TextLabel
if cdText.Text == "0s" then
    tweenParts[obbyPart] = obbyPart
end

cdText:GetPropertyChangedSignal("Text"):Connect(function()
    if cdText.Text == "0s" then
        tweenParts[obbyPart] = obbyPart

   elseif tweenParts[obbyPart] then
        shouldBreak = true
    end
end)

local zero = Vector3.zero
game.RunService.RenderStepped:Connect(function()
    if _G.Autofarm then
        hrp.Velocity = zero
    end
end)

local tween
while true do wait()
    for _, v in tweenParts do
        while true do wait()
            if not _G.Autofarm then
                tween:Stop()
                continue 
            end

            local d = (hrp.Position - v.Position).Magnitude
            if shouldBreak or d < 3 then
                tweenParts[v] = nil
                shouldBreak = false
                break
            end

            local tween_info = TweenInfo.new(d / 30, Enum.EasingStyle.Linear)
            tween = TweenS:Create(hrp, tween_info, {CFrame = v.CFrame})
            tween:Play()
        end
    end
end
