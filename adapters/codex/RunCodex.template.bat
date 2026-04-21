@echo off
setlocal
cd /d "%~dp0"
powershell -NoProfile -Command "$PromptText = (Get-Content -Raw -LiteralPath '%~dp0.codex\startup-prompt.ko.txt').Trim(); $CodexCmd = (Get-Command codex.cmd -CommandType Application -ErrorAction Stop).Source; & $CodexCmd $PromptText"

pause
