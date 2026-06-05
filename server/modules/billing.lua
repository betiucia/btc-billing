-- ════════════════════════════════════════════════════════════════════════════════
-- btc-billing | Lógica de cobranças (criar, aceitar, listar, pagar)
-- ════════════════════════════════════════════════════════════════════════════════

local Core = exports['btc-core']:GetCore()

-- Ofertas pendentes (aguardando aceite) ficam em memória; só viram linha no DB quando aceitas.
local PendingOffers = {}
local offerSeq = 0

-- ════════════════════════════════════════════════════════════════════════════════
-- Helpers
-- ════════════════════════════════════════════════════════════════════════════════

-- Nome completo "Firstname Lastname" a partir do source.
local function FullName(src)
    local first, last = Core.framework.getName(src)
    return (((first or '') .. ' ' .. (last or '')):gsub('^%s*(.-)%s*$', '%1'))
end

-- ════════════════════════════════════════════════════════════════════════════════
-- Expiração de ofertas (varre a cada 5s)
-- ════════════════════════════════════════════════════════════════════════════════

CreateThread(function()
    while true do
        Wait(5000)
        local now = os.time()
        for offerId, offer in pairs(PendingOffers) do
            if now > offer.expiresAt then
                PendingOffers[offerId] = nil
                -- Avisa o credor que a cobrança expirou sem resposta
                Notify(string.format(L('billing.offer.expired_creditor'), offer.debtorName), 5000, 'error', offer.creatorSrc)
            end
        end
    end
end)

-- ════════════════════════════════════════════════════════════════════════════════
-- Criar oferta de cobrança (jogador 1)
-- ════════════════════════════════════════════════════════════════════════════════

Core.callback.register('btc-billing:server:offer:create', function(src, cb, data)
    -- 1) Job habilitado? (acesso + define a caixa de destino)
    local job = Core.framework.getJob(src)
    local jobCfg = Config.Jobs[job]
    if not jobCfg then
        return cb({ success = false, message = L('billing.no_job') })
    end

    -- 2) Valor válido?
    local amount = math.floor((tonumber(data and data.amount) or 0) * 100 + 0.5) / 100
    if amount < Config.MinAmount or amount > Config.MaxAmount then
        return cb({ success = false, message = string.format(L('billing.create.invalid_amount'), Config.MinAmount, Config.MaxAmount) })
    end

    -- 3) Devedor: id válido, online e diferente do próprio jogador
    local targetId = tonumber(data and data.targetId)
    if not targetId then
        return cb({ success = false, message = L('billing.create.invalid_id') })
    end
    -- if targetId == src then
    --     return cb({ success = false, message = L('billing.create.self') })
    -- end

    if not Core.framework.getPlayer(targetId) then
        return cb({ success = false, message = L('billing.create.target_offline') })
    end

    local debtorCid = Core.framework.getCitizenID(targetId)
    if not debtorCid then
        return cb({ success = false, message = L('billing.create.target_offline') })
    end

    -- 4) Monta a oferta em memória (NÃO grava no DB ainda)
    offerSeq = offerSeq + 1
    local offerId = offerSeq
    local description = tostring((data and data.description) or ''):sub(1, 255)

    PendingOffers[offerId] = {
        creatorSrc   = src,
        creatorCid   = Core.framework.getCitizenID(src),
        creatorJob   = job,
        creatorName  = FullName(src),
        businessId   = tostring(jobCfg.businessId),
        debtorSrc    = targetId,
        debtorCid    = debtorCid,
        debtorName   = FullName(targetId),
        amount       = amount,
        description  = description,
        expiresAt    = os.time() + Config.OfferTimeout,
    }

    -- 5) Envia o prompt de aceite para o jogador 2
    TriggerClientEvent('btc-billing:client:offer:prompt', targetId, {
        offerId      = offerId,
        creditorName = PendingOffers[offerId].creatorName,
        amount       = amount,
        description  = description,
    })

    cb({ success = true, message = L('billing.create.sent') })
end)

-- ════════════════════════════════════════════════════════════════════════════════
-- Responder oferta (jogador 2 aceita ou recusa)
-- ════════════════════════════════════════════════════════════════════════════════

Core.callback.register('btc-billing:server:offer:respond', function(src, cb, offerId, accepted)
    offerId = tonumber(offerId)
    local offer = offerId and PendingOffers[offerId]

    -- Valida: oferta existe, não expirou e quem responde é de fato o devedor
    if not offer or os.time() > offer.expiresAt or offer.debtorSrc ~= src then
        return cb({ success = false, message = L('billing.offer.invalid') })
    end

    -- Consome a oferta da memória (evita resposta dupla)
    PendingOffers[offerId] = nil

    if not accepted then
        Notify(L('billing.offer.declined_debtor'), 5000, 'info', src)
        Notify(string.format(L('billing.offer.declined_creditor'), offer.debtorName), 5000, 'error', offer.creatorSrc)
        return cb({ success = true })
    end

    -- Aceitou → grava a conta como ativa, com o relógio da dívida iniciando agora.
    -- await garante o commit antes de invalidar o cache (credor pode abrir /contas em seguida).
    MySQL.update.await([[
        INSERT INTO `btc_billing_bills`
            (`creator_citizenid`, `creator_job`, `business_id`, `creditor_name`,
             `debtor_citizenid`, `debtor_name`, `amount`, `description`, `status`, `accepted_at`)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'active', NOW())
    ]], {
        offer.creatorCid, offer.creatorJob, offer.businessId, offer.creatorName,
        offer.debtorCid, offer.debtorName, offer.amount, offer.description,
    })

    InvalidateCache('bills:')

    QueueWebhook(offer.creatorSrc, 'billing:created', {
        creditor = offer.creatorName,
        creator_cid = offer.creatorCid,
        job = offer.creatorJob,
        business_id = offer.businessId,
        debtor = offer.debtorName,
        debtor_cid = offer.debtorCid,
        amount = offer.amount,
        description = offer.description,
    })

    Notify(string.format(L('billing.offer.accepted_debtor'), offer.amount), 5000, 'success', src)
    Notify(string.format(L('billing.offer.accepted_creditor'), offer.debtorName, offer.amount), 5000, 'success', offer.creatorSrc)

    cb({ success = true })
end)

-- ════════════════════════════════════════════════════════════════════════════════
-- Listar contas do job (credor / jobs especiais / admin)
-- ════════════════════════════════════════════════════════════════════════════════

Core.callback.register('btc-billing:server:list:job', function(src, cb)
    local access = GetBillScope(src)
    if access.scope == 'none' then
        return cb({ success = false, message = L('billing.no_permission') })
    end

    local cacheKey = 'bills:job:' .. (access.scope == 'all' and 'all' or access.job)
    local cached = GetCached(cacheKey)
    if cached then return cb({ success = true, bills = cached }) end

    local rows
    if access.scope == 'all' then
        rows = MySQL.query.await([[
            SELECT `id`, `debtor_name`, `amount`, `description`, `creator_job`,
                   DATEDIFF(NOW(), `accepted_at`) AS days_owed
            FROM `btc_billing_bills` WHERE `status` = 'active' ORDER BY `created_at` DESC
        ]], {})
    else
        rows = MySQL.query.await([[
            SELECT `id`, `debtor_name`, `amount`, `description`, `creator_job`,
                   DATEDIFF(NOW(), `accepted_at`) AS days_owed
            FROM `btc_billing_bills` WHERE `status` = 'active' AND `creator_job` = ? ORDER BY `created_at` DESC
        ]], { access.job })
    end

    rows = rows or {}
    SetCached(cacheKey, rows, 5)
    cb({ success = true, bills = rows })
end)

-- ════════════════════════════════════════════════════════════════════════════════
-- Listar as próprias contas (devedor)
-- ════════════════════════════════════════════════════════════════════════════════

Core.callback.register('btc-billing:server:list:debtor', function(src, cb)
    local cid = Core.framework.getCitizenID(src)
    if not cid then return cb({ success = false, message = L('billing.fetch_failed') }) end

    local cacheKey = 'bills:debtor:' .. cid
    local cached = GetCached(cacheKey)
    if cached then return cb({ success = true, bills = cached }) end

    local rows = MySQL.query.await([[
        SELECT `id`, `creditor_name`, `amount`, `description`,
               DATEDIFF(NOW(), `accepted_at`) AS days_owed
        FROM `btc_billing_bills` WHERE `status` = 'active' AND `debtor_citizenid` = ? ORDER BY `created_at` DESC
    ]], { cid })

    rows = rows or {}
    SetCached(cacheKey, rows, 5)
    cb({ success = true, bills = rows })
end)

-- ════════════════════════════════════════════════════════════════════════════════
-- Pagar uma conta (devedor) → debita do bolso e credita na caixa do job
-- ════════════════════════════════════════════════════════════════════════════════

Core.callback.register('btc-billing:server:bill:pay', function(src, cb, billId)
    local cid = Core.framework.getCitizenID(src)
    billId = tonumber(billId)
    if not cid or not billId then return cb({ success = false, message = L('billing.pay.not_found') }) end

    -- Relê a conta do DB (nunca confiar em valor vindo do client)
    local bill = MySQL.query.await([[
        SELECT `id`, `business_id`, `amount`, `debtor_citizenid`
        FROM `btc_billing_bills` WHERE `id` = ? AND `status` = 'active'
    ]], { billId })
    bill = bill and bill[1]

    if not bill or bill.debtor_citizenid ~= cid then
        return cb({ success = false, message = L('billing.pay.not_found') })
    end

    bill.amount = tonumber(bill.amount)

    -- Debita do bolso; só segue se o débito for confirmado
    if not Core.framework.removeMoney(src, 'cash', bill.amount) then
        return cb({ success = false, message = L('billing.pay.no_money') })
    end

    -- Claim atômico: marca como paga só se ainda estiver ativa (evita pagamento duplo em corrida)
    local affected = MySQL.update.await([[
        UPDATE `btc_billing_bills` SET `status` = 'paid', `paid_at` = NOW()
        WHERE `id` = ? AND `status` = 'active'
    ]], { billId })

    if not affected or affected == 0 then
        -- Outra requisição já quitou: devolve o dinheiro debitado e aborta
        Core.framework.addMoney(src, 'cash', bill.amount)
        return cb({ success = false, message = L('billing.pay.not_found') })
    end

    -- Deposita o valor na caixa do negócio
    DepositToBusiness(bill.business_id, bill.amount)
    InvalidateCache('bills:')

    QueueWebhook(src, 'billing:paid', {
        bill_id = bill.id,
        debtor_cid = cid,
        business_id = bill.business_id,
        amount = bill.amount,
    })

    cb({ success = true, message = string.format(L('billing.pay.success'), bill.amount) })
end)
