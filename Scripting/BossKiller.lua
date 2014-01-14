--[[
	--------------------------------------------------
	Copyright (C) 2011 Blastradius
	
	All rights reserved. You are not allowed to share this!
	--------------------------------------------------
]]--

-- OnLoad: Initialize the settings and register the key handlers.
function OnLoad()

	--------------------------------------------------
	--       Y O U   M A Y   E D I T   T H I S      --
	--------------------------------------------------
	
	-- Register the key combination for Super Glide (Automatic).
	Register( "KeyCheatingAutomatic", "X", "Control" );
	Register( "KeyCheatingApproach", "C", "Control" );

	-- Register the key combinations for Super Glide (Accurate)
	Register( "KeySuperGlideDownAccurate", "E", "Control" );
	Register( "KeySuperGlideForwardAccurate", "Z", "Control" );
	Register( "KeySuperGlideUpAccurate", "Q", "Control" );
	
	-- Register the key combinations for Super Glide (Coarse)
	Register( "KeySuperGlideDownCoarse", "E", "Alt" );
	Register( "KeySuperGlideForwardCoarse", "Z", "Alt" );
	Register( "KeySuperGlideUpCoarse", "Q", "Alt" );
	
	--------------------------------------------------
	--            D O   N O T   T O U C H           --
	--------------------------------------------------
	
	-- Include the Class library.
	Controller = Include( "OfficialGrinderFramework/Classes/" .. Player:GetClass():ToString() .. ".lua" );
	-- Include the Helper library.
	Helper = Include( "OfficialGrinderFramework/HelperFunction.lua" );
	-- Include the Settings.
	Settings = Include( "OfficialGrinderFramework/Settings.lua" );
	-- Initialize the Settings.
	Settings:Initialize();
	-- Initialize the Settings using boss-values.
	Settings:InitializeBoss();
	-- Set the attack state to allow attacking.
	Settings.AllowAttack = true;
	-- Set the Cleric attack state to allow attacking.
	Settings.Cleric.AllowAttack = true;
	
	--------------------------------------------------
	--       Y O U   M A Y   E D I T   T H I S      --
	--------------------------------------------------
	
	-- Contains the line distance when using the automatic attack routine (nil for circular movement).
	Settings.AutomaticLineDistance = 10;
	-- Contains the step size when using the automatic attack routine.
	Settings.AutomaticStepSize = 1;
	-- Contains the distance when using accurate super glide.
	Settings.SuperGlideDistanceAccurate = 0.5;
	-- Contains the distance when using coarse super glide.
	Settings.SuperGlideDistanceCoarse = 6;
	-- Indicates whether super glide coarse is restricted to actually gliding.
	Settings.SuperGlideRestrict = true;
	-- Indicates whether to move while attacking.
	Settings.MoveWhileAttacking = true;
	-- Contains the potion to use to recover MP (Use a 30-second cooldown potion).
	Settings.ManaPotion = "Major Mana Potion";
	-- Contains the potion to use to recover MP/HP (Use a 30-second cooldown potion).
	Settings.RecoveryPotion = "Major Recovery Potion";
	
end

-- OnRun: Check automatic movement for boss bugging.
function OnFrame()
	-- CheatingAutomatic: Check automatic attacking/movement for boss bugging.
	if CircularTeleportation ~= nil then
		-- Check other entities similar to the 'Safety' and 'Trust Force' combination of the cheating extension.
		for ID, Entity in DictionaryIterator( EntityList:GetList()) do
			if Entity:IsPlayer() and ForceList:GetForce( Entity:GetID()) == nil and Entity:GetID() ~= Player:GetID() then
				return;
			end
		end
		-- Retrieve the entity.
		local Entity = EntityList:GetEntity( Player:GetTargetID());
		-- Check if the potion shared cooldown timer has expired.
		if _iPotion == nil or _iPotion < Time() then
			-- Check if the recovery potion has been configured and may need to be used.
			if Settings.RecoveryPotion ~= nil and Entity ~= nil and Entity:GetName() == "Stormwing" and Entity:GetHealth() >= 80 then
				-- Check if the player health or player mana is low enough to justify the use of a recovery potion.
				if ( Player:GetHealth() < 95 or Player:GetMana() < 30 ) and CheatingPotion( Settings.RecoveryPotion ) then
					return;
				end
			-- Check if the mana potion has been configured and needs to be used.
			elseif Settings.ManaPotion ~= nil and Player:GetMana() < 50 and CheatingPotion( Settings.ManaPotion ) then
				return;
			end
		end
		-- Enable smooth casting feature.
		AsCircularMagic:EnableSmoothCasting();
		-- CheatingApproach: Is this an insane bow wielder?
		if CheatingInsaneBowWielder() then
			return;
		end
		-- Check if the character is preparing for movement.
		if Settings.MoveWhileAttacking and _bMoving ~= nil then
			-- Run the Circular Teleportation Magic and wait until it gives a success.
			if not AsCircularMagic:DoMove() then
				return;
			-- Disable the moving toggle.
			else
				_bMoving = nil;
			end
		end
		-- Check if the attacking toggle is enabled.
		if _bAttacking ~= nil and ( Player:IsBusy() or Player:GetSkillTime() > 0 ) then
			-- Disable the attacking toggle.
			_bAttacking = nil;
			-- Enable the moving toggle.
			_bMoving = true;
		end
		-- Check if the controller has an attack routine, the player is not busy and the target entity is valid.
		if Controller.Attack ~= nil and Entity ~= nil and not Player:IsBusy() and Entity:IsMonster() and not Entity:IsFriendly() then
			-- Check if the entity is dead.
			if Entity:IsDead() then
				-- Clear the CircularTeleportation.
				CircularTeleportation = nil;
				return;
			-- Otherwise shoot everything we have got.
			else
				-- Initialize the stunned status.
				local Stunned = false;
				-- Loop through the state of the target entity .
				for ID, StateIndex in DictionaryIterator( Entity:GetState():GetList()) do
					-- Check if the state is correct and is a stun.
					if StateIndex ~= nil and StateIndex:IsStun() then
						-- Set the stunned status.
						Stunned = true;
					end
				end
				-- Run the attack routine on the entity.
				Controller:Attack( Entity, Entity:GetPosition():DistanceToPosition( Player:GetPosition()), Stunned, true );
				-- Enable the attacking toggle.
				_bAttacking = true;
			end
		end
	end
end

--------------------------------------------------
--      C H E A T I N G   F U N C T I O N S     --
--------------------------------------------------

-- CheatingAutomatic: Automatic Circular Teleportation
function CheatingAutomatic( Position, Distance )
	-- Initialize the Circular Teleportation Magic.
	AsCircularMagic:DoInitialize( Position, Distance, Settings.AutomaticLineDistance );
	-- Set the CircularTeleportation.
	CircularTeleportation = true;
end

-- CheatingApproach: Approach Position
function CheatingApproach( Position )
	-- Change the Z-axis of the position.
	Position.Z = Player:GetPosition().Z;
	-- Set the player movement.
	Player:SetMove( Position );
end

-- CheatingApproach: Is this an insane bow wielder?
function CheatingInsaneBowWielder()
	-- Check if this player is either an Assassin or a Gladiator.
	if Player:GetClass():ToString() == "Assassin" or Player:GetClass():ToString() == "Gladiator" then
		-- Loop through each item in the inventory.
		for Inventory in ListIterator( InventoryList:GetList()) do
			-- Check if this item is a bow and is equipped.
			if Inventory:GetType():ToString() == "Bow" and Inventory:GetSlot():ToString() == "MainHand_Equipped" then
				-- Run the Circular Teleportation Magic.
				AsCircularMagic:DoMove();
				return true;
			end
		end
	end
	-- This is not an insane bow wielder.
	return false;
end

-- CheatingPotion: Potion Consumption
function CheatingPotion( Potion )
	-- Retrieve the mana potion from the inventory list.
	local Inventory = InventoryList[Potion];
	-- Check if the potion is available.
	if Inventory ~= nil then
		-- Retrieve the recovery potion.
		local InventoryRecovery = InventoryList:GetInventory( Settings.RecoveryPotion );
		-- Retrieve the mana potion.
		local InventoryMana = InventoryList:GetInventory( Settings.ManaPotion );
		-- Check if either of the possible potions is in cooldown, which means all of them are!
		if ( InventoryRecovery ~= nil and InventoryRecovery:GetCooldown() ~= 0 ) or ( InventoryMana ~= nil and InventoryMana:GetCooldown() ~= 0 ) then
			-- Set the potion shared cooldown timer.
			_iPotion = Time() + 30000;
			-- Enable the moving toggle.
			_bMoving = true;
		-- Use the potion.
		else
			-- Disable smooth casting feature.
			AsCircularMagic:DisableSmoothCasting();
			-- Attempt to use the inventory item.
			PlayerInput:Inventory( Inventory:GetName());
			-- Stop executing the script this run.
			return true;
		end
	end
	-- Do not stop executing the script this run.
	return false;
end
			
--------------------------------------------------
--   S U P E R   G L I D E   F U N C T I O N S  --
--------------------------------------------------

-- SuperGlideDown: Change the Z-axis of the position to a higher position.
function SuperGlideDown( Distance )
	-- Retrieve the player position.
	local Pos = Player:GetPosition();
	-- Change the Z-axis of the position.
	Pos.Z = Pos.Z - Distance;
	-- Set the new player position.
	Player:SetPosition( Pos );
end

-- SuperForward: Change the X-axis and Y-axis of the position to a forward position.
function SuperGlideForward( Distance )
	-- Retrieve the player camera.
	local Angle = Player:GetCamera();
	-- Retrieve the player position.
	local Pos = Player:GetPosition();
	-- Change the X-axis of the position.
	Pos.X = Pos.X + Distance * math.sin( Angle.X / 180 * math.pi );
	-- Change the Y-axis of the position.
	Pos.Y = Pos.Y - Distance * math.cos( Angle.X / 180 * math.pi );
	-- Set the new player position.
	Player:Setposition( Pos );
end

-- SuperGlideUp: Change the Z-axis of the position to a lower position.
function SuperGlideUp( Distance )
	-- Retrieve the player position.
	local Pos = Player:GetPosition();
	-- Change the Z-axis of the position.
	Pos.Z = Pos.Z + Distance;
	-- Set the new player position.
	Player:SetPosition( Pos );
end

--------------------------------------------------
--          K E Y   H A N D L E R S [C]         --
--------------------------------------------------

-- KeyCheatingAutomatic: Automatic Circular Teleportation
function KeyCheatingAutomatic()
	-- Check if the CircularTeleportation is empty.
	if CircularTeleportation == nil then
		-- Visual reference.
		Write( "KeyCheatingAutomatic: Kill the target." );
		-- Automatic Circular Teleportation
		CheatingAutomatic( Player:GetPosition(), Settings.AutomaticStepSize );
	-- Otherwise the CircularTeleportation is not empty.
	else
		-- Visual reference.
		Write( "KeyCheatingAutomatic: Stop killing the target." );
		-- Clear the CircularTeleportation.
		CircularTeleportation = nil;
	end
end

-- KeyCheatingApproach: Approach Target
function KeyCheatingApproach()
	-- Check if we are moving, in which case we stop movement.
	if Player:IsMoving() then
		Player:SetMove( nil );
	-- Otherwise start movement.
	else
		-- Retrieve the entity.
		local Entity = EntityList:GetEntity( Player:GetTargetID());
		-- Check if the entity is a monster and is not friendly.
		if Entity ~= nil and Entity:IsMonster() and not Entity:IsFriendly() then
			CheatingApproach( Entity:GetPosition());
		end
	end
end

--------------------------------------------------
--          K E Y   H A N D L E R S [S]         --
--------------------------------------------------

-- KeySuperGlideDownAccurate: Accurate Super Glide Down
function KeySuperGlideDownAccurate()
	SuperGlideDown( Settings.SuperGlideDistanceAccurate );
end

-- KeySuperGlideForwardAccurate: Accurate Super Glide Forward
function KeySuperGlideForwardAccurate()
	SuperGlideForward( Settings.SuperGlideDistanceAccurate );
end

-- KeySuperGlideUpAccurate: Accurate Super Glide Up
function KeySuperGlideUpAccurate()
	SuperGlideUp( Settings.SuperGlideDistanceAccurate );
end

-- KeySuperGlideDownCoarse: Coarse Super Glide Down
function KeySuperGlideDownCoarse()
	if not Settings.SuperGlideRestrict or Player:IsGliding() then
		SuperGlideDown( Settings.SuperGlideDistanceCoarse );
	end
end

-- KeySuperGlideForwardCoarse: Coarse Super Glide Forward
function KeySuperGlideForwardCoarse()
	if not Settings.SuperGlideRestrict or Player:IsGliding() then
		SuperGlideForward( Settings.SuperGlideDistanceCoarse );
	end
end

-- KeySuperGlideUpCoarse: Coarse Super Glide Up
function KeySuperGlideUpCoarse()
	if not Settings.SuperGlideRestrict or Player:IsGliding() then
		SuperGlideUp( Settings.SuperGlideDistanceCoarse );
	end
end