ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Base = "speeder_base"
ENT.Type = "vehicle"

ENT.PrintName = "Speeder Bike"
ENT.Author = "Liam0102"
ENT.Category = "Star Wars Vehicles: Empire"
ENT.AutomaticFrameAdvance = true
ENT.Spawnable = false;
ENT.AdminSpawnable = false;

ENT.Vehicle = "SpeederBike"; // The unique name for the speeder.
ENT.EntModel = "models/SGG/Starwars/speeder_bike.mdl"; // The path to your model
list.Set("SWVehicles", ENT.PrintName, ENT);

ENT.StartHealth = 1000;
if SERVER then

ENT.NextUse = {Use = CurTime(),Fire = CurTime()};
ENT.FireSound = Sound("vehicles/speeder_shoot.wav");


AddCSLuaFile();
function ENT:SpawnFunction(pl, tr)
	local e = ents.Create("speeder_bike");
	e:SetPos(tr.HitPos + Vector(0,0,10));
	e:SetAngles(Angle(0,pl:GetAimVector():Angle().Yaw+180,0));
	e:Spawn();
	e:Activate();
	return e;
end

function ENT:Initialize()
	self.BaseClass.Initialize(self);
	local driverPos = self:GetPos()+self:GetUp()*20+self:GetRight()*-10;
	local driverAng = self:GetAngles()+Angle(0,180,0);
	self:SpawnChairs(driverPos,driverAng,false)
	
	self.ForwardSpeed = -600;
	self.BoostSpeed = -900
	self.AccelSpeed = 8;
	self.WeaponLocations = {
		Main = self:GetPos()+self:GetRight()*100+self:GetUp()*15,
	}
	self.WeaponDir = self:GetAngles():Right();
	self:SpawnWeapons();
	self.HoverMod = 3;
	self.StartHover = 50;
	self.StandbyHoverAmount = 40;
	self.CanShoot = true;
	self.Bullet = CreateBulletStructure(100,"red");
	self.Flashlights = {
        {Vector(0,-100,0),Angle(0,-90,0)}
    }
    self.HasFlashlight = true;
end


local ZAxis = Vector(0,0,1);

function ENT:PhysicsSimulate( phys, deltatime )
	self.BackPos = self:GetPos()+self:GetRight()*-70+self:GetUp()*15;
	self.FrontPos = self:GetPos()+self:GetRight()*100+self:GetUp()*15;
	self.MiddlePos = self:GetPos()+self:GetUp()*15;
	if(self.Inflight) then
		local UP = ZAxis;
		self.RightDir = self.Entity:GetForward()*-1;
		self.FWDDir = self.Entity:GetForward():Cross(UP):GetNormalized()*-1;	
		

		
		self:RunTraces();

		self.ExtraRoll = Angle(self.YawAccel / 2,0,0);
		if(self.FrontTrace.HitPos.z >= self.BackTrace.HitPos.z) then
			self.PitchMod = Angle(0,0,math.Clamp((self.BackTrace.HitPos.z - self.FrontTrace.HitPos.z),-45,45)/2)
		else
			self.PitchMod = Angle(0,0,math.Clamp(-(self.FrontTrace.HitPos.z - self.BackTrace.HitPos.z),-45,45)/2)
		end
	end
	
	self.BaseClass.PhysicsSimulate(self,phys,deltatime);
	

end

end

if CLIENT then
	ENT.Sounds={
		Engine=Sound("vehicles/speederbike/speederbike_engine.wav"),
	}
	ENT.HasCustomCalcView = true;
	local Health = 0;
	local Speed = 0;
	function ENT:Think()
		self.BaseClass.Think(self);
		local p = LocalPlayer();
		local Flying = p:GetNWBool("Flying"..self.Vehicle);
		if(Flying) then

			Speed = self:GetNWInt("Speed");
		end
		
	end

	local View = {}
	function SpeederBikeCalcView()
		
		local p = LocalPlayer();
		local self = p:GetNWEntity("SpeederBike", NULL)
		local DriverSeat = p:GetNWEntity("DriverSeat",NULL);
		local PassengerSeat = p:GetNWEntity("PassengerSeat",NULL);
		if(IsValid(self)) then

			if(IsValid(DriverSeat)) then
				if(DriverSeat:GetThirdPersonMode()) then
					local pos = self:GetPos()+self:GetRight()*-250+self:GetUp()*100;
					//local face = self:GetAngles() + Angle(0,-90,0);
					local face = ((self:GetPos() + Vector(0,0,100))- pos):Angle();
						View.origin = pos;
						View.angles = face;
					return View;
				end
			end

		end
	end
	hook.Add("CalcView", "SpeederBikeView", SpeederBikeCalcView)

	
	hook.Add( "ShouldDrawLocalPlayer", "SpeederBikeDrawPlayerModel", function( p )
		local self = p:GetNWEntity("SpeederBike", NULL);
		local DriverSeat = p:GetNWEntity("DriverSeat",NULL);
		local PassengerSeat = p:GetNWEntity("PassengerSeat",NULL);
		if(IsValid(self)) then
			if(IsValid(DriverSeat)) then
				if(DriverSeat:GetThirdPersonMode()) then
					return true;
				end
			elseif(IsValid(PassengerSeat)) then
				if(PassengerSeat:GetThirdPersonMode()) then
					return true;
				end
			end
		end
	end);
	
	function SpeederBikeReticle()
	
		local p = LocalPlayer();
		local Flying = p:GetNWBool("FlyingSpeederBike");
		local self = p:GetNWEntity("SpeederBike");
		if(Flying and IsValid(self)) then
			local WeaponsPos = {self:GetPos()};
			
			SW_Speeder_Reticles(self,WeaponsPos)
			SW_Speeder_DrawHull(1000)
			SW_Speeder_DrawSpeedometer()

		end
	end
	hook.Add("HUDPaint", "SpeederBikeReticle", SpeederBikeReticle)
	
	
end