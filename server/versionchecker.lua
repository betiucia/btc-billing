-----------------------------------------------------------------------
-- Version Checker
--
-- Runs once on script start. Compares the resource's manifest version
-- against the latest registered in the public GitHub registry.
--
-- Console output:
--   success → "IS UP TO DATE"
--   error   → "outdated, update to version X"
--   error   → "unable to run version check" (HTTP failed)
--
-- Setup per script: publish a plain-text version file at
--   https://raw.githubusercontent.com/betiucia/CheckVersion/main/<resource-name>/version.txt
-- containing only the latest version string (must match fxmanifest.lua → version).
--
-- No changes needed unless the user explicitly asks to adjust behavior or registry URL.
-----------------------------------------------------------------------
local function versionCheckPrint(_type, log)
    local color = _type == 'success' and '^6' or '^1'

    print(('^2['..GetCurrentResourceName()..']%s %s^7'):format(color, log))
end

local function CheckVersion()
    PerformHttpRequest('https://raw.githubusercontent.com/betiucia/CheckVersion/main/'..GetCurrentResourceName()..'/version.txt', function(err, text, headers)
        local currentVersion = GetResourceMetadata(GetCurrentResourceName(), 'version')

        if not text then
            versionCheckPrint('error', 'Currently unable to run a version check.')
            return
        end

        if text == currentVersion then
            versionCheckPrint('success', 'IS UP TO DATE.')
        else
            versionCheckPrint('error', ('You are currently running an outdated version, please update to version %s'):format(text))
        end
    end)
end

--------------------------------------------------------------------------------------------------
-- start version check
--------------------------------------------------------------------------------------------------
CheckVersion()
