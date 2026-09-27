Mzansi = Mzansi or {}
Mzansi.Inventory = Mzansi.Inventory or {}

Mzansi.Inventory._browser = nil
Mzansi.Inventory._active = false
Mzansi.Inventory._items = {}

addEvent("mzansi:inventory:itemsList", true)

function Mzansi.Inventory.open()
    if Mzansi.Inventory._browser then
        destroyElement(Mzansi.Inventory._browser)
    end

    Mzansi.Inventory._browser = createBrowser(500, 400, true, true)
    Mzansi.Inventory._active = true

    addEventHandler("onClientBrowserCreated", Mzansi.Inventory._browser, function()
        loadBrowserURL(Mzansi.Inventory._browser, "http://mta/local/ui/inventory.html")
        showCursor(true)
    end)

    triggerServerEvent("mzansi:inventory:getItems", localPlayer)
end

function Mzansi.Inventory.close()
    if Mzansi.Inventory._browser then
        destroyElement(Mzansi.Inventory._browser)
        Mzansi.Inventory._browser = nil
    end
    Mzansi.Inventory._active = false
    showCursor(false)
end

function Mzansi.Inventory.useItem(itemName)
    triggerServerEvent("mzansi:inventory:use", localPlayer, itemName)
end

function Mzansi.Inventory.dropItem(itemName, quantity)
    triggerServerEvent("mzansi:inventory:drop", localPlayer, itemName, quantity)
end

function Mzansi.Inventory.giveItem(target, itemName, quantity)
    triggerServerEvent("mzansi:inventory:give", localPlayer, target, itemName, quantity)
end

function Mzansi.Inventory.render()
    if not Mzansi.Inventory._active then return end

    local screenW, screenH = guiGetScreenSize()
    local x, y = (screenW - 500) / 2, (screenH - 400) / 2

    if Mzansi.Inventory._browser then
        dxDrawImage(x, y, 500, 400, Mzansi.Inventory._browser, 0, 0, 0, tocolor(255, 255, 255, 255), true)
    else
        dxDrawRectangle(x, y, 500, 400, tocolor(10, 15, 25, 240), true)
        dxDrawRectangle(x, y, 500, 2, tocolor(200, 170, 50, 255), true)
        dxDrawText("INVENTORY (Loading...)", x + 10, y + 10, x + 490, y + 35, tocolor(200, 170, 50, 255), 1.2, "default-bold", "center", "top")
    end
end

addEventHandler("mzansi:inventory:itemsList", root, function(items)
    Mzansi.Inventory._items = items or {}
    if Mzansi.Inventory._browser then
        local payload = toJSON(Mzansi.Inventory._items)
        local js = string.format("window.postMessage({type: 'inventory:loaded', items: %s}, '*');", payload)
        executeBrowserJavascript(Mzansi.Inventory._browser, js)
    end
end)

addEventHandler("onClientRender", root, function()
    Mzansi.Inventory.render()
end)

addCommandHandler("inv", function()
    if Mzansi.Inventory._active then
        Mzansi.Inventory.close()
    else
        Mzansi.Inventory.open()
    end
end)

addCommandHandler("use", function(cmd, itemName)
    if itemName then
        Mzansi.Inventory.useItem(itemName)
    end
end)

addEventHandler("onClientResourceStart", resourceRoot, function()
    outputDebugString("[Mzansi-Inventory] Inventory client loaded.")
end)
