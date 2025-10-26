game:GetService("StarterGui"):SetCore("SendNotification", {
	Title = "TriOX|Hub";
	Text = "by TriOX (141676) team";
	Icon = "rbxthumb://type=Asset&id=5107182114&w=150&h=150"})
Duration = 2;

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- Основной GUI
local mainGUI = Instance.new("ScreenGui")
mainGUI.Name = "TriOX|Hub"
mainGUI.ResetOnSpawn = false
mainGUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
mainGUI.Parent = player:WaitForChild("PlayerGui")

-- Цвета для анимации
local colorSequence = {
    Color3.fromRGB(148, 0, 211),  -- Фиолетовый
    Color3.fromRGB(255, 165, 0),   -- Оранжевый
    Color3.fromRGB(255, 105, 180), -- Розовый
    Color3.fromRGB(0, 191, 255)    -- Голубой
}

local currentColorIndex = 1
local colorTransitionTime = 2 -- Время перехода между цветами в секундах

-- Текущая тема
local currentTheme = "Dark"
local themes = {
    Dark = {
        Background = Color3.fromRGB(40, 40, 40),
        Header = Color3.fromRGB(30, 30, 30),
        Button = Color3.fromRGB(60, 60, 60),
        ButtonHover = Color3.fromRGB(80, 80, 80),
        Text = Color3.fromRGB(255, 255, 255),
        CloseButton = Color3.fromRGB(200, 50, 50),
        MinimizeButton = Color3.fromRGB(80, 80, 80),
        ExecuteButton = Color3.fromRGB(50, 150, 50),
        ClearButton = Color3.fromRGB(150, 50, 50),
        CodeBox = Color3.fromRGB(25, 25, 25)
    },
    Light = {
        Background = Color3.fromRGB(240, 240, 240),
        Header = Color3.fromRGB(220, 220, 220),
        Button = Color3.fromRGB(200, 200, 200),
        ButtonHover = Color3.fromRGB(180, 180, 180),
        Text = Color3.fromRGB(0, 0, 0),
        CloseButton = Color3.fromRGB(255, 100, 100),
        MinimizeButton = Color3.fromRGB(170, 170, 170),
        ExecuteButton = Color3.fromRGB(100, 200, 100),
        ClearButton = Color3.fromRGB(200, 100, 100),
        CodeBox = Color3.fromRGB(255, 255, 255)
    }
}

-- Функция применения темы
local function applyTheme(theme)
    currentTheme = theme
    local colors = themes[theme]
    
    for _, element in pairs(mainGUI:GetDescendants()) do
        if element:IsA("Frame") then
            if element.Name == "Header" then
                element.BackgroundColor3 = colors.Header
            else
                element.BackgroundColor3 = colors.Background
            end
        elseif element:IsA("TextButton") or element:IsA("TextLabel") or element:IsA("TextBox") then
            element.TextColor3 = colors.Text
            if element:IsA("TextButton") then
                if element.Name == "CloseButton" then
                    element.BackgroundColor3 = colors.CloseButton
                elseif element.Name == "MinimizeButton" then
                    element.BackgroundColor3 = colors.MinimizeButton
                elseif element.Name == "ExecuteButton" then
                    element.BackgroundColor3 = colors.ExecuteButton
                elseif element.Name == "ClearButton" then
                    element.BackgroundColor3 = colors.ClearButton
                elseif element.Name:find("Button") then
                    element.BackgroundColor3 = colors.Button
                end
            elseif element.Name == "CodeBox" then
                element.BackgroundColor3 = colors.CodeBox
            end
        end
    end
end

-- Функция создания фрейма
local function createFrame(name, size, position)
    local frame = Instance.new("Frame")
    frame.Name = name
    frame.Size = size
    frame.Position = position
    frame.BackgroundColor3 = themes[currentTheme].Background
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = true
    frame.Active = true
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    return frame
end

-- Создаем главное окно
-- Уменьшаем размер на 30%:
-- Ширина: 250 * 0.7 = 175
-- Высота: 350 * 0.7 = 245
-- Новое положение для центрирования:
-- X: 0.5, -175 / 2 = 0.5, -87.5
-- Y: 0.5, -245 / 2 = 0.5, -122.5
local mainFrame = createFrame("MainFrame", UDim2.new(0, 175, 0, 245), UDim2.new(0.5, -87.5, 0.5, -122.5))
mainFrame.Parent = mainGUI

-- Заголовок с кнопками управления
local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 28)
header.Position = UDim2.new(0, 0, 0, 0)
header.BackgroundColor3 = themes[currentTheme].Header
header.BorderSizePixel = 0

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 8)
headerCorner.Parent = header

local title = Instance.new("TextLabel")
title.Name = "Title"
-- ИЗМЕНЕНО: Смещение заголовка влево и уменьшение ширины для предотвращения перекрытия
title.Size = UDim2.new(0.6, 0, 1, 0) -- Уменьшена ширина, чтобы дать место для кнопок
title.Position = UDim2.new(0, 5, 0, 0) -- Смещение влево (5 пикселей отступ)
title.BackgroundTransparency = 1
title.Text = "TriOX Hub"
title.TextColor3 = colorSequence[1] -- Начальный цвет
title.TextSize = 14
title.Font = Enum.Font.GothamMedium
title.Parent = header

-- Кнопка закрыть
local closeBtn = Instance.new("TextButton")
closeBtn.Name = "CloseButton"
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -28, 0, 0)
closeBtn.BackgroundColor3 = themes[currentTheme].CloseButton
closeBtn.Text = "X"
closeBtn.TextColor3 = themes[currentTheme].Text
closeBtn.TextSize = 14
closeBtn.Font = Enum.Font.GothamBold

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
    mainGUI:Destroy()
end)

-- Кнопка свернуть
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Name = "MinimizeButton"
minimizeBtn.Size = UDim2.new(0, 28, 0, 28)
minimizeBtn.Position = UDim2.new(1, -56, 0, 0)
minimizeBtn.BackgroundColor3 = themes[currentTheme].MinimizeButton
minimizeBtn.Text = "_"
minimizeBtn.TextColor3 = themes[currentTheme].Text
minimizeBtn.TextSize = 14
minimizeBtn.Font = Enum.Font.GothamBold

local minimizeCorner = Instance.new("UICorner")
minimizeCorner.CornerRadius = UDim.new(0, 8)
minimizeCorner.Parent = minimizeBtn

-- Большая круглая кнопка для разворачивания (60x60)
local unfoldBtn = Instance.new("TextButton")
unfoldBtn.Name = "UnfoldButton"
unfoldBtn.Size = UDim2.new(0, 60, 0, 60)
unfoldBtn.Position = UDim2.new(0, 10, 0, 10)
unfoldBtn.BackgroundColor3 = colorSequence[1] -- Начальный цвет
unfoldBtn.TextColor3 = Color3.new(1, 1, 1)
unfoldBtn.Text = "T"
unfoldBtn.TextSize = 24
unfoldBtn.Visible = false
unfoldBtn.ZIndex = 10

local unfoldCorner = Instance.new("UICorner")
unfoldCorner.CornerRadius = UDim.new(1, 0)
unfoldCorner.Parent = unfoldBtn

minimizeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    unfoldBtn.Visible = true
end)

unfoldBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = true
    unfoldBtn.Visible = false
end)

header.Parent = mainFrame
closeBtn.Parent = header
minimizeBtn.Parent = header
unfoldBtn.Parent = mainGUI

-- Кнопка смены темы
local themeBtn = Instance.new("TextButton")
themeBtn.Name = "ThemeButton"
themeBtn.Size = UDim2.new(0, 28, 0, 28)
themeBtn.Position = UDim2.new(1, -84, 0, 0)
themeBtn.BackgroundColor3 = themes[currentTheme].Button
themeBtn.TextColor3 = themes[currentTheme].Text
themeBtn.Text = "☀"
themeBtn.TextSize = 14
themeBtn.Font = Enum.Font.GothamBold

local themeCorner = Instance.new("UICorner")
themeCorner.CornerRadius = UDim.new(0, 8)
themeCorner.Parent = themeBtn

themeBtn.MouseButton1Click:Connect(function()
    if currentTheme == "Dark" then
        applyTheme("Light")
        themeBtn.Text = "🌑"
    else
        applyTheme("Dark")
        themeBtn.Text = "☀"
    end
end)

themeBtn.Parent = header

-- Кнопка Executor (опущена ниже)
local executorBtn = Instance.new("TextButton")
executorBtn.Name = "ExecutorButton"
executorBtn.Size = UDim2.new(0.8, 0, 0, 35)
executorBtn.Position = UDim2.new(0.1, 0, 1, -50) -- Опущена ниже
executorBtn.BackgroundColor3 = colorSequence[1] -- Начальный цвет
executorBtn.TextColor3 = Color3.new(1, 1, 1)
executorBtn.Text = "Executor"
executorBtn.TextSize = 16

local executorCorner = Instance.new("UICorner")
executorCorner.CornerRadius = UDim.new(0, 6)
executorCorner.Parent = executorBtn

-- Executor окно
-- Уменьшаем размер на 30%:
-- Ширина: 350 * 0.7 = 245
-- Высота: 350 * 0.7 = 245
-- Новое положение для центрирования:
-- X: 0.5, -245 / 2 = 0.5, -122.5
-- Y: 0.5, -245 / 2 = 0.5, -122.5
local executorFrame = createFrame("ExecutorFrame", UDim2.new(0, 245, 0, 245), UDim2.new(0.5, -122.5, 0.5, -122.5))
executorFrame.Visible = false
executorFrame.Parent = mainGUI

-- Заголовок Executor
local executorHeader = Instance.new("Frame")
executorHeader.Name = "Header"
executorHeader.Size = UDim2.new(1, 0, 0, 28)
executorHeader.Position = UDim2.new(0, 0, 0, 0)
executorHeader.BackgroundColor3 = themes[currentTheme].Header
executorHeader.BorderSizePixel = 0

local executorHeaderCorner = Instance.new("UICorner")
executorHeaderCorner.CornerRadius = UDim.new(0, 8)
executorHeaderCorner.Parent = executorHeader

local executorTitle = Instance.new("TextLabel")
executorTitle.Name = "Title"
executorTitle.Size = UDim2.new(0.5, 0, 1, 0)
executorTitle.Position = UDim2.new(0.25, 0, 0, 0)
executorTitle.BackgroundTransparency = 1
executorTitle.Text = "Executor"
executorTitle.TextColor3 = themes[currentTheme].Text
executorTitle.TextSize = 14
executorTitle.Font = Enum.Font.GothamMedium
executorTitle.Parent = executorHeader

-- Кнопка закрыть для Executor
local executorCloseBtn = closeBtn:Clone()
executorCloseBtn.Parent = executorHeader
executorCloseBtn.MouseButton1Click:Connect(function()
    executorFrame.Visible = false
end)

executorHeader.Parent = executorFrame

-- Текстовое поле для кода
local codeBox = Instance.new("TextBox")
codeBox.Name = "CodeBox"
codeBox.Size = UDim2.new(1, -20, 0.7, -10)
codeBox.Position = UDim2.new(0, 10, 0, 35)
codeBox.BackgroundColor3 = themes[currentTheme].CodeBox
codeBox.TextColor3 = themes[currentTheme].Text
codeBox.Text = "-- Введите ваш скрипт здесь"
codeBox.TextSize = 14
codeBox.TextXAlignment = Enum.TextXAlignment.Left
codeBox.TextYAlignment = Enum.TextYAlignment.Top
codeBox.ClearTextOnFocus = false
codeBox.MultiLine = true
codeBox.Font = Enum.Font.Code
codeBox.Parent = executorFrame

local codeBoxCorner = Instance.new("UICorner")
codeBoxCorner.CornerRadius = UDim.new(0, 6)
codeBoxCorner.Parent = codeBox

-- Кнопка Execute
local executeBtn = Instance.new("TextButton")
executeBtn.Name = "ExecuteButton"
executeBtn.Size = UDim2.new(0.45, 0, 0, 35)
executeBtn.Position = UDim2.new(0.05, 0, 0.85, 0)
executeBtn.BackgroundColor3 = themes[currentTheme].ExecuteButton
executeBtn.TextColor3 = themes[currentTheme].Text
executeBtn.Text = "Execute"
executeBtn.TextSize = 16

local executeCorner = Instance.new("UICorner")
executeCorner.CornerRadius = UDim.new(0, 6)
executeCorner.Parent = executeBtn

executeBtn.MouseButton1Click:Connect(function()
    local code = codeBox.Text
    local fn, err = loadstring(code)
    if fn then
        pcall(fn)
    else
        warn("Ошибка выполнения: "..tostring(err))
    end
end)

-- Кнопка Clear
local clearBtn = Instance.new("TextButton")
clearBtn.Name = "ClearButton"
clearBtn.Size = UDim2.new(0.45, 0, 0, 35)
clearBtn.Position = UDim2.new(0.5, 0, 0.85, 0)
clearBtn.BackgroundColor3 = themes[currentTheme].ClearButton
clearBtn.TextColor3 = themes[currentTheme].Text
clearBtn.Text = "Clear"
clearBtn.TextSize = 16

local clearCorner = Instance.new("UICorner")
clearCorner.CornerRadius = UDim.new(0, 6)
clearCorner.Parent = clearBtn

clearBtn.MouseButton1Click:Connect(function()
    codeBox.Text = ""
end)

executorBtn.Parent = mainFrame
executeBtn.Parent = executorFrame
clearBtn.Parent = executorFrame

-- Открытие Executor
executorBtn.MouseButton1Click:Connect(function()
    executorFrame.Visible = not executorFrame.Visible
end)

-- Функция перетаскивания
local function makeDraggable(frame, handle)
    local dragging, dragInput, dragStart, startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
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
    
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            update(input)
        end
    end)
end

-- Делаем перетаскиваемыми
makeDraggable(mainFrame, header)
makeDraggable(executorFrame, executorHeader)
makeDraggable(unfoldBtn, unfoldBtn)

-- Контент главного окна
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name = "ScrollFrame"
scrollFrame.Size = UDim2.new(1, -10, 1, -120)
scrollFrame.Position = UDim2.new(0, 5, 0, 35)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 6
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.Parent = mainFrame

local content = Instance.new("Frame")
content.Name = "Content"
content.Size = UDim2.new(1, 0, 0, 0)
content.BackgroundTransparency = 1
content.Parent = scrollFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 8)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = content

-- Настраиваемые кнопки
local customButtons = {
    {
        name = "Fly Gui",
        func = function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/GrowaGardenSimulator/dfg/refs/heads/main/fly.lua'))()

        end
    },
    {
        name = "Infinite yeld",
        func = function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
        end
    },
    {
        name = "Telekinesis",
        func = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/GrowaGardenSimulator/dfg/refs/heads/main/Telekinesis.lua"))()
        end
    },
    {
        name = "Find part",
        func = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/GrowaGardenSimulator/dfg/refs/heads/main/find.lua"))()
        end
    },
    {
        name = "spectate [new!]",
        func = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/GrowaGardenSimulator/dfg/refs/heads/main/spectate.lua"))()
        end
    }
}

-- Создаем кнопки
for i, btnData in ipairs(customButtons) do
    local btn = Instance.new("TextButton")
    btn.Name = "CustomButton_"..i
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.BackgroundColor3 = themes[currentTheme].Button
    btn.TextColor3 = themes[currentTheme].Text
    btn.Text = btnData.name
    btn.TextSize = 14
    btn.LayoutOrder = i
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    
    -- Анимации
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundColor3 = themes[currentTheme].ButtonHover
        }):Play()
    end)
    
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundColor3 = themes[currentTheme].Button
        }):Play()
    end)
    
    -- Действие
    btn.MouseButton1Click:Connect(btnData.func)
    
    btn.Parent = content
end

-- Автоподстройка скролла
listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
end)

-- Анимация цветов
local colorTime = 0
RunService.Heartbeat:Connect(function(deltaTime)
    colorTime = colorTime + deltaTime
    if colorTime >= colorTransitionTime then
        colorTime = 0
        currentColorIndex = currentColorIndex % #colorSequence + 1
    end
    
    local progress = colorTime / colorTransitionTime
    local startColor = colorSequence[currentColorIndex]
    local endColor = colorSequence[currentColorIndex % #colorSequence + 1]
    
    local r = startColor.R + (endColor.R - startColor.R) * progress
    local g = startColor.G + (endColor.G - startColor.G) * progress
    local b = startColor.B + (endColor.B - startColor.B) * progress
    
    local currentColor = Color3.new(r, g, b)
    
    -- Применяем цвет к элементам
    executorBtn.BackgroundColor3 = currentColor
    unfoldBtn.BackgroundColor3 = currentColor
    title.TextColor3 = currentColor
end)

-- Применяем тему по умолчанию
applyTheme(currentTheme)
