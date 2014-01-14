--[[

	--------------------------------------------------
	Copyright (C) 2011 Blastradius

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
	--------------------------------------------------
	
]]--

--- Check if the provided ability is available and has cooled down.
--
-- @param	string	Name of the ability to check.
-- @param	bool	Indicates whether or not to skip the activation check.
-- @return	boolean

function CheckAvailable( Name, SkipActivation )

	-- Retrieve the ability with the provided name.
	local Ability = AbilityList:GetAbility( Name );

	-- Check if the ability is valid and is not in cooldown.
	if Ability ~= nil and Ability:GetCooldown() == 0 and ( SkipActivation ~= nil or Ability:GetActivated()) then
		return true;
	end

	-- Either we do not have the ability or it is in cooldown.
	return false;
	
end

--- Check if the provided inventory is available and has cooled down.
--
-- @param	string	Name of the inventory to check.
-- @param	integer	Contains the amount required to check, instead of a valid cooldown.
-- @return	boolean

function CheckAvailableInventory( Name, Amount )

	-- Retrieve the item with the provided name.
	local Inventory = InventoryList:GetInventory( Name );

	-- Check if the item is valid and is not in cooldown.
	if Inventory ~= nil and (( Amount == nil and Inventory:GetCooldown() == 0 ) or ( Amount ~= nil and Inventory:GetAmount() >= Amount )) then
		return true;
	end

	-- Either we do not have the item or it is in cooldown.
	return false;
	
end

--- Checks if the target we have matches the conditions to cast friendly magic.
--
-- @param	Entity	Contains the entity to match the target on.
-- @param	bool	Indicates whether or not this is a hostile spell.
-- @return	bool

function CheckExecute( Name, Entity )

	-- Retrieve the ability with the provided name.
	local Ability = AbilityList:GetAbility( Name );
	
	-- Check if the provided ability is available and return when it is not.
	if Ability == nil or Ability:GetCooldown() ~= 0 then
		return false;
	end
	
	-- Check if I am currently resting and stop resting when I am!
	if Player:IsResting() then
		PlayerInput:Ability( "Toggle Rest" );
		return false;
	end
	
	-- Check if this is a friendly ability with my own character as the target.
	if Entity ~= nil and Player:GetID() == Entity:GetID() then
		
		-- Retrieve the skill based on the ability identifier.
		local Skill = SkillList:GetSkill( Ability:GetID());
	
		-- It is not possible to perform a hostile skill on my own character.
		if Skill == nil or Skill:IsAttack() then
			return false;
		end
		
		-- When no target has been selected we can execute the ability.
		if Player:GetTargetID() == 0 then
			return PlayerInput:Ability( Name );
		end
		
		-- Otherwise retrieve the entity we currently have selected.
		local EntityTarget = EntityList:GetEntity( Player:GetTargetID());
		
		-- When the target is valid and is not friendly we can use our ability.
		if EntityTarget ~= nil and not EntityTarget:IsFriendly() then
			return PlayerInput:Ability( Name );
		end
		
	end

	-- Check if the target entity has been selected and select it when it is needed.
	if Entity ~= nil and Player:GetTargetID() ~= Entity:GetID() then
		Player:SetTarget( Entity );
		return false;
	end
	
	-- Everything seems to be valid 
	return PlayerInput:Ability( Name );
	
end

--- Check if a herb treatment can be executed and execute it when required.
--
-- @return	boolean

function CheckHerbTreatment()

	-- Retrieve the total health recharge required.
	local TotalRecharge = Player:GetHealthMaximum() - Player:GetHealthCurrent();
	
	if Settings.HealthTreatmentTreshhold == 0 or Player:GetHealth() < Settings.HerbTreatmentTreshhold then
		if self:CheckAvailable( "Herb Treatment IV" ) and TotalRecharge >= 648 and self:CheckAvailableInventory( "Fine Odella Powder", 2 ) then
			self:CheckExecute( "Herb Treatment IV" );
			return false;
		elseif self:CheckAvailable( "Herb Treatment III" ) and TotalRecharge >= 535 and self:CheckAvailableInventory( "Greater Odella Powder", 2 ) then
			self:CheckExecute( "Herb Treatment III" );
			return false;
		elseif self:CheckAvailable( "Herb Treatment II" ) and TotalRecharge >= 404 and self:CheckAvailableInventory( "Odella Powder", 2 ) then
			self:CheckExecute( "Herb Treatment II" );
			return false;
		elseif self:CheckAvailable( "Herb Treatment I" ) and TotalRecharge >= 298 and self:CheckAvailableInventory( "Lesser Odella Powder", 2 ) then
			self:CheckExecute( "Herb Treatment I" );
			return false;
		end
	end
	
	-- Return true when nothing is executed.
	return true;
	
end

--- Checks if the provided Entity has one of the known reflection-based states.
--
-- @param	Entity	Contains the entity to check for reflect.
-- @return	bool

function CheckMelee()

	-- Retrieve the class of the current character.
	local Class = Player:GetClass():ToString();
	
	-- Check if the class is a focused melee-orientated class.
	if Class == "Assassin" or Class == "Chanter" or Class == "Gladiator" or Class == "Ranger" or Class == "Templar" then
		return true;
	end
	
	-- Otherwise return false, since we are a magical-based class.
	return false;
	
end

--- Check if a mana treatment can be executed and execute it when required.
--
-- @return	boolean

function CheckManaTreatment()

	-- Retrieve the total mana recharge required.
	local TotalRecharge = Player:GetManaMaximum() - Player:GetManaCurrent();
	
	if Settings.ManaTreatmentTreshhold == 0 or Player:GetMana() < Settings.ManaTreatmentTreshhold then
		if self:CheckAvailable( "Mana Treatment IV" ) and TotalRecharge >= 648 and self:CheckAvailableInventory( "Fine Odella Powder", 2 ) then
			self:CheckExecute( "Mana Treatment IV" );
			return false;
		elseif self:CheckAvailable( "Mana Treatment III" ) and TotalRecharge >= 535 and self:CheckAvailableInventory( "Greater Odella Powder", 2 ) then
			self:CheckExecute( "Mana Treatment III" );
			return false;
		elseif self:CheckAvailable( "Mana Treatment II" ) and TotalRecharge >= 404 and self:CheckAvailableInventory( "Odella Powder", 2 ) then
			self:CheckExecute( "Mana Treatment II" );
			return false;
		elseif self:CheckAvailable( "Mana Treatment I" ) and TotalRecharge >= 298 and self:CheckAvailableInventory( "Lesser Odella Powder", 2 ) then
			self:CheckExecute( "Mana Treatment I" );
			return false;
		end
	end
	
	-- Return true when nothing is executed.
	return true;
	
end

--- Check if the provided ability is available and return the full name.
--
-- @param	string	Name of the ability to check.
-- @return	boolean

function CheckName( zName )

	-- Get the ability with the provided name.
	local Ability = AbilityList:GetAbility( zName );
	
	-- Check if the ability is valid (you have learned it) and 
	if Ability ~= nil then
		return Ability:GetName();
	end
	
	-- We do not have the ability, return nothing.
	return nil;
	
end

--- Check the travel position and find the nearest node.
--
-- @return	boolean

function CheckTravelPosition()

	if TravelList == nil then
		-- Write( "No travel path has been loaded!" )
		return false;
	elseif TravelList:GetList().Count < 2 then
		-- Write( "Travel list has 0 or 1 node!" );
		return false;
	elseif TravelList:GetList().Count > 1 then
	
		local BestDistance = 100;
		local BestTravel = nil;
		
		for Travel in ListIterator( TravelList:GetList()) do
			local CurrentDistance = Player:GetPosition():DistanceToPosition( Travel:GetPosition());
			if Travel == nil or CurrentDistance < BestDistance then
				BestTravel = Travel;
				BestDistance = CurrentDistance;
			end
		end
	
		while true do
			if TravelList:GetNext() == BestTravel then
				TravelList:Move();
				return true;
			end
		end
				
	end

	return false;
	
end

--- Checks the best potion required for the current level of the player mana and uses it.
--
-- @return	boolean

function CheckPotionMana()

	-- Prepare the variables to contain the best item and recharge.
	local BestInventory = nil;
	local BestRecharge = 0;
	local TotalRecharge = Player:GetManaMaximum() - Player:GetManaCurrent();
	
	-- Check if a potion is available.
	if self._iPotionDelay == nil or self._iPotionDelay < Time() then

		-- Loop through your inventory.
		for Inventory in ListIterator( InventoryList:GetList()) do

			-- Check if this is a mana elixer or mana potion.
			if string.find( Inventory:GetName(), "Design" ) == nil and ( string.find( Inventory:GetName(), "Mana Elixir" ) ~= nil or string.find( Inventory:GetName(), "Mana Potion" ) ~= nil ) then
				if string.find( Inventory:GetName(), "Fine" ) ~= nil then
					if TotalRecharge >= 1830 and BestRecharge < 1830 then
						BestInventory = Inventory;
						BestRecharge = 1830; -- 1530;
					end
				elseif string.find( Inventory:GetName(), "Major" ) ~= nil then
					if TotalRecharge >= 1600 and BestRecharge < 1600 then
						BestInventory = Inventory;
						BestRecharge = 1600; -- 1340;
					end
				elseif string.find( Inventory:GetName(), "Greater" ) ~= nil then
					if TotalRecharge >= 1480 and BestRecharge < 1480 then
						BestInventory = Inventory;
						BestRecharge = 1480; -- 1240;
					end
				elseif string.find( Inventory:GetName(), "Lesser" ) ~= nil then
					if TotalRecharge >= 950 and BestRecharge < 950 then
						BestInventory = Inventory;
						BestRecharge = 950; -- 820;
					end
				elseif string.find( Inventory:GetName(), "Minor" ) ~= nil then
					if TotalRecharge >= 590 and BestRecharge < 590 then
						BestInventory = Inventory;
						BestRecharge = 590; -- 500;
					end
				elseif TotalRecharge >= 1280 and BestRecharge < 1280 then
					BestInventory = Inventory;
					BestRecharge = 1280; -- 1070;
				end
				
			end

		end
		
		-- Check if we have a positive match and see if the cooldown allows the use of it.
		if BestInventory ~= nil and BestInventory:GetCooldown() == 0 then
			if PlayerInput:Inventory( BestInventory:GetName()) then
				self._iPotionDelay = Time() + BestInventory:GetReuse();
			end
			return false;
		end
		
	end
	
	-- We have not executed any potion.
	return true;
	
end

--- Checks the best potion required for the current level of the player health and uses it.
--
-- @return	boolean

function CheckPotionHealth()

	-- Prepare the variables to contain the best item and recharge.
	local BestInventory = nil;
	local BestRecharge = 0;
	local TotalRecharge = Player:GetHealthMaximum() - Player:GetHealthCurrent();
	
	-- Check if a potion is available.
	if self._iPotionDelay == nil or self._iPotionDelay < Time() then
	
		-- Loop through your inventory
		for Inventory in ListIterator( InventoryList:GetList()) do

			-- Check if this is a life potion
			if string.find( Inventory:GetName(), "Design" ) == nil and ( string.find( Inventory:GetName(), "Life Elixir" ) ~= nil or string.find( Inventory:GetName(), "Life Potion" ) ~= nil ) then
				
				if string.find( Inventory:GetName(), "Fine" ) ~= nil then
					if TotalRecharge >= 2120 and BestRecharge < 2120 then
						BestInventory = Inventory;
						BestRecharge = 2120;
					end
				elseif string.find( Inventory:GetName(), "Major" ) ~= nil then
					if TotalRecharge >= 1540 and BestRecharge < 1540 then
						BestInventory = Inventory;
						BestRecharge = 1540;
					end
				elseif string.find( Inventory:GetName(), "Greater" ) ~= nil then
					if TotalRecharge >= 1270 and BestRecharge < 1270 then
						BestInventory = Inventory;
						BestRecharge = 1270;
					end
				elseif string.find( Inventory:GetName(), "Lesser" ) ~= nil then
					if TotalRecharge >= 670 and BestRecharge < 670 then
						BestInventory = Inventory;
						BestRecharge = 670;
					end
				elseif string.find( Inventory:GetName(), "Minor" ) ~= nil then
					if TotalRecharge >= 370 and BestRecharge < 370 then
						BestInventory = Inventory;
						BestRecharge = 370;
					end
				elseif TotalRecharge >= 970 and BestRecharge < 970 then
					BestInventory = Inventory;
					BestRecharge = 970;
				end
				
			end

		end
		
		-- Check if we have a positive match and see if the cooldown allows the use of it.
		if BestInventory ~= nil and BestInventory:GetCooldown() == 0 then
			if PlayerInput:Inventory( BestInventory:GetName()) then
				self._iPotionDelay = Time() + BestInventory:GetReuse();
			end
			return false;
		end
	
	end
	
	-- We have not executed any potion.
	return true;
	
end

--- Checks the best potion required for the current level of the player health/mana and uses it.
--
-- @return	boolean

function CheckPotionRecovery()

	-- Prepare the variables to contain the best item and recharge.
	local BestInventory = nil;
	local BestRecharge = 0;
	local TotalRechargeHealth = Player:GetHealthMaximum() - Player:GetHealthCurrent();
	local TotalRechargeMana = Player:GetManaMaximum() - Player:GetManaCurrent();
	
	-- Check if a potion is available.
	if self._iPotionDelay == nil or self._iPotionDelay < Time() then
		
		-- Loop through your inventory
		for Inventory in ListIterator( InventoryList:GetList()) do

			-- Check if this is a life potion
			if string.find( Inventory:GetName(), "Design" ) == nil and string.find( Inventory:GetName(), "Recovery Potion" ) ~= nil then
				
				if string.find( Inventory:GetName(), "Fine" ) ~= nil then
					if TotalRechargeHealth >= 2120 and TotalRechargeMana >= 1830 and BestRecharge < 2120 then
						BestInventory = Inventory;
						BestRecharge = 2120;
					end
				elseif string.find( Inventory:GetName(), "Major" ) ~= nil then
					if TotalRechargeHealth >= 1540 and TotalRechargeMana >= 1600 and BestRecharge < 1540 then
						BestInventory = Inventory;
						BestRecharge = 1540;
					end
				elseif string.find( Inventory:GetName(), "Greater" ) ~= nil then
					if TotalRechargeHealth >= 1270 and TotalRechargeMana >= 1480 and BestRecharge < 1270 then
						BestInventory = Inventory;
						BestRecharge = 1270;
					end
				elseif string.find( Inventory:GetName(), "Lesser" ) ~= nil then
					if TotalRechargeHealth >= 670 and TotalRechargeMana >= 980 and BestRecharge < 670 then
						BestInventory = Inventory;
						BestRecharge = 670;
					end
				elseif string.find( Inventory:GetName(), "Minor" ) ~= nil then
					if TotalRechargeHealth >= 370 and TotalRechargeMana >= 590 and BestRecharge < 370 then
						BestInventory = Inventory;
						BestRecharge = 370;
					end
				elseif TotalRechargeHealth >= 970 and TotalRechargeMana >= 1280 and BestRecharge < 970 then
					BestInventory = Inventory;
					BestRecharge = 970;
				end
				
			end

		end
		
		-- Check if we have a positive match and see if the cooldown allows the use of it.
		if BestInventory ~= nil and BestInventory:GetCooldown() == 0 then
			if PlayerInput:Inventory( BestInventory:GetName()) then
				self._iPotionDelay = Time() + BestInventory:GetReuse();
			end
			return false;
		end
		
	end
	
	-- We have not executed any potion.
	return true;
	
end

--- Checks if the provided Entity has one of the known reflection-based states.
--
-- @param	Entity	Contains the entity to check for reflect.
-- @return	bool

function CheckReflect( Entity )

	-- Check if the provided entity is valid.
	if Entity == nil then
		return false;
	end 
	
	-- Retrieve the state for this entity to check for known reflect states.
	local EntityState = Entity:GetState();
	
	-- Check if the retrieved entity state is valid.
	if EntityState == nil then
		return false;
	end
	
	-- Check the list of known reflection states.
	if EntityState:GetState( "Stigma: Protection" ) ~= nil
		or EntityState:GetState( "Punishment" ) ~= nil
		or EntityState:GetState( "Nightmare" ) ~= nil
		or EntityState:GetState( "Wintry Armor" ) ~= nil
		or EntityState:GetState( "Fatal Reflection" ) ~= nil
		or EntityState:GetState( "Reflect" ) ~= nil
		or EntityState:GetState( "Reflective Shield" ) ~= nil
		or EntityState:GetState( "Seal of Reflection" ) ~= nil
		or EntityState:GetState( "Shield of Reflection" ) ~= nil
		or EntityState:GetState( "Strike of Protection" ) ~= nil
		or EntityState:GetState( "Blade Storm" ) ~= nil then
		return true;
	end
	
	-- None of the known reflection 
	return false;
	
end