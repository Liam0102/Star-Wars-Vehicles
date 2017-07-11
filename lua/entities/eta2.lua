ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Base = "fighter_base"
ENT.Type = "vehicle"

ENT.PrintName = "Eta-2"
ENT.Author = "Liam0102"
ENT.Category = "Star Wars Vehicles: Republic"
ENT.AutomaticFrameAdvance = true
ENT.Spawnable = false;
ENT.AdminSpawnable = false;

ENT.EntModel = "models/eta2r/eta2r1.mdl"
ENT.Vehicle = "EtaR"
ENT.StartHealth = 1000;
ENT.Allegiance = "Republic";
list.Set("SWVehicles", ENT.PrintName, ENT);
if SERVER then

ENT.FireSound = Sound("weapons/xwing_shoot.wav");
ENT.NextUse = {Wings = CurTime(),Use = CurTime(),Fire = CurTime(),};


AddCSLuaFile();
function ENT:SpawnFunction(pl, tr)
	local e = ents.Create("eta2");
	e:SetPos(tr.HitPos + Vector(0,0,10));
	e:SetAngles(Angle(0,pl:GetAimVector():Angle().Yaw,0));
	e:Spawn();
	e:Activate();
	return e;
end

function ENT:Initialize()

	self:SetNWInt("Health",self.StartHealth);
	self.CanRoll = true;
	self.WeaponLocations = {
		Left = self:GetPos()+self:GetRight()*-65+self:GetUp()*25+self:GetForward()*42,
		Right = self:GetPos()+self:GetRight()*65+self:GetUp()*25+self:GetForward()*42,
	}
	self.WeaponsTable = {};
	self.BoostSpeed = 2500;
	self.ForwardSpeed = 1500;
	self.UpSpeed = 750;
	self.AccelSpeed = 10;
	self.CanStandby = true;
	self.CanShoot = true;
	self.HasWings = true;
	self.AlternateFire = true;
	self.FireGroup = {"Left","Right"};
	self.LandOffset = Vector(0,0,5);
	
	self.CurrentDroid = self.DroidModels[math.random(1,3)];
	self:SpawnDroid(self:GetPos()+self:GetUp()*32.5+self:GetRight()*-50+self:GetForward()*-8)
	
	self.Bullet = CreateBulletStructure(100,"green");

	self.BaseClass.Initialize(self)
end

ENT.DroidModels = {
	"models/nicholasray/sws/r2d2r.mdl",
	"models/nicholasray/sws/r2d2g.mdl",
	"models/nicholasray/sws/r2d2b.mdl",
};
function ENT:SpawnDroid(pos)
	
	local e = ents.Create("prop_physics");
	e:SetModelScale(0.775);
	e:SetModel(self.CurrentDroid);
	e:SetPos(pos);
	e:SetAngles(self:GetAngles()+Angle(0,0,-10));
	e:SetParent(self);
	e:Spawn();
	e:Activate();
	e:GetPhysicsObject():EnableMotion(false);
	e:GetPhysicsObject():EnableCollisions(false);
	self.Droid = e;

end


end

if CLIENT then
	ENT.CanFPV = true;

	local matPlasma	= Material( "effects/strider_muzzle" )
	function ENT:Draw() 
		self:DrawModel()		
		local Flying = self:GetNWBool("Flying".. self.Vehicle);
		local TakeOff = self:GetNWBool("TakeOff");
		local Land = self:GetNWBool("Land");
		local vel = self:GetVelocity():Length();
		if(vel > 150) then
			if(Flying and !TakeOff and !Land) then
				for i=1,2 do
					local vOffset = self.EnginePos[i] 
					local scroll = CurTime() * -20
						
					render.SetMaterial( matPlasma )
					scroll = scroll * 0.9
					
					render.StartBeam( 3 )
						render.AddBeam( vOffset, 24, scroll, Color( 0, 255, 255, 255) )
						render.AddBeam( vOffset + self:GetForward()*-5, 20, scroll + 0.01, Color( 255, 255, 255, 255) )
						render.AddBeam( vOffset + self:GetForward()*-40, 16, scroll + 0.02, Color( 0, 255, 255, 0) )
					render.EndBeam()
					
					scroll = scroll * 0.9
					
					render.StartBeam( 3 )
						render.AddBeam( vOffset, 24, scroll, Color( 0, 255, 255, 255) )
						render.AddBeam( vOffset + self:GetForward()*-5, 20, scroll + 0.01, Color( 255, 255, 255, 255) )
						render.AddBeam( vOffset + self:GetForward()*-40, 16, scroll + 0.02, Color( 0, 255, 255, 0) )
					render.EndBeam()
					
					scroll = scroll * 0.9
					
					render.StartBeam( 3 )
						render.AddBeam( vOffset, 24, scroll, Color( 0, 255, 255, 255) )
						render.AddBeam( vOffset + self:GetForward()*-5, 20, scroll + 0.01, Color( 255, 255, 255, 255) )
						render.AddBeam( vOffset + self:GetForward()*-40, 16, scroll + 0.02, Color( 0, 255, 255, 0) )
					render.EndBeam()
					
					
				end
			end
		end
	end
		
		
	ENT.EnginePos = {}
	ENT.Sounds={
		Engine=Sound("vehicles/eta/eta_fly.wav"),
	}

	function ENT:FlightEffects()
		local normal = (self:GetForward() * -1):GetNormalized()
		local roll = math.Rand(-90,90)
		local p = LocalPlayer()		
		local FWD = self:GetForward();
		local id = self:EntIndex();

		for k,v in pairs(self.EnginePos) do
			
			local blue = self.FXEmitter:Add("sprites/bluecore",v+FWD*-5)
			blue:SetVelocity(normal)
			blue:SetDieTime(0.025)
			blue:SetStartAlpha(255)
			blue:SetEndAlpha(255)
			blue:SetStartSize(8)
			blue:SetEndSize(5)
			blue:SetRoll(roll)
			blue:SetColor(255,255,255)
			
			local dynlight = DynamicLight(id + 4096 * k);
			dynlight.Pos = v+FWD*-5;
			dynlight.Brightness = 5;
			dynlight.Size = 150;
			dynlight.Decay = 1024;
			dynlight.R = 100;
			dynlight.G = 100;
			dynlight.B = 255;
			dynlight.DieTime = CurTime()+1;
			
		end
	
	end

	
	local Health = 0;
	local Overheat = 0;
	local Overheated = false;
	local FPV = false;
	function ENT:Think()
	
		self.BaseClass.Think(self)
		
		local p = LocalPlayer();
		local Flying = self:GetNWBool("Flying".. self.Vehicle);
		local TakeOff = self:GetNWBool("TakeOff");
		local Land = self:GetNWBool("Land");
		if(Flying) then
			self.EnginePos = {
				self:GetPos()+self:GetForward()*-150+self:GetUp()*28+self:GetRight()*14.5,
				self:GetPos()+self:GetForward()*-150+self:GetUp()*28+self:GetRight()*-17,
			}
			if(!TakeOff and !Land) then
				self:FlightEffects();
			end
		end
		
	end
	
    ENT.ViewDistance = 700;
    ENT.ViewHeight = 200;
    ENT.FPVPos = Vector(-25,0,60);
	
	local HUD = surface.GetTextureID("vgui/eta_cockpit");
	function EtaRReticle()
		
		local p = LocalPlayer();
		local Flying = p:GetNWBool("FlyingEtaR");
		local self = p:GetNWEntity("EtaR");
		if(Flying and IsValid(self)) then
			
			if(self:GetFPV()) then
				SW_HUD_FPV(HUD);
				SW_HUD_WingsIndicator("eta",x,y);
			end

			SW_HUD_DrawHull(self:GetNWInt("StartHealth"));
			SW_WeaponReticles(self);
			SW_HUD_DrawOverheating(self);
			local x = ScrW()/4*0.4;
			local y = ScrH()/4*3.1;
			SW_HUD_Compass(self,x,y);
			SW_HUD_DrawSpeedometer();
			
		end
	end
	hook.Add("HUDPaint", "EtaRReticle", EtaRReticle)

end