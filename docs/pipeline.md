# Conversion Pipeline

## Purpose

The repository should operate like a conversion engine for target projects.

## Stages

### 1. Scan

Input:
- target project path

Output:
- source scan report
- first-pass compatibility matrix

Large scans may use `frameworks/dynamic-orchestration/definition.md`.

### 2. Plan

Input:
- scan report
- compatibility matrix

Output:
- patch plan

### 3. Transform

Input:
- patch plan

Output:
- target-project file edits

### 4. Verify

Input:
- edited target project

Output:
- verification report

Large verification runs may use `frameworks/dynamic-orchestration/definition.md`.

## Success Standard

A project is only considered converted when:

1. the required edits were applied
2. the Claude-side path is still acceptable
3. the Codex-side path is now acceptable
4. evidence is recorded in a verification report
