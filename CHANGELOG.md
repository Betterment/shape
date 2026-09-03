# Changelog

All notable changes to this project will be documented in this file.

### 0.1.0 - 2026-08-06

- feat: simplify API surface and implementation details
  - remove `FormBody` and `FormErrors` generics
  - add `SimpleFormField<T, E>` alias for `FormField<T, T, E>`
  - add `@FieldRequired()` for optional params that must validate as required
  - support redirecting factories (`factory Foo(...) = _$Foo`) in generator
  - add auto-wrap for plain factory params via `GenericFormField`
  - remove `Equatable` usage in favor of explicit `operator ==` / `hashCode` for bodies and errors
  - improve constructor/field validation diagnostics in generator
- chore: upgrade Dart version constraint and dependencies
- test: update and improve tests

### 0.0.2 - 2023-08-11 (`shape_generator` only)

- chore(shape_generator): relax dependency constraint on `analyzer` to maximize compatibility with Flutter projects ([#10](https://github.com/Betterment/shape/pull/10))

### 0.0.1 - 2023-08-02

- feat: add `shape`, `shape_generator` and `shape_starter_kit` packages (with example project)
