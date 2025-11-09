-- UNIVERSAL SCRIPT WITH FOLLOW, ORBIT & AIMBOT
-- Mobile Controls PRESERVED

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "🎮 Universal Script Pro",
   LoadingTitle = "Loading Universal Script...",
   LoadingSubtitle = "Follow, Orbit & Aimbot Ready",
   ConfigurationSaving = {Enabled = false},
   KeySystem = false,
})

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

-- Variables
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Camera = Workspace.CurrentCamera

local Settings = {
    ClickSpeed = 10,
    AutoClickActive = false,
    Notifications = true,
    FollowEnabled = false,
    OrbitEnabled = false,
    AimbotEnabled = false,
    TargetPlayer = nil,
    FollowDistance = 5,
    OrbitDistance = 10,
    OrbitSpeed = 2
}

local clickConnection = nil
local followConnection = nil
local orbitConnection = nil
local aimbotConnection = nil
local lastClick = 0
local orbitAngle = 0

-- Check if mobile
local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled

-- Notification
local function Notify(title, msg)
    if Settings.Notifications then
        Rayfield:Notify({
            Title = title,
            Content = msg,
            Duration = 3,
        })
    end
end

-- IMPORTANT: Ensure mobile controls stay visible
local function PreserveMobileControls()
    if isMobile then
        pcall(function()
            local TouchGui = PlayerGui:FindFirstChild("TouchGui")
            if TouchGui then
                TouchGui.Enabled = true
                local TouchControlFrame = TouchGui:FindFirstChild("TouchControlFrame")
                if TouchControlFrame then
                    TouchControlFrame.Visible = true
                    local Thumbstick = TouchControlFrame:FindFirstChild("ThumbstickFrame")
                    if Thumbstick then
                        Thumbstick.Visible = true
                        Thumbstick.Active = true
                    end
                end
                local JumpButton = TouchGui:FindFirstChild("JumpButton")
                if JumpButton then
                    JumpButton.Visible = true
                    JumpButton.Active = true
                end
            end
        end)
    end
end

-- Keep controls visible
if isMobile then
    spawn(function()
        while task.wait(0.5) do
            PreserveMobileControls()
        end
    end)
end

-- Auto Click Function
local function ExecuteClick()
    local now = tick()
    if now - lastClick < (1 / Settings.ClickSpeed) then
        return
    end
    lastClick = now
    
    spawn(function()
        pcall(function()
            local tool = Player.Character and Player.Character:FindFirstChildOfClass("Tool")
            if tool and tool:FindFirstChild("Handle") then
                tool:Activate()
            else
                local ViewportSize = Camera.ViewportSize
                local center = Vector2.new(ViewportSize.X / 2, ViewportSize.Y / 2)
                local VirtualInputManager = game:GetService("VirtualInputManager")
                VirtualInputManager:SendMouseButtonEvent(center.X, center.Y, 0, true, game, 0)
                task.wait(0.01)
                VirtualInputManager:SendMouseButtonEvent(center.X, center.Y, 0, false, game, 0)
            end
        end)
    end)
end

-- Get player list
local function GetPlayerList()
    local playerList = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Player then
            table.insert(playerList, player.Name)
        end
    end
    return playerList
end

-- Get target player's character
local function GetTargetCharacter()
    if not Settings.TargetPlayer then return nil end
    local targetPlayer = Players:FindFirstChild(Settings.TargetPlayer)
    if targetPlayer and targetPlayer.Character then
        return targetPlayer.Character
    end
    return nil
end

-- Follow function (尾行)
local function FollowTarget()
    local targetChar = GetTargetCharacter()
    local myChar = Player.Character
    
    if not targetChar or not myChar then return end
    
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    local myHumanoid = myChar:FindFirstChild("Humanoid")
    
    if targetRoot and myRoot and myHumanoid then
        local targetPos = targetRoot.Position
        local direction = (myRoot.Position - targetPos).Unit
        local followPos = targetPos + (direction * Settings.FollowDistance)
        
        myHumanoid:MoveTo(followPos)
    end
end

-- Orbit function (周回)
local function OrbitTarget()
    local targetChar = GetTargetCharacter()
    local myChar = Player.Character
    
    if not targetChar or not myChar then return end
    
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    local myHumanoid = myChar:FindFirstChild("Humanoid")
    
    if targetRoot and myRoot and myHumanoid then
        orbitAngle = orbitAngle + (Settings.OrbitSpeed * 0.05)
        if orbitAngle > 360 then orbitAngle = 0 end
        
        local targetPos = targetRoot.Position
        local x = math.cos(math.rad(orbitAngle)) * Settings.OrbitDistance
        local z = math.sin(math.rad(orbitAngle)) * Settings.OrbitDistance
        local orbitPos = targetPos + Vector3.new(x, 0, z)
        
        myHumanoid:MoveTo(orbitPos)
    end
end

-- Aimbot function (標準固定)
local function AimbotTarget()
    local targetChar = GetTargetCharacter()
    
    if not targetChar then return end
    
    local targetHead = targetChar:FindFirstChild("Head")
    
    if targetHead then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetHead.Position)
    end
end

-- ==================== AUTO CLICK TAB ====================
local ClickTab = Window:CreateTab("🖱️ Auto Click", 4483362458)

ClickTab:CreateSection("⚙️ Click Configuration")

ClickTab:CreateSlider({
   Name = "Click Speed (CPS)",
   Range = {1, 50},
   Increment = 1,
   Suffix = " CPS",
   CurrentValue = 10,
   Callback = function(Value)
        Settings.ClickSpeed = Value
        Notify("Click Speed", tostring(Value) .. " CPS")
   end,
})

ClickTab:CreateToggle({
   Name = "Enable Auto Click",
   CurrentValue = false,
   Callback = function(State)
        Settings.AutoClickActive = State
        
        if State then
            clickConnection = RunService.Heartbeat:Connect(function()
                if Settings.AutoClickActive then
                    ExecuteClick()
                end
            end)
            PreserveMobileControls()
            Notify("Auto Click", "ENABLED - " .. Settings.ClickSpeed .. " CPS")
        else
            if clickConnection then
                clickConnection:Disconnect()
                clickConnection = nil
            end
            Notify("Auto Click", "DISABLED")
        end
   end,
})

-- ==================== FOLLOW TAB ====================
local FollowTab = Window:CreateTab("🚶 Follow/Orbit", 4483362458)

FollowTab:CreateSection("👤 Target Selection")

local targetDropdown = FollowTab:CreateDropdown({
   Name = "Select Target Player",
   Options = GetPlayerList(),
   CurrentOption = "None",
   Callback = function(Option)
        Settings.TargetPlayer = Option
        Notify("Target", "Selected: " .. Option)
   end,
})

FollowTab:CreateButton({
   Name = "🔄 Refresh Player List",
   Callback = function()
        targetDropdown:Refresh(GetPlayerList(), true)
        Notify("Refresh", "Player list updated!")
   end,
})

FollowTab:CreateSection("🚶 Follow Mode (尾行)")

FollowTab:CreateSlider({
   Name = "Follow Distance",
   Range = {1, 20},
   Increment = 1,
   Suffix = " studs",
   CurrentValue = 5,
   Callback = function(Value)
        Settings.FollowDistance = Value
   end,
})

FollowTab:CreateToggle({
   Name = "Enable Follow",
   CurrentValue = false,
   Callback = function(State)
        Settings.FollowEnabled = State
        
        if State then
            if not Settings.TargetPlayer then
                Notify("Error", "Please select a target first!")
                return
            end
            
            -- Disable orbit if active
            Settings.OrbitEnabled = false
            if orbitConnection then
                orbitConnection:Disconnect()
                orbitConnection = nil
            end
            
            followConnection = RunService.Heartbeat:Connect(function()
                if Settings.FollowEnabled then
                    FollowTarget()
                end
            end)
            
            Notify("Follow", "Following " .. Settings.TargetPlayer)
        else
            if followConnection then
                followConnection:Disconnect()
                followConnection = nil
            end
            Notify("Follow", "DISABLED")
        end
   end,
})

FollowTab:CreateSection("🔄 Orbit Mode (周回)")

FollowTab:CreateSlider({
   Name = "Orbit Distance",
   Range = {5, 30},
   Increment = 1,
   Suffix = " studs",
   CurrentValue = 10,
   Callback = function(Value)
        Settings.OrbitDistance = Value
   end,
})

FollowTab:CreateSlider({
   Name = "Orbit Speed",
   Range = {1, 10},
   Increment = 1,
   Suffix = "",
   CurrentValue = 2,
   Callback = function(Value)
        Settings.OrbitSpeed = Value
   end,
})

FollowTab:CreateToggle({
   Name = "Enable Orbit",
   CurrentValue = false,
   Callback = function(State)
        Settings.OrbitEnabled = State
        
        if State then
            if not Settings.TargetPlayer then
                Notify("Error", "Please select a target first!")
                return
            end
            
            -- Disable follow if active
            Settings.FollowEnabled = false
            if followConnection then
                followConnection:Disconnect()
                followConnection = nil
            end
            
            orbitAngle = 0
            orbitConnection = RunService.Heartbeat:Connect(function()
                if Settings.OrbitEnabled then
                    OrbitTarget()
                end
            end)
            
            Notify("Orbit", "Orbiting " .. Settings.TargetPlayer)
        else
            if orbitConnection then
                orbitConnection:Disconnect()
                orbitConnection = nil
            end
            Notify("Orbit", "DISABLED")
        end
   end,
})

-- ==================== AIMBOT TAB ====================
local AimbotTab = Window:CreateTab("🎯 Aimbot", 4483362458)

AimbotTab:CreateSection("🎯 Aimbot Configuration")

AimbotTab:CreateParagraph({
    Title = "Aimbot Info",
    Content = "Aimbotは選択したプレイヤーの頭に常にカメラを向けます。Follow/Orbitと組み合わせて使用できます。"
})

AimbotTab:CreateToggle({
   Name = "Enable Aimbot",
   CurrentValue = false,
   Callback = function(State)
        Settings.AimbotEnabled = State
        
        if State then
            if not Settings.TargetPlayer then
                Notify("Error", "Please select a target first!")
                return
            end
            
            aimbotConnection = RunService.RenderStepped:Connect(function()
                if Settings.AimbotEnabled then
                    AimbotTarget()
                end
            end)
            
            Notify("Aimbot", "Locked on " .. Settings.TargetPlayer)
        else
            if aimbotConnection then
                aimbotConnection:Disconnect()
                aimbotConnection = nil
            end
            Notify("Aimbot", "DISABLED")
        end
   end,
})

AimbotTab:CreateSection("⚠️ Warning")

AimbotTab:CreateLabel("⚠️ Aimbotは検出される可能性があります")
AimbotTab:CreateLabel("⚠️ 責任を持って使用してください")

-- ==================== SETTINGS TAB ====================
local SettingsTab = Window:CreateTab("⚙️ Settings", 4483362458)

SettingsTab:CreateSection("🔔 Notifications")

SettingsTab:CreateToggle({
   Name = "Show Notifications",
   CurrentValue = true,
   Callback = function(State)
        Settings.Notifications = State
   end,
})

SettingsTab:CreateSection("🛑 Emergency Stop")

SettingsTab:CreateButton({
   Name = "STOP ALL FEATURES",
   Callback = function()
        Settings.AutoClickActive = false
        Settings.FollowEnabled = false
        Settings.OrbitEnabled = false
        Settings.AimbotEnabled = false
        
        if clickConnection then clickConnection:Disconnect() clickConnection = nil end
        if followConnection then followConnection:Disconnect() followConnection = nil end
        if orbitConnection then orbitConnection:Disconnect() orbitConnection = nil end
        if aimbotConnection then aimbotConnection:Disconnect() aimbotConnection = nil end
        
        PreserveMobileControls()
        Notify("STOPPED", "All features disabled!")
   end,
})

SettingsTab:CreateSection("🎮 Control Protection")

if isMobile then
    SettingsTab:CreateButton({
       Name = "Force Restore Controls",
       Callback = function()
            PreserveMobileControls()
            Notify("Controls", "Mobile controls restored!")
       end,
    })
end

SettingsTab:CreateSection("📊 Player Information")

SettingsTab:CreateLabel("Username: " .. Player.Name)
SettingsTab:CreateLabel("Display Name: " .. Player.DisplayName)
SettingsTab:CreateLabel("User ID: " .. tostring(Player.UserId))
SettingsTab:CreateLabel("Device Type: " .. (isMobile and "Mobile" or "PC"))

-- ==================== INFO TAB ====================
local InfoTab = Window:CreateTab("ℹ️ Info", 4483362458)

InfoTab:CreateSection("📖 About")

InfoTab:CreateParagraph({
    Title = "Universal Script Pro v1.0",
    Content = "Auto Click, Follow, Orbit, Aimbot機能を搭載した万能スクリプト。全デバイス対応でモバイルコントロールも保護されます。"
})

InfoTab:CreateSection("✨ Features")

InfoTab:CreateLabel("✓ Auto Click: 1-50 CPS")
InfoTab:CreateLabel("✓ Follow: プレイヤー尾行")
InfoTab:CreateLabel("✓ Orbit: プレイヤー周回")
InfoTab:CreateLabel("✓ Aimbot: 頭部ロックオン")
InfoTab:CreateLabel("✓ Mobile: コントロール保護")
InfoTab:CreateLabel("✓ Universal: 全ゲーム対応")

InfoTab:CreateSection("📱 使い方")

InfoTab:CreateParagraph({
    Title = "Follow/Orbit使用方法",
    Content = "1. Follow/Orbitタブを開く\n2. ターゲットプレイヤーを選択\n3. FollowまたはOrbitをON\n4. 距離や速度を調整可能\n\nFollow: ターゲットを後ろから追跡\nOrbit: ターゲットの周りを円形に移動"
})

InfoTab:CreateParagraph({
    Title = "Aimbot使用方法",
    Content = "1. Follow/Orbitでターゲット選択\n2. Aimbotタブを開く\n3. Enable AimbotをON\n4. カメラが常に頭部を追跡\n\n※Follow/Orbitと同時使用可能"
})

-- Initial setup
task.wait(1)
PreserveMobileControls()

if isMobile then
    Notify("📱 Mobile Device", "Controls protected & ready!")
else
    Notify("💻 PC Device", "Ready to use!")
end

Notify("✓ Loaded", "All features ready!")

-- Console output
print("=" .. string.rep("=", 50))
print("UNIVERSAL SCRIPT PRO V1.0")
print("=" .. string.rep("=", 50))
print("Status: LOADED ✓")
print("Player: " .. Player.Name)
print("Device: " .. (isMobile and "Mobile (Touch)" or "PC (Keyboard/Mouse)"))
print("Features: Auto Click, Follow, Orbit, Aimbot")
print("=" .. string.rep("=", 50))
