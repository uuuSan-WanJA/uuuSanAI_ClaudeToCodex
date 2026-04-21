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

### Portability Risks

- Codex missing equivalent
- environment mismatch
- permission mismatch
- unclear behavior

### Candidate Edit Areas

- files likely to require modification
- files likely to require addition
- files requiring verification only

## Rules

- evidence should point to real files
- the report should be transformer-ready
- avoid full raw dumps when structured findings are enough
