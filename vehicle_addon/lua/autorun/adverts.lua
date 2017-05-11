if SERVER then
    
    hook.Add("PlayerInitialSpawn", "SWVAdverts", function(p)
        if(game.SinglePlayer()) then
            if(cookie.GetString("SWServer") != "1") then
                timer.Simple(30, function()
                    p:ChatPrint("Join the official Star Wars Vehicles server here: 185.44.76.33:27165");
                    cookie.Set("SWServer","1");
                end);
            end
            if(cookie.GetString("SWDonate") != "1") then
                timer.Create("SWVDonateAdvert",1800,1, function()
                    p:ChatPrint("Enjoying Star Wars Vehicles? Consider donating at: https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=CXLPN943QCVEL");
                    cookie.Set("SWDonate","1");
                end);
            end
        end
    end)

end