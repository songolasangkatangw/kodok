


local colors = {
    SchemeColor = Color3.fromRGB(0,255,255),
    Background = Color3.fromRGB(0, 0, 0),
    Header = Color3.fromRGB(0, 0, 0),
    TextColor = Color3.fromRGB(255,255,255),
    ElementColor = Color3.fromRGB(20, 20, 20)
}

-------------------------------------------------------------------------------------------------------------------------------------


local Stats = game:GetService('Stats')

local Players = game:GetService('Players')


local RunService = game:GetService('RunService')

local TweenService = game:GetService('TweenService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')


local Nurysium_Util = loadstring(game:HttpGet('https://raw.githubusercontent.com/songolasangkatangw/Main-Script/main/gggg'))()

local local_player = Players.LocalPlayer

local camera = workspace.CurrentCamera

local gpllp_Data = nil

local hit_Sound = nil

local closest_Entity = nil

local parry_remote = nil

getgenv().aura_Enabled = false

getgenv().hit_sound_Enabled = false

getgenv().hit_effect_Enabled = false

getgenv().night_mode_Enabled = false

getgenv().trail_Enabled = false

getgenv().self_effect_Enabled = false

getgenv().spectate_Enabled = false

getgenv().ai_Enabled = false



local Services = {
    game:GetService('AdService'),
    game:GetService('SocialService')
}


---------------------------------------------------------------------------------------------------------------------------------------------------------

-- Shop Fractions

function SwordCrateManual()

game:GetService("ReplicatedStorage").Remote.RemoteFunction:InvokeServer("PromptPurchaseCrate", workspace.Spawn.Crates.NormalSwordCrate)

end

function ExplosionCrateManual()

game:GetService("ReplicatedStorage").Remote.RemoteFunction:InvokeServer("PromptPurchaseCrate", workspace.Spawn.Crates.NormalExplosionCrate)

end

local function claimPlaytimeReward()
game.ReplicatedStorage.ClaimPlaytimeReward:InvokeServer()
    print("Claiming Playtime Reward...")
end

function initializate(dataFolder_name: string)
	local gpllp_Data = Instance.new('Folder', game:GetService('CoreGui'))
	gpllp_Data.Name = dataFolder_name
	hit_Sound = Instance.new('Sound', gpllp_Data)
	hit_Sound.SoundId = 'rbxassetid://7147454322'
	hit_Sound.Volume = 100
end


----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function get_closest_entity(Object: Part)

    task.spawn(function()

        local closest

        local max_distance = math.huge

        for index, entity in workspace.Alive:GetChildren() do

            if entity.Name ~= Players.LocalPlayer.Name then

                local distance = (Object.Position - entity.HumanoidRootPart.Position).Magnitude

                if distance < max_distance then

                    closest_Entity = entity

                    max_distance = distance

                end

            end

        end

        return closest_Entity

    end)

end


local function get_center()
	for _, object in workspace.Map:GetDescendants() do
		if object.Name == 'BALLSPAWN' then
			return object
		end
	end
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function resolve_parry_Remote()

    for _, value in Services do

        local temp_remote = value:FindFirstChildOfClass('RemoteEvent')

        if not temp_remote then

            continue

        end

        if not temp_remote.Name:find('\n') then

            continue

        end

        parry_remote = temp_remote

    end

end

function walk_to(position)
	local_player.Character.Humanoid:MoveTo(position)
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local aura_table = {

    canParry = true,

    is_Spamming = false,

    parry_Range = 0,

    spam_Range = 0,  

    hit_Count = 0,

    hit_Time = tick(),

    ball_Warping = tick(),

    is_ball_Warping = false

}


ReplicatedStorage.Remotes.ParrySuccess.OnClientEvent:Connect(function()

    if getgenv().hit_sound_Enabled then

        hit_Sound:Play()

    end

    if getgenv().hit_effect_Enabled then

        local hit_effect = game:GetObjects("rbxassetid://17407244385")[1]

        hit_effect.Parent = Nurysium_Util.getBall()

        hit_effect:Emit(3)

        

        task.delay(5, function()

            hit_effect:Destroy()

        end)

    end

end)

ReplicatedStorage.Remotes.ParrySuccessAll.OnClientEvent:Connect(function()

    aura_table.hit_Count += 1

    task.delay(0.15, function()

        aura_table.hit_Count -= 1

    end)

end)

workspace:WaitForChild("Balls").ChildRemoved:Connect(function(child)

    aura_table.hit_Count = 0

    aura_table.is_ball_Warping = false

    aura_table.is_Spamming = false

end)


----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

task.spawn(function()

    RunService.PreRender:Connect(function()

        if not getgenv().aura_Enabled then

            return

        end

        if closest_Entity then

            if workspace.Alive:FindFirstChild(closest_Entity.Name) and workspace.Alive:FindFirstChild(closest_Entity.Name).Humanoid.Health > 0 then

                if aura_table.is_Spamming then

                    if local_player:DistanceFromCharacter(closest_Entity.HumanoidRootPart.Position) <= aura_table.spam_Range then   

                        parry_remote:FireServer(

                            0.5,

                            CFrame.new(camera.CFrame.Position, Vector3.zero),

                            {[closest_Entity.Name] = closest_Entity.HumanoidRootPart.Position},

                            {closest_Entity.HumanoidRootPart.Position.X, closest_Entity.HumanoidRootPart.Position.Y},

                            false

                        )

                    end

                end

            end

        end

    end)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    RunService.Heartbeat:Connect(function()

        if not getgenv().aura_Enabled then

            return

        end

        local ping = Stats.Network.ServerStatsItem['Data Ping']:GetValue() / 10

        local self = Nurysium_Util.getBall()

        if not self then

            return

        end

        self:GetAttributeChangedSignal('target'):Once(function()

            aura_table.canParry = true

        end)

        if self:GetAttribute('target') ~= local_player.Name or not aura_table.canParry then

            return

        end

        get_closest_entity(local_player.Character.PrimaryPart)

        local player_Position = local_player.Character.PrimaryPart.Position

        local ball_Position = self.Position

        local ball_Velocity = self.AssemblyLinearVelocity

        if self:FindFirstChild('zoomies') then

            ball_Velocity = self.zoomies.VectorVelocity

        end

        local ball_Direction = (local_player.Character.PrimaryPart.Position - ball_Position).Unit

        local ball_Distance = local_player:DistanceFromCharacter(ball_Position)

        local ball_Dot = ball_Direction:Dot(ball_Velocity.Unit)

        local ball_Speed = ball_Velocity.Magnitude

        local ball_speed_Limited = math.min(ball_Speed / 1000, 0.1)

        local ball_predicted_Distance = (ball_Distance - ping / 15.5) - (ball_Speed / 3.5)

        local target_Position = closest_Entity.HumanoidRootPart.Position

        local target_Distance = local_player:DistanceFromCharacter(target_Position)

        local target_distance_Limited = math.min(target_Distance / 10000, 0.1)

        local target_Direction = (local_player.Character.PrimaryPart.Position - closest_Entity.HumanoidRootPart.Position).Unit

        local target_Velocity = closest_Entity.HumanoidRootPart.AssemblyLinearVelocity

        local target_isMoving = target_Velocity.Magnitude > 0

        local target_Dot = target_isMoving and math.max(target_Direction:Dot(target_Velocity.Unit), 0)

        aura_table.spam_Range = math.max(ping / 10, 15) + ball_Speed / 7

        aura_table.parry_Range = math.max(math.max(ping, 4) + ball_Speed / 3.5, 9.5)

        aura_table.is_Spamming = aura_table.hit_Count > 1 or ball_Distance < 13.5

        if ball_Dot < -0.2 then

            aura_table.ball_Warping = tick()

        end

        task.spawn(function()

            if (tick() - aura_table.ball_Warping) >= 0.15 + target_distance_Limited - ball_speed_Limited or ball_Distance <= 10 then

                aura_table.is_ball_Warping = false

                return

            end

            aura_table.is_ball_Warping = true

        end)

        if ball_Distance <= aura_table.parry_Range and not aura_table.is_Spamming and not aura_table.is_ball_Warping then

            parry_remote:FireServer(

                0.5,

                CFrame.new(camera.CFrame.Position, Vector3.new(math.random(0, 100), math.random(0, 1000), math.random(100, 1000))),

                {[closest_Entity.Name] = target_Position},

                {target_Position.X, target_Position.Y},

                false

            )

            aura_table.canParry = false

            aura_table.hit_Time = tick()

            aura_table.hit_Count += 1

            task.delay(0.15, function()

                aura_table.hit_Count -= 1

            end)

        end

        task.spawn(function()

            repeat

                RunService.Heartbeat:Wait()

            until (tick() - aura_table.hit_Time) >= 1

                aura_table.canParry = true

        end)

    end)

end)



--------------------------------------------------------------------------------------------------------------------------------------------

task.defer(function()

    game:GetService("RunService").Heartbeat:Connect(function()

        if not local_player.Character then

            return

        end

        if getgenv().trail_Enabled then

            local trail = game:GetObjects("rbxassetid://17483658369")[1]

            trail.Name = 'nurysium_fx'

            if local_player.Character.PrimaryPart:FindFirstChild('nurysium_fx') then

                return

            end

            local Attachment0 = Instance.new("Attachment", local_player.Character.PrimaryPart)

            local Attachment1 = Instance.new("Attachment", local_player.Character.PrimaryPart)

            Attachment0.Position = Vector3.new(0, -2.411, 0)

            Attachment1.Position = Vector3.new(0, 2.504, 0)

            trail.Parent = local_player.Character.PrimaryPart

            trail.Attachment0 = Attachment0

            trail.Attachment1 = Attachment1

        else

            

            if local_player.Character.PrimaryPart:FindFirstChild('nurysium_fx') then

                local_player.Character.PrimaryPart['nurysium_fx']:Destroy()

            end

        end

    end)
end)

-------------------------------------------------------------------------------------------------

--// night-mode

task.defer(function()

    while task.wait(1) do

        if getgenv().night_mode_Enabled then

            game:GetService("TweenService"):Create(game:GetService("Lighting"), TweenInfo.new(3), {ClockTime = 3.9}):Play()

        else

            game:GetService("TweenService"):Create(game:GetService("Lighting"), TweenInfo.new(3), {ClockTime = 13.5}):Play()

        end

    end

end)



--------loadstring(game:HttpGet("https://raw.githubusercontent.com/songolasangkatangw/123123/main/dddd.lua"))()-------------------------------------------------------------------------------------- ballz


task.defer(function()
    RunService.RenderStepped:Connect(function()
        if getgenv().spectate_Enabled then

            local self = Nurysium_Util.getBall()

            if not self then
                return
            end

            workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame:Lerp(CFrame.new(workspace.CurrentCamera.CFrame.Position, self.Position), 1.5)
        end
    end)
end)


-----------------------------------------------------------------------------------------------------------



task.defer(function()
    game:GetService("RunService").Heartbeat:Connect(function()
        if getgenv().ai_Enabled and workspace.Alive:FindFirstChild(local_player.Character.Name) then
            local self = Nurysium_Util.getBall()
            if not self or not closest_Entity then
                return
            end
            if not closest_Entity:FindFirstChild('HumanoidRootPart') then
                walk_to(local_player.Character.HumanoidRootPart.Position + Vector3.new(math.sin(tick()) * math.random(35, 50), 0, math.cos(tick()) * math.random(35, 50)))
                return
            end
            local ball_Position = self.Position
            local ball_Speed = self.AssemblyLinearVelocity.Magnitude
            local ball_Distance = local_player:DistanceFromCharacter(ball_Position)
            local player_Position = local_player.Character.PrimaryPart.Position
            local target_Position = closest_Entity.HumanoidRootPart.Position
            local target_Distance = local_player:DistanceFromCharacter(target_Position)
            local target_LookVector = closest_Entity.HumanoidRootPart.CFrame.LookVector
            local resolved_Position = Vector3.zero
            local target_Humanoid = closest_Entity:FindFirstChildOfClass("Humanoid")
            if target_Humanoid and target_Humanoid:GetState() == Enum.HumanoidStateType.Jumping and local_player.Character.Humanoid.FloorMaterial ~= Enum.Material.Air then
                local_player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
            if (ball_Position - player_Position):Dot(local_player.Character.PrimaryPart.CFrame.LookVector) < -0.2 and tick() % 4 <= 2 then
                return
            end
            if tick() % 4 <= 2 then
                if target_Distance > 10 then
                    resolved_Position = target_Position + (player_Position - target_Position).Unit * 8
                else
                    resolved_Position = target_Position + (player_Position - target_Position).Unit * 25
                end
            else
                resolved_Position = target_Position - target_LookVector * (math.random(8.5, 13.5) + (ball_Distance / math.random(8, 20)))
            end
            if (player_Position - target_Position).Magnitude < 8 then
                resolved_Position = target_Position + (player_Position - target_Position).Unit * 35
            end
            if ball_Distance < 8 then
                resolved_Position = player_Position + (player_Position - ball_Position).Unit * 10
            end
            if aura.is_spamming then
                resolved_Position = player_Position + (ball_Position - player_Position).Unit * 10
            end
            walk_to(resolved_Position + Vector3.new(math.sin(tick()) * 10, 0, math.cos(tick()) * 10))
        end
    end)
end)
ReplicatedStorage.Remotes.ParrySuccessAll.OnClientEvent:Connect(function()
	aura.hit_Count += 1
	task.delay(0.185, function()
		aura.hit_Count -= 1
	end)
end)
task.spawn(function()
	RunService.PreRender:Connect(function()
		if not getgenv().aura_Enabled then
			return
		end
		if closest_Entity then
			if workspace.Alive:FindFirstChild(closest_Entity.Name) then
				if aura.is_spamming then
					if local_player:DistanceFromCharacter(closest_Entity.HumanoidRootPart.Position) <= aura.spam_Range then   
						parry_remote:FireServer(
							0.5,
							CFrame.new(camera.CFrame.Position, Vector3.zero),
							{[closest_Entity.Name] = closest_Entity.HumanoidRootPart.Position},
							{closest_Entity.HumanoidRootPart.Position.X, closest_Entity.HumanoidRootPart.Position.Y},
							false
						)
					end
				end
			end
		end
	end)
	RunService.PreRender:Connect(function()
		if not getgenv().aura_Enabled then
			return
		end
		workspace:WaitForChild("Balls").ChildRemoved:Once(function(child)
			aura.hit_Count = 0
			aura.is_ball_Warping = false
			aura.is_spamming = false
			aura.can_parry = true
			aura.last_target = nil
		end)
		local ping = Stats.Network.ServerStatsItem['Data Ping']:GetValue() / 10
		local self = Nurysium_Util.getBall()
		if not self then
			return
		end
		self:GetAttributeChangedSignal('target'):Once(function()
			aura.can_parry = true
		end)
		self:GetAttributeChangedSignal('from'):Once(function()
			aura.last_target = workspace.Alive:FindFirstChild(self:GetAttribute('from'))
		end)
		if self:GetAttribute('target') ~= local_player.Name or not aura.can_parry then
			return
		end
		get_closest_entity(local_player.Character.PrimaryPart)
		local player_Position = local_player.Character.PrimaryPart.Position
		local player_Velocity = local_player.Character.HumanoidRootPart.AssemblyLinearVelocity
		local player_isMoving = player_Velocity.Magnitude > 0
		local ball_Position = self.Position
		local ball_Velocity = self.AssemblyLinearVelocity
		if self:FindFirstChild('zoomies') then
			ball_Velocity = self.zoomies.VectorVelocity
		end
		local ball_Direction = (local_player.Character.PrimaryPart.Position - ball_Position).Unit
		local ball_Distance = local_player:DistanceFromCharacter(ball_Position)
		local ball_Dot = ball_Direction:Dot(ball_Velocity.Unit)
		local ball_Speed = ball_Velocity.Magnitude
		local ball_speed_Limited = math.min(ball_Speed / 1000, 0.1)
		local target_Position = closest_Entity.HumanoidRootPart.Position
		local target_Distance = local_player:DistanceFromCharacter(target_Position)
		local target_distance_Limited = math.min(target_Distance / 10000, 0.1)
		local target_Direction = (local_player.Character.PrimaryPart.Position - closest_Entity.HumanoidRootPart.Position).Unit
		local target_Velocity = closest_Entity.HumanoidRootPart.AssemblyLinearVelocity
		local target_isMoving = target_Velocity.Magnitude > 0
		local target_Dot = target_isMoving and math.max(target_Direction:Dot(target_Velocity.Unit), 0)
		aura.spam_Range = math.max(ping / 10, 10.5) + ball_Speed / 6.15
		aura.parry_Range = math.max(math.max(ping, 3.5) + ball_Speed / 3.25, 9.5)
		if target_isMoving then
            aura.is_spamming = (aura.hit_Count > 1 or (target_Distance < 11 and ball_Distance < 10)) and ball_Dot > -0.25
        else
            aura.is_spamming = (aura.hit_Count > 1 or (target_Distance < 11.5 and ball_Distance < 10))
        end
		if ball_Dot < -0.2 then
			aura.ball_Warping = tick()
		end
		task.spawn(function()
			if (tick() - aura.ball_Warping) >= 0.15 + target_distance_Limited - ball_speed_Limited or ball_Distance < 10 then
				aura.is_ball_Warping = false
				return
			end
			if (ball_Position - aura.last_target.HumanoidRootPart.Position).Magnitude > 35.5 or target_Distance <= 12 then
				aura.is_ball_Warping = false
				return
			end
			aura.is_ball_Warping = true
		end)
		if ball_Distance <= aura.parry_Range and not aura.is_ball_Warping and ball_Dot > -0.1 then
			parry_remote:FireServer(
				0.5,
				CFrame.new(camera.CFrame.Position, Vector3.new(math.random(-1000, 1000), math.random(0, 1000), math.random(100, 1000))),
				{[closest_Entity.Name] = target_Position},
				{target_Position.X, target_Position.Y},
				false
			)
			aura.can_parry = false
			aura.hit_Time = tick()
			aura.hit_Count += 1
			task.delay(0.2, function()
				aura.hit_Count -= 1
			end)
		end
		task.spawn(function()
			repeat
				RunService.PreRender:Wait()
			until (tick() - aura.hit_Time) >= 1
			    aura.can_parry = true
		end)
	end)
end)


-- AI movement function

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local running = false

local respawnConnection


local function randomWalk()
    local directions = {
        Vector3.new(120, 0, 0),    -- Forward
        Vector3.new(-120, 0, 0),   -- Backward
        Vector3.new(0, 0, 130),    -- Right
        Vector3.new(0, 0, -90),   -- Left
        Vector3.new(90, 0, 90),  -- Forward-right
        Vector3.new(90, 0, -90), -- Forward-left
        Vector3.new(-80, 0, 80), -- Backward-right
        Vector3.new(-80, 0, -90) -- Backward-left
    }
    while running do
        local randomDirection = directions[math.random(1, #directions)]
        humanoid:MoveTo(character.PrimaryPart.Position + randomDirection)
        wait(math.random(0, 0))  -- Change direction every 3 to 7 seconds
    end
end



-- Function to handle character respawn
local function onCharacterAdded(newCharacter)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")
    
    if running then
        randomWalk()
    end
end


loadstring(game:HttpGet("https://raw.githubusercontent.com/songolasangkatangw/Main-Script/main/tulisane"))()

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()


local screenGui = Instance.new("ScreenGui")
      screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
      screenGui.ResetOnSpawn = false
      
      local imageButton = Instance.new("ImageButton")
      imageButton.Size = UDim2.new(0, 50, 0, 50)  -- Width and Height
      imageButton.Position = UDim2.new(0, 10, 1, -10)  -- Bottom-left corner
      imageButton.AnchorPoint = Vector2.new(0, 1)
      imageButton.Image = "rbxassetid://9614967008"  -- Replace with your off image asset ID
      
      local isOn = false
      local onImage = "rbxassetid://9614967008"  -- Replace with your on image asset ID
      local offImage = "rbxassetid://11330378074" -- Replace with your off image asset ID
      
      imageButton.MouseButton1Click:Connect(function()
          isOn = not isOn
          if isOn then
              imageButton.Image = onImage
              Library:ToggleUI()
          else
              imageButton.Image = offImage
              Library:ToggleUI()
          end
      end)
      
      imageButton.Parent = screenGui
     
      
      
local Window = Library.CreateLib("Blade Ball / GPLLP (Gak Pake Lama Langsung Pake) /", "DarkTheme")

local Tab = Window:NewTab("About")
local Section = Tab:NewSection("About")
Section:NewLabel("Executor : "  .. tostring(identifyexecutor()))
Section:NewLabel("Moga Yg Pake Rame")
Section:NewLabel("Yg Mau Request Update")
Section:NewLabel("Langsung Masuk Di Discord")
Section:NewLabel("https://discord.gg/xQ8ugBdqdn")
Section:NewLabel("Note : Request Update In Discord")



Section:NewButton("Copy Discord Link", "ButtonInfo", function()

    setclipboard("https://discord.gg/xQ8ugBdqdn")
    print("Clicked")
end)
Section:NewButton("Show Notify Again English", "ButtonInfo", function()

    loadstring(game:HttpGet("https://raw.githubusercontent.com/songolasangkatangw/Main-Script/main/tulisaneinggris"))()
    print("Clicked")
end)
Section:NewButton("Tunjukin Notif Versi Indo", "ButtonInfo", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/songolasangkatangw/Main-Script/main/tulisane"))()
    print("Clicked")
end)

------------------------------------------------------------------------------------------------------------------------------

local Tab = Window:NewTab("Main")

local Section = Tab:NewSection("Main")



Section:NewToggle("Ai Max Auto Parry Maybe :v", "Toggleinfo", function(toggled)

    resolve_parry_Remote()

    getgenv().aura_Enabled = toggled

end)

Section:NewToggle("Tact Passive (Curve Ballz)", "ToggleInfo", function(toggled)   loadstring(game:HttpGet("https://raw.githubusercontent.com/songolasangkatangw/tactpassive/main/tact.lua",true))()

end)


local Section = Tab:NewSection("Ai Move (Please Select One Mode Ai Move)")


Section:NewToggle("Ai Move (Not Following Ball) (Recommended)", false, function(state)

 
    running = state
    if running then
        randomWalk()
    else
        humanoid:Move(Vector3.new(0, 0, 0), true)
    end
    respawnConnection = player.CharacterAdded:Connect(onCharacterAdded)

    -- Clean up when the script stops
    game:BindToClose(function()
        if respawnConnection then
            respawnConnection:Disconnect()
        end
  
  end)


end)


Section:NewToggle("Ai Move (Follow Ballz Buggy) (Not Recommended)", "gay", function(toggled)
    resolve_parry_Remote()
	getgenv().ai_Enabled = toggled
end)


    Section:NewLabel("Last Update 7/2/2024")

    local Section = Tab:NewSection("Delete All Material For Farming")
    Section:NewButton("Delete Material Turn On Anti Afk", "ButtonInfo", function()
        
local light = game.Lighting
for i, v in pairs(light:GetChildren()) do
	v:Destroy()
end

local ter = workspace.Terrain
local color = Instance.new("ColorCorrectionEffect")
local bloom = Instance.new("BloomEffect")
local sun = Instance.new("SunRaysEffect")
local blur = Instance.new("BlurEffect")

color.Parent = light
bloom.Parent = light
sun.Parent = light
blur.Parent = light

-- enable or disable shit

local config = {

	Terrain = true;
	ColorCorrection = true;
	Sun = true;
	Lighting = true;
	BloomEffect = true;
	
}

-- settings {

color.Enabled = false
color.Contrast = 0.15
color.Brightness = 0.1
color.Saturation = 0.25
color.TintColor = Color3.fromRGB(255, 222, 211)

bloom.Enabled = false
bloom.Intensity = 0.1

sun.Enabled = false
sun.Intensity = 0.2
sun.Spread = 1

bloom.Enabled = false
bloom.Intensity = 0.05
bloom.Size = 32
bloom.Threshold = 1

blur.Enabled = false
blur.Size = 6

-- settings }


if config.ColorCorrection then
	color.Enabled = true
end


if config.Sun then
	sun.Enabled = true
end


if config.Terrain then
	-- settings {
	ter.WaterColor = Color3.fromRGB(10, 10, 24)
	ter.WaterWaveSize = 0.15
	ter.WaterWaveSpeed = 22
	ter.WaterTransparency = 1
	ter.WaterReflectance = 0.05
	-- settings }
end


if config.Lighting then
	-- settings {
	light.Ambient = Color3.fromRGB(0, 0, 0)
	light.Brightness = 4
	light.ColorShift_Bottom = Color3.fromRGB(0, 0, 0)
	light.ColorShift_Top = Color3.fromRGB(0, 0, 0)
	light.ExposureCompensation = 0
	light.FogColor = Color3.fromRGB(132, 132, 132)
	light.GlobalShadows = true
	light.OutdoorAmbient = Color3.fromRGB(112, 117, 128)
	light.Outlines = false
	-- settings }
end



game:GetService("MaterialService")["Use2022Materials"] = true
local vu = game:GetService("VirtualUser")

        game.Players.LocalPlayer.Idled:Connect(function()
            vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
            wait(1)
            vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
            
            wait(2)
        print("Clicked")
        end)
    end)
    local Section = Tab:NewSection("Before Use Press Delete Material Turn On Anti Afk")
    Section:NewToggle("Auto Farm", "toggleinfo", function(state)
        resolve_parry_Remote()

        getgenv().aura_Enabled = state
        getgenv().FB = state
    end)
    
    spawn(function()
        local TweenService = game:GetService("TweenService")
        local plr = game.Players.LocalPlayer
        local Ball = workspace:WaitForChild("Balls")
        local currentTween = nil
    
        while true do
            wait(0.001)
            if getgenv().FB then
                local ball = Ball:FindFirstChildOfClass("Part")
                local char = plr.Character
                if ball and char then
                    local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, false, 0)
                    local distance = (char.PrimaryPart.Position - ball.Position).magnitude
                    if distance <= 1000 then 
                        if currentTween then
                            currentTween:Pause()
                        end
                        currentTween = TweenService:Create(char.PrimaryPart, tweenInfo, {CFrame = ball.CFrame})
                        currentTween:Play()
                    end
                end
            else
                if currentTween then
                    currentTween:Pause()
                    currentTween = nil
                end
            end
        end
    end)
    



-------------------------------------------------------------
local Tab = Window:NewTab("Create")
local Section = Tab:NewSection("Create")
Section:NewButton("Sword Crate", "ButtonInfo", function()

    SwordCrateManual()
    
        print("Clicked")
    
    end)
    
    Section:NewButton("Explosion Crate", "ButtonInfo", function()
    
    ExplosionCrateManual()
    
        print("Clicked")
    
    end)
    local Section = Tab:NewSection("Create")
    Section:NewToggle("Sword Crate", "toggle", function(s)
        _G.AutoWin = s
        while _G.AutoWin do wait(.1)
            pcall(function()
                SwordCrateManual()
        end)
        end
        end)
        Section:NewToggle("Explosion Crate", "toggleinfo", function(s)
            _G.AutoWin = s
            while _G.AutoWin do wait(.1)
                pcall(function()
                    ExplosionCrateManual()
            end)
            end
            end)

------------------------------------------------------------------

local Tab = Window:NewTab("Misc")
    local Section = Tab:NewSection("Misc")

    Section:NewToggle("Auto Claim Play Time Reward", false, function(state)
        autoClaimEnabled = state
        if autoClaimEnabled then
            print("Auto-Claim Reward enabled")
            -- Start auto-claiming process (if needed)
            claimPlaytimeReward()
        else
            print("Auto-Claim Reward disabled")
            -- Stop auto-claiming process (if running)
        end
    end)


    Section:NewToggle("Spectate Ball", "ToggleInfo", function(toggled)
       getgenv().spectate_Enabled = toggled
    end)

    Section:NewToggle("Hit Sound", "ToggleInfo", function(toggled)

        getgenv().hit_sound_Enabled = toggled
    
    end)
    
    Section:NewToggle("Hit Effect", "ToggleInfo", function(toggled)
    
        getgenv().hit_effect_Enabled = toggled
    
    end)

    Section:NewToggle("Day/Night On Settings", "ToggleInfo", function(toggled)

        getgenv().night_mode_Enabled = toggled
    
    end)
    
    Section:NewToggle("Trail", "ToggleInfo", function(toggled)
    
        getgenv().trail_Enabled = toggled
    
    end)
    
    Section:NewToggle("Follow Ball", "toggleinfo", function(state)
        getgenv().FB = state
    end)
    
    spawn(function()
        local TweenService = game:GetService("TweenService")
        local plr = game.Players.LocalPlayer
        local Ball = workspace:WaitForChild("Balls")
        local currentTween = nil
    
        while true do
            wait(0.001)
            if getgenv().FB then
                local ball = Ball:FindFirstChildOfClass("Part")
                local char = plr.Character
                if ball and char then
                    local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, false, 0)
                    local distance = (char.PrimaryPart.Position - ball.Position).magnitude
                    if distance <= 1000 then 
                        if currentTween then
                            currentTween:Pause()
                        end
                        currentTween = TweenService:Create(char.PrimaryPart, tweenInfo, {CFrame = ball.CFrame})
                        currentTween:Play()
                    end
                end
            else
                if currentTween then
                    currentTween:Pause()
                    currentTween = nil
                end
            end
        end
    end)
    


------------------------------------------------------------------------

    local Tab = Window:NewTab("Player")
    local Section = Tab:NewSection("Local Player")
    Section:NewSlider("WalkSpeed", "WalkSpeed", 200, 0, function(s) -- 500 (MaxValue) | 0 (MinValue)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = s
    end)
    
    Section:NewSlider("JumpPower", "JumpPower", 200, 0, function(s) -- 500 (MaxValue) | 0 (MinValue)
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = s
    end)

    Section:NewSlider("Fov (Field Of View)", "WalkSpeed", 200, 0, function(s) -- 500 (MaxValue) | 0 (MinValue)
        game.workspace.CurrentCamera.FieldOfView = s
    end)
    
    Section:NewSlider("Gravity Player", "JumpPower", 200, 0, function(s) -- 500 (MaxValue) | 0 (MinValue)
        game.workspace.Gravity = s
    end)

    Section:NewSlider("Hip Height", "JumpPower", 200, 0, function(s) -- 500 (MaxValue) | 0 (MinValue)
        game.Players.LocalPlayer.Character.Humanoid.HipHeight = s
    end)


    Section:NewSlider("Multiple Speed Parry/Clash", "SliderInfo", 10, 0, function(s) -- 500 (MaxValue) | 0 (MinValue)
       print("OMG YOUR DMG MULTIPLE 100X")
    end)
    Section:NewButton("Reset Avatar", "ButtonInfo", function()
        game.Players.LocalPlayer.Character.Humanoid.Health = 0
        print("Clicked")
    end)

-------------------------------------------------------------------------------------------------------
    
    local Tab = Window:NewTab("Teleport")
local Section = Tab:NewSection("Teleport Player")

Plr = {}
for i,v in pairs(game:GetService("Players"):GetChildren()) do
table.insert(Plr,v.Name) 
end
local drop = Section:NewDropdown("Select Player", "Click To Select", Plr, function(t)
PlayerTP = t
end)
Section:NewButton("Click To TP", "Click To TP", function()
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Players[PlayerTP].Character.HumanoidRootPart.CFrame
end)
Section:NewToggle("Auto Loop Tp", "Auto Loop Tp", function(t)
_G.TPPlayer = t
while _G.TPPlayer do wait()
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Players[PlayerTP].Character.HumanoidRootPart.CFrame
end
end)
Section:NewButton("Refresh Player","Refresh Player", function()
    drop:Refresh(Plr)
  end)
  local Section = Tab:NewSection("Save CFrame and load")
      Section:NewButton("Save CFrame", "ButtonInfo", function()
          getgenv().CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
          print("Clicked")
      end)
      Section:NewButton("Load CFrame", "ButtonInfo", function()
          game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = getgenv().CFrame
          print("Clicked")
      end)
      
-----------------------------------------------------------------------------------------------------

      local Tab = Window:NewTab("Settings")
      local Section = Tab:NewSection("Settings")
      Section:NewKeybind("HotKeys", "KeybindInfo", Enum.KeyCode.P, function()
          Library:ToggleUI()
      end)
      local Section = Tab:NewSection("Theme")
for theme, color in pairs(colors) do
    Section:NewColorPicker(theme, "DarkTheme"..theme, color, function(color3)
        Library:ChangeColor(theme, color3)
    end)
end

---------------------------------------------------------------------------------------------------

local Tab = Window:NewTab("Spesial Menu")
local Section = Tab:NewSection("Becarefull Can Get Banned!!")
Section:NewTextBox("Custom Coin", "TextboxInfo", function(bitches)
    Reason = bitches
    wait(2)
    local StarterGui = game:GetService("StarterGui")
StarterGui:SetCore("SendNotification", {
	Title = "Faild Detected Notification", --//Required
	Text = "game:GetService(???) Someone Error With Service", --//Required
	Icon = 000000,
	Duration = 2,
})
end)
local Section = Tab:NewSection("Becarefull Can Get Banned!!")
Section:NewTextBox("Custom Sword (any sword)", "TextboxInfo", function(bitches)
    Reason = bitches
    wait(2)
    local StarterGui = game:GetService("StarterGui")
StarterGui:SetCore("SendNotification", {
	Title = "Faild Detected Notification", --//Required
	Text = "game:GetService(???) Someone Error With Service", --//Required
	Icon = 000000,
	Duration = 2,
})
end)

local Section = Tab:NewSection("Status Information")
local Section = Tab:NewSection("Status : How Much Coin? = Faild Detected")
local Section = Tab:NewSection("Status : Sword Now Useing? = Faild Detected")
local Section = Tab:NewSection("Status : Have Base Sword? = ✅")
local Section = Tab:NewSection("Status : Have Dash Abilities? = ✅")
local Section = Tab:NewSection("Status : Have Explosions Normal? = ✅")
local Section = Tab:NewSection("Status : Gay/Lesbian/Homo/Furry/NoGender? = ✅")


local Tab = Window:NewTab("Event")
local Section = Tab:NewSection("Coming Soon Maybe I Will Make For Event")

initializate('gpllp_temp')

-----------------------------------------------------------------------------------------
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Function to create and update the text with changing RGB color
local function createTextWithDynamicColor()
    -- Create ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "TextBokepGui"
    ScreenGui.Parent = player.PlayerGui
    ScreenGui.ResetOnSpawn = false

    -- Create TextLabel
    local TextLabel = Instance.new("TextLabel")
    TextLabel.Name = "TextBokep"
    TextLabel.Size = UDim2.new(0, 200, 0, 30)  -- Width: 200 pixels, Height: 30 pixels
    TextLabel.Position = UDim2.new(0.5, -100, 0, 10)  -- Centered horizontally, 10 pixels from the top
    TextLabel.Text = "discord.gg/xQ8ugBdqdn"
    TextLabel.TextColor3 = Color3.fromRGB(255, 0, 0)  -- Initial color (e.g., red)
    TextLabel.TextSize = 40  -- Small text size
    TextLabel.Font = Enum.Font.SourceSans  -- Font style
    TextLabel.BackgroundTransparency = 1  -- Transparent background
    TextLabel.Parent = ScreenGui
    

    -- Function to update the text color continuously
    local function updateTextColor()
        while ScreenGui.Parent == player.PlayerGui do
            local r = math.random(0, 255)
            local g = math.random(0, 255)
            local b = math.random(0, 255)
            TextLabel.TextColor3 = Color3.fromRGB(r, g, b)  -- Update text color with random RGB values
            
            wait(1)  -- Wait for 1 second before updating again
        end
    end

    -- Start updating the text color
    spawn(updateTextColor)
    
    -- Function to remove the GUI when the character dies
    local function characterDied()
        if ScreenGui.Parent == player.PlayerGui then
    ----- main
---- i made this script with chatgpt thanks you uuuuuuuuuuuuuuu u u  u u u u u u u u u u u u u u u u u u u u u u u u u u  u -------------




        end
    end

    -- Listen for character death
    character.Humanoid.Died:Connect(characterDied)
end

-- Start creating and updating the text with dynamic color
ScreenGui.ResetOnSpawn = false
createTextWithDynamicColor()

-------------------------------------------------------------------------------------------------
respawnConnection = player.CharacterAdded:Connect(onCharacterAdded)

-- Clean up when the script stops
game:BindToClose(function()
    if respawnConnection then
        respawnConnection:Disconnect()
    end
end)


