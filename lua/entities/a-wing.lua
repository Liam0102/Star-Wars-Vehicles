
ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.Type = "vehicle"
ENT.Base = "fighter_base"

ENT.PrintName = "A-Wing"
ENT.Author = "Liam0102"
ENT.Category = "Star Wars Vehicles: Rebels"
ENT.AutomaticFrameAdvance = true
ENT.Spawnable = false;
ENT.AdminSpawnable = false;

ENT.EntModel = "models/awingland/awingland.mdl"
ENT.FlyModel = "models/awing/awing1.mdl"
ENT.Vehicle = "AWing"
ENT.StartHealth = 1000;
ENT.Allegiance = "Rebels";
list.Set("SWVehicles", ENT.PrintName, ENT);
util.PrecacheModel("models/awing/awing1.mdl")

if SERVER then

ENT.FireSound = Sound("weapons/xwing_shoot.wav");
ENT.NextUse = {Wings = CurTime(),Use = CurTime(),Fire = CurTime(),FireMode = CurTime(),};


AddCSLuaFile();
function ENT:SpawnFunction(pl, tr)
	local e = ents.Create("a-wing");
	e:SetPos(tr.HitPos + Vector(0,0,5));
	e:SetAngles(Angle(0,pl:GetAimVector():Angle().Yaw,0));
	e:Spawn();
	e:Activate();
	return e;
end

function ENT:Initialize()
	
	self:SetNWInt("Health",self.StartHealth);
	self.CanRoll = true;
	self.WeaponLocations = {
		Right = self:GetPos()+self:GetForward()*120+self:GetUp()*45+self:GetRight()*87,
		Left = self:GetPos()+self:GetForward()*120+self:GetUp()*43+self:GetRight()*-80,
	}
	self.WeaponsTable = {};

	self.BoostSpeed = 2500;
	self.ForwardSpeed = 1500;
	self.UpSpeed = 550;
	self.AccelSpeed = 9;
	
	self.Cooldown = 2;
	self.Overheat = 0;
	self.Overheated = false;
	self.CanShoot = true;
	self.FireDelay = 0.1;
	self.AlternateFire = true;
	self.FireGroup = {"Left","Right"}
	self.LandOffset = Vector(0,0,20)
	
	self.Bullet = CreateBulletStructure(70,"red");

	self.BaseClass.Initialize(self)
end


function ENT:Enter(p)
	
	if(not self.Inflight) then		
		self:SetModel(self.FlyModel);
	end
	self.BaseClass.Enter(self,p)
end

function ENT:Exit(kill)	
	if(self.Inflight and self.TakeOff) then
		self:SetModel(self.EntModel);
	end
	self.BaseClass.Exit(self,kill);
end

end

if CLIENT then

	function ENT:Draw() self:DrawModel() end
	
	ENT.EnginePos = {}
	ENT.CanFPV = true;
	ENT.Sounds={
		Engine=Sound("vehicles/xwing/xwing_fly2.wav"),
	}
	function ENT:Initialize()	
		self.BaseClass.Initialize(self);
	end
	
	local Health = 0;
	local Overheat;
	local Overheated;
	function ENT:Think()
		self.BaseClass.Think(self);
		
		local p = LocalPlayer();
		local Flying = self:GetNWBool("Flying".. self.Vehicle);
		local IsFlying = p:GetNWBool("Flying"..self.Vehicle);
		local TakeOff = self:GetNWBool("TakeOff");
		local Land = self:GetNWBool("Land");
		if(Flying) then
			self.EnginePos = {
				self:GetPos()+self:GetForward()*-70+self:GetUp()*47+self:GetRight()*43,
				self:GetPos()+self:GetForward()*-70+self:GetUp()*47+self:GetRight()*-43,
			}


			if(!TakeOff and !Land) then
				self:FlightEffects();
			end
			Health = self:GetNWInt("Health");
		end
		
	end
	
	ENT.ViewDistance = 700;
    ENT.ViewHeight = 200;
    ENT.FPVPos = Vector(15,-4,80);

	
	local HUD = surface.GetTextureID("vgui/awing_cockpit");
	local Glass = surface.GetTextureID("models/props_c17/frostedglass_01a_dx60")
	function AWingReticle()
		
		local p = LocalPlayer();
		local Flying = p:GetNWBool("FlyingAWing");
		local self = p:GetNWEntity("AWing");
		

		

		if(Flying and IsValid(self)) then
			local FPV = self:GetFPV();
			if(FPV) then
				SW_HUD_FPV(HUD);
			end
			
			SW_HUD_DrawHull(1000);
			SW_WeaponReticles(self);
			SW_HUD_DrawOverheating(self);
			
			local x = ScrW()/2;
			local y = ScrH()/4*2.8;
			SW_HUD_Compass(self,x,y);
			SW_HUD_DrawSpeedometer();
		end
	end
	hook.Add("HUDPaint", "AWingReticle", AWingReticle)

	function ENT:FlightEffects()
		local normal = (self:GetForward() * -1):GetNormalized()
		local roll = math.Rand(-90,90)
		local p = LocalPlayer()		
		local FWD = self:GetForward();
		local id = self:EntIndex();

		for k,v in pairs(self.EnginePos) do
	
			local heat = self.FXEmitter:Add("sprites/heatwave",v)
			heat:SetVelocity(normal)
			heat:SetDieTime(0.04)
			heat:SetStartAlpha(255)
			heat:SetEndAlpha(255)
			heat:SetStartSize(15)
			heat:SetEndSize(13.5)
			heat:SetRoll(roll)
			heat:SetColor(255,100,100)
			
			if(k == 2 and Health <= (self.StartHealth*0.5)) then
				self:Smoke(true,v);
			else
				local red = self.FXEmitter:Add("sprites/orangecore1",v)
				red:SetVelocity(normal)
				red:SetDieTime(0.04)
				red:SetStartAlpha(255)
				red:SetEndAlpha(255)
				red:SetStartSize(15)
				red:SetEndSize(13.5)
				red:SetRoll(roll)
				red:SetColor(255,255,255)
								
				local dynlight = DynamicLight(id + 4096 * k);
				dynlight.Pos = v+FWD*-25;
				dynlight.Brightness = 5;
				dynlight.Size = 100;
				dynlight.Decay = 1024;
				dynlight.R = 255;
				dynlight.G = 100;
				dynlight.B = 100;
				dynlight.DieTime = CurTime()+1;
			end
		end
	
	end
	
	local UP = Vector(0,0,50); -- Smoke always moves up
	function ENT:Smoke(b,pos)

		local p = LocalPlayer();
		local awing = p:GetNetworkedEntity("AWing",NULL);

		if(b) and (IsValid(awing) and awing==self) then
			local fwd = self:GetForward()
			local vel = self:GetVelocity()
			local roll = math.Rand(-90,90)

			local particle = self.FXEmitter:Add("effects/blood2",pos)
			particle:SetVelocity(vel - 500*fwd+UP)
			particle:SetDieTime(0.75)
			particle:SetStartAlpha(200)
			particle:SetEndAlpha(0)
			particle:SetStartSize(14)
			particle:SetEndSize(20)
			particle:SetColor(40,40,40)
			particle:SetRoll(roll)

			--self.Emitter:Finish()
		end
	end
	
end