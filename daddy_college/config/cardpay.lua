-- The College card wallet: the scholarship allowance (students) and the salary (teachers) build up on the
-- card, and its holder takes it out at any ATM. Nothing is paid onto a card the player does not carry.
Config.CardPay = {
    Account = 'cash', -- where a withdrawal goes (DaddyRP: nakit; öğrencilerin banka hesabı yok)
    WithdrawCooldownMs = 3000,

    -- ATM props that get the withdraw option, the map's own ones too. ATMs placed as world spots of
    -- kind 'cardpay_atm' use the spot's model, or the first one here.
    ATMModels = { 'prop_atm_01', 'prop_atm_02', 'prop_atm_03', 'prop_fleeca_atm' },
    TargetDistance = 2.0, -- at least the bank ATM option's reach (nn_banking 1.8), or only the bank shows

    -- Teacher salary on the card, paid here every IntervalMinutes. Leave it off when the framework's own
    -- paycheck calls the export DepositCardPaycheck(source, amount) instead; never use both.
    Salary = { Enabled = false, Amount = 250, IntervalMinutes = 30 },
}
