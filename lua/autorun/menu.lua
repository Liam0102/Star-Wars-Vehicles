if(CLIENT) then
spawnmenu.AddCreationTab( "Star Wars Vehicles", function()
	local ctrl = vgui.Create( "SpawnmenuContentPanel" )
    ctrl:CallPopulateHook( "SWVehiclesTab" );
    return ctrl;
end, "icons16/other.png", 60 )

hook.Add( "SWVehiclesTab", "AddEntityContent", function( pnlContent, tree, node )

	local Categorised = {}

	-- Add this list into the tormoil
	local SpawnableEntities = list.Get( "SWVehicles" )
	if ( SpawnableEntities ) then
		for k, v in pairs( SpawnableEntities ) do

			v.SpawnName = k
            if(v.Category == "Star Wars") then
                v.Category = "Other";
            else
                v.Category = string.gsub(v.Category, "%Star Wars Vehicles: ", "") or "Other";
            end
			Categorised[ v.Category ] = Categorised[ v.Category ] or {}
			table.insert( Categorised[ v.Category ], v )

		end
	end
            
    SpawnableEntities = list.Get( "SWVehicles.Weapons" )
	if ( SpawnableEntities ) then
		for k, v in pairs( SpawnableEntities ) do

			v.SpawnName = k
            v.Category = "Weapons";
			Categorised[ v.Category ] = Categorised[ v.Category ] or {}
			table.insert( Categorised[ v.Category ], v )

		end
	end

	--
	-- Add a tree node for each category
	--
	for CategoryName, v in SortedPairs( Categorised ) do

		-- Add a node to the tree
		local node = tree:AddNode( CategoryName, "icons16/" .. string.lower(CategoryName) .. ".png" )

			-- When we click on the node - populate it using this function
		node.DoPopulate = function( self )

			-- If we've already populated it - forget it.
			if ( self.PropPanel ) then return end
            
                    
			-- Create the container panel
			self.PropPanel = vgui.Create( "ContentContainer", pnlContent )
			self.PropPanel:SetVisible( false )
			self.PropPanel:SetTriggerSpawnlistChange( false )

			for k, ent in SortedPairsByMemberValue( v, "PrintName" ) do
                local enttype = ent.ScriptedEntityType or "entity";
                if(CategoryName == "Weapons") then
                    enttype = "weapon";
                end
				spawnmenu.CreateContentIcon(enttype, self.PropPanel, {
					nicename	= ent.PrintName or ent.ClassName,
					spawnname	= ent.ClassName,
					material	= "entities/" .. ent.ClassName .. ".vmt",
					admin		= ent.AdminOnly,
                    author		= ent.Author,
                    info		= ent.Instructions,
				} )
			end

		end

		-- If we click on the node populate it and switch to it.
		node.DoClick = function( self )

			self:DoPopulate()
			pnlContent:SwitchPanel( self.PropPanel )

		end

	end

	-- Select the first node
	local FirstNode = tree:Root():GetChildNode( 0 )
	if ( IsValid( FirstNode ) ) then
		FirstNode:InternalDoClick()
	end

end )

    
end