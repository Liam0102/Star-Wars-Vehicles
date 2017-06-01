

ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.Type = "vehicle"
ENT.Base = "fighter_base"

ENT.PrintName = "Y-Wing"
ENT.Author = "Liam0102"
ENT.Category = "Star Wars Vehicles: Rebels"
ENT.AutomaticFrameAdvance = true
ENT.Spawnable = false;
ENT.AdminSpawnable = false;

ENT.EntModel = "models/ywing/ywing.mdl"
ENT.FlyModel = "models/ywing/ywing1.mdl"
ENT.Vehicle = "YWing"
ENT.StartHealth = 1500;
ENT.Allegiance = "Rebels";
list.Set("SWVehicles", ENT.PrintName, ENT);
util.PrecacheModel("models/ywing/ywing1.mdl")

if SERVER then

ENT.FireSound = Sound("weapons/xwing_shoot.wav");
ENT.NextUse = {Wings = CurTime(),Use = CurTime(),Fire = CurTime(),FireMode = CurTime(),};


AddCSLuaFile();
function ENT:SpawnFunction(pl, tr)
	local e = ents.Create("y-wing");
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
		Left = self:GetPos()+self:GetForward()*80+self:GetUp()*100+self:GetRight()*-3,
		Right = self:GetPos()+self:GetForward()*80+self:GetUp()*100+self:GetRight()*4,
	}
	self.WeaponsTable = {};
	//self:SpawnWeapons();
	self.BoostSpeed = 2100;
	self.ForwardSpeed = 1250;
	self.UpSpeed = 500;
	self.AccelSpeed = 7;
	
	self.CanShoot = true;
	self.AlternateFire = true;
	self.FireGroup = {"Left","Right"};
	
	self.Cooldown = 2;
	self.Overheat = 0;
	self.Overheated = false;
	self.Bullet = CreateBulletStructure(85,"red");

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

function ENT:Think()
	self.BaseClass.Think(self);
	if(self.Inflight) then
		if(IsValid(self.Pilot)) then
			
			if(IsValid(self.Pilot) and self.Pilot:KeyDown(IN_ATTACK2)) then
				self:FireBlast(self:GetPos()+self:GetForward()*-220,true,0.5,600,false,20);
			end
		end
	end

end

end

if CLIENT then

	function ENT:Draw() self:DrawModel() end
	
	ENT.EnginePos = {}
	ENT.Sounds={
		Engine=Sound("vehicles/xwing/xwing_fly2.wav"),
	}
	function ENT:Initialize()	
		self.BaseClass.Initialize(self);
	end
	
	function ENT:FlightEffects()
		local normal = (self:GetForward() * -1):GetNormalized()
		local roll = math.Rand(-90,90)
		local p = LocalPlayer()		
		local FWD = self:GetForward();
		local id = self:EntIndex();

		for k,v in pairs(self.EnginePos) do
			local red = self.FXEmitter:Add("sprites/orangecore1",v)
			red:SetVelocity(normal)
			red:SetDieTime(0.08)
			red:SetStartAlpha(255)
			red:SetEndAlpha(255)
			red:SetStartSize(15)
			red:SetEndSize(13.5)
			red:SetRoll(roll)
			red:SetColor(255,100,100)
			
			
			
			local heat = self.FXEmitter:Add("sprites/heatwave",v)
			heat:SetVelocity(normal)
			heat:SetDieTime(0.08)
			heat:SetStartAlpha(255)
			heat:SetEndAlpha(255)
			heat:SetStartSize(15)
			heat:SetEndSize(13.5)
			heat:SetRoll(roll)
			heat:SetColor(255,100,100)
			
			local dynlight = DynamicLight(id + 4096*k);
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
	
	ENT.CanFPV = true;
	
	local Health = 0;
	function ENT:Think()
		self.BaseClass.Think(self);
		
		local p = LocalPlayer();
		local Flying = self:GetNWBool("Flying".. self.Vehicle);
		local TakeOff = self:GetNWBool("TakeOff");
		local Land = self:GetNWBool("Land");
		if(Flying) then
			self.EnginePos = {
				self:GetPos()+self:GetUp()*53+self:GetRight()*122+self:GetForward()*-270,
				self:GetPos()+self:GetUp()*53+self:GetRight()*-122+self:GetForward()*-270,
			}
			if(!TakeOff and !Land) then
				self:FlightEffects();
			end
			Health = self:GetNWInt("Health");
		end
		
		
	end
	
    ENT.ViewDistance = 700;
    ENT.ViewHeight = 200;
    ENT.FPVPos = Vector(95,0,88);
	
	local HUD = surface.GetTextureID("vgui/ywing_cockpit");
	function YWingReticle()
		
		local p = LocalPlayer();
		local Flying = p:GetNWBool("FlyingYWing");
		local self = p:GetNWEntity("YWing");
		

		if(Flying and IsValid(self)) then

			local FPV = self:GetFPV();
			if(FPV) then
				SW_HUD_FPV(HUD);
			end
			
			SW_HUD_DrawHull(1500);
			SW_WeaponReticles(self);
			SW_HUD_DrawOverheating(self);
			SW_BlastIcon(self);
			local x = ScrW()/4*1;
			local y = ScrH()/4*3.3;
			SW_HUD_Compass(self,x,y);
			SW_HUD_DrawSpeedometer();
		end
	end
	hook.Add("HUDPaint", "YWingReticle", YWingReticle)

end