local UIModule = {}

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

function UIModule.CreateWindow(title, themeColor)
    local MakitoGui = Instance.new("ScreenGui")
    MakitoGui.Name = "MakitoHub"
    MakitoGui.ResetOnSpawn = false
    
    local MainFrame = Instance.new("Frame", MakitoGui)
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 550, 0, 350)
    MainFrame.Position = UDim2.new(0.5, -275, 0.5, -175)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    MainFrame.BorderSizePixel = 0
    
    local MainCorner = Instance.new("UICorner", MainFrame)
    MainCorner.CornerRadius = UDim.new(0, 8)
    
    local MainStroke = Instance.new("UIStroke", MainFrame)
    MainStroke.Color = themeColor
    MainStroke.Thickness = 2
    MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    -- Dragging Logic
    local dragging, dragInput, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    -- Minimize Button
    local MinBtn = Instance.new("TextButton", MakitoGui)
    MinBtn.Size = UDim2.new(0, 50, 0, 50)
    MinBtn.Position = UDim2.new(0, 20, 0, 20)
    MinBtn.Text = "M"
    MinBtn.BackgroundColor3 = themeColor
    Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 8)
    
    MinBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = not MainFrame.Visible
    end)

    function UIModule.Notify(text, duration)
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "MAKITO HUB",
                Text = text,
                Duration = duration or 5
            })
        end)
    end

    UIModule.Notify("Interface Carregada com Sucesso!", 5)
    return MakitoGui, MainFrame, MainStroke
end

function UIModule.CreateHub()
    -- Aqui chamamos as funções de criação de abas que estavam no main original
    print("[MAKITO DEBUG]: Criando Hub...")
end

return UIModule
