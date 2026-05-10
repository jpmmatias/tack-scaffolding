# Security policy

## Supported versions

This repository ships agent skills and templates (documentation and shell
scripts), not a production service. Security-sensitive fixes apply to the default
branch (`main` / `master`) going forward; there are no versioned release lines
for backport.

## Reporting a vulnerability

**Please do not file public issues for undisclosed security problems.**

Preferred:

1. Open a [GitHub Security Advisory](https://docs.github.com/en/code-security/security-advisories/guidance-on-reporting-and-writing-information-about-vulnerabilities/privately-reporting-a-security-vulnerability)
   for this repository (private submission), **or**
2. Contact the maintainers with enough detail to reproduce the issue (steps,
   affected files, impact).

We aim to acknowledge reports within a few business days and coordinate a fix
and disclosure timeline with you.

## Scope

In scope: vulnerabilities introduced by scripts, templates, or documentation in
this repo that could lead to unsafe execution, credential leakage, or supply-chain
issues for consumers who copy or run them.

Out of scope: general questions, feature requests, and issues in downstream
projects that only consume this template (report those to the respective
project).
