-- This file is loaded for each script running through AionScript. The purpose of this file is simple,
-- expose functions required for the correct interaction with parts of the programmer interface. This
-- includes common functionality to interact with the Dictionary- and List objects returned by any of
-- the GetList methods. Please do not modify the contents of this file.

-- for ID, Entity in DictionaryIterator( EntityList:GetList()) do
-- 	Write( ID + "=" + Entity:GetID() + "," + Entity:GetName());
-- end

function DictionaryIterator(o)
	local e = o:GetEnumerator();
	return function()
		if e:MoveNext() then
			return e.Current.Key, e.Current.Value;
		end
	end
end

-- for Inventory in ListIterator( InventoryList:GetList()) do
-- 	Write( Inventory:GetAmount() + "x" + Inventory:GetName());
-- end

function ListIterator(o)
	local e = o:GetEnumerator();
	return function()
		if e:MoveNext() then
			return e.Current;
		end
	end
end