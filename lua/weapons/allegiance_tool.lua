
SWEP.PrintName = "Allegiance Tool"
SWEP.Author = "Liam0102"
SWEP.Purpose = "Change the Allegiance of Star Wars Vehicles"
SWEP.Instructions = "Left Click to change Allegiance, Right Click to cycle Allegiances"
SWEP.Category = "Star Wars"
SWEP.Base = "weapon_base"
SWEP.Slot = 3
SWEP.SlotPos = 5
SWEP.DrawAmmo	= false
SWEP.DrawCrosshair = true
SWEP.ViewModel = "models/weapons/c_toolgun.mdl"
SWEP.WorldModel = "models/weapons/w_toolgun.mdl"
SWEP.AnimPrefix = "python"
SWEP.HoldType = "pistol"
SWEP.Spawnable = false
SWEP.AdminSpawnable = false
list.Set("SWVehicles.Weapons", SWEP.PrintName, SWEP);

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true;
SWEP.Primary.Ammo	= "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

function SWEP:Deploy()
	self.Weapon:SendWeaponAnim(ACT_VM_DRAW); -- Animation

	return true
end

function SWEP:Initialize()
	self.Weapon:SetWeaponHoldType(self.HoldType)
	if(SERVER) then
		self:SetNWString("Allegiance",self.Allegiance)
	end
end


if CLIENT then
	
	function SWEP:Initialize()
		surface.CreateFont( "ALLEGIANCE", {
			font = "Arial",
			size = 32,
			weight = 1000,
			blursize = 0,
			scanlines = 0,
			antialias = true,
			underline = false,
			italic = false,
			strikeout = false,
			symbol = false,
			rotary = false,
			shadow = false,
			additive = false,
			outline = true,
		} )
		self.Weapon:SetWeaponHoldType(self.HoldType)
	end
	
	local Allegiance = "";
	local shouldDraw = false;
	function SWEP:Think()
		local p = LocalPlayer();
		Allegiance = self:GetNWString("Allegiance");
		
	end

	local function AllegianceToolHUD()
		local p = LocalPlayer()
		if(IsValid(p:GetActiveWeapon()) and p:GetActiveWeapon():GetClass() == "allegiance_tool") then
			surface.SetTextColor(255,255,255,255);
			surface.SetFont( "ALLEGIANCE" )
			if(SW_GetAllegiance()) then
				local tW,tH = surface.GetTextSize("Old: " .. SW_GetAllegiance())
				surface.SetTextPos(ScrW()- tW,ScrH()/10*1);
				surface.DrawText("Old: " .. SW_GetAllegiance())
			end
			surface.SetTextPos(0,ScrH()/10*1);
			surface.DrawText("New: " .. Allegiance)
		end
	end

	hook.Add("HUDPaint", "AllegianceToolHUD", AllegianceToolHUD)


	function SW_GetAllegiance()
		local p = LocalPlayer();
		local EyeTrace = p:GetEyeTrace();
		if(EyeTrace.Hit) then
			if(IsValid(EyeTrace.Entity)) then
				local e = EyeTrace.Entity;
				local class = e:GetClass();
				if(e.IsSWVehicle) then
					return e.Allegiance;
				end
			end
		end
	end

end

if(SERVER) then

function SWEP:PrimaryAttack()
	local EyeTrace = self.Owner:GetEyeTrace();
	if(EyeTrace.Hit) then
		if(IsValid(EyeTrace.Entity)) then
			local e = EyeTrace.Entity;
			local class = e:GetClass();
			if(e.IsSWVehicle) then
				local distance = (e:GetPos() - self.Owner:GetPos()):Length();
				if(distance <= 300) then
					e.Allegiance = self.Allegiance;
					e:ChangeAllegiance(self.Allegiance);
				end
			end
		end
	end
	return true
end

SWEP.Allegiance = "Rebels";
function SWEP:SecondaryAttack()
	if(self.Allegiance == "Mandalorian") then
		self.Allegiance = "CIS";
	elseif(self.Allegiance == "CIS") then
		self.Allegiance = "Republic";
	elseif(self.Allegiance == "Republic") then
		self.Allegiance = "Rebels";	
	elseif(self.Allegiance == "Rebels") then
		self.Allegiance = "Neutral";
	elseif(self.Allegiance == "Neutral") then
		self.Allegiance = "Empire";
	elseif(self.Allegiance == "Empire") then
		self.Allegiance = "First Order";
	elseif(self.Allegiance == "First Order") then
		self.Allegiance = "Resistance";
	elseif(self.Allegiance == "Resistance") then
		self.Allegiance = "Corruption";
	elseif(self.Allegiance == "Corruption") then
		self.Allegiance = "Mandalorian";
	end
	self:SetNWString("Allegiance",self.Allegiance)
	self:SetNextSecondaryFire(CurTime()+0.3);
	return true
end

end
