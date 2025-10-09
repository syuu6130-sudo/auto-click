-- AUTO CLICK SCRIPT - COMPLETE MOBILE & PC FIX
-- Preserves all controls including joystick

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "🖱️ Auto Click Universal",
   LoadingTitle = "Loading...",
   LoadingSubtitle = "Mobile & PC Compatible",
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
local Mouse = Player:GetMouse()
local Camera = workspace.CurrentCamera

local Settings = {
    ClickSpeed = 10,
    AutoClickEnabled = false,
    RightClickEnabled = false,
    Notifications = true
}

local lastClickTime = 0
local clickLoop = nil

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

-- Click function that DOESN'T block controls
local function DoAutoClick()
    local currentTime = tick()
    local delay = 1 / Settings.ClickSpeed
    
    if currentTime - lastClickTime >= delay then
        -- Method that works on both PC and Mobile without blocking controls
        spawn(function()
            pcall(function()
                -- Get current mouse/touch position
                local mousePos = UserInputService:GetMouseLocation()
                
                -- Send click at current position without interfering with controls
                VirtualInputManager:SendMouseButtonEvent(mousePos.X, mousePos.Y, 0, true, game, 0)
                task.wait(0.01)
                VirtualInputManager:SendMouseButtonEvent(mousePos.X, mousePos.Y, 0, false, game, 0)
            end)
        end)
        
        lastClickTime = currentTime
    end
end

local function DoRightClick()
    local currentTime = tick()
    local delay = 1 / Settings.ClickSpeed
    
    if currentTime - lastClickTime >= delay then
        spawn(function()
            pcall(function()
                local mousePos = UserInputService:GetMouseLocation()
                VirtualInputManager:SendMouseButtonEvent(mousePos.X, mousePos.Y, 1, true, game, 0)
                task.wait(0.01)
                VirtualInputManager:SendMouseButtonEvent(mousePos.X, mousePos.Y, 1, false, game, 0)
            end)
        end)
        
        lastClickTime = currentTime
    end
end

-- ==================== MAIN TAB ====================
local MainTab = Window:CreateTab("🖱️ Auto Click", 4483362458)

MainTab:CreateSection("⚙️ Settings")

MainTab:CreateSlider({
   Name = "Click Speed (CPS)",
   Range = {1, 50},
   Increment = 1,
   Suffix = " CPS",
   CurrentValue = 10,
   Callback = function(Value)
        Settings.ClickSpeed = Value
        Notify("Speed Updated", Value .. " clicks per second")
   end,
})

MainTab:CreateSection("🖱️ Click Controls")

MainTab:CreateToggle({
   Name = "Enable Auto Click",
   CurrentValue = false,
   Callback = function(Value)
        Settings.AutoClickEnabled = Value
        
        if Value then
            -- Use Heartbeat for smooth operation
            clickLoop = RunService.Heartbeat:Connect(function()
                if Settings.AutoClickEnabled then
                    DoAutoClick()
                end
            end)
            Notify("Auto Click", "ENABLED - " .. Settings.ClickSpeed .. " CPS")
        else
            if clickLoop then
                clickLoop:Disconnect()
                clickLoop = nil
            end
            Notify("Auto Click", "DISABLED")
        end
   end,
})

MainTab:CreateToggle({
   Name = "Enable Right Click",
   CurrentValue = false,
   Callback = function(Value)
        Settings.RightClickEnabled = Value
        
        if Value then
            spawn(function()
                while Settings.RightClickEnabled do
                    DoRightClick()
                    task.wait(1 / Settings.ClickSpeed)
                end
            end)
            Notify("Right Click", "ENABLED")
        else
            Notify("Right Click", "DISABLED")
        end
   end,
})

MainTab:CreateSection("🎮 Control Info")

MainTab:CreateLabel("Device: " .. (UserInputService.TouchEnabled and "📱 Mobile" or "💻 PC"))
MainTab:CreateLabel("Movement Controls: ✓ Working")
MainTab:CreateLabel("Camera Controls: ✓ Working")
if UserInputService.TouchEnabled then
    MainTab:CreateLabel("Joystick: ✓ Visible & Working")
end

MainTab:CreateButton({
   Name = "Stop All Clicking",
   Callback = function()
        Settings.AutoClickEnabled = false
        Settings.RightClickEnabled = false
        
        if clickLoop then
            clickLoop:Disconnect()
            clickLoop = nil
        end
        
        Notify("Stopped", "All auto clicking stopped")
   end,
})

-- ==================== SETTINGS TAB ====================
local SettingsTab = Window:CreateTab("⚙️ Settings", 4483362458)

SettingsTab:CreateSection("🔔 Notifications")

SettingsTab:CreateToggle({
   Name = "Show Notifications",
   CurrentValue = true,
   Callback = function(Value)
        Settings.Notifications = Value
        if Value then
            Notify("Notifications", "Enabled")
        end
   end,
})

SettingsTab:CreateSection("📊 Status")

SettingsTab:CreateLabel("Username: " .. Player.Name)
SettingsTab:CreateLabel("User ID: " .. Player.UserId)
SettingsTab:CreateLabel("Platform: " .. (UserInputService.TouchEnabled and "Mobile" or "PC"))

SettingsTab:CreateSection("ℹ️ Instructions")

SettingsTab:CreateParagraph({
    Title = "How to Use",
    Content = "1. Set your desired Click Speed (CPS)\n2. Toggle 'Enable Auto Click' ON\n3. Move normally with joystick/WASD\n4. Auto clicking happens automatically\n\nYour controls are NOT blocked!"
})

-- ==================== INFO TAB ====================
local InfoTab = Window:CreateTab("ℹ️ Info", 4483362458)

InfoTab:CreateSection("📖 About This Script")

InfoTab:CreateParagraph({
    Title = "Auto Click Universal v4.0",
    Content = "A simple auto-clicker that works on both PC and Mobile devices while preserving all game controls including joystick, movement, and camera."
})

InfoTab:CreateSection("✨ Features")

InfoTab:CreateLabel("✓ Works on PC and Mobile")
InfoTab:CreateLabel("✓ Joystick remains visible")
InfoTab:CreateLabel("✓ All controls functional")
InfoTab:CreateLabel("✓ Adjustable click speed")
InfoTab:CreateLabel("✓ Left and right click support")
InfoTab:CreateLabel("✓ Movement while clicking")

InfoTab:CreateSection("🎯 Compatibility")

InfoTab:CreateLabel("Touch Screen: " .. (UserInputService.TouchEnabled and "✓ Supported" or "✗ Not Available"))
InfoTab:CreateLabel("Mouse: " .. (UserInputService.MouseEnabled and "✓ Supported" or "✗ Not Available"))
InfoTab:CreateLabel("Keyboard: " .. (UserInputService.KeyboardEnabled and "✓ Supported" or "✗ Not Available"))
InfoTab:CreateLabel("Gamepad: " .. (UserInputService.GamepadEnabled and "✓ Supported" or "✗ Not Available"))

InfoTab:CreateSection("⚠️ Important Notes")

InfoTab:CreateParagraph({
    Title = "Mobile Users",
    Content = "• Your joystick WILL remain visible\n• You CAN move while auto-clicking\n• All buttons continue to work\n• Camera controls are preserved\n• Just enable auto click and play normally!"
})

InfoTab:CreateParagraph({
    Title = "PC Users",
    Content = "• WASD movement works normally\n• Mouse camera control preserved\n• Can jump and use abilities\n• Auto click runs in background\n• No input blocking"
})

-- Device check and notification
task.wait(1)

if UserInputService.TouchEnabled then
    Notify("📱 Mobile Device", "Joystick preserved! Controls work!")
else
    Notify("💻 PC Device", "Keyboard & Mouse ready!")
end

Notify("✓ Ready!", "Set CPS and enable auto click")

-- Console info
print("========================================")
print("AUTO CLICK UNIVERSAL V4.0")
print("========================================")
print("Player: " .. Player.Name)
print("Device: " .. (UserInputService.TouchEnabled and "Mobile" or "PC"))
print("Status: Ready")
print("Controls: All Preserved")
print("========================================")
print("")
print("USAGE:")
print("1. Main Tab -> Set Click Speed")
print("2. Toggle 'Enable Auto Click'")
print("3. Play normally - controls work!")
print("========================================")
