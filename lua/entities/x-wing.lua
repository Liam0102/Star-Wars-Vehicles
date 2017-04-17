
ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.Type = "vehicle"
ENT.Base = "fighter_base"

ENT.PrintName = "X-Wing"
ENT.Author = "Liam0102"
ENT.Category = "Star Wars Vehicles: Rebels"
ENT.AutomaticFrameAdvance = true
ENT.Spawnable = false;
ENT.AdminSpawnable = false;

ENT.EntModel = "models/xwing/xwingtwo1.mdl"
ENT.Vehicle = "XWing"
ENT.StartHealth = 2000;
ENT.Allegiance = "Rebels";
list.Set("SWVehicles", ENT.PrintName, ENT);
util.PrecacheModel("models/xwing/xwingtwo1.mdl")

if SERVER then

ENT.FireSound = Sound("weapons/xwing_shoot.wav");
ENT.NextUse = {Wings = CurTime(),Use = CurTime(),Fire = CurTime(),FireMode = CurTime(),Torpedos = CurTime(),};


AddCSLuaFile();
function ENT:SpawnFunction(pl, tr)
	local e = ents.Create("x-wing");
	e:SetPos(tr.HitPos + Vector(0,0,20));
	e:SetAngles(Angle(0,pl:GetAimVector():Angle().Yaw,0));
	e:Spawn();
	e:Activate();
	return e;
end

function ENT:Initialize()
	
	self:SetNWInt("Health",self.StartHealth);
	self.CanRoll = true;
	self.WeaponLocations = {
		TopRight = self:GetPos()+self:GetUp()*117+self:GetRight()*187.5+self:GetForward()*167.5,
		BottomRight = self:GetPos()+self:GetRight()*187+self:GetForward()*167+self:GetUp()*-10,
		TopLeft = self:GetPos()+self:GetUp()*117+self:GetRight()*-187.5+self:GetForward()*167.5,
		BottomLeft = self:GetPos()+self:GetRight()*-187+self:GetForward()*167+self:GetUp()*-10,
	}
	self.WeaponsTable = {};
	//self:SpawnWeapons();
	self.BoostSpeed = 1250;
	self.ForwardSpeed = 2250;
	self.UpSpeed = 500;
	self.AccelSpeed = 8;
	self.CanStandby = false;
	self.Cooldown = 2;
	self.Overheat = 0;
	self.Overheated = false;
	self.CanShoot = true;
	self.CanRoll = true;
	self.AlternateFire = true;
	self.FireGroup = {"BottomLeft","BottomRight","TopRight","TopLeft"}
	self.HasWings = true;
	self.ExitModifier = {x = 100, y = -80, z = 115};
	self.FireDelay = 0.15;
	//self.FireMode = 1;
	self.LandOffset = Vector(0,0,20);
	self.NextUse.Torpedos = CurTime();

	//self:SetSkin(6);
	self.Bullet = CreateBulletStructure(80,"red");

	self.BaseClass.Initialize(self)
	self:SpawnLandingGear();


end

local fire = 1;
function ENT:ProtonTorpedos()

	if(self.NextUse.Torpedos < CurTime()) then
		local pos;
		if(fire == 1) then
			pos = self:GetPos()+self:GetUp()*45+self:GetForward()*300+self:GetRight()*-25;
			self.NextUse.Torpedos = CurTime()+0.25;
		elseif(fire == 2) then
			pos = self:GetPos()+self:GetUp()*45+self:GetForward()*300+self:GetRight()*25;
			
		end
		local e = self:FindTarget();
		self:FireTorpedo(pos,e,1500,200,Color(255,50,50,255),15);
		fire = fire + 1;
		if(fire > 2) then
			fire = 1;
			self.NextUse.Torpedos = CurTime()+30;
			self:SetNWInt("FireBlast",self.NextUse.Torpedos)
		else
			self:ProtonTorpedos();
		end

	end
end

function ENT:Think()
	

	if(self.Inflight) then
		if(!self.Wings) then
			self.CanShoot = false;
		else
			self.CanShoot = true;
		end
		
		if(IsValid(self.Pilot)) then
			if(self.Pilot:KeyDown(IN_ATTACK2)) then
				self:ProtonTorpedos();
			end
		end
		
	end
	self.BaseClass.Think(self);
end

function ENT:Enter(p)
	self:RemoveLandingGear();
	self.BaseClass.Enter(self,p);
end

function ENT:Exit(kill)
	self.BaseClass.Exit(self,kill);
	if(self.TakeOff or self.Land or self.Docked) then
		self:SpawnLandingGear();
	end
end

function ENT:SpawnLandingGear()

	local e = ents.Create("prop_physics");
	e:SetModel("models/xwingt70/landgear.mdl")
	e:SetPos(self:GetPos()+self:GetUp()*-2.5);
	e:SetAngles(self:GetAngles());
	e:Spawn();
	e:Activate();
	
	local phys = e:GetPhysicsObject();
	phys:EnableGravity(false);
	phys:EnableDrag(false);
	phys:SetMass(self.Mass);
	constraint.Weld(self,e,0,0,0,true);
	self.LandingGear = e;

end

function ENT:RemoveLandingGear()
	
	if(IsValid(self.LandingGear)) then
		self.LandingGear:Remove();
	end

end

function ENT:OnRemove()
	
	self.BaseClass.OnRemove(self);
	if(IsValid(self.LandingGear)) then
		self.LandingGear:Remove();
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
	

	
	local Health = 0;
	local Overheat = 0;
	local Overheated = false;
	//local FireMode;
	local FPV = false;
	local TakeOff;
	local Land;
	ENT.NextView = CurTime();
	function ENT:Think()
		

		local p = LocalPlayer();
		local Flying = self:GetNWBool("Flying".. self.Vehicle);
		local IsFlying = p:GetNWBool("Flying"..self.Vehicle);
		local Wings = self:GetNWBool("Wings");
		TakeOff = self:GetNWBool("TakeOff");
		Land = self:GetNWBool("Land");
		
		if(Flying) then

			if(Wings) then
				self.EnginePos = {
					self:GetPos()+self:GetForward()*-160+self:GetUp()*95+self:GetRight()*47.5,
					self:GetPos()+self:GetForward()*-160+self:GetUp()*15+self:GetRight()*47.5,
					self:GetPos()+self:GetForward()*-160+self:GetUp()*95+self:GetRight()*-47.5,
					self:GetPos()+self:GetForward()*-160+self:GetUp()*15+self:GetRight()*-47.5,
				}
			else
				self.EnginePos = {
					self:GetPos()+self:GetForward()*-160+self:GetUp()*87.5+self:GetRight()*55,
					self:GetPos()+self:GetForward()*-160+self:GetUp()*22.5+self:GetRight()*55,
					self:GetPos()+self:GetForward()*-160+self:GetUp()*87.5+self:GetRight()*-55,
					self:GetPos()+self:GetForward()*-160+self:GetUp()*22.5+self:GetRight()*-55,
				}

			end
			
			if(!TakeOff and !Land) then
				//local s = "sprites/orangecore1";
				//local c = Color(255,100,100,255);
				self:FlightEffects();
			end

		end
		self.BaseClass.Think(self);
		
	end
	
	local matPlasma	= Material( "sprites/tfaenginered" )
	function ENT:Draw() 
		self:DrawModel()
		local Flying = self:GetNWBool("Flying".. self.Vehicle);
		local TakeOff = self:GetNWBool("TakeOff");
		local Land = self:GetNWBool("Land");
		local vel = self:GetVelocity():Length();
		if(vel > 150) then
			if(Flying and !TakeOff and !Land) then
				for i=1,4 do
					local vOffset = self.EnginePos[i] 
					local scroll = CurTime() * -20
						
					render.SetMaterial( matPlasma )
					scroll = scroll * 0.9
					
					render.StartBeam( 3 )
						render.AddBeam( vOffset, 32, scroll, Color( 0, 255, 255, 255) )
						render.AddBeam( vOffset + self:GetForward()*-5, 28, scroll + 0.01, Color( 255, 255, 255, 255) )
						render.AddBeam( vOffset + self:GetForward()*-40, 24, scroll + 0.02, Color( 0, 255, 255, 0) )
					render.EndBeam()
					
					scroll = scroll * 0.9
					
					render.StartBeam( 3 )
						render.AddBeam( vOffset, 32, scroll, Color( 0, 255, 255, 255) )
						render.AddBeam( vOffset + self:GetForward()*-5, 28, scroll + 0.01, Color( 255, 255, 255, 255) )
						render.AddBeam( vOffset + self:GetForward()*-40, 24, scroll + 0.02, Color( 0, 255, 255, 0) )
					render.EndBeam()
					
					scroll = scroll * 0.9
					
					render.StartBeam( 3 )
						render.AddBeam( vOffset, 32, scroll, Color( 0, 255, 255, 255) )
						render.AddBeam( vOffset + self:GetForward()*-5, 28, scroll + 0.01, Color( 255, 255, 255, 255) )
						render.AddBeam( vOffset + self:GetForward()*-40, 24, scroll + 0.02, Color( 0, 255, 255, 0) )
					render.EndBeam()
				end
			end
		end
	end
	
	//"ambient/atmosphere/ambience_base.wav"
	local View = {}
	local function CalcView()
		local p = LocalPlayer();
		local self = p:GetNetworkedEntity("XWing", NULL)
		if(IsValid(self)) then
			local fpvPos = self:GetPos()+self:GetForward()*70+self:GetUp()*92;
			View = SWVehicleView(self,700,200,fpvPos);		
			return View;
		end
	end
	hook.Add("CalcView", "XWingView", CalcView)
	
	local HUD = surface.GetTextureID("vgui/xwing2_cockpit")
	local Glass = surface.GetTextureID("models/props_c17/frostedglass_01a_dx60")
	ENT.CanFPV = true;
	//local Glass = surface.GetTextureID("glass_overlay")
	function XWingReticle()
		
		local p = LocalPlayer();
		local Flying = p:GetNWBool("FlyingXWing");
		local self = p:GetNWEntity("XWing");
		

		if(Flying and IsValid(self)) then
			local x = ScrW()/4*0.1;
			local y = ScrH()/4*2.5;
			if(self:GetFPV()) then
				SW_HUD_FPV(HUD);				
				SW_HUD_WingsIndicator("xwing",x,y);
			end

			SW_HUD_DrawHull(2000);
			SW_WeaponReticles(self);
			SW_HUD_DrawOverheating(self);
			SW_HUD_Compass(self);
			SW_HUD_DrawSpeedometer();
			SW_BlastIcon(self,30);
			
			x = ScrW() - ScrW()/10*0.5;
			y = ScrH()/2;
			//SW_HUD_LandedIndicator(x,y);
			
		end
	end
	hook.Add("HUDPaint", "XWingReticle", XWingReticle)

	
	function ENT:FlightEffects()
		local normal = (self:GetForward() * -1):GetNormalized()
		local roll = math.Rand(-90,90)
		local p = LocalPlayer()		
		local FWD = self:GetForward();
		local id = self:EntIndex();
		local Health = self:GetNWInt("Health");
		for k,v in pairs(self.EnginePos) do
			
		//	if(k == 3 and Health <= (self.StartHealth*0.5)) then
			//	self:Smoke(true,v);
		//	else
				local red = self.FXEmitter:Add("sprites/orangecore1",v)
				red:SetVelocity(normal)
				red:SetDieTime(FrameTime()*1.25)
				red:SetStartAlpha(255)
				red:SetEndAlpha(255)
				red:SetStartSize(14)
				red:SetEndSize(10)
				red:SetRoll(roll)
				red:SetColor(255,100,100)
				

		//	end
		end
		
		local pos = self:GetPos()+self:GetForward()*-205+self:GetUp()*60+self:GetRight()*0;			
		
		local dynlight = DynamicLight(id + 4096);
		dynlight.Pos = pos;
		dynlight.Brightness = 5;
		dynlight.Size = 200;
		dynlight.Decay = 1024;
		dynlight.R = 255;
		dynlight.G = 100;
		dynlight.B = 100;
		dynlight.DieTime = CurTime()+1;

	end
	
end