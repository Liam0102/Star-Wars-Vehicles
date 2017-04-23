if SERVER then
    
function CreateBulletStructure(dmg,color,nosplashdamage)
	if(color == "blue" and dmg/2 > 30) then
		dmg = 30;
	elseif(color == "blue" and dmg/2 <= 30) then
		dmg = dmg/2;
	end
    
    local noion = false;
    if(color == "blue_noion") then
        color = "blue";
        noion = true;
    end

	local bullet = {
		Spread		= Vector(0.001,0.001,0),
		Damage		= dmg*1.25,
		Force		= dmg,
		TracerName	= color .. "_tracer_fx",
		Callback = function(p,tr,damage)
			local self = damage:GetInflictor():GetParent();
			
			util.Decal( "fadingscorch", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal );
			local fx = EffectData()
				fx:SetOrigin(tr.HitPos);
				fx:SetNormal(tr.HitNormal);
			util.Effect( "StunstickImpact", fx, true )
			
			if(Should_HeliDamage) then
				local e = tr.Entity;
				if(e:GetClass() == "npc_helicopter" or e:GetClass() == "npc_combinegunship") then
					local health = e:Health();
					local new_health = health - dmg;
					if(new_health <= 0) then
						e:Input("SelfDestruct")
					else
						e:SetHealth(health - dmg);
					end
				end
			end		
			if(IsValid(self) and self != tr.Entity) then
				if(!nosplashdamage) then
					util.BlastDamage( self, self.Pilot or self, tr.HitPos, dmg*1.5, dmg*0.66)
				end
				
				if(tr.Entity.IsSWVehicle and tr.Entity.Inflight) then
					if(!tr.Entity.AdminOnly) then
						tr.Entity:GetPhysicsObject():AddAngleVelocity(tr.HitNormal * math.Clamp(tr.Entity.Mass/2,3750,7500));
					end
				end
				
				
				
				if(color == "blue" and !noion) then
					if(tr.Entity.IsSWVehicle) then
						tr.Entity.IonShots = tr.Entity.IonShots + 1;
					end
				end
			end
		end	
	}	
	return bullet;
end
    
end