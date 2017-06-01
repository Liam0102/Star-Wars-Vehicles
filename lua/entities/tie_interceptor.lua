
ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.Base = "fighter_base"
ENT.Type = "vehicle"

ENT.PrintName = "TIE Interceptor"
ENT.Author = "Liam0102"
ENT.Category = "Star Wars Vehicles: Empire"
ENT.Spawnable = false;
ENT.AdminSpawnable = false;

ENT.EntModel = "models/tieinter/tieinterceptor.mdl"
ENT.Vehicle = "TIEInterceptor"
ENT.StartHealth = 2250;
ENT.Allegiance = "Empire";
list.Set("SWVehicles", ENT.PrintName, ENT);
if SERVER then

ENT.FireSound = Sound("weapons/tie_shoot.wav");
ENT.NextUse = {Wings = CurTime(),Use = CurTime(),Fire = CurTime(),};


AddCSLuaFile();
function ENT:SpawnFunction(pl, tr)
	local e = ents.Create("tie_interceptor");
	e:SetPos(tr.HitPos + Vector(0,0,-50));
	e:SetAngles(Angle(0,pl:GetAimVector():Angle().Yaw,0));
	e:Spawn();
	e:Activate();
	return e;
end

function ENT:Initialize()


	self:SetNWInt("Health",self.StartHealth);
	
	self.WeaponLocations = {
		BottomRight = self:GetPos()+self:GetUp()*142.5+self:GetRight()*112.5+self:GetForward()*175,
		TopRight = self:GetPos()+self:GetUp()*217.5+self:GetRight()*112.5+self:GetForward()*175,
		BottomLeft = self:GetPos()+self:GetUp()*142.5+self:GetRight()*-142.5+self:GetForward()*175,
		TopLeft = self:GetPos()+self:GetUp()*217.5+self:GetRight()*-142.5+self:GetForward()*175,
	}
	self.WeaponsTable = {};
	self.BoostSpeed = 2500;
	self.ForwardSpeed = 1250;
	self.UpSpeed = 500;
	self.AccelSpeed = 7;
	self.CanBack = true;
	self.CanRoll = true;
	self.CanStandby = true;
	self.Cooldown = 2;

	self.CanShoot = true;
	self.Bullet = CreateBulletStructure(60,"green");
	self.FireDelay = 0.15;
	self.AlternateFire = true;
	self.FireGroup = {"BottomLeft","TopLeft","BottomRight","TopRight"};

	self.LandOffset = Vector(0,0,-50);
	
	self.ExitModifier = {x=0,y=225,z=100};
	
	self.BaseClass.Initialize(self);
end


end

if CLIENT then
	
	ENT.CanFPV = true;
	ENT.Sounds={
		Engine=Sound("vehicles/tie/tie_interceptor4.wav"),
	}
	
    ENT.ViewDistance = 700;
    ENT.ViewHeight = 300;
    ENT.FPVPos = Vector(50,15,180);
	
	local HUD = surface.GetTextureID("vgui/tie_cockpit");
	function TIEInterceptorReticle()
		
		local p = LocalPlayer();
		local Flying = p:GetNWBool("FlyingTIEInterceptor");
		local self = p:GetNWEntity("TIEInterceptor");
		if(Flying and IsValid(self)) then
			local FPV = self:GetFPV();
			if(FPV) then
				SW_HUD_FPV(HUD);
			end
			SW_HUD_DrawHull(2250);
			SW_WeaponReticles(self);
			SW_HUD_DrawOverheating(self);
			
			local x = ScrW()/4*0.6;
			local y = ScrH()/4*0.825;
			SW_HUD_Compass(self,x,y);
			SW_HUD_DrawSpeedometer();
		end
	end
	hook.Add("HUDPaint", "TIEInterceptorReticle", TIEInterceptorReticle)

end