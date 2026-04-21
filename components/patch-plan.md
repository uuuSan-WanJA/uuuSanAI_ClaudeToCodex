---
solves:
  - codex-compat-patching
version: "1.0"
status: active
---

# Patch Plan

## Summary

Specification for the structured edit plan used before or during target-project modification.

## Required Fields Per Patch Item

- issue id
- source evidence
- target file path
- patch type
- risk tier
- intended Codex effect
- Claude-side safety note
- verification step

## Patch Types

- direct rewrite
- additive compatibility file
- runtime split
- command replacement
- documentation update

## Rules

- every patch item must map back to scan evidence
- every patch item must explain why Claude behavior is preserved
- every patch item must have a verification hook
