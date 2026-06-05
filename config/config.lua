Config = {}

Config.Locale = 'eng'
Config.Debug = false

---------------------------------
-- Webhook
---------------------------------

Config.UrlIcon = 'https://i.postimg.cc/mDfmzj3D/Gemini-Generated-Image-b28dslb28dslb28d.png'
Config.UrlIconThumb = 'https://i.postimg.cc/mDfmzj3D/Gemini-Generated-Image-b28dslb28dslb28d.png'
Config.WebhookColor = 3037669 -- Decimal Color
Config.WebhookUrl = ''



local isServerSide = IsDuplicityVersion()
-- Notification function (shared: works on client and server)
function Notify(message, timer, type, source)
    -- local VORPcore = exports.vorp_core:GetCore() -- For vorp
    if timer then
        timer = timer
    else
        timer = 5000
    end
    local type = type or 'info'

    if isServerSide then
        TriggerClientEvent('ox_lib:notify', source, { title = message, type = type, duration = timer }) -- RSG
        -- VORPcore.NotifyRightTip(source, message, 4000) -- For vorp
    else
        -- VORPcore.NotifyRightTip(message, 4000)         -- For vorp
        TriggerEvent('ox_lib:notify', { title = message, type = type, duration = timer }) -- RSG
    end
end

---------------------------------
-- Billing (pay-later accounts)
---------------------------------

-- Script commands (without the leading "/")
Config.Commands = {
    create     = 'createbill',   -- a job player creates a bill
    listJob    = 'bills',    -- creditor/job views the bills of its own job (special jobs/admins see all)
    listDebtor = 'mybills',  -- debtor views and pays their own bills
}

-- Jobs allowed to CREATE bills + map of the business that receives the money.
-- `businessId` is the `localId` passed to exports['btc-business']:AddMoneyBusiness(localId, amount).
-- Jobs not listed here cannot create nor list job bills.
Config.Jobs = {
    ['salval'] = { businessId = 'saloonValentine' },
    -- ['doctor']  = { businessId = 'doctor' },
}

-- Jobs that can see ALL bills (not only their own job's).
-- Admins (Core.framework.getGroup == 'admin') also see everything, regardless of job.
Config.SpecialJobs = {
    -- 'police',
    -- 'sheriff',
}

-- Time (in seconds) player 2 has to accept/decline before the offer expires.
Config.OfferTimeout = 60

-- Bill amount limits (validated on the server).
Config.MinAmount = 1
Config.MaxAmount = 100000
