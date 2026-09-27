Mzansi = Mzansi or {}
Mzansi.MDT = Mzansi.MDT or {}

function Mzansi.MDT.search(query)
    local results = {}
    local accounts = getAccounts()
    for _, account in ipairs(accounts) do
        local accountName = getAccountName(account)
        if accountName and accountName:lower():find(query:lower(), 1, true) then
            table.insert(results, { name = accountName, type = "account" })
        end
    end
    return results
end

addEvent("mzansi:mdt:search", true)
addEventHandler("mzansi:mdt:search", root, function(query)
    local results = Mzansi.MDT.search(query or "")
    triggerClientEvent(client, "mzansi:mdt:response", client, results)
end)
