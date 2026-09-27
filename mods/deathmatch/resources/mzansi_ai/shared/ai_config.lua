Mzansi = Mzansi or {}
Mzansi.AI = Mzansi.AI or {}

-- No secrets in shared/client config. Server reads optional local file or env-style table.
Mzansi.AI.Config = {
    mode = "reflex", -- "remote" requires provider_url + provider_key loaded server-side only
    provider_url = "",
    provider_model = "gpt-4o-mini",
    max_tokens = 512,
    temperature = 0.3,
    historyTurns = 8,
    rateLimitPerMin = 20,
    dailyBudget = 200,
    systemPrompt = "You are Mzansi RP in-game copilot. Be concise. Use R currency. Never invent real-money trading. Topics: jobs, banking, markets (paper), mechatronics, CE tickets, lab circuits, lore. Prefer allowlisted agent tools when local game data is needed.",
}

Mzansi.AI.Tasks = {
    npc_dialog = "Write a short SA-flavored NPC dialogue (3 lines) about {topic}.",
    lore_answer = "Answer as Mzansi RP lore for: {topic}",
    bug_report_triage = "Triage this bug report into severity and 3 fix steps: {topic}",
    job_coach = "Give 4 bullet job tips for: {topic}",
    market_brief = "Give a 4-line paper-market brief for instrument {topic}. Closed loop only.",
    mechatronics_tutor = "Explain stage topic briefly with one example: {topic}",
    ce_code_review = "Review this snippet pattern briefly (no live secrets): {topic}",
    chat = "{topic}",
}

function Mzansi.AI.promptFor(task, topic)
    local tpl = Mzansi.AI.Tasks[task] or Mzansi.AI.Tasks.chat
    return (tpl:gsub("{topic}", tostring(topic or "")))
end
