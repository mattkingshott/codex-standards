---
name: create-playwright-test
description: Write or update Playwright tests using the project's strict test structure, local helpers, route fakes, request assertions, and formatting conventions. Only use it when the application is a Nuxt SPA.
---

# Create Playwright Test

Use this skill when creating or updating Playwright tests in this repository.

## Workflow

1. Read `testing/support/test.js` and `testing/support/selectors.js` before relying on helpers.
2. Read relevant existing tests in `testing/tests/**` for nearby domain conventions.
3. Implement the test using the current local helpers instead of raw Playwright request plumbing.
4. Verify with `npm run tests -- --list`; run a targeted Playwright test when practical.

## Required Style

- Use multi-line docblocks for `Dependencies.` and `Test.`.
- Keep each `test(...)` opening brace on its own line.
- Use route helpers from `testing/support/test.js`.
- Organize each test in this order: setup data, fake/intercept network, then workflow.
- In workflow, call `await start(page, user)` or `await start(page)` before browser navigation.
- Use `fake(page, method, route(...), body?, status?, headers?)` for mocked responses.
- Use `page.waitFor({ method, url, body?, trigger })` for request assertions and triggering actions.
- Use `button(page, id)`, `menu(page, id, link)`, and `findByDataId(page, id)` instead of repeated selector strings when possible.
- Extract multi-key (3 or more) request bodies into `const payload = { ... }`; keep "1 key" and "2 key" bodies inline.

## References

For examples and exact patterns, read `references/examples.md`.
