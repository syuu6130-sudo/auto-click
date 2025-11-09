-- FOLLOW & AIMBOT SCRIPT
-- Based on proven working code

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "🎯 Follow & Aimbot",
   LoadingTitle = "Loading Script...",
   LoadingSubtitle = "Follow & Aimbot Ready",
   ConfigurationSaving = {Enabled = false},
   KeySystem = false,
})

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

-- Variables
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local Camera = Workspace.CurrentCamera

-- Check if mobile
local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled

-- Auto Click variables
local autoClickEnabled = false
local clickSpeed = 10
local clickConnection = nil
local lastClick = 0

-- Follow variables
local followEnabled = false
local targetPlayerName = ""
local targetPlayer = nil
local followDistance = 3
local followConnection = nil

-- Aimbot variables
local aimbotEnabled = false
local aimbotConnection = nil

-- Notification function
local function Notify(title, content)
    Rayfield:Notify({
        Title = title,
        Content = content,
        Duration = 3,
        Image = 4483362458,
    })
end

-- Auto Click Function
local function ExecuteClick()
    local now = tick()
    if now - lastClick < (1 / clickSpeed) then
        return
    end
    lastClick = now
    
    spawn(function()
        pcall(function()
            local tool = character and character:FindFirstChildOfClass("Tool")
            if tool and tool:FindFirstChild("Handle") then
                tool:Activate()
            else
                local VirtualInputManager = game:GetService("VirtualInputManager")
                local ViewportSize = Camera.ViewportSize
                
                -- ジャンプボタンの上（画面右下から少し上）
                local clickX = ViewportSize.X - 100  -- 右から100px
                local clickY = ViewportSize.Y - 200  -- 下から200px（ジャンプボタンの上）
                
                -- タッチイベントを送信
                VirtualInputManager:SendTouchEvent(0, clickX, clickY)  -- タッチ開始
                task.wait(0.01)
                VirtualInputManager:SendTouchEvent(1, clickX, clickY)  -- タッチ終了
            end
        end)
    end)
end

-- Get player list
local function getPlayerList()
    local players = Players:GetPlayers()
    local names = {}
    for _, plr in pairs(players) do
        if plr ~= player then
            table.insert(names, plr.Name)
        end
    end
    return names
end

-- Follow function (参考2のコードを使用)
local function startFollowing(targetName)
    -- 既存の接続を切断
    if followConnection then
        followConnection:Disconnect()
        followConnection = nil
    end
    
    -- プレイヤーを検索
    targetPlayer = Players:FindFirstChild(targetName)
    
    if not targetPlayer then
        Notify("⚠️ Error", "Player " .. targetName .. " not found")
        followEnabled = false
        return false
    end
    
    Notify("✓ Follow Started", "Following " .. targetName)
    
    -- 尾行ループ (参考2の実装)
    followConnection = RunService.Heartbeat:Connect(function()
        if not followEnabled then
            if followConnection then
                followConnection:Disconnect()
                followConnection = nil
            end
            return
        end
        
        -- ターゲットプレイヤーのキャラクターを取得
        if targetPlayer and targetPlayer.Character then
            local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            character = player.Character
            
            if targetHRP and character and character:FindFirstChild("HumanoidRootPart") then
                humanoidRootPart = character.HumanoidRootPart
                local targetPos = targetHRP.Position
                
                -- ターゲットの後ろに位置する
                local targetLook = targetHRP.CFrame.LookVector
                humanoidRootPart.CFrame = CFrame.new(targetPos - targetLook * followDistance, targetPos)
            end
        else
            -- ターゲットが存在しない場合
            followEnabled = false
            Notify("Follow Ended", targetName .. " left the game")
        end
    end)
    
    return true
end

-- Stop following
local function stopFollowing()
    followEnabled = false
    if followConnection then
        followConnection:Disconnect()
        followConnection = nil
    end
    Notify("Follow Stopped", "Follow disabled")
end

-- Aimbot function (参考1のコードを使用)
local function startAimbot()
    if aimbotConnection then
        aimbotConnection:Disconnect()
        aimbotConnection = nil
    end
    
    Notify("✓ Aimbot Started", "Locking onto nearest player")
    
    -- Aimbot ループ (参考1の実装)
    aimbotConnection = RunService.RenderStepped:Connect(function()
        if not aimbotEnabled then
            if aimbotConnection then
                aimbotConnection:Disconnect()
                aimbotConnection = nil
            end
            return
        end
        
        local nearest = nil
        local shortestDist = math.huge
        
        -- 最も近いプレイヤーを検索
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= player and plr.Character and plr.Character:FindFirstChild("Head") then
                local dist = (plr.Character.Head.Position - Camera.CFrame.Position).Magnitude
                if dist < shortestDist then
                    shortestDist = dist
                    nearest = plr
                end
            end
        end
        
        -- カメラを頭に向ける
        if nearest and nearest.Character and nearest.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, nearest.Character.Head.Position)
        end
    end)
end

-- Stop aimbot
local function stopAimbot()
    aimbotEnabled = false
    if aimbotConnection then
        aimbotConnection:Disconnect()
        aimbotConnection = nil
    end
    Notify("Aimbot Stopped", "Aimbot disabled")
end

-- Character update
player.CharacterAdded:Connect(function(char)
    character = char
    humanoidRootPart = char:WaitForChild("HumanoidRootPart")
end)

-- Player leaving handler
Players.PlayerRemoving:Connect(function(removedPlayer)
    if targetPlayer == removedPlayer and followEnabled then
        stopFollowing()
    end
end)

-- ==================== AUTO CLICK TAB ====================
local ClickTab = Window:CreateTab("🖱️ Auto Click", 4483362458)

ClickTab:CreateSection("⚙️ Click Configuration")

if isMobile then
    ClickTab:CreateLabel("📱 Mobile Mode: Clicking above jump button")
    ClickTab:CreateLabel("✓ You can walk while auto-clicking!")
else
    ClickTab:CreateLabel("💻 PC Mode: Clicking at screen center")
end

ClickTab:CreateSlider({
   Name = "Click Speed (CPS)",
   Range = {1, 50},
   Increment = 1,
   Suffix = " CPS",
   CurrentValue = 10,
   Callback = function(Value)
        clickSpeed = Value
        Notify("Click Speed", tostring(Value) .. " CPS")
   end,
})

ClickTab:CreateToggle({
   Name = "Enable Auto Click",
   CurrentValue = false,
   Callback = function(State)
        autoClickEnabled = State
        
        if State then
            clickConnection = RunService.Heartbeat:Connect(function()
                if autoClickEnabled then
                    ExecuteClick()
                end
            end)
            Notify("Auto Click", "ENABLED - " .. clickSpeed .. " CPS")
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
local FollowTab = Window:CreateTab("🚶 Follow", 4483362458)

FollowTab:CreateSection("👤 Target Selection")

local PlayerInput = FollowTab:CreateInput({
   Name = "Player Name",
   PlaceholderText = "Enter player name to follow",
   RemoveTextAfterFocusLost = false,
   Callback = function(text)
      targetPlayerName = text
   end,
})

FollowTab:CreateToggle({
   Name = "Enable Follow",
   CurrentValue = false,
   Flag = "FollowToggle",
   Callback = function(value)
      followEnabled = value
      if value then
         if targetPlayerName ~= "" then
            startFollowing(targetPlayerName)
         else
            Notify("⚠️ Error", "Please enter a player name")
            followEnabled = false
         end
      else
         stopFollowing()
      end
   end,
})

FollowTab:CreateSection("⚙️ Follow Settings")

FollowTab:CreateSlider({
   Name = "Follow Distance",
   Range = {1, 20},
   Increment = 0.5,
   Suffix = " studs",
   CurrentValue = 3,
   Flag = "FollowDistance",
   Callback = function(value)
      followDistance = value
   end,
})

FollowTab:CreateSection("📋 Player List")

local PlayerListLabel = FollowTab:CreateLabel("Click 'Refresh' to see players")

FollowTab:CreateButton({
   Name = "🔄 Refresh Player List",
   Callback = function()
      local players = getPlayerList()
      if #players > 0 then
         local listText = "Players in server:\n\n"
         for i, name in ipairs(players) do
            listText = listText .. "• " .. name .. "\n"
            if i >= 10 then
               listText = listText .. "...and " .. (#players - 10) .. " more"
               break
            end
         end
         PlayerListLabel:Set(listText)
         
         Notify("✓ Refreshed", #players .. " players found")
      else
         PlayerListLabel:Set("No other players found")
      end
   end,
})

-- Create quick select buttons
local QuickSection = FollowTab:CreateSection("⚡ Quick Select")

local function createPlayerButtons()
   local players = getPlayerList()
   for i = 1, math.min(5, #players) do
      FollowTab:CreateButton({
         Name = "📍 " .. players[i],
         Callback = function()
            targetPlayerName = players[i]
            PlayerInput:Set(players[i])
            Notify("Selected", players[i])
         end,
      })
   end
end

task.spawn(createPlayerButtons)

-- ==================== AIMBOT TAB ====================
local AimbotTab = Window:CreateTab("🎯 Aimbot", 4483362458)

AimbotTab:CreateSection("🎯 Aimbot Configuration")

AimbotTab:CreateParagraph({
    Title = "How Aimbot Works",
    Content = "Aimbot automatically locks your camera onto the nearest player's head. It continuously tracks the closest player in the game."
})

AimbotTab:CreateToggle({
   Name = "Enable Aimbot",
   CurrentValue = false,
   Flag = "AimbotToggle",
   Callback = function(value)
      aimbotEnabled = value
      if value then
         startAimbot()
      else
         stopAimbot()
      end
   end,
})

AimbotTab:CreateSection("⚠️ Warning")

AimbotTab:CreateLabel("⚠️ Aimbot may be detected by anti-cheat")
AimbotTab:CreateLabel("⚠️ Use at your own risk")
AimbotTab:CreateLabel("✓ Targets nearest player automatically")

-- ==================== SETTINGS TAB ====================
local SettingsTab = Window:CreateTab("⚙️ Settings", 4483362458)

SettingsTab:CreateSection("🛑 Emergency Controls")

SettingsTab:CreateButton({
   Name = "STOP ALL FEATURES",
   Callback = function()
      autoClickEnabled = false
      followEnabled = false
      aimbotEnabled = false
      
      if clickConnection then
         clickConnection:Disconnect()
         clickConnection = nil
      end
      if followConnection then
         followConnection:Disconnect()
         followConnection = nil
      end
      if aimbotConnection then
         aimbotConnection:Disconnect()
         aimbotConnection = nil
      end
      
      Notify("✓ Stopped", "All features disabled")
   end,
})

SettingsTab:CreateSection("📊 Current Status")

SettingsTab:CreateButton({
   Name = "Show Status",
   Callback = function()
      print("========== CURRENT STATUS ==========")
      print("Auto Click Enabled:", autoClickEnabled)
      print("Click Speed:", clickSpeed, "CPS")
      print("Target Player:", targetPlayerName ~= "" and targetPlayerName or "NONE")
      print("Follow Enabled:", followEnabled)
      print("Aimbot Enabled:", aimbotEnabled)
      print("Click Connection:", clickConnection and "Active" or "Inactive")
      print("Follow Connection:", followConnection and "Active" or "Inactive")
      print("Aimbot Connection:", aimbotConnection and "Active" or "Inactive")
      print("===================================")
      Notify("Status", "Check console (F9)")
   end,
})

SettingsTab:CreateSection("👤 Player Information")

SettingsTab:CreateLabel("Username: " .. player.Name)
SettingsTab:CreateLabel("Display Name: " .. player.DisplayName)
SettingsTab:CreateLabel("User ID: " .. tostring(player.UserId))
SettingsTab:CreateLabel("Device: " .. (isMobile and "📱 Mobile" or "💻 PC"))

-- ==================== INFO TAB ====================
local InfoTab = Window:CreateTab("ℹ️ Info", 4483362458)

InfoTab:CreateSection("📖 About")

InfoTab:CreateParagraph({
    Title = "Follow & Aimbot Script v1.0",
    Content = "A simple script with three powerful features: Auto Click, Follow players from behind, and lock your camera onto the nearest player's head."
})

InfoTab:CreateSection("✨ Features")

InfoTab:CreateLabel("✓ Auto Click: 1-50 CPS")
InfoTab:CreateLabel("✓ Follow: Track any player")
InfoTab:CreateLabel("✓ Aimbot: Auto-aim at nearest player")
InfoTab:CreateLabel("✓ Simple: Easy to use interface")
InfoTab:CreateLabel("✓ Safe: Emergency stop button")

InfoTab:CreateSection("📱 How to Use")

InfoTab:CreateParagraph({
    Title = "Auto Click",
    Content = "1. Go to Auto Click tab\n2. Adjust click speed (1-50 CPS)\n3. Toggle 'Enable Auto Click'\n\n📱 Mobile: Clicks above jump button (you can walk!)\n💻 PC: Clicks at screen center"
})

InfoTab:CreateParagraph({
    Title = "Follow Mode",
    Content = "1. Go to Follow tab\n2. Enter player name or use Quick Select\n3. Toggle 'Enable Follow'\n4. Adjust distance if needed\n\nYou will automatically follow the player from behind."
})

InfoTab:CreateParagraph({
    Title = "Aimbot Mode",
    Content = "1. Go to Aimbot tab\n2. Toggle 'Enable Aimbot'\n3. Your camera will lock onto nearest player\n\nYou can use Follow and Aimbot together!"
})

InfoTab:CreateSection("🐛 Troubleshooting")

InfoTab:CreateParagraph({
    Title = "If Something Doesn't Work",
    Content = "• Make sure you entered the correct player name\n• Use 'Refresh Player List' to see current players\n• Press F9 to see console messages\n• Use 'STOP ALL FEATURES' to reset\n• Make sure the target player hasn't left"
})

-- Initial notification
Notify("✓ Loaded", "Follow & Aimbot ready!")

-- Console output
print("=" .. string.rep("=", 50))
print("FOLLOW & AIMBOT SCRIPT v1.0")
print("=" .. string.rep("=", 50))
print("Status: LOADED ✓")
print("Player: " .. player.Name)
print("Features: Auto Click, Follow, Aimbot")
print("=" .. string.rep("=", 50))
