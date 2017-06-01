ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.Base = "fighter_base"
ENT.Type = "vehicle"

ENT.PrintName = "TIE Bomber"
ENT.Author = "Liam0102"
ENT.Category = "Star Wars Vehicles: Empire"
ENT.AutomaticFrameAdvance = true
ENT.Spawnable = false;
ENT.AdminSpawnable = false;

ENT.EntModel = "models/tiebo/tiebo1.mdl"
ENT.Vehicle = "TieBomber"
ENT.StartHealth = 2500;
ENT.Allegiance = "Empire";
list.Set("SWVehicles", ENT.PrintName, ENT);
if SERVER then

ENT.FireSound = Sound("weapons/tie_shoot.wav");
ENT.NextUse = {Wings = CurTime(),Use = CurTime(),Fire = CurTime(),};


AddCSLuaFile();
function ENT:SpawnFunction(pl, tr)
	local e = ents.Create("tie_bomber");
	e:SetPos(tr.HitPos + Vector(0,0,20));
	e:SetAngles(Angle(0,pl:GetAimVector():Angle().Yaw,0));
	e:Spawn();
	e:Activate();
	return e;
end

function ENT:Initialize()


	self:SetNWInt("Health",self.StartHealth);
	
	self.WeaponLocations = {
		Blaster = self:GetPos()+self:GetForward()*130+self:GetUp()*85+self:GetRight()*-60,
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
	
	self.Bullet = CreateBulletStructure(85,"green");

	
	self.BaseClass.Initialize(self);
end


function ENT:Think()

	if(self.Inflight) then
		if(IsValid(self.Pilot)) then
			if(self.Pilot:KeyDown(IN_ATTACK2)) then
				self:FireBlast(self:GetPos()+self:GetForward()*50+self:GetRight()*-20,true,0.4);	
			end
		end
	end
	self.BaseClass.Think(self);
end

end

if CLIENT then

	function ENT:Draw() self:DrawModel() end
	
	ENT.EnginePos = {}
	ENT.Sounds={
		//Engine=Sound("ambient/atmosphere/ambience_base.wav"),
		Engine=Sound("vehicles/tie/tie_fly3.wav"),
	}
	ENT.CanFPV = true;
	
	local Health = 0;
	function ENT:Think()
		self.BaseClass.Think(self);
		local p = LocalPlayer();
		local IsFlying = p:GetNWBool("Flying"..self.Vehicle);
		
		local IsDriver = p:GetNWEntity(self.Vehicle) == self.Entity;
		if(IsFlying and IsDriver) then
			Health = self:GetNWInt("Health");
		end		
	end

    ENT.ViewDistance = 700;
    ENT.ViewHeight = 300;
    ENT.FPVPos = Vector(120,-60,85);

	local HUD = surface.GetTextureID("vgui/tie_cockpit");
	function TieBomberReticle()
		
		local p = LocalPlayer();
		local Flying = p:GetNWBool("FlyingTieBomber");
		local self = p:GetNWEntity("TieBomber");
		
		if(Flying and IsValid(self)) then

			local FPV = self:GetFPV();
			if(FPV) then
				SW_HUD_FPV(HUD);
			end
			
			SW_HUD_DrawHull(2500);
			SW_WeaponReticles(self);
			SW_HUD_DrawOverheating(self);
			SW_BlastIcon(self);
			
			local x = ScrW()/4*0.6;
			local y = ScrH()/4*0.825;
			SW_HUD_Compass(self,x,y);
			SW_HUD_DrawSpeedometer();
		end
	end
	hook.Add("HUDPaint", "TieBomberReticle", TieBomberReticle)

end