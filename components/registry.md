# Component Registry

Components are fixed reusable specs or artifacts with little internal design space.

| id | name | status | version | solves | summary |
|----|------|--------|---------|--------|---------|
| applied-solutions-manifest | Applied solutions manifest | active | 1.0 | artifact-ownership-tracking | Records which conversion solutions are actually adopted. |
| compatibility-matrix | Compatibility matrix | active | 1.0 | source-project-scan, codex-compat-patching, capability-preflight-gate | Tracks Claude-side surfaces, Codex-side representations, and portability status. |
| source-scan-report | Source scan report | active | 1.0 | source-project-scan | Structured scanner output for a target project. |
| session-handoff-note | Session handoff note | active | 1.0 | session-switch-continuity, dual-runtime-preservation | Durable repo-local note for resuming work cleanly after Claude/Codex session switches. |
| patch-plan | Patch plan | active | 1.0 | codex-compat-patching | Structured list of target-project edits required for Codex compatibility. |
| verification-report | Verification report | active | 1.0 | behavior-equivalence-verification, dual-runtime-preservation | Records proof that important workflows still work after conversion. |
| owner-routing-contract | Owner routing contract | active | 1.0 | mandatory-owner-routing | Binds task kinds to mandatory owners and fallback rules. |
| execution-packet | Execution packet | active | 1.0 | subagent-context-isolation | Compact handoff schema for delegated scan, transform, or verification work. |
| subagent-reporting-protocol | Subagent reporting protocol | active | 1.0 | subagent-report-interpretation | Structured report format for delegated work units. |
| three-tier-blocking | Three-tier blocking | active | 1.0 | action-authorization | Risk-tier model for deciding which conversion actions may run automatically. |
| policy-optionality-convention | Policy optionality convention | active | 1.0 | — | Common rule for documenting defaults, options, and risk when policies may vary by project. |
