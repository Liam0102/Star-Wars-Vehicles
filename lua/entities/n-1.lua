ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Base = "fighter_base"
ENT.Type = "vehicle"

ENT.PrintName = "N-1 Starfighter"
ENT.Author = "Liam0102, Syphadias"
ENT.Category = "Star Wars Vehicles: Republic"
ENT.AutomaticFrameAdvance = true
ENT.Spawnable = false;
ENT.AdminSpawnable = false;

ENT.EntModel = "models/starwars/syphadias/ships/n1/n1-hull.mdl"
ENT.Vehicle = "N1v2"
ENT.StartHealth = 1500;
ENT.Allegiance = "Republic";
list.Set("SWVehicles", ENT.PrintName, ENT);
if SERVER then

ENT.FireSound = Sound("weapons/xwing_shoot.wav");
ENT.NextUse = {Wings = CurTime(),Use = CurTime(),Fire = CurTime(),};


AddCSLuaFile();
function ENT:SpawnFunction(pl, tr)
	local e = ents.Create("n-1");
	e:SetPos(tr.HitPos + Vector(0,0,10));
	e:SetAngles(Angle(0,pl:GetAimVector():Angle().Yaw,0));
	e:Spawn();
	e:Activate();
	return e;
end

function ENT:Initialize()


	self:SetNWInt("Health",self.StartHealth);
	
	self.WeaponLocations = {
		Left = self:GetPos()+self:GetForward()*150+self:GetUp()*50+self:GetRight()*-20,
		Right = self:GetPos()+self:GetForward()*150+self:GetUp()*50+self:GetRight()*20,
	}
	self.WeaponsTable = {};
	self.BoostSpeed = 2250;
	self.ForwardSpeed = 1500;
	self.UpSpeed = 550;
	self.AccelSpeed = 9;
	self.CanStandby = true;
	self.CanBack = true;
	self.CanRoll = true;
	self.Cooldown = 2;
	self.HasLookaround = true;
	self.CanShoot = true;
	self.Bullet = CreateBulletStructure(75,"green");
	self.FireDelay = 0.15;
	self.AlternateFire = true;
	self.FireGroup = {"Left","Right",};
	//self.CurrentDroid = self.DroidModels[math.random(1,3)];
	//self.ExitModifier = {x=0,y=225,z=100};
	
	self:SpawnCockpit();
	self:SpawnR2Unit();
	self:SpawnEngines();
	self:SpawnWindow();
	
	self.PilotVisible = true;
	self.PilotPosition = {x=0,y=-45,z=33.5};
	self.PilotAnim = "drive_jeep";
	
	self.BaseClass.Initialize(self);
end

//Attachments Below
function ENT:SpawnCockpit()

	local e = ents.Create("prop_physics");
	e:SetModel("models/starwars/syphadias/ships/n1/n1-cockpit.mdl");
	e:SetAngles(self:GetAngles());
	e:SetPos(self:GetPos());
	e:Spawn();
	e:Activate();
	e:SetParent(self);
	//e:GetPhysicsObject():EnableMotion(false);
	//e:GetPhysicsObject():EnableCollisions(false);
	self.Cockpit = e;
end

function ENT:SpawnR2Unit()

	local e = ents.Create("prop_physics");
	e:SetModel("models/starwars/syphadias/ships/n1/n1-r2.mdl");
	e:SetAngles(self:GetAngles());
	e:SetPos(self:GetPos());
	e:Spawn();
	e:Activate();
	e:SetParent(self);
	//e:GetPhysicsObject():EnableMotion(false);
	//e:GetPhysicsObject():EnableCollisions(false);
	self.R2Unit = e;
end

function ENT:SpawnEngines()

	local e = ents.Create("prop_physics");
	e:SetModel("models/starwars/syphadias/ships/n1/n1-engines.mdl");
	e:SetAngles(self:GetAngles());
	e:SetPos(self:GetPos());
	e:Spawn();
	e:Activate();
	e:SetParent(self);
	//e:GetPhysicsObject():EnableMotion(false);
	//e:GetPhysicsObject():EnableCollisions(false);
	self.Engines = e;
end

function ENT:SpawnWindow()

	local e = ents.Create("prop_physics");
	e:SetModel("models/starwars/syphadias/ships/n1/n1-window.mdl");
	e:SetAngles(self:GetAngles());
	e:SetPos(self:GetPos()+self:GetForward()*44);
	e:Spawn();
	e:Activate();
	e:SetParent(self);
	//e:GetPhysicsObject():EnableMotion(false);
	//e:GetPhysicsObject():EnableCollisions(false);
	self.Window = e;
end

function ENT:Enter(p)

	if(IsValid(self.Window)) then
		self.Window:SetPos(self:GetPos()+self:GetForward()*0);
	end
	self.BaseClass.Enter(self,p);
end

function ENT:Exit(kill)

	if(IsValid(self.Window)) then
		self.Window:SetPos(self:GetPos()+self:GetForward()*44);
	end
	self.BaseClass.Exit(self,kill);
end

function ENT:Think()

	if(self.Inflight) then
		if(IsValid(self.Pilot)) then
			if(self.Pilot:KeyDown(IN_ATTACK2)) then
				local pos = self:GetPos()+self:GetForward()*220+self:GetUp()*20;
				self:FireBlast(pos,false,8,600,false,20);
			end
		end
	end
	self.BaseClass.Think(self);
end

end

if CLIENT then
	
	ENT.CanFPV = true;
	ENT.Sounds={
		Engine=Sound("ambient/atmosphere/ambience_base.wav"),
	}
	
	function ENT:Initialize()
		self.Emitter = ParticleEmitter(self:GetPos());
		self.BaseClass.Initialize(self);
	end
	
    ENT.ViewDistance = 575;
    ENT.ViewHeight = 125;
    ENT.FPVPos = Vector(-31,0,67.5);
	
	function ENT:Effects()
	

		local p = LocalPlayer();
		local roll = math.Rand(-45,45);
		local normal = (self.Entity:GetRight() * -1):GetNormalized();
		local FWD = self:GetRight();
		local id = self:EntIndex();
		for k,v in pairs(self.EnginePos) do

			local heatwv = self.Emitter:Add("sprites/heatwave",v+FWD*25);
			heatwv:SetVelocity(normal*2);
			heatwv:SetDieTime(0.1);
			heatwv:SetStartAlpha(255);
			heatwv:SetEndAlpha(255);
			heatwv:SetStartSize(25);
			heatwv:SetEndSize(20);
			heatwv:SetColor(255,255,255);
			heatwv:SetRoll(roll);
			
			local blue = self.FXEmitter:Add("sprites/bluecore",v+FWD*25)
			blue:SetVelocity(normal)
			blue:SetDieTime(0.05)
			blue:SetStartAlpha(255)
			blue:SetEndAlpha(100)
			blue:SetStartSize(25)
			blue:SetEndSize(15)
			blue:SetRoll(roll)
			blue:SetColor(255,255,255)
			
			local dynlight = DynamicLight(id + 4096 * k);
			dynlight.Pos = v+FWD*25;
			dynlight.Brightness = 5;
			dynlight.Size = 150;
			dynlight.Decay = 1024;
			dynlight.R = 100;
			dynlight.G = 100;
			dynlight.B = 255;
			dynlight.DieTime = CurTime()+1;

		end
	end
	
	function ENT:Think()
	
		
		
		local p = LocalPlayer();
		local Flying = self:GetNWBool("Flying".. self.Vehicle);
		local TakeOff = self:GetNWBool("TakeOff");
		local Land = self:GetNWBool("Land");
		if(Flying) then
			if(!TakeOff and !Land) then
				self.EnginePos = {
					self:GetPos()+self:GetRight()*-169.2+self:GetUp()*32.5+self:GetForward()*36,
					self:GetPos()+self:GetRight()*119.2+self:GetUp()*32.5+self:GetForward()*36,
				}
				self:Effects();
			end
		end
		self.BaseClass.Think(self)
	end
	
	local HUD = surface.GetTextureID("vgui/tie_cockpit");
	function N1v2Reticle()
		
		local p = LocalPlayer();
		local Flying = p:GetNWBool("FlyingN1v2");
		local self = p:GetNWEntity("N1v2");
		if(Flying and IsValid(self)) then
			SW_HUD_DrawHull(1500);
			SW_WeaponReticles(self);
			SW_HUD_DrawOverheating(self);
			SW_BlastIcon(self);

			local pos = self:GetPos()+self:GetUp()*58+self:GetForward()*-10+self:GetRight()*6.75;
			local x,y = SW_XYIn3D(pos);
			
			SW_HUD_Compass(self,x,y); // Draw the compass/radar
			SW_HUD_DrawSpeedometer();
		end
	end
	hook.Add("HUDPaint", "N1v2Reticle", N1v2Reticle)

end