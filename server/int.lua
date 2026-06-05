-- ════════════════════════════════════════════════════════════════════════════════
-- btc-billing | Internal server helpers (cache, deposit, visibility)
-- ════════════════════════════════════════════════════════════════════════════════

local Core = exports['btc-core']:GetCore()

-- ════════════════════════════════════════════════════════════════════════════════
-- Cache com TTL (anti-spam de consultas — RULES §5)
-- ════════════════════════════════════════════════════════════════════════════════

local cache = {}

function SetCached(key, value, ttlSeconds)
    cache[key] = { value = value, expires = os.time() + (ttlSeconds or 5) }
end

function GetCached(key)
    local entry = cache[key]
    if not entry then return nil end
    if os.time() > entry.expires then cache[key] = nil; return nil end
    return entry.value
end

-- Invalida entradas do cache cujo prefixo bata (ex: 'bills:' limpa todas as listas)
function InvalidateCache(prefix)
    for key in pairs(cache) do
        if key:sub(1, #prefix) == prefix then cache[key] = nil end
    end
end

-- ════════════════════════════════════════════════════════════════════════════════
-- Depósito na caixa do negócio (btc-business)
-- ════════════════════════════════════════════════════════════════════════════════

-- `businessId` é o localId (sempre string, ex: 'saloonValentine') configurado em Config.Jobs[job].businessId.
-- Export informado pelo usuário: exports['btc-business']:AddMoneyBusiness(localId, addMoney)
function DepositToBusiness(businessId, amount)
    exports['btc-business']:AddMoneyBusiness(businessId, amount)
end

-- ════════════════════════════════════════════════════════════════════════════════
-- Visibilidade das contas (quem vê o quê)
-- ════════════════════════════════════════════════════════════════════════════════

-- Resolve o escopo de leitura de contas para um source:
--   { scope = 'all' }            → admin OU job especial: vê todas as contas
--   { scope = 'job', job = X }   → job habilitado em Config.Jobs: vê só as do próprio job
--   { scope = 'none' }           → sem permissão
function GetBillScope(src)
    local job = Core.framework.getJob(src)
    local group = Core.framework.getGroup(src)

    if group == 'admin' then
        return { scope = 'all' }
    end

    for _, specialJob in ipairs(Config.SpecialJobs) do
        if job == specialJob then
            return { scope = 'all' }
        end
    end

    if Config.Jobs[job] then
        return { scope = 'job', job = job }
    end

    return { scope = 'none' }
end
