
ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.Base = "fighter_base"
ENT.Type = "vehicle"

ENT.PrintName = "TIE Fighter"
ENT.Author = "Liam0102"
ENT.Category = "Star Wars Vehicles: Empire"
ENT.AutomaticFrameAdvance = true
ENT.Spawnable = false;
ENT.AdminSpawnable = false;

ENT.EntModel = "models/tie2/tie2.mdl"
ENT.Vehicle = "Tie"
ENT.StartHealth = 3000;
ENT.Allegiance = "Empire";
list.Set("SWVehicles", ENT.PrintName, ENT);

if SERVER then

ENT.FireSound = Sound("weapons/tie_shoot.wav");
ENT.NextUse = {Wings = CurTime(),Use = CurTime(),Fire = CurTime(),Torpedos = CurTime()};


AddCSLuaFile();
function ENT:SpawnFunction(pl, tr)
	local e = ents.Create("tie_fighter");
	e:SetPos(tr.HitPos + Vector(0,0,10));
	e:SetAngles(Angle(0,pl:GetAimVector():Angle().Yaw,0));
	e:Spawn();
	e:Activate();
	return e;
end

function ENT:Initialize()


	self:SetNWInt("Health",self.StartHealth);
	
	self.WeaponLocations = {
		Right = self:GetPos()+self:GetForward()*150+self:GetUp()*137+self:GetRight()*-6,
		Left = self:GetPos()+self:GetForward()*150+self:GetUp()*137+self:GetRight()*-24,
	}
	self.WeaponsTable = {};
	self.BoostSpeed = 2500;
	self.ForwardSpeed = 1500;
	self.UpSpeed = 500;
	self.AccelSpeed = 9;
	self.CanBack = true;
	
	self.CanShoot = true;
	self.CanStrafe = true;
	self.CanRoll = false;
	self.ExitModifier = {x=0,y=160,z=40};
	self.HasLookaround = true;
	self.Cooldown = 2;
	self.Overheat = 0;
	self.Overheated = false;
	self.FireDelay = 0.2;
	self.Bullet = CreateBulletStructure(65,"green");
	self.NextUse.Torpedos = CurTime();
	

	self.BaseClass.Initialize(self);
end

function ENT:IonTorpedos()

	if(self.NextUse.Torpedos < CurTime()) then
		local pos = self:GetPos()+self:GetForward()*150+self:GetUp()*137+self:GetRight()*-16
		local e = self:FindTarget();
		if(e == self) then
			e = NULL;
		end
		self:FireTorpedo(pos,e,1500,300,Color(255,255,255,255),15,true);
		self.NextUse.Torpedos = CurTime()+30;
		self:SetNWInt("FireBlast",self.NextUse.Torpedos)
	end
end

function ENT:Think()
	

	if(self.Inflight) then
		if(IsValid(self.Pilot)) then
			if(self.Pilot:KeyDown(IN_ATTACK2)) then
				self:IonTorpedos();
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
	ENT.ViewDistance = 700;
    ENT.ViewHeight = 300;
    ENT.FPVPos = Vector(30.6,15,180);

	function TieReticle()
		
		local p = LocalPlayer();
		local Flying = p:GetNWBool("FlyingTie");
		local self = p:GetNWEntity("Tie");
		if(Flying and IsValid(self)) then

			SW_WeaponReticles(self);
			SW_HUD_DrawOverheating(self);
			SW_HUD_DrawHull(3000);
			
			local pos = self:GetPos()+self:GetUp()*186+self:GetForward()*45+self:GetRight()*-15;
			local x,y = SW_XYIn3D(pos);
			
			SW_HUD_Compass(self,x,y);
			
			
			x = ScrW()/4*1.35;
			y = ScrH()/4*3.6;
			
			SW_HUD_DrawSpeedometer();
			SW_BlastIcon(self,30)
		end
	end
	hook.Add("HUDPaint", "TieReticle", TieReticle)

end