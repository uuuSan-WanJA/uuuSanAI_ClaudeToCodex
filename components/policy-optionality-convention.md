---
solves: []
version: "1.0"
status: active
---

# Policy Optionality Convention

## Summary

Common rule for documenting defaults, options, and risk when policies may vary by project. Adapted from HarnessMaker's `policy-optionality-convention` component.

## Standard Form

When a framework or component has a project-dependent policy decision, document three things:

1. default behavior
2. configurable alternatives
3. risk of changing the default

## Use It For

- rollback behavior
- conflict handling strictness
- scan depth
- verification strictness
- approval thresholds

## Do Not Use It For

- structural invariants whose change would break the component definition
- required fields that make artifacts parseable

## Why It Helps Here

Conversion policy will vary by target project. This convention prevents hidden hard-coded defaults from silently shaping behavior.
