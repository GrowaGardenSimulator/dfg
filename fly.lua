local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character
local humanoid

-- GUI Setup (Взято из красивого кода)
local mainGUI = Instance.new("ScreenGui")
mainGUI.Name = "TriOX_FlyGUI"
mainGUI.ResetOnSpawn = false
mainGUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Define Colors and Theme (Взято из красивого кода)
local colorSequence = {
    Color3.fromRGB(148, 0, 211),  -- Violet
    Color3.fromRGB(255, 165, 0),   -- Orange
    Color3.fromRGB(255, 105, 180), -- Pink
    Color3.fromRGB(0, 191, 255)    -- Blue
}
local currentColorIndex = 1
local colorTransitionTime = 2
local flyTitleLabel = nil -- Reference to the title label for color animation

local currentTheme = "Dark"
local themes = {
    Dark = {
        Background = Color3.fromRGB(40, 40, 40),
        Header = Color3.fromRGB(30, 30, 30),
        Button = Color3.fromRGB(60, 60, 60),
        ButtonHover = Color3.fromRGB(80, 80, 80),
        Text = Color3.fromRGB(255, 255, 255),
        CloseButton = Color3.fromRGB(200, 50, 50)
    },
    Light = {
        Background = Color3.fromRGB(240, 240, 240),
        Header = Color3.fromRGB(220, 220, 220),
        Button = Color3.fromRGB(200, 200, 200),
        ButtonHover = Color3.fromRGB(180, 180, 180),
        Text = Color3.fromRGB(0, 0, 0),
        CloseButton = Color3.fromRGB(255, 100, 100)
    }
}

-- Apply theme function (Взято из красивого кода)
local function applyTheme(theme, gui)
    local colors = themes[(theme == "Dark" and "Dark") or "Light"]
    for _, element in pairs(gui:GetDescendants()) do
        if element:IsA("Frame") then
            if element.Name == "Header" then
                element.BackgroundColor3 = colors.Header
            else
                element.BackgroundColor3 = colors.Background
            end
        elseif element:IsA("TextButton") or element:IsA("TextLabel") then
            element.TextColor3 = colors.Text
            if element:IsA("TextButton") then
                if element.Name == "CloseButton" then
                    element.BackgroundColor3 = colors.CloseButton
                else
                    element.BackgroundColor3 = colors.Button
                end
            end
        end
    end
end

-- Fly variables (Обновлено для работы с логикой "уродливого" кода)
local flyEnabled = false -- Соответствует 'nowe' из старого кода
local speeds = 1 -- Соответствует 'speeds' из старого кода
local tpwalking = false -- Для управления циклом движения WASD

-- Fly functions (Адаптировано из "уродливого" кода)
local function enableHumanoidStates()
    local hum = character and character:FindFirstChildOfClass("Humanoid")
    if hum then
        -- Включаем все стандартные состояния
        hum:SetStateEnabled(Enum.HumanoidStateType.Climbing,true)
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown,true)
        hum:SetStateEnabled(Enum.HumanoidStateType.Flying,true)
        hum:SetStateEnabled(Enum.HumanoidStateType.Freefall,true)
        hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp,true)
        hum:SetStateEnabled(Enum.HumanoidStateType.Jumping,true)
        hum:SetStateEnabled(Enum.HumanoidStateType.Landed,true)
        hum:SetStateEnabled(Enum.HumanoidStateType.Physics,true)
        hum:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding,true)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,true)
        hum:SetStateEnabled(Enum.HumanoidStateType.Running,true)
        hum:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics,true)
        hum:SetStateEnabled(Enum.HumanoidStateType.Seated,true)
        hum:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics,true)
        hum:SetStateEnabled(Enum.HumanoidStateType.Swimming,true)
        hum:ChangeState(Enum.HumanoidStateType.RunningNoPhysics) -- Возвращаемся к нормальному состоянию
        hum.PlatformStand = false -- Отключаем платформу

        -- Восстанавливаем анимации
        local animateScript = character:FindFirstChild("Animate")
        if animateScript then
            animateScript.Disabled = false
        end
        for _, track in pairs(hum:GetPlayingAnimationTracks()) do
            track:AdjustSpeed(1)
        end
    end
end

local function disableHumanoidStates()
    local hum = character and character:FindFirstChildOfClass("Humanoid")
    if hum then
        -- Отключаем почти все состояния
        hum:SetStateEnabled(Enum.HumanoidStateType.Climbing,false)
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Flying,false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Freefall,false)
        hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp,false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Jumping,false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Landed,false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Physics,false)
        hum:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding,false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Running,false)
        hum:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics,false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Seated,false)
        hum:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics,false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Swimming,false)
        hum:ChangeState(Enum.HumanoidStateType.Swimming) -- Чтобы избежать проблем с гравитацией
        hum.PlatformStand = true -- Включаем платформу для парения

        -- Отключаем анимации
        local animateScript = character:FindFirstChild("Animate")
        if animateScript then
            animateScript.Disabled = true
        end
        for _, track in pairs(hum:GetPlayingAnimationTracks()) do
            track:AdjustSpeed(0)
        end
    end
end

local function startFly()
    if flyEnabled then return end -- Уже летим
    flyEnabled = true

    disableHumanoidStates()

    -- Логика движения WASD из "уродливого" кода
    tpwalking = true
    for i = 1, speeds do -- Запускаем несколько потоков для стабильности, как в оригинале
        spawn(function()
            local hb = game:GetService("RunService").Heartbeat
            local chr = player.Character
            local hum = chr and chr:FindFirstChildOfClass("Humanoid")
            while tpwalking and hb:Wait() and chr and hum and hum.Parent do
                if hum.MoveDirection.Magnitude > 0 then
                    chr:TranslateBy(hum.MoveDirection * speeds) -- Умножаем на speeds
                end
            end
        end)
    end

    -- Логика BodyMovers для R6/R15 из "уродливого" кода (адаптирована)
    -- Эта часть кода будет работать только если Character RigType R6/R15,
    -- она является альтернативным способом управления движением.
    -- Поскольку мы используем TranslateBy, эту часть можно убрать,
    -- но я оставлю её как опцию, если TranslateBy будет нестабилен.
    -- Я немного упростил её, убрав лишние переменные.
    local rootPart = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
    if rootPart then
        local bg = Instance.new("BodyGyro", rootPart)
        bg.P = 9e4
        bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
        bg.cframe = rootPart.CFrame

        local bv = Instance.new("BodyVelocity", rootPart)
        bv.velocity = Vector3.new(0,0.1,0)
        bv.maxForce = Vector3.new(9e9, 9e9, 9e9)

        -- В оригинале здесь был бесконечный цикл. Мы не будем его использовать,
        -- так как это может конфликтовать с RenderStepped и TranslateBy.
        -- Вместо этого, BodyMovers будут просто висеть, пока не будут уничтожены.
        -- Однако, для WASD движения мы уже используем TranslateBy выше.
        -- Поэтому, если вы хотите использовать BodyMovers для WASD,
        -- вам нужно будет отключить TranslateBy и управлять bv.velocity здесь.
        -- Для простоты, мы сфокусируемся на TranslateBy.
    end
end

local function stopFly()
    if not flyEnabled then return end -- Не летим
    flyEnabled = false

    tpwalking = false -- Останавливаем цикл движения WASD

    enableHumanoidStates()

    -- Удаляем BodyMovers, если они были созданы (из "уродливого" кода)
    local rootPart = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
    if rootPart then
        local bg = rootPart:FindFirstChildOfClass("BodyGyro")
        local bv = rootPart:FindFirstChildOfClass("BodyVelocity")
        if bg then bg:Destroy() end
        if bv then bv:Destroy() end
    end
end

local function createFlyGUI()
    character = player.Character or player.CharacterAdded:Wait()
    humanoid = character:WaitForChild("Humanoid")
    mainGUI.Parent = player:WaitForChild("PlayerGui")

    -- Main Frame (Panel) (Взято из красивого кода)
    local panel = Instance.new("Frame")
    panel.Name = "FlyPanel"
    panel.Size = UDim2.new(0, 190, 0, 120)
    panel.Position = UDim2.new(0.5, -95, 0.5, -60) -- Centered
    panel.BackgroundColor3 = themes[currentTheme].Background
    panel.BorderSizePixel = 0
    panel.ClipsDescendants = true
    panel.Active = true
    panel.Parent = mainGUI

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = panel

    -- Header (Взято из красивого кода)
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 28)
    header.Position = UDim2.new(0, 0, 0, 0)
    header.BackgroundColor3 = themes[currentTheme].Header
    header.BorderSizePixel = 0
    header.Parent = panel

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 8)
    headerCorner.Parent = header

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(0.8, 0, 1, 0)
    title.Position = UDim2.new(0, 5, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "TriOX Fly"
    title.TextColor3 = colorSequence[1] -- Initial color
    title.TextSize = 14
    title.Font = Enum.Font.GothamMedium
    title.Parent = header
    flyTitleLabel = title -- Set the global reference for color animation

    -- Close Button (Взято из красивого кода)
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseButton"
    closeBtn.Size = UDim2.new(0, 28, 0, 28)
    closeBtn.Position = UDim2.new(1, -28, 0, 0)
    closeBtn.BackgroundColor3 = themes[currentTheme].CloseButton
    closeBtn.Text = "X"
    closeBtn.TextColor3 = themes[currentTheme].Text
    closeBtn.TextSize = 14
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = header

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeBtn

    closeBtn.MouseButton1Click:Connect(function()
        stopFly() -- Это очистит всё
        mainGUI:Destroy()
    end)

    -- Draggable functionality (Взято из красивого кода)
    local dragging = false
    local dragStart = Vector2.new()
    local startPos = UDim2.new()

    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = panel.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            panel.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    -- Fly controls (positioned relative to panel) (Взято из красивого кода)
    local flyToggleBtn = Instance.new("TextButton")
    flyToggleBtn.Name = "FlyToggle"
    flyToggleBtn.Parent = panel
    flyToggleBtn.BackgroundColor3 = themes[currentTheme].Button
    flyToggleBtn.Size = UDim2.new(0.35, 0, 0, 28)
    flyToggleBtn.Position = UDim2.new(0.6, 0, 0.65, 0) -- Adjusted position
    flyToggleBtn.Text = "Fly"
    flyToggleBtn.TextColor3 = themes[currentTheme].Text
    flyToggleBtn.TextSize = 14
    flyToggleBtn.Font = Enum.Font.GothamMedium

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 6)
    toggleCorner.Parent = flyToggleBtn

    local upBtn = Instance.new("TextButton")
    upBtn.Name = "UpButton"
    upBtn.Parent = panel
    upBtn.BackgroundColor3 = themes[currentTheme].Button
    upBtn.Size = UDim2.new(0.2, 0, 0, 28)
    upBtn.Position = UDim2.new(0.05, 0, 0.3, 0)
    upBtn.Text = "UP"
    upBtn.TextColor3 = themes[currentTheme].Text
    upBtn.TextSize = 14
    upBtn.Font = Enum.Font.GothamMedium

    local upCorner = Instance.new("UICorner")
    upCorner.CornerRadius = UDim.new(0, 6)
    upCorner.Parent = upBtn

    local downBtn = Instance.new("TextButton")
    downBtn.Name = "DownButton"
    downBtn.Parent = panel
    downBtn.BackgroundColor3 = themes[currentTheme].Button
    downBtn.Size = UDim2.new(0.2, 0, 0, 28)
    downBtn.Position = UDim2.new(0.05, 0, 0.65, 0)
    downBtn.Text = "DOWN"
    downBtn.TextColor3 = themes[currentTheme].Text
    downBtn.TextSize = 14
    downBtn.Font = Enum.Font.GothamMedium

    local downCorner = Instance.new("UICorner")
    downCorner.CornerRadius = UDim.new(0, 6)
    downCorner.Parent = downBtn

    local speedPlusBtn = Instance.new("TextButton")
    speedPlusBtn.Name = "SpeedPlus"
    speedPlusBtn.Parent = panel
    speedPlusBtn.BackgroundColor3 = themes[currentTheme].Button
    speedPlusBtn.Size = UDim2.new(0.2, 0, 0, 28)
    speedPlusBtn.Position = UDim2.new(0.3, 0, 0.3, 0)
    speedPlusBtn.Text = "+"
    speedPlusBtn.TextColor3 = themes[currentTheme].Text
    speedPlusBtn.TextSize = 18
    speedPlusBtn.Font = Enum.Font.GothamMedium

    local plusCorner = Instance.new("UICorner")
    plusCorner.CornerRadius = UDim.new(0, 6)
    plusCorner.Parent = speedPlusBtn

    local speedMinusBtn = Instance.new("TextButton")
    speedMinusBtn.Name = "SpeedMinus"
    speedMinusBtn.Parent = panel
    speedMinusBtn.BackgroundColor3 = themes[currentTheme].Button
    speedMinusBtn.Size = UDim2.new(0.2, 0, 0, 28)
    speedMinusBtn.Position = UDim2.new(0.3, 0, 0.65, 0)
    speedMinusBtn.Text = "-"
    speedMinusBtn.TextColor3 = themes[currentTheme].Text
    speedMinusBtn.TextSize = 18
    speedMinusBtn.Font = Enum.Font.GothamMedium

    local minusCorner = Instance.new("UICorner")
    minusCorner.CornerRadius = UDim.new(0, 6)
    minusCorner.Parent = speedMinusBtn

    local speedLabel = Instance.new("TextLabel")
    speedLabel.Name = "SpeedLabel"
    speedLabel.Parent = panel
    speedLabel.BackgroundColor3 = themes[currentTheme].Background
    speedLabel.BackgroundTransparency = 0
    speedLabel.Size = UDim2.new(0.2, 0, 0, 28)
    speedLabel.Position = UDim2.new(0.6, 0, 0.3, 0)
    speedLabel.Text = tostring(speeds) -- Отображаем текущую скорость
    speedLabel.TextColor3 = themes[currentTheme].Text
    speedLabel.TextSize = 14
    speedLabel.Font = Enum.Font.GothamMedium

    local speedLabelCorner = Instance.new("UICorner")
    speedLabelCorner.CornerRadius = UDim.new(0, 6)
    speedLabelCorner.Parent = speedLabel

    -- Обработчики кнопок (Адаптировано для логики "уродливого" кода)
    local upHoldConnection = nil
    local downHoldConnection = nil

    flyToggleBtn.MouseButton1Click:Connect(function()
        if not flyEnabled then
            startFly()
            flyToggleBtn.Text = "Stop Fly"
            flyToggleBtn.BackgroundColor3 = themes[currentTheme].CloseButton
        else
            stopFly()
            flyToggleBtn.Text = "Fly"
            flyToggleBtn.BackgroundColor3 = themes[currentTheme].Button
        end
    end)

    upBtn.MouseButton1Down:Connect(function()
        if flyEnabled then
            upHoldConnection = RunService.Heartbeat:Connect(function()
                if character and character:FindFirstChild("HumanoidRootPart") then
                    character.HumanoidRootPart.CFrame = character.HumanoidRootPart.CFrame * CFrame.new(0, 1 * speeds, 0) -- Умножаем на speeds
                end
            end)
        end
    end)
    upBtn.MouseButton1Up:Connect(function()
        if upHoldConnection then
            upHoldConnection:Disconnect()
            upHoldConnection = nil
        end
    end)
    upBtn.MouseLeave:Connect(function()
        if upHoldConnection then
            upHoldConnection:Disconnect()
            upHoldConnection = nil
        end
    end)

    downBtn.MouseButton1Down:Connect(function()
        if flyEnabled then
            downHoldConnection = RunService.Heartbeat:Connect(function()
                if character and character:FindFirstChild("HumanoidRootPart") then
                    character.HumanoidRootPart.CFrame = character.HumanoidRootPart.CFrame * CFrame.new(0, -1 * speeds, 0) -- Умножаем на speeds
                end
            end)
        end
    end)
    downBtn.MouseButton1Up:Connect(function()
        if downHoldConnection then
            downHoldConnection:Disconnect()
            downHoldConnection = nil
        end
    end)
    downBtn.MouseLeave:Connect(function()
        if downHoldConnection then
            downHoldConnection:Disconnect()
            downHoldConnection = nil
        end
    end)

    speedPlusBtn.MouseButton1Click:Connect(function()
        speeds = speeds + 1
        speedLabel.Text = tostring(speeds)
        -- Перезапускаем циклы TranslateBy для применения новой скорости
        if flyEnabled then
            tpwalking = false
            startFly() -- Перезапустит логику движения с новой скоростью
        end
    end)

    speedMinusBtn.MouseButton1Click:Connect(function()
        if speeds > 1 then
            speeds = speeds - 1
            speedLabel.Text = tostring(speeds)
            -- Перезапускаем циклы TranslateBy для применения новой скорости
            if flyEnabled then
                tpwalking = false
                startFly() -- Перезапустит логику движения с новой скоростью
            end
        else
            warn("Fly speed cannot be less than 1")
            speedLabel.Text = 'min speed'
            task.wait(1)
            speedLabel.Text = tostring(speeds)
        end
    end)

    -- Initial theme application
    applyTheme(currentTheme, mainGUI)
end

-- Animate title color (runs continuously as long as GUI exists) (Взято из красивого кода)
local colorTime = 0
RunService.Heartbeat:Connect(function(deltaTime)
    colorTime = colorTime + deltaTime
    if colorTime >= colorTransitionTime then
        colorTime = 0
        currentColorIndex = currentColorIndex % #colorSequence + 1
    end

    local progress = colorTime / colorTransitionTime
    local startIndex = currentColorIndex
    local endIndex = (currentColorIndex % #colorSequence) + 1
    local startColor = colorSequence[startIndex]
    local endColor = colorSequence[endIndex]

    local r = startColor.R + (endColor.R - startColor.R) * progress
    local g = startColor.G + (endColor.G - startColor.G) * progress
    local b = startColor.B + (endColor.B - startColor.B) * progress

    local currentColor = Color3.new(r, g, b)
    if flyTitleLabel then -- Use the global reference
        flyTitleLabel.TextColor3 = currentColor
    end
end)

-- Handle character spawning and respawning (Адаптировано)
player.CharacterAdded:Connect(function(char)
    character = char
    humanoid = char:WaitForChild("Humanoid")
    -- If GUI already exists (e.g. from previous character), clean up old one.
    if player.PlayerGui:FindFirstChild(mainGUI.Name) then
        player.PlayerGui:FindFirstChild(mainGUI.Name):Destroy()
    end
    -- Re-create GUI for new character
    createFlyGUI()
    stopFly() -- Ensure fly is off on new character
end)

-- Initial GUI creation if character is already loaded when script starts
if player.Character then
    createFlyGUI()
end
