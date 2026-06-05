-- ════════════════════════════════════════════════════════════════════════════════
-- btc-billing | Comandos e menus (client é só ponte — toda validação é no server)
-- ════════════════════════════════════════════════════════════════════════════════

local Core = exports['btc-core']:GetCore()
local CoreUI = exports['btc-core']

-- Descrição segura para os footers dos menus (motivo vazio vira "-")
local function reasonOr(desc)
    return (desc ~= nil and desc ~= '' and desc) or '-'
end

-- ════════════════════════════════════════════════════════════════════════════════
-- Criar cobrança (jogador 1) — form com inputs
-- ════════════════════════════════════════════════════════════════════════════════

local function OpenCreateMenu()
    -- Guarda o que o jogador digita; o botão de envio lê estes valores.
    local form = { targetId = '', amount = '', description = '' }

    CoreUI:openMenu({
        id = 'btc_billing_create',
        title = L('billing.create.title'),
        subtext = L('billing.create.subtext'),
        align = 'top-left',
        elements = {
            { type = 'input', label = L('billing.create.input_id'), value = '', maxLength = 8, inputType = 'numbers',
              onChanged = function(t) form.targetId = t end },
            { type = 'input', label = L('billing.create.input_amount'), value = '', maxLength = 10, inputType = 'any',
              onChanged = function(t) form.amount = t end },
            { type = 'input', label = L('billing.create.input_reason'), value = '', maxLength = 100, inputType = 'any',
              onChanged = function(t) form.description = t end },
            { label = L('billing.create.submit'),
              action = function()
                  Core.callback.triggerServer('btc-billing:server:offer:create', function(res)
                      Notify(res.message, 5000, res.success and 'success' or 'error')
                  end, { targetId = form.targetId, amount = form.amount, description = form.description })
                  CoreUI:closeMenu()
              end },
        }
    })
end

-- ════════════════════════════════════════════════════════════════════════════════
-- Receber oferta de cobrança (jogador 2) — aceitar/recusar
-- ════════════════════════════════════════════════════════════════════════════════

RegisterNetEvent('btc-billing:client:offer:prompt')
AddEventHandler('btc-billing:client:offer:prompt', function(data)
    local detail = string.format(L('billing.offer.from'), data.creditorName) .. '<br>' ..
                   string.format(L('billing.offer.amount'), data.amount) .. '<br>' ..
                   string.format(L('billing.offer.reason'), reasonOr(data.description))

    local function respond(accepted)
        Core.callback.triggerServer('btc-billing:server:offer:respond', function(res)
            if res and not res.success then Notify(res.message, 5000, 'error') end
        end, data.offerId, accepted)
        CoreUI:closeMenu()
    end

    CoreUI:openMenu({
        id = 'btc_billing_offer',
        title = L('billing.offer.title'),
        subtext = L('billing.offer.subtext'),
        align = 'top-left',
        elements = {
            { label = L('billing.offer.accept'), desc = detail, action = function() respond(true) end },
            { label = L('billing.offer.decline'), desc = detail, action = function() respond(false) end },
        }
    })
end)

-- ════════════════════════════════════════════════════════════════════════════════
-- Listar contas do job (credor / jobs especiais / admin) — somente leitura
-- ════════════════════════════════════════════════════════════════════════════════

local function OpenJobBillsMenu()
    Core.callback.triggerServer('btc-billing:server:list:job', function(res)
        if not res or not res.success then
            Notify((res and res.message) or L('billing.fetch_failed'), 5000, 'error')
            return
        end
        if #res.bills == 0 then
            Notify(L('billing.list.empty'), 5000, 'info')
            return
        end

        local elements = {}
        for _, b in ipairs(res.bills) do
            elements[#elements + 1] = {
                label = string.format(L('billing.list.entry'), b.debtor_name, b.amount),
                desc = string.format(L('billing.list.detail'), b.debtor_name, b.amount, b.days_owed or 0, reasonOr(b.description)),
                action = function() end,
            }
        end

        CoreUI:openMenu({
            id = 'btc_billing_job',
            title = L('billing.list.job_title'),
            searchable = true,
            align = 'top-left',
            elements = elements,
        })
    end)
end

-- ════════════════════════════════════════════════════════════════════════════════
-- Minhas contas (devedor) + pagar
-- ════════════════════════════════════════════════════════════════════════════════

local function OpenMyBillsMenu()
    Core.callback.triggerServer('btc-billing:server:list:debtor', function(res)
        if not res or not res.success then
            Notify((res and res.message) or L('billing.fetch_failed'), 5000, 'error')
            return
        end
        if #res.bills == 0 then
            Notify(L('billing.mybills.empty'), 5000, 'info')
            return
        end

        local elements = {}
        for _, b in ipairs(res.bills) do
            local billId = b.id
            elements[#elements + 1] = {
                label = string.format(L('billing.mybills.pay'), b.amount),
                desc = string.format(L('billing.mybills.detail'), b.creditor_name, b.amount, b.days_owed or 0, reasonOr(b.description)),
                action = function()
                    Core.callback.triggerServer('btc-billing:server:bill:pay', function(payRes)
                        Notify(payRes.message, 5000, payRes.success and 'success' or 'error')
                        CoreUI:closeMenu()
                        -- Reabre a lista já atualizada após um pagamento bem-sucedido
                        if payRes.success then OpenMyBillsMenu() end
                    end, billId)
                end,
            }
        end

        CoreUI:openMenu({
            id = 'btc_billing_mybills',
            title = L('billing.mybills.title'),
            align = 'top-left',
            elements = elements,
        })
    end)
end

-- ════════════════════════════════════════════════════════════════════════════════
-- Comandos
-- ════════════════════════════════════════════════════════════════════════════════

RegisterCommand(Config.Commands.create, function() OpenCreateMenu() end, false)
RegisterCommand(Config.Commands.listJob, function() OpenJobBillsMenu() end, false)
RegisterCommand(Config.Commands.listDebtor, function() OpenMyBillsMenu() end, false)
