local CrazyGames = {}
local js = require("libs.js")

function CrazyGames.init()
    js.callJS("(async () => { await window.CrazyGames.SDK.init(); })()")

    print("Crazy Games Init...")
end

function CrazyGames.getUser()
    js.callJS([[
        (async () => {
            try {
                const user = await window.CrazyGames.SDK.user.getUser();
                console.log("User:", user);
            } catch (e) {
                console.log("User error:", e);
            }
        })();
    ]])
end

function CrazyGames.hasAdBlock()
    js.callJS([[
        (async () => {
            try {
                const result = await window.CrazyGames.SDK.ad.hasAdBlock();
                console.log("AdBlock:", result);
            } catch (e) {
                console.log("AdBlock error:", e);
            }
        })();
    ]])
end

function CrazyGames.ad(adType)
    js.callJS([[
        (async () => {
            await new Promise((resolve) => {
                const callbacks = {
                    adStarted: () => console.log("Start ad"),
                    adFinished: () => { console.log("End ad"); resolve(); },
                    adError: (e) => { console.log("Error ad", e); resolve(); },
                };
                window.CrazyGames.SDK.ad.requestAd("]] .. adType .. [[", callbacks);
            });
        })();
    ]])
end

function CrazyGames.loading(state)
    if type(state) ~= "string" then return end
    js.callJS("window.CrazyGames.SDK.game.loading" .. state .. "();")
end

function CrazyGames.gameplay(state)
    if type(state) ~= "string" then return end
    js.callJS("window.CrazyGames.SDK.game.gameplay" .. state .. "();")
end

function CrazyGames.data_add(item, value)
    local jsValue
    if type(value) == "string" then
        jsValue = '"' .. value .. '"'
    else
        jsValue = tostring(value)
    end
    js.callJS('window.CrazyGames.SDK.data.setItem("' .. item .. '", ' .. jsValue .. ');')
end

function CrazyGames.data_get(item, callback)
    if callback then
        js.callJS([[
            (async () => {
                try {
                    const val = await window.CrazyGames.SDK.data.getItem("]] .. item .. [[");
                    console.log("data_get ]] .. item .. [[:", val);
                } catch (e) {
                    console.log("data_get error:", e);
                }
            })();
        ]])
    else
        js.callJS([[
            (async () => {
                try {
                    const val = await window.CrazyGames.SDK.data.getItem("]] .. item .. [[");
                    console.log("data_get ]] .. item .. [[:", val);
                } catch (e) {
                    console.log("data_get error:", e);
                }
            })();
        ]])
    end
end

function CrazyGames.data_remove(item)
    js.callJS('window.CrazyGames.SDK.data.removeItem("' .. item .. '");')
end

function CrazyGames.data_clear()
    js.callJS("window.CrazyGames.SDK.data.clear();")
end

return CrazyGames