

ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Base = "fighter_base"
ENT.Type = "vehicle"

ENT.PrintName = "Vulture"
ENT.Author = "Liam0102"
ENT.Category = "Star Wars Vehicles: CIS"
ENT.AutomaticFrameAdvance = true
ENT.Spawnable = false;
ENT.AdminSpawnable = false;

ENT.EntModel = "models/vulture/vulture1.mdl"
ENT.Vehicle = "Vulture"
ENT.StartHealth = 500;
ENT.Allegiance = "CIS";
list.Set("SWVehicles", ENT.PrintName, ENT);
if SERVER then

ENT.FireSound = Sound("weapons/tie_shoot.wav");
ENT.NextUse = {Wings = CurTime(),Use = CurTime(),Fire = CurTime(),};

AddCSLuaFile();
function ENT:SpawnFunction(pl, tr)
	local e = ents.Create("vulture");
	e:SetPos(tr.HitPos + Vector(0,0,10));
	e:SetAngles(Angle(0,pl:GetAimVector():Angle().Yaw,0));
	e:Spawn();
	e:Activate();
	return e;
end

function ENT:Initialize()

	self:SetNWInt("Health",self.StartHealth);
	
	self.WeaponLocations = {	
		BottomLeft = self:GetPos()+self:GetRight()*-110+self:GetUp()*24+self:GetForward()*42,
		BottomRight = self:GetPos()+self:GetRight()*110+self:GetUp()*24+self:GetForward()*42,
		TopLeft = self:GetPos()+self:GetRight()*-110+self:GetUp()*35+self:GetForward()*42,
		TopRight = self:GetPos()+self:GetRight()*110+self:GetUp()*35+self:GetForward()*42,
	}
	self.WeaponsTable = {};
	self.BoostSpeed = 2500;
	self.ForwardSpeed = 1400;
	self.UpSpeed = 500;
	self.AccelSpeed = 8;
	self.CanRoll = true;
	self.CanShoot = true;
	self.Bullet = CreateBulletStructure(30,"red");
	self.CanStandby = true;
	
	self.BaseClass.Initialize(self);
end


end

if CLIENT then

	function ENT:Draw() self:DrawModel() end
	
	ENT.EnginePos = {}
	ENT.Sounds={
		Engine=Sound("vehicles/droid/droid_fly.wav"),
	}
	ENT.CanFPV = false;
	
	local Health = 0;
	local Overheat = 0;
	local Overheated = false;
	function ENT:Think()
		
		self.BaseClass.Think(self);
		
		local p = LocalPlayer();
		local IsFlying = p:GetNWBool("Flying"..self.Vehicle);
		local IsDriver = p:GetNWEntity(self.Vehicle) == self.Entity;
		if(IsFlying and IsDriver) then
			Health = self:GetNWInt("Health");
			Overheat = self:GetNWInt("Overheat");
			Overheated = self:GetNWBool("Overheated");
		end
	end
	
    ENT.ViewDistance = 700;
    ENT.ViewHeight = 200;

	function VultureReticle()
		
		local p = LocalPlayer();
		local Flying = p:GetNWBool("FlyingVulture");
		local self = p:GetNWEntity("Vulture");
		if(Flying and IsValid(self)) then
			SW_HUD_DrawHull(500);
			SW_WeaponReticles(self);
			SW_HUD_DrawOverheating(self);
	
			SW_HUD_Compass(self);
			SW_HUD_DrawSpeedometer();
		end
	end
	hook.Add("HUDPaint", "VultureReticle", VultureReticle)

end