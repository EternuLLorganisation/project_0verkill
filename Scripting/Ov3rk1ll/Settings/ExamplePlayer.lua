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

	-- Indicates whether or not attacking is allowed.
	self.AllowAttack = true;
	-- Indicates whether or not to allow the framework to respond on brands (Requires AllowAttack).
	self.AllowBranding = true;	
	-- (NOT RECOMMENDED) Indicates whether or not attack routines are to be ran much and much more often.
	self.AllowInsaneCpuConsumption = false;
	-- Indicates whether or not to allow looting of targets (Requires AllowAttack).
	self.AllowLoot = true;
	-- Indicates whether or not to allow hitting on damage-reflection based states (Requires AllowAttack).
	self.AllowReflect = false;
	-- Indicates whether or not to allow resting (Requires AllowAttack).
	self.AllowRest = true;
	-- Indicdates whether or not resurrecting and quitting is allowed.
	self.AllowRessurectQuit = true;
	-- Indicates whether or not it is allowed to search for targets (Requires AllowAttack).
	self.AllowTargetSearch = true;
	-- Indicates whether or not it is allowed to follow a loaded path (Requires AllowAttack).
	self.AllowTravel = true;
	-- When enabled, your character will run back to each node after searching. Cannot get stuck this way, but may seem more bot-like.
	self.AllowTravelPerfect = false;
	-- Contains the maximum allowed range to the master, at which point the character will run to the master.
	self.MasterFollowRange = 5;
	-- Contains the minimum allowed range to the master, at which point the character will stop moving towards the master.
	self.MasterMinimumRange = 0;
	-- Contains the name of the master, whom is to be followed around while avoiding the branding system (Requires AllowAttack).
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
		AllowAttackDelay = true,
		-- Indicates whether or not high mana consumption skills such as Enfeebling Burst and Call Lightning.
		AllowAttackMana = false,
		-- Indicates whether or not approaching a target is allowed. Auto approach must be enabled for this to work.
		AllowApproach = false,
		-- Indicates whether or not buffing force members is allowed. Disable this if you want to run as an assisting script.
		AllowBuff = true,
		-- Indicates whether or not buffing force members is allowed.
		AllowBuffForce = false,
		-- Indicates whether or not healing is allowed. Disable this if you want to run as an assisting script.
		AllowHealing = true
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
		-- Indicates whether or not to allow trap skills.
		AllowTraps = true,
		-- Indicates whether or not sleeping multiple attackers is allowed.
		AllowSleep = true
	};
	
	-- "This will only hurt for a second."
	self.Sorcerer = {
		-- Indicates whether or not to allow boss mode, which uses a different rotation without slow effects.
		AllowGroupRotation = false
	};
	
	-- "Never fight alone."
	self.SpiritMaster = {
		-- Indicates whether or not to preserve mana. Damage-over-time skills are not applied after 50%.
		AllowPreserveMana = true
	};
	
	-- "You're only as good as your armor."
	self.Templar = {
		-- Indicates whether or not Doom Lure is allowed, which is pointless on bosses.
		AllowDoomLure = false,
		-- Indicates whether or not skills using DP are allowed.
		AllowDpSkills = true,
		-- Indicates whether or not taunting is allowed and should be performed.
		AllowTaunting = false,
		-- Indicates whether or not to taunt without continously spamming it.
		AllowSmartTaunting = true
	};
		
end