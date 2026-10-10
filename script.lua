local DataStoreService = game:GetService("DataStoreService")
local AvatarDataStore = DataStoreService:GetDataStore("PlayerSavedAvatarSystem_v2")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Buat RemoteEvent otomatis kalau belum ada
local remoteEvent = ReplicatedStorage:FindFirstChild("AvatarChangeRemote")
if not remoteEvent then
	remoteEvent = Instance.new("RemoteEvent")
	remoteEvent.Name = "AvatarChangeRemote"
	remoteEvent.Parent = ReplicatedStorage
end

local function saveAvatar(player)
	local character = player.Character
	if not character then return end
	
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		local success, err = pcall(function()
			AvatarDataStore:SetAsync("User_" .. player.UserId, player.UserId)
		end)
		
		if success then
			print("Avatar " .. player.Name .. " berhasil disimpan!")
		else
			warn("Gagal menyimpan avatar: " .. tostring(err))
		end
	end
end

local function loadAvatar(player)
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")
	
	local success, savedUserId = pcall(function()
		return AvatarDataStore:GetAsync("User_" .. player.UserId)
	end)
	
	if success and savedUserId then
		local appearanceSuccess, model = pcall(function()
			return Players:GetHumanoidDescriptionFromUserId(savedUserId)
		end)
		
		if appearanceSuccess and model then
			humanoid:ApplyDescriptionReset(model)
			print("Avatar " .. player.Name .. " berhasil dimuat!")
		end
	end
end

remoteEvent.OnServerEvent:Connect(function(player, action)
	if action == "Save" then
		saveAvatar(player)
	elseif action == "Load" then
		loadAvatar(player)
	end
end)

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		task.wait(1.5)
		loadAvatar(player)
	end)
end)
