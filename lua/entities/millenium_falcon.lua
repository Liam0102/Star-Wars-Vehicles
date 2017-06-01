ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.Type = "vehicle"
ENT.Base = "fighter_base"

ENT.PrintName = "Millennium Falcon"
ENT.Author = "Liam0102"
ENT.Category = "Star Wars Vehicles: Rebels"
ENT.AutomaticFrameAdvance = true
ENT.Spawnable = false;
ENT.AdminSpawnable = true;
ENT.AdminOnly = true;

ENT.EntModel = "models/mf/mf.mdl"
ENT.FlyModel = "models/mf/mf1.mdl"
ENT.Vehicle = "Falcon"
ENT.StartHealth = 6000;
ENT.Allegiance = "Rebels";
list.Set("SWVehicles", ENT.PrintName, ENT);
util.PrecacheModel("models/mf/mf1.mdl")


if SERVER then

ENT.FireSound = Sound("vehicles/mf/mf_shoot2.wav");
ENT.NextUse = {Wings = CurTime(),Use = CurTime(),Fire = CurTime(),FireMode = CurTime(),};


AddCSLuaFile();
function ENT:SpawnFunction(pl, tr)
	local e = ents.Create("millenium_falcon");
	e:SetPos(tr.HitPos + Vector(0,0,10));
	e:SetAngles(Angle(0,pl:GetAimVector():Angle().Yaw,0));
	e:Spawn();
	e:Activate();
	return e;
end

function ENT:Initialize()
	
	self:SetNWInt("Health",self.StartHealth);
	self.CanRoll = true;
	self.CanBack = true;
	self.WeaponLocations = {
		TopRight = self:GetPos()+self:GetUp()*210+self:GetForward()*450+self:GetRight()*7,
		BottomRight = self:GetPos()+self:GetUp()*40+self:GetForward()*450+self:GetRight()*7,
		TopLeft = self:GetPos()+self:GetUp()*210+self:GetForward()*450+self:GetRight()*-9,
		BottomLeft = self:GetPos()+self:GetUp()*40+self:GetForward()*450+self:GetRight()*-9,
	}
	self.WeaponsTable = {};
	//self:SpawnWeapons();
	self.BoostSpeed = 3000;
	self.ForwardSpeed = 1500;
	self.UpSpeed = 600;
	self.AccelSpeed = 10;
	self.ExitModifier = {x=-450,y=-130,z=15}
	self.CanShoot = true;
	self.DontOverheat = true;
	self.FireDelay = 0.15
	self.AlternateFire = true;
	self.FireGroup = {"TopRight","TopLeft","BottomRight","BottomLeft"}
	self.Bullet = CreateBulletStructure(200,"red");
	self.HasLightspeed = true;
	self.BaseClass.Initialize(self)

end


function ENT:Enter(p)

	self:SetModel(self.FlyModel);
	self.BaseClass.Enter(self,p);

end

function ENT:Exit()
	
	if(self.TakeOff) then
		self:SetModel(self.EntModel);
	end		
	self.BaseClass.Exit(self);
	
end


end

if CLIENT then

	function ENT:Draw() self:DrawModel() end
	
	ENT.EnginePos = {}
	ENT.Sounds={
		Engine=Sound("vehicles/mf/mf_fly5.wav"),
	}
	
	local Health = 0;
	ENT.NextView = CurTime();
	ENT.CanFPV = true;
	function ENT:Think()
		self.BaseClass.Think(self);
		
		local p = LocalPlayer();
		local Flying = self:GetNWBool("Flying".. self.Vehicle);
		local IsFlying = p:GetNWBool("Flying"..self.Vehicle);
		local Wings = self:GetNWBool("Wings");
		local TakeOff = self:GetNWBool("TakeOff");
		local Land = self:GetNWBool("Land");
		
		if(Flying) then
			if(!TakeOff and !Land) then
				self:FlightEffects();
			end
			Health = self:GetNWInt("Health");

		end
		
		
	end
	
    ENT.ViewDistance = 1000;
    ENT.ViewHeight = 250;
    ENT.FPVPos = Vector(160,-320,140);
	
	function ENT:FlightEffects()
		local normal = (self:GetForward() * -1):GetNormalized()
		local roll = math.Rand(-90,90)
		local p = LocalPlayer()		
		local FWD = self:GetForward();
		local id = self:EntIndex();
		
		self.EnginePos = {
			self:GetPos()+self:GetUp()*135+self:GetRight()*-230+self:GetForward()*-462;
			self:GetPos()+self:GetUp()*135+self:GetRight()*-185+self:GetForward()*-482;
			self:GetPos()+self:GetUp()*135+self:GetRight()*-145+self:GetForward()*-502;
			self:GetPos()+self:GetUp()*135+self:GetRight()*-105+self:GetForward()*-522;
			
			self:GetPos()+self:GetUp()*135+self:GetRight()*-65+self:GetForward()*-532;
			self:GetPos()+self:GetUp()*135+self:GetRight()*-20+self:GetForward()*-539;
			self:GetPos()+self:GetUp()*135+self:GetRight()*20+self:GetForward()*-539;
			self:GetPos()+self:GetUp()*135+self:GetRight()*65+self:GetForward()*-532;
			
			self:GetPos()+self:GetUp()*135+self:GetRight()*230+self:GetForward()*-462;
			self:GetPos()+self:GetUp()*135+self:GetRight()*185+self:GetForward()*-482;
			self:GetPos()+self:GetUp()*135+self:GetRight()*145+self:GetForward()*-502;
			self:GetPos()+self:GetUp()*135+self:GetRight()*105+self:GetForward()*-522;
		}
		for k,v in pairs(self.EnginePos) do
				
			local blue = self.FXEmitter:Add("sprites/bluecore",v)
			blue:SetVelocity(normal)
			blue:SetDieTime(FrameTime()*1.25)
			blue:SetStartAlpha(255)
			blue:SetEndAlpha(255)
			blue:SetStartSize(37.5)
			blue:SetEndSize(25)
			blue:SetRoll(roll)
			blue:SetColor(255,255,255)
			
			local dynlight = DynamicLight(id + 4096 * k);
			dynlight.Pos = v;
			dynlight.Brightness = 5;
			dynlight.Size = 250;
			dynlight.Decay = 1024;
			dynlight.R = 100;
			dynlight.G = 100;
			dynlight.B = 255;
			dynlight.DieTime = CurTime()+1;
			
		end
	
	end
	
	local HUD = surface.GetTextureID("vgui/falcon_cockpit")
	local Glass = surface.GetTextureID("models/props_c17/frostedglass_01a_dx60")
	function FalconReticle()
		
		local p = LocalPlayer();
		local Flying = p:GetNWBool("FlyingFalcon");
		local self = p:GetNWEntity("Falcon");
		

		if(Flying and IsValid(self)) then

			local FPV = self:GetFPV();
			
			if(FPV) then
				SW_HUD_FPV(HUD);
			end
			
			SW_HUD_DrawHull(6000);
			SW_WeaponReticles(self);
			
			local x = ScrW()/4*1.3;
			local y = ScrH()/4*3.1;
			SW_HUD_Compass(self,x,y);
			SW_HUD_DrawSpeedometer();
		end
	end
	hook.Add("HUDPaint", "FalconReticle", FalconReticle)

end