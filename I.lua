
repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer and game.Players.LocalPlayer.Character and game.Players.LocalPlayer:FindFirstChild("PlayerGui")
if not game:IsLoaded() then game.Loaded:Wait(3) end

local Service = {}

setmetatable(Service, {
    __index = function(_, key)
        local success, result = pcall(function()
            return cloneref(game:GetService(tostring(key)))
        end)
        return success and result or game:GetService(tostring(key))
    end
})

local Players = Service.Players
local LocalPlayer = Players.LocalPlayer
local Workspace = Service.Workspace
local LocalUserId = LocalPlayer.UserId
local HttpService = Service.HttpService
local ReplicatedStorage = Service.ReplicatedStorage
local RunService = Service.RunService
local VirtualUser = Service.VirtualUser
local VirtualInputManager = Service.VirtualInputManager
local UserInputService = Service.UserInputService
local TeleportService = Service.TeleportService
local GuiService = Service.GuiService
local PlayerGui = LocalPlayer.PlayerGui
local TweenService = Service.TweenService

Config = Config or {
    ["One Click"] = true,
}

function SendKey(Key)
    VirtualInputManager:SendKeyEvent(true,Key, false, LocalPlayer.Character.HumanoidRootPart)
    VirtualInputManager:SendKeyEvent(false,Key, false, LocalPlayer.Character.HumanoidRootPart)
    wait(0.3)
end 

function TP(CFrame)
    local Root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if Root then
        Root.CFrame = CFrame
    end
end

function A()
    ReplicatedStorage.Remotes.Serverside:FireServer("Server","Sword","M1s","Dual Dagger",3)
end 

task.spawn(function()
    while Config["One Click"] do task.wait()
        pcall(function()
            if not workspace.Main.Characters["Rogue Town"].Boss:FindFirstChild("Sung Jin Woo") and LocalPlayer.PlayerGui.HUD.Bar.List:FindFirstChild("Quest") then 
                for i,v in next, workspace.Main.Characters["Forge Isle"]:GetChildren() do 
                    if v.Name == "Slayer's Trainee" and v.Humanoid.Health > 0 then 
                        TP(v.HumanoidRootPart.CFrame * CFrame.new(0,9,0) * CFrame.Angles(math.rad(-90),0,0))
                        A()
                        task.wait()
                    end 
                end 
            elseif not workspace.Main.Characters["Rogue Town"].Boss:FindFirstChild("Sung Jin Woo") and not LocalPlayer.PlayerGui.HUD.Bar.List:FindFirstChild("Quest") then 
                TP(workspace.Main.NPCs.Quests["8"].HumanoidRootPart.CFrame * CFrame.new(0,0,-3))
                workspace.Main.NPCs.Quests["8"]["{}"].HoldDuration = 0
                SendKey("E")
            elseif workspace.Main.Characters["Rogue Town"].Boss:FindFirstChild("Sung Jin Woo") then 
                for i,v in next, workspace.Main.Characters["Rogue Town"].Boss:GetChildren() do 
                    if v.Name == "Sung Jin Woo" and v.Humanoid.Health > 0  then 
                        TP(v.HumanoidRootPart.CFrame * CFrame.new(0,9,0) * CFrame.Angles(math.rad(-90),0,0))
                        A()
                    end 
                end 
            elseif not workspace.Main.Characters["Rogue Town"].Boss:FindFirstChild("Sung Jin Woo") and not workspace.Main.Characters["Forge Isle"]["Slayer's Trainee"]:FindFirstChild("Slayer's Trainee") then
                TP(workspace.Main.NPCs.Quests["8"].HumanoidRootPart.CFrame * CFrame.new(0,0,-3))
            end
        end)
    end 
end)