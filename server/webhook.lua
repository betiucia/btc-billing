-- ════════════════════════════════════════════════════════════════════════════════
-- Webhook System with Batching (Auditoria & Segurança)
-- ════════════════════════════════════════════════════════════════════════════════

local BtcCore = exports['btc-core']:GetCore()
local WebhookQueue = {}
local WebhookBatchTimer = nil
local BATCH_INTERVAL = (Config.WebhookBatchInterval or 10) * 1000 -- padrão 10 segundos

-- ════════════════════════════════════════════════════════════════════════════════
-- Batching System
-- ════════════════════════════════════════════════════════════════════════════════

function QueueWebhook(src, action, data)
    table.insert(WebhookQueue, {
        timestamp = os.time(),
        playerName = src and GetPlayerName(src) or 'System',
        citizenID = src and (BtcCore.framework.getCitizenID(src) or 'invalid') or 'N/A',
        license = src and (BtcCore.framework.getLicense(src) or 'invalid') or 'N/A',
        action = action,
        data = data,
    })

    if not WebhookBatchTimer then
        WebhookBatchTimer = SetTimeout(BATCH_INTERVAL, function()
            SendBatchWebhook()
            WebhookBatchTimer = nil
        end)
    end
end

function SendBatchWebhook()
    if #WebhookQueue == 0 then return end

    local fields = {}

    for _, entry in ipairs(WebhookQueue) do
        table.insert(fields, {
            name = '[' .. entry.timestamp .. '] ' .. entry.action,
            value = '**' .. L('webhook.player') .. ':** ' .. entry.playerName .. ' (' .. entry.citizenID .. ')\n' ..
                    '**' .. L('webhook.license') .. ':** ' .. entry.license .. '\n' ..
                    '**' .. L('webhook.data') .. ':** ```json\n' .. json.encode(entry.data) .. '\n```',
            inline = false
        })
    end

    local embed = {
        {
            ["color"] = Config.WebhookColor,
            ["icon_url"] = Config.UrlIcon,
            ["title"] = L('webhook.batch.title') .. ' [' .. #WebhookQueue .. ' ' .. L('webhook.batch.actions') .. ']',
            ["timestamp"] = os.date('!%Y-%m-%dT%H:%M:%SZ'),

            author = {
                name = GetCurrentResourceName(),
                icon_url = Config.UrlIcon,
            },

            thumbnail = {
                url = Config.UrlIconThumb,
            },

            fields = fields,
        }
    }

    PerformHttpRequest(Config.WebhookUrl, function(_, _, _) end, 'POST',
        json.encode({ username = GetCurrentResourceName(), embeds = embed }),
        { ['Content-Type'] = 'application/json' })

    WebhookQueue = {}
end

-- ════════════════════════════════════════════════════════════════════════════════
-- Immediate Webhook (Apenas para casos críticos - exploit, erro, etc)
-- ════════════════════════════════════════════════════════════════════════════════

function SendImmediateWebhook(src, action, info)
    local firstname, lastname = src and BtcCore.framework.getName(src) or 'System', ''
    local citizenid = src and (BtcCore.framework.getCitizenID(src) or 'invalid') or 'N/A'
    local license = src and (BtcCore.framework.getLicense(src) or 'invalid') or 'N/A'

    local embed = {
        {
            ["color"] = 16711680, -- vermelho para crítico
            ["icon_url"] = Config.UrlIcon,
            ["title"] = '⚠️ ' .. L('webhook.critical.title') .. ': ' .. action,

            author = {
                name = GetCurrentResourceName(),
                icon_url = Config.UrlIcon,
            },

            thumbnail = {
                url = Config.UrlIconThumb,
            },

            fields = {
                { name = L('webhook.player'), value = firstname .. ' ' .. lastname, inline = true },
                { name = L('webhook.citizen_id'), value = citizenid, inline = true },
                { name = L('webhook.license'), value = license, inline = false },
                { name = L('webhook.details'), value = json.encode(info), inline = false },
            },
        }
    }

    PerformHttpRequest(Config.WebhookUrl, function(_, _, _) end, 'POST',
        json.encode({ username = GetCurrentResourceName(), embeds = embed }),
        { ['Content-Type'] = 'application/json' })
end

-- ════════════════════════════════════════════════════════════════════════════════
-- Compat Functions (Legacy Support)
-- ════════════════════════════════════════════════════════════════════════════════

function Webhook(source, action, info)
    QueueWebhook(source, action, { info = info })
end

function WebhookNoSource(_, action, info)
    QueueWebhook(nil, action, { info = info })
end
