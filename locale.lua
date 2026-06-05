Locale = {
    ['pt-br'] = {
        -- Webhook Labels
        ['webhook.batch.title'] = 'Relatório em Lote',
        ['webhook.batch.actions'] = 'ações',
        ['webhook.critical.title'] = 'CRÍTICO',
        ['webhook.player'] = 'Jogador',
        ['webhook.citizen_id'] = 'ID do Cidadão',
        ['webhook.license'] = 'License/Steam ID',
        ['webhook.timestamp'] = 'Horário',
        ['webhook.action'] = 'Ação',
        ['webhook.data'] = 'Dados',
        ['webhook.details'] = 'Detalhes',

        -- Billing: acesso / erros
        ['billing.no_job'] = 'Você não tem um job habilitado para criar cobranças.',
        ['billing.no_permission'] = 'Você não tem permissão para ver estas contas.',
        ['billing.fetch_failed'] = 'Falha ao buscar as contas.',

        -- Billing: criação
        ['billing.create.title'] = 'Nova Cobrança',
        ['billing.create.subtext'] = 'Preencha os dados da conta',
        ['billing.create.input_id'] = 'ID do Devedor',
        ['billing.create.input_amount'] = 'Valor',
        ['billing.create.input_reason'] = 'Motivo (opcional)',
        ['billing.create.submit'] = 'Enviar Cobrança',
        ['billing.create.invalid_id'] = 'ID do devedor inválido.',
        ['billing.create.invalid_amount'] = 'Valor inválido (mín. %s, máx. %s).',
        ['billing.create.target_offline'] = 'Jogador não encontrado ou offline.',
        ['billing.create.self'] = 'Você não pode cobrar a si mesmo.',
        ['billing.create.sent'] = 'Cobrança enviada. Aguardando o aceite do jogador.',

        -- Billing: oferta (lado do devedor)
        ['billing.offer.title'] = 'Cobrança Recebida',
        ['billing.offer.subtext'] = 'Você aceita esta conta?',
        ['billing.offer.from'] = 'Credor: %s',
        ['billing.offer.amount'] = 'Valor: $%s',
        ['billing.offer.reason'] = 'Motivo: %s',
        ['billing.offer.accept'] = 'Aceitar',
        ['billing.offer.decline'] = 'Recusar',
        ['billing.offer.invalid'] = 'Oferta expirada ou inválida.',

        -- Billing: resultado da oferta
        ['billing.offer.accepted_creditor'] = '%s aceitou a cobrança de $%s.',
        ['billing.offer.accepted_debtor'] = 'Você aceitou a conta de $%s.',
        ['billing.offer.declined_creditor'] = '%s recusou a sua cobrança.',
        ['billing.offer.declined_debtor'] = 'Você recusou a cobrança.',
        ['billing.offer.expired_creditor'] = 'A cobrança enviada para %s expirou.',

        -- Billing: lista do job
        ['billing.list.job_title'] = 'Contas do Job',
        ['billing.list.empty'] = 'Nenhuma conta em aberto encontrada.',
        ['billing.list.entry'] = '%s — $%s',
        ['billing.list.detail'] = 'Devedor: %s<br>Valor: $%s<br>Dias devendo: %s<br>Motivo: %s',

        -- Billing: minhas contas (lado do devedor) + pagamento
        ['billing.mybills.title'] = 'Minhas Contas',
        ['billing.mybills.empty'] = 'Você não tem contas em aberto.',
        ['billing.mybills.pay'] = 'Pagar $%s',
        ['billing.mybills.detail'] = 'Credor: %s<br>Valor: $%s<br>Dias devendo: %s<br>Motivo: %s',
        ['billing.pay.no_money'] = 'Você não tem dinheiro suficiente para pagar esta conta.',
        ['billing.pay.success'] = 'Conta paga com sucesso: $%s.',
        ['billing.pay.not_found'] = 'Conta não encontrada ou já paga.',
        ['billing.pay.error'] = 'Erro ao processar o pagamento.',
    },
    ['eng'] = {
        -- Webhook Labels
        ['webhook.batch.title'] = 'Batch Report',
        ['webhook.batch.actions'] = 'actions',
        ['webhook.critical.title'] = 'CRITICAL',
        ['webhook.player'] = 'Player',
        ['webhook.citizen_id'] = 'Citizen ID',
        ['webhook.license'] = 'License/Steam ID',
        ['webhook.timestamp'] = 'Timestamp',
        ['webhook.action'] = 'Action',
        ['webhook.data'] = 'Data',
        ['webhook.details'] = 'Details',

        -- Billing: access / errors
        ['billing.no_job'] = 'You do not have a job allowed to create bills.',
        ['billing.no_permission'] = 'You are not allowed to view these bills.',
        ['billing.fetch_failed'] = 'Failed to fetch the bills.',

        -- Billing: creation
        ['billing.create.title'] = 'New Bill',
        ['billing.create.subtext'] = 'Fill in the bill details',
        ['billing.create.input_id'] = 'Debtor ID',
        ['billing.create.input_amount'] = 'Amount',
        ['billing.create.input_reason'] = 'Reason (optional)',
        ['billing.create.submit'] = 'Send Bill',
        ['billing.create.invalid_id'] = 'Invalid debtor ID.',
        ['billing.create.invalid_amount'] = 'Invalid amount (min. %s, max. %s).',
        ['billing.create.target_offline'] = 'Player not found or offline.',
        ['billing.create.self'] = 'You cannot bill yourself.',
        ['billing.create.sent'] = 'Bill sent. Waiting for the player to accept.',

        -- Billing: offer (debtor side)
        ['billing.offer.title'] = 'Bill Received',
        ['billing.offer.subtext'] = 'Do you accept this bill?',
        ['billing.offer.from'] = 'Creditor: %s',
        ['billing.offer.amount'] = 'Amount: $%s',
        ['billing.offer.reason'] = 'Reason: %s',
        ['billing.offer.accept'] = 'Accept',
        ['billing.offer.decline'] = 'Decline',
        ['billing.offer.invalid'] = 'Offer expired or invalid.',

        -- Billing: offer outcome
        ['billing.offer.accepted_creditor'] = '%s accepted the bill of $%s.',
        ['billing.offer.accepted_debtor'] = 'You accepted the bill of $%s.',
        ['billing.offer.declined_creditor'] = '%s declined your bill.',
        ['billing.offer.declined_debtor'] = 'You declined the bill.',
        ['billing.offer.expired_creditor'] = 'The bill sent to %s has expired.',

        -- Billing: job list
        ['billing.list.job_title'] = 'Job Bills',
        ['billing.list.empty'] = 'No open bills found.',
        ['billing.list.entry'] = '%s — $%s',
        ['billing.list.detail'] = 'Debtor: %s<br>Amount: $%s<br>Days owed: %s<br>Reason: %s',

        -- Billing: my bills (debtor side) + payment
        ['billing.mybills.title'] = 'My Bills',
        ['billing.mybills.empty'] = 'You have no open bills.',
        ['billing.mybills.pay'] = 'Pay $%s',
        ['billing.mybills.detail'] = 'Creditor: %s<br>Amount: $%s<br>Days owed: %s<br>Reason: %s',
        ['billing.pay.no_money'] = 'You do not have enough money to pay this bill.',
        ['billing.pay.success'] = 'Bill paid successfully: $%s.',
        ['billing.pay.not_found'] = 'Bill not found or already paid.',
        ['billing.pay.error'] = 'Error while processing the payment.',
    },
}

-- Global locale helper: L('script.module.key')
-- Returns the translated string for Config.Locale, or the key itself if missing.
function L(key)
    local lang = (Config and Config.Locale) or 'eng'
    local entry = Locale[lang] and Locale[lang][key]
    return entry or key
end