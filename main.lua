-- UNIVERSAL SCRIPT WITH FOLLOW, ORBIT & AIMBOT
-- Mobile Controls PRESERVED + DEBUG MODE

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
    OrbitSpeed = 2,
    DebugMode = true  -- デバッグモード追加
}

local clickConnection = nil
local followConnection = nil
local orbitConnection = nil
local aimbotConnection = nil
local lastClick = 0
local orbitAngle = 0

-- Check if mobile
local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled

-- Debug print function
local function DebugPrint(...)
    if Settings.DebugMode then
        print("[DEBUG]", ...)
    end
end

-- Notification
local function Notify(title, msg)
    if Settings.Notifications then
        Rayfield:Notify({
            Title = title,
            Content = msg,
            Duration = 3,
        })
    end
    DebugPrint("Notification:", title, "-", msg)
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
    DebugPrint("Player list updated:", #playerList, "players found")
    return playerList
end

-- Get target player's character
local function GetTargetCharacter()
    if not Settings.TargetPlayer then 
        DebugPrint("No target player set")
        return nil 
    end
    local targetPlayer = Players:FindFirstChild(Settings.TargetPlayer)
    if targetPlayer and targetPlayer.Character then
        return targetPlayer.Character
    end
    DebugPrint("Target player character not found:", Settings.TargetPlayer)
    return nil
end

-- Follow function (尾行)
local function FollowTarget()
    local targetChar = GetTargetCharacter()
    local myChar = Player.Character
    
    if not targetChar or not myChar then 
        DebugPrint("Follow: Missing character data")
        return 
    end
    
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    local myHumanoid = myChar:FindFirstChild("Humanoid")
    
    if targetRoot and myRoot and myHumanoid then
        local targetPos = targetRoot.Position
        local direction = (myRoot.Position - targetPos).Unit
        local followPos = targetPos + (direction * Settings.FollowDistance)
        
        myHumanoid:MoveTo(followPos)
    else
        DebugPrint("Follow: Missing components")
    end
end

-- Orbit function (周回)
local function OrbitTarget()
    local targetChar = GetTargetCharacter()
    local myChar = Player.Character
    
    if not targetChar or not myChar then 
        DebugPrint("Orbit: Missing character data")
        return 
    end
    
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
    else
        DebugPrint("Orbit: Missing components")
    end
end

-- Aimbot function (標準固定)
local function AimbotTarget()
    local targetChar = GetTargetCharacter()
    
    if not targetChar then 
        DebugPrint("Aimbot: No target character")
        return 
    end
    
    local targetHead = targetChar:FindFirstChild("Head")
    
    if targetHead then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetHead.Position)
    else
        DebugPrint("Aimbot: Head not found")
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
        DebugPrint("Click speed changed to", Value)
        Notify("Click Speed", tostring(Value) .. " CPS")
   end,
})

ClickTab:CreateToggle({
   Name = "Enable Auto Click",
   CurrentValue = false,
   Callback = function(State)
        DebugPrint("Auto Click Toggle:", State)
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
        DebugPrint("Target selected:", Option)
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
        DebugPrint("Follow distance:", Value)
   end,
})

local FollowToggle = FollowTab:CreateToggle({
   Name = "Enable Follow",
   CurrentValue = false,
   Callback = function(State)
        DebugPrint("========================================")
        DebugPrint("FOLLOW TOGGLE PRESSED:", State)
        DebugPrint("Target Player:", Settings.TargetPlayer or "NONE")
        DebugPrint("========================================")
        
        if State then
            if not Settings.TargetPlayer or Settings.TargetPlayer == "None" then
                DebugPrint("ERROR: No target selected!")
                Notify("⚠️ Error", "Please select a target first!")
                Settings.FollowEnabled = false
                return
            end
            
            -- Disable orbit if active
            if Settings.OrbitEnabled then
                DebugPrint("Disabling Orbit mode")
                Settings.OrbitEnabled = false
                if orbitConnection then
                    orbitConnection:Disconnect()
                    orbitConnection = nil
                end
            end
            
            Settings.FollowEnabled = true
            
            followConnection = RunService.Heartbeat:Connect(function()
                if Settings.FollowEnabled then
                    FollowTarget()
                end
            end)
            
            DebugPrint("Follow mode STARTED for", Settings.TargetPlayer)
            Notify("✓ Follow ENABLED", "Following " .. Settings.TargetPlayer)
        else
            Settings.FollowEnabled = false
            if followConnection then
                followConnection:Disconnect()
                followConnection = nil
            end
            DebugPrint("Follow mode STOPPED")
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
        DebugPrint("Orbit distance:", Value)
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
        DebugPrint("Orbit speed:", Value)
   end,
})

local OrbitToggle = FollowTab:CreateToggle({
   Name = "Enable Orbit",
   CurrentValue = false,
   Callback = function(State)
        DebugPrint("========================================")
        DebugPrint("ORBIT TOGGLE PRESSED:", State)
        DebugPrint("Target Player:", Settings.TargetPlayer or "NONE")
        DebugPrint("========================================")
        
        if State then
            if not Settings.TargetPlayer or Settings.TargetPlayer == "None" then
                DebugPrint("ERROR: No target selected!")
                Notify("⚠️ Error", "Please select a target first!")
                Settings.OrbitEnabled = false
                return
            end
            
            -- Disable follow if active
            if Settings.FollowEnabled then
                DebugPrint("Disabling Follow mode")
                Settings.FollowEnabled = false
                if followConnection then
                    followConnection:Disconnect()
                    followConnection = nil
                end
            end
            
            Settings.OrbitEnabled = true
            orbitAngle = 0
            
            orbitConnection = RunService.Heartbeat:Connect(function()
                if Settings.OrbitEnabled then
                    OrbitTarget()
                end
            end)
            
            DebugPrint("Orbit mode STARTED for", Settings.TargetPlayer)
            Notify("✓ Orbit ENABLED", "Orbiting " .. Settings.TargetPlayer)
        else
            Settings.OrbitEnabled = false
            if orbitConnection then
                orbitConnection:Disconnect()
                orbitConnection = nil
            end
            DebugPrint("Orbit mode STOPPED")
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

local AimbotToggle = AimbotTab:CreateToggle({
   Name = "Enable Aimbot",
   CurrentValue = false,
   Callback = function(State)
        DebugPrint("========================================")
        DebugPrint("AIMBOT TOGGLE PRESSED:", State)
        DebugPrint("Target Player:", Settings.TargetPlayer or "NONE")
        DebugPrint("========================================")
        
        if State then
            if not Settings.TargetPlayer or Settings.TargetPlayer == "None" then
                DebugPrint("ERROR: No target selected!")
                Notify("⚠️ Error", "Please select a target first!")
                Settings.AimbotEnabled = false
                return
            end
            
            Settings.AimbotEnabled = true
            
            aimbotConnection = RunService.RenderStepped:Connect(function()
                if Settings.AimbotEnabled then
                    AimbotTarget()
                end
            end)
            
            DebugPrint("Aimbot STARTED for", Settings.TargetPlayer)
            Notify("✓ Aimbot ENABLED", "Locked on " .. Settings.TargetPlayer)
        else
            Settings.AimbotEnabled = false
            if aimbotConnection then
                aimbotConnection:Disconnect()
                aimbotConnection = nil
            end
            DebugPrint("Aimbot STOPPED")
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
        DebugPrint("Notifications:", State)
   end,
})

SettingsTab:CreateSection("🐛 Debug Mode")

SettingsTab:CreateToggle({
   Name = "Enable Debug Mode",
   CurrentValue = true,
   Callback = function(State)
        Settings.DebugMode = State
        print("[DEBUG MODE]", State and "ENABLED" or "DISABLED")
   end,
})

SettingsTab:CreateButton({
   Name = "Show Current Status",
   Callback = function()
        print("========== CURRENT STATUS ==========")
        print("Target Player:", Settings.TargetPlayer or "NONE")
        print("Follow Enabled:", Settings.FollowEnabled)
        print("Orbit Enabled:", Settings.OrbitEnabled)
        print("Aimbot Enabled:", Settings.AimbotEnabled)
        print("Follow Connection:", followConnection and "Active" or "Inactive")
        print("Orbit Connection:", orbitConnection and "Active" or "Inactive")
        print("Aimbot Connection:", aimbotConnection and "Active" or "Inactive")
        print("===================================")
        Notify("Status", "Check console (F9)")
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
        DebugPrint("ALL FEATURES STOPPED")
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
    Title = "Universal Script Pro v1.1 (Debug)",
    Content = "Auto Click, Follow, Orbit, Aimbot機能を搭載した万能スクリプト。全デバイス対応でモバイルコントロールも保護されます。"
})

InfoTab:CreateSection("✨ Features")

InfoTab:CreateLabel("✓ Auto Click: 1-50 CPS")
InfoTab:CreateLabel("✓ Follow: プレイヤー尾行")
InfoTab:CreateLabel("✓ Orbit: プレイヤー周回")
InfoTab:CreateLabel("✓ Aimbot: 頭部ロックオン")
InfoTab:CreateLabel("✓ Mobile: コントロール保護")
InfoTab:CreateLabel("✓ Debug: デバッグモード搭載")

InfoTab:CreateSection("📱 使い方")

InfoTab:CreateParagraph({
    Title = "Follow/Orbit使用方法",
    Content = "1. Follow/Orbitタブを開く\n2. ターゲットプレイヤーを選択\n3. FollowまたはOrbitをON\n4. 距離や速度を調整可能\n\nFollow: ターゲットを後ろから追跡\nOrbit: ターゲットの周りを円形に移動"
})

InfoTab:CreateParagraph({
    Title = "Aimbot使用方法",
    Content = "1. Follow/Orbitでターゲット選択\n2. Aimbotタブを開く\n3. Enable AimbotをON\n4. カメラが常に頭部を追跡\n\n※Follow/Orbitと同時使用可能"
})

InfoTab:CreateSection("🐛 Troubleshooting")

InfoTab:CreateParagraph({
    Title = "動作しない場合",
    Content = "1. F9キーでコンソールを開く\n2. Settingsタブで「Show Current Status」を押す\n3. デバッグメッセージを確認\n4. ターゲットが正しく選択されているか確認\n5. 「STOP ALL FEATURES」で全機能をリセット"
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
print("UNIVERSAL SCRIPT PRO V1.1 (DEBUG MODE)")
print("=" .. string.rep("=", 50))
print("Status: LOADED ✓")
print("Player: " .. Player.Name)
print("Device: " .. (isMobile and "Mobile (Touch)" or "PC (Keyboard/Mouse)"))
print("Features: Auto Click, Follow, Orbit, Aimbot")
print("Debug Mode: ENABLED (Press F9 to see logs)")
print("=" .. string.rep("=", 50))
print("")
print("🐛 DEBUG TIPS:")
print("- Use 'Show Current Status' button to check state")
print("- All toggle actions will print to console")
print("- Check for error messages in red")
print("=" .. string.rep("=", 50))
