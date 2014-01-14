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

--[[

	Public Variables
	
		Controller			- Contains the controller instance. This can either be a player- or class-specific file.
		Class				- Contains the class instance. This is available when a player-specific file has been loaded.
		Framework			- Contains the framework functionality. These functions are used to run the engine.
		Helper				- Contains the helper functionality. These functions make it easier to execute actions.
		
	Private Variables
	
		_IsDead				- Indicates the target has died. Looting is only attempted once in case of full inventory.
		_IsResting			- Indicates whether or not the character is currently allowed to rest.
		_ForceLogout		- Indicates a force logout is coming up.
		_PositionStart		- Contains the starting position. This is used when no travel path has been allowed or loaded.
		_TravelStart		- Contains the object at which the travel list started.
		_TravelTimer		- Contains a timer indicating when to run to the next node.
		_SelectForce		- Contains the identifier of the entity to select. Used to avoid auto attacks on reflect.
		_SelectPrevious		- Contains the identifier of the previously selected entitiy.
		_SelectTimer		- Contains the timer of the previous send select command.
		_NumberOfLoot		- Contains the amount of times loot has been attempted.
		
	Room for Improvement
	
		Check inventory to see if you have room for additional items.
		Check for Loot windows, automatically roll and accept items.

]]--

--- OnLoad is called when the script is being initialized.
--
-- @return	void

function OnLoad()
	
if Settings == nil or Helper == nil or Settings.Initialize == nil then
		Write( "Unable to find/load the framework settings/helper functions!" );
		Close();
		return false;
	end

	Settings:Initialize();
	
	Controller = Include( "Ov3rk1ll/Players/" .. Player:GetName() .. ".lua" );
	PlayerInput:Console("/createchannel BuffLogs")
	Write( "Channel 5 'BuffLogs' Created SUCCESSFULLY!" );
	
	
	if Controller == nil then
		Controller = Include( "Ov3rk1ll/Classes/" .. Player:GetClass():ToString() .. ".lua" );
	else
		Class = Include( "Ov3rk1ll/Classes/" .. Player:GetClass():ToString() .. ".lua" );
	end

	lastMob = nil;

end

--- OnFrame: Detect movement stop on a per-frame basis to quickly chain movement.
--
-- @return	void

function OnFrame()
			if self._IsMoving then
				self:OnRun();
				self._IsMoving = false;
		else
			self._IsMoving = true;
		end
	end

--- OnRun is called each frame to advance the script logic.
--
-- @return	void

--function _StartsWith( String, Start )
--   return string.sub( String, 1, string.len( Start )) == Start;
--end
function OnRun()
			
	local EntityState = Player:GetState();
	local DebuffNumber = 0;
	local InventorySmall = InventoryList:GetInventory( "Lesser Healing Potion" );
	local InventoryLarge = InventoryList:GetInventory( "Greater Healing Potion" );
	local Entity = EntityList[Player:GetTargetID()];
	
	-- Function to buff / scroll you up. Assassins - DO NOT put your poison here!
	-- Avoid running into errors
	if _NotBuffed ~= nil then

		-- Avoid running into errors
		if food_scroll_numbers == nil or food_scroll_names == nil then
			Write( "food_scroll_numbers or food_scroll_names does not exist");
			return;
		end
		if #food_scroll_numbers ~= #food_scroll_names then
			Write( "unequal length of food_scroll_numbers and food_scroll_names");
			return;
		end
		-- Starting actuall Buff check and buff process
		for k = 1, #food_scroll_numbers, 1 do
	
			if Player:GetState():GetState( food_scroll_numbers[k] ) == nil and Helper:CheckAvailableInventory( food_scroll_names[k] ) and not Player:IsHidden() then
				if CheckScroll(food_scroll_names[k]) and TimeScroll < Time() then
					PlayerInput:Inventory( food_scroll_names[k] );
					TimeScroll = Time() + 15000;
					PlayerInput:Console ("/5 " .. (food_scroll_names[k]) .. " used.");
				elseif not CheckScroll(food_scroll_names[k]) then
					PlayerInput:Inventory( food_scroll_names[k] );
				end
			end
		end
	end
	-- Anti-AFK funtion: prevents from server disconnecting you for being AFK too long!
	-- Credit goes to Blastradius
	if _AFK ~= nil then
		if AFKTime == nil or AFKTime < Time() then
	
			PlayerInput:Console( "/Skill Toggle Combat" );
			PlayerInput:Console( "/Skill Toggle Rest");
			Write ("Window Interaction completed - will reinteract in 3 minutes");
			
			
			AFKTime = Time() + (60000 * 2) ; -- 2 Minutes
		end
	end

	-- Anti-Silence
	--if EntityState ~= nil and ( InventorySmall ~= nil or InventoryLarge ~= nil ) then
			
	--	for j = 0, EntityState:GetStateSize() - 1, 1 do
		
	--		local Skill = EntityState:GetStateIndex( j );
			
	--		if Skill:IsDebuff() then
			
	--			DebuffNumber = DebuffNumber + 1;
				
	--			if  _StartsWith( Skill:GetName(), "Silence Arrow" )
	--				or _StartsWith( Skill:GetName(), "Signet Silence" )
	--				or _StartsWith( Skill:GetName(), "Soul Freeze" )
	--				or _StartsWith( Skill:GetName(), "Sigil of Silence" )
	--				or Skill:GetName() == "Godstone: Jumentis's Pacification"
	--				or Skill:GetName() == "Godstone: Sigyn's Tranquility"
	--				or Skill:GetName() == "Godstone: Khrudgelmir's Tacitness"
	--				or Skill:GetName() == "Godstone: Khrudgelmir's Silence"
	--				or Skill:GetName() == "Godstone: Beritra's Plot" then
	--
	--				if DebuffNumber == 1 and InventorySmall ~= nil and InventorySmall:GetCooldown() == 0 then
	--					PlayerInput:Inventory( "Lesser Healing Potion" );
	--					PlayerInput:Console( "/5 !!!STUNNED!!! " );
	--					return;
	--				elseif DebuffNumber == 2 and InventoryLarge ~= nil and InventoryLarge:GetCooldown() == 0 then
	--					PlayerInput:Inventory( "Greater Healing Potion" );
	--					PlayerInput:Console ("/5 !!!STUNNED!!! " );
	--					return;
	--				end
	--					
	--			end
	--				
	--		end
				
	--end
	

	-- Kill it!	
	if Entity == nil or Entity:IsDead() or Player:IsDead() then
			_AttackStarted = nil;
			return false;
	end

	local EntityState = Entity:GetState();

	if allowCheckTarget and (Entity:IsHostile() or Entity:IsMonster()) and lastMob ~= Entity then
			lastMob = Entity;
	end


	-- Healing sequence for classes who use it

		if Controller.Heal ~= nil and not Controller:Heal( true ) then
			return false;
		end
		
		if Controller.Force ~= nil and not Controller:Force() then
			return false;
		end
		
		if Controller.Heal ~= nil and not Controller:Heal( false ) then
			return false;
		end
	
	cT(Entity, lastMob);
	if Controller.Attack ~= nil and not Entity:IsFriendly() then
		
	Controller:Attack( Entity, Entity:GetPosition():DistanceToPosition( Player:GetPosition()) );
	return true;
	end
end