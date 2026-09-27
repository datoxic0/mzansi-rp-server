Mzansi = Mzansi or {}
Mzansi.GroupBankUI = Mzansi.GroupBankUI or {}
Mzansi.GroupBankUI._visible = false
Mzansi.GroupBankUI._accounts = nil
Mzansi.GroupBankUI._history = nil
Mzansi.GroupBankUI._selected = 1
Mzansi.GroupBankUI._amount = ""

-- Lightweight overlay opened from Bank UI Groups tab (tab 5).
-- When BankUI is open with tab==5, render group list.

addEvent("mzansi:groupbank:setAccounts", true)
addEventHandler("mzansi:groupbank:setAccounts", root, function(accounts)
    if type(accounts) == "table" then
        Mzansi.GroupBankUI._accounts = accounts
        if Mzansi.GroupBankUI._selected > #accounts then
            Mzansi.GroupBankUI._selected = math.max(1, #accounts)
        end
    end
end)

addEvent("mzansi:groupbank:setHistory", true)
addEventHandler("mzansi:groupbank:setHistory", root, function(hist)
    if type(hist) == "table" then
        Mzansi.GroupBankUI._history = hist
    end
end)

-- Called by BankUI when Groups tab selected
function Mzansi.GroupBankUI.request()
    triggerServerEvent("mzansi:groupbank:requestAccounts", localPlayer)
end

function Mzansi.GroupBankUI.deposit(ownerType, ownerId, amount)
    triggerServerEvent("mzansi:groupbank:deposit", localPlayer, ownerType, ownerId, amount)
end

function Mzansi.GroupBankUI.withdraw(ownerType, ownerId, amount)
    triggerServerEvent("mzansi:groupbank:withdraw", localPlayer, ownerType, ownerId, amount)
end

function Mzansi.GroupBankUI.select(i)
    Mzansi.GroupBankUI._selected = i
    local a = Mzansi.GroupBankUI._accounts and Mzansi.GroupBankUI._accounts[i]
    if a then
        triggerServerEvent("mzansi:groupbank:requestHistory", localPlayer, a.id)
    end
end
