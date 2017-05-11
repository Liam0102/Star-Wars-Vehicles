
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Base = "speeder_base"
ENT.Type = "vehicle"

ENT.PrintName = "TX-130"
ENT.Author = "Liam0102"
ENT.Category = "Star Wars Vehicles: Republic"
ENT.AutomaticFrameAdvance = true
ENT.Spawnable = false;
ENT.AdminSpawnable = false;

ENT.Vehicle = "TX130";
ENT.EntModel = "models/tx130t/tx130t_hull1.mdl";
ENT.StartHealth = 2500;
list.Set("SWVehicles", ENT.PrintName, ENT);

if SERVER then

ENT.NextUse = {Use = CurTime(),Fire = CurTime()};
ENT.FireSound = Sound("weapons/xwing_shoot.wav");


AddCSLuaFile();
function ENT:SpawnFunction(pl, tr)
	local e = ents.Create("tx130");
	e:SetPos(tr.HitPos + Vector(0,0,10));
	e:SetAngles(Angle(0,pl:GetAimVector():Angle().Yaw+180,0));
	e:Spawn();
	e:Activate();
	return e;
end

function ENT:Initialize()

	self.BaseClass.Initialize(self);
	local driverPos = self:GetPos()+self:GetUp()*40+self:GetForward()*42;
	local driverAng = self:GetAngles()+Angle(0,90,0);
	local passPos = self:GetPos()+self:GetUp()*20+self:GetForward()*25+self:GetRight()*15
	self:SpawnChairs(driverPos,driverAng,false);
	
	self.ForwardSpeed = -300;
	self.BoostSpeed = -450
	self.AccelSpeed = 6;
	self.HoverMod = 0.5;
	self.SpeederClass = 2;
	self.NoWobble = true;
	self.WeaponLocations = {
		Left = self:GetPos()+self:GetUp()*30+self:GetRight()*46+self:GetForward()*-85,
		Right = self:GetPos()+self:GetUp()*30+self:GetRight()*-46+self:GetForward()*-85,
	}
	self.WeaponDir = self:GetAngles():Forward()*-1;
	self:SpawnWeapons();
	self.CannonLocation = self:GetPos()+self:GetUp()*60+self:GetForward()*-10;
	
	self.CanBack = true;
	self.StartHover = 30;
	
	self:SpawnTurretGuard();
	self:SpawnTurret();
	self:SpawnCannons();
	
	self.Bullet = CreateBulletStructure(150,"red");
	
end

function ENT:SpawnTurret()
	
	local e = ents.Create("prop_physics");
	e:SetPos(self:GetPos()+self:GetUp()*60+self:GetForward()*25);
	e:SetAngles(self:GetAngles());
	e:SetModel("models/tx130t/tx130t_gun1.mdl");
	e:SetParent(self.TurretGuard);
	e:Spawn();
	e:Activate();
	e:GetPhysicsObject():EnableCollisions(false);
	e:GetPhysicsObject():EnableMotion(false);
	self.Turret = e;
	self:SetNWEntity("Turret",e);
	
end

function ENT:SpawnTurretGuard()
	
	local e = ents.Create("prop_physics");
	e:SetPos(self:GetPos()+self:GetUp()*55+self:GetForward()*40);
	e:SetAngles(self:GetAngles());
	e:SetModel("models/tx130t/tx130t_turret1.mdl");
	e:SetParent(self);
	e:Spawn();
	e:Activate();
	e:GetPhysicsObject():EnableCollisions(false);
	e:GetPhysicsObject():EnableMotion(false);
	self.TurretGuard = e;

end

function ENT:SpawnCannons()
	
	local e = ents.Create("prop_physics");
	e:SetModel("models/tx130t/tx130t_arms1.mdl");
	e:SetPos(self:GetPos()+self:GetUp()*30+self:GetForward()*40);
	e:SetAngles(self:GetAngles());
	e:SetParent(self);
	e:Spawn();
	e:Activate();
	e:GetPhysicsObject():EnableCollisions(false);
	e:GetPhysicsObject():EnableMotion(false);
	self.Cannon = e;
	self:SetNWEntity("Cannon",e);
	
end

local lastY = 0;
function ENT:Think()
	self.BaseClass.Think(self)
	if(self.Inflight) then
		if(IsValid(self.Pilot)) then
		

			self.Turret.LastAng = self.Turret:GetAngles();
			self.TurretGuard.LastAng = self.TurretGuard:GetAngles();
			self.Cannon.LastAng = self.Cannon:GetAngles();
		
			local aim = self.Pilot:GetAimVector():Angle();
			local p = aim.p*-1;
			if(p <= -0 and p >= -40) then
				p = -0;
			elseif(p >= -300 and p <= 280) then
				p = -300;
			end
			self.Turret:SetAngles(Angle(p,aim.y+180,0));
			//self.DriverChair:SetAngles(self.TurretGuard:GetAngles())
			self.TurretGuard:SetAngles(Angle(self:GetAngles().p,self.Turret:GetAngles().y,self:GetAngles().r));
			self.Cannon:SetAngles(Angle(p,self:GetAngles().y,self:GetAngles().r));
			if(self.Pilot:KeyDown(IN_ATTACK2)) then
				self:FireBlast(self.Turret:GetPos()+self.Turret:GetForward()*-40,true,-3,self.Turret:GetAngles():Forward());
			elseif(self.Pilot:KeyDown(IN_ATTACK)) then
				self:FireWeapons();
			end
			lastY = aim.y;
			self:NextThink(CurTime());
			return true;
		end
	end
	
end

function ENT:Exit(driver,kill)
	
	self.BaseClass.Exit(self,driver,kill);
	if(IsValid(self.Turret)) then
		self.Turret:SetAngles(self.Turret.LastAng);
	end
	if(IsValid(self.TurretGuard)) then
		self.TurretGuard:SetAngles(self.TurretGuard.LastAng);
	end
	if(IsValid(self.Cannon)) then
		self.Cannon:SetAngles(self.Cannon.LastAng);
	end
	
end


function ENT:FireWeapons()

	if(self.NextUse.Fire < CurTime()) then
		local e = self.Cannon;
		local WeaponPos = {
			e:GetPos()+e:GetRight()*45+e:GetForward()*-110,
			e:GetPos()+e:GetRight()*-45+e:GetForward()*-110,
		}
		for k,v in pairs(WeaponPos) do
			local tr = util.TraceLine({
				start = self:GetPos(),
				endpos = self:GetPos() + self.Cannon:GetForward()*-10000,
				filter = {self,self.Cannon,self.Turret,self.TurretGuard},
			})
		
			self.Bullet.Src		= v;
			self.Bullet.Attacker = self.Pilot or self;	
			self.Bullet.Dir = (tr.HitPos - v);

			self:FireBullets(self.Bullet)
		end
		self:EmitSound(self.FireSound, 120, math.random(90,110));
		self.NextUse.Fire = CurTime() + 0.8;
	end
end

local ZAxis = Vector(0,0,1);

function ENT:PhysicsSimulate( phys, deltatime )
	self.BackPos = self:GetPos()+self:GetForward()*100;
	self.FrontPos = self:GetPos()+self:GetForward()*-145;
	self.MiddlePos = self:GetPos();
	if(self.Inflight) then
		local UP = ZAxis;
		self.RightDir = self.Entity:GetForward():Cross(UP):GetNormalized();
		self.FWDDir = self.Entity:GetForward();

		if(IsValid(self.Pilot)) then
			if(self.Pilot:KeyDown(IN_JUMP)) then
				self.Right = -500;
			elseif(self.Pilot:KeyDown(IN_WALK)) then
				self.Right = 500;
			else
				self.Right = 0;
			end
		end
		self.Accel.RIGHT = math.Approach(self.Accel.RIGHT,self.Right,5);
		

		
		self:RunTraces();

		self.ExtraRoll = Angle(0,0,self.YawAccel / 4);
		if(!self.WaterTrace.Hit) then
			if(self.FrontTrace.HitPos.z >= self.BackTrace.HitPos.z) then
				self.PitchMod = Angle(math.Clamp((self.BackTrace.HitPos.z - self.FrontTrace.HitPos.z),-45,45)/3*-1,0,0)
			else
				self.PitchMod = Angle(math.Clamp(-(self.FrontTrace.HitPos.z - self.BackTrace.HitPos.z),-45,45)/3*-1,0,0)
			end
		end
	end

	self.BaseClass.PhysicsSimulate(self,phys,deltatime);
	

end

end

if CLIENT then
	ENT.Sounds={
		Engine=Sound("ambient/atmosphere/ambience_base.wav"),
	}
	
	local Health = 0;
	local Target;
	local Turret;
	local Cannon;
	function ENT:Think()
		self.BaseClass.Think(self);
		local p = LocalPlayer();
		local Flying = p:GetNWBool("Flying"..self.Vehicle);
		if(Flying) then
			Health = self:GetNWInt("Health");
			Target = self:GetNWVector("Target");
			Turret = self:GetNWEntity("Turret");
			Cannon = self:GetNWEntity("Cannon");
		end
		
	end

	local View = {}
	function CalcView()
		
		local p = LocalPlayer();
		local self = p:GetNWEntity("TX130", NULL)
		local DriverSeat = p:GetNWEntity("DriverSeat",NULL);
		local PassengerSeat = p:GetNWEntity("PassengerSeat",NULL);

		if(IsValid(self) and IsValid(Turret)) then

			if(IsValid(DriverSeat)) then
				if(DriverSeat:GetThirdPersonMode()) then
					local pos = Turret:GetPos()+Turret:GetForward()*270+Turret:GetUp()*50;
					//local face = self:GetAngles() + Angle(0,180,0);
					local face = ((self:GetPos() + Vector(0,0,100))- pos):Angle();
						View.origin = pos;
						View.angles = face;
					return View;
				end
			end
			
		end
	end
	hook.Add("CalcView", "TX130View", CalcView)

	
	hook.Add( "ShouldDrawLocalPlayer", "TX130DrawPlayerModel", function( p )
		local self = p:GetNWEntity("TX130", NULL);
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
	
	function TX130Reticle()
	
		local p = LocalPlayer();
		local Flying = p:GetNWBool("FlyingTX130");
		local self = p:GetNWEntity("TX130");
		if(Flying and IsValid(self)) then
surface.SetDrawColor( color_white )	
			local TurretPos = Turret:GetPos()+Turret:GetForward()*-40;
			local tr = util.TraceLine({
				start = TurretPos,
				endpos = TurretPos + Turret:GetForward()*-10000,
				filter = {self,Turret},
			});
			
			local vpos = tr.HitPos;
			local screen = vpos:ToScreen();
			local x,y;
			for k,v in pairs(screen) do
				if(k == "x") then
					x = v;
				elseif(k == "y") then
					y = v;
				end
			end
			
			local w = ScrW()/100*2;
			local h = w;
			x = x - w/2;
			y = y - h/2;
			surface.SetMaterial( Material( "hud/missile_reticle.png", "noclamp" ) )
			surface.DrawTexturedRectUV( x , y, w, h, 0, 0, 1, 1 )
			
			local WeaponPos = {
				Cannon:GetPos()+Cannon:GetForward()*-105+Cannon:GetRight()*105+Cannon:GetUp()*5,
				Cannon:GetPos()+Cannon:GetForward()*-105+Cannon:GetRight()*-105+Cannon:GetUp()*5,
			}
			
		
			tr = util.TraceLine({
				start = self:GetPos(),
				endpos = self:GetPos() + Cannon:GetForward()*-10000,
				filter = {self,Cannon,Turret},
			})
			
			vpos = tr.HitPos;
			screen = vpos:ToScreen();
			x = 0;
			y = 0;
			for k,v in pairs(screen) do
				if(k == "x") then
					x = v;
				elseif(k == "y") then
					y = v;
				end
			end
			
			
			x = x - w/2;
			y = y - h/2;
			
			surface.SetMaterial( Material( "hud/reticle.png", "noclamp" ) )
			surface.DrawTexturedRectUV( x , y, w, h, 0, 0, 1, 1 )
	
			SW_Speeder_DrawHull(2500)
			SW_Speeder_DrawSpeedometer()
	
	

		end
	end
	hook.Add("HUDPaint", "TX130Reticle", TX130Reticle)
	
	
end