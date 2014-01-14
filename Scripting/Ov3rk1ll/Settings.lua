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

--- Initializes the settings in the framework. You can change settings here or in your loaded script.
--
-- @return	void

function Initialize()

	-- Indicates whether or not to use the boss-mode settings (Overwrites all configured settings).
	self.BossMode = false;
	
	-- Check if boss mode has been enabled and load default boss settings values when this is the case.
	if self.BossMode then
		Write( "WARNING: Boss mode has been enabled!" );
		self:InitializeBoss();
	else

		-- Attempt to load a player-specific settings file, which will take priority over the configured values here.
		local Settings = Include( "OfficialGrinderFramework/Settings/" .. Player:GetName() .. ".lua" );
		
		-- Indicates whether or not attacking is allowed.
		self.AllowAttack = true;
		-- Indicates whether or not to allow the framework to respond on brands (Requires AllowAttack).
		self.AllowBranding = true;	
		-- (NOT RECOMMENDED) Indicates whether or not attack routines are to be ran much and much more often.
		self.AllowInsaneCpuConsumption = true;
		-- Indicates whether or not to allow looting of targets (Requires AllowAttack).
		self.AllowLoot = false;
		-- Indicates whether or not to allow hitting on damage-reflection based states (Requires AllowAttack).
		self.AllowReflect = false;
		-- Indicates whether or not to allow resting (Requires AllowAttack).
		self.AllowRest = true;
		-- Indicdates whether or not resurrecting and quitting is allowed.
		self.AllowRessurectQuit = true;
		-- Indicates whether or not it is allowed to search for targets (Requires AllowAttack).
		self.AllowTargetSearch = true;
		-- Indicates whether or not it is allowed to follow a loaded path.
		self.AllowTravel = true;
		-- When enabled, your character will constantly search for aggressive monsters. Disable for performance gain!
		self.AllowTravelAggressionCheck = false;
		-- When enabled, your character will run back to each node after searching. Cannot get stuck this way, but may seem more bot-like.
		self.AllowTravelPerfect = false;
		-- Indicates whether or not the herb treatment skill is allowed to be used (Requires AllowAttack).
		self.HerbTreatment = true;
		-- Contains the treshold before herb treatment is used (In percentages, or 0 to recharge an exact amount).
		self.HerbTreatmentTreshhold = 40;
		-- Contains the maximum allowed range to the master, at which point the character will run to the master.
		self.MasterFollowRange = 5;
		-- Contains the minimum allowed range to the master, at which point the character will stop moving towards the master.
		self.MasterMinimumRange = 0;
		-- Contains the name of the master, whom is to be followed around while avoiding the branding system (Requires AllowAttack).
		--   This setting should be placed in quotes, for example "Blastradius" or "TheyRot".
		--   If you do not place the name in quotes, the script will behave as if you did not set anything at all.
		self.MasterName = nil;
		-- Indicates whether or not to provide support when the master is attacking an enemy (Requires AllowAttack).
		self.MasterSupport = true;
		-- Indicates whether passive or active support is used; In Active mode, each select marks the target, while in passive, attack when the master is attacking.
		self.MasterSupportActive = false;
		-- Indicates whether or not potions are allowed (does not use Serums, only Elixir and Potions).
		self.Potion = true;
		-- Contains the remaining amount of health required before potions are used (0 = disabled).
		self.PotionHealth = 80;
		-- Contains the remaining amount of mana required before potions are used (0 = disabled).
		self.PotionMana = 40;
		-- Contains the remaining amount of health and mana required before potions are used (0 = disabled).
		self.PotionRecovery = 30;
		-- Contains the remaining amount of health required before resting (Requires AllowRest).
		self.RestHealth = 50;
		-- Contains the remaining amount of mana required before resting (Requires AllowRest).
		self.RestMana = 40;
		-- Contains the remaining amount of flight time required before resting (Requires AllowRest).
		self.RestFlight = 60;
		-- Indicates whether or not the mana treatment skill is allowed to be used (Requires AllowAttack).
		self.ManaTreatment = true;
		-- Contains the treshold before mana treatment is used (In percentages, or 0 to recharge an exact amount).
		self.ManaTreatmentTreshhold = 70;
		-- Contains the maximum distance of the area in which to search for targets (Requires AllowTargetSearch).
		self.TargetSearchDistance = 15;
		-- Contains the minimum delay to wait at each action node (Requires AllowTravel).
		self.TravelDelay = 0;
			
		-- "Protect me and you shall never fall."
		self.Cleric = {
			-- Indicates whether or not attacking is allowed. Cleric version to allow following and such.
			AllowAttack = true,
			-- Indicates whether or not delaying for a Noble Energy or Holy Servant is required before attacking.
			AllowAttackDelay = false,
			-- Indicates whether or not high mana consumption skills such as Enfeebling Burst and Call Lightning.
			AllowAttackMana = false,
			-- Indicates whether or not approaching a target is allowed. Auto approach must be enabled for this to work.
			AllowApproach = false,
			-- Indicates whether or not buffing force members is allowed. Disable this if you want to run as an assisting script.
			AllowBuff = true,
			-- Indicates whether or not buffing force members is allowed.
			AllowBuffForce = false,
			-- Indicates whether or not healing is allowed. Disable this if you want to run as an assisting script.
			AllowHealing = true,
			-- Indicates whether or not using Rebirth is allowed.
			AllowRebirth = true,
			-- Indicates whether or not using Summer Circle is allowed.
			AllowSummerCircleBuff = true,
			-- Indicates whether or not using Winter Circle is allowed.
			AllowWinterCircleBuff = false
		};
		
		-- "Nothing can stand in my way!"
		self.Gladiator = {
			-- Indicates whether or not to allow area-of-attack skills.
			AllowAoe = true,
			-- Indicates whether or not to allow Taloc's Hollow Skills
			AllowTalocHollow = true
		};
		
		-- "Chase me or run away. Either way, you'll only die tired."
		self.Ranger = {
			-- Indicates whether or not to allow area-of-attack skills.
			AllowAoe = true,
			-- Indicates whether Mau Form is allowed when grinding.
			AllowMauWhenGrinding = true,
			-- Indicates whether or not to allow trap skills.
			AllowTraps = true,
			-- Indicates whether or not sleeping multiple attackers is allowed.
			AllowSleep = true
		};
		
		-- "This will only hurt for a second."
		self.Sorcerer = {
			-- Indicates whether or not to allow boss mode, which uses a different rotation without slow effects.
			AllowGroupRotation = false,
			-- Indicates whether MP conservation is allowed (Lumiel's Wisdom).
			AllowMpConservation = true
		};
		
		-- "Never fight alone."
		self.SpiritMaster = {
			-- Indicates whether or not to preserve mana. Damage-over-time skills are not applied after 50%.
			AllowPreserveMana = true,
			-- Indicates whehter initial threat with a spirit is prefered.
			AllowInitialThreat = true
		};
		
		-- "You're only as good as your armor."
		self.Templar = {
			-- Indicates whether or not Doom Lure is allowed, which is pointless on bosses.
			AllowDoomLure = true,
			-- Indicates whether or not skills using DP are allowed.
			AllowDpSkills = true,
			-- Indicates whether or not taunting is allowed and should be performed.
			AllowTaunting = false,
			-- Indicates whether or not to taunt without continously spamming it.
			AllowSmartTaunting = true
		};

		-- Check if the player-specific settings file exists and load values from it.
		if Settings ~= nil then

			-- Load the settings from the file to allow the configuration of the framework.
			Settings:Initialize();
			
			-- Loop through the keys and values exposed by the Settings object and import them.
			for k, v in pairs( Settings ) do
				self[k] = v;
			end
			
		end
				
	end
	
end

--- Initializes/overwrites existing settings to comply with the standard boss-hunting roles.
--
-- @return	void

function InitializeBoss()

	-- Indicates whether or not attacking is allowed.
	self.AllowAttack = true;
	-- Indicates whether or not to allow the framework to respond on brands (Requires AllowAttack).
	self.AllowBranding = true;	
	-- (NOT RECOMMENDED) Indicates whether or not attack routines are to be ran much and much more often.
	self.AllowInsaneCpuConsumption = false;
	-- Indicates whether or not to allow looting of targets (Requires AllowAttack).
	self.AllowLoot = false;
	-- Indicates whether or not to allow hitting on damage-reflection based states (Requires AllowAttack).
	self.AllowReflect = false;
	-- Indicates whether or not to allow resting (Requires AllowAttack).
	self.AllowRest = false;
	-- Indicdates whether or not resurrecting and quitting is allowed.
	self.AllowRessurectQuit = false;
	-- Indicates whether or not it is allowed to search for targets (Requires AllowAttack).
	self.AllowTargetSearch = false;
	-- Indicates whether or not it is allowed to follow a loaded path.
	self.AllowTravel = false;
	-- When enabled, your character will constantly search for aggressive monsters. Disable for performance gain!
	self.AllowTravelAggressionCheck = false;
	-- When enabled, your character will run back to each node after searching. Cannot get stuck this way, but may seem more bot-like.
	self.AllowTravelPerfect = false;
	-- Indicates whether or not to provide support when the master is attacking an enemy (Requires AllowAttack).
	self.MasterSupport = false;
	-- Indicates whether passive or active support is used; In Active mode, each select marks the target, while in passive, attack when the master is attacking.
	self.MasterSupportActive = false;
	-- Indicates whether or not potions are allowed (does not use Serums, only Elixir and Potions).
	self.Potion = true;
	-- Contains the remaining amount of health required before potions are used (0 = disabled).
	self.PotionHealth = 80;
	-- Contains the remaining amount of mana required before potions are used (0 = disabled).
	self.PotionMana = 40;
	-- Contains the remaining amount of health and mana required before potions are used (0 = disabled).
	self.PotionRecovery = 30;
	-- Indicates whether or not the mana treatment skill is allowed to be used (Requires AllowAttack).
	self.ManaTreatment = true;
	-- Contains the treshold before mana treatment is used (In percentages, or 0 to recharge an exact amount).
	self.ManaTreatmentTreshhold = 70;
	-- Contains the maximum distance of the area in which to search for targets (Requires AllowTargetSearch).
	self.TargetSearchDistance = 15;
	-- Contains the minimum delay to wait at each action node (Requires AllowTravel).
	self.TravelDelay = 0;
		
	-- Classes belonging to the priest-archtype are not expected to attack or rest.
	if Player:GetClass():ToString() == "Cleric" then
		self.AllowAttack = false;
		self.AllowRest = false;
		self.ManaTreatment = false;
	end
	
	-- "Protect me and you shall never fall."
	self.Cleric = {
		-- Indicates whether or not attacking is allowed. Cleric version to allow following and such.
		AllowAttack = false,
		-- Indicates whether or not delaying for a Noble Energy or Holy Servant is required before attacking.
		AllowAttackDelay = true,
		-- Indicates whether or not high mana consumption skills such as Enfeebling Burst and Call Lightning.
		AllowAttackMana = false,
		-- Indicates whether or not approaching a target is allowed. Auto approach must be enabled for this to work.
		AllowApproach = false,
		-- Indicates whether or not buffing force members is allowed. Disable this if you want to run as an assisting script.
		AllowBuff = true,
		-- Indicates whether or not buffing force members is allowed.
		AllowBuffForce = true,
		-- Indicates whether or not healing is allowed. Disable this if you want to run as an assisting script.
		AllowHealing = true
	};
	
	-- "Nothing can stand in my way!"
	self.Gladiator = {
		-- Indicates whether or not to allow area-of-attack skills.
		AllowAoe = false,
		-- Indicates whether or not to allow Taloc's Hollow Skills
		AllowTalocHollow = false
	};
	
	-- "Chase me or run away. Either way, you'll only die tired."
	self.Ranger = {
		-- Indicates whether or not to allow area-of-attack skills.
		AllowAoe = false,
		-- Indicates whether or not to allow trap skills.
		AllowTraps = false,
		-- Indicates whether or not sleeping multiple attackers is allowed.
		AllowSleep = false
	};
	
	-- "This will only hurt for a second."
	self.Sorcerer = {
		-- Indicates whether or not to allow boss mode, which uses a different rotation without slow effects.
		AllowGroupRotation = true,
		-- Indicates whether MP conservation is allowed (Lumiel's Wisdom).
		AllowMpConservation = true
	};
	
	-- "Never fight alone."
	self.SpiritMaster = {
		-- Indicates whether or not to preserve mana. Damage-over-time skills are not applied after 50%.
		AllowPreserveMana = false,
		-- Indicates whehter initial threat with a spirit is prefered.
		AllowInitialThreat = false
	};
	
	-- "You're only as good as your armor."
	self.Templar = {
		-- Indicates whether or not Doom Lure is allowed, which is pointless on bosses.
		AllowDoomLure = false,
		-- Indicates whether or not skills using DP are allowed.
		AllowDpSkills = false,
		-- Indicates whether or not taunting is allowed and should be performed.
		AllowTaunting = true,
		-- Indicates whether or not to taunt without continously spamming it.
		AllowSmartTaunting = false
	};
		
end