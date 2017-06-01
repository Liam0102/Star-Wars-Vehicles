ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Base = "speeder_base"
ENT.Type = "vehicle"

ENT.PrintName = "Imperial Speeder"
ENT.Author = "Liam0102"
ENT.Category = "Star Wars Vehicles: Empire"
ENT.AutomaticFrameAdvance = true
ENT.Spawnable = false;
ENT.AdminSpawnable = false;

ENT.Vehicle = "ImperialSpeeder";
ENT.EntModel = "models/av21/av211.mdl";
ENT.StartHealth = 1000;
list.Set("SWVehicles", ENT.PrintName, ENT);
if SERVER then

ENT.NextUse = {Use = CurTime(),Fire = CurTime()};
ENT.FireSound = Sound("weapons/xwing_shoot.wav");

AddCSLuaFile();
function ENT:SpawnFunction(pl, tr)
	local e = ents.Create("imp_speeder");
	e:SetPos(tr.HitPos + Vector(0,0,10));
	e:SetAngles(Angle(0,pl:GetAimVector():Angle().Yaw+180,0));
	e:Spawn();
	e:Activate();
	return e;
end

function ENT:Initialize()
	self.SeatClass = "phx_seat2";
	self.BaseClass.Initialize(self);
	local driverPos = self:GetPos()+self:GetUp()*10+self:GetForward()*35+self:GetRight()*-15;
	local driverAng = self:GetAngles()+Angle(0,90,0);
	local passPos = self:GetPos()+self:GetUp()*20+self:GetForward()*25+self:GetRight()*15
	self:SpawnChairs(driverPos,driverAng,true,passPos,driverAng);
	self.CanBack = true;
	self.ForwardSpeed = -650;
	self.BoostSpeed = -1000
	self.AccelSpeed = 8;
	self.StandbyHoverAmount = 80;

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
	self.BackPos = self:GetPos()+self:GetForward()*80+self:GetUp()*15
	self.FrontPos = self:GetPos()+self:GetForward()*-100+self:GetUp()*15
	self.MiddlePos = self:GetPos()+self:GetUp()*15;
	if(self.Inflight) then
		local UP = ZAxis;
		self.RightDir = self.Entity:GetForward():Cross(UP):GetNormalized();
		self.FWDDir = self.Entity:GetForward();	
				
		self:RunTraces();

		self.ExtraRoll = Angle(0,0,self.YawAccel / 2);
		if(!self.WaterTrace.Hit) then
			if(self.FrontTrace.HitPos.z >= self.BackTrace.HitPos.z) then
				self.PitchMod = Angle(math.Clamp((self.BackTrace.HitPos.z - self.FrontTrace.HitPos.z),-45,45)/2*-1,0,0)
			else
				self.PitchMod = Angle(math.Clamp(-(self.FrontTrace.HitPos.z - self.BackTrace.HitPos.z),-45,45)/2*-1,0,0)
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
				self:GetPos()+self:GetForward()*120+self:GetRight()*55+self:GetUp()*20,
				self:GetPos()+self:GetForward()*120+self:GetRight()*-55+self:GetUp()*20,
			}
			self:Effects(EnginePos)
		end
		
	end

	local View = {}
	function CalcView()
		
		local p = LocalPlayer();
		local self = p:GetNWEntity("ImperialSpeeder", NULL)
		local DriverSeat = p:GetNWEntity("DriverSeat",NULL);
		local PassengerSeat = p:GetNWEntity("PassengerSeat",NULL);

		if(IsValid(self)) then

			if(IsValid(DriverSeat)) then
				if(DriverSeat:GetThirdPersonMode()) then
					local pos = self:GetPos()+LocalPlayer():GetAimVector():GetNormal()*-300+self:GetUp()*120;
					//local pos = self:GetPos()+self:GetRight()*250+self:GetUp()*100;
					//local face = self:GetAngles() + Angle(0,-90,0);
					local face = ((self:GetPos() + Vector(0,0,100))- pos):Angle();
						View.origin = pos;
						View.angles = face;
					return View;
				end
			end
			
			if(IsValid(PassengerSeat)) then
				if(PassengerSeat:GetThirdPersonMode()) then
					local pos = self:GetPos()+LocalPlayer():GetAimVector():GetNormal()*-300+self:GetUp()*120;
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
	hook.Add("CalcView", "ImperialSpeederView", CalcView)

	
	hook.Add( "ShouldDrawLocalPlayer", "ImperialSpeederDrawPlayerModel", function( p )
		local self = p:GetNWEntity("ImperialSpeeder", NULL);
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
	
	function ImperialSpeederReticle()
	
		local p = LocalPlayer();
		local Flying = p:GetNWBool("FlyingImperialSpeeder");
		local self = p:GetNWEntity("ImperialSpeeder");
		if(Flying and IsValid(self)) then
				
			SW_Speeder_DrawHull(1000)
			SW_Speeder_DrawSpeedometer()
	

		end
	end
	hook.Add("HUDPaint", "ImperialSpeederReticle", ImperialSpeederReticle)
	
	
end