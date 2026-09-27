Mzansi = Mzansi or {}
Mzansi.Phone = Mzansi.Phone or {}
Mzansi.Phone.Config = {}

Mzansi.Phone.Config.CallCostPerMinute = 50
Mzansi.Phone.Config.SMSCost = 25
Mzansi.Phone.Config.DataCostPerMB = 10
Mzansi.Phone.Config.SignalRadius = 200

Mzansi.Phone.Config.PhoneModels = {
    { name = "Basic Phone", model = 0, price = 0 },
    { name = "Smartphone", model = 1, price = 5000 },
    { name = "Mzansi Pro", model = 2, price = 15000 },
}

Mzansi.Phone.Config.DialPlans = {
    [0] = { name = "Free Plan", minutes = 0, sms = 0, data = 0, monthlyCost = 0 },
    [1] = { name = "Basic Plan", minutes = 100, sms = 50, data = 500, monthlyCost = 200 },
    [2] = { name = "Premium Plan", minutes = 500, sms = 200, data = 2000, monthlyCost = 500 },
}
