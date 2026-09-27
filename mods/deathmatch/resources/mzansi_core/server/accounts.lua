Mzansi = Mzansi or {}
Mzansi.Accounts = {}
Mzansi.Accounts._loggedIn = {}

addEvent("mzansi:accounts:login", true)
addEvent("mzansi:accounts:register", true)
addEvent("mzansi:accounts:logout", true)
addEvent("mzansi:accounts:recoverPassword", true)

local function hashPassword(password, username)
    if passwordHash then
        return passwordHash(password, "bcrypt", { cost = 10 })
    elseif sha256 then
        return sha256(password .. username)
    else
        return md5(password .. username)
    end
end

local function verifyPassword(password, username, storedHash)
    if not storedHash then return false end
    if storedHash:sub(1, 4) == "$2y$" or storedHash:sub(1, 4) == "$2a$" or storedHash:sub(1, 4) == "$2b$" then
        if passwordVerify then
            local ok, result = pcall(passwordVerify, password, storedHash)
            if ok then return result == true end
        end
        return false
    end
    if sha256 then
        if sha256(password .. username) == storedHash
        or sha256(password) == storedHash
        or sha256(username .. password) == storedHash
        or sha256(password .. string.lower(username)) == storedHash
        or sha256(string.lower(username) .. password) == storedHash then
            return true
        end
    end
    if md5 then
        if md5(password .. username) == storedHash
        or md5(password) == storedHash
        or md5(username .. password) == storedHash then
            return true
        end
    end
    if password == storedHash then
        return true
    end
    return false
end

function Mzansi.Accounts.login(source, username, password)
    if not source or not username or not password then
        return false, "Invalid login parameters."
    end

    username = Mzansi.Util.sanitizeInput(username)
    -- Passwords must NOT be sanitized: stripping quotes/angle brackets corrupts valid credentials.
    password = tostring(password)

    local account = Mzansi.Database.getAccount(username)
    if not account then
        return false, "Account not found."
    end

    if account.banned == 1 then
        return false, "Account is banned: " .. (account.ban_reason or "No reason provided.")
    end

    if not verifyPassword(password, account.username, account.password_hash) then
        return false, "Incorrect password."
    end

    -- Auto-upgrade legacy hash to BCrypt if needed
    if account.password_hash:sub(1, 4) ~= "$2y$" and passwordHash then
        local newHash = hashPassword(password, account.username)
        Mzansi.Database.update(
            "UPDATE mzansi_accounts SET password_hash = ? WHERE id = ?",
            newHash, account.id
        )
    end

    Mzansi.Database.update(
        "UPDATE mzansi_accounts SET last_login = NOW(), serial = ? WHERE id = ?",
        getPlayerSerial(source), account.id
    )

    setElementData(source, "mzansi:accountId", account.id)
    setElementData(source, "mzansi:username", account.username or username)
    setElementData(source, "mzansi:adminLevel", account.admin_level)

    local character = Mzansi.Database.getCharacter(account.id)
    if character then
        Mzansi.Accounts._loggedIn[source] = account.id
        Mzansi.Characters.loadCharacter(source, character)
        Mzansi.Characters.spawnPlayer(source)
        Mzansi.Database.logAction("LOGIN", account.id, username, "Player logged in", "", getPlayerIP(source))
        return true, "Login successful."
    else
        Mzansi.Accounts._loggedIn[source] = account.id
        triggerClientEvent(source, "mzansi:accounts:showCharCreate", source)
        return true, "No character found. Please create one."
    end
end

function Mzansi.Accounts.register(source, username, password, email)
    if not source or not username or not password then
        return false, "Invalid registration parameters."
    end

    username = Mzansi.Util.sanitizeInput(username)
    password = tostring(password)
    email = Mzansi.Util.sanitizeInput(email or "")

    if #username < 3 or #username > 32 then
        return false, "Username must be 3-32 characters."
    end

    if #password < 6 then
        return false, "Password must be at least 6 characters."
    end

    if email ~= "" and not Mzansi.Util.isValidEmail(email) then
        return false, "Invalid email address."
    end

    local existing = Mzansi.Database.getAccount(username)
    if existing then
        return false, "Username already taken."
    end

    local passwordHashStr = hashPassword(password, username)
    local serial = getPlayerSerial(source)
    local accountId = Mzansi.Database.createAccount(username, passwordHashStr, email, serial)

    if accountId then
        setElementData(source, "mzansi:accountId", accountId)
        setElementData(source, "mzansi:username", username)
        setElementData(source, "mzansi:adminLevel", 0)
        Mzansi.Accounts._loggedIn[source] = accountId
        Mzansi.Database.logAction("REGISTER", accountId, username, "New account created", "", getPlayerIP(source))
        return true, "Account created! Please log in."
    else
        return false, "Failed to create account."
    end
end

function Mzansi.Accounts.logout(source)
    local accountId = Mzansi.Accounts._loggedIn[source]
    if accountId then
        if Mzansi.Vehicles and Mzansi.Vehicles.savePlayerVehicles then
            Mzansi.Vehicles.savePlayerVehicles(source)
        end
        Mzansi.Characters.saveCharacter(source)
        Mzansi.Database.logAction("LOGOUT", accountId, getElementData(source, "mzansi:username") or "Unknown", "Player logged out", "", getPlayerIP(source))
        Mzansi.Accounts._loggedIn[source] = nil
        removeElementData(source, "mzansi:accountId")
        removeElementData(source, "mzansi:username")
        removeElementData(source, "mzansi:character")
        removeElementData(source, "mzansi:adminLevel")
    end
end

function Mzansi.Accounts.isLoggedIn(source)
    return Mzansi.Accounts._loggedIn[source] ~= nil
end

function Mzansi.Accounts.getAccountId(source)
    return Mzansi.Accounts._loggedIn[source]
end

addEventHandler("mzansi:accounts:login", root, function(username, password)
    local source = client or source
    local success, message = Mzansi.Accounts.login(source, username, password)
    triggerClientEvent(source, "mzansi:accounts:loginResult", source, success, message)
end)

addEventHandler("mzansi:accounts:register", root, function(username, password, email)
    local source = client or source
    local success, message = Mzansi.Accounts.register(source, username, password, email)
    triggerClientEvent(source, "mzansi:accounts:registerResult", source, success, message)
end)

addEventHandler("mzansi:accounts:recoverPassword", root, function(username, email, newPassword)
    local source = client or source
    local success, message = Mzansi.Accounts.recoverPassword(source, username, email, newPassword)
    triggerClientEvent(source, "mzansi:accounts:recoveryResult", source, success, message)
end)

function Mzansi.Accounts.recoverPassword(source, username, email, newPassword)
    if not source or not username or not email or not newPassword then
        return false, "All recovery fields are required."
    end

    username = Mzansi.Util.sanitizeInput(username)
    email = Mzansi.Util.sanitizeInput(email)
    newPassword = tostring(newPassword)

    if #newPassword < 6 then
        return false, "New password must be 6+ characters."
    end

    local account = Mzansi.Database.getAccount(username)
    if not account then
        return false, "No account found matching this username."
    end

    local accEmail = tostring(account.email or ""):gsub("%s+", ""):lower()
    local inputEmail = tostring(email):gsub("%s+", ""):lower()

    if #accEmail == 0 or accEmail ~= inputEmail then
        return false, "Email address does not match the registered account."
    end

    local newHash = hashPassword(newPassword, account.username)
    local updated = Mzansi.Database.update(
        "UPDATE mzansi_accounts SET password_hash = ? WHERE id = ?",
        newHash, account.id
    )

    if updated then
        Mzansi.Database.logAction("RECOVERY", account.id, username, "Password reset via email verification", "", getPlayerIP(source))
        return true, "Password successfully reset! You can now sign in with your new password."
    else
        return false, "Database error resetting password. Please try again."
    end
end

addEventHandler("mzansi:accounts:logout", root, function()
    local source = client or source
    Mzansi.Accounts.logout(source)
end)

addEventHandler("onPlayerQuit", root, function()
    local player = source
    if isElement(player) then
        Mzansi.Accounts.logout(player)
    end
end)

addEventHandler("onPlayerJoin", root, function()
    local player = source
    setElementDimension(player, 0)
    setElementInterior(player, 0)
    fadeCamera(player, true, 1.5)
    setTimer(function()
        if isElement(player) and not Mzansi.Accounts.isLoggedIn(player) then
            triggerClientEvent(player, "mzansi:accounts:showLogin", player)
        end
    end, 1000, 1)
end)

addEventHandler("onResourceStart", resourceRoot, function()
    outputDebugString("[Mzansi-Accounts] Account system loaded.")
end)
