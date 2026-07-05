local ButtonClass = {}

local Connections = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local function ScaleUDim2(Input: UDim2, Multiplier: number)
	if not Input then return UDim2.new(0, 0, 0, 0) end
	return UDim2.new(
		Input.X.Scale * Multiplier, Input.X.Offset * Multiplier,
		Input.Y.Scale * Multiplier, Input.Y.Offset * Multiplier
	)
end

local function getOGSize(Button: GuiButton): UDim2
	return Button:GetAttribute("OGSize") or Button.Size
end

-- Presets
ButtonClass.ClickPresets = {
	["One"] = function(Button: GuiButton)
		TweenService:Create(Button, TweenInfo.new(0.2), {Size = ScaleUDim2(getOGSize(Button), 1.05)}):Play()
		task.delay(0.2, function()
			TweenService:Create(Button, TweenInfo.new(0.2), {Size = getOGSize(Button)}):Play()
		end)
	end,
	-- Subtle bounce effect for smaller buttons
	["Bounce"] = function(Button: GuiButton)
		local ogSize = getOGSize(Button)
		TweenService:Create(Button, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = ScaleUDim2(ogSize, 0.92)
		}):Play()
		task.delay(0.08, function()
			TweenService:Create(Button, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = ogSize
			}):Play()
		end)
	end,
	-- Quick press feedback
	["Press"] = function(Button: GuiButton)
		local ogSize = getOGSize(Button)
		TweenService:Create(Button, TweenInfo.new(0.06), {Size = ScaleUDim2(ogSize, 0.95)}):Play()
		task.delay(0.06, function()
			TweenService:Create(Button, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = ogSize
			}):Play()
		end)
	end,
}

ButtonClass.HoverOnPresets = {
	["One"] = function(Button: GuiButton)
		TweenService:Create(Button, TweenInfo.new(0.2), {Size = ScaleUDim2(getOGSize(Button), 1.02)}):Play()
	end,
	-- Subtle glow effect via slightly larger scale
	["Bounce"] = function(Button: GuiButton)
		TweenService:Create(Button, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = ScaleUDim2(getOGSize(Button), 1.04)
		}):Play()
	end,
	["Press"] = function(Button: GuiButton)
		TweenService:Create(Button, TweenInfo.new(0.1), {Size = ScaleUDim2(getOGSize(Button), 1.02)}):Play()
	end,
}

ButtonClass.HoverOffPresets = {
	["One"] = function(Button: GuiButton)
		TweenService:Create(Button, TweenInfo.new(0.2), {Size = getOGSize(Button)}):Play()
	end,
	["Bounce"] = function(Button: GuiButton)
		TweenService:Create(Button, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = getOGSize(Button)
		}):Play()
	end,
	["Press"] = function(Button: GuiButton)
		TweenService:Create(Button, TweenInfo.new(0.1), {Size = getOGSize(Button)}):Play()
	end,
}

-- Animation methods
function ButtonClass:ClickAnimation(Button: GuiButton, AnimationPreset: any)
	if AnimationPreset and ButtonClass.ClickPresets[AnimationPreset] then
		ButtonClass.ClickPresets[AnimationPreset](Button)
	end
end

function ButtonClass:HoverOnAnimation(Button: GuiButton, AnimationPreset: any)
	if AnimationPreset and ButtonClass.HoverOnPresets[AnimationPreset] then
		ButtonClass.HoverOnPresets[AnimationPreset](Button)
	end
end

function ButtonClass:HoverOffAnimation(Button: GuiButton, AnimationPreset: any)
	if AnimationPreset and ButtonClass.HoverOffPresets[AnimationPreset] then
		ButtonClass.HoverOffPresets[AnimationPreset](Button)
	end
end

-- Helper to update Switch visuals (using Quad easing for smooth, non-bouncy transitions)
local function UpdateSwitchVisual(Switch, Indicator, state: boolean)
	if state then
		TweenService:Create(Indicator, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
		TweenService:Create(Indicator, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.new(1, 0.666667, 0.870588)}):Play()
	else
		TweenService:Create(Indicator, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0.1, 0, 0.5, 0)}):Play()
		TweenService:Create(Indicator, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.new(0.47451, 0.243137, 0.372549)}):Play()
	end
end

function ButtonClass.new(Button: GuiButton, ButtonType: any, AnimationPresets: any, Cooldown: number, ClickFunction: any, HoverOnFunction: any, HoverOffFunction: any)
	if not ButtonType then
		return error("Button Type not set!")
	end

	if Button and (Button:IsA("TextButton") or Button:IsA("ImageButton")) then
		Button.Active = true
		Button.Selectable = true
	end

	local self = {}
	setmetatable(self, {__index = ButtonClass})

	if ButtonType[1] == "Action" then
		
		Connections[Button] = Connections[Button] or {}
		
		self.Button = Button

		if AnimationPresets.HoverOn or HoverOnFunction then
			local conn = Button.MouseEnter:Connect(function()
				if AnimationPresets.HoverOn then
					self:HoverOnAnimation(Button, AnimationPresets.HoverOn)
				end
				if HoverOnFunction then HoverOnFunction(Button) end
			end)
			table.insert(Connections[Button], conn)

			local connSel = Button.SelectionGained:Connect(function()
				if AnimationPresets.HoverOn then
					self:HoverOnAnimation(Button, AnimationPresets.HoverOn)
				end
				if HoverOnFunction then HoverOnFunction(Button) end
			end)
			table.insert(Connections[Button], connSel)
		end

		if AnimationPresets.HoverOff or HoverOffFunction then
			local conn = Button.MouseLeave:Connect(function()
				if AnimationPresets.HoverOff then
					self:HoverOffAnimation(Button, AnimationPresets.HoverOff)
				end
				if HoverOffFunction then HoverOffFunction(Button) end
			end)
			table.insert(Connections[Button], conn)

			local connSel = Button.SelectionLost:Connect(function()
				if AnimationPresets.HoverOff then
					self:HoverOffAnimation(Button, AnimationPresets.HoverOff)
				end
				if HoverOffFunction then HoverOffFunction(Button) end
			end)
			table.insert(Connections[Button], connSel)
		end

	elseif ButtonType[1] == "Switch" then
		-- Build switch UI
		
		local SwitchContainer = script:WaitForChild("SwitchContainer"):Clone()
		SwitchContainer.Parent = Button

		self.Switch = SwitchContainer:WaitForChild("Switch")
		self.Indicator = self.Switch:WaitForChild("Indicator")
		self.Interact = SwitchContainer:WaitForChild("Interact")

		self.Interact:SetAttribute("Activated", ButtonType[2] or false)
		UpdateSwitchVisual(self.Switch, self.Indicator, self.Interact:GetAttribute("Activated"))

		-- Style
		local gameUI = game.Players.LocalPlayer.PlayerGui:WaitForChild("GameUI")
		local settingsRoot = gameUI:FindFirstChild("Settings")
		if settingsRoot and SwitchContainer:IsDescendantOf(settingsRoot) then
			self.Switch.BackgroundColor3 = Color3.new(0.941176, 0.529412, 0.784314)
			if not self.Interact:GetAttribute("Activated") then
				self.Indicator.BackgroundColor3 = Color3.new(0.47451, 0.243137, 0.372549)
			end
		end

		-- Use ActualButton as click target if present (bigger overlay for easier tapping)
		local ActualButton = Button:FindFirstChild("ActualButton")
		if ActualButton and (ActualButton:IsA("TextButton") or ActualButton:IsA("ImageButton")) then
			Button = ActualButton
		else
			Button = self.Interact
		end

		if Button and (Button:IsA("TextButton") or Button:IsA("ImageButton")) then
			Button.Active = true
			Button.Selectable = true
		end

		Connections[Button] = Connections[Button] or {}
	end

	if Button:GetAttribute("Cooldown") == nil then
		Button:SetAttribute("Cooldown", false)
	end

	if ClickFunction
		or (type(AnimationPresets) == "table" and (AnimationPresets.HoverOn or AnimationPresets.HoverOff)) then
		Button:SetAttribute("OGSize", Button.Size)
	end

	local function handlePress()
		if Button:GetAttribute("Cooldown") == false then
			Button:SetAttribute("Cooldown", true)

			if ButtonType[1] == "Action" then
				self:ClickAnimation(Button, AnimationPresets.Click)
				if ClickFunction then ClickFunction(Button) end

			elseif ButtonType[1] == "Switch" then
				local newState = not self.Interact:GetAttribute("Activated")
				self.Interact:SetAttribute("Activated", newState)

				UpdateSwitchVisual(self.Switch, self.Indicator, newState)

				if ClickFunction then
					ClickFunction(self.Interact, newState)
				end
			end

			task.delay(Cooldown, function()
				Button:SetAttribute("Cooldown", false)
			end)
		end
	end

	local clickConn = Button.MouseButton1Down:Connect(handlePress)
	table.insert(Connections[Button], clickConn)

	local activatedConn = Button.Activated:Connect(function(inputObject)
		if inputObject and inputObject.UserInputType.Name:find("Gamepad") then
			handlePress()
		end
	end)
	table.insert(Connections[Button], activatedConn)

	return self
end

-- Connection cleanup
function ButtonClass:ClearConnection(instance: Instance)
	local conns = Connections[instance]
	if conns then
		for _, conn in ipairs(conns) do
			if conn.Connected then
				conn:Disconnect()
			end
		end
		Connections[instance] = nil
		return true
	end
	return false
end

return ButtonClass