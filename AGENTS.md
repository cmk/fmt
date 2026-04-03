# fmt

Multi-package Haskell repo for type-safe formatting.

## Packages

- **stringfmt** — Core formatting library: type-safe formatting as an indexed
  continuation profunctor, with pretty-printing via Church-encoded fixed points.
- **logfmt** — Fast-logger bridge: `LogStr`-specialized formatting built on stringfmt.
- **vtyfmt** — ANSI terminal formatting via stringfmt + vty color types.

## Project structure

```
cabal.project                — Multi-package build config
scheme-extensions/           — Git submodule (dependency, not on Hackage)
.github/workflows/ci.yml    — CI: build matrix + haddock deploy

stringfmt/
  src/Data/Fmt.hs            — Core Fmt type, combinators, generic formatters
  src/Data/Fmt/Fixed.hs      — Fix type, generic recursion schemes
  src/Data/Fmt/Functor.hs    — FmtF pattern functor, Tree type alias, instances
  src/Data/Fmt/Tree.hs       — Pretty-printer API: smart constructors, combinators
  src/Data/Fmt/String.hs     — ShowS-backed Builder newtype, StringFmt alias
  src/Data/Fmt/Text.hs       — Text-backed formatting
  src/Data/Fmt/ByteString.hs — ByteString-backed formatting
  src/Data/Fmt/Kan.hs        — Kan extension machinery
  src/Data/Fmt/Cons.hs       — Cons/stream infrastructure
  src/Data/Fmt/Code.hs       — Code formatting combinators
  src/Data/Fmt/Type.hs       — Type-level machinery
  test/                      — Hedgehog property tests
  doc/design.md              — Architectural design document
  doc/plans/                 — Sprint plans (sprint-N.md)
  doc/plans/todo.md          — Backlog / future work
  doc/notes/                 — Dated development notes (notes-YYYY-MM-DD.md)

logfmt/
  src/Data/Fmt/Log.hs        — LogStr formatting bridge

vtyfmt/
  src/Data/Fmt/ANSI.hs       — ANSI escape code combinators
  src/Data/Fmt/ANSI/Code.hs  — SGR code definitions
  src/Data/Fmt/ANSI/Type.hs  — ANSI formatting types
```

## Development workflow

### Sprint planning

Sprints live in `stringfmt/doc/plans/sprint-N.md` following cirklon conventions:
- Story IDs: `SN.M` (e.g. `S1.1`, `S2.3`)
- Hedgehog properties numbered globally: `P1`, `P2`, ...
- Sections: Scope, Rationale, Stories (table), New types,
  Hedgehog properties (table), Work order (TDD), Deferred,
  Open questions

### TDD work order

1. Write property skeletons (`property $ failure`) — all red
2. Define Hedgehog generators
3. Implement code to green properties one at a time
4. Commit only when all properties pass

### Notes

When asked to "print to notes", append a new section to
`doc/notes/notes-YYYY-MM-DD.md` (create if needed).

## Key design decisions

- `Fix` (Church-encoded, called `Mu` in literature) is parametric
  over any base functor, not specialized to `FmtF`
- No `Recursive`/`Corecursive` typeclasses — explicit schemes only
- Recursion schemes use concrete names: `fold`, `unfold`, `refold`,
  `wrap`, `unwrap`, `hoist`, `foldWithContext`, `foldWithAux`,
  `unfoldShort`
- `FmtF m ann r` is parametric over content type `m`
- Naming: `StringFmt`/`TextFmt`/`ByteFmt` for `Fmt` specializations,
  `Builder` for underlying newtype wrappers

## Dependencies

- `scheme-extensions` — git submodule (cmk/scheme-extensions)
- `profunctors`, `kan-extensions`, `data-fix`
- `bytestring`, `text`, `transformers`
- `fast-logger` (logfmt)
- `vty` (vtyfmt)
- `hedgehog` (test)
