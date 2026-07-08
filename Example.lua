-- Load library
local FallensUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/FallensHub/Fallens-UI/refs/heads/main/Library.lua"))()

-- Create window
local Window = FallensUI:Window({
    Title = "FallensUI",
    AlwaysShowTab = true,
    Content = "Best Script",
    Image = "91112706169806",
    Color = Color3.fromRGB(78, 127, 252),
    Uitransparent = 0.12,
    ShowUser = true,
    KeySytem = {
        Title = "My Hub",
        Subtitle = "Enter key to continue",
    },
    Options = {
        Keyless = false,
        Blur = true,
        Draggable = true,
    },
    Callbacks = {
        OnVerify = function(key)
            if key == "test" then return { valid = true } end
            return { valid = false, error = "KEY_INVALID" }
        end,
        OnSuccess = function() print("Verified!") end,
    }
})

-- Watermark
Window:Watermark({ Desc = "{Fallens} | {TIME} | {FPS} FPS" })

-- Home tab
Window:CreateHomeTab({
    Name = "Dashboard",
    Content = "Welcome to My Hub!",
    Changelog = {
        { Title = "v1.0", Date = "Today", Description = "Initial release" }
    }
})

-- Add tab
local Tab = Window:AddTab({ Name = "Main", Icon = "lucide:sparkles", Type = "Double" })
local Section = Tab:AddSection({ Name = "Features", Position = "Center" })

Section:AddToggle({
    Name = "Auto Farm",
    Default = false,
    Callback = function(v) print("Auto Farm:", v) end
})

Section:AddButton({
    Name = "Execute",
    Callback = function() print("Executed!") end
})
