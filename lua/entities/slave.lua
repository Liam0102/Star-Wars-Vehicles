ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.Type = "vehicle"
ENT.Base = "fighter_base"

ENT.PrintName = "Slave One"
ENT.Author = "Liam0102"
ENT.Category = "Star Wars Vehicles: Empire"
ENT.AutomaticFrameAdvance = true
ENT.Spawnable = false;
ENT.AdminSpawnable = true;
ENT.AdminOnly = true;

ENT.EntModel = "models/firespray/firespray1.mdl"
ENT.Vehicle = "Slave"
ENT.StartHealth = 7000;
ENT.Allegiance = "Empire";
list.Set("SWVehicles", ENT.PrintName, ENT);
if SERVER then

ENT.FireSound = Sound("weapons/slave_shoot.wav");
ENT.NextUse = {Wings = CurTime(),Use = CurTime(),Fire = CurTime(),FireMode = CurTime(),};


AddCSLuaFile();
function ENT:SpawnFunction(pl, tr)
	local e = ents.Create("slave");
	e:SetPos(tr.HitPos + Vector(0,0,175));
	e:SetAngles(Angle(-90,pl:GetAimVector():Angle().Yaw-180,0));
	e:Spawn();
	e:Activate();
	return e;
end


function ENT:Initialize()
	
	self:SetNWInt("Health",self.StartHealth);
	self.CanRoll = true;
	self.CanBack = true;
	self.WeaponLocations = {
		Left = self:GetPos()+self:GetForward()*60+self:GetUp()*70+self:GetRight()*-40,
		Right = self:GetPos()+self:GetForward()*60+self:GetUp()*70+self:GetRight()*40,
	}
	self.WeaponsTable = {};
	//self:SpawnWeapons();
	self.BoostSpeed = 3000;
	self.ForwardSpeed = 1500;
	self.UpSpeed = 600;
	self.AccelSpeed = 10;
	self.HasWings = true;
	self.ExitModifier = {x=0,y=-100,z=0};
	self.DontOverheat = true;
	self.FireDelay = 0;
	self.Bullet = CreateBulletStructure(180,"red");
	self.CanShoot = true;
	self.AlternateFire = true;
	self.FireGroup = {"Left","Right"}
	self.TakeOffVector = Vector(0,0,300);
	
	self:TestLoc(self:GetPos()+self:GetForward()*-150+self:GetUp()*407.5+self:GetRight()*60);

	self.BaseClass.Initialize(self)
	
	self:SetSkin(1);
end



function ENT:Enter(p)

	self.EnterAngles = Angle(0,self:GetAngles().y,self:GetAngles().r);
	
	self.BaseClass.Enter(self,p);
	
end

function ENT:Think()
	self.BaseClass.Think(self);
	if(self.Inflight) then
		if(IsValid(self.Pilot)) then

			self.LandAngles = Angle(-90,self:GetAngles().y,0);
		end
	end

end

end

if CLIENT then
	local Booster = Material("sprites/slave_engine");
	function ENT:Draw() 
		self:DrawModel()
	end
	
	ENT.EnginePos = {}
	ENT.Sounds={
		Engine=Sound("vehicles/slave1_fly_loop.wav"),
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
			Health = self:GetNWInt("Health");
			if(!TakeOff and !Land) then
				self:FlightEffects();
			end
		end
		
		
	end	
	function ENT:FlightEffects()
		local normal = (self:GetForward() * -1):GetNormalized()
		local roll = math.Rand(-90,90)
		local p = LocalPlayer()		
		local FWD = self:GetForward();
		local id = self:EntIndex();
		
		self.EnginePos = {
			self:GetPos()+self:GetForward()*-152.5+self:GetUp()*315+self:GetRight()*45,
			self:GetPos()+self:GetForward()*-152.5+self:GetUp()*315+self:GetRight()*-45,
			
			self:GetPos()+self:GetForward()*-152.5+self:GetUp()*407.5+self:GetRight()*50,
			self:GetPos()+self:GetForward()*-152.5+self:GetUp()*407.5+self:GetRight()*40,
			self:GetPos()+self:GetForward()*-152.5+self:GetUp()*407.5+self:GetRight()*30,
			self:GetPos()+self:GetForward()*-152.5+self:GetUp()*407.5+self:GetRight()*20,
			self:GetPos()+self:GetForward()*-152.5+self:GetUp()*407.5+self:GetRight()*10,
			self:GetPos()+self:GetForward()*-152.5+self:GetUp()*407.5,
			self:GetPos()+self:GetForward()*-152.5+self:GetUp()*407.5+self:GetRight()*-10,
			self:GetPos()+self:GetForward()*-152.5+self:GetUp()*407.5+self:GetRight()*-20,
			self:GetPos()+self:GetForward()*-152.5+self:GetUp()*407.5+self:GetRight()*-30,
			self:GetPos()+self:GetForward()*-152.5+self:GetUp()*407.5+self:GetRight()*-40,
			self:GetPos()+self:GetForward()*-152.5+self:GetUp()*407.5+self:GetRight()*-50,
		}
		
		

		for k,v in pairs(self.EnginePos) do	
			local size = 39;
			if(k > 2) then
				size = 30;
			end
			local red = self.FXEmitter:Add("sprites/orangecore1",v)
			red:SetVelocity(normal)
			//red:SetDieTime(0.035)
			red:SetDieTime(FrameTime()*1.25)
			red:SetStartAlpha(255)
			red:SetEndAlpha(255)
			red:SetStartSize(size)
			red:SetEndSize(size*0.75)
			red:SetRoll(roll)
			red:SetColor(255,255,255)
					
			
			local dynlight = DynamicLight(id + 4096 * k);
			dynlight.Pos = v+FWD*-25;
			dynlight.Brightness = 5;
			dynlight.Size = 100;
			dynlight.Decay = 1024;
			dynlight.R = 255;
			dynlight.G = 128;
			dynlight.B = 0;
			dynlight.DieTime = CurTime()+1;

		end
	
	end
    
    ENT.ViewDistance = 1000;
    ENT.ViewHeight = 500;
    ENT.FPVPos = Vector(10,0,400);
	
	local HUD = surface.GetTextureID("vgui/slave_cockpit")
	function SlaveReticle()
		
		local p = LocalPlayer();
		local Flying = p:GetNWBool("FlyingSlave");
		local self = p:GetNWEntity("Slave");
		

		if(Flying and IsValid(self)) then
			local FPV = self:GetFPV();
			
			if(FPV) then
				SW_HUD_FPV(HUD);
				SW_HUD_WingsIndicator("slave1");
			end
			SW_HUD_DrawHull(7000);
			SW_WeaponReticles(self);
			
			local x = ScrW()/4*1.15;
			local y = ScrH()/4*3.25;
			SW_HUD_Compass(self,x,y);
			SW_HUD_DrawSpeedometer();
		end
	end
	hook.Add("HUDPaint", "SlaveReticle", SlaveReticle)

end