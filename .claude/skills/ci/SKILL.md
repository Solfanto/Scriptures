---
name: ci
description: Run the full CI suite locally and fix any failures. Use when the user wants to check code quality, run tests, or validate before committing.
---

Run the full CI suite with `bin/ci` and fix any failures.

The CI pipeline runs these steps in order:
1. Setup (`bin/setup --skip-server`)
2. Style: rubocop
3. Security: bundler-audit, importmap audit, brakeman
4. Tests: Rails tests, system tests, seed validation

If any step fails:
- Fix the issue
- Re-run only the failing step to confirm the fix
- Then re-run the full suite with `bin/ci` to confirm everything passes
