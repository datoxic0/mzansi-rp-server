Mzansi = Mzansi or {}
Mzansi.CE = Mzansi.CE or {}

Mzansi.CE.Tickets = {
    {
        id = "ce001",
        title = "Fix cross-resource Inventory call pattern",
        severity = "medium",
        reward = 1500,
        prompt = "Mzansi.Inventory is nil across VMs. What is the correct pattern?",
        options = {
            "Use exports.mzansi_inventory with getResourceFromName + pcall guards",
            "Call OtherResource.Table.Function() directly",
            "Copy inventory.lua into every resource",
            "Use global Mzansi.Inventory on server",
        },
        answer = 1,
    },
    {
        id = "ce002",
        title = "Lua 5.1 has no compound assignment",
        severity = "easy",
        reward = 900,
        prompt = "Which line is invalid in MTA server Lua 5.1?",
        options = {
            "x = x + 1",
            "x = x + 1",
            "local x = 1; x = x + 1",
            "local ok = pcall(function() end)",
        },
        answer = 3,
    },
    {
        id = "ce003",
        title = "meta.xml missing file registration",
        severity = "easy",
        reward = 800,
        prompt = "Resource fails to load because a <script src> points to a missing file. Fix?",
        options = {
            "Delete meta.xml",
            "Create the missing file or remove the tag so src always exists",
            "Use hyphens in folder names",
            "Put resources under server/resources/",
        },
        answer = 2,
    },
    {
        id = "ce004",
        title = "Cross-resource global crash",
        severity = "hard",
        reward = 2200,
        prompt = "mzansi_anticheat indexes Mzansi.Util before core finishes loading. Remediation?",
        options = {
            "Hardcode distance math everywhere",
            "Add nil guards / delay until resource is running",
            "Protect mzansi_anticheat and never load core",
            "Remove anticheat",
        },
        answer = 2,
    },
    {
        id = "ce005",
        title = "Sandbox escape attempt",
        severity = "hard",
        reward = 2500,
        prompt = "A snippet calls os.execute. The sandbox must:",
        options = {
            "Allow it for admin players",
            "Reject forbidden identifiers (io, os, require, debug) before eval",
            "Strip comments only",
            "Run in the resource root VM",
        },
        answer = 2,
    },
}
