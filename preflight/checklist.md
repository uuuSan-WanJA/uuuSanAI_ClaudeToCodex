# Preflight Checklist

Mandatory checks before claiming a target Claude Code project is ready for Codex compatibility work or has been successfully converted.

| check | why it matters | expected evidence | status |
|-------|----------------|-------------------|--------|
| Source project scanned | Missing one operating surface corrupts every later step. | Source scan report. | planned |
| Compatibility matrix drafted | Conversion work needs an explicit gap map. | `compatibility-matrix.md` rows for the target. | planned |
| Hook dependence assessed | Hooks are a common Claude-specific portability risk. | Hook rows marked direct, rewrite, emulate, or blocked. | planned |
| Patchable files identified | The transformer needs concrete file targets. | Scan report plus patch plan candidates. | planned |
| Claude-safe strategy defined | Codex support must not silently break Claude behavior. | Patch items with Claude-side safety notes. | planned |
| Codex capability fit assessed | Some projects require features Codex may not expose directly. | Capability notes in compatibility matrix. | planned |
| Verification workflows chosen | Conversion success must be provable. | Named workflows for Claude-side and Codex-side checks. | planned |
| Known blockers recorded | Hidden blockers create false success claims. | Compatibility matrix `blocked` or explicit notes. | planned |

## Passing Rule

Preflight only passes when critical surfaces are no longer unknown and the project can proceed to transformation or verification honestly.
