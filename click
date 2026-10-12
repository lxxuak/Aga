-- ================================================================
-- XEXER GAME EXPLOIT SUITE
-- Native GUI (No External Libraries - Pure Roblox API)
-- ================================================================

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local WS = game:GetService("Workspace")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LP = Players.LocalPlayer
local Char = LP.Character or LP.CharacterAdded:Wait()
local HRP = Char:WaitForChild("HumanoidRootPart")

-- Remotes
local Remotes = RS:WaitForChild("Remotes")
local ClickRemote = Remotes:WaitForChild("Click")
local FuerzaRemote = Remotes:WaitForChild("Fuerza")
local RebirthRemote = Remotes:WaitForChild("Rebirth")
local HuevoAbrirRemote = Remotes:WaitForChild("Huevo_Abrir")
local PetsSetEquippedRemote = Remotes:WaitForChild("Pets_SetEquipped")
local CodigoRemote = Remotes:WaitForChild("Codigo_Canjear")
local RegaloRemote = Remotes:WaitForChild("Regalo")

local ArenaRemotos = RS.Arena:WaitForChild("Remotos")
local MobPegaRemote = ArenaRemotos:WaitForChild("MobPega")

-- State
local AutoClickEnabled = false
local AutoRebirthEnabled = false
local AutoHatchEnabled = false
local GodModeEnabled = false
local AutoFuerzaEnabled = false

local ClickSpeed = 0.01
local RebirthDelay = 5
local HatchEggName = "BasicEgg"
local HatchCount = 1
local FuerzaMultiplier = 999999

-- Utility
local function fireRemote(remote, ...)
    if remote:IsA("RemoteEvent") or remote:IsA("UnreliableRemoteEvent") then
        remote:FireServer(...)
    elseif remote:IsA("RemoteFunction") then
        return remote:InvokeServer(...)
    end
end

local function Notify(title, text)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = 3
    })
end

-- Exploit Loops
spawn(function()
    while wait(ClickSpeed) do
        if AutoClickEnabled then
            pcall(function() fireRemote(ClickRemote) end)
        end
    end
end)

spawn(function()
    while wait(0.5) do
        if AutoFuerzaEnabled then
            pcall(function() fireRemote(FuerzaRemote, FuerzaMultiplier) end)
        end
    end
end)

spawn(function()
    while wait(RebirthDelay) do
        if AutoRebirthEnabled then
            pcall(function() fireRemote(RebirthRemote) end)
        end
    end
end)

spawn(function()
    while wait(1) do
        if AutoHatchEnabled then
            for i = 1, HatchCount do
                pcall(function()
                    local result = fireRemote(HuevoAbrirRemote, HatchEggName)
                    if result then print("[Hatch]", HatchEggName, "→", result) end
                end)
                wait(0.1)
            end
        end
    end
end)

local OldNamecall
OldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if GodModeEnabled and self == MobPegaRemote and method == "FireServer" then
        return nil
    end
    return OldNamecall(self, ...)
end))

local function TeleportTo(cframe)
    if Char and HRP then HRP.CFrame = cframe end
end

local function RedeemCode(code)
    local success, result = pcall(function() return fireRemote(CodigoRemote, code) end)
    if success and result then
        Notify("✓ Code", code)
        return true
    end
    return false
end

local function RedeemAllCodes()
    local codes = {"RELEASE","LAUNCH","BETA","1000LIKES","5000LIKES","10KLIKES","UPDATE1","UPDATE2","FREEPET","SECRET","VIP","CHRISTMAS","HALLOWEEN","EASTER","SUMMER","WINTER"}
    Notify("Codes", "Starting...")
    local count = 0
    for _, code in pairs(codes) do
        if RedeemCode(code) then count = count + 1 end
        wait(1)
    end
    Notify("Codes", count .. " redeemed")
end

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "XexerGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LP.PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "Main"
MainFrame.Size = UDim2.new(0, 520, 0, 420)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.BorderSizePixel = 0
Title.Text = "XEXER Exploit Suite"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

local TabBar = Instance.new("Frame")
TabBar.Name = "TabBar"
TabBar.Size = UDim2.new(0, 120, 1, -40)
TabBar.Position = UDim2.new(0, 0, 0, 40)
TabBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TabBar.BorderSizePixel = 0
TabBar.Parent = MainFrame

local TabLayout = Instance.new("UIListLayout")
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.Padding = UDim.new(0, 2)
TabLayout.Parent = TabBar

local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "Content"
ContentFrame.Size = UDim2.new(1, -120, 1, -40)
ContentFrame.Position = UDim2.new(0, 120, 0, 40)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -10, 1, -10)
ScrollFrame.Position = UDim2.new(0, 5, 0, 5)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.Parent = ContentFrame

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 8)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Parent = ScrollFrame

-- Helper Functions
local currentTab = nil

local function CreateTab(name)
    local TabButton = Instance.new("TextButton")
    TabButton.Name = name
    TabButton.Size = UDim2.new(1, 0, 0, 40)
    TabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    TabButton.BorderSizePixel = 0
    TabButton.Text = name
    TabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    TabButton.TextSize = 14
    TabButton.Font = Enum.Font.Gotham
    TabButton.Parent = TabBar

    local TabContent = Instance.new("Frame")
    TabContent.Name = name .. "Content"
    TabContent.Size = UDim2.new(1, 0, 1, 0)
    TabContent.BackgroundTransparency = 1
    TabContent.Visible = false
    TabContent.Parent = ScrollFrame

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Padding = UDim.new(0, 8)
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Parent = TabContent

    TabButton.MouseButton1Click:Connect(function()
        for _, child in pairs(ScrollFrame:GetChildren()) do
            if child:IsA("Frame") then child.Visible = false end
        end
        for _, btn in pairs(TabBar:GetChildren()) do
            if btn:IsA("TextButton") then
                btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            end
        end
        TabButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
        TabContent.Visible = true
        currentTab = TabContent
        ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y + 10)
    end)

    return TabContent
end

local function AddLabel(parent, text)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -10, 0, 25)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextSize = 14
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = parent
end

local function AddToggle(parent, text, callback)
    local Toggle = Instance.new("Frame")
    Toggle.Size = UDim2.new(1, -10, 0, 30)
    Toggle.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Toggle.BorderSizePixel = 0
    Toggle.Parent = parent

    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 6)
    ToggleCorner.Parent = Toggle

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -60, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.TextSize = 13
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Toggle

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 40, 0, 20)
    Button.Position = UDim2.new(1, -50, 0.5, -10)
    Button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Button.BorderSizePixel = 0
    Button.Text = ""
    Button.Parent = Toggle

    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(1, 0)
    ButtonCorner.Parent = Button

    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 16, 0, 16)
    Indicator.Position = UDim2.new(0, 2, 0.5, -8)
    Indicator.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    Indicator.BorderSizePixel = 0
    Indicator.Parent = Button

    local IndicatorCorner = Instance.new("UICorner")
    IndicatorCorner.CornerRadius = UDim.new(1, 0)
    IndicatorCorner.Parent = Indicator

    local state = false
    Button.MouseButton1Click:Connect(function()
        state = not state
        local pos = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        local col = state and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(60, 60, 60)
        TweenService:Create(Indicator, TweenInfo.new(0.2), {Position = pos}):Play()
        TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = col}):Play()
        callback(state)
    end)
end

local function AddButton(parent, text, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -10, 0, 35)
    Button.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    Button.BorderSizePixel = 0
    Button.Text = text
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextSize = 14
    Button.Font = Enum.Font.GothamBold
    Button.Parent = parent

    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 6)
    ButtonCorner.Parent = Button

    Button.MouseButton1Click:Connect(callback)
end

local function AddTextbox(parent, placeholder, callback)
    local Box = Instance.new("TextBox")
    Box.Size = UDim2.new(1, -10, 0, 35)
    Box.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Box.BorderSizePixel = 0
    Box.PlaceholderText = placeholder
    Box.Text = ""
    Box.TextColor3 = Color3.fromRGB(255, 255, 255)
    Box.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    Box.TextSize = 13
    Box.Font = Enum.Font.Gotham
    Box.ClearTextOnFocus = false
    Box.Parent = parent

    local BoxCorner = Instance.new("UICorner")
    BoxCorner.CornerRadius = UDim.new(0, 6)
    BoxCorner.Parent = Box

    Box.FocusLost:Connect(function()
        if Box.Text ~= "" then callback(Box.Text) end
    end)
end

-- Build Tabs
local FarmTab = CreateTab("Farm")
AddLabel(FarmTab, "Click Farming")
AddToggle(FarmTab, "Auto Click", function(state)
    AutoClickEnabled = state
    Notify("Auto Click", state and "Enabled" or "Disabled")
end)
AddTextbox(FarmTab, "Click Speed (0.01)", function(val)
    local num = tonumber(val)
    if num and num > 0 then
        ClickSpeed = num
        Notify("Click Speed", val .. "s")
    end
end)

AddLabel(FarmTab, "Force Multiplier")
AddToggle(FarmTab, "Auto Fuerza", function(state)
    AutoFuerzaEnabled = state
    Notify("Auto Fuerza", state and "Enabled" or "Disabled")
end)
AddTextbox(FarmTab, "Fuerza Value (999999)", function(val)
    local num = tonumber(val)
    if num then
        FuerzaMultiplier = num
        Notify("Fuerza", val)
    end
end)

AddLabel(FarmTab, "Rebirth")
AddToggle(FarmTab, "Auto Rebirth", function(state)
    AutoRebirthEnabled = state
    Notify("Auto Rebirth", state and "Enabled" or "Disabled")
end)
AddTextbox(FarmTab, "Rebirth Delay (5)", function(val)
    local num = tonumber(val)
    if num and num > 0 then
        RebirthDelay = num
        Notify("Rebirth Delay", val .. "s")
    end
end)
AddButton(FarmTab, "Rebirth Once", function()
    fireRemote(RebirthRemote)
    Notify("Rebirth", "Triggered")
end)

-- TAB 2: PETS
local PetTab = CreateTab("Pets")
AddLabel(PetTab, "Auto Hatch")
AddToggle(PetTab, "Auto Hatch Eggs", function(state)
    AutoHatchEnabled = state
    Notify("Auto Hatch", state and "Enabled" or "Disabled")
end)
AddTextbox(PetTab, "Egg Name (BasicEgg)", function(val)
    HatchEggName = val
    Notify("Egg", val)
end)
AddTextbox(PetTab, "Hatch Count (1)", function(val)
    local num = tonumber(val)
    if num and num > 0 then
        HatchCount = num
        Notify("Hatch Count", val)
    end
end)
AddButton(PetTab, "Hatch Once", function()
    local result = fireRemote(HuevoAbrirRemote, HatchEggName)
    Notify("Hatch", result and tostring(result) or "Failed")
end)
AddLabel(PetTab, "Pet Management")
AddButton(PetTab, "Equip All Pets", function()
    for i = 1, 50 do
        pcall(function() fireRemote(PetsSetEquippedRemote, i, true) end)
    end
    Notify("Pets", "Equipped all")
end)

-- TAB 3: TELEPORTS
local TPTab = CreateTab("Teleport")
AddLabel(TPTab, "Weapon Pads (13 Total)")

local weaponPads = {
    {"Pad01 - Rookie Blade", "Pad01"},
    {"Pad02 - Ashen Fang", "Pad02"},
    {"Pad03 - Searing Edge", "Pad03"},
    {"Pad04 - Bloodletter", "Pad04"},
    {"Pad05 - Frostbite", "Pad05"},
    {"Pad06 - Royal Standard", "Pad06"},
    {"Pad07 - Infernal Eye", "Pad07"},
    {"Pad08 - Void Arc", "Pad08"},
    {"Pad09 - Soul Eater", "Pad09"},
    {"Pad10 - Divine Judgment", "Pad10"},
    {"Pad11 - Thunderstrike", "Pad11"},
    {"Pad12 - Amethyst Shard", "Pad12"},
    {"Pad13 - Shadow Sovereign", "Pad13"}
}

for _, pad in pairs(weaponPads) do
    AddButton(TPTab, pad[1], function()
        pcall(function()
            local target = WS.PADS.Pads:FindFirstChild(pad[2])
            if target and target:FindFirstChild("Led") then
                TeleportTo(target.Led.CFrame * CFrame.new(0, 3, 0))
                wait(0.5)
                if target.Led:FindFirstChild("Equipar") and target.Led.Equipar:FindFirstChild("Prompt") then
                    fireproximityprompt(target.Led.Equipar.Prompt)
                end
                Notify("TP", pad[1])
            else
                Notify("Error", "Pad not found")
            end
        end)
    end)
end

AddLabel(TPTab, "Special Locations")

AddButton(TPTab, "Pet Exclusive Shop", function()
    pcall(function()
        local t = WS.Lobby.Interactivos.PetExclusivo.Nucleo
        if t then
            TeleportTo(t.CFrame * CFrame.new(0, 5, 0))
            Notify("TP", "Pet Shop")
        end
    end)
end)

AddButton(TPTab, "Fusion Machine", function()
    pcall(function()
        local t = WS.Lobby.Interactivos.FusionMaquina.Nucleo
        if t then
            TeleportTo(t.CFrame * CFrame.new(0, 5, 0))
            Notify("TP", "Fusion Machine")
        end
    end)
end)

AddButton(TPTab, "Boss Shop", function()
    pcall(function()
        local t = WS.Lobby.Interactivos.TiendaJefe.Cofre.Nucleo
        if t then
            TeleportTo(t.CFrame * CFrame.new(0, 5, 0))
            Notify("TP", "Boss Shop")
        end
    end)
end)

-- TAB 4: MISC
local MiscTab = CreateTab("Misc")
AddLabel(MiscTab, "Combat")
AddToggle(MiscTab, "God Mode", function(state)
    GodModeEnabled = state
    Notify("God Mode", state and "Enabled" or "Disabled")
end)

AddLabel(MiscTab, "Gifts & Items")
AddButton(MiscTab, "Claim All Gifts", function()
    for i = 1, 20 do
        pcall(function() fireRemote(RegaloRemote, i) end)
    end
    Notify("Gifts", "Claimed all")
end)

AddLabel(MiscTab, "Player Controls")
AddButton(MiscTab, "Reset Character", function()
    LP.Character:BreakJoints()
    Notify("Reset", "Character reset")
end)

AddButton(MiscTab, "Rejoin Server", function()
    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LP)
end)

-- TAB 5: CODES
local CodeTab = CreateTab("Codes")
AddLabel(CodeTab, "Redeem Codes")
AddTextbox(CodeTab, "Enter Code", function(val)
    RedeemCode(val)
end)
AddButton(CodeTab, "Redeem All Codes", RedeemAllCodes)
AddLabel(CodeTab, "Common: RELEASE, BETA")
AddLabel(CodeTab, "UPDATE1, FREEPET, SECRET")

-- Initialize First Tab
wait(0.1)
for _, btn in pairs(TabBar:GetChildren()) do
    if btn:IsA("TextButton") then
        btn.MouseButton1Click:Connect(function() end)
        btn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
        break
    end
end

if FarmTab then FarmTab.Visible = true end

Notify("XEXER Suite", "Loaded successfully")
