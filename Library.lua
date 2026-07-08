--========================================================
-- SERVICES
--========================================================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local ContextActionService = game:GetService("ContextActionService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--========================================================
-- UTILITIES
--========================================================
local Utility = {}

function Utility:Create(class, properties, children)
    local obj = Instance.new(class)
    if properties then
        for prop, val in pairs(properties) do
            if prop ~= "Parent" then
                obj[prop] = val
            end
        end
    end
    if children then
        for _, child in pairs(children) do
            child.Parent = obj
        end
    end
    return obj
end

function Utility:Tween(obj, props, time, style, direction)
    local info = TweenInfo.new(
        time or 0.2,
        style or Enum.EasingStyle.Quad,
        direction or Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(obj, info, props)
    tween:Play()
    return tween
end

function Utility:Round(num, places)
    local mult = 10 ^ (places or 0)
    return math.floor(num * mult + 0.5) / mult
end

function Utility:GetExecutor()
    local exec = "Unknown"
    pcall(function()
        if identifyexecutor then
            exec = identifyexecutor()
        end
    end)
    return exec
end

function Utility:GetTime()
    return os.date("%H:%M:%S")
end

function Utility:GetFPS()
    return math.floor(1 / RunService.RenderStepped:Wait())
end

function Utility:SafeGetGui()
    local gui = CoreGui
    pcall(function()
        if syn and syn.protect_gui then
            gui = CoreGui
        end
    end)
    return gui
end

function Utility:ParentToGui(obj)
    local parent = CoreGui
    pcall(function()
        if gethui then
            parent = gethui()
        end
    end)
    pcall(function()
        if syn and syn.protect_gui then
            syn.protect_gui(obj)
        end
    end)
    obj.Parent = parent
    return obj
end

--========================================================
-- ICON SYSTEM (Lucide-style SVG icons)
--========================================================
local Icons = {
    ["lucide:layout-dashboard"] = "rbxassetid://129080111323259",
    ["lucide:sparkles"] = "rbxassetid://129080111323259",
    ["lucide:settings"] = "rbxassetid://129080111323259",
    ["lucide:trash-2"] = "rbxassetid://129080111323259",
    ["lucide:rocket"] = "rbxassetid://129080111323259",
    ["lucide:download"] = "rbxassetid://129080111323259",
    ["lucide:user"] = "rbxassetid://129080111323259",
    ["lucide:play"] = "rbxassetid://129080111323259",
    ["lucide:swords"] = "rbxassetid://129080111323259",
    ["lucide:triangle-alert"] = "rbxassetid://129080111323259",
    ["lucide:check"] = "rbxassetid://129080111323259",
    ["lucide:grid-2x2"] = "rbxassetid://129080111323259",
    ["lucide:code"] = "rbxassetid://129080111323259",
    ["lucide:file-text"] = "rbxassetid://129080111323259",
    ["lucide:bell"] = "rbxassetid://129080111323259",
    ["lucide:x"] = "rbxassetid://129080111323259",
    ["lucide:minus"] = "rbxassetid://129080111323259",
    ["lucide:plus"] = "rbxassetid://129080111323259",
    ["lucide:chevron-down"] = "rbxassetid://129080111323259",
    ["lucide:chevron-right"] = "rbxassetid://129080111323259",
    ["lucide:search"] = "rbxassetid://129080111323259",
    ["lucide:circle-i"] = "rbxassetid://129080111323259",
    ["lucide:lightning-bolt"] = "rbxassetid://129080111323259",
    ["lucide:paint-brush"] = "rbxassetid://129080111323259",
    ["lucide:rectangle-numbers-counting"] = "rbxassetid://129080111323259",
    ["lucide:minus-small"] = "rbxassetid://129080111323259",
    ["lucide:arrow-back"] = "rbxassetid://129080111323259",
    ["lucide:play-large"] = "rbxassetid://129080111323259",
    ["lucide:discord"] = "rbxassetid://129080111323259",
    ["lucide:key"] = "rbxassetid://129080111323259",
    ["lucide:shield"] = "rbxassetid://129080111323259",
    ["lucide:loader"] = "rbxassetid://129080111323259",
}

local function GetIcon(name)
    if Icons[name] then
        return Icons[name]
    end
    -- Try direct asset id
    if type(name) == "string" and name:match("^rbxassetid") then
        return name
    end
    if type(name) == "string" and name:match("^http") then
        return name
    end
    return "rbxassetid://129080111323259"
end

--========================================================
-- THEME
--========================================================
local Theme = {
    Background = Color3.fromRGB(20, 20, 25),
    BackgroundLight = Color3.fromRGB(30, 30, 38),
    Sidebar = Color3.fromRGB(25, 25, 32),
    Card = Color3.fromRGB(35, 35, 44),
    CardHover = Color3.fromRGB(42, 42, 52),
    Border = Color3.fromRGB(50, 50, 60),
    Text = Color3.fromRGB(240, 240, 245),
    TextSecondary = Color3.fromRGB(160, 160, 175),
    TextMuted = Color3.fromRGB(110, 110, 125),
    Accent = Color3.fromRGB(78, 127, 252),
    AccentDark = Color3.fromRGB(55, 95, 200),
    Success = Color3.fromRGB(72, 187, 120),
    Warning = Color3.fromRGB(237, 153, 28),
    Danger = Color3.fromRGB(239, 68, 68),
    White = Color3.fromRGB(255, 255, 255),
    Black = Color3.fromRGB(0, 0, 0),
    Overlay = Color3.fromRGB(0, 0, 0),
}

--========================================================
-- DRAGGABLE SYSTEM
--========================================================
local function MakeDraggable(frame, callback)
    local dragging = false
    local dragStart, startPos
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                local delta = input.Position - dragStart
                frame.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
                if callback then callback(frame.Position) end
            end
        end
    end)
end

--========================================================
-- RIPPLE EFFECT
--========================================================
local function CreateRipple(button, x, y)
    local ripple = Utility:Create("Frame", {
        Name = "Ripple",
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.7,
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0, x, 0, y),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex = 100,
    }, {
        Utility:Create("UICorner", { CornerRadius = UDim.new(1, 0) })
    })
    ripple.Parent = button
    
    local size = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 1.5
    Utility:Tween(ripple, {
        Size = UDim2.new(0, size, 0, size),
        BackgroundTransparency = 1
    }, 0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    task.delay(0.4, function()
        ripple:Destroy()
    end)
end

--========================================================
-- TOOLTIP SYSTEM
--========================================================
local TooltipSystem = {}
TooltipSystem.__index = TooltipSystem

function TooltipSystem.new(parentGui)
    local self = setmetatable({}, TooltipSystem)
    
    self.Tooltip = Utility:Create("Frame", {
        Name = "Tooltip",
        BackgroundColor3 = Theme.Card,
        BackgroundTransparency = 0,
        Size = UDim2.new(0, 200, 0, 32),
        AutomaticSize = Enum.AutomaticSize.Y,
        Visible = false,
        ZIndex = 9999,
    }, {
        Utility:Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
        Utility:Create("UIStroke", {
            Color = Theme.Border,
            Thickness = 1,
            Transparency = 0.5,
        }),
        Utility:Create("UIPadding", {
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10),
            PaddingTop = UDim.new(0, 6),
            PaddingBottom = UDim.new(0, 6),
        }),
        Utility:Create("TextLabel", {
            Name = "Text",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 20),
            Font = Enum.Font.Gotham,
            TextColor3 = Theme.Text,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            AutomaticSize = Enum.AutomaticSize.Y,
        })
    })
    
    self.Tooltip.Parent = parentGui
    self.Label = self.Tooltip.Text
    self.ParentGui = parentGui
    
    return self
end

function TooltipSystem:Show(text, mousePos)
    self.Label.Text = text
    self.Tooltip.Size = UDim2.new(0, 200, 0, 32)
    self.Tooltip.AutomaticSize = Enum.AutomaticSize.Y
    self.Tooltip.Visible = true
    
    local x = mousePos.X + 15
    local y = mousePos.Y + 15
    
    if x + 210 > self.ParentGui.AbsoluteSize.X then
        x = mousePos.X - 215
    end
    
    self.Tooltip.Position = UDim2.new(0, x, 0, y)
end

function TooltipSystem:Hide()
    self.Tooltip.Visible = false
end

--========================================================
-- NOTIFICATION SYSTEM
--========================================================
local NotificationSystem = {}
NotificationSystem.__index = NotificationSystem

function NotificationSystem.new(parentGui)
    local self = setmetatable({}, NotificationSystem)
    
    self.Container = Utility:Create("Frame", {
        Name = "Notifications",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 350, 1, 0),
        Position = UDim2.new(1, -370, 0, 20),
        BackgroundColor3 = Theme.Background,
    }, {
        Utility:Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8),
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
        })
    })
    
    self.Container.Parent = parentGui
    self.ParentGui = parentGui
    self.Notifications = {}
    
    return self
end

function NotificationSystem:Notify(config)
    local notif = Utility:Create("Frame", {
        Name = "Notification",
        BackgroundColor3 = Theme.Card,
        BackgroundTransparency = 0,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        ClipsDescendants = true,
    }, {
        Utility:Create("UICorner", { CornerRadius = UDim.new(0, 10) }),
        Utility:Create("UIStroke", {
            Color = Theme.Border,
            Thickness = 1,
            Transparency = 0.3,
        }),
        Utility:Create("UIPadding", {
            PaddingLeft = UDim.new(0, 14),
            PaddingRight = UDim.new(0, 14),
            PaddingTop = UDim.new(0, 12),
            PaddingBottom = UDim.new(0, 12),
        }),
    })
    
    local accentBar = Utility:Create("Frame", {
        Name = "AccentBar",
        BackgroundColor3 = config.Color or Theme.Accent,
        Size = UDim2.new(0, 3, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
    }, {
        Utility:Create("UICorner", { CornerRadius = UDim.new(0, 2) })
    })
    accentBar.Parent = notif
    
    local content = Utility:Create("Frame", {
        Name = "Content",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -10, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Position = UDim2.new(0, 10, 0, 0),
    }, {
        Utility:Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 4),
        })
    })
    content.Parent = notif
    
    local titleRow = Utility:Create("Frame", {
        Name = "TitleRow",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 20),
    }, {
        Utility:Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8),
            VerticalAlignment = Enum.VerticalAlignment.Center,
        })
    })
    titleRow.Parent = content
    
    if config.Icon then
        local icon = Utility:Create("ImageLabel", {
            Name = "Icon",
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 16, 0, 16),
            Image = GetIcon(config.Icon),
            ImageColor3 = Theme.Accent,
        })
        icon.Parent = titleRow
    end
    
    local title = Utility:Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 250, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = config.Title or "Notification",
        TextColor3 = Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    title.Parent = titleRow
    
    if config.Content then
        local desc = Utility:Create("TextLabel", {
            Name = "Description",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 16),
            Font = Enum.Font.Gotham,
            Text = config.Content,
            TextColor3 = Theme.TextSecondary,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            AutomaticSize = Enum.AutomaticSize.Y,
        })
        desc.Parent = content
    end
    
    -- Progress bar for duration
    local progressBg = Utility:Create("Frame", {
        Name = "ProgressBg",
        BackgroundColor3 = Theme.Background,
        BackgroundTransparency = 0.5,
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, -2),
    }, {
        Utility:Create("UICorner", { CornerRadius = UDim.new(1, 0) })
    })
    progressBg.Parent = notif
    
    local progressFill = Utility:Create("Frame", {
        Name = "ProgressFill",
        BackgroundColor3 = Theme.Accent,
        Size = UDim2.new(1, 0, 1, 0),
    }, {
        Utility:Create("UICorner", { CornerRadius = UDim.new(1, 0) })
    })
    progressFill.Parent = progressBg
    
    notif.Parent = self.Container
    
    -- Animate in
    notif.Size = UDim2.new(1, 0, 0, 0)
    notif.BackgroundTransparency = 1
    Utility:Tween(notif, { BackgroundTransparency = 0 }, 0.2)
    task.wait(0.05)
    local targetSize = notif.AbsoluteSize
    Utility:Tween(notif, { Size = UDim2.new(1, 0, 0, targetSize.Y + 24) }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    
    -- Auto dismiss
    local duration = config.Duration or 4
    Utility:Tween(progressFill, { Size = UDim2.new(0, 0, 1, 0) }, duration, Enum.EasingStyle.Linear)
    
    task.delay(duration, function()
        Utility:Tween(notif, { 
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundTransparency = 1,
        }, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        task.wait(0.3)
        notif:Destroy()
    end)
end

--========================================================
-- KEY SYSTEM
--========================================================
local KeySystem = {}
KeySystem.__index = KeySystem

function KeySystem.new(config)
    local self = setmetatable({}, KeySystem)
    self.Config = config
    self.Verified = false
    return self
end

function KeySystem:Show(parentGui, callbacks)
    local config = self.Config
    
    -- Blur
    local blur
    if config.Options and config.Options.Blur then
        blur = Utility:Create("BlurEffect", {
            Size = 24,
            Parent = Lighting,
        })
    end
    
    -- Overlay
    local overlay = Utility:Create("Frame", {
        Name = "KeySystemOverlay",
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.5,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 5000,
    })
    overlay.Parent = parentGui
    
    -- Main card
    local card = Utility:Create("Frame", {
        Name = "KeyCard",
        BackgroundColor3 = Theme.Background,
        BackgroundTransparency = 0,
        Size = UDim2.new(0, 420, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex = 5001,
    }, {
        Utility:Create("UICorner", { CornerRadius = UDim.new(0, 16) }),
        Utility:Create("UIStroke", {
            Color = Theme.Border,
            Thickness = 1,
        }),
        Utility:Create("UIPadding", {
            PaddingLeft = UDim.new(0, 30),
            PaddingRight = UDim.new(0, 30),
            PaddingTop = UDim.new(0, 30),
            PaddingBottom = UDim.new(0, 30),
        }),
    })
    card.Parent = overlay
    
    -- Animate in
    Utility:Tween(card, { Size = UDim2.new(0, 420, 0, 480) }, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    
    -- Icon
    local icon = Utility:Create("ImageLabel", {
        Name = "Icon",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 56, 0, 56),
        Position = UDim2.new(0.5, 0, 0, 0),
        AnchorPoint = Vector2.new(0.5, 0),
        Image = config.KeySytem and config.KeySytem.Icon or GetIcon("lucide:key"),
        ImageColor3 = Theme.Accent,
    })
    icon.Parent = card
    
    -- Title
    local title = Utility:Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 28),
        Position = UDim2.new(0, 0, 0, 70),
        Font = Enum.Font.GothamBold,
        Text = config.KeySytem and config.KeySytem.Title or "Key System",
        TextColor3 = Theme.Text,
        TextSize = 22,
    })
    title.Parent = card
    
    -- Subtitle
    local subtitle = Utility:Create("TextLabel", {
        Name = "Subtitle",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 18),
        Position = UDim2.new(0, 0, 0, 102),
        Font = Enum.Font.Gotham,
        Text = config.KeySytem and config.KeySytem.Subtitle or "Enter key to continue",
        TextColor3 = Theme.TextSecondary,
        TextSize = 13,
    })
    subtitle.Parent = card
    
    -- Input box
    local inputBox = Utility:Create("Frame", {
        Name = "InputBox",
        BackgroundColor3 = Theme.BackgroundLight,
        Size = UDim2.new(1, 0, 0, 44),
        Position = UDim2.new(0, 0, 0, 140),
    }, {
        Utility:Create("UICorner", { CornerRadius = UDim.new(0, 10) }),
        Utility:Create("UIStroke", {
            Color = Theme.Border,
            Thickness = 1,
            Transparency = 0.5,
        }),
        Utility:Create("UIPadding", {
            PaddingLeft = UDim.new(0, 14),
            PaddingRight = UDim.new(0, 14),
        }),
    })
    inputBox.Parent = card
    
    local input = Utility:Create("TextBox", {
        Name = "Input",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.Gotham,
        PlaceholderText = "Enter your key...",
        PlaceholderColor3 = Theme.TextMuted,
        Text = "",
        TextColor3 = Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    input.Parent = inputBox
    
    -- Error label
    local errorLabel = Utility:Create("TextLabel", {
        Name = "Error",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 16),
        Position = UDim2.new(0, 0, 0, 192),
        Font = Enum.Font.Gotham,
        Text = "",
        TextColor3 = Theme.Danger,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Visible = false,
    })
    errorLabel.Parent = card
    
    -- Get key button
    local getKeyBtn = Utility:Create("TextButton", {
        Name = "GetKey",
        BackgroundColor3 = Theme.Card,
        Size = UDim2.new(1, 0, 0, 40),
        Position = UDim2.new(0, 0, 0, 220),
        Font = Enum.Font.Gotham,
        Text = "Get Key",
        TextColor3 = Theme.Accent,
        TextSize = 13,
        AutoButtonColor = false,
    }, {
        Utility:Create("UICorner", { CornerRadius = UDim.new(0, 10) }),
        Utility:Create("UIStroke", {
            Color = Theme.Accent,
            Thickness = 1,
            Transparency = 0.5,
        }),
    })
    getKeyBtn.Parent = card
    
    getKeyBtn.MouseEnter:Connect(function()
        Utility:Tween(getKeyBtn, { BackgroundColor3 = Theme.CardHover }, 0.15)
    end)
    getKeyBtn.MouseLeave:Connect(function()
        Utility:Tween(getKeyBtn, { BackgroundColor3 = Theme.Card }, 0.15)
    end)
    getKeyBtn.MouseButton1Click:Connect(function()
        if config.Provider then
            local providers = {}
            if config.Provider.Linkvertise and config.Provider.Linkvertise ~= "yourlink" then
                table.insert(providers, { name = "Linkvertise", url = config.Provider.Linkvertise })
            end
            if config.Provider.lootlabs and config.Provider.lootlabs ~= "yourlink" then
                table.insert(providers, { name = "LootLabs", url = config.Provider.lootlabs })
            end
            if config.Provider.Workink and config.Provider.Workink ~= "yourlink" then
                table.insert(providers, { name = "Workink", url = config.Provider.Workink })
            end
            
            if #providers > 0 then
                -- Show provider selection
                self:ShowProviderSelection(parentGui, providers, config)
            else
                -- Default: try to set clipboard
                pcall(function()
                    if setclipboard then
                        setclipboard("https://linkvertise.com")
                    end
                end)
            end
        end
    end)
    
    -- Verify button
    local verifyBtn = Utility:Create("TextButton", {
        Name = "Verify",
        BackgroundColor3 = Theme.Accent,
        Size = UDim2.new(1, 0, 0, 44),
        Position = UDim2.new(0, 0, 0, 274),
        Font = Enum.Font.GothamBold,
        Text = "Verify Key",
        TextColor3 = Theme.White,
        TextSize = 14,
        AutoButtonColor = false,
    }, {
        Utility:Create("UICorner", { CornerRadius = UDim.new(0, 10) }),
    })
    verifyBtn.Parent = card
    
    verifyBtn.MouseEnter:Connect(function()
        Utility:Tween(verifyBtn, { BackgroundColor3 = Theme.AccentDark }, 0.15)
    end)
    verifyBtn.MouseLeave:Connect(function()
        Utility:Tween(verifyBtn, { BackgroundColor3 = Theme.Accent }, 0.15)
    end)
    
    -- Remember checkbox
    if config.Storage and config.Storage.Remember then
        local rememberBox = Utility:Create("Frame", {
            Name = "Remember",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 20),
            Position = UDim2.new(0, 0, 0, 330),
        }, {
            Utility:Create("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                Padding = UDim.new(0, 8),
                VerticalAlignment = Enum.VerticalAlignment.Center,
            })
        })
        rememberBox.Parent = card
        
        local checkbox = Utility:Create("TextButton", {
            Name = "Checkbox",
            BackgroundColor3 = Theme.Card,
            Size = UDim2.new(0, 18, 0, 18),
            AutoButtonColor = false,
        }, {
            Utility:Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
            Utility:Create("UIStroke", { Color = Theme.Border, Thickness = 1 }),
        })
        checkbox.Parent = rememberBox
        
        local checkIcon = Utility:Create("ImageLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Image = GetIcon("lucide:check"),
            ImageColor3 = Theme.White,
            ImageTransparency = 1,
        })
        checkIcon.Parent = checkbox
        
        local rememberLabel = Utility:Create("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 200, 0, 18),
            Font = Enum.Font.Gotham,
            Text = "Remember key",
            TextColor3 = Theme.TextSecondary,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
        })
        rememberLabel.Parent = rememberBox
        
        local checked = false
        
        -- Try to load saved key
        if config.Storage.AutoLoad then
            pcall(function()
                local saved = (readfile and readfile(config.Storage.FileName .. ".txt")) or ""
                if saved ~= "" then
                    input.Text = saved
                    checked = true
                    checkbox.BackgroundColor3 = Theme.Accent
                    checkIcon.ImageTransparency = 0
                end
            end)
        end
        
        checkbox.MouseButton1Click:Connect(function()
            checked = not checked
            if checked then
                Utility:Tween(checkbox, { BackgroundColor3 = Theme.Accent }, 0.15)
                Utility:Tween(checkIcon, { ImageTransparency = 0 }, 0.15)
            else
                Utility:Tween(checkbox, { BackgroundColor3 = Theme.Card }, 0.15)
                Utility:Tween(checkIcon, { ImageTransparency = 1 }, 0.15)
            end
        end)
        
        -- Store reference for verify
        self._checked = function() return checked end
    end
    
    -- Links
    if config.Links and config.Links.Discord then
        local discordBtn = Utility:Create("TextButton", {
            Name = "Discord",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 20),
            Position = UDim2.new(0, 0, 0, 370),
            Font = Enum.Font.Gotham,
            Text = "Join Discord",
            TextColor3 = Theme.TextMuted,
            TextSize = 12,
            AutoButtonColor = false,
        })
        discordBtn.Parent = card
        discordBtn.MouseButton1Click:Connect(function()
            pcall(function()
                if setclipboard then
                    setclipboard(config.Links.Discord)
                end
            end)
        end)
    end
    
    -- Verify logic
    local function doVerify()
        local key = input.Text
        if key == "" then
            errorLabel.Text = "Please enter a key"
            errorLabel.Visible = true
            return
        end
        
        if callbacks.OnVerify then
            local result = callbacks.OnVerify(key)
            if result and result.valid then
                self.Verified = true
                -- Save key if remember is checked
                if self._checked and self._checked() and config.Storage and config.Storage.FileName then
                    pcall(function()
                        if writefile then
                            writefile(config.Storage.FileName .. ".txt", key)
                        end
                    end)
                end
                
                if callbacks.OnSuccess then callbacks.OnSuccess() end
                
                -- Animate out
                Utility:Tween(card, { Size = UDim2.new(0, 420, 0, 0) }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
                Utility:Tween(overlay, { BackgroundTransparency = 1 }, 0.3)
                task.wait(0.3)
                if blur then blur:Destroy() end
                overlay:Destroy()
            else
                local errorMsg = (result and result.error) or "Invalid key"
                errorLabel.Text = errorMsg == "KEY_INVALID" and "Invalid key, please try again" or errorMsg
                errorLabel.Visible = true
                if callbacks.OnFail then callbacks.OnFail(errorMsg) end
                
                -- Shake animation
                local origPos = card.Position
                for i = 1, 3 do
                    Utility:Tween(card, { Position = UDim2.new(0.5, -8, 0.5, 0) }, 0.05)
                    task.wait(0.05)
                    Utility:Tween(card, { Position = UDim2.new(0.5, 8, 0.5, 0) }, 0.05)
                    task.wait(0.05)
                end
                Utility:Tween(card, { Position = origPos }, 0.05)
            end
        end
    end
    
    verifyBtn.MouseButton1Click:Connect(doVerify)
    input.FocusLost:Connect(function(enter)
        if enter then doVerify() end
    end)
    
    -- Close button (if keyless or allow close)
    if config.Options and config.Options.Keyless then
        self.Verified = true
        task.wait(0.1)
        Utility:Tween(card, { Size = UDim2.new(0, 420, 0, 0) }, 0.3)
        Utility:Tween(overlay, { BackgroundTransparency = 1 }, 0.3)
        task.wait(0.3)
        if blur then blur:Destroy() end
        overlay:Destroy()
        if callbacks.OnSuccess then callbacks.OnSuccess() end
    end
end

function KeySystem:ShowProviderSelection(parentGui, providers, config)
    -- Simple: just open the first provider
    pcall(function()
        if setclipboard then
            setclipboard(providers[1].url)
        end
    end)
end

--========================================================
-- LOADING SCREEN
--========================================================
local LoadingScreen = {}
LoadingScreen.__index = LoadingScreen

function LoadingScreen.new(parentGui, config)
    local self = setmetatable({}, LoadingScreen)
    
    self.Overlay = Utility:Create("Frame", {
        Name = "LoadingOverlay",
        BackgroundColor3 = Theme.Background,
        BackgroundTransparency = 0,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 8000,
    })
    self.Overlay.Parent = parentGui
    
    -- Main container
    self.Main = Utility:Create("Frame", {
        Name = "Main",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 500, 0, 320),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
    }, {
        Utility:Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 0),
        })
    })
    self.Main.Parent = self.Overlay
    
    -- Left content
    self.LeftContent = Utility:Create("Frame", {
        Name = "LeftContent",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 340, 1, 0),
    }, {
        Utility:Create("UIPadding", {
            PaddingLeft = UDim.new(0, 20),
            PaddingRight = UDim.new(0, 20),
            PaddingTop = UDim.new(0, 30),
            PaddingBottom = UDim.new(0, 30),
        }),
        Utility:Create("UIListLayout", {
            Padding = UDim.new(0, 16),
            VerticalAlignment = Enum.VerticalAlignment.Center,
        })
    })
    self.LeftContent.Parent = self.Main
    
    -- Icon
    self.Icon = Utility:Create("ImageLabel", {
        Name = "Icon",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 48, 0, 48),
        Image = GetIcon(config.Icon or "lucide:rocket"),
        ImageColor3 = Theme.Accent,
    })
    self.Icon.Parent = self.LeftContent
    
    -- Title
    self.Title = Utility:Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 30),
        Font = Enum.Font.GothamBold,
        Text = config.Title or "Loading",
        TextColor3 = Theme.Text,
        TextSize = 24,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    self.Title.Parent = self.LeftContent
    
    -- Message
    self.Message = Utility:Create("TextLabel", {
        Name = "Message",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 18),
        Font = Enum.Font.Gotham,
        Text = "",
        TextColor3 = Theme.TextSecondary,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    self.Message.Parent = self.LeftContent
    
    -- Description
    self.Description = Utility:Create("TextLabel", {
        Name = "Description",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 16),
        Font = Enum.Font.Gotham,
        Text = "",
        TextColor3 = Theme.TextMuted,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
    })
    self.Description.Parent = self.LeftContent
    
    -- Progress bar
    self.ProgressBg = Utility:Create("Frame", {
        Name = "ProgressBg",
        BackgroundColor3 = Theme.BackgroundLight,
        Size = UDim2.new(1, 0, 0, 4),
    }, {
        Utility:Create("UICorner", { CornerRadius = UDim.new(1, 0) })
    })
    self.ProgressBg.Parent = self.LeftContent
    
    self.ProgressFill = Utility:Create("Frame", {
        Name = "ProgressFill",
        BackgroundColor3 = Theme.Accent,
        Size = UDim2.new(0, 0, 1, 0),
    }, {
        Utility:Create("UICorner", { CornerRadius = UDim.new(1, 0) })
    })
    self.ProgressFill.Parent = self.ProgressBg
    
    -- Step text
    self.StepText = Utility:Create("TextLabel", {
        Name = "StepText",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 14),
        Font = Enum.Font.Gotham,
        Text = "0 / " .. (config.TotalSteps or 1),
        TextColor3 = Theme.TextMuted,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    self.StepText.Parent = self.LeftContent
    
    -- Sidebar (hidden by default)
    self.Sidebar = Utility:Create("Frame", {
        Name = "Sidebar",
        BackgroundColor3 = Theme.BackgroundLight,
        Size = UDim2.new(0, 160, 1, 0),
        Visible = false,
    }, {
        Utility:Create("UICorner", { CornerRadius = UDim.new(0, 12) }),
        Utility:Create("UIPadding", {
            PaddingLeft = UDim.new(0, 14),
            PaddingRight = UDim.new(0, 14),
            PaddingTop = UDim.new(0, 16),
            PaddingBottom = UDim.new(0, 16),
        }),
        Utility:Create("UIListLayout", {
            Padding = UDim.new(0, 8),
        })
    })
    self.Sidebar.Parent = self.Main
    
    -- Sidebar methods
    self.Sidebar.AddLabel = function(_, text)
        local label = Utility:Create("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 16),
            Font = Enum.Font.Gotham,
            Text = text,
            TextColor3 = Theme.TextSecondary,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
        })
        label.Parent = self.Sidebar
        return label
    end
    
    self.TotalSteps = config.TotalSteps or 1
    self.CurrentStep = 0
    self.Closed = false
    
    return self
end

function LoadingScreen:SetMessage(msg)
    self.Message.Text = msg
end

function LoadingScreen:SetDescription(desc)
    self.Description.Text = desc
end

function LoadingScreen:SetCurrentStep(step)
    self.CurrentStep = step
    self.StepText.Text = step .. " / " .. self.TotalSteps
    local pct = step / self.TotalSteps
    Utility:Tween(self.ProgressFill, { Size = UDim2.new(pct, 0, 1, 0) }, 0.3)
end

function LoadingScreen:ShowSidebarPage(show)
    self.Sidebar.Visible = show
    if show then
        self.LeftContent.Size = UDim2.new(0, 340, 1, 0)
    else
        self.LeftContent.Size = UDim2.new(1, 0, 1, 0)
    end
end

function LoadingScreen:Continue()
    Utility:Tween(self.ProgressFill, { Size = UDim2.new(1, 0, 1, 0) }, 0.3)
    task.wait(0.4)
    Utility:Tween(self.Overlay, { BackgroundTransparency = 1 }, 0.4)
    task.wait(0.4)
    self.Overlay:Destroy()
    self.Closed = true
end

--========================================================
-- DIALOG SYSTEM
--========================================================
local DialogSystem = {}
DialogSystem.__index = DialogSystem

function DialogSystem.new(window)
    local self = setmetatable({}, DialogSystem)
    self.Window = window
    return self
end

function DialogSystem:AddDialog(config)
    local overlay = Utility:Create("Frame", {
        Name = "DialogOverlay",
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.6,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 6000,
    })
    overlay.Parent = self.Window.ScreenGui
    
    local card = Utility:Create("Frame", {
        Name = "DialogCard",
        BackgroundColor3 = Theme.Background,
        Size = UDim2.new(0, 420, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex = 6001,
    }, {
        Utility:Create("UICorner", { CornerRadius = UDim.new(0, 16) }),
        Utility:Create("UIStroke", { Color = Theme.Border, Thickness = 1 }),
        Utility:Create("UIPadding", {
            PaddingLeft = UDim.new(0, 24),
            PaddingRight = UDim.new(0, 24),
            PaddingTop = UDim.new(0, 24),
            PaddingBottom = UDim.new(0, 24),
        }),
    })
    card.Parent = overlay
    
    -- Animate in
    Utility:Tween(card, { Size = UDim2.new(0, 420, 0, 0) }, 0.01)
    task.wait(0.01)
    
    local contentFrame = Utility:Create("Frame", {
        Name = "Content",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
    }, {
        Utility:Create("UIListLayout", {
            Padding = UDim.new(0, 12),
        })
    })
    contentFrame.Parent = card
    
    -- Icon
    if config.Icon then
        local icon = Utility:Create("ImageLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 40, 0, 40),
            Image = GetIcon(config.Icon),
            ImageColor3 = Theme.Accent,
        })
        icon.Parent = contentFrame
    end
    
    -- Title
    local title = Utility:Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 24),
        Font = Enum.Font.GothamBold,
        Text = config.Title or "Dialog",
        TextColor3 = Theme.Text,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    title.Parent = contentFrame
    
    -- Description
    if config.Description then
        local desc = Utility:Create("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            Font = Enum.Font.Gotham,
            Text = config.Description,
            TextColor3 = Theme.TextSecondary,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            AutomaticSize = Enum.AutomaticSize.Y,
        })
        desc.Parent = contentFrame
    end
    
    -- Dialog elements container (for AddToggle, etc.)
    local elementsContainer = Utility:Create("Frame", {
        Name = "Elements",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
    }, {
        Utility:Create("UIListLayout", {
            Padding = UDim.new(0, 8),
        })
    })
    elementsContainer.Parent = contentFrame
    
    -- Footer buttons
    local footer = Utility:Create("Frame", {
        Name = "Footer",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 40),
    }, {
        Utility:Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 10),
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
        })
    })
    footer.Parent = contentFrame
    
    -- Sort footer buttons by order
    local footerButtons = {}
    if config.FooterButtons then
        for name, btnConfig in pairs(config.FooterButtons) do
            btnConfig._name = name
            table.insert(footerButtons, btnConfig)
        end
        table.sort(footerButtons, function(a, b)
            return (a.Order or 0) < (b.Order or 0)
        end)
    end
    
    local dialogObj = {
        Card = card,
        Overlay = overlay,
        Elements = elementsContainer,
        Toggles = {},
    }
    
    dialogObj.Dismiss = function()
        Utility:Tween(card, { Size = UDim2.new(0, 420, 0, 0) }, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        Utility:Tween(overlay, { BackgroundTransparency = 1 }, 0.25)
        task.wait(0.25)
        overlay:Destroy()
    end
    
    dialogObj.AddToggle = function(_, toggleConfig)
        local toggleFrame = Utility:Create("Frame", {
            BackgroundColor3 = Theme.Card,
            Size = UDim2.new(1, 0, 0, 44),
        }, {
            Utility:Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
            Utility:Create("UIPadding", {
                PaddingLeft = UDim.new(0, 12),
                PaddingRight = UDim.new(0, 12),
            }),
        })
        toggleFrame.Parent = elementsContainer
        
        local label = Utility:Create("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -50, 1, 0),
            Font = Enum.Font.Gotham,
            Text = toggleConfig.Name,
            TextColor3 = Theme.Text,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
        })
        label.Parent = toggleFrame
        
        local switchBg = Utility:Create("Frame", {
            BackgroundColor3 = Theme.BackgroundLight,
            Size = UDim2.new(0, 36, 0, 20),
            Position = UDim2.new(1, -36, 0.5, -10),
        }, {
            Utility:Create("UICorner", { CornerRadius = UDim.new(1, 0) })
        })
        switchBg.Parent = toggleFrame
        
        local knob = Utility:Create("Frame", {
            BackgroundColor3 = Theme.White,
            Size = UDim2.new(0, 16, 0, 16),
            Position = UDim2.new(0, 2, 0.5, -8),
        }, {
            Utility:Create("UICorner", { CornerRadius = UDim.new(1, 0) })
        })
        knob.Parent = switchBg
        
        local state = toggleConfig.Default or false
        local function updateToggle()
            if state then
                Utility:Tween(switchBg, { BackgroundColor3 = Theme.Accent }, 0.15)
                Utility:Tween(knob, { Position = UDim2.new(1, -18, 0.5, -8) }, 0.15)
            else
                Utility:Tween(switchBg, { BackgroundColor3 = Theme.BackgroundLight }, 0.15)
                Utility:Tween(knob, { Position = UDim2.new(0, 2, 0.5, -8) }, 0.15)
            end
        end
        updateToggle()
        
        switchBg.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                state = not state
                updateToggle()
                if toggleConfig.Callback then toggleConfig.Callback(state) end
            end
        end)
        
        local toggleObj = {
            GetValue = function() return state end,
            SetValue = function(v) state = v; updateToggle() end,
        }
        dialogObj.Toggles[toggleConfig.Flag or toggleConfig.Name] = toggleObj
        dialogObj[toggleConfig.Flag or toggleConfig.Name] = toggleObj
        return toggleObj
    end
    
    for _, btnConfig in ipairs(footerButtons) do
        local btnColor = Theme.Card
        local textColor = Theme.Text
        if btnConfig.Variant == "Primary" then
            btnColor = Theme.Accent
            textColor = Theme.White
        elseif btnConfig.Variant == "Destructive" then
            btnColor = Theme.Danger
            textColor = Theme.White
        elseif btnConfig.Variant == "Secondary" then
            btnColor = Theme.Card
            textColor = Theme.TextSecondary
        end
        
        local btn = Utility:Create("TextButton", {
            BackgroundColor3 = btnColor,
            Size = UDim2.new(0, 100, 1, 0),
            Font = Enum.Font.GothamBold,
            Text = btnConfig.Title or "Button",
            TextColor3 = textColor,
            TextSize = 13,
            AutoButtonColor = false,
        }, {
            Utility:Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
        })
        btn.Parent = footer
        
        -- Wait time for destructive buttons
        local waitTime = btnConfig.WaitTime or 0
        local originalText = btnConfig.Title
        
        btn.MouseButton1Click:Connect(function()
            if waitTime > 0 then
                for i = waitTime, 1, -1 do
                    btn.Text = originalText .. " (" .. i .. ")"
                    btn.BackgroundColor3 = Theme.Card
                    task.wait(1)
                end
            end
            if btnConfig.Callback then btnConfig.Callback(dialogObj) end
        end)
    end
    
    -- Auto dismiss
    if config.AutoDismiss then
        overlay.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                if config.OutsideClickDismiss then
                    dialogObj.Dismiss()
                end
            end
        end)
    end
    
    -- Animate in
    local targetHeight = contentFrame.AbsoluteSize.Y + 48
    Utility:Tween(card, { Size = UDim2.new(0, 420, 0, targetHeight) }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    
    return dialogObj
end

function DialogSystem:ProgressDialog(config)
    local overlay = Utility:Create("Frame", {
        Name = "ProgressOverlay",
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.6,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 6000,
    })
    overlay.Parent = self.Window.ScreenGui
    
    local card = Utility:Create("Frame", {
        Name = "ProgressDialog",
        BackgroundColor3 = Theme.Background,
        Size = UDim2.new(0, 380, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex = 6001,
    }, {
        Utility:Create("UICorner", { CornerRadius = UDim.new(0, 16) }),
        Utility:Create("UIStroke", { Color = Theme.Border, Thickness = 1 }),
        Utility:Create("UIPadding", {
            PaddingLeft = UDim.new(0, 24),
            PaddingRight = UDim.new(0, 24),
            PaddingTop = UDim.new(0, 24),
            PaddingBottom = UDim.new(0, 24),
        }),
        Utility:Create("UIListLayout", { Padding = UDim.new(0, 12) }),
    })
    card.Parent = overlay
    
    local title = Utility:Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 22),
        Font = Enum.Font.GothamBold,
        Text = config.Title or "Progress",
        TextColor3 = Theme.Text,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    title.Parent = card
    
    local desc = Utility:Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 16),
        Font = Enum.Font.Gotham,
        Text = config.Description or "",
        TextColor3 = Theme.TextSecondary,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
    })
    desc.Parent = card
    
    local progressBg = Utility:Create("Frame", {
        BackgroundColor3 = Theme.BackgroundLight,
        Size = UDim2.new(1, 0, 0, 6),
    }, {
        Utility:Create("UICorner", { CornerRadius = UDim.new(1, 0) })
    })
    progressBg.Parent = card
    
    local progressFill = Utility:Create("Frame", {
        BackgroundColor3 = Theme.Accent,
        Size = UDim2.new(0, 0, 1, 0),
    }, {
        Utility:Create("UICorner", { CornerRadius = UDim.new(1, 0) })
    })
    progressFill.Parent = progressBg
    
    local valueLabel = Utility:Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 14),
        Font = Enum.Font.GothamBold,
        Text = "0%",
        TextColor3 = Theme.Accent,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Right,
    })
    valueLabel.Parent = card
    
    local cancelBtn
    if config.Cancelable then
        cancelBtn = Utility:Create("TextButton", {
            BackgroundColor3 = Theme.Card,
            Size = UDim2.new(1, 0, 0, 36),
            Font = Enum.Font.Gotham,
            Text = config.CancelText or "Cancel",
            TextColor3 = Theme.Danger,
            TextSize = 13,
            AutoButtonColor = false,
        }, {
            Utility:Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
            Utility:Create("UIStroke", { Color = Theme.Danger, Thickness = 1, Transparency = 0.5 }),
        })
        cancelBtn.Parent = card
    end
    
    local progressObj = {
        Value = config.Value or 0,
        Max = config.Max or 100,
        Closed = false,
    }
    
    function progressObj:SetValue(val)
        self.Value = val
        local pct = val / self.Max
        Utility:Tween(progressFill, { Size = UDim2.new(pct, 0, 1, 0) }, 0.1)
        if config.Type == "%" then
            valueLabel.Text = math.floor(val) .. "%"
        else
            valueLabel.Text = val .. " / " .. self.Max
        end
        
        if config.AutoClose and val >= self.Max then
            task.wait(0.3)
            self:Close()
            if config.Callback then config.Callback("Completed") end
        end
    end
    
    function progressObj:SetDescription(text)
        desc.Text = text
    end
    
    function progressObj:Close()
        self.Closed = true
        Utility:Tween(card, { Size = UDim2.new(0, 380, 0, 0) }, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        Utility:Tween(overlay, { BackgroundTransparency = 1 }, 0.25)
        task.wait(0.25)
        overlay:Destroy()
    end
    
    if cancelBtn then
        cancelBtn.MouseButton1Click:Connect(function()
            progressObj.Closed = true
            progressObj:Close()
            if config.Callback then config.Callback("Cancelled") end
        end)
    end
    
    -- Animate in
    Utility:Tween(card, { Size = UDim2.new(0, 380, 0, 180) }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    
    return progressObj
end

function DialogSystem:InputDialog(config)
    local overlay = Utility:Create("Frame", {
        Name = "InputDialog",
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.6,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 6000,
    })
    overlay.Parent = self.Window.ScreenGui
    
    local card = Utility:Create("Frame", {
        BackgroundColor3 = Theme.Background,
        Size = UDim2.new(0, 380, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex = 6001,
    }, {
        Utility:Create("UICorner", { CornerRadius = UDim.new(0, 16) }),
        Utility:Create("UIStroke", { Color = Theme.Border, Thickness = 1 }),
        Utility:Create("UIPadding", {
            PaddingLeft = UDim.new(0, 24),
            PaddingRight = UDim.new(0, 24),
            PaddingTop = UDim.new(0, 24),
            PaddingBottom = UDim.new(0, 24),
        }),
        Utility:Create("UIListLayout", { Padding = UDim.new(0, 10) }),
    })
    card.Parent = overlay
    
    local title = Utility:Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 22),
        Font = Enum.Font.GothamBold,
        Text = config.Title or "Input",
        TextColor3 = Theme.Text,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    title.Parent = card
    
    if config.Content then
        local content = Utility:Create("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 16),
            Font = Enum.Font.Gotham,
            Text = config.Content,
            TextColor3 = Theme.TextSecondary,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
        })
        content.Parent = card
    end
    
    local inputBox = Utility:Create("Frame", {
        BackgroundColor3 = Theme.BackgroundLight,
        Size = UDim2.new(1, 0, 0, 40),
    }, {
        Utility:Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
        Utility:Create("UIStroke", { Color = Theme.Border, Thickness = 1, Transparency = 0.5 }),
        Utility:Create("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) }),
    })
    inputBox.Parent = card
    
    local input = Utility:Create("TextBox", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.Gotham,
        PlaceholderText = config.Name or "Enter value...",
        PlaceholderColor3 = Theme.TextMuted,
        Text = config.Default or "",
        TextColor3 = Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    input.Parent = inputBox
    
    local submitBtn = Utility:Create("TextButton", {
        BackgroundColor3 = Theme.Accent,
        Size = UDim2.new(1, 0, 0, 40),
        Font = Enum.Font.GothamBold,
        Text = "Submit",
        TextColor3 = Theme.White,
        TextSize = 13,
        AutoButtonColor = false,
    }, {
        Utility:Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
    })
    submitBtn.Parent = card
    
    local function close()
        Utility:Tween(card, { Size = UDim2.new(0, 380, 0, 0) }, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        Utility:Tween(overlay, { BackgroundTransparency = 1 }, 0.25)
        task.wait(0.25)
        overlay:Destroy()
    end
    
    local function submit()
        local val = input.Text
        if config.Numeric then
            val = tonumber(val) or val
        end
        if config.Callback then config.Callback(val) end
        close()
    end
    
    submitBtn.MouseButton1Click:Connect(submit)
    input.FocusLost:Connect(function(enter)
        if enter then submit() end
    end)
    
    Utility:Tween(card, { Size = UDim2.new(0, 380, 0, 180) }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end

--========================================================
-- VIEWPORT COMPONENT
--========================================================
local ViewportComponent = {}
ViewportComponent.__index = ViewportComponent

function ViewportComponent.new(parent, config)
    local self = setmetatable({}, ViewportComponent)
    
    self.Frame = Utility:Create("Frame", {
        Name = "ViewportCard",
        BackgroundColor3 = Theme.Card,
        Size = UDim2.new(1, 0, 0, 200),
    }, {
        Utility:Create("UICorner", { CornerRadius = UDim.new(0, 10) }),
        Utility:Create("UIStroke", { Color = Theme.Border, Thickness = 1, Transparency = 0.5 }),
    })
    self.Frame.Parent = parent
    
    -- ViewportFrame
    self.VP = Utility:Create("ViewportFrame", {
        Name = "Viewport",
        BackgroundColor3 = Theme.Background,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
    }, {
        Utility:Create("UICorner", { CornerRadius = UDim.new(0, 10) }),
    })
    self.VP.Parent = self.Frame
    
    -- Set up camera
    self.Camera = Instance.new("Camera")
    self.Camera.CFrame = CFrame.new(Vector3.new(0, 3, 5), Vector3.new(0, 0, 0))
    self.VP.CurrentCamera = self.Camera
    
    -- Clone object
    self.Object = nil
    self.Chams = nil
    
    if config.Object then
        self:SetObject(config.Object, config.ChamsEnabled, config.ChamsColor)
    end
    
    self.Zoom = 1.5
    self.AutoRotate = config.AutoRotate or false
    self.RotationAngle = 0
    
    -- Auto rotate
    if self.AutoRotate then
        RunService.RenderStepped:Connect(function()
            if self.Object then
                self.RotationAngle = self.RotationAngle + 0.02
                local rad = math.rad(self.RotationAngle)
                local dist = 5 * self.Zoom
                self.Camera.CFrame = CFrame.new(
                    Vector3.new(math.sin(rad) * dist, 3, math.cos(rad) * dist),
                    Vector3.new(0, 0, 0)
                )
            end
        end)
    end
    
    function self.SetZoom(zoom)
        self.Zoom = zoom
        if not self.AutoRotate then
            local dist = 5 * zoom
            self.Camera.CFrame = CFrame.new(Vector3.new(0, 3, dist), Vector3.new(0, 0, 0))
        end
    end
    
    function self.SetObject(obj, chamsEnabled, chamsColor)
        if self.Object then
            self.Object:Destroy()
        end
        if not obj then return end
        
        local clone = obj:Clone()
        clone.Parent = self.VP
        
        -- Center the object
        if clone:IsA("Model") then
            local cf, size = clone:GetBoundingBox()
            clone:PivotTo(CFrame.new(Vector3.new(0, 0, 0)) - cf.Position + cf.Position)
        elseif clone:IsA("BasePart") then
            clone.Position = Vector3.new(0, 0, 0)
        end
        
        self.Object = clone
        
        -- Chams
        if chamsEnabled then
            local chams = Utility:Create("Highlight", {
                FillColor = chamsColor or Theme.Accent,
                FillTransparency = 0.5,
                OutlineColor = chamsColor or Theme.Accent,
                OutlineTransparency = 0,
            })
            chams.Parent = clone:IsA("Model") and clone or (clone.Parent)
            self.Chams = chams
        end
    end
    
    return self
end

--========================================================
-- COMPONENTS
--========================================================

-- Button Component
local function CreateButton(parent, config, window)
    local button = Utility:Create("TextButton", {
        Name = "Button",
        BackgroundColor3 = Theme.Card,
        Size = UDim2.new(1, 0, 0, 38),
        Font = Enum.Font.Gotham,
        Text = "",
        TextColor3 = Theme.Text,
        TextSize = 13,
        AutoButtonColor = false,
    }, {
        Utility:Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
        Utility:Create("UIStroke", { Color = Theme.Border, Thickness = 1, Transparency = 0.5 }),
        Utility:Create("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) }),
    })
    button.Parent = parent
    
    local contentRow = Utility:Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
    }, {
        Utility:Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 8),
            VerticalAlignment = Enum.VerticalAlignment.Center,
        })
    })
    contentRow.Parent = button
    
    if config.Icon then
        local icon = Utility:Create("ImageLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 16, 0, 16),
            Image = GetIcon(config.Icon),
            ImageColor3 = Theme.TextSecondary,
        })
        icon.Parent = contentRow
    end
    
    local label = Utility:Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -24, 1, 0),
        Font = Enum.Font.Gotham,
        Text = config.Name or "Button",
        TextColor3 = Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    label.Parent = contentRow
    
    -- Sub button
    if config.SubName then
        local subBtn = Utility:Create("TextButton", {
            BackgroundColor3 = Theme.BackgroundLight,
            Size = UDim2.new(0, 60, 0, 24),
            Font = Enum.Font.Gotham,
            Text = config.SubName,
            TextColor3 = Theme.TextSecondary,
            TextSize = 11,
            AutoButtonColor = false,
        }, {
            Utility:Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
        })
        subBtn.Parent = contentRow
        
        if config.SubLocked then
            subBtn.Text = config.SubTextLocked or "Locked"
            subBtn.TextColor3 = Theme.TextMuted
        end
        
        subBtn.MouseButton1Click:Connect(function()
            if not config.SubLocked and config.SubCallback then
                config.SubCallback()
            end
        end)
    end
    
    -- KeyPicker
    if config.KeyPicker then
        local keyBtn = Utility:Create("TextButton", {
            BackgroundColor3 = Theme.BackgroundLight,
            Size = UDim2.new(0, 50, 0, 24),
            Font = Enum.Font.GothamBold,
            Text = (config.KeyPicker.Default and config.KeyPicker.Default.Name) or "None",
            TextColor3 = Theme.Accent,
            TextSize = 11,
            AutoButtonColor = false,
        }, {
            Utility:Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
        })
        keyBtn.Parent = contentRow
        
        local currentKey = config.KeyPicker.Default
        local listening = false
        
        keyBtn.MouseButton1Click:Connect(function()
            if not listening then
                listening = true
                keyBtn.Text = "..."
                local conn
                conn = UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        currentKey = input.KeyCode
                        keyBtn.Text = currentKey.Name
                        listening = false
                        conn:Disconnect()
                    end
                end)
            end
        end)
        
        if currentKey then
            UserInputService.InputBegan:Connect(function(input, processed)
                if processed then return end
                if input.KeyCode == currentKey then
                    if config.Callback then config.Callback() end
                end
            end)
        end
    end
    
    -- Hover effects
    button.MouseEnter:Connect(function()
        Utility:Tween(button, { BackgroundColor3 = Theme.CardHover }, 0.15)
    end)
    button.MouseLeave:Connect(function()
        Utility:Tween(button, { BackgroundColor3 = Theme.Card }, 0.15)
    end)
    
    button.MouseButton1Click:Connect(function()
        local mousePos = UserInputService:GetMouseLocation()
        CreateRipple(button, mousePos.X - button.AbsolutePosition.X, mousePos.Y - button.AbsolutePosition.Y)
        if config.Callback then config.Callback() end
    end)
    
    -- Tooltip
    if config.Tooltip then
        button.MouseEnter:Connect(function()
            local mousePos = UserInputService:GetMouseLocation()
            window.Tooltip:Show(config.Tooltip, mousePos)
        end)
        button.MouseLeave:Connect(function()
            window.Tooltip:Hide()
        end)
    end
    
    return {
        Frame = button,
    }
end

-- Toggle Component
local function CreateToggle(parent, config, window)
    local toggle = Utility:Create("TextButton", {
        Name = "Toggle",
        BackgroundColor3 = Theme.Card,
        Size = UDim2.new(1, 0, 0, 38),
        Text = "",
        AutoButtonColor = false,
    }, {
        Utility:Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
        Utility:Create("UIStroke", { Color = Theme.Border, Thickness = 1, Transparency = 0.5 }),
        Utility:Create("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) }),
    })
    toggle.Parent = parent
    
    local label = Utility:Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -50, 1, 0),
        Font = Enum.Font.Gotham,
        Text = config.Name or "Toggle",
        TextColor3 = Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    label.Parent = toggle
    
    -- Switch
    local switchBg = Utility:Create("Frame", {
        BackgroundColor3 = Theme.BackgroundLight,
        Size = UDim2.new(0, 36, 0, 20),
        Position = UDim2.new(1, -36, 0.5, -10),
    }, {
        Utility:Create("UICorner", { CornerRadius = UDim.new(1, 0) })
    })
    switchBg.Parent = toggle
    
    local knob = Utility:Create("Frame", {
        BackgroundColor3 = Theme.White,
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0, 2, 0.5, -8),
    }, {
        Utility:Create("UICorner", { CornerRadius = UDim.new(1, 0) })
    })
    knob.Parent = switchBg
    
    local state = config.Default or false
    
    local function updateToggle()
        if state then
            Utility:Tween(switchBg, { BackgroundColor3 = Theme.Accent }, 0.15)
            Utility:Tween(knob, { Position = UDim2.new(1, -18, 0.5, -8) }, 0.15)
        else
            Utility:Tween(switchBg, { BackgroundColor3 = Theme.BackgroundLight }, 0.15)
            Utility:Tween(knob, { Position = UDim2.new(0, 2, 0.5, -8) }, 0.15)
        end
    end
    updateToggle()
    
    toggle.MouseButton1Click:Connect(function()
        state = not state
        updateToggle()
        if config.Callback then config.Callback(state) end
    end)
    
    -- Keybind
    if config.Keybind then
        local keyBtn = Utility:Create("TextButton", {
            BackgroundColor3 = Theme.BackgroundLight,
            Size = UDim2.new(0, 40, 0, 20),
            Position = UDim2.new(1, -80, 0.5, -10),
            Font = Enum.Font.GothamBold,
            Text = config.Keybind.Default and config.Keybind.Default.Name or "None",
            TextColor3 = Theme.Accent,
            TextSize = 10,
            AutoButtonColor = false,
            Visible = false,
        }, {
            Utility:Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
        })
        keyBtn.Parent = toggle
        
        local currentKey = config.Keybind.Default
        local mode = config.Keybind.Mode or "Toggle"
        local listening = false
        
        keyBtn.MouseButton1Click:Connect(function()
            if not listening then
                listening = true
                keyBtn.Text = "..."
                local conn
                conn = UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        currentKey = input.KeyCode
                        keyBtn.Text = currentKey.Name
                        listening = false
                        conn:Disconnect()
                    end
                end)
            end
        end)
        
        if currentKey then
            UserInputService.InputBegan:Connect(function(input, processed)
                if processed then return end
                if input.KeyCode == currentKey then
                    if mode == "Toggle" then
                        state = not state
                        updateToggle()
                        if config.Callback then config.Callback(state) end
                    else
                        if config.Callback then config.Callback(true) end
                    end
                end
            end)
        end
    end
    
    -- Tooltip
    if config.Tooltip then
        toggle.MouseEnter:Connect(function()
            local mousePos = UserInputService:GetMouseLocation()
            window.Tooltip:Show(config.Tooltip, mousePos)
        end)
        toggle.MouseLeave:Connect(function()
            window.Tooltip:Hide()
        end)
    end
    
    return {
        Frame = toggle,
        GetValue = function() return state end,
        SetValue = function(v)
            state = v
            updateToggle()
        end,
    }
end

-- TextInput Component
local function CreateTextInput(parent, config)
    local inputFrame = Utility:Create("Frame", {
        Name = "TextInput",
        BackgroundColor3 = Theme.Card,
        Size = UDim2.new(1, 0, 0, 60),
    }, {
        Utility:Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
        Utility:Create("UIStroke", { Color = Theme.Border, Thickness = 1, Transparency = 0.5 }),
        Utility:Create("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8) }),
    })
    inputFrame.Parent = parent
    
    local label = Utility:Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 14),
        Font = Enum.Font.Gotham,
        Text = config.Name or "Input",
        TextColor3 = Theme.TextSecondary,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    label.Parent = inputFrame
    
    local input = Utility:Create("TextBox", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 24),
        Position = UDim2.new(0, 0, 0, 20),
        Font = Enum.Font.Gotham,
        PlaceholderText = config.Placeholder or "Enter text...",
        PlaceholderColor3 = Theme.TextMuted,
        Text = config.Default or "",
        TextColor3 = Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    input.Parent = inputFrame
    
    input.FocusLost:Connect(function(enter)
        if config.Callback then config.Callback(input.Text) end
    end)
    
    return {
        Frame = inputFrame,
        GetValue = function() return input.Text end,
        SetValue = function(v) input.Text = v end,
    }
end

-- Dropdown Component
local function CreateDropdown(parent, config, window)
    local dropdown = Utility:Create("TextButton", {
        Name = "Dropdown",
        BackgroundColor3 = Theme.Card,
        Size = UDim2.new(1, 0, 0, 38),
        Text = "",
        AutoButtonColor = false,
    }, {
        Utility:Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
        Utility:Create("UIStroke", { Color = Theme.Border, Thickness = 1, Transparency = 0.5 }),
        Utility:Create("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) }),
    })
    dropdown.Parent = parent
    
    local label = Utility:Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -50, 1, 0),
        Font = Enum.Font.Gotham,
        Text = config.Name or "Dropdown",
        TextColor3 = Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    label.Parent = dropdown
    
    local valueLabel = Utility:Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 100, 1, 0),
        Position = UDim2.new(1, -100, 0, 0),
        Font = Enum.Font.Gotham,
        Text = "Select...",
        TextColor3 = Theme.TextSecondary,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Right,
    })
    valueLabel.Parent = dropdown
    
    local chevron = Utility:Create("ImageLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(1, -14, 0.5, -7),
        Image = GetIcon("lucide:chevron-down"),
        ImageColor3 = Theme.TextMuted,
    })
    chevron.Parent = dropdown
    
    -- Dropdown list
    local listVisible = false
    local listFrame = Utility:Create("Frame", {
        BackgroundColor3 = Theme.BackgroundLight,
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 1, 4),
        ZIndex = 100,
        Visible = false,
        AutomaticSize = Enum.AutomaticSize.Y,
    }, {
        Utility:Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
        Utility:Create("UIStroke", { Color = Theme.Border, Thickness = 1 }),
        Utility:Create("UIPadding", { PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4), PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4) }),
        Utility:Create("UIListLayout", { Padding = UDim.new(0, 2) }),
    })
    listFrame.Parent = dropdown
    
    local selectedValue = nil
    local values = config.Values or {}
    
    -- Player dropdown special type
    if config.SpecialType == "Player" then
        values = {}
        for _, player in ipairs(Players:GetPlayers()) do
            table.insert(values, player.Name)
        end
        
        Players.PlayerAdded:Connect(function(player)
            -- Could refresh list here
        end)
    end
    
    local function buildList()
        -- Clear existing
        for _, child in ipairs(listFrame:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        
        for _, val in ipairs(values) do
            local item = Utility:Create("TextButton", {
                BackgroundColor3 = Theme.Background,
                Size = UDim2.new(1, 0, 0, 30),
                Font = Enum.Font.Gotham,
                Text = "",
                TextColor3 = Theme.Text,
                TextSize = 12,
                AutoButtonColor = false,
            }, {
                Utility:Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
                Utility:Create("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }),
            })
            item.Parent = listFrame
            
            local itemLabel = Utility:Create("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Font = Enum.Font.Gotham,
                Text = val,
                TextColor3 = Theme.Text,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            itemLabel.Parent = item
            
            -- Player image
            if config.EnablePlayerImages then
                local image = Utility:Create("ImageLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, 20, 0, 20),
                    Position = UDim2.new(1, -24, 0.5, -10),
                    Image = "rbxasset://textures/ui/GuiImagePlaceholder.png",
                }, {
                    Utility:Create("UICorner", { CornerRadius = UDim.new(0, 4) })
                })
                image.Parent = item
                
                -- Load player headshot
                pcall(function()
                    local userId = Players:GetUserIdFromNameAsync(val)
                    local thumbType = Enum.ThumbnailType.HeadShot
                    local thumbUrl = Players:GetUserThumbnailAsync(userId, thumbType, Enum.ThumbnailSize.Size48x48)
                    image.Image = thumbUrl
                end)
            end
            
            item.MouseEnter:Connect(function()
                Utility:Tween(item, { BackgroundColor3 = Theme.CardHover }, 0.1)
            end)
            item.MouseLeave:Connect(function()
                Utility:Tween(item, { BackgroundColor3 = Theme.Background }, 0.1)
            end)
            
            item.MouseButton1Click:Connect(function()
                selectedValue = val
                valueLabel.Text = val
                valueLabel.TextColor3 = Theme.Accent
                
                if config.SpecialType == "Player" then
                    local player = Players:FindPlayer(val)
                    if config.Callback then config.Callback(player) end
                else
                    if config.Callback then config.Callback(val) end
                end
                
                -- Hide list
                listVisible = false
                listFrame.Visible = false
                Utility:Tween(chevron, { Rotation = 0 }, 0.15)
            end)
        end
    end
    buildList()
    
    dropdown.MouseButton1Click:Connect(function()
        listVisible = not listVisible
        listFrame.Visible = listVisible
        Utility:Tween(chevron, { Rotation = listVisible and 180 or 0 }, 0.15)
    end)
    
    return {
        Frame = dropdown,
        GetValue = function() return selectedValue end,
        SetValue = function(v) 
            selectedValue = v
            valueLabel.Text = v
            valueLabel.TextColor3 = Theme.Accent
        end,
        Refresh = buildList,
    }
end

-- Progress Bar Component
local function CreateProgressBar(parent, config)
    local bar = Utility:Create("Frame", {
        Name = "ProgressBar",
        BackgroundColor3 = Theme.Card,
        Size = UDim2.new(1, 0, 0, 50),
    }, {
        Utility:Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
        Utility:Create("UIStroke", { Color = Theme.Border, Thickness = 1, Transparency = 0.5 }),
        Utility:Create("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8) }),
    })
    bar.Parent = parent
    
    local label = Utility:Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 14),
        Font = Enum.Font.Gotham,
        Text = config.Name or "Progress",
        TextColor3 = Theme.TextSecondary,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    label.Parent = bar
    
    local pctLabel = Utility:Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 40, 0, 14),
        Position = UDim2.new(1, -40, 0, 0),
        Font = Enum.Font.GothamBold,
        Text = "0%",
        TextColor3 = Theme.Accent,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Right,
    })
    pctLabel.Parent = bar
    
    local track = Utility:Create("Frame", {
        BackgroundColor3 = Theme.BackgroundLight,
        Size = UDim2.new(1, 0, 0, 6),
        Position = UDim2.new(0, 0, 0, 22),
    }, {
        Utility:Create("UICorner", { CornerRadius = UDim.new(1, 0) })
    })
    track.Parent = bar
    
    local fill = Utility:Create("Frame", {
        BackgroundColor3 = config.Color or Theme.Accent,
        Size = UDim2.new(0, 0, 1, 0),
    }, {
        Utility:Create("UICorner", { CornerRadius = UDim.new(1, 0) })
    })
    fill.Parent = track
    
    local value = config.Value or 0
    
    return {
        Frame = bar,
        GetValue = function() return value end,
        SetValue = function(v)
            value = v
            local pct = math.clamp(v / 100, 0, 1)
            Utility:Tween(fill, { Size = UDim2.new(pct, 0, 1, 0) }, 0.2)
            pctLabel.Text = math.floor(v) .. "%"
        end,
        SetColor = function(c)
            fill.BackgroundColor3 = c
        end,
    }
end

-- Switch (Segmented) Component
local function CreateSwitch(parent, config)
    local switch = Utility:Create("Frame", {
        Name = "Switch",
        BackgroundColor3 = Theme.Card,
        Size = UDim2.new(1, 0, 0, 50),
    }, {
        Utility:Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
        Utility:Create("UIStroke", { Color = Theme.Border, Thickness = 1, Transparency = 0.5 }),
        Utility:Create("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8) }),
    })
    switch.Parent = parent
    
    local label = Utility:Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 14),
        Font = Enum.Font.Gotham,
        Text = config.Name or "Switch",
        TextColor3 = Theme.TextSecondary,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    label.Parent = switch
    
    local container = Utility:Create("Frame", {
        BackgroundColor3 = Theme.BackgroundLight,
        Size = UDim2.new(1, 0, 0, 28),
        Position = UDim2.new(0, 0, 0, 18),
    }, {
        Utility:Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
        Utility:Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 2),
        }),
    })
    container.Parent = switch
    
    local values = config.Values or {}
    local selected = config.Default or values[1]
    local buttons = {}
    
    for i, val in ipairs(values) do
        local btn = Utility:Create("TextButton", {
            BackgroundColor3 = (val == selected) and Theme.Accent or Theme.Background,
            Size = UDim2.new(1 / #values, -2, 1, 0),
            Font = Enum.Font.GothamBold,
            Text = val,
            TextColor3 = (val == selected) and Theme.White or Theme.TextSecondary,
            TextSize = 11,
            AutoButtonColor = false,
        }, {
            Utility:Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
        })
        btn.Parent = container
        buttons[val] = btn
        
        btn.MouseButton1Click:Connect(function()
            selected = val
            -- Update all buttons
            for v, b in pairs(buttons) do
                if v == selected then
                    Utility:Tween(b, { BackgroundColor3 = Theme.Accent }, 0.15)
                    b.TextColor3 = Theme.White
                else
                    Utility:Tween(b, { BackgroundColor3 = Theme.Background }, 0.15)
                    b.TextColor3 = Theme.TextSecondary
                end
            end
            if config.Callback then config.Callback(val) end
        end)
    end
    
    return {
        Frame = switch,
        GetValue = function() return selected end,
        SetValue = function(v)
            selected = v
            for val, b in pairs(buttons) do
                if val == selected then
                    Utility:Tween(b, { BackgroundColor3 = Theme.Accent }, 0.15)
                    b.TextColor3 = Theme.White
                else
                    Utility:Tween(b, { BackgroundColor3 = Theme.Background }, 0.15)
                    b.TextColor3 = Theme.TextSecondary
                end
            end
        end,
    }
end

-- RadioGroup Component
local function CreateRadioGroup(parent, config)
    local radio = Utility:Create("Frame", {
        Name = "RadioGroup",
        BackgroundColor3 = Theme.Card,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
    }, {
        Utility:Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
        Utility:Create("UIStroke", { Color = Theme.Border, Thickness = 1, Transparency = 0.5 }),
        Utility:Create("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8) }),
        Utility:Create("UIListLayout", { Padding = UDim.new(0, 6) }),
    })
    radio.Parent = parent
    
    local label = Utility:Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 14),
        Font = Enum.Font.Gotham,
        Text = config.Name or "Radio",
        TextColor3 = Theme.TextSecondary,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    label.Parent = radio
    
    local values = config.Values or {}
    local selected = config.Default or values[1]
    local circles = {}
    
    for _, val in ipairs(values) do
        local item = Utility:Create("TextButton", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 24),
            Text = "",
            AutoButtonColor = false,
        })
        item.Parent = radio
        
        local circle = Utility:Create("Frame", {
            BackgroundColor3 = Theme.BackgroundLight,
            Size = UDim2.new(0, 16, 0, 16),
            Position = UDim2.new(0, 0, 0.5, -8),
        }, {
            Utility:Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
            Utility:Create("UIStroke", { Color = (val == selected) and Theme.Accent or Theme.Border, Thickness = 2 }),
        })
        circle.Parent = item
        
        local dot = Utility:Create("Frame", {
            BackgroundColor3 = Theme.Accent,
            Size = UDim2.new(0, 8, 0, 8),
            Position = UDim2.new(0.5, -4, 0.5, -4),
            Visible = (val == selected),
        }, {
            Utility:Create("UICorner", { CornerRadius = UDim.new(1, 0) })
        })
        dot.Parent = circle
        
        local itemLabel = Utility:Create("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -24, 1, 0),
            Position = UDim2.new(0, 24, 0, 0),
            Font = Enum.Font.Gotham,
            Text = val,
            TextColor3 = Theme.Text,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
        })
        itemLabel.Parent = item
        
        circles[val] = { circle = circle, dot = dot }
        
        item.MouseButton1Click:Connect(function()
            selected = val
            for v, c in pairs(circles) do
                c.dot.Visible = (v == selected)
                c.circle.UIStroke.Color = (v == selected) and Theme.Accent or Theme.Border
            end
            if config.Callback then config.Callback(val) end
        end)
    end
    
    return {
        Frame = radio,
        GetValue = function() return selected end,
        SetValue = function(v)
            selected = v
            for val, c in pairs(circles) do
                c.dot.Visible = (val == selected)
                c.circle.UIStroke.Color = (val == selected) and Theme.Accent or Theme.Border
            end
        end,
    }
end

--========================================================
-- SECTION CLASS
--========================================================
local Section = {}
Section.__index = Section

function Section.new(tab, config)
    local self = setmetatable({}, Section)
    self.Tab = tab
    self.Config = config
    self.Window = tab.Window
    
    local container = tab.ContentCenter
    if config.Position == "Left" and tab.ContentLeft then
        container = tab.ContentLeft
    elseif config.Position == "Right" and tab.ContentRight then
        container = tab.ContentRight
    end
    
    self.Container = container
    
    -- Section frame
    self.Frame = Utility:Create("Frame", {
        Name = "Section_" .. (config.Name or "Section"),
        BackgroundColor3 = Theme.Card,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
    }, {
        Utility:Create("UICorner", { CornerRadius = UDim.new(0, 10) }),
        Utility:Create("UIStroke", { Color = Theme.Border, Thickness = 1, Transparency = 0.5 }),
        Utility:Create("UIPadding", {
            PaddingLeft = UDim.new(0, 14),
            PaddingRight = UDim.new(0, 14),
            PaddingTop = UDim.new(0, 14),
            PaddingBottom = UDim.new(0, 14),
        }),
        Utility:Create("UIListLayout", {
            Padding = UDim.new(0, 8),
        }),
    })
    self.Frame.Parent = container
    
    -- Section header
    local header = Utility:Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 20),
    }, {
        Utility:Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 6),
            VerticalAlignment = Enum.VerticalAlignment.Center,
        })
    })
    header.Parent = self.Frame
    
    local dot = Utility:Create("Frame", {
        BackgroundColor3 = Theme.Accent,
        Size = UDim2.new(0, 6, 0, 6),
    }, {
        Utility:Create("UICorner", { CornerRadius = UDim.new(1, 0) })
    })
    dot.Parent = header
    
    local title = Utility:Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -12, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = config.Name or "Section",
        TextColor3 = Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    title.Parent = header
    
    return self
end

function Section:AddButton(config)
    return CreateButton(self.Frame, config, self.Window)
end

function Section:AddToggle(config)
    return CreateToggle(self.Frame, config, self.Window)
end

function Section:AddTextInput(config)
    return CreateTextInput(self.Frame, config)
end

function Section:AddDropdown(config)
    return CreateDropdown(self.Frame, config, self.Window)
end

function Section:AddProgressBar(config)
    return CreateProgressBar(self.Frame, config)
end

function Section:AddSwitch(config)
    return CreateSwitch(self.Frame, config)
end

function Section:AddRadioGroup(config)
    return CreateRadioGroup(self.Frame, config)
end

function Section:AddViewport(config)
    return ViewportComponent.new(self.Frame, config)
end

function Section:AddSlider(config)
    -- Slider implementation
    local slider = Utility:Create("Frame", {
        Name = "Slider",
        BackgroundColor3 = Theme.Card,
        Size = UDim2.new(1, 0, 0, 50),
    }, {
        Utility:Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
        Utility:Create("UIStroke", { Color = Theme.Border, Thickness = 1, Transparency = 0.5 }),
        Utility:Create("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8) }),
    })
    slider.Parent = self.Frame
    
    local label = Utility:Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 14),
        Font = Enum.Font.Gotham,
        Text = config.Name or "Slider",
        TextColor3 = Theme.TextSecondary,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    label.Parent = slider
    
    local valueLabel = Utility:Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 50, 0, 14),
        Position = UDim2.new(1, -50, 0, 0),
        Font = Enum.Font.GothamBold,
        Text = tostring(config.Default or config.Min or 0),
        TextColor3 = Theme.Accent,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Right,
    })
    valueLabel.Parent = slider
    
    local track = Utility:Create("Frame", {
        BackgroundColor3 = Theme.BackgroundLight,
        Size = UDim2.new(1, 0, 0, 6),
        Position = UDim2.new(0, 0, 0, 22),
    }, {
        Utility:Create("UICorner", { CornerRadius = UDim.new(1, 0) })
    })
    track.Parent = slider
    
    local fill = Utility:Create("Frame", {
        BackgroundColor3 = Theme.Accent,
        Size = UDim2.new(0, 0, 1, 0),
    }, {
        Utility:Create("UICorner", { CornerRadius = UDim.new(1, 0) })
    })
    fill.Parent = track
    
    local knob = Utility:Create("Frame", {
        BackgroundColor3 = Theme.White,
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(0, 0, 0.5, -7),
    }, {
        Utility:Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
        Utility:Create("UIStroke", { Color = Theme.Accent, Thickness = 2 }),
    })
    knob.Parent = track
    
    local min = config.Min or 0
    local max = config.Max or 100
    local value = config.Default or min
    local dragging = false
    
    local function update(val)
        value = math.clamp(val, min, max)
        local pct = (value - min) / (max - min)
        fill.Size = UDim2.new(pct, 0, 1, 0)
        knob.Position = UDim2.new(pct, -7, 0.5, -7)
        valueLabel.Text = tostring(Utility:Round(value, config.Decimals or 0))
    end
    update(value)
    
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            local pct = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
            update(min + pct * (max - min))
            if config.Callback then config.Callback(value) end
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pct = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            update(min + pct * (max - min))
            if config.Callback then config.Callback(value) end
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    return {
        Frame = slider,
        GetValue = function() return value end,
        SetValue = function(v) update(v) end,
    }
end

--========================================================
-- TAB CLASS
--========================================================
local Tab = {}
Tab.__index = Tab

function Tab.new(window, config)
    local self = setmetatable({}, Tab)
    self.Window = window
    self.Config = config
    self.Sections = {}
    
    -- Tab button in sidebar
    self.TabButton = Utility:Create("TextButton", {
        Name = "Tab_" .. (config.Name or "Tab"),
        BackgroundColor3 = Theme.Background,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 36),
        Text = "",
        AutoButtonColor = false,
    }, {
        Utility:Create("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }),
        Utility:Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 8),
            VerticalAlignment = Enum.VerticalAlignment.Center,
        }),
    })
    self.TabButton.Parent = window.TabList
    
    local icon = Utility:Create("ImageLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 18, 0, 18),
        Image = GetIcon(config.Icon),
        ImageColor3 = Theme.TextSecondary,
    })
    icon.Parent = self.TabButton
    
    local label = Utility:Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -26, 1, 0),
        Font = Enum.Font.Gotham,
        Text = config.Name or "Tab",
        TextColor3 = Theme.TextSecondary,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    label.Parent = self.TabButton
    
    -- Badge
    self.BadgeFrame = Utility:Create("Frame", {
        BackgroundColor3 = Theme.Accent,
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(1, -4, 0, 2),
        Visible = false,
    }, {
        Utility:Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
    })
    self.BadgeFrame.Parent = self.TabButton
    
    self.BadgeLabel = Utility:Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = "",
        TextColor3 = Theme.White,
        TextSize = 9,
    })
    self.BadgeLabel.Parent = self.BadgeFrame
    
    self.Icon = icon
    self.Label = label
    
    -- Content page
    self.Page = Utility:Create("ScrollingFrame", {
        Name = "Page_" .. (config.Name or "Tab"),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Theme.Border,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
    }, {
        Utility:Create("UIPadding", {
            PaddingLeft = UDim.new(0, 16),
            PaddingRight = UDim.new(0, 16),
            PaddingTop = UDim.new(0, 16),
            PaddingBottom = UDim.new(0, 16),
        }),
    })
    
    -- Layout based on Type
    if config.Type == "Double" then
        -- Two columns
        local columns = Utility:Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
        }, {
            Utility:Create("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                Padding = UDim.new(0, 12),
            })
        })
        columns.Parent = self.Page
        
        self.ContentLeft = Utility:Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0.5, -6, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
        }, {
            Utility:Create("UIListLayout", { Padding = UDim.new(0, 12) })
        })
        self.ContentLeft.Parent = columns
        
        self.ContentRight = Utility:Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0.5, -6, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
        }, {
            Utility:Create("UIListLayout", { Padding = UDim.new(0, 12) })
        })
        self.ContentRight.Parent = columns
        
        self.ContentCenter = self.ContentLeft
    else
        self.ContentCenter = Utility:Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
        }, {
            Utility:Create("UIListLayout", { Padding = UDim.new(0, 12) })
        })
        self.ContentCenter.Parent = self.Page
    end
    
    self.Page.Parent = window.ContentContainer
    
    -- Tab selection
    self.TabButton.MouseButton1Click:Connect(function()
        window:SelectTab(self)
    end)
    
    -- Auto-select first tab
    if #window.Tabs == 0 then
        window:SelectTab(self)
    end
    
    return self
end

function Tab:AddSection(config)
    local section = Section.new(self, config)
    table.insert(self.Sections, section)
    return section
end

function Tab:SetBadge(show)
    self.BadgeFrame.Visible = show
end

function Tab:SetBadgeCount(count)
    if count then
        self.BadgeLabel.Text = tostring(count)
        self.BadgeFrame.Size = UDim2.new(0, count > 9 and 20 or 16, 0, 16)
    else
        self.BadgeLabel.Text = ""
        self.BadgeFrame.Size = UDim2.new(0, 8, 0, 8)
    end
end

function Tab:SetBadgeColor(color)
    self.BadgeFrame.BackgroundColor3 = color
end

--========================================================
-- WINDOW CLASS
--========================================================
local WindowClass = {}
WindowClass.__index = WindowClass

function WindowClass.new(config)
    local self = setmetatable({}, WindowClass)
    self.Config = config
    self.Tabs = {}
    
    local accentColor = config.Color or Theme.Accent
    
    -- ScreenGui
    self.ScreenGui = Utility:Create("ScreenGui", {
        Name = "FallensUI_" .. (config.Title or "Window"),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
    })
    Utility:ParentToGui(self.ScreenGui)
    
    -- Tooltip system
    self.Tooltip = TooltipSystem.new(self.ScreenGui)
    
    -- Notification system
    self.Notifications = NotificationSystem.new(self.ScreenGui)
    
    -- Dialog system
    self.Dialogs = DialogSystem.new(self)
    
    -- Main window
    self.Main = Utility:Create("Frame", {
        Name = "MainWindow",
        BackgroundColor3 = Theme.Background,
        BackgroundTransparency = config.Uitransparent or 0,
        Size = UDim2.new(0, 680, 0, 440),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ClipsDescendants = false,
    }, {
        Utility:Create("UICorner", { CornerRadius = UDim.new(0, 14) }),
        Utility:Create("UIStroke", {
            Color = Theme.Border,
            Thickness = 1,
        }),
    })
    self.Main.Parent = self.ScreenGui
    
    -- Shadow (gradient)
    local shadow = Utility:Create("ImageLabel", {
        Name = "Shadow",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 40, 1, 40),
        Position = UDim2.new(0, -20, 0, -20),
        ZIndex = -1,
        Image = "rbxassetid://1316045217",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(10, 10, 118, 118),
    })
    shadow.Parent = self.Main
    
    -- Draggable
    if config.Options and config.Options.Draggable ~= false then
        local dragBar = Utility:Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 40),
            ZIndex = 0,
        })
        dragBar.Parent = self.Main
        MakeDraggable(dragBar, self.Main)
    end
    
    -- Sidebar
    self.Sidebar = Utility:Create("Frame", {
        Name = "Sidebar",
        BackgroundColor3 = Theme.Sidebar,
        BackgroundTransparency = config.Uitransparent or 0,
        Size = UDim2.new(0, 200, 1, 0),
    }, {
        Utility:Create("UICorner", { CornerRadius = UDim.new(0, 14) }),
    })
    self.Sidebar.Parent = self.Main
    
    -- Sidebar content
    local sidebarContent = Utility:Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
    }, {
        Utility:Create("UIPadding", {
            PaddingLeft = UDim.new(0, 14),
            PaddingRight = UDim.new(0, 14),
            PaddingTop = UDim.new(0, 16),
            PaddingBottom = UDim.new(0, 16),
        }),
        Utility:Create("UIListLayout", { Padding = UDim.new(0, 0) }),
    })
    sidebarContent.Parent = self.Sidebar
    
    -- Logo/Header
    local header = Utility:Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 40),
    }, {
        Utility:Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 10),
            VerticalAlignment = Enum.VerticalAlignment.Center,
        })
    })
    header.Parent = sidebarContent
    
    local logo = Utility:Create("ImageLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 32, 0, 32),
        Image = config.Image or "rbxassetid://129080111323259",
    }, {
        Utility:Create("UICorner", { CornerRadius = UDim.new(0, 8) })
    })
    logo.Parent = header
    
    local titleCol = Utility:Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -42, 0, 40),
    }, {
        Utility:Create("UIListLayout", { Padding = UDim.new(0, 0) })
    })
    titleCol.Parent = header
    
    local title = Utility:Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = config.Title or "FallensUI",
        TextColor3 = Theme.Text,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    title.Parent = titleCol
    
    local subtitle = Utility:Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 16),
        Font = Enum.Font.Gotham,
        Text = config.Content or "",
        TextColor3 = Theme.TextMuted,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    subtitle.Parent = titleCol
    
    -- Separator
    local sep1 = Utility:Create("Frame", {
        BackgroundColor3 = Theme.Border,
        BackgroundTransparency = 0.5,
        Size = UDim2.new(1, 0, 0, 1),
    })
    sep1.Parent = sidebarContent
    
    -- Tab list
    self.TabList = Utility:Create("ScrollingFrame", {
        Name = "TabList",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, -120),
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, {
        Utility:Create("UIListLayout", { Padding = UDim.new(0, 4) }),
        Utility:Create("UIPadding", {
            PaddingTop = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10),
        }),
    })
    self.TabList.Parent = sidebarContent
    
    -- User info at bottom
    if config.ShowUser then
        local userFrame = Utility:Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 40),
        }, {
            Utility:Create("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                Padding = UDim.new(0, 8),
                VerticalAlignment = Enum.VerticalAlignment.Center,
            })
        })
        userFrame.Parent = sidebarContent
        
        local userAvatar = Utility:Create("ImageLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 28, 0, 28),
            Image = "rbxasset://textures/ui/GuiImagePlaceholder.png",
        }, {
            Utility:Create("UICorner", { CornerRadius = UDim.new(0, 6) })
        })
        userAvatar.Parent = userFrame
        
        -- Load avatar
        pcall(function()
            local thumbUrl = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
            userAvatar.Image = thumbUrl
        end)
        
        local userInfo = Utility:Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -36, 0, 40),
        }, {
            Utility:Create("UIListLayout", { Padding = UDim.new(0, 0) })
        })
        userInfo.Parent = userFrame
        
        local userName = Utility:Create("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 18),
            Font = Enum.Font.GothamBold,
            Text = LocalPlayer.DisplayName,
            TextColor3 = Theme.Text,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
        })
        userName.Parent = userInfo
        
        local userExec = Utility:Create("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 14),
            Font = Enum.Font.Gotham,
            Text = Utility:GetExecutor(),
            TextColor3 = Theme.TextMuted,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
        })
        userExec.Parent = userInfo
    end
    
    -- Content area
    self.ContentContainer = Utility:Create("Frame", {
        Name = "Content",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -200, 1, 0),
        Position = UDim2.new(0, 200, 0, 0),
    }, {
        Utility:Create("UIPadding", {
            PaddingLeft = UDim.new(0, 0),
            PaddingRight = UDim.new(0, 0),
            PaddingTop = UDim.new(0, 0),
            PaddingBottom = UDim.new(0, 0),
        }),
    })
    self.ContentContainer.Parent = self.Main
    
    -- Close button
    local closeBtn = Utility:Create("TextButton", {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -35, 0, 5),
        Font = Enum.Font.GothamBold,
        Text = "×",
        TextColor3 = Theme.TextMuted,
        TextSize = 20,
        AutoButtonColor = false,
    })
    closeBtn.Parent = self.Main
    
    closeBtn.MouseEnter:Connect(function()
        Utility:Tween(closeBtn, { TextColor3 = Theme.Danger }, 0.15)
    end)
    closeBtn.MouseLeave:Connect(function()
        Utility:Tween(closeBtn, { TextColor3 = Theme.TextMuted }, 0.15)
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        if config.Callbacks and config.Callbacks.OnClose then
            config.Callbacks.OnClose()
        end
        self.ScreenGui:Destroy()
    end)
    
    -- Changelog badge if always show tabs
    if config.AlwaysShowTab and config.Changelog then
        -- Could add a changelog notification here
    end
    
    -- Minimize button
    local minBtn = Utility:Create("TextButton", {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -65, 0, 5),
        Font = Enum.Font.GothamBold,
        Text = "—",
        TextColor3 = Theme.TextMuted,
        TextSize = 16,
        AutoButtonColor = false,
    })
    minBtn.Parent = self.Main
    
    local minimized = false
    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            Utility:Tween(self.Main, { Size = UDim2.new(0, 200, 0, 40) }, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
        else
            Utility:Tween(self.Main, { Size = UDim2.new(0, 680, 0, 440) }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        end
    end)
    
    return self
end

function WindowClass:SelectTab(tab)
    -- Hide all pages
    for _, t in ipairs(self.Tabs) do
        t.Page.Visible = false
        t.TabButton.BackgroundColor3 = Theme.Background
        t.TabButton.BackgroundTransparency = 1
        t.Icon.ImageColor3 = Theme.TextSecondary
        t.Label.TextColor3 = Theme.TextSecondary
    end
    
    -- Show selected
    tab.Page.Visible = true
    tab.TabButton.BackgroundColor3 = Theme.Card
    tab.TabButton.BackgroundTransparency = 0
    tab.Icon.ImageColor3 = Theme.Accent
    tab.Label.TextColor3 = Theme.Text
    
    -- Animate
    Utility:Tween(tab.TabButton, { BackgroundTransparency = 0 }, 0.15)
end

function WindowClass:AddTab(config)
    local tab = Tab.new(self, config)
    table.insert(self.Tabs, tab)
    return tab
end

function WindowClass:CreateHomeTab(config)
    local tab = self:AddTab({
        Name = config.Name or "Dashboard",
        Icon = config.Icon or "lucide:layout-dashboard",
    })
    
    local section = tab:AddSection({
        Name = config.Name or "Dashboard",
        Position = "Center",
    })
    
    -- Hero card
    local heroCard = Utility:Create("Frame", {
        BackgroundColor3 = Theme.BackgroundLight,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
    }, {
        Utility:Create("UICorner", { CornerRadius = UDim.new(0, 10) }),
        Utility:Create("UIPadding", {
            PaddingLeft = UDim.new(0, 16),
            PaddingRight = UDim.new(0, 16),
            PaddingTop = UDim.new(0, 16),
            PaddingBottom = UDim.new(0, 16),
        }),
        Utility:Create("UIListLayout", { Padding = UDim.new(0, 8) }),
    })
    heroCard.Parent = section.Frame
    
    local heroTitle = Utility:Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 24),
        Font = Enum.Font.GothamBold,
        Text = "Welcome to " .. (self.Config.Title or "FallensUI"),
        TextColor3 = Theme.Text,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    heroTitle.Parent = heroCard
    
    local heroDesc = Utility:Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        Font = Enum.Font.Gotham,
        Text = config.Content or "",
        TextColor3 = Theme.TextSecondary,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        AutomaticSize = Enum.AutomaticSize.Y,
    })
    heroDesc.Parent = heroCard
    
    -- Discord button
    if config.DiscordInvite then
        local discordBtn = Utility:Create("TextButton", {
            BackgroundColor3 = Color3.fromRGB(88, 101, 242),
            Size = UDim2.new(0, 140, 0, 34),
            Font = Enum.Font.GothamBold,
            Text = "Join Discord",
            TextColor3 = Theme.White,
            TextSize = 12,
            AutoButtonColor = false,
        }, {
            Utility:Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
        })
        discordBtn.Parent = heroCard
        
        discordBtn.MouseButton1Click:Connect(function()
            pcall(function()
                if setclipboard then
                    setclipboard("https://" .. config.DiscordInvite)
                end
            end)
        end)
    end
    
    -- Segments
    if config.Segments then
        for segName, segData in pairs(config.Segments) do
            if segData.Show ~= false then
                local segCard = Utility:Create("Frame", {
                    BackgroundColor3 = Theme.BackgroundLight,
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                }, {
                    Utility:Create("UICorner", { CornerRadius = UDim.new(0, 10) }),
                    Utility:Create("UIPadding", {
                        PaddingLeft = UDim.new(0, 14),
                        PaddingRight = UDim.new(0, 14),
                        PaddingTop = UDim.new(0, 12),
                        PaddingBottom = UDim.new(0, 12),
                    }),
                    Utility:Create("UIListLayout", { Padding = UDim.new(0, 6) }),
                })
                segCard.Parent = section.Frame
                
                local segHeader = Utility:Create("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 20),
                }, {
                    Utility:Create("UIListLayout", {
                        FillDirection = Enum.FillDirection.Horizontal,
                        Padding = UDim.new(0, 6),
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                    })
                })
                segHeader.Parent = segCard
                
                if segData.Icon then
                    local segIcon = Utility:Create("ImageLabel", {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0, 14, 0, 14),
                        Image = GetIcon(segData.Icon),
                        ImageColor3 = Theme.Accent,
                    })
                    segIcon.Parent = segHeader
                end
                
                local segTitle = Utility:Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -20, 0, 20),
                    Font = Enum.Font.GothamBold,
                    Text = segData.Text or segName,
                    TextColor3 = Theme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })
                segTitle.Parent = segHeader
            end
        end
    end
    
    -- Changelog
    if config.Changelog then
        for _, change in ipairs(config.Changelog) do
            local changeCard = Utility:Create("Frame", {
                BackgroundColor3 = Theme.BackgroundLight,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
            }, {
                Utility:Create("UICorner", { CornerRadius = UDim.new(0, 10) }),
                Utility:Create("UIPadding", {
                    PaddingLeft = UDim.new(0, 14),
                    PaddingRight = UDim.new(0, 14),
                    PaddingTop = UDim.new(0, 12),
                    PaddingBottom = UDim.new(0, 12),
                }),
                Utility:Create("UIListLayout", { Padding = UDim.new(0, 4) }),
            })
            changeCard.Parent = section.Frame
            
            local changeTitle = Utility:Create("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 18),
                Font = Enum.Font.GothamBold,
                Text = change.Title or "Update",
                TextColor3 = Theme.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            changeTitle.Parent = changeCard
            
            local changeDate = Utility:Create("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 14),
                Font = Enum.Font.Gotham,
                Text = change.Date or "",
                TextColor3 = Theme.Accent,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            changeDate.Parent = changeCard
            
            local changeDesc = Utility:Create("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 0),
                Font = Enum.Font.Gotham,
                Text = change.Description or "",
                TextColor3 = Theme.TextSecondary,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextWrapped = true,
                AutomaticSize = Enum.AutomaticSize.Y,
            })
            changeDesc.Parent = changeCard
        end
    end
    
    return tab
end

function WindowClass:Watermark(config)
    local wm = Utility:Create("Frame", {
        Name = "Watermark",
        BackgroundColor3 = Theme.Background,
        BackgroundTransparency = 0.2,
        Size = UDim2.new(0, 0, 0, 30),
        Position = UDim2.new(0, 20, 0, 20),
        AutomaticSize = Enum.AutomaticSize.X,
    }, {
        Utility:Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
        Utility:Create("UIStroke", { Color = Theme.Border, Thickness = 1, Transparency = 0.3 }),
        Utility:Create("UIPadding", {
            PaddingLeft = UDim.new(0, 12),
            PaddingRight = UDim.new(0, 12),
        }),
    })
    wm.Parent = self.ScreenGui
    
    local label = Utility:Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 0, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = "",
        TextColor3 = Theme.Text,
        TextSize = 12,
        AutomaticSize = Enum.AutomaticSize.X,
        TextXAlignment = Enum.TextXAlignment.Center,
    })
    label.Parent = wm
    
    -- Update watermark
    local fps = 60
    local frames = 0
    local lastTime = os.clock()
    
    RunService.RenderStepped:Connect(function()
        frames = frames + 1
        local now = os.clock()
        if now - lastTime >= 1 then
            fps = frames
            frames = 0
            lastTime = now
        end
        
        local text = config.Desc or "{NAME} | {TIME} | {FPS} FPS | {MS} ms"
        text = text:gsub("{NAME}", self.Config.Title or "FallensUI")
        text = text:gsub("{TIME}", Utility:GetTime())
        text = text:gsub("{FPS}", tostring(fps))
        text = text:gsub("{MS}", tostring(Utility:Round(stats.Workspace.Heartbeat:GetValue(), 0)))
        
        label.Text = text
    end)
    
    -- Make draggable
    MakeDraggable(wm)
    
    return wm
end

function WindowClass:Notify(config)
    self.Notifications:Notify(config)
end

function WindowClass:AddDialog(config)
    return self.Dialogs:AddDialog(config)
end

function WindowClass:ProgressDialog(config)
    return self.Dialogs:ProgressDialog(config)
end

function WindowClass:InputDialog(config)
    self.Dialogs:InputDialog(config)
end

--========================================================
-- MAIN LIBRARY
--========================================================
local FallensUI = {}

function FallensUI:Window(config)
    local window = WindowClass.new(config)
    
    -- Show key system if needed
    if config.KeySytem and not (config.Options and config.Options.Keyless) then
        local keySys = KeySystem.new(config)
        keySys:Show(window.ScreenGui, config.Callbacks or {})
    elseif config.Options and config.Options.Keyless then
        if config.Callbacks and config.Callbacks.OnSuccess then
            config.Callbacks.OnSuccess()
        end
    end
    
    return window
end

function FallensUI:AddLoading(config)
    return LoadingScreen.new(self._CurrentGui or CoreGui, config)
end

function FallensUI:SetCustomCursorEnabled(enabled)
    if enabled then
        -- Custom cursor implementation
        local cursor = Utility:Create("ImageLabel", {
            Name = "CustomCursor",
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 20, 0, 20),
            Image = "rbxassetid://129080111323259",
            ZIndex = 99999,
            Visible = true,
        })
        cursor.Parent = (self._CurrentGui or CoreGui)
        
        RunService.RenderStepped:Connect(function()
            local mousePos = UserInputService:GetMouseLocation()
            cursor.Position = UDim2.new(0, mousePos.X - 10, 0, mousePos.Y - 10)
        end)
        
        self._CustomCursor = cursor
    else
        if self._CustomCursor then
            self._CustomCursor:Destroy()
            self._CustomCursor = nil
        end
    end
end

-- Set theme
function FallensUI:SetTheme(themeTable)
    for k, v in pairs(themeTable) do
        if Theme[k] then
            Theme[k] = v
        end
    end
end

-- Return the library
return FallensUI
