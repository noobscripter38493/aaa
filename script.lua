if _G.Loaded then return end
_G.Loaded = true

local workspace = workspace
local wait = task.wait
local spawn = task.spawn
local TweenS = game:GetService("TweenService")
local HttpS = game:GetService("HttpService")
local Players = game:GetService("Players")
local Remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")
local RunS = game:GetService("RunService")
local plr = Players.LocalPlayer
local char = plr.Character
local hrp = char.HumanoidRootPart

_G.Settings = _G.Settings or Https:JSONDecode(readfile("Settings.json"))
spawn(function()
    while true do
        writefile("Settings.json", HttpS:JSONEncode(_G.Settings))
        wait(5)
    end
end)

local Portals = workspace:WaitForChild("Portals")
_G.PortalVis = _G.PortalVis or function(bool)
    Portals.Parent = bool and workspace or nil
end
_G.PortalVis(false)
setrawmetatable(_G, __index = _G.Settings}

queueonteleport('loadstring(game:HttpGet("https://raw.githubusercontent.com/noobscripter38493/aaa/main/script.lua"))()')

game.CoreGui.DescendantAdded:Connect(function(d)
    if not d:IsA("TextLabel") or not d:FindFirstAncestor("RCTScrollContentView") then 
        return 
    end

    local Text = d.Text
    if Text:find("got") then
        local InServer
        local discordId
        for _, p in Players:GetPlayers() do
            if Text:find(p.Name) then
                InServer = true
                discordId = _G.RblxToDisc[p.Name]
                break
            end
        end

        if not InServer then return end

        Text = Text:split([[Gotham">]])[2]:split("<")[1]

        local chance = Text:split("in ")[2]:gsub("%p", "")
        if tonumber(chance) >= 500000 then
            if discordId then
                Text = `<@{discordId}> {Text}`
            end

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

for _, v in getconnections(plr.Idled) do
    v:Disable()
end

local arena = Remotes.Arena
local refresh = Remotes.Refresh

spawn(function()
    while true do
        if _G.Arena then
            refresh:InvokeServer()
            wait(1)
            arena:FireServer(1)
        end

        wait(75)
    end
end)

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
    hrp.Velocity = zero
end)

local tween
while true do wait()
    for _, v in tweenParts do
        while true do wait()
            if not _G.Autofarm then
                pcall(function()
                    tween:Stop()
                end)
                
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
