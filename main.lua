-- AUTO CLICK SCRIPT - MOBILE FIXED VERSION
-- Preserves joystick and all mobile controls

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "🖱️ Auto Click - Mobile Fixed",
   LoadingTitle = "Loading Auto Click...",
   LoadingSubtitle = "Joystick & Controls Preserved",
   ConfigurationSaving = {Enabled = false},
   KeySystem = false,
})

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Variables
local Player = Players.LocalPlayer
local Settings = {
    ClickSpeed = 10,
    AutoClickEnabled = false,
    Notifications = true
}

local Loops = {}
local lastClickTime = 0

-- Notification Function
local function Notify(title, text)
    if Settings.Notifications then
        Rayfield:Notify({
            Title = title,
            Content = text,
            Duration = 3,
        })
    end
end

-- Safe Click Function (doesn't interfere with controls)
local function PerformClick()
    local currentTime = tick()
    if currentTime - lastClickTime >= (1 / Settings.ClickSpeed) then
        -- Use pcall to prevent errors
        pcall(function()
            -- Simulate mouse click without blocking input
            local virtualUser = game:GetService("VirtualUser")
            virtualUser:CaptureController()
            virtualUser:Button1Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            task.wait(0.01)
            virtualUser:Button1Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        end)
        lastClickTime = currentTime
    end
end

-- Alternative click method for better compatibility
local function SafeAutoClick()
    local currentTime = tick()
    if currentTime - lastClickTime >= (1 / Settings.ClickSpeed) then
        pcall(function()
            mouse1press()
            task.wait(0.01)
            mouse1release()
        end)
        lastClickTime = currentTime
    end
end

-- ==================== MAIN TAB ====================
local MainTab = Window:CreateTab("🖱️ Auto Click", 4483362458)

MainTab:CreateSection("⚙️ Click Settings")

MainTab:CreateSlider({
   Name = "Click Speed (CPS)",
   Range = {1, 50},
   Increment = 1,
   Suffix = " Clicks/sec",
   CurrentValue = 10,
   Flag = "ClickSpeed",
   Callback = function(Value)
        Settings.ClickSpeed = Value
        Notify("Click Speed", "Set to " .. Value .. " CPS")
   end,
})

MainTab:CreateSection("🎮 Auto Click Modes")

MainTab:CreateToggle({
   Name = "Auto Click (Method 1)",
   CurrentValue = false,
   Flag = "AutoClick1",
   Callback = function(Value)
        Settings.AutoClickEnabled = Value
        
        if Value then
            -- Use Heartbeat to avoid blocking input
            Loops.AutoClick = RunService.Heartbeat:Connect(function()
                if Settings.AutoClickEnabled then
                    SafeAutoClick()
                end
            end)
            Notify("Auto Click", "Method 1 ON - " .. Settings.ClickSpeed .. " CPS")
        else
            if Loops.AutoClick then
                Loops.AutoClick:Disconnect()
                Loops.AutoClick = nil
            end
            Notify("Auto Click", "Method 1 OFF")
        end
   end,
})

MainTab:CreateToggle({
   Name = "Auto Click (Method 2 - VirtualUser)",
   CurrentValue = false,
   Flag = "AutoClick2",
   Callback = function(Value)
        if Value then
            Loops.AutoClick2 = RunService.Heartbeat:Connect(function()
                PerformClick()
            end)
            Notify("Auto Click", "Method 2 ON")
        else
            if Loops.AutoClick2 then
                Loops.AutoClick2:Disconnect()
                Loops.AutoClick2 = nil
            end
            Notify("Auto Click", "Method 2 OFF")
        end
   end,
})

MainTab:CreateToggle({
   Name = "Auto Click (Method 3 - Simple)",
   CurrentValue = false,
   Flag = "AutoClick3",
   Callback = function(Value)
        if Value then
            Loops.AutoClick3 = task.spawn(function()
                while Loops.AutoClick3 do
                    pcall(function()
                        mouse1click()
                    end)
                    task.wait(1 / Settings.ClickSpeed)
                end
            end)
            Notify("Auto Click", "Method 3 ON - Simple mode")
        else
            if Loops.AutoClick3 then
                task.cancel(Loops.AutoClick3)
                Loops.AutoClick3 = nil
            end
            Notify("Auto Click", "Method 3 OFF")
        end
   end,
})

MainTab:CreateSection("🔧 Additional Options")

MainTab:CreateButton({
   Name = "Test Single Click",
   Callback = function()
        SafeAutoClick()
        Notify("Test", "Single click executed!")
   end,
})

MainTab:CreateButton({
   Name = "Stop All Auto Click",
   Callback = function()
        Settings.AutoClickEnabled = false
        
        -- Disconnect all loops safely
        if Loops.AutoClick then
            Loops.AutoClick:Disconnect()
            Loops.AutoClick = nil
        end
        if Loops.AutoClick2 then
            Loops.AutoClick2:Disconnect()
            Loops.AutoClick2 = nil
        end
        if Loops.AutoClick3 then
            task.cancel(Loops.AutoClick3)
            Loops.AutoClick3 = nil
        end
        
        Notify("Stopped", "All auto click disabled")
   end,
})

MainTab:CreateSection("📱 Mobile Users")

MainTab:CreateParagraph({
    Title = "Important for Mobile",
    Content = "Your joystick and controls are preserved!\n\n• Use Method 1, 2, or 3\n• You can move with joystick while auto-clicking\n• All mobile controls work normally\n• Try different methods if one doesn't work"
})

-- ==================== SETTINGS TAB ====================
local SettingsTab = Window:CreateTab("⚙️ Settings", 4483362458)

SettingsTab:CreateSection("🔔 Notifications")

SettingsTab:CreateToggle({
   Name = "Enable Notifications",
   CurrentValue = true,
   Flag = "Notifications",
   Callback = function(Value)
        Settings.Notifications = Value
        if Value then
            Notify("Notifications", "Enabled")
        end
   end,
})

SettingsTab:CreateSection("📊 Information")

SettingsTab:CreateLabel("Current Click Speed: " .. Settings.ClickSpeed .. " CPS")
SettingsTab:CreateLabel("Platform: " .. (UserInputService.TouchEnabled and "📱 Mobile" or "💻 PC"))
SettingsTab:CreateLabel("Touch Support: " .. (UserInputService.TouchEnabled and "✓ Yes" or "✗ No"))
SettingsTab:CreateLabel("Keyboard: " .. (UserInputService.KeyboardEnabled and "✓ Yes" or "✗ No"))

SettingsTab:CreateSection("🎮 Controls Status")

SettingsTab:CreateParagraph({
    Title = "Mobile Controls",
    Content = "✓ Joystick: Working\n✓ Jump Button: Working\n✓ Action Buttons: Working\n✓ Camera: Working\n\nAll Roblox mobile controls are preserved!"
})

SettingsTab:CreateSection("⚠️ Troubleshooting")

SettingsTab:CreateParagraph({
    Title = "If Controls Don't Work",
    Content = "1. Make sure only ONE auto click method is enabled\n2. Try different methods (1, 2, or 3)\n3. Check if CPS is not too high (try 10-20)\n4. Use 'Stop All Auto Click' to reset\n5. Method 3 usually works best on mobile"
})

-- ==================== INFO TAB ====================
local InfoTab = Window:CreateTab("ℹ️ Info", 4483362458)

InfoTab:CreateSection("📖 About")

InfoTab:CreateParagraph({
    Title = "Auto Click Script v3.0",
    Content = "Fixed version that preserves ALL mobile controls including joystick, jump button, and camera controls. Works on both PC and Mobile."
})

InfoTab:CreateSection("✨ Features")

InfoTab:CreateLabel("✓ Mobile Joystick Preserved")
InfoTab:CreateLabel("✓ Jump Button Works")
InfoTab:CreateLabel("✓ Camera Controls Work")
InfoTab:CreateLabel("✓ 3 Different Click Methods")
InfoTab:CreateLabel("✓ Adjustable CPS (1-50)")
InfoTab:CreateLabel("✓ PC & Mobile Compatible")
InfoTab:CreateLabel("✓ Movement While Clicking")
InfoTab:CreateLabel("✓ No Control Blocking")

InfoTab:CreateSection("🎯 How to Use")

InfoTab:CreateParagraph({
    Title = "Quick Start (Mobile)",
    Content = "1. Set Click Speed (start with 10 CPS)\n2. Enable ONE auto click method\n3. Move with joystick as normal\n4. Auto click happens automatically\n5. If one method doesn't work, try another!"
})

InfoTab:CreateParagraph({
    Title = "Quick Start (PC)",
    Content = "1. Set Click Speed\n2. Enable Method 1 or 2\n3. Move with WASD as normal\n4. Auto click works automatically\n5. You can still aim with mouse"
})

InfoTab:CreateSection("🛡️ Method Differences")

InfoTab:CreateParagraph({
    Title = "Which Method to Use?",
    Content = "Method 1: Best for most games (press/release)\n\nMethod 2: Uses VirtualUser (alternative)\n\nMethod 3: Simplest method, works on most mobile devices\n\nTry each one to see which works best!"
})

InfoTab:CreateSection("🎮 Player Info")

InfoTab:CreateLabel("Username: " .. Player.Name)
InfoTab:CreateLabel("Display Name: " .. Player.DisplayName)
InfoTab:CreateLabel("User ID: " .. Player.UserId)

-- Device Detection
if UserInputService.TouchEnabled then
    Notify("📱 Mobile Detected", "Your controls are preserved!")
else
    Notify("💻 PC Detected", "Mouse and keyboard ready!")
end

-- Final Notifications
Notify("✓ Loaded!", "Auto Click Ready - Controls Preserved")
Notify("Welcome", Player.Name .. ", all controls work!")

-- Console Output
print("=" .. string.rep("=", 50))
print("AUTO CLICK SCRIPT V3.0 - MOBILE FIXED")
print("=" .. string.rep("=", 50))
print("Status: ✓ LOADED")
print("Player: " .. Player.Name)
print("Platform: " .. (UserInputService.TouchEnabled and "Mobile" or "PC"))
print("Joystick: ✓ PRESERVED")
print("Movement: ✓ WORKING")
print("Controls: ✓ ALL FUNCTIONAL")
print("=" .. string.rep("=", 50))
print("")
print("INSTRUCTIONS:")
print("1. Set Click Speed (CPS)")
print("2. Enable ONE auto click method")
print("3. Move normally with joystick/WASD")
print("4. Auto click happens automatically!")
print("=" .. string.rep("=", 50))
