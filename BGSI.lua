--[[
    Rayfield Script Hub Template
    Save this file and build your features!
--]]

-- 1. Load Rayfield Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- 2. Create the Main Window
local Window = Rayfield:CreateWindow({
    Name = "Your Script Hub",
    Icon = 0, -- Icon ID from Lucide icons (0 = default)
    LoadingTitle = "Loading Your Script...",
    LoadingSubtitle = "by YourName",
    Theme = "Default", -- Options: "Default", "DarkBlue", "Green", "Red", "Purple", "Yellow", "Orange"
    
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "YourHubConfig", -- Creates a folder to save settings
        FileName = "Settings"
    },
    
    KeySystem = false, -- Set to true if you want a key system
    KeySettings = {
        Title = "Key System",
        Subtitle = "Enter your key",
        Note = "Get key from discord.gg/yourlink",
        FileName = "YourHubKey",
        SaveKey = true,
        GrabKeyFromSite = false,
        Key = {"YourKey123"}
    }
})

-- 3. Create Tabs for Organization
local MainTab = Window:CreateTab("Main", 4483362458) -- Icon ID for home
local FarmTab = Window:CreateTab("Auto Farm", 4483362458) -- Change icon IDs as needed
local PlayerTab = Window:CreateTab("Player", 4483362458)
local TeleportTab = Window:CreateTab("Teleports", 4483362458)
local SettingsTab = Window:CreateTab("Settings", 4483362458)

-- 4. Add Elements to Tabs

-- ============== MAIN TAB ==============
MainTab:CreateSection("Welcome")

MainTab:CreateParagraph({
    Title = "Script Information",
    Content = "Welcome to Your Script Hub!\n\nThis is a template you can expand with your own features.\n\nUse the tabs above to navigate."
})

MainTab:CreateButton({
    Name = "Refresh Status",
    Callback = function()
        Rayfield:Notify({
            Title = "Refreshed",
            Content = "Status has been updated!",
            Duration = 3,
            Image = 4483362458,
        })
    end,
})

-- ============== AUTO FARM TAB ==============
FarmTab:CreateSection("Farming Options")

local autoFarmEnabled = false

FarmTab:CreateToggle({
    Name = "Auto Farm",
    CurrentValue = false,
    Flag = "AutoFarmToggle",
    Callback = function(Value)
        autoFarmEnabled = Value
        Rayfield:Notify({
            Title = "Auto Farm",
            Content = Value and "Enabled" or "Disabled",
            Duration = 2,
        })
    end,
})

FarmTab:CreateSlider({
    Name = "Farm Speed",
    Range = {1, 100},
    Increment = 1,
    Suffix = "%",
    CurrentValue = 50,
    Flag = "FarmSpeed",
    Callback = function(Value)
        print("Farm speed set to: " .. Value)
    end,
})

FarmTab:CreateDropdown({
    Name = "Select Area",
    Options = {"Spawn", "Forest", "Desert", "Volcano"},
    CurrentOption = {"Spawn"},
    MultipleOptions = false,
    Flag = "FarmArea",
    Callback = function(Options)
        print("Selected area: " .. tostring(Options[1]))
    end,
})

-- ============== PLAYER TAB ==============
PlayerTab:CreateSection("Movement")

PlayerTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 200},
    Increment = 1,
    Suffix = "studs/s",
    CurrentValue = 16,
    Flag = "WalkSpeed",
    Callback = function(Value)
        local player = game:GetService("Players").LocalPlayer
        local character = player.Character
        if character and character:FindFirstChild("Humanoid") then
            character.Humanoid.WalkSpeed = Value
        end
    end,
})

PlayerTab:CreateSlider({
    Name = "Jump Power",
    Range = {50, 300},
    Increment = 5,
    Suffix = "power",
    CurrentValue = 50,
    Flag = "JumpPower",
    Callback = function(Value)
        local player = game:GetService("Players").LocalPlayer
        local character = player.Character
        if character and character:FindFirstChild("Humanoid") then
            character.Humanoid.JumpPower = Value
        end
    end,
})

PlayerTab:CreateButton({
    Name = "Reset Walk Speed",
    Callback = function()
        local player = game:GetService("Players").LocalPlayer
        local character = player.Character
        if character and character:FindFirstChild("Humanoid") then
            character.Humanoid.WalkSpeed = 16
            character.Humanoid.JumpPower = 50
            Rayfield:Notify({
                Title = "Reset",
                Content = "Speed and jump reset to default",
                Duration = 2,
            })
        end
    end,
})

-- ============== TELEPORT TAB ==============
TeleportTab:CreateSection("Locations")

local locations = {
    ["Spawn"] = CFrame.new(0, 10, 0),
    ["Shop"] = CFrame.new(100, 10, 50),
    ["Forest"] = CFrame.new(-200, 15, 100),
    -- Add actual coordinates from your game here
}

for name, cframe in pairs(locations) do
    TeleportTab:CreateButton({
        Name = "Teleport to " .. name,
        Callback = function()
            local player = game:GetService("Players").LocalPlayer
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                character.HumanoidRootPart.CFrame = cframe
                Rayfield:Notify({
                    Title = "Teleported",
                    Content = "Arrived at " .. name,
                    Duration = 2,
                })
            end
        end,
    })
end

-- ============== SETTINGS TAB ==============
SettingsTab:CreateSection("UI Settings")

local themes = {"Default", "DarkBlue", "Green", "Red", "Purple", "Yellow", "Orange"}

SettingsTab:CreateDropdown({
    Name = "Theme",
    Options = themes,
    CurrentOption = {"Default"},
    MultipleOptions = false, 
    Flag = "ThemeSelector",
    Callback = function(Options)
        Rayfield:Notify({
            Title = "Theme",
            Content = "Theme changes apply after restart",
            Duration = 3,
        })
    end,
})

SettingsTab:CreateButton({
    Name = "Destroy UI",
    Callback = function()
        Rayfield:Destroy()
    end,
})

SettingsTab:CreateParagraph({
    Title = "Credits",
    Content = "Script Hub Template\nMade with Rayfield Library\n\nExpand this with your own features!"
})

-- 5. Initialization Notification
Rayfield:Notify({
    Title = "Script Loaded",
    Content = "Welcome! Select a tab to begin.",
    Duration = 5,
    Image = 4483362458,
})

print("Rayfield Script Hub Template loaded successfully!")