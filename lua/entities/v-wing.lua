ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Base = "fighter_base"
ENT.Type = "vehicle"

ENT.PrintName = "V-Wing"
ENT.Author = "Liam0102"
ENT.Category = "Star Wars Vehicles: Republic"
ENT.AutomaticFrameAdvance = true
ENT.Spawnable = false;
ENT.AdminSpawnable = false;

ENT.EntModel = "models/vwing/vwing1.mdl"
ENT.Vehicle = "VWing"
ENT.StartHealth = 1500;
ENT.Allegiance = "Rebels";
list.Set("SWVehicles", ENT.PrintName, ENT);
if SERVER then

ENT.FireSound = Sound("weapons/xwing_shoot.wav");
ENT.NextUse = {Wings = CurTime(),Use = CurTime(),Fire = CurTime(),};


AddCSLuaFile();
function ENT:SpawnFunction(pl, tr)
	local e = ents.Create("v-wing");
	e:SetPos(tr.HitPos + Vector(0,0,0));
	e:SetAngles(Angle(0,pl:GetAimVector():Angle().Yaw,0));
	e:Spawn();
	e:Activate();
	return e;
end

function ENT:Initialize()


	self:SetNWInt("Health",self.StartHealth);
	
	self.WeaponLocations = {
		Left = self:GetPos()+self:GetForward()*100+self:GetUp()*70+self:GetRight()*-70,
		Right = self:GetPos()+self:GetForward()*100+self:GetUp()*70+self:GetRight()*70,
	}
	self.WeaponsTable = {};
	self.BoostSpeed = 1500;
	self.ForwardSpeed = 2250;
	self.UpSpeed = 600;
	self.AccelSpeed = 8;
	self.CanStandby = false;
	self.CanBack = false;
	self.CanRoll = false;
	self.CanStrafe = true;
	self.Cooldown = 2;
	self.HasWings = true;
	self.CanShoot = true;
	self.Bullet = CreateBulletStructure(75,"green");
	self.FireDelay = 0.15;
	self.AlternateFire = true;
	self.FireGroup = {"Left","Right",};


	//self.ExitModifier = {x=0,y=225,z=100};
	
	self.BaseClass.Initialize(self);
end

function ENT:Think()

	if(self.Inflight) then
		if(self.Wings) then
			self.CanShoot = true;
			self.CanStrafe = true;
			self.CanRoll = false;
		else
			self.CanShoot = false;
			self.CanRoll = true;
			self.CanStrafe = false;
		end
	end

	self.BaseClass.Think(self);
end


end

if CLIENT then
	
	ENT.CanFPV = false;
	ENT.Sounds={
		Engine=Sound("ambient/atmosphere/ambience_base.wav"),
	}
	
	function ENT:Initialize()
		self.Emitter = ParticleEmitter(self:GetPos());
		self.BaseClass.Initialize(self);
	end
	
    ENT.ViewDistance = 700;
    ENT.ViewHeight = 200;
	
	function ENT:Effects()
	
		self.ThrusterLocations = {
			self:GetPos()+self:GetUp()*77.5+self:GetForward()*-110,
			self:GetPos()+self:GetUp()*47.5+self:GetForward()*-110,
		}
		local p = LocalPlayer();
		local roll = math.Rand(-45,45);
		local normal = (self.Entity:GetForward() * -1):GetNormalized();
		local id = self:EntIndex();
		for k,v in pairs(self.ThrusterLocations) do

			local heatwv = self.Emitter:Add("sprites/heatwave",v);
			heatwv:SetVelocity(normal*2);
			heatwv:SetDieTime(0.1);
			heatwv:SetStartAlpha(255);
			heatwv:SetEndAlpha(255);
			heatwv:SetStartSize(13);
			heatwv:SetEndSize(10);
			heatwv:SetColor(255,255,255);
			heatwv:SetRoll(roll);
			
			local blue = self.FXEmitter:Add("sprites/bluecore",v)
			blue:SetVelocity(normal)
			blue:SetDieTime(0.05)
			blue:SetStartAlpha(255)
			blue:SetEndAlpha(255)
			blue:SetStartSize(13)
			blue:SetEndSize(10)
			blue:SetRoll(roll)
			blue:SetColor(255,255,255)
			
			local dynlight = DynamicLight(id + 4096 * k);
			dynlight.Pos = v;
			dynlight.Brightness = 5;
			dynlight.Size = 150;
			dynlight.Decay = 1024;
			dynlight.R = 100;
			dynlight.G = 100;
			dynlight.B = 255;
			dynlight.DieTime = CurTime()+1;

		end
	end
	
	function ENT:Think()
	
		self.BaseClass.Think(self)
		
		local p = LocalPlayer();
		local Flying = self:GetNWBool("Flying".. self.Vehicle);
		local TakeOff = self:GetNWBool("TakeOff");
		local Land = self:GetNWBool("Land");
		if(Flying) then
			if(!TakeOff and !Land) then
				self:Effects();
			end
		end
		
	end
	
	function VWingReticle()
		
		local p = LocalPlayer();
		local Flying = p:GetNWBool("FlyingVWing");
		local self = p:GetNWEntity("VWing");
		if(Flying and IsValid(self)) then
			SW_HUD_DrawHull(1500);
			SW_WeaponReticles(self);
			SW_HUD_DrawOverheating(self);

			SW_HUD_Compass(self);
			SW_HUD_DrawSpeedometer();
		end
	end
	hook.Add("HUDPaint", "VWingReticle", VWingReticle)

end