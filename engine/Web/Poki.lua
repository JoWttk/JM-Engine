local Poki = {}
local js = require("libs.js")

function Poki.init(callback)
    js.callJS([[
        (function() {
            PokiSDK.init().then(function() {
                console.log("Poki SDK initialized");
            }).catch(function() {
                console.log("Poki SDK init failed, loading anyway");
            });
        })();
    ]])
    print("Poki Init...")
end

function Poki.setDebug(enabled)
    if enabled then
        js.callJS("PokiSDK.setDebug(true);")
    end
end

function Poki.loadingFinished()
    js.callJS("PokiSDK.gameLoadingFinished();")
end

function Poki.gameplayStart()
    js.callJS("PokiSDK.gameplayStart();")
end

function Poki.gameplayStop()
    js.callJS("PokiSDK.gameplayStop();")
end

function Poki.commercialBreak(callback)
    js.callJS([[
        (function() {
            PokiSDK.commercialBreak().then(function() {
                console.log("Commercial break done");
            });
        })();
    ]])
    if callback then callback() end
end

function Poki.rewardedBreak(onSuccess, onError)
    js.callJS([[
        (function() {
            PokiSDK.rewardedBreak().then(function(withAd) {
                if (withAd) {
                    console.log("Rewarded break: watched");
                } else {
                    console.log("Rewarded break: skipped or no ad");
                }
            }).catch(function(e) {
                console.log("Rewarded break error:", e);
            });
        })();
    ]])
end

function Poki.shareableURL(params)
    params = params or "{}"
    js.callJS([[
        (function() {
            PokiSDK.shareableURL(]] .. params .. [[).then(function(url) {
                console.log("Shareable URL:", url);
            });
        })();
    ]])
end

function Poki.login()
    js.callJS([[
        (async () => {
            try {
                await PokiSDK.auth.login();
                console.log("Poki login success");
            } catch(e) {
                console.log("Poki login failed:", e);
            }
        })();
    ]])
end

function Poki.getUser()
    js.callJS([[
        (async () => {
            try {
                const user = await PokiSDK.auth.getUser();
                console.log("Poki user:", user);
            } catch(e) {
                console.log("Poki getUser error:", e);
            }
        })();
    ]])
end

return Poki