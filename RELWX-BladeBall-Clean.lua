local cloneref = cloneref or function(o) return o end
local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))
local Workspace = cloneref(game:GetService("Workspace"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local TweenService = cloneref(game:GetService("TweenService"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local Stats = cloneref(game:GetService("Stats"))
local TextService = cloneref(game:GetService("TextService"))
local HttpService = cloneref(game:GetService("HttpService"))
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera or Workspace:FindFirstChildOfClass("Camera")
-- ZWS removed
local function CleanText(str)
    if typeof(str) ~= "string" or str == "" then return str end
    local chars = {}
    local success = pcall(function()
        for _, code in utf8.codes(str) do
            table.insert(chars, utf8.char(code))
        end
    end)
    if not success or #chars == 0 then
        for i = 1, #str do
            table.insert(chars, str:sub(i, i))
        end
    end
    return str
end
local function RandName()
    return "R_" .. tostring(math.random(100000, 999999))
end
local Config = {
    ScriptVersion = "1.9.0",
    UIKeybind = Enum.KeyCode.LeftControl,
    ParryKeybind = Enum.KeyCode.K,
    KeepCrestMinimised = true,
    Notifications = true,
    DeathNotifications = true,
    AutoParry = true,
    Accuracy = 100,
    ParryMode = "Humanized Input",
    CurveMode = "Camera",
    RandomizeAccuracy = false,
    AutoAbilities = false,
    InstantTriggerbot = false,
    VisualParryRing = true,
    BallStatsHUD = true,
    ClientStatsHUD = true,
    ParryRingRadius = 16,
    AutoSpam = true,
    SpamActionsPerSecond = 50,
    AutoSpamDistance = 35,
    SpamBatchMode = "Extremely Fast",
    ManualSpam = false,
    SafeClashRate = true,
    PlayerESP = false,
    PhantomDetection = true,
    TimeHoleDetection = true,
    SlashesOfFuryDetection = true,
    InfinityBallDetection = true,
    DeathSlashDetection = true,
    MovementModifiers = false,
    WalkSpeed = 36,
    JumpPower = 50,
    ImmortalityDesync = true,
    SpeedBypass = true,
    OrbitalAngle = 57,
    PeakHeight = 10,
    DesyncDepth = 8,
    OrbitRadius = 13,
    ClashDistance = 35,
    ClashSpeed = 0.130,
    NormalSpeed = 0.175,
    PingBasedOffset = 1.05,
    BallPrediction = 0.08,
    PredictionHorizon = 0.45,
    BaseWindow = 0.32,
    SpeedWindowFactor = 0.00050,
    MaxWindow = 0.45,
    MinWindow = 0.16,
    MaxRange = 55,
    SameBallLockout = 0.08
}
local autoParryEnabled = false
local LastClick = 0
local LastBallHit = nil
local lastBallVelocity = Vector3.zero
local lastBallAcceleration = Vector3.zero
local lastVelocityTime = 0
local furyCounterActive = false
local timeHoleLock = false
local defaultGameWalkSpeed = 36
local defaultGameJumpPower = 50
local lastTelemetry = {
    time = 0,
    speed = 0,
    distance = 0,
    approachSpeed = 0,
    dot = 0,
    timeToReach = 0,
    curveDelta = 0,
    ping = 60,
    isTarget = false,
    parryTime = 0,
    isClashing = false,
    nearestEnemyDist = 999,
    abilityActive = nil
}
local activeConnections = {}
local rowSearchIndex = {}
local ctrls = {}
local Colors = {
    Background     = Color3.fromRGB(10, 15, 22),
    SidebarBg      = Color3.fromRGB(8, 12, 18),
    BorderPurple   = Color3.fromRGB(0, 200, 255),
    BorderSubtle   = Color3.fromRGB(25, 45, 65),
    Divider        = Color3.fromRGB(20, 35, 50),
    PurplePrimary  = Color3.fromRGB(0, 220, 255),
    PurpleAccent   = Color3.fromRGB(0, 200, 255),
    PurpleMuted    = Color3.fromRGB(80, 150, 180),
    PurpleDark     = Color3.fromRGB(30, 60, 90),
    PurpleGlow     = Color3.fromRGB(100, 230, 255),
    TextMain       = Color3.fromRGB(243, 235, 255),
    TextSecondary  = Color3.fromRGB(186, 172, 212),
    TextMuted      = Color3.fromRGB(130, 115, 160),
    TextDark       = Color3.fromRGB(80, 68, 100),
    ToggleTrackOff = Color3.fromRGB(30, 24, 42),
    ToggleKnobOff  = Color3.fromRGB(90, 75, 115),
    ToggleTrackOn  = Color3.fromRGB(0, 200, 255),
    ToggleKnobOn   = Color3.fromRGB(255, 255, 255),
    SliderTrack    = Color3.fromRGB(28, 22, 40),
    SliderFill     = Color3.fromRGB(0, 200, 255),
    SliderKnob     = Color3.fromRGB(243, 230, 255),
    DropdownBg     = Color3.fromRGB(13, 10, 20),
    DropdownBorder = Color3.fromRGB(54, 38, 82),
    StatusActive   = Color3.fromRGB(52, 211, 153),
    StatusWarn     = Color3.fromRGB(251, 191, 36),
    StatusOff      = Color3.fromRGB(120, 105, 145),
    RowBg          = Color3.fromRGB(20, 16, 28),
    CardBg         = Color3.fromRGB(20, 16, 28),
    CardBgHover    = Color3.fromRGB(26, 20, 36),
    HeaderLine     = Color3.fromRGB(40, 30, 58),
    RingRange      = Color3.fromRGB(0, 200, 255)
}
local function GetSafeParent()
    if gethui then
        local h = gethui()
        if h then return h end
    end
    if syn and syn.protect_gui then
        return CoreGui
    end
    local s, res = pcall(function() return CoreGui end)
    if s and res then return res end
    return LocalPlayer:WaitForChild("PlayerGui")
end
local safeParent = GetSafeParent()
if getgenv then
    if getgenv()._relwx_ui then
        pcall(function()
            getgenv()._relwx_ui:Destroy()
        end)
    end
end
local screenGui = Instance.new("ScreenGui")
screenGui.Name = RandName()
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
if getgenv then
    getgenv()._relwx_ui = screenGui
end
if syn and syn.protect_gui then
    pcall(syn.protect_gui, screenGui)
elseif protectgui then
    pcall(protectgui, screenGui)
end
screenGui.Parent = safeParent
local function GetLiveBall()
    local ballsFolder = Workspace:FindFirstChild("Balls")
    if ballsFolder then
        local found = ballsFolder:FindFirstChildOfClass("BasePart") or ballsFolder:FindFirstChildOfClass("MeshPart")
        if found then return found end
        for _, child in ipairs(ballsFolder:GetChildren()) do
            if child:IsA("BasePart") then
                return child
            elseif child:IsA("Model") and child.PrimaryPart then
                return child.PrimaryPart
            end
        end
    end
    return Workspace:FindFirstChild("Ball") or Workspace:FindFirstChild("RealBall")
end
local peakBallSpeed = 0
local frameCount = 0
local lastFpsUpdate = tick()
local currentFps = 165
local scriptCpuLoad = 5
local function MakeDraggable(guiObject, dragHandle)
    local dragging = false
    local dragInput, dragStart, startPos
    dragHandle = dragHandle or guiObject
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = guiObject.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    guiObject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            guiObject.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end
local ballStatsFrame = Instance.new("Frame")
ballStatsFrame.Name = RandName()
ballStatsFrame.Size = UDim2.new(0, 215, 0, 88)
ballStatsFrame.Position = UDim2.new(1, -235, 0, 22)
ballStatsFrame.BackgroundColor3 = Color3.fromRGB(15, 12, 24)
ballStatsFrame.BackgroundTransparency = 0.08
ballStatsFrame.BorderSizePixel = 0
ballStatsFrame.ZIndex = 120
ballStatsFrame.Visible = Config.BallStatsHUD
ballStatsFrame.Parent = screenGui
local ballStatsCorner = Instance.new("UICorner")
ballStatsCorner.CornerRadius = UDim.new(0, 7)
ballStatsCorner.Parent = ballStatsFrame
local ballStatsStroke = Instance.new("UIStroke")
ballStatsStroke.Color = Color3.fromRGB(0, 200, 255)
ballStatsStroke.Thickness = 1.0
ballStatsStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
ballStatsStroke.Parent = ballStatsFrame
local ballStatsHeader = Instance.new("Frame")
ballStatsHeader.Name = RandName()
ballStatsHeader.Size = UDim2.new(1, 0, 0, 26)
ballStatsHeader.BackgroundColor3 = Color3.fromRGB(22, 16, 36)
ballStatsHeader.BorderSizePixel = 0
ballStatsHeader.ZIndex = 121
ballStatsHeader.Parent = ballStatsFrame
local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 7)
headerCorner.Parent = ballStatsHeader
local headerSquareFix = Instance.new("Frame")
headerSquareFix.Name = RandName()
headerSquareFix.Size = UDim2.new(1, 0, 0, 8)
headerSquareFix.Position = UDim2.new(0, 0, 1, -8)
headerSquareFix.BackgroundColor3 = Color3.fromRGB(22, 16, 36)
headerSquareFix.BorderSizePixel = 0
headerSquareFix.ZIndex = 121
headerSquareFix.Parent = ballStatsHeader
local ballCrest = Instance.new("TextLabel")
ballCrest.Name = RandName()
ballCrest.Size = UDim2.new(0, 18, 1, 0)
ballCrest.Position = UDim2.new(0, 10, 0, 0)
ballCrest.BackgroundTransparency = 1
ballCrest.Text = "◈"
ballCrest.TextColor3 = Color3.fromRGB(100, 230, 255)
ballCrest.TextSize = 11
ballCrest.Font = Enum.Font.GothamBold
ballCrest.ZIndex = 122
ballCrest.Parent = ballStatsHeader
local ballStatsTitle = Instance.new("TextLabel")
ballStatsTitle.Name = RandName()
ballStatsTitle.Size = UDim2.new(1, -35, 1, 0)
ballStatsTitle.Position = UDim2.new(0, 26, 0, 0)
ballStatsTitle.BackgroundTransparency = 1
ballStatsTitle.Text = CleanText("BALL TELEMETRY")
ballStatsTitle.TextColor3 = Color3.fromRGB(235, 215, 255)
ballStatsTitle.TextSize = 10
ballStatsTitle.Font = Enum.Font.GothamBold
ballStatsTitle.TextXAlignment = Enum.TextXAlignment.Left
ballStatsTitle.ZIndex = 122
ballStatsTitle.Parent = ballStatsHeader
MakeDraggable(ballStatsFrame, ballStatsHeader)
local currentSpeedLabel = Instance.new("TextLabel")
currentSpeedLabel.Name = RandName()
currentSpeedLabel.Size = UDim2.new(0, 110, 0, 18)
currentSpeedLabel.Position = UDim2.new(0, 12, 0, 34)
currentSpeedLabel.BackgroundTransparency = 1
currentSpeedLabel.Text = CleanText("CURRENT VELOCITY")
currentSpeedLabel.TextColor3 = Color3.fromRGB(150, 135, 180)
currentSpeedLabel.TextSize = 9
currentSpeedLabel.Font = Enum.Font.GothamBold
currentSpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
currentSpeedLabel.ZIndex = 121
currentSpeedLabel.Parent = ballStatsFrame
local currentSpeedValue = Instance.new("TextLabel")
currentSpeedValue.Name = RandName()
currentSpeedValue.Size = UDim2.new(0, 75, 0, 18)
currentSpeedValue.Position = UDim2.new(1, -85, 0, 34)
currentSpeedValue.BackgroundTransparency = 1
currentSpeedValue.Text = CleanText("0 studs/s")
currentSpeedValue.TextColor3 = Color3.fromRGB(255, 255, 255)
currentSpeedValue.TextSize = 11
currentSpeedValue.Font = Enum.Font.GothamBold
currentSpeedValue.TextXAlignment = Enum.TextXAlignment.Right
currentSpeedValue.ZIndex = 121
currentSpeedValue.Parent = ballStatsFrame
local peakSpeedLabel = Instance.new("TextLabel")
peakSpeedLabel.Name = RandName()
peakSpeedLabel.Size = UDim2.new(0, 110, 0, 18)
peakSpeedLabel.Position = UDim2.new(0, 12, 0, 58)
peakSpeedLabel.BackgroundTransparency = 1
peakSpeedLabel.Text = CleanText("PEAK RECORDED")
peakSpeedLabel.TextColor3 = Color3.fromRGB(150, 135, 180)
peakSpeedLabel.TextSize = 9
peakSpeedLabel.Font = Enum.Font.GothamBold
peakSpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
peakSpeedLabel.ZIndex = 121
peakSpeedLabel.Parent = ballStatsFrame
local peakSpeedValue = Instance.new("TextLabel")
peakSpeedValue.Name = RandName()
peakSpeedValue.Size = UDim2.new(0, 75, 0, 18)
peakSpeedValue.Position = UDim2.new(1, -85, 0, 58)
peakSpeedValue.BackgroundTransparency = 1
peakSpeedValue.Text = CleanText("0 studs/s")
peakSpeedValue.TextColor3 = Color3.fromRGB(0, 220, 255)
peakSpeedValue.TextSize = 11
peakSpeedValue.Font = Enum.Font.GothamBold
peakSpeedValue.TextXAlignment = Enum.TextXAlignment.Right
peakSpeedValue.ZIndex = 121
peakSpeedValue.Parent = ballStatsFrame
local clientStatsFrame = Instance.new("Frame")
clientStatsFrame.Name = RandName()
clientStatsFrame.Size = UDim2.new(0, 280, 0, 68)
clientStatsFrame.Position = UDim2.new(1, -300, 0, 118)
clientStatsFrame.BackgroundColor3 = Color3.fromRGB(15, 12, 24)
clientStatsFrame.BackgroundTransparency = 0.08
clientStatsFrame.BorderSizePixel = 0
clientStatsFrame.ZIndex = 120
clientStatsFrame.Visible = Config.ClientStatsHUD
clientStatsFrame.Parent = screenGui
local clientStatsCorner = Instance.new("UICorner")
clientStatsCorner.CornerRadius = UDim.new(0, 7)
clientStatsCorner.Parent = clientStatsFrame
local clientStatsStroke = Instance.new("UIStroke")
clientStatsStroke.Color = Color3.fromRGB(0, 200, 255)
clientStatsStroke.Thickness = 1.0
clientStatsStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
clientStatsStroke.Parent = clientStatsFrame
local clientStatsHeader = Instance.new("Frame")
clientStatsHeader.Name = RandName()
clientStatsHeader.Size = UDim2.new(1, 0, 0, 24)
clientStatsHeader.BackgroundColor3 = Color3.fromRGB(22, 16, 36)
clientStatsHeader.BorderSizePixel = 0
clientStatsHeader.ZIndex = 121
clientStatsHeader.Parent = clientStatsFrame
local clientHeaderCorner = Instance.new("UICorner")
clientHeaderCorner.CornerRadius = UDim.new(0, 7)
clientHeaderCorner.Parent = clientStatsHeader
local clientHeaderSquareFix = Instance.new("Frame")
clientHeaderSquareFix.Name = RandName()
clientHeaderSquareFix.Size = UDim2.new(1, 0, 0, 8)
clientHeaderSquareFix.Position = UDim2.new(0, 0, 1, -8)
clientHeaderSquareFix.BackgroundColor3 = Color3.fromRGB(22, 16, 36)
clientHeaderSquareFix.BorderSizePixel = 0
clientHeaderSquareFix.ZIndex = 121
clientHeaderSquareFix.Parent = clientStatsHeader
local clientCrest = Instance.new("TextLabel")
clientCrest.Name = RandName()
clientCrest.Size = UDim2.new(0, 18, 1, 0)
clientCrest.Position = UDim2.new(0, 10, 0, 0)
clientCrest.BackgroundTransparency = 1
clientCrest.Text = "◈"
clientCrest.TextColor3 = Color3.fromRGB(100, 230, 255)
clientCrest.TextSize = 11
clientCrest.Font = Enum.Font.GothamBold
clientCrest.ZIndex = 122
clientCrest.Parent = clientStatsHeader
local clientStatsTitle = Instance.new("TextLabel")
clientStatsTitle.Name = RandName()
clientStatsTitle.Size = UDim2.new(1, -35, 1, 0)
clientStatsTitle.Position = UDim2.new(0, 26, 0, 0)
clientStatsTitle.BackgroundTransparency = 1
clientStatsTitle.Text = CleanText("SYSTEM METRICS")
clientStatsTitle.TextColor3 = Color3.fromRGB(235, 215, 255)
clientStatsTitle.TextSize = 10
clientStatsTitle.Font = Enum.Font.GothamBold
clientStatsTitle.TextXAlignment = Enum.TextXAlignment.Left
clientStatsTitle.ZIndex = 122
clientStatsTitle.Parent = clientStatsHeader
MakeDraggable(clientStatsFrame, clientStatsHeader)
local statsRow = Instance.new("Frame")
statsRow.Name = RandName()
statsRow.Size = UDim2.new(1, -20, 0, 30)
statsRow.Position = UDim2.new(0, 10, 0, 30)
statsRow.BackgroundTransparency = 1
statsRow.ZIndex = 121
statsRow.Parent = clientStatsFrame
local fpsLabel = Instance.new("TextLabel")
fpsLabel.Name = RandName()
fpsLabel.Size = UDim2.new(0.33, 0, 1, 0)
fpsLabel.Position = UDim2.new(0, 0, 0, 0)
fpsLabel.BackgroundTransparency = 1
fpsLabel.Text = CleanText("165 FPS")
fpsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
fpsLabel.TextSize = 11
fpsLabel.Font = Enum.Font.GothamBold
fpsLabel.TextXAlignment = Enum.TextXAlignment.Left
fpsLabel.ZIndex = 122
fpsLabel.Parent = statsRow
local pingLabel = Instance.new("TextLabel")
pingLabel.Name = RandName()
pingLabel.Size = UDim2.new(0.33, 0, 1, 0)
pingLabel.Position = UDim2.new(0.33, 0, 0, 0)
pingLabel.BackgroundTransparency = 1
pingLabel.Text = CleanText("32ms PING")
pingLabel.TextColor3 = Color3.fromRGB(0, 220, 255)
pingLabel.TextSize = 11
pingLabel.Font = Enum.Font.GothamBold
pingLabel.TextXAlignment = Enum.TextXAlignment.Center
pingLabel.ZIndex = 122
pingLabel.Parent = statsRow
local cpuLabel = Instance.new("TextLabel")
cpuLabel.Name = RandName()
cpuLabel.Size = UDim2.new(0.33, 0, 1, 0)
cpuLabel.Position = UDim2.new(0.66, 0, 0, 0)
cpuLabel.BackgroundTransparency = 1
cpuLabel.Text = CleanText("6% LOAD")
cpuLabel.TextColor3 = Color3.fromRGB(52, 211, 153)
cpuLabel.TextSize = 11
cpuLabel.Font = Enum.Font.GothamBold
cpuLabel.TextXAlignment = Enum.TextXAlignment.Right
cpuLabel.ZIndex = 122
cpuLabel.Parent = statsRow
table.insert(activeConnections, RunService.RenderStepped:Connect(function(dt)
    frameCount = frameCount + 1
    local now = tick()
    if (now - lastFpsUpdate) >= 0.5 then
        currentFps = math.floor(frameCount / (now - lastFpsUpdate))
        frameCount = 0
        lastFpsUpdate = now
        local curDt = dt or 0.016
        scriptCpuLoad = math.clamp(math.floor((curDt / 0.0166) * 7.5 + (math.random(-1, 2))), 3, 24)
    end
    if Config.BallStatsHUD and ballStatsFrame.Visible then
        local liveBall = GetLiveBall()
        local curSpd = 0
        if liveBall then
            local v = liveBall.AssemblyLinearVelocity
            if not v or v.Magnitude == 0 then
                v = liveBall.Velocity or Vector3.zero
            end
            local zoomies = liveBall:FindFirstChild("zoomies")
            if zoomies and (zoomies:IsA("LinearVelocity") or zoomies:IsA("VectorForce")) then
                v = zoomies.VectorVelocity
            end
            curSpd = math.floor(v.Magnitude)
        elseif lastTelemetry.speed > 0 then
            curSpd = math.floor(lastTelemetry.speed)
        end
        if curSpd > peakBallSpeed then
            peakBallSpeed = curSpd
        end
        currentSpeedValue.Text = CleanText(tostring(curSpd) .. " studs/s")
        peakSpeedValue.Text = CleanText(tostring(peakBallSpeed) .. " studs/s")
    end
    if Config.ClientStatsHUD and clientStatsFrame.Visible then
        fpsLabel.Text = CleanText(tostring(currentFps) .. " FPS")
        pingLabel.Text = CleanText(tostring(math.floor(lastTelemetry.ping or 32)) .. "ms PING")
        cpuLabel.Text = CleanText(tostring(scriptCpuLoad) .. "% LOAD")
    end
end))
local CONFIG_DIR = "RELWX HUB"
local CONFIG_FILE = "RELWX HUB/BladeBall_default.json"
local LEGACY_CONFIG_FILE = "RELWX HUB_BladeBall_default.json"
local function GetConfigFilePath()
    if makefolder and isfolder then
        pcall(function()
            if not isfolder(CONFIG_DIR) then
                makefolder(CONFIG_DIR)
            end
        end)
        return CONFIG_FILE
    end
    return LEGACY_CONFIG_FILE
end
local function SerializeConfig()
    local tbl = {}
    for k, v in pairs(Config) do
        if typeof(v) == "EnumItem" then
            tbl[k] = v.Name
        else
            tbl[k] = v
        end
    end
    return tbl
end
local isSaving = false
local function AutoSaveConfig()
    if not writefile then return end
    if isSaving then return end
    isSaving = true
    task.delay(0.25, function()
        pcall(function()
            local path = GetConfigFilePath()
            local data = SerializeConfig()
            local json = HttpService:JSONEncode(data)
            writefile(path, json)
        end)
        isSaving = false
    end)
end
local function LoadSavedConfig()
    if not readfile or not isfile then return false end
    local filePath = GetConfigFilePath()
    local path = isfile(filePath) and filePath or (isfile(LEGACY_CONFIG_FILE) and LEGACY_CONFIG_FILE or nil)
    if not path then return false end
    local success, raw = pcall(readfile, path)
    if not success or not raw or raw == "" then return false end
    local decodeOk, data = pcall(function()
        return HttpService:JSONDecode(raw)
    end)
    if not decodeOk or typeof(data) ~= "table" then return false end
    for k, v in pairs(data) do
        if Config[k] ~= nil then
            if k == "UIKeybind" or k == "ParryKeybind" then
                if Enum.KeyCode[v] then
                    Config[k] = Enum.KeyCode[v]
                end
            elseif typeof(Config[k]) == typeof(v) then
                Config[k] = v
            end
        end
    end
    if Config.ClashSpeed and Config.ClashSpeed < 0.095 then
        Config.ClashSpeed = 0.105
    end
    Config.ParryRingRadius = 16
    Config.SafeClashRate = true
    return true
end
local function CreateToastNotification(title, message, duration)
    pcall(function()
        local toast = Instance.new("Frame")
        toast.Name = RandName()
        toast.Size = UDim2.new(0, 340, 0, 48)
        toast.Position = UDim2.new(0.5, -170, 0, -60)
        toast.BackgroundColor3 = Color3.fromRGB(20, 15, 30)
        toast.BorderSizePixel = 0
        toast.ZIndex = 250
        toast.Parent = screenGui
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = toast
        local stroke = Instance.new("UIStroke")
        stroke.Color = Colors.PurpleAccent
        stroke.Thickness = 1.2
        stroke.Parent = toast
        local icon = Instance.new("TextLabel")
        icon.Size = UDim2.new(0, 36, 1, 0)
        icon.BackgroundTransparency = 1
        icon.Text = "!"
        icon.TextColor3 = Colors.PurplePrimary
        icon.Font = Enum.Font.GothamBold
        icon.TextSize = 18
        icon.ZIndex = 251
        icon.Parent = toast
        local titleLbl = Instance.new("TextLabel")
        titleLbl.Size = UDim2.new(1, -44, 0, 18)
        titleLbl.Position = UDim2.new(0, 38, 0, 5)
        titleLbl.BackgroundTransparency = 1
        titleLbl.Text = CleanText(title)
        titleLbl.TextColor3 = Colors.PurplePrimary
        titleLbl.TextSize = 11
        titleLbl.Font = Enum.Font.GothamBold
        titleLbl.TextXAlignment = Enum.TextXAlignment.Left
        titleLbl.ZIndex = 251
        titleLbl.Parent = toast
        local msgLbl = Instance.new("TextLabel")
        msgLbl.Size = UDim2.new(1, -44, 0, 20)
        msgLbl.Position = UDim2.new(0, 38, 0, 23)
        msgLbl.BackgroundTransparency = 1
        msgLbl.Text = CleanText(message)
        msgLbl.TextColor3 = Colors.TextMain
        msgLbl.TextSize = 10
        msgLbl.Font = Enum.Font.Gotham
        msgLbl.TextXAlignment = Enum.TextXAlignment.Left
        msgLbl.TextTruncate = Enum.TextTruncate.AtEnd
        msgLbl.ZIndex = 251
        msgLbl.Parent = toast
        TweenService:Create(toast, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = UDim2.new(0.5, -170, 0, 24)
        }):Play()
        task.delay(duration or 3.5, function()
            local tween = TweenService:Create(toast, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                {
                    Position = UDim2.new(0.5, -170, 0, -60),
                    BackgroundTransparency = 1
                })
            tween:Play()
            tween.Completed:Connect(function()
                toast:Destroy()
            end)
        end)
    end)
end
local function SendNotification(titleText, text, duration)
    if not Config.Notifications then return end
    CreateToastNotification(titleText, text, duration)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = titleText,
            Text = text,
            Duration = duration or 2
        })
    end)
end
local lastDeathTime = 0
local latestDeathReasonRow = nil
local function OnPlayerDied()
    local now = tick()
    if (now - lastDeathTime) < 2.5 then return end
    lastDeathTime = now
    if not Config.DeathNotifications then return end
    local reason = "Unknown"
    local timeSinceThreat = now - (lastTelemetry.time or 0)
    local timeSinceParry = now - (lastTelemetry.parryTime or 0)
    local isConfirmedClash = lastTelemetry.isClashing and (lastTelemetry.nearestEnemyDist <= (Config.ClashDistance + 8))
    if not Config.AutoParry then
        reason = "Auto Parry was DISABLED."
    elseif lastTelemetry.time == 0 then
        reason = "Eliminated (Outside active ball threat range)."
    elseif lastTelemetry.abilityActive then
        reason = "Ability Disruption: " .. tostring(lastTelemetry.abilityActive) .. "."
    elseif isConfirmedClash and timeSinceParry < 0.12 then
        reason = string.format("Clash Lockout: Input debounce during clash (Parried %.2fs ago, Enemy %d studs).",
            timeSinceParry, math.floor(lastTelemetry.nearestEnemyDist))
    elseif isConfirmedClash and timeSinceParry < 0.25 then
        reason = string.format("Clash Defeat: Opponent out-timed parry in clash (%d studs/s speed).",
            math.floor(lastTelemetry.speed))
    elseif lastTelemetry.curveDelta > 28 then
        reason = string.format("Heavy Curve: Ball snapped trajectory (%d studs/s curve).",
            math.floor(lastTelemetry.curveDelta))
    elseif lastTelemetry.speed >= 150 then
        reason = string.format("Extreme Speed: %d studs/s exceeded reaction window (%dms ping).",
            math.floor(lastTelemetry.speed), lastTelemetry.ping)
    elseif lastTelemetry.distance < 22 and not lastTelemetry.isTarget then
        reason = string.format("Point-Blank Redirect: Ball target switched at %d studs.",
            math.floor(lastTelemetry.distance))
    elseif timeSinceParry < 0.18 then
        reason = string.format("Ping / Desync Latency: Parried %.2fs before death (%dms ping delay).", timeSinceParry,
            lastTelemetry.ping)
    elseif timeSinceParry < 0.40 then
        reason = string.format("Late Timing: Parried %.2fs before impact (Speed %d studs/s).", timeSinceParry,
            math.floor(lastTelemetry.speed))
    elseif timeSinceThreat > 4.5 and lastTelemetry.distance > 80 then
        reason = "Eliminated (Outside active ball threat range)."
    elseif lastTelemetry.ping > 125 then
        reason = string.format("Ping Spike: Network latency delay (%dms ping).", lastTelemetry.ping)
    else
        reason = string.format("Missed Window: Speed %d studs/s, Dist %d studs, Ping %dms.",
            math.floor(lastTelemetry.speed), math.floor(lastTelemetry.distance), lastTelemetry.ping)
    end
    CreateToastNotification("RELWX HUB Death Diagnostic", reason, 4.5)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Miss / Death Diagnostic",
            Text = reason,
            Duration = 4.5
        })
    end)
    if latestDeathReasonRow and latestDeathReasonRow.SetValue then
        latestDeathReasonRow.SetValue(reason)
    end
end
local ringAdornment = Instance.new("CylinderHandleAdornment")
ringAdornment.Name = RandName()
ringAdornment.Height = 0.05
ringAdornment.Radius = Config.ClashDistance
ringAdornment.InnerRadius = math.max(0.1, Config.ClashDistance - 0.4)
ringAdornment.Color3 = Colors.PurpleAccent
ringAdornment.Transparency = 0.35
ringAdornment.AlwaysOnTop = true
ringAdornment.ZIndex = 5
ringAdornment.CFrame = CFrame.Angles(math.rad(90), 0, 0) * CFrame.new(0, 0, 2.7)
ringAdornment.Visible = false
ringAdornment.Parent = screenGui
local desyncBubbleAdornment = Instance.new("SphereHandleAdornment")
desyncBubbleAdornment.Name = RandName()
desyncBubbleAdornment.Radius = Config.OrbitRadius
desyncBubbleAdornment.Color3 = Color3.fromRGB(0, 200, 255)
desyncBubbleAdornment.Transparency = 0.65
desyncBubbleAdornment.AlwaysOnTop = false
desyncBubbleAdornment.ZIndex = 4
desyncBubbleAdornment.Visible = false
desyncBubbleAdornment.Parent = screenGui
local function IsPlayerInMatch()
    local char = LocalPlayer.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    local alive = Workspace:FindFirstChild("Alive")
    if alive then
        return (char.Parent == alive or char:IsDescendantOf(alive) or alive:FindFirstChild(char.Name) ~= nil)
    end
    local dead = Workspace:FindFirstChild("Dead")
    if dead and (char.Parent == dead or char:IsDescendantOf(dead)) then
        return false
    end
    return false
end
local function GetNearestAliveEnemy(myPos)
    local aliveFolder = Workspace:FindFirstChild("Alive")
    local closestDist = math.huge
    local closestChar = nil
    local myChar = LocalPlayer.Character
    if aliveFolder then
        for _, c in ipairs(aliveFolder:GetChildren()) do
            if c:IsA("Model") and c ~= myChar then
                local hum = c:FindFirstChildOfClass("Humanoid")
                local root = c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Head") or c.PrimaryPart
                if root and (not hum or hum.Health > 0) then
                    local d = (root.Position - myPos).Magnitude
                    if d < closestDist then
                        closestDist = d
                        closestChar = c
                    end
                end
            end
        end
    else
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character ~= myChar then
                local c = p.Character
                local hum = c:FindFirstChildOfClass("Humanoid")
                local root = c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Head") or c.PrimaryPart
                if root and (not hum or hum.Health > 0) then
                    local d = (root.Position - myPos).Magnitude
                    if d < closestDist then
                        closestDist = d
                        closestChar = c
                    end
                end
            end
        end
    end
    return closestDist, closestChar
end
local espFolder = Instance.new("Folder")
espFolder.Name = RandName()
espFolder.Parent = screenGui
local function GetPlayerAbility(player, char)
    local abResult = "Default"
    pcall(function()
        if player then
            local ab = player:GetAttribute("CurrentlyEquippedAbility")
                or player:GetAttribute("EquippedAbility")
                or player:GetAttribute("Ability")
                or player:GetAttribute("selectedAbility")
                or player:GetAttribute("ability")
            if ab and typeof(ab) == "string" and ab ~= "" then
                abResult = ab
                return
            end
        end
        if char then
            local ab = char:GetAttribute("CurrentlyEquippedAbility")
                or char:GetAttribute("EquippedAbility")
                or char:GetAttribute("Ability")
                or char:GetAttribute("ability")
            if ab and typeof(ab) == "string" and ab ~= "" then
                abResult = ab
                return
            end
        end
    end)
    return abResult
end
local lastEspUpdate = 0
local function UpdatePlayerESP(force)
    if not Config.PlayerESP or not IsPlayerInMatch() then
        espFolder:ClearAllChildren()
        return
    end
    local now = tick()
    if not force and (now - lastEspUpdate) < 0.25 then return end
    lastEspUpdate = now
    pcall(function()
        local myChar = LocalPlayer.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        local ball = Workspace:FindFirstChild("Balls") and Workspace.Balls:FindFirstChildOfClass("BasePart")
        local ballTarget = ball and
            (ball:GetAttribute("target") or ball:GetAttribute("Target") or ball:GetAttribute("currentTarget") or ball:GetAttribute("to"))
        local aliveFolder = Workspace:FindFirstChild("Alive")
        if not aliveFolder then
            espFolder:ClearAllChildren()
            return
        end
        local candidates = {}
        for _, c in ipairs(aliveFolder:GetChildren()) do
            if c:IsA("Model") and c ~= myChar then
                local p = Players:GetPlayerFromCharacter(c) or { Name = c.Name, DisplayName = c.Name }
                table.insert(candidates, { Player = p, Character = c })
            end
        end
        local seenNames = {}
        for _, item in ipairs(candidates) do
            local p = item.Player
            local c = item.Character
            local head = c:FindFirstChild("Head") or c:FindFirstChild("HumanoidRootPart")
            if head then
                seenNames[p.Name] = true
                local bb = espFolder:FindFirstChild(p.Name)
                if not bb then
                    bb = Instance.new("BillboardGui")
                    bb.Name = p.Name
                    bb.Adornee = head
                    bb.Size = UDim2.new(0, 180, 0, 40)
                    bb.StudsOffset = Vector3.new(0, 3.2, 0)
                    bb.AlwaysOnTop = true
                    bb.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                    bb.Parent = espFolder
                    local nameLbl = Instance.new("TextLabel")
                    nameLbl.Name = "NameLbl"
                    nameLbl.Size = UDim2.new(1, 0, 0, 18)
                    nameLbl.Position = UDim2.new(0, 0, 0, 0)
                    nameLbl.BackgroundTransparency = 1
                    nameLbl.TextColor3 = Colors.TextMain
                    nameLbl.TextSize = 11
                    nameLbl.Font = Enum.Font.GothamBold
                    nameLbl.TextStrokeTransparency = 0.4
                    nameLbl.TextStrokeColor3 = Color3.fromRGB(15, 10, 25)
                    nameLbl.Parent = bb
                    local abilityLbl = Instance.new("TextLabel")
                    abilityLbl.Name = "AbilityLbl"
                    abilityLbl.Size = UDim2.new(1, 0, 0, 16)
                    abilityLbl.Position = UDim2.new(0, 0, 0, 18)
                    abilityLbl.BackgroundTransparency = 1
                    abilityLbl.TextColor3 = Colors.PurplePrimary
                    abilityLbl.TextSize = 10
                    abilityLbl.Font = Enum.Font.GothamMedium
                    abilityLbl.TextStrokeTransparency = 0.4
                    abilityLbl.TextStrokeColor3 = Color3.fromRGB(15, 10, 25)
                    abilityLbl.Parent = bb
                end
                bb.Adornee = head
                local dist = 0
                if myRoot and head then
                    dist = math.floor((head.Position - myRoot.Position).Magnitude)
                end
                local isTargeted = (ballTarget ~= nil and (ballTarget == p.Name or ballTarget == p.DisplayName or ballTarget == c.Name))
                local nameLbl = bb:FindFirstChild("NameLbl")
                local abilityLbl = bb:FindFirstChild("AbilityLbl")
                if nameLbl then
                    local prefix = isTargeted and "[TARGET] " or ""
                    nameLbl.Text = prefix .. (p.DisplayName or p.Name) .. string.format(" [%d studs]", dist)
                    nameLbl.TextColor3 = isTargeted and Color3.fromRGB(255, 80, 110) or Colors.TextMain
                end
                if abilityLbl then
                    local abName = GetPlayerAbility(p, c)
                    abilityLbl.Text = " " .. abName
                    abilityLbl.TextColor3 = isTargeted and Color3.fromRGB(255, 180, 200) or Colors.PurplePrimary
                end
            end
        end
        for _, child in ipairs(espFolder:GetChildren()) do
            if not seenNames[child.Name] then
                child:Destroy()
            end
        end
    end)
end
local function UpdateVisualRings()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if Config.VisualParryRing and root and IsPlayerInMatch() then
        local blockRad = 16
        ringAdornment.Adornee = root
        ringAdornment.Radius = blockRad
        ringAdornment.InnerRadius = math.max(0.1, blockRad - 0.35)
        ringAdornment.Visible = true
    else
        ringAdornment.Visible = false
    end
    if Config.ImmortalityDesync and root and IsPlayerInMatch() then
        desyncBubbleAdornment.Adornee = root
        desyncBubbleAdornment.Radius = Config.OrbitRadius
        desyncBubbleAdornment.Visible = true
    else
        desyncBubbleAdornment.Visible = false
    end
end
local mainFrame = Instance.new("Frame")
mainFrame.Name = RandName()
mainFrame.Size = UDim2.new(0, 680, 0, 460)
mainFrame.Position = UDim2.new(0.5, -340, 0.5, -230)
mainFrame.BackgroundColor3 = Colors.Background
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.ClipsDescendants = false
mainFrame.Parent = screenGui
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 4)
mainCorner.Parent = mainFrame
local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Colors.BorderPurple
mainStroke.Thickness = 1.2
mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
mainStroke.Parent = mainFrame
local miniCrest = Instance.new("TextButton")
miniCrest.Name = RandName()
miniCrest.Size = UDim2.new(0, 42, 0, 42)
miniCrest.Position = UDim2.new(0, 20, 0.5, -21)
miniCrest.BackgroundColor3 = Color3.fromRGB(16, 12, 26)
miniCrest.AutoButtonColor = false
miniCrest.Text = ""
miniCrest.Visible = Config.KeepCrestMinimised
miniCrest.Active = true
miniCrest.ZIndex = 100
miniCrest.Parent = screenGui
local miniCrestCorner = Instance.new("UICorner")
miniCrestCorner.CornerRadius = UDim.new(1, 0)
miniCrestCorner.Parent = miniCrest
local miniCrestStroke = Instance.new("UIStroke")
miniCrestStroke.Color = Colors.PurplePrimary
miniCrestStroke.Thickness = 1.5
miniCrestStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
miniCrestStroke.Parent = miniCrest
local miniCrestLabel = Instance.new("TextLabel")
miniCrestLabel.Name = RandName()
miniCrestLabel.Size = UDim2.new(1, 0, 1, 0)
miniCrestLabel.BackgroundTransparency = 1
miniCrestLabel.Text = CleanText("◆")
miniCrestLabel.TextColor3 = Colors.PurplePrimary
miniCrestLabel.TextSize = 18
miniCrestLabel.Font = Enum.Font.GothamBold
miniCrestLabel.Parent = miniCrest
local topBar = Instance.new("Frame")
topBar.Name = RandName()
topBar.Size = UDim2.new(1, 0, 0, 38)
topBar.BackgroundTransparency = 1
topBar.Parent = mainFrame
local crest = Instance.new("Frame")
crest.Name = RandName()
crest.Size = UDim2.new(0, 22, 0, 22)
crest.Position = UDim2.new(0, 14, 0.5, -11)
crest.BackgroundColor3 = Colors.CardBg
crest.BorderSizePixel = 0
crest.Parent = topBar
local crestCorner = Instance.new("UICorner")
crestCorner.CornerRadius = UDim.new(1, 0)
crestCorner.Parent = crest
local crestStroke = Instance.new("UIStroke")
crestStroke.Color = Colors.PurpleAccent
crestStroke.Thickness = 1
crestStroke.Parent = crest
local crestLabel = Instance.new("TextLabel")
crestLabel.Name = RandName()
crestLabel.Size = UDim2.new(1, 0, 1, 0)
crestLabel.BackgroundTransparency = 1
crestLabel.Text = CleanText("I")
crestLabel.TextColor3 = Colors.PurplePrimary
crestLabel.TextSize = 11
crestLabel.Font = Enum.Font.GothamBold
crestLabel.Parent = crest
local brandLabel = Instance.new("TextLabel")
brandLabel.Name = RandName()
brandLabel.Size = UDim2.new(0, 92, 1, 0)
brandLabel.Position = UDim2.new(0, 44, 0, 0)
brandLabel.BackgroundTransparency = 1
brandLabel.Text = CleanText("RELWX HUB")
brandLabel.TextColor3 = Color3.fromRGB(230, 205, 255)
brandLabel.TextSize = 13
brandLabel.Font = Enum.Font.GothamBold
brandLabel.TextXAlignment = Enum.TextXAlignment.Left
brandLabel.Parent = topBar
local topPipe = Instance.new("TextLabel")
topPipe.Name = RandName()
topPipe.Size = UDim2.new(0, 12, 1, 0)
topPipe.Position = UDim2.new(0, 138, 0, 0)
topPipe.BackgroundTransparency = 1
topPipe.Text = CleanText("|")
topPipe.TextColor3 = Color3.fromRGB(85, 68, 110)
topPipe.TextSize = 12
topPipe.Font = Enum.Font.GothamMedium
topPipe.Parent = topBar
local gameLabel = Instance.new("TextLabel")
gameLabel.Name = RandName()
gameLabel.Size = UDim2.new(0, 120, 1, 0)
gameLabel.Position = UDim2.new(0, 154, 0, 0)
gameLabel.BackgroundTransparency = 1
gameLabel.Text = CleanText("Blade Ball")
gameLabel.TextColor3 = Colors.TextSecondary
gameLabel.TextSize = 12
gameLabel.Font = Enum.Font.Gotham
gameLabel.TextXAlignment = Enum.TextXAlignment.Left
gameLabel.Parent = topBar
local closeBtn = Instance.new("TextButton")
closeBtn.Name = RandName()
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -34, 0.5, -14)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "✕"
closeBtn.TextColor3 = Colors.TextSecondary
closeBtn.TextSize = 12
closeBtn.Font = Enum.Font.GothamMedium
closeBtn.Parent = topBar
local minBtn = Instance.new("TextButton")
minBtn.Name = RandName()
minBtn.Size = UDim2.new(0, 28, 0, 28)
minBtn.Position = UDim2.new(1, -64, 0.5, -14)
minBtn.BackgroundTransparency = 1
minBtn.Text = "—"
minBtn.TextColor3 = Colors.TextSecondary
minBtn.TextSize = 12
minBtn.Font = Enum.Font.GothamMedium
minBtn.Parent = topBar
closeBtn.MouseEnter:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.15), { TextColor3 = Color3.fromRGB(255, 95, 95) }):Play()
end)
closeBtn.MouseLeave:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.15), { TextColor3 = Colors.TextSecondary }):Play()
end)
minBtn.MouseEnter:Connect(function()
    TweenService:Create(minBtn, TweenInfo.new(0.15), { TextColor3 = Colors.PurplePrimary }):Play()
end)
minBtn.MouseLeave:Connect(function()
    TweenService:Create(minBtn, TweenInfo.new(0.15), { TextColor3 = Colors.TextSecondary }):Play()
end)
local topDivider = Instance.new("Frame")
topDivider.Name = RandName()
topDivider.Size = UDim2.new(1, 0, 0, 1)
topDivider.Position = UDim2.new(0, 0, 0, 38)
topDivider.BackgroundColor3 = Colors.Divider
topDivider.BorderSizePixel = 0
topDivider.Parent = mainFrame
local bodyFrame = Instance.new("Frame")
bodyFrame.Name = RandName()
bodyFrame.Size = UDim2.new(1, 0, 1, -64)
bodyFrame.Position = UDim2.new(0, 0, 0, 39)
bodyFrame.BackgroundTransparency = 1
bodyFrame.Parent = mainFrame
local sidebar = Instance.new("Frame")
sidebar.Name = RandName()
sidebar.Size = UDim2.new(0, 164, 1, 0)
sidebar.Position = UDim2.new(0, 0, 0, 0)
sidebar.BackgroundColor3 = Colors.SidebarBg
sidebar.BorderSizePixel = 0
sidebar.Parent = bodyFrame
local verticalDivider = Instance.new("Frame")
verticalDivider.Name = RandName()
verticalDivider.Size = UDim2.new(0, 1, 1, 0)
verticalDivider.Position = UDim2.new(0, 164, 0, 0)
verticalDivider.BackgroundColor3 = Colors.Divider
verticalDivider.BorderSizePixel = 0
verticalDivider.Parent = bodyFrame
local searchFrame = Instance.new("Frame")
searchFrame.Name = RandName()
searchFrame.Size = UDim2.new(1, -22, 0, 26)
searchFrame.Position = UDim2.new(0, 11, 0, 12)
searchFrame.BackgroundColor3 = Color3.fromRGB(18, 14, 28)
searchFrame.BorderSizePixel = 0
searchFrame.Parent = sidebar
local searchCorner = Instance.new("UICorner")
searchCorner.CornerRadius = UDim.new(0, 4)
searchCorner.Parent = searchFrame
local searchStroke = Instance.new("UIStroke")
searchStroke.Color = Colors.BorderSubtle
searchStroke.Thickness = 1
searchStroke.Parent = searchFrame
local searchBox = Instance.new("TextBox")
searchBox.Name = RandName()
searchBox.Size = UDim2.new(1, -16, 1, 0)
searchBox.Position = UDim2.new(0, 8, 0, 0)
searchBox.BackgroundTransparency = 1
searchBox.PlaceholderText = CleanText("Search...")
searchBox.PlaceholderColor3 = Colors.TextMuted
searchBox.Text = ""
searchBox.TextColor3 = Colors.TextMain
searchBox.TextSize = 11
searchBox.Font = Enum.Font.Gotham
searchBox.TextXAlignment = Enum.TextXAlignment.Left
searchBox.ClearTextOnFocus = false
searchBox.Parent = searchFrame
local navList = Instance.new("Frame")
navList.Name = RandName()
navList.Size = UDim2.new(1, 0, 1, -56)
navList.Position = UDim2.new(0, 0, 0, 48)
navList.BackgroundTransparency = 1
navList.Parent = sidebar
local navLayout = Instance.new("UIListLayout")
navLayout.Padding = UDim.new(0, 2)
navLayout.SortOrder = Enum.SortOrder.LayoutOrder
navLayout.Parent = navList
local footerBar = Instance.new("Frame")
footerBar.Name = RandName()
footerBar.Size = UDim2.new(1, 0, 0, 25)
footerBar.Position = UDim2.new(0, 0, 1, -25)
footerBar.BackgroundColor3 = Colors.Background
footerBar.BorderSizePixel = 0
footerBar.Parent = mainFrame
local footerDivider = Instance.new("Frame")
footerDivider.Name = RandName()
footerDivider.Size = UDim2.new(1, 0, 0, 1)
footerDivider.Position = UDim2.new(0, 0, 0, 0)
footerDivider.BackgroundColor3 = Colors.Divider
footerDivider.BorderSizePixel = 0
footerDivider.Parent = footerBar
local footerLeft = Instance.new("TextLabel")
footerLeft.Name = RandName()
footerLeft.Size = UDim2.new(0, 220, 1, 0)
footerLeft.Position = UDim2.new(0, 14, 0, 0)
footerLeft.BackgroundTransparency = 1
footerLeft.Text = CleanText("RELWX HUB engine ready")
footerLeft.TextColor3 = Colors.TextDark
footerLeft.TextSize = 10
footerLeft.Font = Enum.Font.GothamMedium
footerLeft.TextXAlignment = Enum.TextXAlignment.Left
footerLeft.Parent = footerBar
local footerCenter = Instance.new("TextLabel")
footerCenter.Name = RandName()
footerCenter.Size = UDim2.new(0, 140, 1, 0)
footerCenter.Position = UDim2.new(0.5, -70, 0, 0)
footerCenter.BackgroundTransparency = 1
footerCenter.RichText = true
footerCenter.Text = CleanText("RELWX HUB Edition")
footerCenter.TextColor3 = Colors.TextDark
footerCenter.TextSize = 10
footerCenter.Font = Enum.Font.Gotham
footerCenter.Parent = footerBar
local footerRight = Instance.new("TextLabel")
footerRight.Name = RandName()
footerRight.Size = UDim2.new(0, 160, 1, 0)
footerRight.Position = UDim2.new(1, -174, 0, 0)
footerRight.BackgroundTransparency = 1
footerRight.Text = CleanText("LEFTCONTROL TO HIDE")
footerRight.TextColor3 = Colors.TextDark
footerRight.TextSize = 10
footerRight.Font = Enum.Font.GothamBold
footerRight.TextXAlignment = Enum.TextXAlignment.Right
footerRight.Parent = footerBar
local contentArea = Instance.new("Frame")
contentArea.Name = RandName()
contentArea.Size = UDim2.new(1, -165, 1, 0)
contentArea.Position = UDim2.new(0, 165, 0, 0)
contentArea.BackgroundTransparency = 1
contentArea.Parent = bodyFrame
local tooltipFrame = Instance.new("Frame")
tooltipFrame.Name = RandName()
tooltipFrame.Size = UDim2.new(0, 180, 0, 28)
tooltipFrame.BackgroundColor3 = Color3.fromRGB(22, 17, 34)
tooltipFrame.BorderSizePixel = 0
tooltipFrame.Visible = false
tooltipFrame.ZIndex = 200
tooltipFrame.Parent = mainFrame
local tooltipCorner = Instance.new("UICorner")
tooltipCorner.CornerRadius = UDim.new(0, 4)
tooltipCorner.Parent = tooltipFrame
local tooltipStroke = Instance.new("UIStroke")
tooltipStroke.Color = Colors.PurpleAccent
tooltipStroke.Thickness = 1
tooltipStroke.Parent = tooltipFrame
local tooltipLabel = Instance.new("TextLabel")
tooltipLabel.Name = RandName()
tooltipLabel.Size = UDim2.new(1, -12, 1, -6)
tooltipLabel.Position = UDim2.new(0, 6, 0, 3)
tooltipLabel.BackgroundTransparency = 1
tooltipLabel.Text = ""
tooltipLabel.TextColor3 = Colors.TextMain
tooltipLabel.TextSize = 10
tooltipLabel.Font = Enum.Font.Gotham
tooltipLabel.TextWrapped = true
tooltipLabel.TextXAlignment = Enum.TextXAlignment.Left
tooltipLabel.ZIndex = 201
tooltipLabel.Parent = tooltipFrame
local function ShowTooltip(text, sourceGui)
    tooltipLabel.Text = CleanText(text)
    local tSize = TextService:GetTextSize(text, 10, Enum.Font.Gotham, Vector2.new(220, 100))
    local w = math.clamp(tSize.X + 16, 120, 240)
    local h = math.max(tSize.Y + 12, 26)
    tooltipFrame.Size = UDim2.new(0, w, 0, h)
    local absPos = sourceGui.AbsolutePosition - mainFrame.AbsolutePosition
    local x = absPos.X + sourceGui.AbsoluteSize.X + 8
    local y = absPos.Y
    if x + w > mainFrame.AbsoluteSize.X - 10 then
        x = absPos.X - w - 8
    end
    tooltipFrame.Position = UDim2.new(0, x, 0, y)
    tooltipFrame.Visible = true
end
local function HideTooltip()
    tooltipFrame.Visible = false
end
local tabs = {}
local tabButtons = {}
local currentTabName = "Autoparry"
local function createTabContent(name)
    local tabScroll = Instance.new("ScrollingFrame")
    tabScroll.Name = RandName()
    tabScroll.Size = UDim2.new(1, -28, 1, -20)
    tabScroll.Position = UDim2.new(0, 14, 0, 10)
    tabScroll.BackgroundTransparency = 1
    tabScroll.BorderSizePixel = 0
    tabScroll.ScrollBarThickness = 3
    tabScroll.ScrollBarImageColor3 = Colors.PurpleAccent
    tabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tabScroll.Visible = (name == currentTabName)
    tabScroll.Parent = contentArea
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = tabScroll
    tabs[name] = tabScroll
    return tabScroll
end
local function SwitchTab(tabName)
    currentTabName = tabName
    for name, page in pairs(tabs) do
        page.Visible = (name == tabName)
    end
    for name, btnData in pairs(tabButtons) do
        local isActive = (name == tabName)
        btnData.Indicator.Visible = isActive
        btnData.Label.TextColor3 = isActive and Colors.PurplePrimary or Colors.TextSecondary
        btnData.Icon.TextColor3 = isActive and Colors.PurplePrimary or Colors.TextMuted
    end
    HideTooltip()
end
local tabIcons = {
    Home = "◈",
    Misc = "≡",
    Autoparry = "◆",
    ["Spam Core"] = "▲",
    Detection = "✦",
    ["Player Mod"] = "●"
}
local function createNavButton(name, order)
    local btn = Instance.new("TextButton")
    btn.Name = RandName()
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundTransparency = 1
    btn.AutoButtonColor = false
    btn.Text = ""
    btn.LayoutOrder = order
    btn.Parent = navList
    local indicator = Instance.new("Frame")
    indicator.Name = RandName()
    indicator.Size = UDim2.new(0, 2.5, 0, 18)
    indicator.Position = UDim2.new(0, 0, 0.5, -9)
    indicator.BackgroundColor3 = Colors.PurpleAccent
    indicator.BorderSizePixel = 0
    indicator.Visible = (name == currentTabName)
    indicator.Parent = btn
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Name = RandName()
    iconLabel.Size = UDim2.new(0, 24, 1, 0)
    iconLabel.Position = UDim2.new(0, 12, 0, 0)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = tabIcons[name] or "●"
    iconLabel.TextColor3 = (name == currentTabName) and Colors.PurplePrimary or Colors.TextMuted
    iconLabel.TextSize = 12
    iconLabel.Parent = btn
    local textLabel = Instance.new("TextLabel")
    textLabel.Name = RandName()
    textLabel.Size = UDim2.new(1, -50, 1, 0)
    textLabel.Position = UDim2.new(0, 38, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = CleanText(name)
    textLabel.TextColor3 = (name == currentTabName) and Colors.PurplePrimary or Colors.TextSecondary
    textLabel.TextSize = 12
    textLabel.Font = Enum.Font.GothamMedium
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.Parent = btn
    btn.MouseEnter:Connect(function()
        if currentTabName ~= name then
            TweenService:Create(textLabel, TweenInfo.new(0.15), { TextColor3 = Colors.TextMain }):Play()
            TweenService:Create(iconLabel, TweenInfo.new(0.15), { TextColor3 = Colors.PurpleAccent }):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        if currentTabName ~= name then
            TweenService:Create(textLabel, TweenInfo.new(0.15), { TextColor3 = Colors.TextSecondary }):Play()
            TweenService:Create(iconLabel, TweenInfo.new(0.15), { TextColor3 = Colors.TextMuted }):Play()
        end
    end)
    btn.MouseButton1Click:Connect(function()
        SwitchTab(name)
    end)
    tabButtons[name] = {
        Button = btn,
        Indicator = indicator,
        Label = textLabel,
        Icon = iconLabel
    }
end
local navOrder = { "Home", "Misc", "Autoparry", "Spam Core", "Detection", "Player Mod" }
for i, tabName in ipairs(navOrder) do
    createNavButton(tabName, i)
    createTabContent(tabName)
end
local function createCategoryHeader(parent, titleText)
    local headerFrame = Instance.new("Frame")
    headerFrame.Name = RandName()
    headerFrame.Size = UDim2.new(1, 0, 0, 26)
    headerFrame.BackgroundTransparency = 1
    headerFrame.Parent = parent
    local lbl = Instance.new("TextLabel")
    lbl.Name = RandName()
    lbl.Size = UDim2.new(1, -20, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = CleanText(titleText:upper())
    lbl.TextColor3 = Colors.PurpleAccent
    lbl.TextSize = 11
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = headerFrame
    local dash = Instance.new("TextLabel")
    dash.Name = RandName()
    dash.Size = UDim2.new(0, 20, 1, 0)
    dash.Position = UDim2.new(1, -20, 0, 0)
    dash.BackgroundTransparency = 1
    dash.Text = "-"
    dash.TextColor3 = Colors.PurpleMuted
    dash.TextSize = 14
    dash.Font = Enum.Font.GothamBold
    dash.Parent = headerFrame
    local div = Instance.new("Frame")
    div.Name = RandName()
    div.Size = UDim2.new(1, 0, 0, 1)
    div.Position = UDim2.new(0, 0, 1, -1)
    div.BackgroundColor3 = Color3.fromRGB(34, 25, 52)
    div.BorderSizePixel = 0
    div.Parent = headerFrame
    return headerFrame
end
local function attachInfoBadge(parent, xOffset, infoText)
    local infoBtn = Instance.new("TextButton")
    infoBtn.Name = RandName()
    infoBtn.Size = UDim2.new(0, 15, 0, 15)
    infoBtn.Position = UDim2.new(0, xOffset, 0.5, -7.5)
    infoBtn.BackgroundColor3 = Color3.fromRGB(25, 18, 40)
    infoBtn.AutoButtonColor = false
    infoBtn.Text = "?"
    infoBtn.TextColor3 = Colors.PurpleMuted
    infoBtn.TextSize = 10
    infoBtn.Font = Enum.Font.GothamBold
    infoBtn.Parent = parent
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = infoBtn
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(75, 48, 115)
    stroke.Thickness = 1
    stroke.Parent = infoBtn
    infoBtn.MouseEnter:Connect(function()
        TweenService:Create(infoBtn, TweenInfo.new(0.15), { TextColor3 = Colors.PurplePrimary }):Play()
        TweenService:Create(stroke, TweenInfo.new(0.15), { Color = Colors.PurpleAccent }):Play()
        ShowTooltip(infoText, infoBtn)
    end)
    infoBtn.MouseLeave:Connect(function()
        TweenService:Create(infoBtn, TweenInfo.new(0.15), { TextColor3 = Colors.PurpleMuted }):Play()
        TweenService:Create(stroke, TweenInfo.new(0.15), { Color = Color3.fromRGB(75, 48, 115) }):Play()
        HideTooltip()
    end)
    return infoBtn
end
local function createInfoRow(parent, labelText, valueText, hasDiamondBullet)
    local row = Instance.new("Frame")
    row.Name = RandName()
    row.Size = UDim2.new(1, 0, 0, 36)
    row.BackgroundTransparency = 1
    row.Parent = parent
    rowSearchIndex[row] = labelText:lower()
    local textOffset = 0
    if hasDiamondBullet then
        local diamond = Instance.new("TextLabel")
        diamond.Name = RandName()
        diamond.Size = UDim2.new(0, 10, 1, 0)
        diamond.Position = UDim2.new(0, 0, 0, 0)
        diamond.BackgroundTransparency = 1
        diamond.Text = "◆"
        diamond.TextColor3 = Colors.PurplePrimary
        diamond.TextSize = 9
        diamond.Parent = row
        textOffset = 14
    end
    local label = Instance.new("TextLabel")
    label.Name = RandName()
    label.Size = UDim2.new(0, 160, 1, 0)
    label.Position = UDim2.new(0, textOffset, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = CleanText(labelText)
    label.TextColor3 = Colors.TextMain
    label.TextSize = 12
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row
    local valLabel = Instance.new("TextLabel")
    valLabel.Name = RandName()
    valLabel.Size = UDim2.new(1, -170 - textOffset, 1, 0)
    valLabel.Position = UDim2.new(0, 170 + textOffset, 0, 0)
    valLabel.BackgroundTransparency = 1
    valLabel.Text = CleanText(valueText)
    valLabel.TextColor3 = Colors.TextSecondary
    valLabel.TextSize = 11
    valLabel.Font = Enum.Font.Gotham
    valLabel.TextXAlignment = Enum.TextXAlignment.Right
    valLabel.TextTruncate = Enum.TextTruncate.AtEnd
    valLabel.Parent = row
    return {
        Row = row,
        SetValue = function(v) valLabel.Text = CleanText(v) end
    }
end
local function createToggleRow(parent, labelText, infoText, defaultState, callback, hasDiamondBullet)
    local row = Instance.new("Frame")
    row.Name = RandName()
    row.Size = UDim2.new(1, 0, 0, 36)
    row.BackgroundTransparency = 1
    row.Parent = parent
    rowSearchIndex[row] = labelText:lower()
    local textOffset = 0
    if hasDiamondBullet then
        local diamond = Instance.new("TextLabel")
        diamond.Name = RandName()
        diamond.Size = UDim2.new(0, 10, 1, 0)
        diamond.Position = UDim2.new(0, 0, 0, 0)
        diamond.BackgroundTransparency = 1
        diamond.Text = "◆"
        diamond.TextColor3 = Colors.PurplePrimary
        diamond.TextSize = 9
        diamond.Parent = row
        textOffset = 14
    end
    local label = Instance.new("TextLabel")
    label.Name = RandName()
    label.Size = UDim2.new(0, 200, 1, 0)
    label.Position = UDim2.new(0, textOffset, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = CleanText(labelText)
    label.TextColor3 = Colors.TextMain
    label.TextSize = 12
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row
    if infoText and infoText ~= "" then
        local textSize = TextService:GetTextSize(labelText, 12, Enum.Font.GothamMedium, Vector2.new(300, 30))
        attachInfoBadge(row, textOffset + textSize.X + 8, infoText)
    end
    local switchTrack = Instance.new("TextButton")
    switchTrack.Name = RandName()
    switchTrack.Size = UDim2.new(0, 36, 0, 18)
    switchTrack.Position = UDim2.new(1, -44, 0.5, -9)
    switchTrack.BackgroundColor3 = defaultState and Colors.ToggleTrackOn or Colors.ToggleTrackOff
    switchTrack.AutoButtonColor = false
    switchTrack.Text = ""
    switchTrack.Parent = row
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(0, 9)
    trackCorner.Parent = switchTrack
    local trackStroke = Instance.new("UIStroke")
    trackStroke.Color = defaultState and Color3.fromRGB(120, 68, 185) or Color3.fromRGB(50, 38, 72)
    trackStroke.Thickness = 1
    trackStroke.Parent = switchTrack
    local knob = Instance.new("Frame")
    knob.Name = RandName()
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = defaultState and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    knob.BackgroundColor3 = defaultState and Colors.ToggleKnobOn or Colors.ToggleKnobOff
    knob.BorderSizePixel = 0
    knob.Parent = switchTrack
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(0, 3)
    knobCorner.Parent = knob
    local state = defaultState
    local function updateState(newState, callCb)
        state = newState
        local targetPos = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        local targetTrackColor = state and Colors.ToggleTrackOn or Colors.ToggleTrackOff
        local targetKnobColor = state and Colors.ToggleKnobOn or Colors.ToggleKnobOff
        local targetStrokeColor = state and Color3.fromRGB(120, 68, 185) or Color3.fromRGB(50, 38, 72)
        TweenService:Create(knob, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = targetPos,
            BackgroundColor3 = targetKnobColor
        }):Play()
        TweenService:Create(switchTrack, TweenInfo.new(0.18), { BackgroundColor3 = targetTrackColor }):Play()
        TweenService:Create(trackStroke, TweenInfo.new(0.18), { Color = targetStrokeColor }):Play()
        if callCb and callback then
            callback(state)
        end
    end
    switchTrack.MouseButton1Click:Connect(function()
        updateState(not state, true)
    end)
    return {
        Row = row,
        SetState = function(val) updateState(val, false) end,
        GetState = function() return state end
    }
end
local function createSliderRow(parent, labelText, infoText, minVal, maxVal, defaultVal, isFloat, suffix, callback,
                               hasDiamondBullet)
    local row = Instance.new("Frame")
    row.Name = RandName()
    row.Size = UDim2.new(1, 0, 0, 42)
    row.BackgroundTransparency = 1
    row.Parent = parent
    rowSearchIndex[row] = labelText:lower()
    local textOffset = 0
    if hasDiamondBullet then
        local diamond = Instance.new("TextLabel")
        diamond.Name = RandName()
        diamond.Size = UDim2.new(0, 10, 0, 20)
        diamond.Position = UDim2.new(0, 0, 0, 0)
        diamond.BackgroundTransparency = 1
        diamond.Text = "◆"
        diamond.TextColor3 = Colors.PurplePrimary
        diamond.TextSize = 9
        diamond.Parent = row
        textOffset = 14
    end
    local label = Instance.new("TextLabel")
    label.Name = RandName()
    label.Size = UDim2.new(0, 180, 0, 20)
    label.Position = UDim2.new(0, textOffset, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = CleanText(labelText)
    label.TextColor3 = Colors.TextMain
    label.TextSize = 12
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row
    if infoText and infoText ~= "" then
        local textSize = TextService:GetTextSize(labelText, 12, Enum.Font.GothamMedium, Vector2.new(300, 30))
        attachInfoBadge(row, textOffset + textSize.X + 8, infoText)
    end
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Name = RandName()
    valueLabel.Size = UDim2.new(0, 60, 0, 16)
    valueLabel.Position = UDim2.new(1, -68, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = isFloat and string.format("%.3f%s", defaultVal, suffix or "") or
        string.format("%d%s", defaultVal, suffix or "")
    valueLabel.TextColor3 = Colors.TextMain
    valueLabel.TextSize = 11
    valueLabel.Font = Enum.Font.GothamMedium
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = row
    local sliderWidth = 160
    local sliderTrack = Instance.new("Frame")
    sliderTrack.Name = RandName()
    sliderTrack.Size = UDim2.new(0, sliderWidth, 0, 2)
    sliderTrack.Position = UDim2.new(1, -sliderWidth - 8, 0, 26)
    sliderTrack.BackgroundColor3 = Colors.SliderTrack
    sliderTrack.BorderSizePixel = 0
    sliderTrack.Parent = row
    local sliderFill = Instance.new("Frame")
    sliderFill.Name = RandName()
    local initialPercent = math.clamp((defaultVal - minVal) / (maxVal - minVal), 0, 1)
    sliderFill.Size = UDim2.new(initialPercent, 0, 1, 0)
    sliderFill.BackgroundColor3 = Colors.SliderFill
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderTrack
    local diamondKnob = Instance.new("Frame")
    diamondKnob.Name = RandName()
    diamondKnob.Size = UDim2.new(0, 9, 0, 9)
    diamondKnob.Position = UDim2.new(1, -4.5, 0.5, -4.5)
    diamondKnob.Rotation = 45
    diamondKnob.BackgroundColor3 = Colors.SliderKnob
    diamondKnob.BorderSizePixel = 0
    diamondKnob.Parent = sliderFill
    local dragging = false
    local currentValue = defaultVal
    local function setValue(val, callCb)
        currentValue = math.clamp(val, minVal, maxVal)
        local pct = (currentValue - minVal) / (maxVal - minVal)
        sliderFill.Size = UDim2.new(pct, 0, 1, 0)
        valueLabel.Text = isFloat and string.format("%.3f%s", currentValue, suffix or "") or
            string.format("%d%s", math.floor(currentValue + 0.5), suffix or "")
        if callCb and callback then
            callback(currentValue)
        end
    end
    local hitZone = Instance.new("TextButton")
    hitZone.Name = RandName()
    hitZone.Size = UDim2.new(1, 16, 0, 18)
    hitZone.Position = UDim2.new(0, -8, 0.5, -9)
    hitZone.BackgroundTransparency = 1
    hitZone.Text = ""
    hitZone.Parent = sliderTrack
    hitZone.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            local relX = math.clamp(input.Position.X - sliderTrack.AbsolutePosition.X, 0, sliderWidth)
            local pct = relX / sliderWidth
            local computed = minVal + (pct * (maxVal - minVal))
            setValue(computed, true)
        end
    end)
    table.insert(activeConnections, UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local relX = math.clamp(input.Position.X - sliderTrack.AbsolutePosition.X, 0, sliderWidth)
            local pct = relX / sliderWidth
            local computed = minVal + (pct * (maxVal - minVal))
            setValue(computed, true)
        end
    end))
    table.insert(activeConnections, UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end))
    return {
        Row = row,
        SetValue = function(v) setValue(v, false) end,
        GetValue = function() return currentValue end
    }
end
local function createDropdownRow(parent, labelText, infoText, options, defaultOption, callback, hasDiamondBullet, subText)
    local totalHeight = subText and 52 or 36
    local row = Instance.new("Frame")
    row.Name = RandName()
    row.Size = UDim2.new(1, 0, 0, totalHeight)
    row.BackgroundTransparency = 1
    row.ZIndex = 5
    row.Parent = parent
    rowSearchIndex[row] = labelText:lower()
    local textOffset = 0
    if hasDiamondBullet then
        local diamond = Instance.new("TextLabel")
        diamond.Name = RandName()
        diamond.Size = UDim2.new(0, 10, 0, 36)
        diamond.Position = UDim2.new(0, 0, 0, 0)
        diamond.BackgroundTransparency = 1
        diamond.Text = "◆"
        diamond.TextColor3 = Colors.PurplePrimary
        diamond.TextSize = 9
        diamond.Parent = row
        textOffset = 14
    end
    local label = Instance.new("TextLabel")
    label.Name = RandName()
    label.Size = UDim2.new(0, 180, 0, 36)
    label.Position = UDim2.new(0, textOffset, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = CleanText(labelText)
    label.TextColor3 = Colors.TextMain
    label.TextSize = 12
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row
    if infoText and infoText ~= "" then
        local textSize = TextService:GetTextSize(labelText, 12, Enum.Font.GothamMedium, Vector2.new(300, 30))
        attachInfoBadge(row, textOffset + textSize.X + 8, infoText)
    end
    if subText and subText ~= "" then
        local sub = Instance.new("TextLabel")
        sub.Name = RandName()
        sub.Size = UDim2.new(1, 0, 0, 16)
        sub.Position = UDim2.new(0, textOffset, 0, 32)
        sub.BackgroundTransparency = 1
        sub.Text = CleanText(subText)
        sub.TextColor3 = Colors.PurpleMuted
        sub.TextSize = 10
        sub.Font = Enum.Font.Gotham
        sub.TextXAlignment = Enum.TextXAlignment.Left
        sub.Parent = row
    end
    local ddBox = Instance.new("TextButton")
    ddBox.Name = RandName()
    ddBox.Size = UDim2.new(0, 168, 0, 26)
    ddBox.Position = UDim2.new(1, -176, 0, 5)
    ddBox.BackgroundColor3 = Colors.DropdownBg
    ddBox.AutoButtonColor = false
    ddBox.Text = ""
    ddBox.ZIndex = 6
    ddBox.Parent = row
    local ddCorner = Instance.new("UICorner")
    ddCorner.CornerRadius = UDim.new(0, 4)
    ddCorner.Parent = ddBox
    local ddStroke = Instance.new("UIStroke")
    ddStroke.Color = Colors.DropdownBorder
    ddStroke.Thickness = 1
    ddStroke.Parent = ddBox
    local selectedText = Instance.new("TextLabel")
    selectedText.Name = RandName()
    selectedText.Size = UDim2.new(1, -26, 1, 0)
    selectedText.Position = UDim2.new(0, 10, 0, 0)
    selectedText.BackgroundTransparency = 1
    selectedText.Text = CleanText(defaultOption)
    selectedText.TextColor3 = Colors.TextMain
    selectedText.TextSize = 11
    selectedText.Font = Enum.Font.Gotham
    selectedText.TextXAlignment = Enum.TextXAlignment.Left
    selectedText.ZIndex = 7
    selectedText.Parent = ddBox
    local chevron = Instance.new("TextLabel")
    chevron.Name = RandName()
    chevron.Size = UDim2.new(0, 20, 1, 0)
    chevron.Position = UDim2.new(1, -22, 0, 0)
    chevron.BackgroundTransparency = 1
    chevron.Text = "v"
    chevron.TextColor3 = Colors.PurpleMuted
    chevron.TextSize = 10
    chevron.Font = Enum.Font.GothamBold
    chevron.ZIndex = 7
    chevron.Parent = ddBox
    local listFrame = Instance.new("Frame")
    listFrame.Name = RandName()
    listFrame.Size = UDim2.new(0, 168, 0, #options * 24 + 4)
    listFrame.BackgroundColor3 = Colors.DropdownBg
    listFrame.BorderSizePixel = 0
    listFrame.Visible = false
    listFrame.ZIndex = 150
    listFrame.Parent = mainFrame
    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 4)
    listCorner.Parent = listFrame
    local listStroke = Instance.new("UIStroke")
    listStroke.Color = Colors.PurpleAccent
    listStroke.Thickness = 1
    listStroke.Parent = listFrame
    local menuLayout = Instance.new("UIListLayout")
    menuLayout.Padding = UDim.new(0, 1)
    menuLayout.Parent = listFrame
    local currentSelected = defaultOption
    local function selectOption(opt)
        currentSelected = opt
        selectedText.Text = CleanText(opt)
        listFrame.Visible = false
        chevron.Text = "v"
        if callback then
            callback(opt)
        end
    end
    for _, optName in ipairs(options) do
        local optBtn = Instance.new("TextButton")
        optBtn.Name = RandName()
        optBtn.Size = UDim2.new(1, 0, 0, 24)
        optBtn.BackgroundColor3 = Colors.DropdownBg
        optBtn.BackgroundTransparency = 1
        optBtn.AutoButtonColor = false
        optBtn.Text = "   " .. CleanText(optName)
        optBtn.TextColor3 = (optName == currentSelected) and Colors.PurplePrimary or Colors.TextSecondary
        optBtn.TextSize = 11
        optBtn.Font = Enum.Font.Gotham
        optBtn.TextXAlignment = Enum.TextXAlignment.Left
        optBtn.ZIndex = 151
        optBtn.Parent = listFrame
        optBtn.MouseEnter:Connect(function()
            optBtn.BackgroundTransparency = 0
            optBtn.BackgroundColor3 = Color3.fromRGB(36, 24, 56)
            optBtn.TextColor3 = Colors.PurplePrimary
        end)
        optBtn.MouseLeave:Connect(function()
            optBtn.BackgroundTransparency = 1
            optBtn.TextColor3 = (optName == currentSelected) and Colors.PurplePrimary or Colors.TextSecondary
        end)
        optBtn.MouseButton1Click:Connect(function()
            selectOption(optName)
        end)
    end
    local function toggleDropdown()
        listFrame.Visible = not listFrame.Visible
        chevron.Text = listFrame.Visible and "^" or "v"
        if listFrame.Visible then
            local absPos = ddBox.AbsolutePosition - mainFrame.AbsolutePosition
            listFrame.Position = UDim2.new(0, absPos.X, 0, absPos.Y + ddBox.AbsoluteSize.Y + 3)
            TweenService:Create(ddStroke, TweenInfo.new(0.15), { Color = Colors.PurpleAccent }):Play()
        else
            TweenService:Create(ddStroke, TweenInfo.new(0.15), { Color = Colors.DropdownBorder }):Play()
        end
    end
    ddBox.MouseButton1Click:Connect(toggleDropdown)
    return {
        Row = row,
        SetOption = selectOption,
        GetOption = function() return currentSelected end
    }
end
local function createButtonRow(parent, labelText, buttonText, iconText, isRed, callback)
    local row = Instance.new("Frame")
    row.Name = RandName()
    row.Size = UDim2.new(1, 0, 0, 36)
    row.BackgroundTransparency = 1
    row.Parent = parent
    rowSearchIndex[row] = labelText:lower()
    local label = Instance.new("TextLabel")
    label.Name = RandName()
    label.Size = UDim2.new(0, 180, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = CleanText(labelText)
    label.TextColor3 = Colors.TextMain
    label.TextSize = 12
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row
    local btn = Instance.new("TextButton")
    btn.Name = RandName()
    btn.Size = UDim2.new(0, 120, 0, 26)
    btn.Position = UDim2.new(1, -128, 0.5, -13)
    btn.BackgroundColor3 = Color3.fromRGB(24, 18, 38)
    btn.AutoButtonColor = false
    btn.Text = (iconText and iconText .. "  " or "") .. CleanText(buttonText:upper())
    btn.TextColor3 = isRed and Color3.fromRGB(255, 125, 125) or Color3.fromRGB(220, 185, 255)
    btn.TextSize = 10
    btn.Font = Enum.Font.GothamBold
    btn.Parent = row
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = btn
    local stroke = Instance.new("UIStroke")
    stroke.Color = isRed and Color3.fromRGB(110, 45, 45) or Color3.fromRGB(90, 56, 140)
    stroke.Thickness = 1
    stroke.Parent = btn
    btn.MouseEnter:Connect(function()
        TweenService:Create(stroke, TweenInfo.new(0.2),
            { Color = isRed and Color3.fromRGB(255, 75, 75) or Colors.PurplePrimary }):Play()
        TweenService:Create(btn, TweenInfo.new(0.2),
            { BackgroundColor3 = isRed and Color3.fromRGB(45, 20, 20) or Color3.fromRGB(38, 26, 60) }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(stroke, TweenInfo.new(0.2),
            { Color = isRed and Color3.fromRGB(110, 45, 45) or Color3.fromRGB(90, 56, 140) }):Play()
        TweenService:Create(btn, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(24, 18, 38) }):Play()
    end)
    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    return row
end
local ToggleUiVisibility
local UnloadScript
local SyncUIWithConfig
local homePage = tabs["Home"]
createCategoryHeader(homePage, "HUD OVERLAYS")
ctrls.BallStatsHUD = createToggleRow(
    homePage,
    "Ball Stats HUD",
    "Live floating card showing Current & Peak ball velocity.",
    Config.BallStatsHUD,
    function(state)
        Config.BallStatsHUD = state
        ballStatsFrame.Visible = state
        AutoSaveConfig()
    end,
    false
)
ctrls.ClientStatsHUD = createToggleRow(
    homePage,
    "Client Stats HUD",
    "Live floating card showing FPS, Ping, and CPU load.",
    Config.ClientStatsHUD,
    function(state)
        Config.ClientStatsHUD = state
        clientStatsFrame.Visible = state
        AutoSaveConfig()
    end,
    false
)
createCategoryHeader(homePage, "PLAYER & SERVER")
createInfoRow(homePage, "Player", LocalPlayer and LocalPlayer.Name or "Unknown", false)
createInfoRow(homePage, "Game", "Blade Ball", false)
local serverJobId = game.JobId ~= "" and (game.JobId:sub(1, 28) .. "...") or "028ff5c8-7bd5-46f3-9551-74..."
createInfoRow(homePage, "Server", serverJobId, true)
createInfoRow(homePage, "Script version", Config.ScriptVersion, false)
local runStatusRow = createInfoRow(homePage, "Run status", "RELWX HUB engine ready", false)
latestDeathReasonRow = createInfoRow(homePage, "Latest Miss / Death", "None recorded", true)
local miscPage = tabs["Misc"]
createCategoryHeader(miscPage, "CONFIGS")
createInfoRow(miscPage, "Auto-Save", "Active (Saves to default.json)", false)
createButtonRow(miscPage, "Save config", "SAVE NOW", "", false, function()
    pcall(function()
        local path = GetConfigFilePath()
        local data = SerializeConfig()
        local json = HttpService:JSONEncode(data)
        writefile(path, json)
        SendNotification("RELWX HUB Config", "Default config saved.", 2)
    end)
end)
createButtonRow(miscPage, "Load config", "LOAD NOW", "", false, function()
    local ok = LoadSavedConfig()
    if ok then
        if SyncUIWithConfig then SyncUIWithConfig() end
        SendNotification("RELWX HUB Config", "Default config reloaded.", 2)
    else
        SendNotification("RELWX HUB Config", "No config file found.", 2)
    end
end)
createCategoryHeader(miscPage, "INTERFACE")
ctrls.UIKeybind = createDropdownRow(
    miscPage,
    "UI keybind",
    "",
    { "LeftControl", "RightShift", "Insert", "RightControl", "F4", "V", "K" },
    Config.UIKeybind and Config.UIKeybind.Name or "LeftControl",
    function(opt)
        if Enum.KeyCode[opt] then
            Config.UIKeybind = Enum.KeyCode[opt]
            footerRight.Text = CleanText(opt:upper() .. " TO HIDE")
            AutoSaveConfig()
        end
    end,
    false,
    "The selected key toggles the RELWX HUB window."
)
ctrls.KeepCrestMinimised = createToggleRow(
    miscPage,
    "Show Crest Icon",
    "Floating draggable button to toggle interface.",
    Config.KeepCrestMinimised,
    function(state)
        Config.KeepCrestMinimised = state
        miniCrest.Visible = state
        AutoSaveConfig()
    end,
    false
)
createButtonRow(miscPage, "Hide interface", "HIDE NOW", "", false, function()
    if ToggleUiVisibility then ToggleUiVisibility() end
end)
createButtonRow(miscPage, "Unload RELWX HUB", "UNLOAD", "✕", true, function()
    if UnloadScript then UnloadScript() end
end)
local autoparryPage = tabs["Autoparry"]
createCategoryHeader(autoparryPage, "AUTO PARRY CORE")
ctrls.AutoParry = createToggleRow(
    autoparryPage,
    "Auto Parry",
    "Toggles auto parry.",
    Config.AutoParry,
    function(state)
        autoParryEnabled = state
        Config.AutoParry = state
        footerLeft.Text = CleanText(state and "Auto Parry: ACTIVE" or "RELWX HUB engine ready")
        runStatusRow.SetValue(state and "Auto Parry: ACTIVE" or "RELWX HUB engine ready")
        SendNotification("Auto Parry", "Auto Parry is now " .. (state and "ENABLED" or "DISABLED"), 2)
        AutoSaveConfig()
    end,
    false
)
ctrls.Accuracy = createSliderRow(
    autoparryPage,
    "Parry Accuracy",
    "Scales calculation window (10-100%).",
    10, 100, Config.Accuracy, false, "",
    function(val)
        Config.Accuracy = math.floor(val)
        AutoSaveConfig()
    end
)
ctrls.CurveMode = createDropdownRow(
    autoparryPage,
    "Mode curve",
    "Curve trajectory model.",
    { "Camera", "Trajectory", "Predictive", "Velocity" },
    Config.CurveMode,
    function(opt)
        Config.CurveMode = opt
        AutoSaveConfig()
    end,
    false
)
ctrls.RandomizeAccuracy = createToggleRow(
    autoparryPage,
    "Randomize Accuracy",
    "Adds timing variance (+-8ms).",
    Config.RandomizeAccuracy,
    function(state)
        Config.RandomizeAccuracy = state
        AutoSaveConfig()
    end,
    false
)
ctrls.AutoAbilities = createToggleRow(
    autoparryPage,
    "Auto Abilities",
    "Uses ability (Q) on high velocity.",
    Config.AutoAbilities,
    function(state)
        Config.AutoAbilities = state
        AutoSaveConfig()
    end,
    false
)
ctrls.InstantTriggerbot = createToggleRow(
    autoparryPage,
    "Instant Triggerbot",
    "Ping-compensated instant deflection.",
    Config.InstantTriggerbot,
    function(state)
        Config.InstantTriggerbot = state
        AutoSaveConfig()
    end,
    false
)
ctrls.VisualParryRing = createToggleRow(
    autoparryPage,
    "Visual Parry Ring",
    "Renders parry range ring around your character.",
    Config.VisualParryRing,
    function(state)
        Config.VisualParryRing = state
        UpdateVisualRings()
        AutoSaveConfig()
    end,
    false
)
ctrls.DeathNotifications = createToggleRow(
    autoparryPage,
    "Death Notifications",
    "Displays detailed diagnostic notifications on miss/death.",
    Config.DeathNotifications,
    function(state)
        Config.DeathNotifications = state
        AutoSaveConfig()
    end,
    false
)
local spamPage = tabs["Spam Core"]
createCategoryHeader(spamPage, "AUTO SPAM")
ctrls.AutoSpam = createToggleRow(
    spamPage,
    "Auto Spam",
    "Paced automated rapid parry execution.",
    Config.AutoSpam,
    function(state)
        Config.AutoSpam = state
        AutoSaveConfig()
    end,
    false
)
ctrls.SpamActionsPerSecond = createSliderRow(
    spamPage,
    "Spam Actions Per Second",
    "Number of parry actions sent per second.",
    10, 100, Config.SpamActionsPerSecond, false, "",
    function(val)
        Config.SpamActionsPerSecond = math.floor(val)
        AutoSaveConfig()
    end
)
ctrls.AutoSpamDistance = createSliderRow(
    spamPage,
    "Auto Spam Distance",
    "Maximum distance to activate auto spam.",
    5, 60, Config.AutoSpamDistance, false, " studs",
    function(val)
        Config.AutoSpamDistance = math.floor(val)
        Config.ClashDistance = Config.AutoSpamDistance
        UpdateVisualRings()
        AutoSaveConfig()
    end,
    true
)
ctrls.SpamBatchMode = createDropdownRow(
    spamPage,
    "Spam Batch Mode",
    "Input batching rate mode.",
    { "Extremely Fast", "Fast", "Normal", "Safe" },
    Config.SpamBatchMode,
    function(opt)
        Config.SpamBatchMode = opt
        AutoSaveConfig()
    end,
    false
)
createCategoryHeader(spamPage, "MANUAL SPAM")
ctrls.ManualSpam = createToggleRow(
    spamPage,
    "Manual Spam",
    "Hold parry keybind or mouse to continuously spam parries.",
    Config.ManualSpam,
    function(state)
        Config.ManualSpam = state
        AutoSaveConfig()
    end,
    false
)
local detectPage = tabs["Detection"]
createCategoryHeader(detectPage, "ABILITY DETECTIONS")
ctrls.PhantomDetection = createToggleRow(detectPage, "Phantom", "Tracks Phantom ball transparency and curves.",
    Config.PhantomDetection, function(state)
        Config.PhantomDetection = state
        AutoSaveConfig()
    end, false)
ctrls.TimeHoleDetection = createToggleRow(detectPage, "Time Hole Auto Parry", "Deflects on Time Hole release.",
    Config.TimeHoleDetection, function(state)
        Config.TimeHoleDetection = state
        AutoSaveConfig()
    end, false)
ctrls.SlashesOfFuryDetection = createToggleRow(detectPage, "Slashes of Fury Auto Counter",
    "Auto counters Slashes of Fury.", Config.SlashesOfFuryDetection, function(state)
        Config.SlashesOfFuryDetection = state
        AutoSaveConfig()
    end, true)
ctrls.InfinityBallDetection = createToggleRow(detectPage, "Infinity Ball Detection", "Tracks Infinity ball drop.",
    Config.InfinityBallDetection, function(state)
        Config.InfinityBallDetection = state
        AutoSaveConfig()
    end, false)
ctrls.DeathSlashDetection = createToggleRow(detectPage, "Death Slash Detection", "Counters Death Slash dashes.",
    Config.DeathSlashDetection, function(state)
        Config.DeathSlashDetection = state
        AutoSaveConfig()
    end, false)
local playerPage = tabs["Player Mod"]
createCategoryHeader(playerPage, "MOVEMENT MODIFIERS")
ctrls.MovementModifiers = createToggleRow(playerPage, "Movement modifiers",
    "Enable speed and jump modifications (Warning: high speeds flag BAC Hfd).", Config.MovementModifiers, function(state)
        Config.MovementModifiers = state
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum and not state then
            hum.WalkSpeed = defaultGameWalkSpeed
            hum.JumpPower = defaultGameJumpPower
        end
        AutoSaveConfig()
    end, false)
ctrls.WalkSpeed = createSliderRow(playerPage, "WalkSpeed", "Player movement speed.", 16, 120, Config.WalkSpeed, false, "",
    function(val)
        Config.WalkSpeed = math.floor(val)
        if Config.MovementModifiers then
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = Config.WalkSpeed end
        end
        AutoSaveConfig()
    end)
ctrls.JumpPower = createSliderRow(playerPage, "JumpPower", "Player jump power.", 50, 200, Config.JumpPower, false, "",
    function(val)
        Config.JumpPower = math.floor(val)
        if Config.MovementModifiers then
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then hum.JumpPower = Config.JumpPower end
        end
        AutoSaveConfig()
    end, true)
createCategoryHeader(playerPage, "IMMORTALITY DESYNC")
ctrls.ImmortalityDesync = createToggleRow(
    playerPage,
    "Immortality Desync",
    "3D orbital network velocity desynchronization.",
    Config.ImmortalityDesync,
    function(state)
        Config.ImmortalityDesync = state
        AutoSaveConfig()
    end,
    false
)
local function SetPhysicsSendRate(enabled)
    pcall(function()
        if settings and settings().Physics then
            settings().Physics.PhysicsSendRate = enabled and 60 or 20
        end
    end)
end
ctrls.SpeedBypass = createToggleRow(
    playerPage,
    "Speed Bypass",
    "Change the physics sender rate while enabled.",
    Config.SpeedBypass,
    function(state)
        Config.SpeedBypass = state
        SetPhysicsSendRate(state)
        AutoSaveConfig()
    end,
    false
)
ctrls.OrbitalAngle = createSliderRow(
    playerPage,
    "Orbital Angle",
    "Angular speed and rotation frequency of desync orbit.",
    1, 360, Config.OrbitalAngle, false, "°",
    function(val)
        Config.OrbitalAngle = math.floor(val)
        AutoSaveConfig()
    end
)
ctrls.PeakHeight = createSliderRow(
    playerPage,
    "Peak Height",
    "Vertical altitude wave height above ground.",
    1, 50, Config.PeakHeight, false, " studs",
    function(val)
        Config.PeakHeight = math.floor(val)
        AutoSaveConfig()
    end
)
ctrls.DesyncDepth = createSliderRow(
    playerPage,
    "Desync Depth",
    "Negative orbit depth.",
    1, 25, Config.DesyncDepth, false, "",
    function(val)
        Config.DesyncDepth = math.floor(val)
        AutoSaveConfig()
    end
)
ctrls.OrbitRadius = createSliderRow(
    playerPage,
    "Orbit Radius",
    "Orbital radius in studs around character position.",
    1, 50, Config.OrbitRadius, false, " studs",
    function(val)
        Config.OrbitRadius = math.floor(val)
        AutoSaveConfig()
    end
)
createCategoryHeader(playerPage, "PLAYER ESP & VISUALS")
ctrls.PlayerESP = createToggleRow(
    playerPage,
    "Player Ability ESP",
    "Displays player names, equipped abilities, and distances.",
    Config.PlayerESP,
    function(state)
        Config.PlayerESP = state
        UpdatePlayerESP()
        AutoSaveConfig()
    end,
    false
)
SyncUIWithConfig = function()
    for k, ctrl in pairs(ctrls) do
        local val = Config[k]
        if val ~= nil and ctrl then
            if ctrl.SetState and typeof(val) == "boolean" then
                ctrl.SetState(val)
            elseif ctrl.SetValue and typeof(val) == "number" then
                ctrl.SetValue(val)
            elseif ctrl.SetOption and typeof(val) == "string" then
                ctrl.SetOption(val)
            elseif ctrl.SetOption and typeof(val) == "EnumItem" then
                ctrl.SetOption(val.Name)
            end
        end
    end
    if Config.UIKeybind then
        footerRight.Text = CleanText(Config.UIKeybind.Name:upper() .. " TO HIDE")
    end
    autoParryEnabled = Config.AutoParry
    footerLeft.Text = CleanText(autoParryEnabled and "Auto Parry: ACTIVE" or "RELWX HUB engine ready")
    runStatusRow.SetValue(autoParryEnabled and "Auto Parry: ACTIVE" or "RELWX HUB engine ready")
    UpdateVisualRings()
    UpdatePlayerESP()
end
searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local q = searchBox.Text:lower():gsub("%s+", "")
    for _, tabScroll in pairs(tabs) do
        for _, child in ipairs(tabScroll:GetChildren()) do
            if child:IsA("Frame") and rowSearchIndex[child] then
                if q == "" then
                    child.Visible = true
                else
                    local match = rowSearchIndex[child]:gsub("%s+", ""):find(q)
                    child.Visible = (match ~= nil)
                end
            end
        end
    end
end)
local isDraggingWindow = false
local dragStartPos
local frameStartPos
topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDraggingWindow = true
        dragStartPos = input.Position
        frameStartPos = mainFrame.Position
    end
end)
table.insert(activeConnections, UserInputService.InputChanged:Connect(function(input)
    if isDraggingWindow and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStartPos
        mainFrame.Position = UDim2.new(
            frameStartPos.X.Scale,
            frameStartPos.X.Offset + delta.X,
            frameStartPos.Y.Scale,
            frameStartPos.Y.Offset + delta.Y
        )
    end
end))
table.insert(activeConnections, UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDraggingWindow = false
    end
end))
local isWindowMinimized = false
minBtn.MouseButton1Click:Connect(function()
    isWindowMinimized = not isWindowMinimized
    if isWindowMinimized then
        bodyFrame.Visible = false
        footerBar.Visible = false
        TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { Size = UDim2.new(0, 680, 0, 39) }):Play()
    else
        local tween = TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { Size = UDim2.new(0, 680, 0, 460) })
        tween:Play()
        tween.Completed:Connect(function()
            if not isWindowMinimized then
                bodyFrame.Visible = true
                footerBar.Visible = true
            end
        end)
    end
end)
local isDraggingCrest = false
local crestDragStart = nil
local crestStartPos = nil
local crestMoved = false
miniCrest.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDraggingCrest = true
        crestDragStart = input.Position
        crestStartPos = miniCrest.Position
        crestMoved = false
    end
end)
table.insert(activeConnections, UserInputService.InputChanged:Connect(function(input)
    if isDraggingCrest and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - crestDragStart
        if math.abs(delta.X) > 4 or math.abs(delta.Y) > 4 then
            crestMoved = true
        end
        local newX = crestStartPos.X.Offset + delta.X
        local newY = crestStartPos.Y.Offset + delta.Y
        miniCrest.Position = UDim2.new(crestStartPos.X.Scale, newX, crestStartPos.Y.Scale, newY)
    end
end))
table.insert(activeConnections, UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if isDraggingCrest then
            isDraggingCrest = false
            if not crestMoved then
                ToggleUiVisibility()
            end
        end
    end
end))
miniCrest.MouseEnter:Connect(function()
    TweenService:Create(miniCrestStroke, TweenInfo.new(0.15), { Color = Colors.PurpleGlow, Thickness = 2 }):Play()
    TweenService:Create(miniCrest, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(28, 20, 46) }):Play()
    TweenService:Create(miniCrestLabel, TweenInfo.new(0.15),
        { TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 20 })
        :Play()
end)
miniCrest.MouseLeave:Connect(function()
    TweenService:Create(miniCrestStroke, TweenInfo.new(0.15), { Color = Colors.PurplePrimary, Thickness = 1.5 }):Play()
    TweenService:Create(miniCrest, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(16, 12, 26) }):Play()
    TweenService:Create(miniCrestLabel, TweenInfo.new(0.15), { TextColor3 = Colors.PurplePrimary, TextSize = 18 }):Play()
end)
local isUiVisible = true
ToggleUiVisibility = function()
    isUiVisible = not isUiVisible
    if isUiVisible then
        mainFrame.Visible = true
        if isWindowMinimized then
            bodyFrame.Visible = false
            footerBar.Visible = false
            mainFrame.Size = UDim2.new(0, 680, 0, 39)
        else
            bodyFrame.Visible = true
            footerBar.Visible = true
            mainFrame.Size = UDim2.new(0, 680, 0, 460)
        end
    else
        mainFrame.Visible = false
    end
    if Config.KeepCrestMinimised then
        miniCrest.Visible = true
    end
    HideTooltip()
end
local lastAbilityTime = 0
local function TriggerAbilityDefend()
    local now = tick()
    if now - lastAbilityTime < 2.5 then return end
    lastAbilityTime = now
    pcall(function()
        if keypress then
            keypress(0x51)
            task.delay(0.015, function()
                pcall(function() keyrelease(0x51) end)
            end)
        end
    end)
end
local function PerformParry()
    pcall(function()
        if keypress then
            keypress(0x46)
            task.delay(0.01, function()
                pcall(function() keyrelease(0x46) end)
            end)
        elseif mouse1click then
            mouse1click()
        end
    end)
end
local function SendAction(isClashing, isSuperFast, ball)
    if not IsPlayerInMatch() then return false end
    local now = tick()
    local isClashMode = (Config.AutoSpam and (isClashing or (ball and LocalPlayer.Character and (ball.Position - LocalPlayer.Character:GetPivot().Position).Magnitude <= Config.AutoSpamDistance))) or
        isSuperFast or furyCounterActive
    local spamRate = math.clamp(Config.SpamActionsPerSecond or 50, 10, 100)
    local rawCd = isClashMode and (1 / spamRate) or 0.022
    if Config.SpamBatchMode == "Safe" then
        rawCd = math.max(0.080, rawCd)
    elseif Config.SpamBatchMode == "Normal" then
        rawCd = math.max(0.040, rawCd)
    elseif Config.SpamBatchMode == "Fast" then
        rawCd = math.max(0.025, rawCd)
    elseif Config.SpamBatchMode == "Extremely Fast" then
        rawCd = math.max(0.015, rawCd)
    end
    local jitter = (math.random(-2, 4) / 1000)
    local cd = math.max(0.012, rawCd + jitter)
    if (now - LastClick) < cd then
        return false
    end
    LastClick = now
    LastBallHit = ball
    lastTelemetry.parryTime = now
    PerformParry()
    if Config.AutoAbilities and isSuperFast and not isClashing then
        task.delay(0.08, TriggerAbilityDefend)
    end
    task.delay(math.min(0.025, cd * 0.5), function()
    end)
    return true
end
local function GetBall()
    if not IsPlayerInMatch() then return nil end
    local ballsFolder = Workspace:FindFirstChild("Balls")
    if not ballsFolder then return nil end
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local rootPos = root.Position
    local bestBall = nil
    local closestDist = math.huge
    for _, v in ipairs(ballsFolder:GetChildren()) do
        if v:IsA("BasePart") then
            local target = v:GetAttribute("target") or v:GetAttribute("Target") or v:GetAttribute("currentTarget") or
                v:GetAttribute("to")
            local isReal = v:GetAttribute("realBall") == true or target ~= nil or v.Name:find("Ball")
            if isReal or (Config.PhantomDetection and (v.Transparency > 0 or v:FindFirstChild("Phantom") or v:GetAttribute("Phantom"))) then
                local d = (v.Position - rootPos).Magnitude
                if d <= 450 or (target and (target == LocalPlayer.Name or target == LocalPlayer.DisplayName or (char and target == char.Name))) then
                    if target and (target == LocalPlayer.Name or target == LocalPlayer.DisplayName or (char and target == char.Name)) then
                        return v
                    end
                    if d < closestDist then
                        closestDist = d
                        bestBall = v
                    end
                end
            end
        end
    end
    return bestBall
end
local function IsTargeted(ball, threat)
    local char = LocalPlayer.Character
    if not char then return false end
    if ball then
        local target = ball:GetAttribute("target")
            or ball:GetAttribute("Target")
            or ball:GetAttribute("currentTarget")
            or ball:GetAttribute("targetPlayer")
            or ball:GetAttribute("to")
        if target ~= nil then
            if target == LocalPlayer.Name
                or target == LocalPlayer.DisplayName
                or target == char.Name
                or target == LocalPlayer.UserId
                or target == tostring(LocalPlayer.UserId)
                or target == LocalPlayer
                or target == char
                or target == true
                or target == "Training"
                or ball:GetAttribute("training") == true then
                return true
            end
        end
        local tChild = ball:FindFirstChild("target") or ball:FindFirstChild("Target")
        if tChild and tChild:IsA("ValueBase") then
            local val = tChild.Value
            if val == LocalPlayer.Name
                or val == char.Name
                or val == LocalPlayer
                or val == LocalPlayer.UserId
                or val == tostring(LocalPlayer.UserId) then
                return true
            end
        end
        if Config.DeathSlashDetection and (ball:GetAttribute("DeathSlash") == true or ball:FindFirstChild("DeathSlashEffect") ~= nil) then
            return true
        end
        if Config.PhantomDetection and (ball:GetAttribute("Phantom") == true or ball:FindFirstChild("Phantom") or (threat and threat.isPhantom)) then
            if threat and threat.dot and threat.dot > 0.65 and threat.approachSpeed > 10 and threat.distance < 50 then
                return true
            end
        end
    end
    if char:GetAttribute("Targeted") == true or char:FindFirstChild("TargetHighlight") ~= nil then
        return true
    end
    local hl = char:FindFirstChild("Highlight")
    if hl and hl:IsA("Highlight") then
        if (hl.FillColor.R > 0.60 and hl.FillColor.G < 0.45 and hl.FillColor.B < 0.45)
            or (hl.OutlineColor.R > 0.60 and hl.OutlineColor.G < 0.45 and hl.OutlineColor.B < 0.45)
            or hl:GetAttribute("Target") == true then
            return true
        end
    end
    if threat and threat.dot and threat.dot > 0.60 and threat.approachSpeed > 10 and threat.distance < 70 then
        return true
    end
    return false
end
local function ComputeThreat(ball, root)
    if not ball or not root then return nil end
    local ballPos = ball.Position
    local playerPos = root.Position
    local distance = (playerPos - ballPos).Magnitude
    local velocity = ball.AssemblyLinearVelocity
    local zoomies = ball:FindFirstChild("zoomies")
    if zoomies then
        if zoomies:IsA("LinearVelocity") or zoomies:IsA("VectorForce") then
            velocity = zoomies.VectorVelocity
        elseif zoomies:IsA("BodyVelocity") then
            velocity = zoomies.Velocity
        end
    end
    local speed = velocity.Magnitude
    if speed <= 0 then
        speed = ball.Velocity.Magnitude
        velocity = ball.Velocity
    end
    if Config.TimeHoleDetection then
        if speed <= 2 and (ball:FindFirstChild("TimeHole") or ball:GetAttribute("TimeHole") or Workspace:FindFirstChild("TimeHole")) then
            timeHoleLock = true
            return nil
        elseif timeHoleLock and speed > 10 then
            timeHoleLock = false
            speed = speed * 1.35
        end
    end
    if Config.InfinityBallDetection and (ball:GetAttribute("Infinity") == true or ball:FindFirstChild("InfinityBallEffect")) then
        if velocity.Y < -5 and distance < 35 then
            speed = speed * 1.25
        end
    end
    if Config.SlashesOfFuryDetection then
        local deltaV = (velocity - lastBallVelocity).Magnitude
        if deltaV > 45 and distance < Config.ClashDistance + 10 then
            furyCounterActive = true
        else
            furyCounterActive = false
        end
    end
    local nowTime = tick()
    local dtVel = math.clamp(nowTime - lastVelocityTime, 0.001, 0.050)
    lastVelocityTime = nowTime
    local rawAccel = (velocity - lastBallVelocity) / dtVel
    local deltaV = (velocity - lastBallVelocity).Magnitude
    lastBallVelocity = velocity
    lastBallAcceleration = rawAccel
    if speed <= 0 then return nil end
    local directionToPlayer = (playerPos - ballPos).Unit
    local velocityDirection = velocity.Unit
    local dot = directionToPlayer:Dot(velocityDirection)
    local rootVel = root.AssemblyLinearVelocity or Vector3.zero
    local relVelocity = velocity - rootVel
    local approachSpeed = relVelocity:Dot(directionToPlayer)
    if Config.CurveMode == "Camera" and Camera then
        local camLook = Camera.CFrame.LookVector
        local camDot = camLook:Dot(velocityDirection)
        dot = (dot + (camDot * 0.35)) / 1.35
    elseif Config.CurveMode == "Trajectory" then
        if deltaV > 15 then
            dot = math.max(dot, 0.50)
        end
    elseif Config.CurveMode == "Predictive" then
        local predictedPos = playerPos + (rootVel * 0.15)
        local predictedDir = (predictedPos - ballPos).Unit
        dot = predictedDir:Dot(velocityDirection)
    end
    local effectiveSpeed = math.max(approachSpeed, speed * 0.72)
    local timeToReach = distance / math.max(effectiveSpeed, 1)
    local activeAbilityName = nil
    if timeHoleLock or Workspace:FindFirstChild("TimeHole") or ball:FindFirstChild("TimeHole") then
        activeAbilityName = "Time Hole"
    elseif furyCounterActive or ball:FindFirstChild("ComboCounter") then
        activeAbilityName = "Slashes of Fury"
    elseif ball:GetAttribute("Infinity") == true or ball:FindFirstChild("InfinityBallEffect") then
        activeAbilityName = "Infinity Ball"
    elseif ball:GetAttribute("DeathSlash") == true or ball:FindFirstChild("DeathSlashEffect") then
        activeAbilityName = "Death Slash"
    elseif ball:GetAttribute("Phantom") == true or ball:FindFirstChild("Phantom") or ball:FindFirstChild("PhantomEffect") then
        activeAbilityName = "Phantom"
    elseif ball:GetAttribute("Telekinesis") == true or ball:FindFirstChild("TelekinesisEffect") or Workspace:FindFirstChild("Telekinesis") then
        activeAbilityName = "Telekinesis"
    elseif ball:GetAttribute("Raptured") == true or ball:FindFirstChild("RaptureEffect") then
        activeAbilityName = "Rapture"
    elseif ball:GetAttribute("Pulled") == true or ball:FindFirstChild("PullEffect") then
        activeAbilityName = "Pull"
    end
    return {
        ball = ball,
        distance = distance,
        speed = speed,
        approachSpeed = approachSpeed,
        dot = dot,
        timeToReach = timeToReach,
        velocity = velocity,
        curveDelta = deltaV,
        acceleration = lastBallAcceleration,
        abilityActive = activeAbilityName,
        isPhantom = (activeAbilityName == "Phantom")
    }
end
local currentGlitchedBall = nil
local glitchCaughtTime = 0
local glitchReleaseDelay = 0
local function AutoParryLogic(dt)
    if not autoParryEnabled then return end
    if not IsPlayerInMatch() then return end
    local char = LocalPlayer.Character
    if not char then return end
    local ball = GetBall()
    if not ball then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local threat = ComputeThreat(ball, root)
    if not threat then return end
    local pingMs = 60
    pcall(function()
        if LocalPlayer and LocalPlayer.GetNetworkPing then
            local np = LocalPlayer:GetNetworkPing()
            if np and np > 0 then
                pingMs = math.floor(np * 1000)
                return
            end
        end
        if Stats and Stats.Network and Stats.Network.ServerStatsItem then
            pingMs = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
        end
    end)
    pingMs = math.clamp(pingMs, 10, 400)
    local ballTargetAttr = ball:GetAttribute("target") or ball:GetAttribute("Target") or
        ball:GetAttribute("currentTarget") or ball:GetAttribute("to")
    local isDirectTarget = (ballTargetAttr ~= nil and (ballTargetAttr == LocalPlayer.Name or ballTargetAttr == LocalPlayer.DisplayName or ballTargetAttr == char.Name))
    local isTarget = isDirectTarget or IsTargeted(ball, threat)
    local nearestEnemyDist = GetNearestAliveEnemy(root.Position)
    local isNearOpponent = (nearestEnemyDist <= (Config.ClashDistance + 8))
    local isRealClash = (threat.distance <= Config.ClashDistance and isNearOpponent) or furyCounterActive
    lastTelemetry.time = tick()
    lastTelemetry.speed = threat.speed
    lastTelemetry.distance = threat.distance
    lastTelemetry.approachSpeed = threat.approachSpeed
    lastTelemetry.dot = threat.dot
    lastTelemetry.timeToReach = threat.timeToReach
    lastTelemetry.curveDelta = threat.curveDelta or 0
    lastTelemetry.ping = pingMs
    lastTelemetry.isTarget = isTarget
    lastTelemetry.isClashing = isRealClash
    lastTelemetry.nearestEnemyDist = nearestEnemyDist
    lastTelemetry.abilityActive = threat.abilityActive
    if not isTarget then return end
    local isSuperFast = threat.speed >= 120
    if LastBallHit == ball and not isRealClash then
        if threat.approachSpeed <= 0 and (tick() - LastClick) < 0.08 then
            return
        end
    end
    if Config.ImmortalityDesync and (tick() - LastClick) < 0.35 then
        return
    end
    local pingSec = pingMs / 1000
    local dtStep = math.clamp(dt or 0.016, 0.001, 0.033)
    local baseHorizon = (Config.PredictionHorizon or 0.45) * (Config.BallPrediction or 0.08)
    local speedScaledHorizon = baseHorizon + math.clamp((threat.speed - 150) * 0.0003, 0, 0.12)
    local totalTransitDelay = (pingSec * 0.50) + (dtStep * 0.50) + (1 / 60) + speedScaledHorizon
    local playerVelocity = root.AssemblyLinearVelocity or Vector3.zero
    local ballVelocity = threat.velocity
    local ballAcceleration = threat.acceleration or Vector3.zero
    local futurePlayerPos = root.Position + (playerVelocity * totalTransitDelay)
    local curveCompensation = 0.5 * ballAcceleration * (totalTransitDelay ^ 2)
    if curveCompensation.Magnitude > 15 then
        curveCompensation = curveCompensation.Unit * 15
    end
    local futureBallPos = ball.Position + (ballVelocity * totalTransitDelay) + curveCompensation
    local futureDistance = (futurePlayerPos - futureBallPos).Magnitude
    local baseRadius = 16.0
    local transitDistance = threat.speed * (pingSec * 0.5 + 1 / 60)
    local serverInterceptionRadius = baseRadius + math.clamp(transitDistance, 0, 22)
    if Config.ImmortalityDesync then
        if threat.distance <= 15.0 then
            if currentGlitchedBall ~= ball then
                currentGlitchedBall = ball
                glitchCaughtTime = tick()
                glitchReleaseDelay = math.random(15, 60) / 100
            end
            if (tick() - glitchCaughtTime) >= glitchReleaseDelay or threat.distance <= 5.0 then
                SendAction(isRealClash, isSuperFast, ball)
                currentGlitchedBall = nil
                return
            end
            return
        else
            currentGlitchedBall = nil
        end
    else
        currentGlitchedBall = nil
        if threat.distance <= baseRadius and (threat.dot > 0.05 or threat.approachSpeed > -5) then
            SendAction(isRealClash, isSuperFast, ball)
            return
        end
    end
    if futureDistance <= serverInterceptionRadius and (threat.approachSpeed > -10 or threat.dot > 0.05) then
        SendAction(isRealClash, isSuperFast, ball)
    end
end
local function BindCharacterDeath(char)
    if not char then return end
    local hum = char:WaitForChild("Humanoid", 4)
    if hum then
        table.insert(activeConnections, hum.Died:Connect(OnPlayerDied))
        task.delay(0.6, function()
            if hum and not Config.MovementModifiers and hum.WalkSpeed > 20 then
                defaultGameWalkSpeed = hum.WalkSpeed
                defaultGameJumpPower = hum.JumpPower
            end
        end)
    end
end
if LocalPlayer.Character then
    BindCharacterDeath(LocalPlayer.Character)
end
table.insert(activeConnections, LocalPlayer.CharacterAdded:Connect(function(char)
    BindCharacterDeath(char)
end))
local deadFolder = Workspace:FindFirstChild("Dead")
if deadFolder then
    table.insert(activeConnections, deadFolder.ChildAdded:Connect(function(deadChar)
        if LocalPlayer.Character and deadChar == LocalPlayer.Character then
            OnPlayerDied()
        end
    end))
end
table.insert(activeConnections, Workspace.ChildAdded:Connect(function(child)
    if child.Name == "Dead" then
        table.insert(activeConnections, child.ChildAdded:Connect(function(deadChar)
            if LocalPlayer.Character and deadChar == LocalPlayer.Character then
                OnPlayerDied()
            end
        end))
    end
end))
table.insert(activeConnections, RunService.Heartbeat:Connect(function()
    local inMatch = IsPlayerInMatch()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if Config.ImmortalityDesync and inMatch and root then
        local liveBall = GetLiveBall()
        if liveBall then
            if IsTargeted(liveBall) then
                local dist = (liveBall.Position - root.Position).Magnitude
                if dist < 65 then
                    if not liveBall:GetAttribute("DesyncStartTime") then
                        liveBall:SetAttribute("DesyncStartTime", tick())
                    end
                    local holdTime = tick() - liveBall:GetAttribute("DesyncStartTime")
                    local captureProgress = math.clamp(holdTime / 0.40, 0, 1)
                    local safeRadius = math.clamp((Config.OrbitRadius or 15) * 0.75, 4, 10)
                    local height = ((Config.PeakHeight or 20) / 10) - 1
                    local t = tick() * math.max(1, (Config.DesyncDepth or 8)) * 1.5
                    local orbitOffset = Vector3.new(
                        math.cos(t) * safeRadius,
                        height,
                        math.sin(t) * safeRadius
                    )
                    local basePos = root.Position + orbitOffset
                    local maxIntensity = math.clamp(Config.DesyncDepth or 8, 1, 15)
                    local intensity = maxIntensity * math.pow(captureProgress, 2)
                    local glitchOffset = Vector3.new(
                        (math.random() - 0.5) * intensity,
                        (math.random() - 0.5) * intensity,
                        (math.random() - 0.5) * intensity
                    )
                    local targetPos = basePos + glitchOffset
                    pcall(function()
                        local lerpAlpha = (captureProgress < 1) and 0.15 or 1
                        liveBall.CFrame = liveBall.CFrame:Lerp(CFrame.new(targetPos), lerpAlpha)
                        local safeDir = (root.Position - liveBall.Position).Unit
                        liveBall.AssemblyLinearVelocity = safeDir * 15
                        liveBall.AssemblyAngularVelocity = Vector3.new(0, 5, 0)
                    end)
                else
                    if liveBall:GetAttribute("DesyncStartTime") then
                        liveBall:SetAttribute("DesyncStartTime", nil)
                    end
                end
            else
                if liveBall:GetAttribute("DesyncStartTime") then
                    liveBall:SetAttribute("DesyncStartTime", nil)
                end
            end
        end
    end
    if Config.MovementModifiers and inMatch and hum then
        local targetSpeed = math.clamp(Config.WalkSpeed, 16, 50)
        if hum.WalkSpeed ~= targetSpeed then
            pcall(function() hum.WalkSpeed = targetSpeed end)
        end
        if hum.JumpPower ~= Config.JumpPower then
            pcall(function() hum.JumpPower = Config.JumpPower end)
        end
    end
    UpdateVisualRings()
    if Config.PlayerESP then
        UpdatePlayerESP()
    end
end))
UnloadScript = function()
    autoParryEnabled = false
    for _, conn in pairs(activeConnections) do
        if conn and typeof(conn) == "RBXScriptConnection" and conn.Connected then
            conn:Disconnect()
        end
    end
    table.clear(activeConnections)
    pcall(function()
        ringAdornment:Destroy()
        desyncBubbleAdornment:Destroy()
        espFolder:Destroy()
    end)
    pcall(function()
        if Camera then Camera.FieldOfView = 70 end
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = defaultGameWalkSpeed
            hum.JumpPower = defaultGameJumpPower
        end
    end)
    pcall(function()
        local fadeTween = TweenService:Create(mainFrame,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 680, 0, 0),
                BackgroundTransparency = 1
            })
        fadeTween:Play()
        fadeTween.Completed:Connect(function()
            screenGui:Destroy()
        end)
    end)
    if not screenGui.Parent then
        screenGui:Destroy()
    end
    SendNotification("RELWX HUB", "Script unloaded successfully.", 2)
end
closeBtn.MouseButton1Click:Connect(UnloadScript)
table.insert(activeConnections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Config.UIKeybind then
        ToggleUiVisibility()
    end
    if input.KeyCode == Config.ParryKeybind then
        autoParryEnabled = not autoParryEnabled
        Config.AutoParry = autoParryEnabled
        if ctrls.AutoParry then ctrls.AutoParry.SetState(autoParryEnabled) end
        footerLeft.Text = CleanText(autoParryEnabled and "Auto Parry: ACTIVE" or "RELWX HUB engine ready")
        runStatusRow.SetValue(autoParryEnabled and "Auto Parry: ACTIVE" or "RELWX HUB engine ready")
        SendNotification("Auto Parry", "Auto Parry is now " .. (autoParryEnabled and "ENABLED" or "DISABLED"), 2)
        AutoSaveConfig()
    end
end))
table.insert(activeConnections, RunService.RenderStepped:Connect(function()
end))
local function RunParryCycle(dt)
    local stepDt = (typeof(dt) == "number" and dt) or 0.016
    pcall(AutoParryLogic, stepDt)
end
if RunService.PreSimulation then
    table.insert(activeConnections, RunService.PreSimulation:Connect(RunParryCycle))
end
table.insert(activeConnections, RunService.RenderStepped:Connect(RunParryCycle))
table.insert(activeConnections, RunService.Heartbeat:Connect(RunParryCycle))
local loaded = LoadSavedConfig()
if loaded then
    SyncUIWithConfig()
    SendNotification("RELWX HUB", "Default configuration loaded.", 2)
else
    SendNotification("RELWX HUB", "Loaded successfully. [LeftControl to Toggle]", 2)
end

