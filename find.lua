local Players = game:GetService("Players")

local RunService = game:GetService("RunService")

local UserInputService = game:GetService("UserInputService") -- For Drag and Drop GUI

local player = Players.LocalPlayer

local character

local humanoidRootPart

-- Function to get the character and HumanoidRootPart

local function getCharacterAndHumanoidRootPart()

    character = player.Character

    if not character then

        character = player.CharacterAdded:Wait()

    end

    humanoidRootPart = character:WaitForChild("HumanoidRootPart")

end

getCharacterAndHumanoidRootPart() -- Initial call

-- Connect to the character added event (after death/respawn)

player.CharacterAdded:Connect(function(char)

    character = char

    humanoidRootPart = char:WaitForChild("HumanoidRootPart")

    -- If there was active highlighting, clear it on respawn

    cleanupExistingHighlights()

end)

-- Stored values

local highlightTarget = "Items" -- Default value

local currentHighlightColor = Color3.fromRGB(0, 255, 0)

local currentBillboardOffset = Vector3.new(0, 3, 0) -- Default offset for Billboard

-- Toggle settings

local showDistance = true

local showName = true

-- Highlighting functionality

local activeHighlights = {} -- Stores active highlights for cleanup

local activeBillboards = {} -- Stores active BillboardGuis for cleanup

local heartbeatConnection = nil -- Connection for Heartbeat

local function cleanupExistingHighlights()

    if heartbeatConnection then

        heartbeatConnection:Disconnect()

        heartbeatConnection = nil

    end

    for _, highlight in pairs(activeHighlights) do

        if highlight and highlight.Parent then

            highlight:Destroy()

        end

    end

    table.clear(activeHighlights)

    for _, billboard in pairs(activeBillboards) do

        if billboard and billboard.Parent then

            billboard:Destroy()

        end

    end

    table.clear(activeBillboards)

    print("Existing highlights cleared.")

end

local function createBillboard(item, distanceText, offset)

    local billboard = Instance.new("BillboardGui")

    billboard.Name = "ItemInfo"

    billboard.Adornee = item

    billboard.Size = UDim2.new(0, 200, 0, 50)

    billboard.StudsOffset = offset

    billboard.AlwaysOnTop = true

    billboard.LightInfluence = 0

    billboard.MaxDistance = 100 -- Make configurable in the future?

    local textLabel = Instance.new("TextLabel")

    textLabel.Name = "TextLabel"

    textLabel.Size = UDim2.new(1, 0, 1, 0)

    textLabel.BackgroundTransparency = 1

    textLabel.Text = distanceText

    textLabel.TextColor3 = Color3.new(1, 1, 1)

    textLabel.TextStrokeTransparency = 0

    textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)

    textLabel.Font = Enum.Font.SourceSansBold

    textLabel.TextSize = 14

    textLabel.Parent = billboard

    billboard.Parent = item

    return billboard

end

local function highlightItem(item, color)

    if not item:IsA("BasePart") then return end

    local highlight = Instance.new("Highlight")

    highlight.Name = "ItemHighlight"

    highlight.FillColor = color

    highlight.OutlineColor = color

    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

    highlight.Parent = item

    return highlight

end

local function applyHighlighting()

    cleanupExistingHighlights()

    local itemsToHighlight = {}

    if highlightTarget == "" then

        warn("Highlight target not specified.")

        return

    end

    -- Attempt to find the object by full path (e.g., workspace.Items)

    local foundObject = game:GetService("Workspace"):FindFirstChild(highlightTarget)

    if foundObject then

        if foundObject:IsA("Model") or foundObject:IsA("Folder") then

            for _, item in ipairs(foundObject:GetDescendants()) do

                if item:IsA("BasePart") then

                    table.insert(itemsToHighlight, item)

                end

            end

        elseif foundObject:IsA("BasePart") then

            table.insert(itemsToHighlight, foundObject)

        end

    else

        -- If not found by full path, search by partial name among all BaseParts

        local lowerCaseTarget = string.lower(highlightTarget)

        for _, obj in pairs(game:GetService("Workspace"):GetDescendants()) do

            if obj:IsA("BasePart") and string.find(string.lower(obj.Name), lowerCaseTarget, 1, true) then

                table.insert(itemsToHighlight, obj)

            end

        end

    end

    if #itemsToHighlight == 0 then

        warn("No items found to highlight with name/path '" .. highlightTarget .. "'.")

        return

    end

    for _, item in ipairs(itemsToHighlight) do

        local highlight = highlightItem(item, currentHighlightColor)

        table.insert(activeHighlights, highlight)

        if humanoidRootPart then

            local distance = (humanoidRootPart.Position - item.Position).Magnitude

            local distanceText = ""

            

            if showName and showDistance then

                distanceText = string.format("%s\n%.2f studs", item.Name, distance)

            elseif showName then

                distanceText = item.Name

            elseif showDistance then

                distanceText = string.format("%.2f studs", distance)

            end

            

            if showName or showDistance then

                local billboard = createBillboard(item, distanceText, currentBillboardOffset)

                table.insert(activeBillboards, billboard)

            end

        end

    end

    print("Highlight applied to " .. #itemsToHighlight .. " items.")

    if #itemsToHighlight > 0 and not heartbeatConnection then

        heartbeatConnection = RunService.Heartbeat:Connect(function()

            if humanoidRootPart and character and character.Parent then

                for i = #activeBillboards, 1, -1 do

                    local billboard = activeBillboards[i]

                    if billboard and billboard.Adornee and billboard.Adornee:IsA("BasePart") and billboard.Adornee.Parent then

                        local item = billboard.Adornee

                        local distance = (humanoidRootPart.Position - item.Position).Magnitude

                        

                        local newText = ""

                        if showName and showDistance then

                            newText = string.format("%s\n%.2f studs", item.Name, distance)

                        elseif showName then

                            newText = item.Name

                        elseif showDistance then

                            newText = string.format("%.2f studs", distance)

                        end

                        

                        billboard.TextLabel.Text = newText

                    else

                        if billboard and billboard.Parent then

                            billboard:Destroy()

                        end

                        if activeHighlights[i] and activeHighlights[i].Parent then

                            activeHighlights[i]:Destroy()

                        end

                        table.remove(activeBillboards, i)

                        table.remove(activeHighlights, i)

                    end

                end

            else

                cleanupExistingHighlights()

            end

        end)

    end

end

-- GUI

local highlightGUI = Instance.new("ScreenGui")

highlightGUI.Name = "TriOX_ItemHighlight_GUI"

highlightGUI.ResetOnSpawn = false

highlightGUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

highlightGUI.Parent = player:WaitForChild("PlayerGui")

local colorSequence = {

    Color3.fromRGB(148, 0, 211),

    Color3.fromRGB(255, 165, 0),

    Color3.fromRGB(255, 105, 180),

    Color3.fromRGB(0, 191, 255)

}

local currentColorIndex = 1

local colorTransitionTime = 2

local currentTheme = "Dark"

local themes = {

    Dark = {

        Background = Color3.fromRGB(40, 40, 40),

        Header = Color3.fromRGB(30, 30, 30),

        Button = Color3.fromRGB(60, 60, 60),

        Text = Color3.fromRGB(255, 255, 255),

        CloseButton = Color3.fromRGB(200, 50, 50),

        InputBackground = Color3.fromRGB(50, 50, 50)

    }

}

local function createDraggablePanel(titleText, width, height, parentGui)

    local panel = Instance.new("Frame")

    panel.Size = UDim2.new(0, width, 0, height)

    panel.Position = UDim2.new(0.5, -width/2, 0.5, -height/2)

    panel.BackgroundColor3 = themes["Dark"].Background

    panel.BorderSizePixel = 0

    panel.ClipsDescendants = true

    panel.Active = true

    panel.Draggable = true

    panel.ZIndex = 2

    panel.Parent = parentGui

    local corner = Instance.new("UICorner")

    corner.CornerRadius = UDim.new(0, 8)

    corner.Parent = panel

    local header = Instance.new("Frame")

    header.Name = "Header"

    header.Size = UDim2.new(1, 0, 0, 28)

    header.BackgroundColor3 = themes["Dark"].Header

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

    title.Text = titleText

    title.TextColor3 = colorSequence[1]

    title.TextSize = 14

    title.Font = Enum.Font.GothamMedium

    title.TextXAlignment = Enum.TextXAlignment.Left

    title.Parent = header

    local closeBtn = Instance.new("TextButton")

    closeBtn.Name = "CloseButton"

    closeBtn.Size = UDim2.new(0, 28, 0, 28)

    closeBtn.Position = UDim2.new(1, -28, 0, 0)

    closeBtn.BackgroundColor3 = themes["Dark"].CloseButton

    closeBtn.Text = "X"

    closeBtn.TextColor3 = themes["Dark"].Text

    closeBtn.TextSize = 14

    closeBtn.Font = Enum.Font.GothamBold

    closeBtn.ZIndex = 3

    closeBtn.Parent = header

    closeBtn.MouseButton1Click:Connect(function()

        panel.Visible = false

        cleanupExistingHighlights()

    end)

    return panel, title

end

local highlightPanel, highlightTitleLabel = createDraggablePanel("TriOX Highlight", 200, 280, highlightGUI) -- Increased height for new buttons

highlightPanel.Visible = true

local contentFrame = Instance.new("Frame")

contentFrame.Name = "ContentFrame"

contentFrame.Size = UDim2.new(1, -10, 1, -40)

contentFrame.Position = UDim2.new(0, 5, 0, 35)

contentFrame.BackgroundTransparency = 1

contentFrame.Parent = highlightPanel

local listLayout = Instance.new("UIListLayout")

listLayout.Padding = UDim.new(0, 5)

listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

listLayout.VerticalAlignment = Enum.VerticalAlignment.Top

listLayout.SortOrder = Enum.SortOrder.LayoutOrder

listLayout.Parent = contentFrame

local pathLabel = Instance.new("TextLabel")

pathLabel.Size = UDim2.new(1, 0, 0, 18)

pathLabel.BackgroundTransparency = 1

pathLabel.TextColor3 = themes[currentTheme].Text

pathLabel.Text = "Path / Partial Name:"

pathLabel.TextSize = 12

pathLabel.Font = Enum.Font.GothamMedium

pathLabel.TextXAlignment = Enum.TextXAlignment.Left

pathLabel.Parent = contentFrame

local pathTextBox = Instance.new("TextBox")

pathTextBox.Name = "PathTextBox"

pathTextBox.Size = UDim2.new(1, 0, 0, 24)

pathTextBox.PlaceholderText = "e.g., Items or Sword"

pathTextBox.Text = highlightTarget

pathTextBox.BackgroundColor3 = themes[currentTheme].InputBackground

pathTextBox.TextColor3 = themes[currentTheme].Text

pathTextBox.TextSize = 12

pathTextBox.Font = Enum.Font.SourceSans

pathTextBox.TextXAlignment = Enum.TextXAlignment.Left

pathTextBox.BorderSizePixel = 0

pathTextBox.Parent = contentFrame

pathTextBox.Changed:Connect(function(property)

    if property == "Text" then

        highlightTarget = pathTextBox.Text

    end

end)

local rgbInputFrame = Instance.new("Frame")

rgbInputFrame.Size = UDim2.new(1, 0, 0, 40)

rgbInputFrame.BackgroundTransparency = 1

rgbInputFrame.Parent = contentFrame

local horizontalListLayout = Instance.new("UIListLayout")

horizontalListLayout.FillDirection = Enum.FillDirection.Horizontal

horizontalListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left

horizontalListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

horizontalListLayout.Padding = UDim.new(0, 5)

horizontalListLayout.Parent = rgbInputFrame

local rgbTextBoxesFrame = Instance.new("Frame")

rgbTextBoxesFrame.Size = UDim2.new(0.65, 0, 1, 0)

rgbTextBoxesFrame.BackgroundTransparency = 1

rgbTextBoxesFrame.Parent = rgbInputFrame

local rgbTextBoxesListLayout = Instance.new("UIListLayout")

rgbTextBoxesListLayout.FillDirection = Enum.FillDirection.Vertical

rgbTextBoxesListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left

rgbTextBoxesListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

rgbTextBoxesListLayout.Padding = UDim.new(0, 2)

rgbTextBoxesListLayout.Parent = rgbTextBoxesFrame

local colorActualSquare

local function updateColorPreview()

    currentHighlightColor = Color3.fromRGB(math.floor(tonumber(rTextBox.Text)), math.floor(tonumber(gTextBox.Text)), math.floor(tonumber(bTextBox.Text)))

    if colorActualSquare then

        colorActualSquare.BackgroundColor3 = currentHighlightColor

    end

end

local rValue = currentHighlightColor.R * 255

local gValue = currentHighlightColor.G * 255

local bValue = currentHighlightColor.B * 255

local function createRGBInput(name, initialValue, parentFrame)

    local inputFrame = Instance.new("Frame")

    inputFrame.Size = UDim2.new(1, 0, 0, 12)

    inputFrame.BackgroundTransparency = 1

    inputFrame.Parent = parentFrame

    local label = Instance.new("TextLabel")

    label.Size = UDim2.new(0.15, 0, 1, 0)

    label.BackgroundTransparency = 1

    label.TextColor3 = themes[currentTheme].Text

    label.Text = name .. ":"

    label.TextSize = 10

    label.Font = Enum.Font.GothamMedium

    label.TextXAlignment = Enum.TextXAlignment.Left

    label.Parent = inputFrame

    local textBox = Instance.new("TextBox")

    textBox.Name = name .. "TextBox"

    textBox.Size = UDim2.new(0.85, 0, 1, 0)

    textBox.Position = UDim2.new(0.15, 0, 0, 0)

    textBox.Text = tostring(initialValue)

    textBox.BackgroundColor3 = themes[currentTheme].InputBackground

    textBox.TextColor3 = themes[currentTheme].Text

    textBox.TextSize = 10

    textBox.Font = Enum.Font.SourceSans

    textBox.TextXAlignment = Enum.TextXAlignment.Center

    textBox.BorderSizePixel = 0

    textBox.Parent = inputFrame

    local corner = Instance.new("UICorner")

    corner.CornerRadius = UDim.new(0, 3)

    corner.Parent = textBox

    textBox.FocusLost:Connect(function()

        local value = tonumber(textBox.Text)

        if value then

            value = math.clamp(value, 0, 255)

            textBox.Text = tostring(math.floor(value))

        else

            if name == "R" then textBox.Text = tostring(rValue) end

            if name == "G" then textBox.Text = tostring(gValue) end

            if name == "B" then textBox.Text = tostring(bValue) end

        end

        rValue = tonumber(rTextBox.Text) -- update internal value

        gValue = tonumber(gTextBox.Text) -- update internal value

        bValue = tonumber(bTextBox.Text) -- update internal value

        updateColorPreview()

    end)

    return textBox

end

rTextBox = createRGBInput("R", rValue, rgbTextBoxesFrame)

gTextBox = createRGBInput("G", gValue, rgbTextBoxesFrame)

bTextBox = createRGBInput("B", bValue, rgbTextBoxesFrame)

local colorPreviewSquare = Instance.new("Frame")

colorPreviewSquare.Name = "ColorPreview"

colorPreviewSquare.Size = UDim2.new(0.3, 0, 1, 0)

colorPreviewSquare.BackgroundTransparency = 1

colorPreviewSquare.Parent = rgbInputFrame

colorActualSquare = Instance.new("Frame")

colorActualSquare.Size = UDim2.new(0.9, 0, 0.9, 0)

colorActualSquare.Position = UDim2.new(0.5, 0, 0.5, 0)

colorActualSquare.AnchorPoint = Vector2.new(0.5, 0.5)

colorActualSquare.BackgroundColor3 = currentHighlightColor

colorActualSquare.BorderSizePixel = 1

colorActualSquare.BorderColor3 = Color3.fromRGB(255, 255, 255)

colorActualSquare.Parent = colorPreviewSquare

local colorCorner = Instance.new("UICorner")

colorCorner.CornerRadius = UDim.new(0, 4)

colorCorner.Parent = colorActualSquare

updateColorPreview()

-- Toggle buttons for name and distance

local toggleButtonsFrame = Instance.new("Frame")

toggleButtonsFrame.Size = UDim2.new(1, 0, 0, 28)

toggleButtonsFrame.BackgroundTransparency = 1

toggleButtonsFrame.Parent = contentFrame

local toggleButtonsLayout = Instance.new("UIListLayout")

toggleButtonsLayout.FillDirection = Enum.FillDirection.Horizontal

toggleButtonsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

toggleButtonsLayout.VerticalAlignment = Enum.VerticalAlignment.Center

toggleButtonsLayout.Padding = UDim.new(0, 5)

toggleButtonsLayout.Parent = toggleButtonsFrame

local function createToggleButton(name, initialState, parentFrame)

    local button = Instance.new("TextButton")

    button.Name = name .. "Toggle"

    button.Size = UDim2.new(0.45, 0, 1, 0)

    button.BackgroundColor3 = initialState and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(150, 50, 50)

    button.TextColor3 = themes[currentTheme].Text

    button.Text = name .. ": " .. (initialState and "ON" or "OFF")

    button.TextSize = 12

    button.Font = Enum.Font.GothamBold

    button.ZIndex = 3

    button.Parent = parentFrame

    local corner = Instance.new("UICorner")

    corner.CornerRadius = UDim.new(0, 4)

    corner.Parent = button

    return button

end

local nameToggleButton = createToggleButton("Name", showName, toggleButtonsFrame)

local distanceToggleButton = createToggleButton("Distance", showDistance, toggleButtonsFrame)

nameToggleButton.MouseButton1Click:Connect(function()

    showName = not showName

    nameToggleButton.Text = "Name: " .. (showName and "ON" or "OFF")

    nameToggleButton.BackgroundColor3 = showName and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(150, 50, 50)

    if #activeHighlights > 0 then

        applyHighlighting() -- Reapply highlighting to update billboards

    end

end)

distanceToggleButton.MouseButton1Click:Connect(function()

    showDistance = not showDistance

    distanceToggleButton.Text = "Distance: " .. (showDistance and "ON" or "OFF")

    distanceToggleButton.BackgroundColor3 = showDistance and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(150, 50, 50)

    if #activeHighlights > 0 then

        applyHighlighting() -- Reapply highlighting to update billboards

    end

end)

local highlightButton = Instance.new("TextButton")

highlightButton.Name = "HighlightButton"

highlightButton.Size = UDim2.new(0.9, 0, 0, 28)

highlightButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)

highlightButton.TextColor3 = themes[currentTheme].Text

highlightButton.Text = "Highlight"

highlightButton.TextSize = 12

highlightButton.Font = Enum.Font.GothamBold

highlightButton.ZIndex = 3

highlightButton.Parent = contentFrame

local highlightButtonCorner = Instance.new("UICorner")

highlightButtonCorner.CornerRadius = UDim.new(0, 4)

highlightButtonCorner.Parent = highlightButton

highlightButton.MouseButton1Click:Connect(function()

    applyHighlighting()

end)

local removeHighlightButton = Instance.new("TextButton")

removeHighlightButton.Name = "RemoveHighlightButton"

removeHighlightButton.Size = UDim2.new(0.9, 0, 0, 28)

removeHighlightButton.BackgroundColor3 = Color3.fromRGB(150, 50, 50)

removeHighlightButton.TextColor3 = themes[currentTheme].Text

removeHighlightButton.Text = "Clear Highlight"

removeHighlightButton.TextSize = 12

removeHighlightButton.Font = Enum.Font.GothamBold

removeHighlightButton.ZIndex = 3

removeHighlightButton.Parent = contentFrame

local removeHighlightButtonCorner = Instance.new("UICorner")

removeHighlightButtonCorner.CornerRadius = UDim.new(0, 4)

removeHighlightButtonCorner.Parent = removeHighlightButton

removeHighlightButton.MouseButton1Click:Connect(function()

    cleanupExistingHighlights()

end)

-- Animation for header and Highlight button colors

local colorTime = 0

RunService.Heartbeat:Connect(function(deltaTime)

    colorTime = colorTime + deltaTime

    if colorTime >= colorTransitionTim
