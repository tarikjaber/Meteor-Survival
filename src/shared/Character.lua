local DataStoreService = game:GetService("DataStoreService")
local SCORE_DATA_STORE = "allTimeHighScore"
local Players = game:GetService("Players")

local function setScore(player, score)
	local dataStore = DataStoreService:GetDataStore(SCORE_DATA_STORE)
	local success, error = pcall(function()
		dataStore:SetAsync(tostring(player.UserId), score)
	end)
    local leaderstats = player.leaderstats
    local topScore = leaderstats and leaderstats:FindFirstChild("HighScore")
    if topScore then
        topScore.Value = score
    end
	if not success then
		warn("Error setting score for player " .. player.Name .. ": " .. error)
	end
end

local function getScore(player)
	local dataStore = DataStoreService:GetDataStore(SCORE_DATA_STORE)
	local success, result = pcall(function()
		return dataStore:GetAsync(tostring(player.UserId))
	end)
	if not success then
		warn("Error getting score for player " .. player.Name .. ": " .. result)
		return 0
	end
	return tonumber(result) or 0
end

local function countScore(player, character, scoreLabel)
	local score = 0
	local highScore = getScore(player)
	while true do
		task.wait(1)
		if character.Humanoid.Health <= 0 then
			if score > highScore then
				setScore(player, score)
				scoreLabel.Text = "Score: " .. score .. "\nHigh Score: " .. score -- update score label with high score
			else
				score = 0
			end
		else
			score += 1
			scoreLabel.Text = "Score: " .. score -- update score label

			scoreLabel.Text = "Score: " .. score .. "\nHigh Score: " .. highScore -- update score label with high score
		end
	end
end

local function onCharacterAdded(character, player)
	print("Character added for player " .. player.Name)

	character.Humanoid.WalkSpeed = 80
	character.Humanoid.JumpHeight = 20

	local forceField = Instance.new("ForceField", character)
	task.delay(4, function()
		forceField:Destroy()
	end)

	-- create score label
	local billboardGui = Instance.new("BillboardGui", character.Head)
	billboardGui.Name = "ScoreLabel"
	billboardGui.AlwaysOnTop = true
	billboardGui.Size = UDim2.new(0, 100, 0, 50)
	billboardGui.StudsOffset = Vector3.new(0, 2, 0)

	local scoreLabel = Instance.new("TextLabel", billboardGui)
	scoreLabel.Name = "Score"
	scoreLabel.Text = "Score: 0\nHigh Score: 0"
	scoreLabel.Size = UDim2.new(1, 0, 1, 0)
	scoreLabel.BackgroundTransparency = 1
	scoreLabel.Font = Enum.Font.SourceSansBold
	scoreLabel.TextSize = 24
	scoreLabel.TextColor3 = Color3.new(1, 1, 1)
	scoreLabel.TextStrokeTransparency = 0.5

	countScore(player, character, scoreLabel)
end

local function leaderboardSetup(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local topScore = Instance.new("IntValue")
	topScore.Name = "HighScore"
	topScore.Value = getScore(player)
	topScore.Parent = leaderstats
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		onCharacterAdded(character, player)
	end)
    leaderboardSetup(player)
end)

return nil
