--[[
	Hand in AP-items for AP (0.1) by TheyRot
	
	This function is based upon: AP counter [1.0], by Theyrot and Blastradius.
	
	AP items are often dropped in instances of forts, which allow you to add additional AP to your total AP count. This script allows you to set a 
	number of AP you want to add, coming from AP items. Obviously, you need to have that amount in AP-items. There is a safety check for that. Upon
	setting AP_to_be_added to nil or higher than your amount of AP-items actually holds, it will hand in the maximum. The AP-item priority is currently
	set to pick the lowest AP-item, and then moves its way up. The order of preference is (used in Determine_AP_items_to_hand_in):
		Lesser Ancient Icon		300
		Lesser Ancient Seal		600
		Ancient Icon			600
		Lesser Ancient Goblet	 	800
		Greater Ancient Icon		800
		Ancient Seal			1200
		Lesser Ancient Crown		1600
		Ancient Goblet			1600
		Major Ancient Icon		1600
		Greater Ancient Seal		1800
		Greater Ancient Goblet		2400
		Major Ancient Seal		2400
		Ancient Crown			3200
		Major Ancient Goblet		3200
		Greater Ancient Crown		4800
		Major Ancient Crown		6400
	This script has to be started when you are in the vicinity of the NPCs which allow you to hand in the AP-items.
	
	The script consists of the following functions:
	OnLoad: 						Allows you to set the amount of AP from the AP-items, and select your race
		- GetCurrentAP				Computes the maximum amount of AP-items (integer), the number of AP-items (integer) and the AP-item distribution (4x4 matrix)
			- AddAP 				Adds a certain amount of AP to the maximum AP from items counter.
		- Determine_AP_items_to_hand_in 	The AP-items in your inventory are known, and this function picks the ones necessary to hand in your pre-defined AP number.				
	OnRun						Every 250ms this function is called. This function checks if there are still items to be handed in.
		- Handle_Delivery_AP_items 		The items which are checked in OnRun are handed in.
	
--]]

-- OnLoad function --
-- Allows you to set the amount of AP from the AP-items, and select your race. If you are merely using this script, do not touch the rest.
function OnLoad()

	-- User settings
	AP_to_be_added = nil  	-- Make nil to automaticaly hand in everything
	hand_in_type = 1		-- 1: icons, seals, goblets, crowns; 2: crowns, goblets, seals, icons
	bIsCore = true 			-- Compute AP when handed in at core
	
	-- Script setitngs, do not touch
	timer = 0;				-- a timer used to slow down the clicking process, when handing in AP-items
	Item_ID = 0;			-- ID of the item that has just been handed in
	
	-- Safety check for running this script
	if EntityList:GetEntity( "Amarunerk") then
		Core = true
	elseif EntityList:GetEntity( "Iacchus" ) == nil then
		if EntityList:GetEntity( "Byrgafa" ) == nil then
			Write("none of the NPCs is in the vicinity")
			Close()
		else
			Elyos = false
			Core = false
		end
	else
		Elyos = true
		Core = false
	end
	
	
	-- Determine the amount of AP to be handed in. This can be your maximum AP of all items combined or AP_to_be_added in the settings. 
	iTotalAP, AP_items, N_AP_items = GetCurrentAP( bIsCore )

	-- Safety check, number of items should be > 0.
	if N_AP_items > 0 then
	
		-- Determine if you need to hand in a selection of your AP items, and if so, which items.
		if AP_to_be_added ~= nil and not (AP_to_be_added > iTotalAP)  then
		
			AP_items = Determine_AP_items_to_hand_in( AP_to_be_added, AP_items, AP_to_be_added )
			
		else
		
			Write("Everything is handed in, with a total of " .. iTotalAP .. " AP")
			
		end
	
	else
	
		Write( "There are no AP items to hand in")
		Close();
		
	end
	
end

-- OnRun function --
--  Every 250ms this function is called. This function checks if there are still items to be handed in.
function OnRun()

	-- Check all entities and if there is one enemy, stop handing in items to allow the player to run away/fight
	local escape = false
	local List = EntityList:GetList()
	
	for ID, Entity in DictionaryIterator( List ) do
		if Entity:IsPlayer() and Entity:IsHostile() then
			escape = true;
		end
	end
	
	if escape or Player:IsMoving() or timer >= Time() then
		return
	end

	-- Core
	if Core == true then
		-- Icons, Seals, Goblets, Crowns
		if hand_in_type == 1 then
			-- Hand in Goblets, denoted as 3
			if AP_items[3][1] + AP_items[3][2] + AP_items[3][3] + AP_items[3][4] > 0 then
				Handle_Delivery_AP_items( "Amarunerk", 3 )
			-- Hand in Crowns, denoted as 4
			elseif AP_items[4][1] + AP_items[4][2] + AP_items[4][3] + AP_items[4][4] > 0 then
				Handle_Delivery_AP_items( "Momorinrinerk", 4 )
			-- Every item necessary has been handed in, close script
			else
				Close();
			end
		-- Crowns, Goblets, Seals, Icons
		else
			-- Hand in Crowns, denoted as 4
			if AP_items[4][1] + AP_items[4][2] + AP_items[4][3] + AP_items[4][4] > 0 then
				--Write("handing in Crowns")
				Handle_Delivery_AP_items( "Momorinrinerk", 4 )
			-- Hand in Goblets, denoted as 3
			elseif AP_items[3][1] + AP_items[3][2] + AP_items[3][3] + AP_items[3][4] > 0 then
				Handle_Delivery_AP_items( "Amarunerk", 3 )
			end
		end
	-- Not Core
	else
		-- Icons, Seals, Goblets, Crowns
		if hand_in_type == 1 then
			-- Hand in icons, denoted as 1
			if AP_items[1][1] + AP_items[1][2] + AP_items[1][3] + AP_items[1][4] > 0 then
				if Elyos then
					Handle_Delivery_AP_items( "Iacchus", 1 )
				else
					Handle_Delivery_AP_items( "Byrgafa", 1 )
				end
			 -- Hand in Seals, denoted as 2
			elseif AP_items[2][1] + AP_items[2][2] + AP_items[2][3] + AP_items[2][4] > 0 then
				if Elyos then
					Handle_Delivery_AP_items( "Ceres", 2 )
				else
					Handle_Delivery_AP_items( "Bakan", 2 )
				end
			-- Hand in Goblets, denoted as 3
			elseif AP_items[3][1] + AP_items[3][2] + AP_items[3][3] + AP_items[3][4] > 0 then
				if Elyos then
					Handle_Delivery_AP_items( "Philemon", 3 )
				else
					Handle_Delivery_AP_items( "Tiele", 3 )
				end
			-- Hand in Crowns, denoted as 4
			elseif AP_items[4][1] + AP_items[4][2] + AP_items[4][3] + AP_items[4][4] > 0 then
				if Elyos then
					Handle_Delivery_AP_items( "Bergila", 4 )
				else
					Handle_Delivery_AP_items( "Juergen", 4 )
				end
			-- Every item necessary has been handed in, close script
			else 
				Close();
			end
		-- Crowns, Goblets, Seals, Icons
		elseif hand_in_type == 2 then
			-- Hand in Crowns, denoted as 4
			if AP_items[4][1] + AP_items[4][2] + AP_items[4][3] + AP_items[4][4] > 0 then 
				if Elyos then 
					Handle_Delivery_AP_items( "Bergila", 4 )
				else
					Handle_Delivery_AP_items( "Juergen", 4 )
				end
			-- Hand in Goblets, denoted as 3
			elseif AP_items[3][1] + AP_items[3][2] + AP_items[3][3] + AP_items[3][4] > 0 then
				if Elyos then
					Handle_Delivery_AP_items( "Philemon", 3 )
				else
					Handle_Delivery_AP_items( "Tiele", 3 )
				end
			-- Hand in Seals, denoted as 2
			elseif AP_items[2][1] + AP_items[2][2] + AP_items[2][3] + AP_items[2][4] > 0 then
				if Elyos then
					Handle_Delivery_AP_items( "Ceres", 2 )
				else
					Handle_Delivery_AP_items( "Bakan", 2 )
				end
			-- Hand in icons, denoted as 1
			elseif AP_items[1][1] + AP_items[1][2] + AP_items[1][3] + AP_items[1][4] > 0 then
				if Elyos then
					Handle_Delivery_AP_items( "Iacchus", 1 )
				else
					Handle_Delivery_AP_items( "Byrgafa", 1 )
				end
			-- Every item necessary has been handed in, close script
			else
				Close();
			end
		end
	end
end

--  Handle_Delivery_AP_items function --
-- The items which are checked in OnRun are handed in.
function Handle_Delivery_AP_items( NPC_name, item_type )

	-- Get the target entity
	local Entity = EntityList:GetEntity( NPC_name )
	
	if not DialogList:GetDialog( "dlg_dialog" ):IsVisible() then -- Move to the target NPC and start the dialog
	
		if Player:GetTargetID() ~= Entity:GetID() then -- Move to the target NPC

			Player:SetTarget( Entity )
			Player:SetMove( Entity:GetPosition() )
		
		else -- start dialog
		
			PlayerInput:Ability( 'Attack/Chat' )
			
		end
	--
	elseif DialogList:GetDialog( "dlg_dialog/ok" ):IsVisible() then
		--
		DialogList:GetDialog( "dlg_dialog/ok" ):Click()
	--
	elseif DialogList:GetDialog( "dlg_dialog/html_view/1" ) == nil then
		--
		DialogList:GetDialog( "dlg_dialog/close" ):Click()
		-- Subtract Count
		if Item_ID == 1 then -- Lesser item
			AP_items[item_type][1] = AP_items[item_type][1] - 1 -- Subtract one Lesser item
		elseif Item_ID == 2 then -- Normal item
			AP_items[item_type][2] = AP_items[item_type][2] - 1 -- Subtract one Normal item
		elseif Item_ID == 3 then -- Greater item
			AP_items[item_type][3] = AP_items[item_type][3] - 1 -- Subtract one Greater item
		elseif Item_ID == 4 then -- Major item
			AP_items[item_type][4] = AP_items[item_type][4] - 1 -- Subtract one Major item
		end
		-- End Subtract Count
	-- Start Text of dialog
	elseif DialogList:GetDialog( "dlg_dialog/html_view/4" ) == nil then
		DialogList:GetDialog( "dlg_dialog/html_view/1" ):Click()
	-- Select AP-item dialog
	else
		if AP_items[item_type][1] > 0 then -- Select Lesser item
			DialogList:GetDialog( "dlg_dialog/html_view/1" ):Click()
			Item_ID = 1 -- Lesser item
		elseif AP_items[item_type][2] > 0 then -- Select Normal item
			DialogList:GetDialog( "dlg_dialog/html_view/2" ):Click()
			Item_ID = 2 -- Normal item
		elseif AP_items[item_type][3] > 0 then -- Select Greater item
			DialogList:GetDialog( "dlg_dialog/html_view/3" ):Click()
			Item_ID = 3 -- Greater item
		elseif AP_items[item_type][4] > 0 then -- Select Major item
			DialogList:GetDialog( "dlg_dialog/html_view/4" ):Click()
			Item_ID = 4 -- Major item
		end
	end
	
	timer = Time() + 500; -- Safety timer for allowing the dialogs to pop up.

end

-- GetCurrentAP function --
-- Computes the maximum amount of AP-items (integer), the number of AP-items (integer) and the AP-item distribution (4x4 matrix). Modified version of AP counter [1.0].
function GetCurrentAP(bIsCore)

	local iTotalAP = 0 		-- Starting number of AP items you have in your inventory
	local N_AP_items = 0	-- Number of AP_items, used for a for loop in Determine_AP_items_to_hand_in()
	local AP_items = {}		-- matrix with number of AP items
		  AP_items[1] = {0,0,0,0} -- Icons
		  AP_items[2] = {0,0,0,0} -- Seals
		  AP_items[3] = {0,0,0,0} -- Goblets
		  AP_items[4] = {0,0,0,0} -- Crowns

	-- Loop through the inventory items you have.
	for i = 0, InventoryList:GetInventorySize() - 1, 1 do
	
		-- Retrieve the inventory index for the current number!
		local Inventory = InventoryList:GetInventoryIndex( i )
		
		-- Retrieve the amount of items for this thing.
		local iAmount = Inventory:GetAmount()
		
		-- Retrieve the current item name.
		local zName = Inventory:GetName()
			
		-- Check the Ancient Icon items.
		if zName == "Lesser Ancient Icon" then
			iTotalAP = iTotalAP + AddAP( 300 * iAmount )
			AP_items[1][1] = AP_items[1][1] + iAmount
			N_AP_items = N_AP_items + 1
		elseif zName == "Ancient Icon" then
			iTotalAP = iTotalAP + AddAP( 600 * iAmount )
			AP_items[1][2] = AP_items[1][2] + iAmount
			N_AP_items = N_AP_items + 1
		elseif zName == "Greater Ancient Icon" then
			iTotalAP = iTotalAP + AddAP( 800 * iAmount )
			AP_items[1][3] = AP_items[1][3] + iAmount
			N_AP_items = N_AP_items + 1
		elseif zName == "Major Ancient Icon" then
			iTotalAP = iTotalAP + AddAP( 1600 * iAmount )
			AP_items[1][4] = AP_items[1][4] + iAmount
			N_AP_items = N_AP_items + 1
			
		-- Check the Ancient Seal items.
		elseif zName == "Lesser Ancient Seal" then
			iTotalAP = iTotalAP + AddAP( 600 * iAmount )
			AP_items[2][1] = AP_items[2][1] + iAmount
			N_AP_items = N_AP_items + 1
		elseif zName == "Ancient Seal" then
			iTotalAP = iTotalAP + AddAP( 1200 * iAmount )
			AP_items[2][2] = AP_items[2][2] + iAmount
			N_AP_items = N_AP_items + 1
		elseif zName == "Greater Ancient Seal" then
			iTotalAP = iTotalAP + AddAP( 1800 * iAmount )
			AP_items[2][3] = AP_items[2][3] + iAmount
			N_AP_items = N_AP_items + 1
		elseif zName == "Major Ancient Seal" then
			iTotalAP = iTotalAP + AddAP( 2400 * iAmount )
			AP_items[2][4] = AP_items[2][4] + iAmount
			N_AP_items = N_AP_items + 1
			
		-- Check the Ancient Goblet items.
		elseif zName == "Lesser Ancient Goblet" then
			iTotalAP = iTotalAP + AddAP( 800 * iAmount, bIsCore )
			AP_items[3][1] = AP_items[3][1] + iAmount
			N_AP_items = N_AP_items + 1
		elseif zName == "Ancient Goblet" then
			iTotalAP = iTotalAP + AddAP( 1600 * iAmount, bIsCore )
			AP_items[3][2] = AP_items[3][2] + iAmount
			N_AP_items = N_AP_items + 1
		elseif zName == "Greater Ancient Goblet" then
			iTotalAP = iTotalAP + AddAP( 2400 * iAmount, bIsCore )
			AP_items[3][3] = AP_items[3][3] + iAmount
			N_AP_items = N_AP_items + 1
		elseif zName == "Major Ancient Goblet" then
			iTotalAP = iTotalAP + AddAP( 3200 * iAmount, bIsCore )
			AP_items[3][4] = AP_items[3][4] + iAmount
			N_AP_items = N_AP_items + 1
			
		-- Check the Ancient Crown items.
		elseif zName == "Lesser Ancient Crown" then
			iTotalAP = iTotalAP + AddAP( 1600 * iAmount, bIsCore )
			AP_items[4][1] = AP_items[4][1] + iAmount
			N_AP_items = N_AP_items + 1
		elseif zName == "Ancient Crown" then
			iTotalAP = iTotalAP + AddAP( 3200 * iAmount, bIsCore )
			AP_items[4][2] = AP_items[4][2] + iAmount
			N_AP_items = N_AP_items + 1
		elseif zName == "Greater Ancient Crown" then
			iTotalAP = iTotalAP + AddAP( 4800 * iAmount, bIsCore )
			AP_items[4][3] = AP_items[4][3] + iAmount
			N_AP_items = N_AP_items + 1
		elseif zName == "Major Ancient Crown" then
			iTotalAP = iTotalAP + AddAP( 6400 * iAmount, bIsCore )
			AP_items[4][4] = AP_items[4][4] + iAmount
			N_AP_items = N_AP_items + 1
		end
			
	end 
	
	return iTotalAP, AP_items, N_AP_items
	
end

-- Determine_AP_items_to_hand_in function --
--The AP-items in your inventory are known, and this function picks the ones necessary to hand in your pre-defined AP number.
function Determine_AP_items_to_hand_in( AP_to_be_added, AP_items, AP_to_be_added )
	
	local AP_items_return = {}	  -- matrix with number of AP items
		  AP_items_return[1] = {0,0,0,0} -- Icons	[ Lesser	Normal	Greater	Major]
		  AP_items_return[2] = {0,0,0,0} -- Seals	[ Lesser	Normal	Greater	Major]
		  AP_items_return[3] = {0,0,0,0} -- Goblets	[ Lesser	Normal	Greater	Major]
		  AP_items_return[4] = {0,0,0,0} -- Crowns	[ Lesser	Normal	Greater	Major]
	
	-- Loop through all item types and every item separately to find the best fitting AP-item count
	while AP_to_be_added > 0 do
	
		if AP_items[1][1] > 0 then -- Lesser Icon
			AP_items_return[1][1] = AP_items_return[1][1] + 1
			AP_items[1][1] = AP_items[1][1] - 1
			AP_to_be_added = AP_to_be_added - 300
		elseif AP_items[2][1] > 0 then -- Lesser Seal
			AP_items_return[2][1] = AP_items_return[2][1] + 1
			AP_items[2][1] = AP_items[2][1] - 1
			AP_to_be_added = AP_to_be_added - 600
		elseif AP_items[1][2] > 0 then -- Normal Icon
			AP_items_return[1][2] = AP_items_return[1][2] + 1
			AP_items[1][2] = AP_items[1][2] - 1
			AP_to_be_added = AP_to_be_added - 600
		elseif AP_items[3][1] > 0 then -- Lesser Goblet
			AP_items_return[3][1] = AP_items_return[3][1] + 1
			AP_items[3][1] = AP_items[3][1] - 1
			AP_to_be_added = AP_to_be_added - 800
		elseif AP_items[1][3] > 0 then -- Greater Icon
			AP_items_return[1][3] = AP_items_return[1][3] + 1
			AP_items[1][3] = AP_items[1][3] - 1
			AP_to_be_added = AP_to_be_added - 800
		elseif AP_items[2][2] > 0 then -- Normal Seal
			AP_items_return[2][2] = AP_items_return[2][2] + 1
			AP_items[2][2] = AP_items[2][2] - 1
			AP_to_be_added = AP_to_be_added - 1200
		elseif AP_items[4][1] > 0 then -- Lesser Crown
			AP_items_return[4][1] = AP_items_return[4][1] + 1
			AP_items[4][1] = AP_items[4][1] - 1
			AP_to_be_added = AP_to_be_added - 1600
		elseif AP_items[3][2] > 0 then -- Normal Goblet
			AP_items_return[3][2] = AP_items_return[3][2] + 1
			AP_items[3][2] = AP_items[3][2] - 1
			AP_to_be_added = AP_to_be_added - 1600
		elseif AP_items[1][4] > 0 then -- Major Icon
			AP_items_return[1][4] = AP_items_return[1][4] + 1
			AP_items[1][4] = AP_items[1][4] - 1
			AP_to_be_added = AP_to_be_added - 1600
		elseif AP_items[2][3] > 0 then -- Greater Seal
			AP_items_return[2][3] = AP_items_return[2][3] + 1
			AP_items[2][3] = AP_items[2][3] - 1
			AP_to_be_added = AP_to_be_added - 1800
		elseif AP_items[3][3] > 0 then -- Greater Goblet
			AP_items_return[3][3] = AP_items_return[3][3] + 1
			AP_items[3][3] = AP_items[3][3] - 1
			AP_to_be_added = AP_to_be_added - 2400
		elseif AP_items[2][4] > 0 then -- Major Seal
			AP_items_return[2][4] = AP_items_return[2][4] + 1
			AP_items[2][4] = AP_items[2][4] - 1
			AP_to_be_added = AP_to_be_added - 2400
		elseif AP_items[4][2] > 0 then -- Normal Crown
			AP_items_return[4][2] = AP_items_return[4][2] + 1
			AP_items[4][2] = AP_items[4][2] - 1
			AP_to_be_added = AP_to_be_added - 3200			
		elseif AP_items[3][4] > 0 then -- Major Goblet
			AP_items_return[3][4] = AP_items_return[3][4] + 1
			AP_items[3][4] = AP_items[3][4] - 1
			AP_to_be_added = AP_to_be_added - 3200				
		elseif AP_items[4][3] > 0 then -- Greater Crown
			AP_items_return[4][3] = AP_items_return[4][3] + 1
			AP_items[4][3] = AP_items[4][3] - 1
			AP_to_be_added = AP_to_be_added - 4800	
		elseif AP_items[4][4] > 0 then -- Major Crown
			AP_items_return[4][4] = AP_items_return[4][4] + 1
			AP_items[4][4] = AP_items[4][4] - 1
			AP_to_be_added = AP_to_be_added - 6400				
		end
			
	end
		
	return AP_items_return -- Return the found 4x4 matrix
	
end

-- AddAP function --
-- Adds a certain amount of AP to the maximum AP from items counter. Stolen from AP counter [1.0].
function AddAP( iNormalAP, bAllowCore )
	
	local iAddpAP = 0
	
	if bAllowCore ~= nil and bIsCore then
		iAddAP = iNormalAP * 1.5
	else
		iAddAP = iNormalAP
	end
	
	return iAddAP
	
end
