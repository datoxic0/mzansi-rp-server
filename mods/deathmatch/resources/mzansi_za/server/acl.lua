Mzansi = Mzansi or {}
Mzansi.ACL = Mzansi.ACL or {}

local rightList = {
    "command.mzansi_bank",
    "command.mzansi_mdt",
    "command.mzansi_register",
    "command.mzansi_spawn",
    "function.mzansiOpenBank",
    "function.mzansiOpenMDT"
}

function Mzansi.ACL.register()
    local aclName = "MzansiZA"
    if not aclCreate(aclName) then
        outputDebugString("[Mzansi-ZA] ACL already exists.", 3)
    end

    for _, right in ipairs(rightList) do
        aclSetRight(aclName, right, true)
    end

    local adminGroup = aclGetGroup("Admin")
    if adminGroup then
        aclGroupAddACL(adminGroup, aclName)
    end
end
