# Code Style Guide - Vue Rules

All generated Vue code must match these patterns to ensure consistency and maintainability.

---

## General
- When creating new files and components, always use the Composition API.
- When changing existing files, adopt the API currently in use e.g. Options.

## Properties & Attributes
- Use full vue syntax e.g. `v-bind:class` not `:class`
- Order attributes by line length, first attribute on same line as element, subsequent attributes on separate lines, last attribute ends with '>', e.g.
```html
<Portal class="max-w-800px"
        heading="Page Title"
        v-bind:title="`Page Title - ${organization.name}`">
```

## Spacing
- Empty line between template sections
- No empty lines within tag attributes
- Single space around mustaches: `{{ var }}`

## Structure
- State properties before methods
- Prefer component `state()` for local reactive values; use `computed` only when Vue's computed behavior is required (automatic derivation from dependencies, caching, or getter/setter semantics).

## Template Logic
- Keep simple logic inline within the template when it can be expressed as a single readable expression, such as conditionals, boolean checks, simple formatting, or straightforward bindings.
- Create a method only when multiple statements need to run, the logic is significantly reused, or the inline expression would make the template difficult to scan.
