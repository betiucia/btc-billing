-- ════════════════════════════════════════════════════════════════════════════════
-- btc-billing | Database setup
-- ════════════════════════════════════════════════════════════════════════════════

-- Cria as tabelas necessárias na inicialização. IF NOT EXISTS para nunca perder dados.
local function CreateDatabase()
    local tables = {
        { query = [[
            CREATE TABLE IF NOT EXISTS `btc_billing_bills` (
                `id` int(11) NOT NULL AUTO_INCREMENT,
                `creator_citizenid` varchar(50) NOT NULL DEFAULT '0',
                `creator_job` varchar(50) NOT NULL DEFAULT '0',
                `business_id` varchar(50) NOT NULL DEFAULT '0',
                `creditor_name` varchar(100) NOT NULL DEFAULT '',
                `debtor_citizenid` varchar(50) NOT NULL DEFAULT '0',
                `debtor_name` varchar(100) NOT NULL DEFAULT '',
                `amount` decimal(10,2) NOT NULL DEFAULT 0.00,
                `description` varchar(255) NOT NULL DEFAULT '',
                `status` varchar(20) NOT NULL DEFAULT 'active',
                `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
                `accepted_at` timestamp NULL DEFAULT NULL,
                `paid_at` timestamp NULL DEFAULT NULL,
                PRIMARY KEY (`id`),
                KEY `idx_creator_job` (`creator_job`),
                KEY `idx_debtor` (`debtor_citizenid`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
        ]] },
    }

    for _, tbl in ipairs(tables) do
        exports.oxmysql:execute(tbl.query, {})
    end
end

CreateDatabase()
