--[[
    Aether UI
    Librería de interfaz moderna para Roblox
    - Pestañas en columna izquierda (sidebar)
    - Contenido a la derecha
    - Estilo limpio inspirado en Rayfield (mejorado)
    
    Creado para uso libre
]]

local Aether = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Tema
local Theme = {
    Background     = Color3.fromRGB(18, 18, 22),
    Sidebar        = Color3.fromRGB(14, 14, 17),
    Element        = Color3.fromRGB(28, 28, 34),
    ElementHover   = Color3.fromRGB(38, 38, 46),
    Text           = Color3.fromRGB(240, 240, 245),
    TextDark       = Color3.fromRGB(150, 150, 160),
    Stroke         = Color3.fromRGB(45, 45, 55),
    Accent         = Color3.fromRGB(0, 170, 255)
}

local function Create(class, props)
    local inst = Instance.new(class)
    for prop, value in pairs(props or {}) do
        inst[prop] = value
    end
    return inst
end

local function Tween(obj, goal, time)
    local tw = TweenService:Create(obj, TweenInfo.new(time or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), goal)
    tw:Play()
    return tw
end

function Aether:CreateWindow(config)
    config = config or {}
    local WindowName = config.Name or "Aether UI"
    local Accent = config.Theme or Theme.Accent
    local WindowSize = config.Size or UDim2.new(0, 620, 0, 430)

    -- Destroy previous
    if CoreGui:FindFirstChild("AetherUI") then
        CoreGui.AetherUI:Destroy()
    end

    local ScreenGui = Create("ScreenGui", {
        Name = "AetherUI",
        Parent = CoreGui,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })

    local Main = Create("Frame", {
        Name = "Main",
        Parent = ScreenGui,
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -WindowSize.X.Offset/2, 0.5, -WindowSize.Y.Offset/2),
        Size = WindowSize,
        ClipsDescendants = true
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = Main})
    Create("UIStroke", {Color = Theme.Stroke, Thickness = 1.2, Parent = Main})

    -- ========== SIDEBAR (Izquierda) ==========
    local Sidebar = Create("Frame", {
        Name = "Sidebar",
        Parent = Main,
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 155, 1, 0)
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = Sidebar})

    local Title = Create("TextLabel", {
        Parent = Sidebar,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 45),
        Font = Enum.Font.GothamBold,
        Text = WindowName,
        TextColor3 = Accent,
        TextSize = 16
    })

    local TabContainer = Create("ScrollingFrame", {
        Name = "Tabs",
        Parent = Sidebar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 50),
        Size = UDim2.new(1, 0, 1, -60),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Accent,
        BorderSizePixel = 0
    })

    local TabListLayout = Create("UIListLayout", {
        Parent = TabContainer,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5)
    })

    TabListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabContainer.CanvasSize = UDim2.new(0, 0, 0, TabListLayout.AbsoluteContentSize.Y + 15)
    end)

    -- ========== CONTENT (Derecha) ==========
    local Content = Create("Frame", {
        Name = "Content",
        Parent = Main,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 155, 0, 0),
        Size = UDim2.new(1, -155, 1, 0)
    })

    local ContentTitle = Create("TextLabel", {
        Parent = Content,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 18, 0, 14),
        Size = UDim2.new(1, -30, 0, 28),
        Font = Enum.Font.GothamBold,
        Text = "Inicio",
        TextColor3 = Theme.Text,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local Pages = Create("Folder", {Name = "Pages", Parent = Content})

    -- Drag
    local dragging, dragStart, startPos
    Main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    local Window = {}
    local Tabs = {}
    local Selected = nil

    function Window:CreateTab(name)
        local TabBtn = Create("TextButton", {
            Parent = TabContainer,
            BackgroundColor3 = Theme.Element,
            BorderSizePixel = 0,
            Size = UDim2.new(1, -12, 0, 34),
            Position = UDim2.new(0, 6, 0, 0),
            Font = Enum.Font.Gotham,
            Text = "   " .. name,
            TextColor3 = Theme.TextDark,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            AutoButtonColor = false
        })
        Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = TabBtn})

        local Indicator = Create("Frame", {
            Parent = TabBtn,
            BackgroundColor3 = Accent,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 3, 0.55, 0),
            Position = UDim2.new(0, 0, 0.225, 0),
            Visible = false
        })
        Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Indicator})

        local Page = Create("ScrollingFrame", {
            Name = name,
            Parent = Pages,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 15, 0, 50),
            Size = UDim2.new(1, -30, 1, -65),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Accent,
            Visible = false,
            BorderSizePixel = 0
        })

        local PageLayout = Create("UIListLayout", {
            Parent = Page,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 7)
        })

        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 20)
        end)

        local Tab = {
            Button = TabBtn,
            Page = Page
        }

        local function SelectTab()
            if Selected then
                Selected.Button.BackgroundColor3 = Theme.Element
                Selected.Button.TextColor3 = Theme.TextDark
                Selected.Button:FindFirstChildOfClass("Frame").Visible = false
                Selected.Page.Visible = false
            end
            Selected = Tab
            TabBtn.BackgroundColor3 = Theme.ElementHover
            TabBtn.TextColor3 = Theme.Text
            Indicator.Visible = true
            Page.Visible = true
            ContentTitle.Text = name
        end

        TabBtn.MouseButton1Click:Connect(SelectTab)

        TabBtn.MouseEnter:Connect(function()
            if Selected ~= Tab then
                Tween(TabBtn, {BackgroundColor3 = Theme.ElementHover})
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if Selected ~= Tab then
                Tween(TabBtn, {BackgroundColor3 = Theme.Element})
            end
        end)

        if #Tabs == 0 then
            SelectTab()
        end
        table.insert(Tabs, Tab)

        -- ==================== ELEMENTOS ====================

        function Tab:CreateSection(text)
            local Section = Create("TextLabel", {
                Parent = Page,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 26),
                Font = Enum.Font.GothamBold,
                Text = text,
                TextColor3 = Accent,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            return Section
        end

        function Tab:CreateLabel(text)
            local Label = Create("TextLabel", {
                Parent = Page,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 20),
                Font = Enum.Font.Gotham,
                Text = text,
                TextColor3 = Theme.TextDark,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextWrapped = true
            })
            return Label
        end

        function Tab:CreateButton(cfg)
            cfg = cfg or {}
            local Btn = Create("TextButton", {
                Parent = Page,
                BackgroundColor3 = Theme.Element,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 36),
                Font = Enum.Font.Gotham,
                Text = cfg.Name or "Button",
                TextColor3 = Theme.Text,
                TextSize = 13,
                AutoButtonColor = false
            })
            Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = Btn})

            Btn.MouseEnter:Connect(function()
                Tween(Btn, {BackgroundColor3 = Theme.ElementHover})
            end)
            Btn.MouseLeave:Connect(function()
                Tween(Btn, {BackgroundColor3 = Theme.Element})
            end)
            Btn.MouseButton1Click:Connect(function()
                if cfg.Callback then
                    cfg.Callback()
                end
            end)
            return Btn
        end

        -- ========== INTERRUPTOR (TOGGLE) ==========
        function Tab:CreateToggle(cfg)
            cfg = cfg or {}
            local Toggled = cfg.CurrentValue or false

            local Frame = Create("Frame", {
                Parent = Page,
                BackgroundColor3 = Theme.Element,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 40)
            })
            Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = Frame})

            local Title = Create("TextLabel", {
                Parent = Frame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0, 0),
                Size = UDim2.new(1, -70, 1, 0),
                Font = Enum.Font.Gotham,
                Text = cfg.Name or "Toggle",
                TextColor3 = Theme.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local SwitchBG = Create("Frame", {
                Parent = Frame,
                BackgroundColor3 = Color3.fromRGB(45, 45, 55),
                Position = UDim2.new(1, -54, 0.5, -11),
                Size = UDim2.new(0, 42, 0, 22)
            })
            Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = SwitchBG})

            local Circle = Create("Frame", {
                Parent = SwitchBG,
                BackgroundColor3 = Color3.fromRGB(220, 220, 230),
                Position = UDim2.new(0, 3, 0.5, -8),
                Size = UDim2.new(0, 16, 0, 16)
            })
            Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Circle})

            local function Update()
                if Toggled then
                    Tween(SwitchBG, {BackgroundColor3 = Accent})
                    Tween(Circle, {Position = UDim2.new(1, -19, 0.5, -8)})
                else
                    Tween(SwitchBG, {BackgroundColor3 = Color3.fromRGB(45, 45, 55)})
                    Tween(Circle, {Position = UDim2.new(0, 3, 0.5, -8)})
                end
            end
            Update()

            Frame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Toggled = not Toggled
                    Update()
                    if cfg.Callback then
                        cfg.Callback(Toggled)
                    end
                end
            end)

            return {
                Set = function(value)
                    Toggled = value
                    Update()
                end
            }
        end

        function Tab:CreateSlider(cfg)
            cfg = cfg or {}
            local Min = cfg.Range and cfg.Range[1] or 0
            local Max = cfg.Range and cfg.Range[2] or 100
            local Inc = cfg.Increment or 1
            local Value = cfg.CurrentValue or Min

            local Frame = Create("Frame", {
                Parent = Page,
                BackgroundColor3 = Theme.Element,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 54)
            })
            Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = Frame})

            local Title = Create("TextLabel", {
                Parent = Frame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0, 6),
                Size = UDim2.new(1, -80, 0, 18),
                Font = Enum.Font.Gotham,
                Text = cfg.Name or "Slider",
                TextColor3 = Theme.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local ValueText = Create("TextLabel", {
                Parent = Frame,
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -70, 0, 6),
                Size = UDim2.new(0, 58, 0, 18),
                Font = Enum.Font.Gotham,
                Text = tostring(Value),
                TextColor3 = Accent,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Right
            })

            local BarBG = Create("Frame", {
                Parent = Frame,
                BackgroundColor3 = Color3.fromRGB(40, 40, 50),
                Position = UDim2.new(0, 12, 0, 34),
                Size = UDim2.new(1, -24, 0, 6)
            })
            Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = BarBG})

            local Bar = Create("Frame", {
                Parent = BarBG,
                BackgroundColor3 = Accent,
                Size = UDim2.new((Value - Min) / (Max - Min), 0, 1, 0)
            })
            Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Bar})

            local sliding = false

            BarBG.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    sliding = true
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    sliding = false
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local pct = math.clamp((input.Position.X - BarBG.AbsolutePosition.X) / BarBG.AbsoluteSize.X, 0, 1)
                    local newVal = math.floor((Min + (Max - Min) * pct) / Inc + 0.5) * Inc
                    newVal = math.clamp(newVal, Min, Max)
                    Value = newVal
                    Bar.Size = UDim2.new((Value - Min) / (Max - Min), 0, 1, 0)
                    ValueText.Text = tostring(Value)
                    if cfg.Callback then
                        cfg.Callback(Value)
                    end
                end
            end)

            return {
                Set = function(v)
                    Value = math.clamp(v, Min, Max)
                    Bar.Size = UDim2.new((Value - Min) / (Max - Min), 0, 1, 0)
                    ValueText.Text = tostring(Value)
                end
            }
        end

        return Tab
    end

    return Window
end

return Aether
