
ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.Base = "fighter_base"
ENT.Type = "vehicle"

ENT.PrintName = "TIE Advanced"
ENT.Author = "Liam0102"
ENT.Category = "Star Wars Vehicles: Empire"
ENT.AutomaticFrameAdvance = true
ENT.Spawnable = false;
ENT.AdminSpawnable = false;

ENT.EntModel = "models/tiead/tiead1.mdl"
ENT.Vehicle = "TieAdvanced"
ENT.StartHealth = 3000;
ENT.Allegiance = "Empire";
list.Set("SWVehicles", ENT.PrintName, ENT);
if SERVER then

ENT.FireSound = Sound("weapons/tie_shoot.wav");
ENT.NextUse = {Wings = CurTime(),Use = CurTime(),Fire = CurTime(),};


AddCSLuaFile();
function ENT:SpawnFunction(pl, tr)
	local e = ents.Create("tie_advanced");
	e:SetPos(tr.HitPos + Vector(0,0,20));
	e:SetAngles(Angle(0,pl:GetAimVector():Angle().Yaw,0));
	e:Spawn();
	e:Activate();
	return e;
end

function ENT:Initialize()


	self:SetNWInt("Health",self.StartHealth);
	
	self.WeaponLocations = {
		Right = self:GetPos()+self:GetForward()*80+self:GetUp()*40+self:GetRight()*15,
		Left = self:GetPos()+self:GetForward()*80+self:GetUp()*40+self:GetRight()*-15,
	}
	
	self.WeaponsTable = {};
	self.BoostSpeed = 2000;
	self.ForwardSpeed = 1000;
	self.UpSpeed = 500;
	self.AccelSpeed = 8;
	self.CanBack = true;
	self.CanRoll = true;
	
	self.Cooldown = 2;
	self.Overheat = 0;
	self.Overheated = false;
	
	self.CanShoot = true;
	self.ExitModifier = {x=0,y=140,z=40};
	
	self.Bullet = CreateBulletStructure(100,"green");

	self.BaseClass.Initialize(self);
end


end

if CLIENT then

	function ENT:Draw() self:DrawModel() end
	
	ENT.EnginePos = {}
	ENT.Sounds={
		//Engine=Sound("ambient/atmosphere/ambience_base.wav"),
		Engine=Sound("vehicles/tie/tie_engine.wav"),
	}

	ENT.CanFPV = true;
	local Health = 100;
	function ENT:Think()
		
		local p = LocalPlayer();
		local Flying = p:GetNWBool("Flying"..self.Vehicle);
		if(Flying) then
			Health = self:GetNWInt("Health");
		end
		self.BaseClass.Think(self);
	end
    
    ENT.ViewDistance = 700;
    ENT.ViewHeight = 300;
    ENT.FPVPos = Vector(40,0,85);

	local HUD = surface.GetTextureID("vgui/tie_cockpit");
	local Glass = surface.GetTextureID("models/props_c17/frostedglass_01a_dx60");
	function TieAdvancedReticle()
		
		local p = LocalPlayer();
		local Flying = p:GetNWBool("FlyingTieAdvanced");
		local self = p:GetNWEntity("TieAdvanced");
		if(Flying and IsValid(self)) then
			local WeaponsPos = {
				self:GetPos()+self:GetForward()*80+self:GetUp()*40+self:GetRight()*15,
				self:GetPos()+self:GetForward()*80+self:GetUp()*40+self:GetRight()*-15,
			}
			
			local FPV = self:GetFPV();
			
			if(FPV) then
				SW_HUD_FPV(HUD);
			end
			SW_HUD_DrawHull(3000);
			SW_WeaponReticles(self);
			SW_HUD_DrawOverheating(self);
			
			local x = ScrW()/4*0.6;
			local y = ScrH()/4*0.825;
			SW_HUD_Compass(self,x,y);
			SW_HUD_DrawSpeedometer();
		end
	end
	hook.Add("HUDPaint", "TieAdvancedReticle", TieAdvancedReticle)

end