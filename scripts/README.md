# Scripts

Automation entrypoints for the conversion pipeline.

## Implemented

- `scan-claude-project.ps1`
  - inventory Claude-oriented operating surfaces in a target project
  - emit a durable source scan report and first-pass compatibility matrix under `reports/`
  - detect continuity surfaces such as repo-root Codex guides, runtime launchers, and session handoff artifacts
  - default output names: `<report-stem>-source-scan-report.md` and `<report-stem>-compatibility-matrix.md`

### Usage

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\scan-claude-project.ps1 -ProjectPath <target-project>
```

Optional:

- `-ReportsDirectory <path>`
- `-ReportStem <name>`

## Planned

- `plan-codex-patch.ps1`
  - generate a patch plan from scan results and compatibility gaps
- `apply-codex-patch.ps1`
  - apply approved project edits
- `verify-dual-runtime.ps1`
  - run Claude-side and Codex-side verification workflows
- `regenerate-registries.ps1`
  - derive registry views from framework and component metadata
