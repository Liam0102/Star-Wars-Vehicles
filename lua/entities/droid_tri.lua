ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Base = "fighter_base"
ENT.Type = "vehicle"

ENT.PrintName = "Droid Tri-Fighter"
ENT.Author = "Liam0102"
ENT.Category = "Star Wars Vehicles: CIS"
ENT.AutomaticFrameAdvance = true
ENT.Spawnable = false;
ENT.AdminSpawnable = false;

ENT.EntModel = "models/tri/tri1.mdl"
ENT.Vehicle = "DroidTri"
ENT.Allegiance = "CIS";
ENT.StartHealth = 750;
list.Set("SWVehicles", ENT.PrintName, ENT);
if SERVER then

ENT.FireSound = Sound("weapons/tie_shoot.wav");
ENT.NextUse = {FireMode = CurTime(),Use = CurTime(),Fire = CurTime(),FireBlast=CurTime()};


AddCSLuaFile();
function ENT:SpawnFunction(pl, tr)
	local e = ents.Create("droid_tri");
	e:SetPos(tr.HitPos + Vector(0,0,10));
	e:SetAngles(Angle(0,pl:GetAimVector():Angle().Yaw,0));
	e:Spawn();
	e:Activate();
	return e;
end

function ENT:Initialize()

	self:SetNWInt("Health",self.StartHealth);
	
	self.WeaponLocations = {	
		BottomLeft = self:GetPos()+self:GetForward()*102+self:GetUp()*43+self:GetRight()*-87,
		BottomRight = self:GetPos()+self:GetForward()*102+self:GetUp()*43+self:GetRight()*84,
		TopMiddle = self:GetPos()+self:GetForward()*102+self:GetUp()*195+self:GetRight()*-3,
	}
	self.WeaponsTable = {};
	self.BoostSpeed = 2250;
	self.ForwardSpeed = 1500;
	self.UpSpeed = 550;
	self.AccelSpeed = 9;
	self.CanStandby = true;
	self.CanBack = true;
	self.CanRoll = false;
	self.CanStrafe = true;
	self.Cooldown = 2;
	
	self.CanShoot = true;
	self.Bullet = CreateBulletStructure(50,"red");
	self.FireDelay = 0.2;
	
	self.BaseClass.Initialize(self);
end

function ENT:Think()
	
	
	
	if(self.Inflight) then
		if(IsValid(self.Pilot)) then
			if(self.Pilot:KeyDown(IN_ATTACK2)) then
				local pos = self:GetPos()+self:GetForward()*185+self:GetUp()*95+self:GetRight()*-3;
				self:FireBlast(pos,false,8,600,false,20);
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
		Engine=Sound("vehicles/droid/droid_fly.wav"),
	}
	
	function ENT:Initialize()
		self.Emitter = ParticleEmitter(self:GetPos());
		self.BaseClass.Initialize(self);
	end
	
	ENT.ViewDistance = 700;
    ENT.ViewHeight = 200;
	
	function ENT:FlightEffects()
		local normal = (self:GetForward() * -1):GetNormalized()
		local roll = math.Rand(-90,90)
		local p = LocalPlayer()		
		local FWD = self:GetForward();
		local id = self:EntIndex();
		
		self.EnginePos = {
			self:GetPos()+self:GetForward()*-170+self:GetUp()*75+self:GetRight()*-30,
			self:GetPos()+self:GetForward()*-170+self:GetUp()*130+self:GetRight()*-3,
			self:GetPos()+self:GetForward()*-170+self:GetUp()*75+self:GetRight()*27,
		}

		for k,v in pairs(self.EnginePos) do
			
			local blue = self.FXEmitter:Add("sprites/bluecore",v+FWD*-5)
			blue:SetVelocity(normal)
			blue:SetDieTime(0.05)
			blue:SetStartAlpha(255)
			blue:SetEndAlpha(255)
			blue:SetStartSize(20)
			blue:SetEndSize(10)
			blue:SetRoll(roll)
			blue:SetColor(255,255,255)
			
			local dynlight = DynamicLight(id + 4096*k);
			dynlight.Pos = v+FWD*-25;
			dynlight.Brightness = 5;
			dynlight.Size = 100;
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
				self:FlightEffects();
			end
		end
		
	end

	function DroidTriReticle()
		
		local p = LocalPlayer();
		local Flying = p:GetNWBool("FlyingDroidTri");
		local self = p:GetNWEntity("DroidTri");
		if(Flying and IsValid(self)) then
			SW_HUD_DrawHull(750);
			SW_WeaponReticles(self);
			SW_HUD_DrawOverheating(self);
			SW_BlastIcon(self);
			SW_HUD_Compass(self);
			SW_HUD_DrawSpeedometer();
		end
	end
	hook.Add("HUDPaint", "DroidTriReticle", DroidTriReticle)

end