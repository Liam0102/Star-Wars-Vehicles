ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.Type = "vehicle"
ENT.Base = "fighter_base"

ENT.PrintName = "ARC-170"
ENT.Author = "Liam0102"
ENT.Category = "Star Wars Vehicles: Republic"
ENT.AutomaticFrameAdvance = true // For smooth animations
ENT.Spawnable = false; // Spawnable
ENT.AdminSpawnable = false; // Is it only Admin spawnable?

ENT.EntModel = "models/arc170/arc1701.mdl" // The model for the vehicle you're using
ENT.Vehicle = "ARC170" // The name of the vehicle, this is very important.
ENT.StartHealth = 2000; // How much health the vehicle will have
ENT.Allegiance = "Republic";
list.Set("SWVehicles", ENT.PrintName, ENT);

if SERVER then

ENT.FireSound = Sound("weapons/xwing_shoot.wav"); // The sound used for the weapon fire
ENT.NextUse = {Wings = CurTime(),Use = CurTime(),Fire = CurTime(),FireMode = CurTime(),}; // Leave this stuff


AddCSLuaFile();
function ENT:SpawnFunction(pl, tr)
	local e = ents.Create("arc170");
	e:SetPos(tr.HitPos + Vector(0,0,10));
	e:SetAngles(Angle(0,pl:GetAimVector():Angle().Yaw,0));
	e:Spawn();
	e:Activate();
	return e;
end

function ENT:Initialize()
	
	self:SetNWInt("Health",self.StartHealth); //This is here to set the health to the variable made above
	self.CanRoll = true; //Set this to true if the vehicle can roll, false if it can't
	self.WeaponLocations = {
		Right = self:GetPos()+self:GetForward()*250+self:GetUp()*45+self:GetRight()*315,
		Left = self:GetPos()+self:GetForward()*250+self:GetUp()*45+self:GetRight()*-322,
	}

	self.WeaponsTable = {}; //This is what holds the players weapons, you must have this here in ENT:Initialize
	self.BoostSpeed = 2200; //This is the speed when holding SHIFT or the Wings are open
	self.ForwardSpeed = 1250; //This is the standard forward speed
	self.UpSpeed = 500; //This is how fast you can go up or down while holding SPACE or CTRL
	self.AccelSpeed = 8; //This is how fast you reach the speeds. The higher the number the quicker it is.
	
	self.Bullet = CreateBulletStructure(90,"blue");
	self.CanShoot = true;
	self.FireDelay = 0.3 // This is how fast you can fire. The smaller, the faster.
	self.AlternateFire = true;
	self.FireGroup = { "Left" , "Right" };
	self.HasWings = true;
	
	self.ExitModifier = {x = 200, y = 0, z = 130};
	
	self.BaseClass.Initialize(self)
end


end

if CLIENT then

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
						render.AddBeam( vOffset, 40, scroll, Color( 0, 255, 255, 255) )
						render.AddBeam( vOffset + self:GetForward()*-5, 36, scroll + 0.01, Color( 255, 255, 255, 255) )
						render.AddBeam( vOffset + self:GetForward()*-40, 32, scroll + 0.02, Color( 0, 255, 255, 0) )
					render.EndBeam()
					
					scroll = scroll * 0.9
					
					render.StartBeam( 3 )
						render.AddBeam( vOffset, 40, scroll, Color( 0, 255, 255, 255) )
						render.AddBeam( vOffset + self:GetForward()*-5, 36, scroll + 0.01, Color( 255, 255, 255, 255) )
						render.AddBeam( vOffset + self:GetForward()*-40, 32, scroll + 0.02, Color( 0, 255, 255, 0) )
					render.EndBeam()
					
					scroll = scroll * 0.9
					
					render.StartBeam( 3 )
						render.AddBeam( vOffset, 40, scroll, Color( 0, 255, 255, 255) )
						render.AddBeam( vOffset + self:GetForward()*-5, 36, scroll + 0.01, Color( 255, 255, 255, 255) )
						render.AddBeam( vOffset + self:GetForward()*-40, 32, scroll + 0.02, Color( 0, 255, 255, 0) )
					render.EndBeam()
				end
			end
		end
	end
	
	ENT.EnginePos = {} // Positions of the engines for the effects
	ENT.Sounds={
		Engine=Sound("vehicles/xwing/xwing_fly2.wav"), //The flying sounds
	}

	// The flight effects, for the most part you can leave this alone
	function ENT:FlightEffects()
		local normal = (self:GetForward() * -1):GetNormalized()
		local roll = math.Rand(-90,90)
		local p = LocalPlayer()		
		local FWD = self:GetForward();
		local id = self:EntIndex();

		for k,v in pairs(self.EnginePos) do
			local blue = self.FXEmitter:Add("sprites/bluecore",v)
			blue:SetVelocity(normal)
			blue:SetDieTime(0.025)
			blue:SetStartAlpha(255)
			blue:SetEndAlpha(255)
			blue:SetStartSize(15)
			blue:SetEndSize(13)
			blue:SetRoll(roll)
			blue:SetColor(255,255,255)
			
			local dynlight = DynamicLight(id + 4096*k);
			dynlight.Pos = v;
			dynlight.Brightness = 5;
			dynlight.Size = 100;
			dynlight.Decay = 1024;
			dynlight.R = 100;
			dynlight.G = 100;
			dynlight.B = 255;
			dynlight.DieTime = CurTime()+1;

		end
	
	end
	
	local Health = 0;
	function ENT:Think()
		self.BaseClass.Think(self);
		
		local p = LocalPlayer(); //The player
		local Flying = self:GetNWBool("Flying".. self.Vehicle); //Is the vehicle currently inflight?
		local TakeOff = self:GetNWBool("TakeOff");
		local Land = self:GetNWBool("Land");
		local IsFlying = p:GetNWBool("Flying"..self.Vehicle);
		if(Flying) then
			
			// We need to constantly update the engine positions for the effects
			self.EnginePos = {
				self:GetPos()+self:GetForward()*-220+self:GetUp()*95+self:GetRight()*65, 
				self:GetPos()+self:GetForward()*-220+self:GetUp()*95+self:GetRight()*-72,
			}

			if(!TakeOff and !Land) then
				self:FlightEffects(); // Draw the effects
			end
			Health = self:GetNWInt("Health"); // Get the health for the HUD
		end

	end
	
    ENT.ViewDistance = 700;
    ENT.ViewHeight = 200;
    ENT.FPVPos = Vector(80,3,130);
	
	local HUD = surface.GetTextureID("vgui/arc_cockpit");
	ENT.CanFPV = true;
	function ARC170Reticle() // Rename to Vehicle Name Reticle
		
		local p = LocalPlayer();
		local Flying = p:GetNWBool("FlyingARC170"); // Change ARC-170 to your vehicle name
		local self = p:GetNWEntity("ARC170"); // Change ARC-170 to your vehicle name
		

		if(Flying and IsValid(self)) then
			//These should be the same positions for the weapons as above in initialize
			local FPV = self:GetFPV();
			if(FPV) then
				SW_HUD_FPV(HUD);
				SW_HUD_WingsIndicator("ARC",x,y);
			end
			
			SW_HUD_DrawHull(2000);
			SW_WeaponReticles(self);
			SW_HUD_DrawOverheating(self);
			
			local x = ScrW()/10*8.25;
			local y = ScrH()/4*2;
			SW_HUD_Compass(self,x,y);
			SW_HUD_DrawSpeedometer();
			
		end
	end
	hook.Add("HUDPaint", "ARC170Reticle", ARC170Reticle)

end