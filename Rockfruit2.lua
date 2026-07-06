repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer and game.Players.LocalPlayer:FindFirstChild("PlayerGui") and game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

local Service = {}
setmetatable(Service, {
    __index = function(_, key)
        local success, result = pcall(function()
            return cloneref(game:GetService(tostring(key)))
        end)
        return success and result or game:GetService(tostring(key))
    end
})

local CoreGui = Service.CoreGui
local Players = Service.Players
local UserInputService = Service.UserInputService
local Workspace = Service.Workspace
local HttpService = Service.HttpService
local ReplicatedStorage = Service.ReplicatedStorage
local RunService = Service.RunService
local VirtualUser = Service.VirtualUser
local VirtualInputManager = Service.VirtualInputManager
local TeleportService = Service.TeleportService
local GuiService = Service.GuiService
local TweenService = Service.TweenService
local LocalPlayer = Players.LocalPlayer
local LocalUserId = LocalPlayer.UserId

Config = Config or {}

Ex_Function = Ex_Function or {}

local SaveFolder = "Xeleng Hub/Rock Fruit"
local SaveFile = SaveFolder .. "/Config.json"
local function SaveSettings()
    if not (readfile and writefile and isfile and isfolder and makefolder) then
        return warn("Executor Not Support Save System")
    end

    local saveData = {}
    for k, v in next, Config do
        if typeof(v) == "CFrame" then
            saveData[k] = EncodeCFrame(v)

        elseif typeof(v) == "table" then
            local newTable = {}
            for a, b in next, v do
                newTable[a] = b
            end
            saveData[k] = newTable

        else
            saveData[k] = v
        end
    end

    local success, encoded = pcall(function()
        return HttpService:JSONEncode(saveData)
    end)

    if success and encoded then
        if not isfile(SaveFile) or readfile(SaveFile) ~= encoded then
            writefile(SaveFile, encoded)
        end
    end
end

local function LoadSettings()
    if not (readfile and writefile and isfile and isfolder and makefolder) then
        return warn("Executor Not Support Save System")
    end

    if not isfolder(SaveFolder) then
        makefolder(SaveFolder)
    end

    if not isfile(SaveFile) then
        SaveSettings()
        return
    end
    local success, data = pcall(function()
        return HttpService:JSONDecode(readfile(SaveFile))
    end)
    if success and type(data) == "table" then
        for key, defaultValue in next, Config do
            if data[key] == nil then
                data[key] = defaultValue
            end
        end
        for k, v in next, data do
            if typeof(v) == "table" and v.__type == "CFrame" then
                Config[k] = DecodeCFrame(v)
            else
                Config[k] = v
            end
        end
    else
        warn("Failed to load config file")
    end
end

LoadSettings()

local function AddToggle(where, data)
    local defaultValue = Config[data.Title]
    if defaultValue == nil then
        defaultValue = data.Default or false
        Config[data.Title] = defaultValue
    end
    local toggle = where:AddToggle(data.Title, {
        Title = data.Title,
        Description = data.Desc or "",
        Default = defaultValue,
        Flag = data.Title
    })
    local threadRunning
    toggle:OnChanged(function(state)
        Config[data.Title] = state
        local fn = Ex_Function[data.Title]
        if fn then
            if state then
                threadRunning = task.spawn(fn)
            elseif threadRunning then
                task.cancel(threadRunning)
                threadRunning = nil
            end
        end
        if data.Callback then
            data.Callback(state)
        end
        SaveSettings()
    end)
    return toggle
end

function AddDropdown(where, data)
    local title = data.Title
    local saved = Config[title]
    local isMulti = data.Multi or false
    local default
    if isMulti then
        default = {}
        if type(saved) == "table" then
            for _, v in pairs(saved) do
                default[tostring(v)] = true
            end
        end
    else
        default = (type(saved) == "string" and saved) or ""
    end
    local dropdown = where:AddDropdown(title, {
        Title = title,
        Description = data.Desc or "",
        Values = data.Values or {},
        Multi = isMulti,
        Default = default,
        Flag = title
    })
    dropdown:OnChanged(function(value)
        local result = value
        if isMulti and typeof(value) == "table" then
            result = {}
            for k, v in pairs(value) do
                if v then
                    table.insert(result, k)
                end
            end
        end
        Config[title] = result
        if data.Callback then
            pcall(data.Callback, result)
        end
        SaveSettings()
    end)
    return dropdown
end

function AddSlider(where, data)
    data.Min = data.Min or 0
    data.Max = data.Max or 100
    data.Rounding = data.Rounding or 0

    local flag = data.Flag or data.Title
    data.Default = Config[flag] or data.Default or data.Min

    local slider = where:AddSlider(data.Title, {
        Title = data.Title,
        Description = data.Desc or data.Description or "",
        Default = data.Default,
        Min = data.Min,
        Max = data.Max,
        Rounding = data.Rounding,
        Compact = true,
        DisplayMethod = "Value",
        Flag = flag
    })

    slider:OnChanged(function(value)
        Config[flag] = value
        if data.Callback then
            data.Callback(value)
        end
        SaveSettings()
    end)

    return slider
end

function AddTextbox(where, data)
    data.Default = Config[data.Title] or data.Default or ""
    local textbox = where:AddInput(data.Title, {
        Title = data.Title,
        Description = data.Desc or "",
        Placeholder = data.Placeholder or "",
        Default = data.Default,
        Flag = data.Title
    })
    textbox:OnChanged(function(text)
        Config[data.Title] = text
        if data.Callback then data.Callback(text) end
        SaveSettings()
    end)
    return textbox
end

pcall(function()
    CoreGui:FindFirstChild("WindowToggle"):Destroy()
end)

pcall(function()
    for _, v in next, getconnections(LocalPlayer.Idled) do
        v:Disable()
    end
end)

local function GetRoot()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function TP(P)
    local Root = GetRoot()
    if Root and P then
        Root.CFrame = P
        Root.Velocity = Vector3.zero
        Root.RotVelocity = Vector3.zero
    end
end

function Method()
    local Distance = Config["Distance Farm"] or 10
    if Config["Select Method"] == "Behind" then
        return CFrame.new(0, 0, Distance)
    elseif Config["Select Method"] == "Below" then
        return CFrame.new(0, -Distance, 0) * CFrame.Angles(math.rad(90), 0, 0)
    else
        return CFrame.new(0, Distance, 0) * CFrame.Angles(math.rad(-90), 0, 0)
    end
end

local function Equip()
    local char = LocalPlayer.Character
    if not char then return end
    local Humanoid = char:FindFirstChildOfClass("Humanoid")
    if not Humanoid or Humanoid.Health <= 0 then return end
    local held = char:FindFirstChildOfClass("Tool")
    if held and held:GetAttribute("Type") == Config["Select Weapon"] then return end
    for _, v in next, LocalPlayer.Backpack:GetChildren() do
        if v:IsA("Tool") and v:GetAttribute("Type") == Config["Select Weapon"] then
            Humanoid:EquipTool(v)
            break
        end
    end
end

local function IsAlive(mob)
    local hum = mob:FindFirstChildOfClass("Humanoid")
    return hum ~= nil and hum.Health > 0
end

local MobList = {}
local function AddMobName(mob)
    if mob:IsA("Model") then
        local Name = mob.Name:match("^(%D+)")
        if Name and not table.find(MobList, Name) then
            table.insert(MobList, Name)
            return true
        end
    end
    return false
end

for _, v in ipairs(workspace.Mob:GetChildren()) do
    AddMobName(v)
end

local function GetNearestMob()
    local selected = Config["Select Mob"]
    if type(selected) ~= "table" or #selected == 0 then return nil end
    local Root = GetRoot()
    if not Root then return nil end
    local nearest, nearestDist = nil, math.huge
    for _, v in next, workspace.Mob:GetChildren() do
        if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and IsAlive(v) then
            local Name = v.Name:match("^(%D+)")
            if Name and table.find(selected, Name) then
                local dist = (v.HumanoidRootPart.Position - Root.Position).Magnitude
                if dist < nearestDist then
                    nearest, nearestDist = v, dist
                end
            end
        end
    end
    return nearest
end

local function Attack()
    local char = LocalPlayer.Character
    local tool = char and char:FindFirstChildOfClass("Tool")
    if tool then
        tool:Activate()
    end
    VirtualUser:CaptureController()
    VirtualUser:Button1Down(Vector2.new(1280, 672))
    VirtualUser:Button1Up(Vector2.new(1280, 672))
end

local SkillKey = {
    ["1"] = Enum.KeyCode.Z,
    ["2"] = Enum.KeyCode.X,
    ["3"] = Enum.KeyCode.C,
    ["4"] = Enum.KeyCode.V,
}

-- ยิง Remote ของเกมตรงๆ ถ้าหาเจอ ไม่งั้น fallback เป็นกดปุ่ม Z/X/C/V แทน
local function UseSkill(slot)
    slot = tostring(slot)
    local char = LocalPlayer.Character
    local tool = char and char:FindFirstChildOfClass("Tool")

    local RemoteFolder = ReplicatedStorage:FindFirstChild("Remote")
    local ActionRemote = RemoteFolder and RemoteFolder:FindFirstChild("Action")
    if ActionRemote and tool then
        ActionRemote:FireServer(tool.Name, slot)
        return
    end

    local Ability = ReplicatedStorage:FindFirstChild("AbilitySystem")
    local AbilityRemotes = Ability and Ability:FindFirstChild("Remotes")
    local RequestAbility = AbilityRemotes and AbilityRemotes:FindFirstChild("RequestAbility")
    if RequestAbility then
        RequestAbility:FireServer(tonumber(slot))
        return
    end

    local Key = SkillKey[slot]
    if Key then
        VirtualInputManager:SendKeyEvent(true, Key, false, game)
        VirtualInputManager:SendKeyEvent(false, Key, false, game)
    end
end

-----------------------------------------------------------------------------------------------------
Ex_Function["Equip Weapon"] = function()
    while Config["Equip Weapon"] and task.wait(0.2) do
        pcall(Equip)
    end
end

Ex_Function["Auto Farm Mob"] = function()
    while Config["Auto Farm Mob"] and task.wait() do
        pcall(function()
            local Mob = GetNearestMob()
            if Mob then
                repeat
                    TP(Mob:GetPivot() * Method())
                    task.wait()
                until not Config["Auto Farm Mob"]
                    or not Mob.Parent
                    or not Mob:FindFirstChild("HumanoidRootPart")
                    or not IsAlive(Mob)
            end
        end)
    end
end

Ex_Function["Auto Attack"] = function()
    while Config["Auto Attack"] and task.wait(0.1) do
        pcall(Attack)
    end
end

Ex_Function["Auto Skills"] = function()
    while Config["Auto Skills"] and task.wait(0.15) do
        pcall(function()
            local selected = Config["Select Skills"]
            if type(selected) ~= "table" then return end
            for _, slot in next, selected do
                UseSkill(slot)
                task.wait(0.05)
            end
        end)
    end
end
-----------------------------------------------------------------------------------------------------
local Library = loadstring(request({
    Url = "https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua",
    Method = "GET"
}).Body)()


local Window = Library:CreateWindow({
    Title = "[🌙Moon Update⚔️] Sailor Piece",
    SubTitle = "By x2punniez",
    TabWidth = 160,
    Size = UDim2.fromOffset(580,400),
    MinimizeKey = Enum.KeyCode.LeftControl,
    Theme = "Dark",
    Transparency = 0.85,
    FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json")
})

local ScreenGui1 = Instance.new("ScreenGui")

local ToggleButton = Instance.new("ImageButton")
local UICorner1 = Instance.new("UICorner")

ScreenGui1.Name = "WindowToggle"
ScreenGui1.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui1.Parent = game:GetService("CoreGui")

ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = ScreenGui1

ToggleButton.AnchorPoint = Vector2.new(0.5, 0)
ToggleButton.Position = UDim2.new(0.5, 0, 0, 20)

ToggleButton.Size = UDim2.new(0, 45, 0, 45)
ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 1, 0)
ToggleButton.BackgroundTransparency = 0.25
ToggleButton.BorderSizePixel = 0
ToggleButton.Draggable = true
ToggleButton.Image = "rbxassetid://108559968423771"
ToggleButton.AutoButtonColor = true

UICorner1.CornerRadius = UDim.new(0.25, 0)
UICorner1.Parent = ToggleButton

ToggleButton.MouseButton1Click:Connect(function()
    Window:Minimize()
end)

local Tabs = {
    Main = Window:AddTab({Title = "Main", Icon = "crown"}),
}

local Setting = Tabs.Main:AddSection("Setting Farm")

AddSlider(Setting, {
    Title = "Distance Farm",
    Min = 0,
    Max = 500,
    Rounding = 0,
    Default = 10,
    Callback = function(value)
    end
})

MethodDropdown = AddDropdown(Setting,{
    Title = "Select Method",
    Values = {"Behind","Upper","Below"},
    Multi = false,
})


local WeaponSection = Tabs.Main:AddSection("Weapon")

WeaponDropdown = AddDropdown(WeaponSection,{
    Title = "Select Weapon",
    Values = {"Melee","Sword","Power"},
    Multi = false,
})


AddToggle(WeaponSection, {
    Title = "Equip Weapon",
})

local SkillsSection = Tabs.Main:AddSection("Auto Skills")

AddDropdown(SkillsSection, {
    Title = "Select Skills",
    Desc = "",
    Values = {"1", "2", "3", "4"},
    Multi = true,
})

AddToggle(SkillsSection, {
    Title = "Auto Attack",
})

AddToggle(SkillsSection, {
    Title = "Auto Skills",
})

local Tabs = {
    Farm = Window:AddTab({Title = "Automatic", Icon = "gamepad-2"}),
}

local Mob = Tabs.Farm:AddSection("Mob")

local MobDropdown = AddDropdown(Mob, {
    Title = "Select Mob",
    Desc = "",
    Values = MobList,
    Multi = true
})

AddToggle(Mob, {
    Title = "Auto Farm Mob",
})

-- ม็อบตัวใหม่โผล่มาในแมพ ก็เพิ่มชื่อเข้า dropdown ให้เอง
workspace.Mob.ChildAdded:Connect(function(v)
    task.wait()
    if AddMobName(v) then
        pcall(function()
            MobDropdown:SetValues(MobList)
        end)
    end
end)

task.spawn(function()
    while task.wait() do
        pcall(function()
            local FarmEnabled = Config["Auto Farm Mob"]

            local character = LocalPlayer.Character
            if not character then return end

            local humanoid = character:FindFirstChildWhichIsA("Humanoid")
            local root = character:FindFirstChild("HumanoidRootPart")
            if not root then return end

            if FarmEnabled then

                if humanoid and humanoid.Sit then
                    humanoid.Sit = false
                end

                local bv = root:FindFirstChild("BodyVelocity1")
                if not bv then
                    bv = Instance.new("BodyVelocity")
                    bv.Name = "BodyVelocity1"
                    bv.MaxForce = Vector3.new(1e5,1e5,1e5)
                    bv.Velocity = Vector3.zero
                    bv.Parent = root
                end

                root.Velocity = Vector3.zero

                for _,v in ipairs(character:GetChildren()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                    elseif v:IsA("Accessory") then
                        local h = v:FindFirstChild("Handle")
                        if h then h.CanCollide = false end
                    end
                end

            else
                local bv = root:FindFirstChild("BodyVelocity1")
                if bv then
                    bv:Destroy()
                end
            end

        end)
    end
end)

task.defer(function()
    for key, value in pairs(Config) do
        if value == true and Ex_Function[key] then
            task.spawn(Ex_Function[key])
        end
    end
end)
