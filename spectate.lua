local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Удаляем старый GUI если существует
if playerGui:FindFirstChild("TrioXSpectate") then
    playerGui.TrioXSpectate:Destroy()
end

-- Основной GUI
local SpectateGui = Instance.new("ScreenGui")
SpectateGui.Name = "TrioXSpectate"
SpectateGui.ResetOnSpawn = false
SpectateGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SpectateGui.Parent = playerGui

-- Переменные для хранения состояния
local lastSpectatedPlayer = nil
local highlightEnabled = false -- Сохраняем для будущих нужд, хотя кнопка убрана
local espEnabled = false
local playerHighlights = {}

-- Верхняя панель с кнопками
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Parent = SpectateGui
TopBar.BackgroundTransparency = 1
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.Position = UDim2.new(0, 0, 0, 0)
TopBar.Visible = false -- Изначально скрыта

-- Кнопка быстрой телепортации
local QuickTPBtn = Instance.new("TextButton")
QuickTPBtn.Name = "QuickTPBtn"
QuickTPBtn.Parent = TopBar
QuickTPBtn.BackgroundColor3 = Color3.fromRGB(120, 90, 200)
QuickTPBtn.BorderSizePixel = 0
QuickTPBtn.Position = UDim2.new(0.5, -100, 0, 5)
QuickTPBtn.Size = UDim2.new(0, 100, 0, 30)
QuickTPBtn.Font = Enum.Font.GothamBold
QuickTPBtn.Text = "TP"
QuickTPBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
QuickTPBtn.TextSize = 14

-- Кнопка ESP (белый контур)
local EspBtn = Instance.new("TextButton")
EspBtn.Name = "EspBtn"
EspBtn.Parent = TopBar
EspBtn.BackgroundColor3 = Color3.fromRGB(120, 90, 200)
EspBtn.BorderSizePixel = 0
EspBtn.Position = UDim2.new(0.5, 10, 0, 5)
EspBtn.Size = UDim2.new(0, 100, 0, 30)
EspBtn.Font = Enum.Font.GothamBold
EspBtn.Text = "ESP"
EspBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
EspBtn.TextSize = 14

-- Круглая кнопка активации
local Button = Instance.new("TextButton")
Button.Name = "Button"
Button.Parent = SpectateGui
Button.BackgroundColor3 = Color3.fromRGB(90, 70, 150)
Button.BorderSizePixel = 0
Button.Position = UDim2.new(0, 20, 0.5, -30)
Button.Size = UDim2.new(0, 60, 0, 60)
Button.Font = Enum.Font.GothamBold
Button.Text = "👁"
Button.TextColor3 = Color3.fromRGB(255, 255, 255)
Button.TextSize = 28
Button.TextScaled = true
Button.AutoButtonColor = false

-- Сделаем кнопку круглой
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = Button

-- Градиент для кнопки
local buttonGradient = Instance.new("UIGradient")
buttonGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(140, 100, 220)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(90, 70, 150))
}
buttonGradient.Rotation = 90
buttonGradient.Parent = Button

-- Панель управления
local Bar = Instance.new("Frame")
Bar.Name = "Bar"
Bar.Parent = SpectateGui
Bar.BackgroundColor3 = Color3.fromRGB(40, 35, 60)
Bar.BorderSizePixel = 0
Bar.Position = UDim2.new(0.5, -150, 0.85, -50)
Bar.Size = UDim2.new(0, 300, 0, 100)
Bar.Visible = false

-- Градиент для панели
local BarGradient = Instance.new("UIGradient")
BarGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 90, 200)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 60, 150))
}
BarGradient.Rotation = 90
BarGradient.Parent = Bar

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Parent = Bar
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, 0, 0.5, 0)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "Spectating: None"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.TextScaled = true
Title.TextStrokeColor3 = Color3.fromRGB(60, 40, 100)
Title.TextStrokeTransparency = 0.5

-- Кнопка следующего (теперь слева)
local Next = Instance.new("TextButton")
Next.Name = "Next"
Next.Parent = Bar
Next.BackgroundColor3 = Color3.fromRGB(120, 90, 200)
Next.BorderSizePixel = 0
Next.Position = UDim2.new(0.67, 0, 0.5, 0) -- Слева
Next.Size = UDim2.new(0.33, 0, 0.4, 0) -- Увеличена ширина
Next.Font = Enum.Font.GothamBold
Next.Text = ">"
Next.TextColor3 = Color3.fromRGB(255, 255, 255)
Next.TextSize = 32

-- Кнопка предыдущего (теперь справа)
local Previous = Instance.new("TextButton")
Previous.Name = "Previous"
Previous.Parent = Bar
Previous.BackgroundColor3 = Color3.fromRGB(120, 90, 200)
Previous.BorderSizePixel = 0
Previous.Position = UDim2.new(0, 0, 0.5, 0) -- Справа
Previous.Size = UDim2.new(0.33, 0, 0.4, 0) -- Увеличена ширина
Previous.Font = Enum.Font.GothamBold
Previous.Text = "<"
Previous.TextColor3 = Color3.fromRGB(255, 255, 255)
Previous.TextSize = 32

-- Градиенты для кнопок
local function setupGradient(button)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(160, 120, 240)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 90, 200))
    }
    gradient.Rotation = 90
    gradient.Parent = button
    return gradient
end

local gradients = {
    setupGradient(Previous),
    setupGradient(Next),
    setupGradient(QuickTPBtn),
    setupGradient(EspBtn)
}

-- Анимация градиентов
local function animateGradient(gradient)
    local ti = TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
    local offsetGoal = {Offset = Vector2.new(1, 0)}
    TweenService:Create(gradient, ti, offsetGoal):Play()
end

for _, gradient in ipairs(gradients) do
    animateGradient(gradient)
end
animateGradient(buttonGradient)
animateGradient(BarGradient)

-- Эффекты при наведении
local function setupButtonHover(button)
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = button.BackgroundColor3 * 1.2
    end)
    
    button.MouseLeave:Connect(function()
        if button == Button then
            button.BackgroundColor3 = Color3.fromRGB(90, 70, 150)
        else
            button.BackgroundColor3 = Color3.fromRGB(120, 90, 200)
        end
    end)
end

setupButtonHover(Button)
setupButtonHover(Previous)
setupButtonHover(Next)
setupButtonHover(QuickTPBtn)
setupButtonHover(EspBtn)

-- Основная логика спектрации
local cam = game.Workspace.CurrentCamera
local debounce = false
local isSpectating = false
local currentSpectateIndex = 0

local function getSpectatablePlayers()
    local spectatable = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= Players.LocalPlayer and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            table.insert(spectatable, p)
        end
    end
    return spectatable
end

local function updateTitle(targetName)
    Title.Text = "Spectating: " .. (targetName or "None")
end

local function spectatePlayer(playerToSpectate)
    if playerToSpectate and playerToSpectate.Character and playerToSpectate.Character:FindFirstChild("Humanoid") then
        cam.CameraSubject = playerToSpectate.Character.Humanoid
        updateTitle(playerToSpectate.Name)
        lastSpectatedPlayer = playerToSpectate
        return true
    end
    return false
end

local function cycleSpectate(direction) -- direction: 1 for next, -1 for previous
    local spectatable = getSpectatablePlayers()
    if #spectatable == 0 then
        updateTitle("No players to spectate")
        return
    end

    local currentTarget = Title.Text:match("Spectating: (.+)")
    local foundCurrent = false

    if currentTarget and lastSpectatedPlayer and lastSpectatedPlayer.Name == currentTarget then
        -- Попробуем найти текущего игрока в списке
        for i, p in ipairs(spectatable) do
            if p == lastSpectatedPlayer then
                currentSpectateIndex = i
                foundCurrent = true
                break
            end
        end
    end
    
    if not foundCurrent then
        -- Если текущий не найден или не установлен, начинаем с первого
        currentSpectateIndex = 0
    end

    currentSpectateIndex = currentSpectateIndex + direction

    if currentSpectateIndex > #spectatable then
        currentSpectateIndex = 1
    elseif currentSpectateIndex < 1 then
        currentSpectateIndex = #spectatable
    end
    
    spectatePlayer(spectatable[currentSpectateIndex])
end

-- Функция ESP (белый контур)
local function toggleESP()
    espEnabled = not espEnabled
    
    if espEnabled then
        EspBtn.BackgroundColor3 = Color3.fromRGB(200, 120, 240)
        
        -- Подсветка всех игроков белым контуром
        for _, p in ipairs(Players:GetPlayers()) do
            if p == player then continue end
            
            local char = p.Character
            if char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                if not playerHighlights[p] then
                    local h = Instance.new("Highlight")
                    h.Name = "PlayerESP"
                    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    h.FillTransparency = 1 -- Полностью прозрачная заливка
                    h.OutlineTransparency = 0.2
                    h.FillColor = Color3.fromRGB(255, 255, 255)
                    h.OutlineColor = Color3.fromRGB(255, 255, 255) -- Белый контур
                    h.Parent = char
                    playerHighlights[p] = h
                end
            end
        end
    else
        EspBtn.BackgroundColor3 = Color3.fromRGB(120, 90, 200)
        
        -- Удаляем ESP
        for p, highlight in pairs(playerHighlights) do
            if highlight and highlight.Name == "PlayerESP" then
                highlight:Destroy()
                playerHighlights[p] = nil
            end
        end
    end
end

-- Быстрая телепортация (закрывает наблюдение)
local function quickTeleport()
    if isSpectating then
        -- Выходим из режима спектрации
        Bar.Visible = false
        TopBar.Visible = false -- Скрываем верхнюю панель
        cam.CameraSubject = player.Character.Humanoid
        updateTitle("None")
        isSpectating = false
    end
    
    -- Телепортируем к текущей позиции камеры
    local targetCFrame = cam.CFrame
    local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
    local rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    
    if humanoid and rootPart then
        rootPart.CFrame = targetCFrame + targetCFrame.LookVector * 5
    end
end

-- Обработчики кнопок
Button.MouseButton1Click:Connect(function()
    if debounce then return end
    debounce = true
    
    if not isSpectating then
        -- Начать спектрацию
        Bar.Visible = true
        TopBar.Visible = true -- Показываем верхнюю панель
        
        -- Попробовать начать с последнего наблюдаемого игрока
        local targetFound = false
        if lastSpectatedPlayer then
            targetFound = spectatePlayer(lastSpectatedPlayer)
        end
        
        -- Если не нашли последнего или он недоступен, найти первого подходящего
        if not targetFound then
            cycleSpectate(1) -- Начать с первого доступного
        end
        
        isSpectating = true
    else
        -- Остановить спектрацию
        Bar.Visible = false
        TopBar.Visible = false -- Скрываем верхнюю панель
        cam.CameraSubject = player.Character.Humanoid
        updateTitle("None")
        isSpectating = false
    end
    
    debounce = false
end)

Next.MouseButton1Click:Connect(function()
    if not isSpectating then return end
    cycleSpectate(1)
end)

Previous.MouseButton1Click:Connect(function()
    if not isSpectating then return end
    cycleSpectate(-1)
end)

QuickTPBtn.MouseButton1Click:Connect(function()
    quickTeleport()
end)

EspBtn.MouseButton1Click:Connect(function()
    toggleESP()
end)

-- Перетаскивание панели
local dragging = false
local dragStart, startPos

Bar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Bar.Position
    end
end)

Bar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        Bar.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- Анимация кнопки при нажатии
Button.MouseButton1Down:Connect(function()
    TweenService:Create(Button, TweenInfo.new(0.1), {Size = UDim2.new(0, 55, 0, 55)}):Play()
end)

Button.MouseButton1Up:Connect(function()
    TweenService:Create(Button, TweenInfo.new(0.1), {Size = UDim2.new(0, 60, 0, 60)}):Play()
end)

-- Обработчик изменения игроков и автоматическое обновление ESP
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function(char)
        if espEnabled then
            -- Если ESP включен, сразу добавляем подсветку для нового игрока
            local h = Instance.new("Highlight")
            h.Name = "PlayerESP"
            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            h.FillTransparency = 1
            h.OutlineTransparency = 0.2
            h.FillColor = Color3.fromRGB(255, 255, 255)
            h.OutlineColor = Color3.fromRGB(255, 255, 255)
            h.Parent = char
            playerHighlights[p] = h
        end
    end)
end)

Players.PlayerRemoving:Connect(function(p)
    if playerHighlights[p] then
        playerHighlights[p]:Destroy()
        playerHighlights[p] = nil
    end
    -- Если удаленный игрок был текущим наблюдаемым, переключаемся на следующего
    if isSpectating and cam.CameraSubject == p.Character.Humanoid then
        cycleSpectate(1)
    end
end)

-- Автоматическое обновление ESP при изменении персонажей (например, после смерти/респуна)
RunService.Heartbeat:Connect(function()
    for p, highlight in pairs(playerHighlights) do
        if p and p.Character and highlight then
            -- Проверяем, что Highlight все еще привязан к нужному персонажу
            if highlight.Adornee ~= p.Character then
                highlight.Adornee = p.Character
            end
        else
            -- Если игрок или его персонаж больше не существуют, удаляем Highlight
            if highlight then highlight:Destroy() end
            playerHighlights[p] = nil
        end
    end

    -- Дополнительная проверка на живых персонажей для ESP, если игрок уже был добавлен
    if espEnabled then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player then
                local char = p.Character
                if char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                    if not playerHighlights[p] then
                        -- Добавляем Highlight, если его нет и игрок жив
                        local h = Instance.new("Highlight")
                        h.Name = "PlayerESP"
                        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        h.FillTransparency = 1
                        h.OutlineTransparency = 0.2
                        h.FillColor = Color3.fromRGB(255, 255, 255)
                        h.OutlineColor = Color3.fromRGB(255, 255, 255)
                        h.Parent = char
                        playerHighlights[p] = h
                    end
                elseif playerHighlights[p] then
                    -- Если игрок умер или персонаж пропал, удаляем Highlight
                    playerHighlights[p]:Destroy()
                    playerHighlights[p] = nil
                end
            end
        end
    end
end)

return SpectateGui
