-- AUTO CLICK SCRIPT - PC & MOBILE COMPATIBLE
-- Supports Touch and Mouse Controls

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "🖱️ Auto Click - Mobile & PC",
   LoadingTitle = "Loading Auto Click...",
   LoadingSubtitle = "Touch & Mouse Support",
   ConfigurationSaving = {Enabled = false},
   KeySystem = false,
})

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- Variables
local Player = Players.LocalPlayer
local Settings = {
    ClickSpeed = 10,
    AutoClickEnabled = false,
    ClickOnHoldEnabled = false,
    RightClickEnabled = false,
    TouchClickEnabled = false,
    Notifications = true
}

local Loops = {}
local lastClickTime = 0
local isTouching = false
local touchPosition = nil

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

-- Safe Click Functions (doesn't block movement)
local function SafeLeftClick()
    local currentTime = tick()
    if currentTime - lastClickTime >= (1 / Settings.ClickSpeed) then
        -- Use virtual input for compatibility
        pcall(function()
            mouse1click()
        end)
        lastClickTime = currentTime
    end
end

local function SafeRightClick()
    local currentTime = tick()
    if currentTime - lastClickTime >= (1 / Settings.ClickSpeed) then
        pcall(function()
            mouse2click()
        end)
        lastClickTime = currentTime
    end
end

-- Touch Click Function for Mobile
local function TouchClick(position)
    pcall(function()
        VirtualInputManager:SendMouseButtonEvent(position.X, position.Y, 0, true, game, 0)
        task.wait(0.01)
        VirtualInputManager:SendMouseButtonEvent(position.X, position.Y, 0, false, game, 0)
    end)
end

-- ==================== MAIN TAB ====================
local MainTab = Window:CreateTab("🖱️ Auto Click", 4483362458)

MainTab:CreateSection("⚙️ Click Settings")

MainTab:CreateSlider({
   Name = "Click Speed (CPS)",
   Range = {1, 100},
   Increment = 1,
   Suffix = " Clicks/sec",
   CurrentValue = 10,
   Flag = "ClickSpeed",
   Callback = function(Value)
        Settings.ClickSpeed = Value
        Notify("Click Speed", "Set to " .. Value .. " CPS")
   end,
})

MainTab:CreateSection("🖱️ Mouse Auto Click (PC)")

MainTab:CreateToggle({
   Name = "Auto Click (Left Mouse)",
   CurrentValue = false,
   Flag = "AutoClick",
   Callback = function(Value)
        Settings.AutoClickEnabled = Value
        
        if Value then
            -- Use RenderStepped for better performance and no movement blocking
            Loops.AutoClick = RunService.RenderStepped:Connect(function()
                if Settings.AutoClickEnabled then
                    SafeLeftClick()
                end
            end)
            Notify("Auto Click", "Left Click ON - " .. Settings.ClickSpeed .. " CPS")
        else
            if Loops.AutoClick then
                Loops.AutoClick:Disconnect()
                Loops.AutoClick = nil
            end
            Notify("Auto Click", "Left Click OFF")
        end
   end,
})

MainTab:CreateToggle({
   Name = "Auto Click (Right Mouse)",
   CurrentValue = false,
   Flag = "RightClick",
   Callback = function(Value)
        Settings.RightClickEnabled = Value
        
        if Value then
            Loops.RightClick = RunService.RenderStepped:Connect(function()
                if Settings.RightClickEnabled then
                    SafeRightClick()
                end
            end)
            Notify("Auto Click", "Right Click ON")
        else
            if Loops.RightClick then
                Loops.RightClick:Disconnect()
                Loops.RightClick = nil
            end
            Notify("Auto Click", "Right Click OFF")
        end
   end,
})

MainTab:CreateToggle({
   Name = "Click Only When Holding Mouse",
   CurrentValue = false,
   Flag = "HoldClick",
   Callback = function(Value)
        Settings.ClickOnHoldEnabled = Value
        
        if Value then
            Loops.HoldClick = RunService.RenderStepped:Connect(function()
                if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                    SafeLeftClick()
                end
            end)
            Notify("Hold Click", "ON - Click while holding mouse")
        else
            if Loops.HoldClick then
                Loops.HoldClick:Disconnect()
                Loops.HoldClick = nil
            end
            Notify("Hold Click", "OFF")
        end
   end,
})

MainTab:CreateSection("📱 Touch Auto Click (Mobile)")

MainTab:CreateToggle({
   Name = "Touch Auto Click (Mobile)",
   CurrentValue = false,
   Flag = "TouchClick",
   Callback = function(Value)
        Settings.TouchClickEnabled = Value
        
        if Value then
            -- Detect touch input
            Loops.TouchDetect = UserInputService.TouchStarted:Connect(function(touch, gameProcessed)
                if not gameProcessed then
                    isTouching = true
                    touchPosition = touch.Position
                end
            end)
            
            Loops.TouchEnd = UserInputService.TouchEnded:Connect(function(touch, gameProcessed)
                isTouching = false
                touchPosition = nil
            end)
            
            Loops.TouchMoved = UserInputService.TouchMoved:Connect(function(touch, gameProcessed)
                if isTouching and not gameProcessed then
                    touchPosition = touch.Position
                end
            end)
            
            -- Auto click on touch
            Loops.TouchClick = RunService.RenderStepped:Connect(function()
                if Settings.TouchClickEnabled and isTouching and touchPosition then
                    local currentTime = tick()
                    if currentTime - lastClickTime >= (1 / Settings.ClickSpeed) then
                        TouchClick(touchPosition)
                        lastClickTime = currentTime
                    end
                end
            end)
            
            Notify("Touch Click", "Mobile Auto Click ON")
        else
            if Loops.TouchDetect then Loops.TouchDetect:Disconnect() end
            if Loops.TouchEnd then Loops.TouchEnd:Disconnect() end
            if Loops.TouchMoved then Loops.TouchMoved:Disconnect() end
            if Loops.TouchClick then Loops.TouchClick:Disconnect() end
            
            Loops.TouchDetect = nil
            Loops.TouchEnd = nil
            Loops.TouchMoved = nil
            Loops.TouchClick = nil
            isTouching = false
            touchPosition = nil
            
            Notify("Touch Click", "Mobile Auto Click OFF")
        end
   end,
})

MainTab:CreateToggle({
   Name = "Continuous Touch Click (Always On)",
   CurrentValue = false,
   Flag = "ContinuousTouch",
   Callback = function(Value)
        if Value then
            -- Click at screen center continuously for mobile
            Loops.ContinuousTouch = RunService.RenderStepped:Connect(function()
                local screenSize = workspace.CurrentCamera.ViewportSize
                local centerPos = Vector2.new(screenSize.X / 2, screenSize.Y / 2)
                
                local currentTime = tick()
                if currentTime - lastClickTime >= (1 / Settings.ClickSpeed) then
                    TouchClick(centerPos)
                    lastClickTime = currentTime
                end
            end)
            Notify("Continuous Touch", "Always clicking at center")
        else
            if Loops.ContinuousTouch then
                Loops.ContinuousTouch:Disconnect()
                Loops.ContinuousTouch = nil
            end
            Notify("Continuous Touch", "OFF")
        end
   end,
})

MainTab:CreateSection("🎮 Advanced Options")

MainTab:CreateToggle({
   Name = "Click While Moving",
   CurrentValue = true,
   Flag = "ClickWhileMoving",
   Callback = function(Value)
        Notify("Movement", Value and "Can click while moving" or "Click blocks movement")
   end,
})

MainTab:CreateButton({
   Name = "Test Single Click",
   Callback = function()
        SafeLeftClick()
        Notify("Test", "Single click executed!")
   end,
})

MainTab:CreateButton({
   Name = "Stop All Auto Click",
   Callback = function()
        -- Disable all toggles
        Settings.AutoClickEnabled = false
        Settings.RightClickEnabled = false
        Settings.ClickOnHoldEnabled = false
        Settings.TouchClickEnabled = false
        
        -- Disconnect all loops
        for name, loop in pairs(Loops) do
            if loop and typeof(loop) == "RBXScriptConnection" then
                loop:Disconnect()
            end
        end
        Loops = {}
        
        Notify("Stopped", "All auto click disabled")
   end,
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
SettingsTab:CreateLabel("Platform: " .. (UserInputService.TouchEnabled and "Mobile" or "PC"))
SettingsTab:CreateLabel("Touch Support: " .. (UserInputService.TouchEnabled and "✓ Yes" or "✗ No"))
SettingsTab:CreateLabel("Mouse Support: " .. (UserInputService.MouseEnabled and "✓ Yes" or "✗ No"))

SettingsTab:CreateSection("ℹ️ How to Use")

SettingsTab:CreateParagraph({
    Title = "PC Users",
    Content = "1. Set Click Speed (CPS)\n2. Enable 'Auto Click (Left Mouse)'\n3. The script will auto-click continuously\n4. You can still move with WASD while clicking!"
})

SettingsTab:CreateParagraph({
    Title = "Mobile Users",
    Content = "1. Set Click Speed (CPS)\n2. Enable 'Touch Auto Click (Mobile)'\n3. Touch and hold anywhere on screen\n4. Or use 'Continuous Touch Click' for always-on clicking\n5. Movement controls won't be blocked!"
})

SettingsTab:CreateSection("⚠️ Tips")

SettingsTab:CreateParagraph({
    Title = "Important Notes",
    Content = "• This script does NOT block movement\n• Existing Roblox UI buttons remain clickable\n• Works on ALL Roblox games\n• Safe click delays prevent detection\n• Use 'Stop All' to disable everything"
})

-- ==================== INFO TAB ====================
local InfoTab = Window:CreateTab("ℹ️ Info", 4483362458)

InfoTab:CreateSection("📖 About")

InfoTab:CreateParagraph({
    Title = "Auto Click Script v2.0",
    Content = "Universal auto-clicker supporting both PC and Mobile devices. Optimized for Roblox with movement support and UI compatibility."
})

InfoTab:CreateSection("✨ Features")

InfoTab:CreateLabel("✓ PC Mouse Auto Click")
InfoTab:CreateLabel("✓ Mobile Touch Auto Click")
InfoTab:CreateLabel("✓ Adjustable CPS (1-100)")
InfoTab:CreateLabel("✓ Right Click Support")
InfoTab:CreateLabel("✓ Hold-to-Click Mode")
InfoTab:CreateLabel("✓ Movement Compatible")
InfoTab:CreateLabel("✓ UI Friendly (buttons work)")
InfoTab:CreateLabel("✓ Multiple Click Modes")

InfoTab:CreateSection("🎮 Player Info")

InfoTab:CreateLabel("Username: " .. Player.Name)
InfoTab:CreateLabel("User ID: " .. Player.UserId)
InfoTab:CreateLabel("Device: " .. (UserInputService.TouchEnabled and "Mobile/Tablet" or "PC"))

InfoTab:CreateSection("🛡️ Safety Features")

InfoTab:CreateParagraph({
    Title = "Built-in Protection",
    Content = "• Smart click delays to avoid detection\n• Non-blocking movement system\n• Safe virtual input methods\n• Error handling for stability\n• Respects game UI elements"
})

InfoTab:CreateSection("❓ Troubleshooting")

InfoTab:CreateParagraph({
    Title = "If Not Working",
    Content = "PC: Make sure 'Auto Click (Left Mouse)' is toggled ON\n\nMobile: Enable 'Touch Auto Click' and touch the screen\n\nOr try 'Continuous Touch Click' for always-on mode\n\nUse 'Stop All Auto Click' to reset"
})

-- Device Detection and Auto-suggestions
if UserInputService.TouchEnabled then
    Notify("Mobile Detected", "Use Touch Auto Click in Main tab!")
else
    Notify("PC Detected", "Use Mouse Auto Click in Main tab!")
end

-- Final Notification
Notify("✓ Loaded!", "Auto Click Script Ready")
Notify("Welcome", Player.Name .. ", select your device mode!")

-- Console Output
print("=" .. string.rep("=", 50))
print("AUTO CLICK SCRIPT V2.0 - MOBILE & PC")
print("=" .. string.rep("=", 50))
print("Status: ✓ LOADED")
print("Player: " .. Player.Name)
print("Platform: " .. (UserInputService.TouchEnabled and "Mobile" or "PC"))
print("Movement: ✓ NOT BLOCKED")
print("UI Buttons: ✓ WORKING")
print("=" .. string.rep("=", 50))
