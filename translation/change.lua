local change = {}

signal = require("engine.Utils.signal")
ChangeLanguage = signal:new()

ChangeLanguage:connect(function(NewLanguage)
    CurrentLanguage = NewLanguage

    package.loaded["translation." ..CurrentLanguage] = nil
    package.loaded[CurrentLanguageModule] = nil
    CurrentLanguageModule = require("translation." ..CurrentLanguage)
end)

return change