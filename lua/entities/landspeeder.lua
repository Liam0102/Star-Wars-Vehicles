ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Base = "speeder_base"
ENT.Type = "vehicle"

ENT.PrintName = "X-34 Landspeeder"
ENT.Author = "Liam0102"
ENT.Category = "Star Wars Vehicles: Other"
ENT.AutomaticFrameAdvance = true
ENT.Spawnable = false;
ENT.AdminSpawnable = false;

ENT.Vehicle = "Speeder";
ENT.EntModel = "models/SGG/Starwars/landspeeder.mdl";
ENT.StartHealth = 1000;
list.Set("SWVehicles", ENT.PrintName, ENT);
if SERVER then

ENT.NextUse = {Use = CurTime(),Fire = CurTime()};
ENT.FireSound = Sound("weapons/xwing_shoot.wav");


AddCSLuaFile();
function ENT:SpawnFunction(pl, tr)
	local e = ents.Create("landspeeder");
	e:SetPos(tr.HitPos + Vector(0,0,10));
	e:SetAngles(Angle(0,pl:GetAimVector():Angle().Yaw+270,0));
	e:Spawn();
	e:Activate();
	return e;
end

function ENT:Initialize()
	self.SeatClass = "phx_seat2";
	self.BaseClass.Initialize(self);
	local driverPos = self:GetPos()+self:GetUp()*20+self:GetRight()*50+self:GetForward()*-10;
	local driverAng = self:GetAngles();
	local passPos = self:GetPos()+self:GetUp()*25+self:GetRight()*40+self:GetForward()*20;
	self:SpawnChairs(driverPos,driverAng,true,passPos,driverAng);
	
	self.ForwardSpeed = -650;
	self.BoostSpeed = -1000
	self.AccelSpeed = 6;
	self.HoverMod = 3;
	self.CanBack = true;
	self.StartHover = 55;
	self.StandbyHoverAmount = 50;

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
	self.BackPos = self:GetPos()+self:GetUp()*20+self:GetRight()*120+self:GetForward()*5;
	self.FrontPos = self:GetPos()+self:GetUp()*20+self:GetRight()*-120+self:GetForward()*5;
	self.MiddlePos = self:GetPos()+self:GetUp()*20+self:GetForward()*5;
	if(self.Inflight) then
		local UP = ZAxis;
		self.RightDir = self.Entity:GetForward();
		self.FWDDir = self.Entity:GetForward():Cross(UP):GetNormalized();	
		

		
		self:RunTraces();

		self.ExtraRoll = Angle(self.YawAccel / 2*-1,0,0);
		if(!self.WaterTrace.Hit) then
			if(self.FrontTrace.HitPos.z >= self.BackTrace.HitPos.z) then
				self.PitchMod = Angle(0,0,math.Clamp((self.BackTrace.HitPos.z - self.FrontTrace.HitPos.z),-45,45)/2*-1)
			else
				self.PitchMod = Angle(0,0,math.Clamp(-(self.FrontTrace.HitPos.z - self.BackTrace.HitPos.z),-45,45)/2*-1)
			end
		end
	end

	
	self.BaseClass.PhysicsSimulate(self,phys,deltatime);
	

end

end

if CLIENT then
	ENT.Sounds={
		Engine=Sound("vehicles/landspeeder/t47_fly2.wav"),
	}
	
	local Health = 0;
	function ENT:Think()
		self.BaseClass.Think(self);
		local p = LocalPlayer();
		local Flying = p:GetNWBool("Flying"..self.Vehicle);
		if(Flying) then
			Health = self:GetNWInt("Health");
			local EnginePos = {
				Left = 	self:GetPos()+self:GetRight()*85+self:GetForward()*-64+self:GetUp()*30,
				Middle = self:GetPos()+self:GetUp()*61+self:GetRight()*150+self:GetForward()*4,
				Right = self:GetPos()+self:GetRight()*85+self:GetForward()*75+self:GetUp()*32,
			}
			self:Effects(EnginePos,true);
		end
		
	end
    
	ENT.HasCustomCalcView = true;	
    local View = {}
	function CalcView()
		
		local p = LocalPlayer();
		local self = p:GetNWEntity("Speeder", NULL)
		local DriverSeat = p:GetNWEntity("DriverSeat",NULL);
		local PassengerSeat = p:GetNWEntity("PassengerSeat",NULL);

		if(IsValid(self)) then

			if(IsValid(DriverSeat)) then
				if(DriverSeat:GetThirdPersonMode()) then
					local pos = self:GetPos()+LocalPlayer():GetAimVector():GetNormal()*-400+self:GetUp()*100;
					//local pos = self:GetPos()+self:GetRight()*250+self:GetUp()*100;
					//local face = self:GetAngles() + Angle(0,-90,0);
					local face = ((self:GetPos() + Vector(0,0,100))- pos):Angle();
						View.origin = pos;
						View.angles = face;
					return View;
				end
			elseif(IsValid(PassengerSeat)) then
				if(PassengerSeat:GetThirdPersonMode()) then
					local pos = self:GetPos()+LocalPlayer():GetAimVector():GetNormal()*-400+self:GetUp()*100;
					//local pos = self:GetPos()+self:GetRight()*250+self:GetUp()*100;
					//local face = self:GetAngles() + Angle(0,-90,0);
					local face = ((self:GetPos() + Vector(0,0,100))- pos):Angle();
						View.origin = pos;
						View.angles = face;
					return View;
				end
			end
		end
	end
	hook.Add("CalcView", "SpeederView", CalcView)
	
	hook.Add( "ShouldDrawLocalPlayer", "SpeederDrawPlayerModel", function( p )
		local self = p:GetNWEntity("Speeder", NULL);
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
	
	function X47SpeederHUD()
	
		local p = LocalPlayer();
		local Flying = p:GetNWBool("FlyingSpeeder");
		local self = p:GetNWEntity("Speeder");
		if(Flying and IsValid(self)) then

			SW_Speeder_DrawHull(1000)
			SW_Speeder_DrawSpeedometer()

		end
	end
	hook.Add("HUDPaint", "X47SpeederHUD", X47SpeederHUD)
	
end