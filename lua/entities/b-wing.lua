ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Base = "fighter_base"
ENT.Type = "vehicle"

ENT.PrintName = "B-Wing"
ENT.Author = "Liam0102"
ENT.Category = "Star Wars Vehicles: Rebels"
ENT.AutomaticFrameAdvance = true
ENT.Spawnable = false;
ENT.AdminSpawnable = false;

ENT.EntModel = "models/bwing/bwing.mdl"
ENT.Vehicle = "BWing"
ENT.StartHealth = 2500;
ENT.Allegiance = "Rebels";

util.PrecacheModel("models/bwing/bwingopen.mdl");

ENT.Open = "models/bwing/bwingopen.mdl";
ENT.Closed = "models/bwing/bwing.mdl";
list.Set("SWVehicles", ENT.PrintName, ENT);
if SERVER then

ENT.FireSound = Sound("weapons/xwing_shoot.wav");
ENT.NextUse = {Wings = CurTime(),Use = CurTime(),Fire = CurTime(),};


AddCSLuaFile();
function ENT:SpawnFunction(pl, tr)
	local e = ents.Create("b-wing");
	e:SetPos(tr.HitPos + Vector(0,0,-20));
	e:SetAngles(Angle(0,pl:GetAimVector():Angle().Yaw,0));
	e:Spawn();
	e:Activate();
	return e;
end

function ENT:Initialize()


	self:SetNWInt("Health",self.StartHealth);
	
	self.WeaponLocations = {
		MainTop = self:GetPos()+self:GetRight()*890+self:GetUp()*205+self:GetForward()*175,
		MainBottom = self:GetPos()+self:GetRight()*890+self:GetUp()*150+self:GetForward()*175,
		
		CockpitLeft = self:GetPos()+self:GetUp()*158+self:GetForward()*140+self:GetRight()*-22.5,
		CockpitRight = self:GetPos()+self:GetUp()*158+self:GetForward()*140+self:GetRight()*-9,
		
		
	}
	self.WeaponsTable = {};
	self.BoostSpeed = 2500;
	self.ForwardSpeed = 1250;
	self.UpSpeed = 700;
	self.AccelSpeed = 8;
	self.CanStandby = true;
	self.CanBack = false;
	self.CanRoll = true;
	self.CanStrafe = false;
	self.Cooldown = 2;
	self.HasWings = false;
	self.CanShoot = true;
	self.Bullet = CreateBulletStructure(25,"red");
	self.FireDelay = 0.15;
	self.AlternateFire = true;
	self.FireGroup = {"MainTop","MainBottom","CockpitLeft","CockpitRight"};
	//self.ExitModifier = {x=0,y=225,z=100};
	self.Wings = false;
	self.HasLookaround = true;
	
	self.BaseClass.Initialize(self);

end

function ENT:ToggleWings()
	if(self.NextUse.Wings < CurTime()) then
		self:RemoveWeapons();

		if(self.Wings) then
			self:SetModel(self.Closed);
			self:SetPos(self:GetPos()+self:GetUp()*-215+self:GetRight()*-289.5+self:GetForward()*-16.5)
			self.Wings = false;
			for k,v in pairs(self.WeaponLocations) do
				if(k == "MainTop") then
					self.WeaponLocations[k] = self:GetPos()+self:GetRight()*890+self:GetUp()*205+self:GetForward()*175;
				elseif(k == "MainBottom") then
					self.WeaponLocations[k] = self:GetPos()+self:GetRight()*890+self:GetUp()*150+self:GetForward()*175;
				elseif(k == "CockpitRight") then
					self.WeaponLocations[k] = self:GetPos()+self:GetUp()*158+self:GetForward()*140+self:GetRight()*-22.5;
				elseif(k == "CockpitLeft") then
					self.WeaponLocations[k] = self:GetPos()+self:GetUp()*158+self:GetForward()*140+self:GetRight()*-9;
				end
			end
			self.FireDelay = 0.15;
			self.FireGroup = {"MainTop","MainBottom","CockpitLeft","CockpitRight"};
			self:SpawnWeapons();
		else
			self:SetModel(self.Open);
			self:SetPos(self:GetPos()+self:GetUp()*215+self:GetRight()*289.5+self:GetForward()*16.5)
			self.Wings = true;
			for k,v in pairs(self.WeaponLocations) do
				if(k == "MainTop") then
					self.WeaponLocations[k] = self:GetPos()+self:GetRight()*15+self:GetUp()*267.5+self:GetForward()*140;
				elseif(k == "MainBottom") then
					self.WeaponLocations[k] = self:GetPos()+self:GetRight()*15+self:GetUp()*-340+self:GetForward()*140;
				end				
			end
			self.FireGroup = {"MainTop","MainBottom"};
			self.Bullet = CreateBulletStructure(100,"red");
			self.FireDelay = 0.25;
			self:SpawnWeapons();
		end
		self.NextUse.Wings = CurTime() + 1;
		self:SetNWBool("Wings",self.Wings);
	end
end

function ENT:RemoveWeapons()
	for k,v in pairs(self.Weapons) do
		v:Remove();
	end

end

function ENT:Think()

	if(self.Inflight) then
		if(IsValid(self.Pilot)) then
			if(!self.TakeOff and !self.Land) then
				if(self.Pilot:KeyDown(IN_SPEED)) then
					self:ToggleWings();
				end
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
	
    ENT.HasCustomCalcView = true;
	local View = {}
	local function CalcView()
		
		local p = LocalPlayer();
		local self = p:GetNetworkedEntity("BWing", NULL)
		local Wings = self:GetNWBool("Wings");
		if(IsValid(self)) then
			local fpvPos = self:GetPos()+self:GetRight()*-17+self:GetUp()*205+self:GetForward()*55;
			if(Wings) then
				fpvPos = fpvPos + self:GetUp()*-215 + self:GetRight()*-289.5+self:GetForward()*-16.5;
			end
			View = SWVehicleView(self,850,200,fpvPos,true);		
			return View;
		end
	end
	hook.Add("CalcView", "BWingView", CalcView)
	
	function ENT:Effects()
		self.ThrusterLocations = {
			self:GetPos()+self:GetRight()*188+self:GetUp()*205+self:GetForward()*-150,
			self:GetPos()+self:GetRight()*243+self:GetUp()*205+self:GetForward()*-150,	
			self:GetPos()+self:GetRight()*188+self:GetUp()*150+self:GetForward()*-150,
			self:GetPos()+self:GetRight()*243+self:GetUp()*150+self:GetForward()*-150,
		}
		local p = LocalPlayer();
		local roll = math.Rand(-45,45);
		local normal = (self.Entity:GetForward() * -1):GetNormalized();
		local id = self:EntIndex();
		local Wings = self:GetNWBool("Wings");
		for k,v in pairs(self.ThrusterLocations) do
			
			if(Wings) then
				v = v + self:GetUp()*-215+self:GetRight()*-289.5+self:GetForward()*-16.5;
			end
			
			local heatwv = self.Emitter:Add("sprites/heatwave",v);
			heatwv:SetVelocity(normal*2);
			heatwv:SetDieTime(0.1);
			heatwv:SetStartAlpha(255);
			heatwv:SetEndAlpha(255);
			heatwv:SetStartSize(40);
			heatwv:SetEndSize(10);
			heatwv:SetColor(255,255,255);
			heatwv:SetRoll(roll);
			
			local red = self.FXEmitter:Add("sprites/orangecore1",v)
			red:SetVelocity(normal)
			red:SetDieTime(0.03)
			red:SetStartAlpha(255)
			red:SetEndAlpha(255)
			red:SetStartSize(50)
			red:SetEndSize(10)
			red:SetRoll(roll)
			red:SetColor(255,100,100)
		
			local dynlight = DynamicLight(id + 4096 * k);
			dynlight.Pos = v;
			dynlight.Brightness = 5;
			dynlight.Size = 150;
			dynlight.Decay = 1024;
			dynlight.R = 255;
			dynlight.G = 100;
			dynlight.B = 100;
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
				self:Effects();
			end
		end
		
	end
	
	function BWingReticle()
		
		local p = LocalPlayer();
		local Flying = p:GetNWBool("FlyingBWing");
		local self = p:GetNWEntity("BWing");
		if(Flying and IsValid(self)) then
			if(self:GetFPV()) then
				SW_HUD_WingsIndicator("bwing",x,y);
			end
			SW_HUD_DrawHull(2500);
			SW_WeaponReticles(self);
			SW_HUD_DrawOverheating(self);
			
			local pos = self:GetPos()+self:GetRight()*-22+self:GetUp()*200+self:GetForward()*65;
			local Wings = self:GetNWBool("Wings") or p:GetNWBool("SW_Wings");
			if(Wings) then
				pos = pos + self:GetUp()*-215 + self:GetRight()*-289.5+self:GetForward()*-16.5;
			end
			
			local x,y = SW_XYIn3D(pos)
			SW_HUD_Compass(self,x,y);
			SW_HUD_DrawSpeedometer();
			
		end
	end
	hook.Add("HUDPaint", "BWingReticle", BWingReticle)

end