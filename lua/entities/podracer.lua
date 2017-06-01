ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Base = "speeder_base"
ENT.Type = "vehicle"

ENT.PrintName = "Podracer"
ENT.Author = "Liam0102"
ENT.Category = "Star Wars Vehicles: Other"
ENT.AutomaticFrameAdvance = true
ENT.Spawnable = false;
ENT.AdminSpawnable = false;

ENT.Vehicle = "Podracer";
ENT.EntModel = "models/sebracer/sebracer.mdl";
ENT.StartHealth = 1000;
list.Set("SWVehicles", ENT.PrintName, ENT);
if SERVER then

ENT.NextUse = {Use = CurTime(),Fire = CurTime()};
ENT.FireSound = Sound("weapons/xwing_shoot.wav");

AddCSLuaFile();
function ENT:SpawnFunction(pl, tr)
	local e = ents.Create("podracer");
	e:SetPos(tr.HitPos + Vector(0,0,10));
	e:SetAngles(Angle(0,pl:GetAimVector():Angle().Yaw,0));
	e:Spawn();
	e:Activate();
	return e;
end

function ENT:Initialize()

	self.BaseClass.Initialize(self);
	local driverPos = self:GetPos()+self:GetUp()*155+self:GetForward()*-300+self:GetRight()*-5;
	local driverAng = self:GetAngles()+Angle(0,-90,0);
	self:SpawnChairs(driverPos,driverAng,false);
	self.CanBack = true;
	self.ForwardSpeed = 500;
	self.BoostSpeed = 1000
	self.AccelSpeed = 6;
end


function ENT:OnTakeDamage(dmg) --########## Shuttle's aren't invincible are they? @RononDex

	local health=self:GetNetworkedInt("Health")-(dmg:GetDamage()/2)

	self:SetNWInt("Health",health);
	
	if(health<100) then
		self.CriticalDamage = true;
		self:SetNWBool("CriticalDamage",true);
	end
	
	
	if((health)<=0) then
		self:Bang() -- Go boom
	end
end

local ZAxis = Vector(0,0,1);
function ENT:PhysicsSimulate( phys, deltatime )
	self.BackPos = self:GetPos()+self:GetForward()*-300+self:GetUp()*40;
	self.FrontPos = self:GetPos()+self:GetForward()*280+self:GetUp()*40;
	self.MiddlePos = self:GetPos()+self:GetUp()*40;
	if(self.Inflight) then
		local UP = ZAxis;
		self.RightDir = self.Entity:GetForward():Cross(UP):GetNormalized();
		self.FWDDir = self.Entity:GetForward();	


		
		self:RunTraces();

		self.ExtraRoll = Angle(0,0,self.YawAccel / 2*-1);
		if(!self.WaterTrace.Hit) then
			if(self.FrontTrace.HitPos.z >= self.BackTrace.HitPos.z) then
				self.PitchMod = Angle(math.Clamp((self.BackTrace.HitPos.z - self.FrontTrace.HitPos.z),-45,45)/2,0,0)
			else
				self.PitchMod = Angle(math.Clamp(-(self.FrontTrace.HitPos.z - self.BackTrace.HitPos.z),-45,45)/2,0,0)
			end
		end
	end

	
	self.BaseClass.PhysicsSimulate(self,phys,deltatime);
	

end

end

if CLIENT then
	ENT.Sounds={
		Engine=Sound("landspeeder_fly.wav"),
	}
	ENT.HasCustomCalcView = true;
	local Health = 0;
	function ENT:Think()
		self.BaseClass.Think(self);
		local p = LocalPlayer();
		local Flying = p:GetNWBool("Flying"..self.Vehicle);
		if(Flying) then
			Health = self:GetNWInt("Health");
			local EnginePos = {
				Left = 	self:GetPos()+self:GetRight()*-106+self:GetUp()*96,
				Right = self:GetPos()+self:GetRight()*96+self:GetUp()*96,
			}
			self:Effects(EnginePos);
		end
		
	end

	local View = {}
	function CalcView()
		
		local p = LocalPlayer();
		local self = p:GetNWEntity("Podracer", NULL)
		local DriverSeat = p:GetNWEntity("DriverSeat",NULL);

		if(IsValid(self)) then

			if(IsValid(DriverSeat)) then
				if(DriverSeat:GetThirdPersonMode()) then
					local pos = self:GetPos()+LocalPlayer():GetAimVector():GetNormal()*-600+self:GetUp()*250;
					//local face = self:GetAngles() + Angle(0,-90,0);
					local face = ((self:GetPos() + Vector(0,0,100))- pos):Angle();
						View.origin = pos;
						View.angles = face;
					return View;
				end
			end
		end
	end
	hook.Add("CalcView", "PodracerView", CalcView)
	
	hook.Add( "ShouldDrawLocalPlayer", "PodracerDrawPlayerModel", function( p )
		local self = p:GetNWEntity("Podracer", NULL);
		local DriverSeat = p:GetNWEntity("DriverSeat",NULL);
		if(IsValid(self)) then
			if(IsValid(DriverSeat)) then
				if(DriverSeat:GetThirdPersonMode()) then
					return true;
				end
			end
		end
	end);
	
	local function PodracerHUD()
	
		local p = LocalPlayer();
		local Flying = p:GetNWBool("FlyingPodracer");
		local self = p:GetNWEntity("Podracer");
		if(Flying and IsValid(self)) then

			SW_Speeder_DrawHull(1000)
			SW_Speeder_DrawSpeedometer()

		end
	end
	hook.Add("HUDPaint", "PodracerHUD", PodracerHUD)
end