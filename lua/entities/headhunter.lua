ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Base = "fighter_base"
ENT.Type = "vehicle"

ENT.PrintName = "Z-95 Headhunter"
ENT.Author = "Liam0102"
ENT.Category = "Star Wars Vehicles: Republic"
ENT.AutomaticFrameAdvance = true
ENT.Spawnable = false;
ENT.AdminSpawnable = false;

ENT.EntModel = "models/z95/z951.mdl"
ENT.Vehicle = "Headhunter"
ENT.StartHealth = 1500;
ENT.Allegiance = "Rebels";
list.Set("SWVehicles", ENT.PrintName, ENT);
if SERVER then

ENT.FireSound = Sound("weapons/xwing_shoot.wav");
ENT.NextUse = {Wings = CurTime(),Use = CurTime(),Fire = CurTime(),};


AddCSLuaFile();
function ENT:SpawnFunction(pl, tr)
	local e = ents.Create("headhunter");
	e:SetPos(tr.HitPos + Vector(0,0,0));
	e:SetAngles(Angle(0,pl:GetAimVector():Angle().Yaw,0));
	e:Spawn();
	e:Activate();
	return e;
end

function ENT:Initialize()


	self:SetNWInt("Health",self.StartHealth);
	
	self.WeaponLocations = {
		Left = self:GetPos()+self:GetForward()*70+self:GetRight()*-212.5+self:GetUp()*65,
		Right = self:GetPos()+self:GetForward()*70+self:GetRight()*212.5+self:GetUp()*65,
	}
	self.WeaponsTable = {};
	self.BoostSpeed = 2500;
	self.ForwardSpeed = 1000;
	self.UpSpeed = 600;
	self.AccelSpeed = 8;
	self.CanStandby = true;
	self.CanBack = true;
	self.CanRoll = true;
	self.CanStrafe = false;
	self.Cooldown = 2;
	self.CanShoot = true;
	self.Bullet = CreateBulletStructure(75,"red");
	self.FireDelay = 0.2;
	self.AlternateFire = true;
	self.FireGroup = {"Left","Right",};
	self.HasWings = false;

	//self.ExitModifier = {x=0,y=-325,z=100};

	self.BaseClass.Initialize(self);
end

end

if CLIENT then
	
	ENT.CanFPV = false;
	ENT.Sounds={
		Engine=Sound("vehicles/xwing/xwing_fly2.wav"),
	}
	
	local matPlasma	= Material( "effects/strider_muzzle" )
	function ENT:Draw()
		self:DrawModel();

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
	
	function ENT:FlightEffects()
		local normal = (self:GetForward() * -1):GetNormalized()
		local roll = math.Rand(-90,90)
		local p = LocalPlayer()		
		local FWD = self:GetForward();
		local id = self:EntIndex();

		for k,v in pairs(self.EnginePos) do
			
			local blue = self.FXEmitter:Add("sprites/bluecore",v+FWD*-3)
			blue:SetVelocity(normal)
			blue:SetDieTime(FrameTime()*1.25)
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
	
	function ENT:Think()
		local Flying = self:GetNWBool("Flying"..self.Vehicle);
		if(Flying) then
			self.EnginePos = {
				self:GetPos()+self:GetForward()*-185+self:GetUp()*42.5+self:GetRight()*49,
				self:GetPos()+self:GetForward()*-185+self:GetUp()*75+self:GetRight()*49,
				self:GetPos()+self:GetForward()*-185+self:GetUp()*42.5+self:GetRight()*-49,
				self:GetPos()+self:GetForward()*-185+self:GetUp()*75+self:GetRight()*-49,
			}
			self:FlightEffects();
		end
		self.BaseClass.Think(self);
	end
	
	ENT.ViewDistance = 800;
    ENT.ViewHeight = 200;
	
	function HeadhunterReticle()
		
		local p = LocalPlayer();
		local Flying = p:GetNWBool("FlyingHeadhunter");
		local self = p:GetNWEntity("Headhunter");
		if(Flying and IsValid(self)) then
			SW_HUD_DrawHull(1500);
			SW_WeaponReticles(self);
			SW_HUD_DrawOverheating(self);
			SW_HUD_Compass(self);
			SW_HUD_DrawSpeedometer();
		end
	end
	hook.Add("HUDPaint", "HeadhunterReticle", HeadhunterReticle)

end