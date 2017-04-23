
SWEP.PrintName = "Repair Tool"
SWEP.Author = "Liam0102"
SWEP.Purpose = "Repair Star Wars Vehicles"
SWEP.Instructions = "Left Click to Repair"
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
end

if CLIENT then
	
	function SWEP:Initialize()
		surface.CreateFont( "REPAIR_Health", {
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
	
	local veh_Health = 0;
	local veh_StartHealth = 0;
	local shouldDraw = false;
	local Weapon;
	function SWEP:Think()
		local p = LocalPlayer();
		Weapon = self;
		veh_Health, veh_StartHealth = self:GetVehicleHealth();

	end

	local function RepairToolHUD()
		local p = LocalPlayer()
		if(veh_Health == nil or veh_StartHealth == nil) then return end;
		if(veh_Health > 0 and (p:GetActiveWeapon() == Weapon) and veh_StartHealth > 0) then
			surface.SetTextColor(255,255,255,255);
			surface.SetFont( "REPAIR_Health" )
			surface.SetTextPos(ScrW()/10*9,ScrH()/10*9);
			surface.DrawText("Hull: " .. (math.Round(veh_Health / veh_StartHealth * 100)) .. "%")
		end
	end

	hook.Add("HUDPaint", "RepairToolHUD", RepairToolHUD)


	function SWEP:GetVehicleHealth()
		local p = LocalPlayer();
		local EyeTrace = p:GetEyeTrace();
		if(EyeTrace.Hit) then
			if(IsValid(EyeTrace.Entity)) then
				local e = EyeTrace.Entity;
				local class = e:GetClass();
				if(GetStarWarsVehicle(class) or e.IsSWVehicle) then
					return e:GetNWInt("Health"), e.StartHealth;
				end
			end
		end
		return 0,0;
	end

end

function GetStarWarsVehicle(veh)
    
    local Vehicles = list.Get("SWVehicles");
	for k,v in pairs(Vehicles) do
		if(v.ClassName == veh) then
            return true;
        end
	end
	return false;

end

if SERVER then

AddCSLuaFile()


function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)
end

function SWEP:PrimaryAttack()
	local EyeTrace = self.Owner:GetEyeTrace();
	if(EyeTrace.Hit) then
		if(IsValid(EyeTrace.Entity)) then
			local e = EyeTrace.Entity;
			local class = e:GetClass();
			if(GetStarWarsVehicle(class) or e.IsSWVehicle) then
				local distance = (e:GetPos() - self.Owner:GetPos()):Length();
				if(distance <= 300) then
					local Health = e:GetNWInt("Health");
					
					if(Health < e.StartHealth) then
						self:RepairEffect(EyeTrace.HitPos);
					end
					
					if(Health <= e.StartHealth - 10) then
						Health = Health + 10;
						self:RepairEffect(EyeTrace.HitPos);						
					else
						Health = e.StartHealth;
					end
					
					if(e.CriticalDamage) then
						if(Health >= Health / e.StartHealth * 10) then
							e.CriticalDamage = false;
						end
					end
					e:SetNWInt("Health",Health);
					e.VehicleHealth = Health;
					if(Health >= e.StartHealth*0.1) then
						e.CriticalDamage = false;
					end

					if(Health >= e.StartHealth*0.2) then
						e.WeaponsDisabled = false;
					end					
				end
			end
		end
	end
	return true
end

function SWEP:RepairEffect(pos)
	local fx = EffectData()
		fx:SetOrigin( pos )
	util.Effect( "StunstickImpact", fx, true )

end


end