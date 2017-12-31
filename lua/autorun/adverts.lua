if SERVER then
    
    hook.Add("PlayerInitialSpawn", "SWVAdverts", function(p)
        if(game.SinglePlayer()) then
            if(cookie.GetString("SWServer") != "1") then
                timer.Simple(30, function()
                    p:ChatPrint("Join the official Star Wars Vehicles server here: 185.44.76.33:27165");
                    cookie.Set("SWServer","1");
                end);
            end
        end
    end)

end