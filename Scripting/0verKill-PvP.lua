-------------------------------------------------------------
--	0v3rk1ll 1.1				   --
-------------------------------------------------------------
--							   --
--	This script uses custom attack scripts and framework  --
--	Original idea / credit: Blastradius & TheRot		  --
--							   --
--							   --
--		et0.NiNJA scripting by 0x00.NiNJA				   --
--							   --
-------------------------------------------------------------

function OnLoad()
	
	Write( "	Welcome to the 0v3rk1ll script! 		" );
	Write( "	Controls:								" );
	Write( "	INSERT	: Turn the auto buff ON/OFF.	");
	Write( "	DELETE	: Turn the auto pot  ON/OFF.	");
	Write( "	END		: Turn the anti AFK: ON/OFF.	");
	Write( "	For more info, visit http://www.eternull.com/aionluascripts	");
	
	-- Settings
	-- Below, where you have    "F"    inside quotes put key code you want for attack sequence.
	-- Check the key codes here (Member Name): http://msdn.microsoft.com/en-us/library/system.windows.input.key.aspx
	Register( "Scroll_Buffs", "Insert" );
	Register( "AntiAFK", "End" );
	Register( "AutoPotFunc", "Delete" );	
	
	-- CheckTarget, it will go back to the target who was being attacked if the scripts target a friendly character (for example as cleric for healing a party member).
	-- You can disable it (change to false) if you want just want the attack sequence to perform faster and spend less cpu.
	allowCheckTarget = false;
	
	-- Auto-Scroll Function, scroll identifiers
	food_scroll_numbers = {9960, 9959, 9957,10019,10094};
	food_scroll_names = {"Greater Running Scroll","Greater Courage Scroll","Major Immortal Crit Strike Scroll", "Tasty Horned Dragon Emperor's Curry", "Tasty Drupa Cocktail" };
	TimeScroll = 0;
	-- End Settings
	
	
	
	Settings = Include( "Ov3rk1ll/Settings.lua" );
	Helper = Include( "Ov3rk1ll/HelperFunction.lua" );
	
	Framework = Include( "Ov3rk1ll/0verkillFramework.lua" );
	Framework:OnLoad();
	
end

function OnRun()
		Framework:OnFrame();
end

function cT(Entity, lastMob)

	if allowCheckTarget and Entity ~= nil and lastMob ~= nil then

		if not Entity:IsMonster() and not Entity:IsDead() and Entity:IsFriendly() then

			if lastMob ~= Entity and not lastMob:IsDead() then
				Player:SetTarget(lastMob);
				-- Just in case Aion's a bitch
				Player:SetTarget(lastMob);
			end

		end
	
	end

end

function OnFrame()
	Framework:OnFrame();
		Framework:OnRun();
end

function CheckScroll(Name)
    local Inventory = InventoryList:GetInventory(Name);
        if Inventory ~= nil and Inventory:GetType():ToString() == "Scroll" then
            return true;
        end
return false;
end

function Scroll_Buffs()
	if _NotBuffed == true then
		_NotBuffed = nil;
		Write( "Auto-Buff: Off" );
		PlayerInput:Console("/5 	Auto-Buff: 		ON	..")
	else
		_NotBuffed = true;
		Write( "Auto-Buff: On" );
		PlayerInput:Console("/5 	Auto-Buff:		OFF	..")
	end
end

function AntiAFK()
	if _AFK == true then
		_AFK = nil;
		Write( "	AFK-Mode: Off	" );
		PlayerInput:Console("/l back !!!");
	else
		_AFK = true;
		Write( "	AFK-Mode: ON	" );
		PlayerInput:Console("/l going afk, brb guys!");
	end
end

function AutoPotFunc()
	if _AutoPot == true then
		_AutoPot = nil;
		Write( "	Auto-Pot: OFF	" );
	else
		_AutoPot = true;
		Write( "	Auto-Pot: ON	" );
	end
end