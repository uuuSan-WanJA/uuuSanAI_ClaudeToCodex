---
solves:
  - source-project-scan
version: "1.0"
status: active
---

# Source Scan Report

## Summary

Specification for a structured report produced by the scanner for a target Claude Code project.

## Required Sections

### Target Summary

- project path
- project type
- operating system assumptions
- shell assumptions

### Claude Surfaces

- root policy file
- `.claude/settings*.json`
- hooks
- agents
- skills
- wrapper scripts

### Continuity Surfaces

- repo-root Codex guide when present
- runtime launchers or documented substitutes
- session handoff artifacts when present

### Portability Risks

- Codex missing equivalent
- environment mismatch
- permission mismatch
- unclear behavior
- descriptive role docs without a binding owner contract
- missing delegation fallback or guard rules for owner-bound work

### Candidate Edit Areas

- files likely to require modification
- files likely to require addition
- files requiring verification only

## Rules

- evidence should point to real files
- the report should be transformer-ready
- avoid full raw dumps when structured findings are enough
- continuity surfaces should be captured as evidence, not assumed correct by default
- when role or agent docs exist, state whether binding owner routing was detected or whether those docs are only descriptive
