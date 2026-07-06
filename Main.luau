-- Connected Discord-GitHub 
--[[

Credit: TempsNewAccount (Roblox) / temperrature (Discord)
Purpose: Button Handler with Centralized Array Tracking Engine

]]

-- Services
local TS = game:GetService("TweenService")

-- Instances
local Root = script.Parent
local Home = Root.Home
local Sounds = Root.Sounds
local MainErrorUI = Root.Error

--Data Config

-- Error code definitions for the popup system
local ErrorCodes = {
	["0000-0000"] = {
		Code = "0000-0000",
		Title = "An error has occured.",
		Description = "If the problem persists please refer to the Ritch Support Website.",
		Link = "support.ritch.world/ritch/error",
	},
	["0000-0001"] = {
		Code= "0000-0001",
		Title = "An error has occured.",
		Description = "This has not been added yet.",
		Link = "support.ritch.world/ritch/error",
	},
	["0000-0002"] = {
		Code= "0000-0002",
		Title = "Game could not be launched.",
		Description = "If the problem persists please refer to the Ritch Support Website.",
		Link = "support.ritch.world/ritch/error",
	},
	["0000-0003"] = {
		Code= "0000-0003",
		Title = "A fatal Error has occured.",
		Description = "The console has encountered a fatal error and needs to restart.",
		Link = "support.ritch.world/ritch/error/fatal",
	},
}

-- Home Menu Options
local OtherButtons = {
	Home.HomeOptions.NewsButton,
	Home.HomeOptions.EshopButton,
	Home.HomeOptions.AlbumButton,
	Home.HomeOptions.ControllersButton,
	Home.HomeOptions.SettingsButton,
	Home.HomeOptions.PowerButton,
}

-- Game library data structure: {Instance, Title, Publisher}
local Games = {
	{Home.Games["1"], "Sonic X Shadow Generations", "SEGA"},
	{Home.Games["2"], "Sonic Mania", "SEGA"},
	{Home.Games["3"], "Sonic Frontiers", "SEGA"},
	{Home.Games["4"], "Team Sonic Racing", "SEGA"},
	{Home.Games["5"], "Sonic Colors Ultimate", "SEGA"},
}

-- Utilities and Popups
local ErrorPopup = {}

-- Error handler
function ErrorPopup:Throw(EC)
	Sounds.Error:Play()
	MainErrorUI.Visible = true
	MainErrorUI.BackgroundTransparency = 1
	MainErrorUI.Main.Size = UDim2.new(0.448, 0, 0.352, 0)

	-- Animate
	TS:Create(MainErrorUI, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 0.5}):Play()
	TS:Create(MainErrorUI.Main, TweenInfo.new(0.2, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut), {Size = UDim2.new(0.495, 0, 0.388, 0)}):Play()

	-- Populate UI labels with correct data
	MainErrorUI.Main.ErrorCode.Text = ErrorCodes[EC].Code
	MainErrorUI.Main.Title.Text = ErrorCodes[EC].Title
	MainErrorUI.Main.Description.Text = ErrorCodes[EC].Description
	MainErrorUI.Main.Link.Text = ErrorCodes[EC].Link

	-- Specialized dimming behavior if the error happens during a game launch
	if ErrorCodes[EC].Code == "0000-0002" then
		TS:Create(Root.GameLaunch, TweenInfo.new(0.3, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut), {BackgroundTransparency = 0.75}):Play()
	end

	-- Handle closing the error popup
	local Connection
	Connection = MainErrorUI.Main.Close.MouseButton1Click:Connect(function()
		if ErrorCodes[EC].Code == "0000-0002" then
			TS:Create(Root.GameLaunch, TweenInfo.new(0.3, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut), {BackgroundTransparency = 1}):Play()
			task.delay(0.3, function()
				Root.GameLaunch.Visible = false
			end)
		end

		Sounds.Enter:Play()
		Connection:Disconnect()
		Connection = nil

		-- Animate window out
		TS:Create(MainErrorUI, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 1}):Play()
		TS:Create(MainErrorUI.Main, TweenInfo.new(0.1, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut), {Size = UDim2.new(0.448, 0, 0.352, 0)}):Play()

		task.delay(0.1, function()
			MainErrorUI.Visible = false
		end)
	end)
end

-- Page management

-- Configures layout for the Locked/Sleep state screen
function SetupLockedPage()
	Home.BatteryWifi.Visible = true
	Home.LockedContinue.Visible = true
	Home.CurrentTime.Visible = true
	Home.NewsLocked.Visible = true

	Home.BottomLine.Visible = false
	Home.Games.Visible = false
	Home.HomeOptions.Visible = false
end

-- Configures layout and triggers entry tweens for the Main Dashboard
function SetupHomePage()
	Root.GameLaunch.Visible = false
	Home.BatteryWifi.Visible = true
	Home.CurrentTime.Visible = true

	task.delay(0.15, function()
		Home.NewsLocked.Visible = false
		Home.LockedContinue.Visible = false
	end)

	Home.BottomLine.Visible = true
	Home.Games.Visible = true
	Home.HomeOptions.Visible = true
	Home.UserProfile.Visible = true

	-- Reset sizing before scaling inward
	Home.Games.Size = UDim2.new(0.776, 0, 0.323, 0)
	Home.HomeOptions.Size = UDim2.new(0.427, 0, 0.125, 0)

	-- Bounce-in scale effect
	TS:Create(Home.Games, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Size = UDim2.new(0.817, 0, 0.341, 0)}):Play()
	TS:Create(Home.HomeOptions, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Size = UDim2.new(0.45, 0, 0.132, 0)}):Play()
end

-- Launch the title/game
function LaunchTitle()
	Sounds.RunTitle:Play()
	Root.GameLaunch.Visible = true
	Root.GameLaunch.BackgroundTransparency = 1

	-- Game icon pulsing
	TS:Create(Home.Games.Selected, TweenInfo.new(0.15, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut), {Size = UDim2.new(0.25092, 0, 1.02, 0)}):Play()
	task.delay(0.15, function()
		TS:Create(Home.Games.Selected, TweenInfo.new(0.15, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut), {Size = UDim2.new(0.247, 0, 1.005, 0)}):Play()
	end)

	-- Fade into full black
	task.delay(0.3, function()
		TS:Create(Root.GameLaunch, TweenInfo.new(0.45, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut), {BackgroundTransparency = 0}):Play()
	end)

	-- Simulation of game failing to boot
	task.delay(0.75, function()
		ErrorPopup:Throw("0000-0002")
	end)
end

-- Input handling

-- Hover behaviors
for i, v in pairs(OtherButtons) do
	v.MouseEnter:Connect(function()
		Home.HomeOptions.Selected.Position = v.Position
		Home.HomeOptions.Selected.NameOf.Text = v.Name:gsub("Button", "") -- excludes "Button"
		Home.HomeOptions.Selected.Visible = true
		Home.AOK.Visible = true
		Sounds.Select:Play()
	end)
	v.MouseLeave:Connect(function()
		Home.HomeOptions.Selected.Visible = false
		Home.AOK.Visible = false
	end)
end

-- Hover and click activations 
for i, v in pairs(Games) do
	v[1].MouseEnter:Connect(function()
		Home.Games.Selected.Position = v[1].Position
		Home.Games.Selected.NameOf.Text = v[2]
		Home.Games.Selected.Visible = true
		Home.AOK.Visible = true
		Sounds.Select:Play()
	end)
	v[1].MouseLeave:Connect(function()
		Home.Games.Selected.Visible = false
		Home.AOK.Visible = false
	end)
	v[1].MouseButton1Up:Connect(function()
		LaunchTitle()
	end)
end

-- Account profile shortcut
Home.UserProfile.MouseButton1Up:Connect(function()
	Sounds.User:Play()
	ErrorPopup:Throw("0000-0001")
end)

-- Album click handler
Home.HomeOptions.AlbumButton.MouseButton1Up:Connect(function()
	Sounds.Album:Play()
	ErrorPopup:Throw("0000-0001")
end)

-- News click handler
Home.HomeOptions.NewsButton.MouseButton1Up:Connect(function()
	ErrorPopup:Throw("0000-0001")
end)

-- Settings click handler
Home.HomeOptions.SettingsButton.MouseButton1Up:Connect(function()
	ErrorPopup:Throw("0000-0001")
end)

-- Eshop click handler
Home.HomeOptions.EshopButton.MouseButton1Up:Connect(function()
	ErrorPopup:Throw("0000-0001")
end)



-- Sleep click handler
Home.HomeOptions.PowerButton.MouseButton1Up:Connect(function()
	Sounds.ThisOne:Play()
	Root.GameLaunch.BackgroundTransparency = 1
	Root.GameLaunch.Visible = true

	-- Fade screen out entirely to black
	TS:Create(Root.GameLaunch, TweenInfo.new(0.15, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut), {BackgroundTransparency = 0}):Play()

	task.delay(0.25, function()
		local Connect 
		-- Wait until screen is tapped anywhere to "wake" system back up
		Connect = Root.GameLaunch.Unclickable.MouseButton1Up:Connect(function()
			SetupLockedPage()
			TS:Create(Root.GameLaunch, TweenInfo.new(0.15, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut), {BackgroundTransparency = 1}):Play()
			Connect:Disconnect()
			Connect = nil

			local twif = TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
			TS:Create(Home.LockedContinue, twif, {ImageTransparency = 0}):Play()
			TS:Create(Home.NewsLocked, twif, {BackgroundTransparency = 0}):Play()
			TS:Create(Home.NewsLocked.FeaturedNews, twif, {ImageTransparency = 0}):Play()
			TS:Create(Home.NewsLocked["1"], twif, {BackgroundTransparency = 0}):Play()
			TS:Create(Home.NewsLocked["2"], twif, {BackgroundTransparency = 0}):Play()
			TS:Create(Home.NewsLocked["3"], twif, {BackgroundTransparency = 0}):Play()

			task.delay(0.15, function()
				Root.GameLaunch.Visible = false
			end)
		end)
	end)
end)

-- Action logic for pressing any key to advance beyond Lock Screen
Home.LockedContinue.MouseButton1Up:Connect(function()
	Sounds.ThisOne:Play()
	Root.GameLaunch.Visible = false
	task.wait(0.05)
	Sounds.Home:Play()

	-- Fade-out animation for Lock Screen elements
	local twif = TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
	TS:Create(Home.LockedContinue, twif, {ImageTransparency = 1}):Play()
	TS:Create(Home.NewsLocked, twif, {BackgroundTransparency = 1}):Play()
	TS:Create(Home.NewsLocked.FeaturedNews, twif, {ImageTransparency = 1}):Play()
	TS:Create(Home.NewsLocked["1"], twif, {BackgroundTransparency = 1}):Play()
	TS:Create(Home.NewsLocked["2"], twif, {BackgroundTransparency = 1}):Play()
	TS:Create(Home.NewsLocked["3"], twif, {BackgroundTransparency = 1}):Play()

	SetupHomePage()
end)

--Start
SetupLockedPage()