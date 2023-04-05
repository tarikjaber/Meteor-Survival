local ReplicatedStorage = game:GetService("ReplicatedStorage")

require(ReplicatedStorage.Common:WaitForChild("Character"))

-- Define some constants
local MIN_SPAWN_HEIGHT = 50 -- Minimum height at which to spawn meteors
local MAX_SPAWN_HEIGHT = 200 -- Maximum height at which to spawn meteors
local SPAWN_TIME_INTERVAL = 0.35 -- Time between meteor spawns (in seconds)
local METEOR_LIFETIME = 3 -- Time for which meteors should remain visible (in seconds)
local EXPLOSION_RADIUS = 30 -- Radius of the explosion
local METEOR_FURTHEST_DISTANCE = 100 -- Distance from the player at which meteors should be destroyed
local BOUNDARY_THICKNESS = 5
local WALL_HEIGHT = 100
local WALL_Y_POSITION = 50
local BOUNDARY_COLOR = Color3.new(218, 245, 255)

local wallPositions = {
    {position = Vector3.new(-100, WALL_Y_POSITION, 0), size = Vector3.new(BOUNDARY_THICKNESS, WALL_HEIGHT, 200), material = Enum.Material.Neon, transparency = 0.5},
    {position = Vector3.new(100, WALL_Y_POSITION, 0), size = Vector3.new(BOUNDARY_THICKNESS, WALL_HEIGHT, 200), material = Enum.Material.Neon, transparency = 0.5},
    {position = Vector3.new(0, WALL_Y_POSITION, -100), size = Vector3.new(200, WALL_HEIGHT, BOUNDARY_THICKNESS), material = Enum.Material.Neon, transparency = 0.5},
    {position = Vector3.new(0, WALL_Y_POSITION, 100), size = Vector3.new(200, WALL_HEIGHT, BOUNDARY_THICKNESS), material = Enum.Material.Neon, transparency = 0.5}
}

for _, wallData in ipairs(wallPositions) do
	local wall = Instance.new("Part")
	wall.Size = wallData.size
	wall.Color = BOUNDARY_COLOR
	wall.Anchored = true
	wall.CanCollide = true
	wall.Position = wallData.position
	wall.Parent = workspace
end

-- Define a function to spawn a single meteor
local function spawnMeteor()
	-- Determine the spawn location and velocity for the meteor
	local x = math.random(-METEOR_FURTHEST_DISTANCE, METEOR_FURTHEST_DISTANCE)
	local y = math.random(MIN_SPAWN_HEIGHT, MAX_SPAWN_HEIGHT)
	local z = math.random(-METEOR_FURTHEST_DISTANCE, METEOR_FURTHEST_DISTANCE)
	local velocity = Vector3.new(math.random(-5, 5), -10, math.random(-5, 5))

	-- Create the meteor Part
	local meteor = Instance.new("Part") -- create a new Part instance
	meteor.Parent = workspace -- set the parent of the Part to the Workspace
	meteor.Size = Vector3.new(3, 3, 3) -- set the size of the Part
	meteor.Position = Vector3.new(x, y, z) -- set the position of the Part
	meteor.Anchored = false -- set the Anchored property of the Part to true, so it won't fall down
	local mesh = Instance.new("SpecialMesh") -- create a new SpecialMesh instance
	mesh.MeshType = Enum.MeshType.FileMesh -- set the MeshType to FileMesh
	mesh.MeshId = "http://www.roblox.com/asset/?id=1290033" -- set the MeshId to the ID of the mesh you want to use
	mesh.TextureId = "http://www.roblox.com/asset/?id=1290030" -- set the TextureId to the ID of the texture you want to use
	mesh.Parent = meteor -- set the parent of the mesh to the Part
	mesh.Scale = Vector3.new(5, 5, 5) -- set the scale of the mesh
	meteor.Velocity = velocity
	meteor.CanCollide = true
	meteor.Parent = workspace

	local function explode()
		local explosion = Instance.new("Explosion")
		explosion.ExplosionType = Enum.ExplosionType.NoCraters
		explosion.Position = meteor.Position
		explosion.Parent = workspace
		explosion.BlastRadius = EXPLOSION_RADIUS

		-- Get all players within the explosion radius
		local roots = {}
		for _,player in pairs(game.Players:GetChildren()) do
			if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
				table.insert(roots,player.Character.HumanoidRootPart)
			end
		end

		local radius = 15
		local overlapParams = OverlapParams.new()
		overlapParams.FilterDescendantsInstances = roots
		local nearbyPlayers = workspace:GetPartBoundsInRadius(explosion.Position, radius, overlapParams)

		-- Kill all players within the explosion radius
		for _, part in ipairs(nearbyPlayers) do
			if part.Parent and part.Parent:FindFirstChild("Humanoid") then
				local humanoid = part.Parent:FindFirstChild("Humanoid")
				local forceField = part.Parent:FindFirstChild("ForceField")
				if not forceField then
					humanoid.Health = 0
				end
			end
		end

		meteor:Destroy()
	end

	local function onMeteorHit(part)
		if part.Parent and part.Parent:FindFirstChild("Humanoid") then
			explode()
		end
	end
	meteor.Touched:Connect(onMeteorHit)

	-- Schedule the explosion to happen after a delay
	task.delay(METEOR_LIFETIME, explode)
end

-- Start spawning meteors
while true do
	spawnMeteor()
	task.wait(SPAWN_TIME_INTERVAL)
end
