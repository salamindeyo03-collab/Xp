-- [[ 실행기 전용 에임봇 올인원 최종 스크립트 ]] --
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

if CoreGui:FindFirstChild("AimbotMenu_Perfect_Fixed") then
	CoreGui["AimbotMenu_Perfect_Fixed"]:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AimbotMenu_Perfect_Fixed"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui:FindFirstChild("RobloxGui") or CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 320)
MainFrame.Position = UDim2.new(0.5, -160, 0.4, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(145, 145, 145)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 100, 0, 30)
Title.Position = UDim2.new(0, 20, 0, 20)
Title.BackgroundTransparency = 1
Title.Text = "Aimbot"
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 22
Title.TextColor3 = Color3.fromRGB(0, 0, 0)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

local SliderTrack = Instance.new("Frame")
SliderTrack.Size = UDim2.new(0, 240, 0, 14)
SliderTrack.Position = UDim2.new(0.5, -120, 0, 130)
SliderTrack.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
SliderTrack.Parent = MainFrame

local TrackCorner = Instance.new("UICorner")
TrackCorner.CornerRadius = UDim.new(1, 0)
TrackCorner.Parent = SliderTrack

local SliderFill = Instance.new("Frame")
SliderFill.Size = UDim2.new(0.15, 0, 1, 0)
SliderFill.Position = UDim2.new(0, 0, 0, 0)
SliderFill.BackgroundColor3 = Color3.fromRGB(50, 130, 230)
SliderFill.Parent = SliderTrack

local FillCorner = Instance.new("UICorner")
FillCorner.CornerRadius = UDim.new(1, 0)
FillCorner.Parent = SliderFill

local SliderButton = Instance.new("TextButton")
SliderButton.Size = UDim2.new(0, 18, 0, 18)
SliderButton.Position = UDim2.new(0.15, 0, 0.5, 0)
SliderButton.AnchorPoint = Vector2.new(0.5, 0.5)
SliderButton.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
SliderButton.Text = "✓"
SliderButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SliderButton.TextSize = 12
SliderButton.Font = Enum.Font.SourceSansBold
SliderButton.ZIndex = 5
SliderButton.Parent = SliderTrack

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(1, 0)
ButtonCorner.Parent = SliderButton

local ValueLabel = Instance.new("TextLabel")
ValueLabel.Size = UDim2.new(0, 60, 0, 20)
ValueLabel.Position = UDim2.new(0.5, -30, 0, -25)
ValueLabel.BackgroundTransparency = 1
ValueLabel.Text = "0.15"
ValueLabel.Font = Enum.Font.SourceSansBold
ValueLabel.TextSize = 16
ValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
ValueLabel.Parent = SliderTrack

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 220, 0, 45)
ToggleButton.Position = UDim2.new(0.5, -110, 0, 200)
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Text = "Aimbot: OFF"
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 18
ToggleButton.TextColor3 = Color3.fromRGB(0, 0, 0)
ToggleButton.Parent = MainFrame

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 10)
ToggleCorner.Parent = ToggleButton

local isDragging = false
local currentValue = 0.15

local function updateSlider()
	local mouseX = UserInputService:GetMouseLocation().X
	local trackLeft = SliderTrack.AbsolutePosition.X
	local trackWidth = SliderTrack.AbsoluteSize.X
	
	local scale = (mouseX - trackLeft) / trackWidth
	scale = math.clamp(scale, 0, 1)
	
	SliderFill.Size = UDim2.new(scale, 0, 1, 0)
	SliderButton.Position = UDim2.new(scale, 0, 0.5, 0)
	
	currentValue = math.floor(scale * 100) / 100
	ValueLabel.Text = tostring(currentValue)
end

SliderButton.MouseButton1Down:Connect(function()
	isDragging = true
end)

UserInputService.InputChanged:Connect(function(input)
	if isDragging and input.UserInput
