-- UNIVERSAL AUTO CLICK SCRIPT
-- Mobile Controls PRESERVED - Joystick Won't Disappear

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "🎮 Universal Auto Click",
   LoadingTitle = "Loading Universal Script...",
   LoadingSubtitle = "Mobile Controls Protected",
   ConfigurationSaving = {Enabled = false},
   KeySystem = false,
})

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")

-- Variables
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local Settings = {
    ClickSpeed = 10,
    AutoClickActive = false,
    Notifications = true
}

local clickConnection = nil
local lastClick = 0

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
        -- Make sure TouchGui and ControlsModule stay active
        pcall(function()
            local TouchGui = PlayerGui:FindFirstChild("TouchGui")
            if TouchGui then
                TouchGui.Enabled = true
                
                -- Ensure joystick stays visible
                local TouchControlFrame = TouchGui:FindFirstChild("TouchControlFrame")
                if TouchControlFrame then
                    TouchControlFrame.Visible = true
                    
                    -- Thumbstick (movement joystick)
                    local Thumbstick = TouchControlFrame:FindFirstChild("ThumbstickFrame")
                    if Thumbstick then
                        Thumbstick.Visible = true
                        Thumbstick.Active = true
                    end
                end
                
                -- Jump button
                local JumpButton = TouchGui:FindFirstChild("JumpButton")
                if JumpButton then
                    JumpButton.Visible = true
                    JumpButton.Active = true
                end
            end
        end)
    end
end

-- Keep controls visible (run continuously)
if isMobile then
    spawn(function()
        while task.wait(0.5) do
            PreserveMobileControls()
        end
    end)
end

-- Auto Click Function (doesn't interfere with touch controls)
local function ExecuteClick()
    local now = tick()
    if now - lastClick < (1 / Settings.ClickSpeed) then
        return
    end
    lastClick = now
    
    -- Execute click without blocking touch input
    spawn(function()
        pcall(function()
            -- Use tool activation instead of raw clicks
            local tool = Player.Character and Player.Character:FindFirstChildOfClass("Tool")
            if tool and tool:FindFirstChild("Handle") then
                tool:Activate()
            else
                -- Fallback: simulate click at center screen (won't block controls)
                local ViewportSize = workspace.CurrentCamera.ViewportSize
                local center = Vector2.new(ViewportSize.X / 2, ViewportSize.Y / 2)
                
                -- This method doesn't capture input events
                local VirtualInputManager = game:GetService("VirtualInputManager")
                VirtualInputManager:SendMouseButtonEvent(center.X, center.Y, 0, true, game, 0)
                task.wait(0.01)
                VirtualInputManager:SendMouseButtonEvent(center.X, center.Y, 0, false, game, 0)
            end
        end)
    end)
end

-- ==================== MAIN TAB ====================
local MainTab = Window:CreateTab("🎮 Main", 4483362458)

MainTab:CreateSection("⚙️ Click Configuration")

MainTab:CreateSlider({
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

MainTab:CreateSection("🖱️ Auto Click")

MainTab:CreateToggle({
   Name = "Enable Auto Click",
   CurrentValue = false,
   Callback = function(State)
        Settings.AutoClickActive = State
        
        if State then
            -- Start auto clicking
            clickConnection = RunService.Heartbeat:Connect(function()
                if Settings.AutoClickActive then
                    ExecuteClick()
                end
            end)
            
            -- Ensure mobile controls stay
            PreserveMobileControls()
            
            Notify("Auto Click", "ENABLED - " .. Settings.ClickSpeed .. " CPS")
        else
            -- Stop auto clicking
            if clickConnection then
                clickConnection:Disconnect()
                clickConnection = nil
            end
            
            Notify("Auto Click", "DISABLED")
        end
   end,
})

MainTab:CreateSection("📱 Mobile Controls Status")

if isMobile then
    MainTab:CreateLabel("Device: 📱 Mobile/Tablet")
    MainTab:CreateLabel("Joystick: ✓ Protected & Visible")
    MainTab:CreateLabel("Jump Button: ✓ Protected & Visible")
    MainTab:CreateLabel("Movement: ✓ Fully Functional")
    
    MainTab:CreateButton({
       Name = "Force Restore Controls",
       Callback = function()
            PreserveMobileControls()
            Notify("Controls", "Mobile controls restored!")
       end,
    })
else
    MainTab:CreateLabel("Device: 💻 PC/Desktop")
    MainTab:CreateLabel("Keyboard: ✓ WASD Movement")
    MainTab:CreateLabel("Mouse: ✓ Camera Control")
end

MainTab:CreateSection("🛑 Emergency Stop")

MainTab:CreateButton({
   Name = "STOP All Auto Click",
   Callback = function()
        Settings.AutoClickActive = false
        
        if clickConnection then
            clickConnection:Disconnect()
            clickConnection = nil
        end
        
        PreserveMobileControls()
        
        Notify("STOPPED", "Auto click disabled & controls restored")
   end,
})

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

SettingsTab:CreateSection("🎮 Control Protection")

if isMobile then
    SettingsTab:CreateParagraph({
        Title = "Mobile Control Protection",
        Content = "This script protects your mobile controls:\n\n✓ Joystick stays visible\n✓ Jump button stays visible\n✓ All touch controls work\n✓ Movement is preserved\n\nIf controls disappear, use 'Force Restore Controls' button!"
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
    Title = "Universal Auto Click v5.0",
    Content = "A universal auto-clicker designed to work on ALL devices while preserving native Roblox controls. Mobile joysticks and buttons are protected and will not disappear."
})

InfoTab:CreateSection("✨ Features")

InfoTab:CreateLabel("✓ Universal: Works on ALL games")
InfoTab:CreateLabel("✓ Mobile: Joystick protected")
InfoTab:CreateLabel("✓ PC: Full keyboard/mouse support")
InfoTab:CreateLabel("✓ Safe: Doesn't block game controls")
InfoTab:CreateLabel("✓ Adjustable: 1-50 CPS")
InfoTab:CreateLabel("✓ Smart: Auto-detects device type")

InfoTab:CreateSection("📱 Mobile Users - READ THIS")

InfoTab:CreateParagraph({
    Title = "How to Use on Mobile",
    Content = "1. Set your Click Speed (CPS)\n2. Toggle 'Enable Auto Click' ON\n3. Your JOYSTICK and BUTTONS stay visible!\n4. Move with joystick as normal\n5. Auto-clicking happens automatically\n\nIMPORTANT: If controls disappear, press 'Force Restore Controls' button!"
})

InfoTab:CreateSection("💻 PC Users - READ THIS")

InfoTab:CreateParagraph({
    Title = "How to Use on PC",
    Content = "1. Set your Click Speed (CPS)\n2. Toggle 'Enable Auto Click' ON\n3. Move with WASD as normal\n4. Use mouse for camera\n5. Auto-clicking happens automatically\n\nAll keyboard and mouse controls work normally!"
})

InfoTab:CreateSection("⚠️ Troubleshooting")

InfoTab:CreateParagraph({
    Title = "If Something Goes Wrong",
    Content = "Mobile Controls Disappeared?\n→ Press 'Force Restore Controls'\n\nCan't Move?\n→ Press 'STOP All Auto Click'\n→ Then re-enable auto click\n\nNot Clicking?\n→ Check if CPS is set correctly\n→ Make sure toggle is ON\n\nStill Issues?\n→ Rejoin the game"
})

InfoTab:CreateSection("🎯 Compatibility")

InfoTab:CreateLabel("Touch Devices: " .. (UserInputService.TouchEnabled and "✓ YES" or "✗ NO"))
InfoTab:CreateLabel("Mouse Support: " .. (UserInputService.MouseEnabled and "✓ YES" or "✗ NO"))
InfoTab:CreateLabel("Keyboard Support: " .. (UserInputService.KeyboardEnabled and "✓ YES" or "✗ NO"))
InfoTab:CreateLabel("Gamepad Support: " .. (UserInputService.GamepadEnabled and "✓ YES" or "✗ NO"))

-- Initial setup
task.wait(1)

-- Ensure controls are visible on startup
PreserveMobileControls()

-- Send welcome message
if isMobile then
    Notify("📱 Mobile Device", "Controls protected & ready!")
else
    Notify("💻 PC Device", "Ready to use!")
end

Notify("✓ Loaded", "Set CPS and enable auto click!")

-- Console output
print("=" .. string.rep("=", 50))
print("UNIVERSAL AUTO CLICK V5.0")
print("=" .. string.rep("=", 50))
print("Status: LOADED ✓")
print("Player: " .. Player.Name)
print("Device: " .. (isMobile and "Mobile (Touch)" or "PC (Keyboard/Mouse)"))
print("Controls: " .. (isMobile and "Joystick PROTECTED" or "WASD/Mouse ACTIVE"))
print("=" .. string.rep("=", 50))
print("")
if isMobile then
    print("MOBILE USERS:")
    print("• Your joystick WILL stay visible")
    print("• Jump button WILL stay visible")
    print("• All controls protected by script")
    print("• Use 'Force Restore' if needed")
else
    print("PC USERS:")
    print("• WASD movement works")
    print("• Mouse controls work")
    print("• All inputs preserved")
end
print("=" .. string.rep("=", 50))
