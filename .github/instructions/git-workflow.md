# Git & Workflow Standards

## 1. Branching

All development work must be performed on a dedicated branch. Do not commit directly to `main`.

### Branch Naming

Use the following format:

```text
<type>/<short-description>
```

Supported branch types:

| Type        | Purpose                                     |
| ----------- | ------------------------------------------- |
| `feature/`  | New functionality                           |
| `fix/`      | Bug fixes                                   |
| `refactor/` | Code restructuring without behavior changes |
| `perf/`     | Performance improvements                    |
| `docs/`     | Documentation-only changes                  |
| `test/`     | Adding or modifying tests                   |
| `build/`    | Build system/toolchain changes              |
| `ci/`       | CI/CD changes                               |
| `chore/`    | Maintenance work                            |
| `release/`  | Release preparation                         |
| `hotfix/`   | Critical fixes requiring expedited review   |

Examples:

```text
feature/parser-error-recovery
fix/string-buffer-overflow
refactor/runtime-dispatch
perf/lexer-tokenization
docs/compiler-internals
test/lexer-regressions
build/update-toolchain
ci/github-actions
```

Use lowercase names and hyphens. Keep branch names short and descriptive.

Avoid:

```text
my-branch
test
stuff
valerie-changes
fix-final-final
feature/THIS_IS_A_LONG_BRANCH_NAME
```

---

## 2. Main Branch

`main` represents the latest stable and review-approved state of the project.

Rules:

* Never push directly to `main`.
* All changes must go through a Pull Request.
* CI checks must pass before merging.
* Changes should receive appropriate review before merging.
* Do not merge known-broken compiler, runtime, or build-system changes.
* Keep `main` buildable whenever reasonably possible.

For release branches, use the project's release process rather than treating `main` as a temporary development branch.

---

## 3. Commits

Commits must use a concise, imperative format:

```text
<type>(<scope>): <description>
```

Examples:

```text
feat(parser): add hexadecimal literal support
fix(runtime): prevent invalid series access
refactor(lexer): simplify token dispatch
perf/evaluator: reduce allocation during evaluation
docs/compiler: document lexer architecture
test(parser): add malformed literal cases
build(toolchain): update Red compiler bootstrap
```

### Commit Types

| Type       | Meaning                    |
| ---------- | -------------------------- |
| `feat`     | New functionality          |
| `fix`      | Bug fix                    |
| `refactor` | Internal restructuring     |
| `perf`     | Performance improvement    |
| `docs`     | Documentation              |
| `test`     | Tests                      |
| `build`    | Build/toolchain changes    |
| `ci`       | CI changes                 |
| `chore`    | Maintenance                |
| `release`  | Release/versioning changes |

### Commit Rules

* Use the imperative mood: `add`, `fix`, `remove`, `update`.
* Keep the subject concise, preferably under 72 characters.
* Do not end the subject with a period.
* Explain non-obvious reasoning in the commit body.
* Avoid combining unrelated changes into one commit.
* Do not use meaningless messages such as `stuff`, `changes`, `fix`, or `WIP`.
* Do not commit generated artifacts unless the repository explicitly requires them.

Good:

```text
fix(parser): reject unterminated strings

The lexer previously consumed the remainder of the input when a
closing quote was missing. Stop lexing and emit the appropriate
syntax error instead.
```

Bad:

```text
fixed parser stuff
```

---

## 4. Red-Specific Commit Scopes

When practical, use scopes corresponding to the affected subsystem.

Common scopes include:

```text
lexer
parser
compiler
runtime
interpreter
evaluator
types
series
string
unicode
io
network
ffi
gc
memory
modules
loader
rebol
red
red-system
tests
docs
toolchain
bootstrap
build
ci
```

Use the smallest meaningful scope rather than forcing every commit into a generic scope.

For example:

```text
fix(lexer): correctly tokenize escaped quotes
fix(series): preserve index after insertion
feat(compiler): add constant folding for integers
fix(runtime): handle null series references
test(parser): cover nested block expressions
```

---

## 5. Pull Requests

Every Pull Request must:

* Have a clear title following the commit convention.
* Explain what changed and why.
* Identify relevant tests.
* Mention breaking changes explicitly.
* Keep unrelated changes out of the PR.
* Pass all required CI checks.
* Be reviewable without requiring undocumented local setup.

PR titles should follow:

```text
<type>(<scope>): <description>
```

Example:

```text
feat(parser): support additional literal forms
```

### PR Description

Use the following structure when appropriate:

```markdown
## Summary

- What changed?
- Why was it needed?

## Testing

- What was tested?
- Which test suites were run?

## Breaking Changes

- None
```

For compiler, parser, runtime, or language-semantics changes, include examples when they make the behavioral change easier to understand.

---

## 6. Code Review

Reviewers should prioritize:

1. Correctness
2. Language/runtime semantics
3. Memory safety
4. Compatibility
5. Performance
6. Maintainability
7. Style

For compiler and runtime changes, reviewers should pay particular attention to:

* Memory ownership and lifetime.
* Bounds checking.
* Invalid or malformed input.
* Parser/lexer state transitions.
* Error propagation.
* ABI/FFI compatibility.
* Platform-specific behavior.
* Changes to language semantics.
* Unintended performance regressions.
* Compatibility with existing Red/Rebol behavior.

Do not approve code solely because it compiles.

---

## 7. Rebasing and Merging

Branches should be kept reasonably up to date with `main`.

Before merging:

```text
feature branch
      ↓
update/rebase
      ↓
run tests
      ↓
Pull Request
      ↓
review + CI
      ↓
main
```

Prefer a clean project history. Squash commits when a branch contains numerous temporary or fixup commits and the project's merge policy permits it.

Do not rewrite shared branches that other contributors are actively using without coordination.

---

## 8. Fixup and Work-in-Progress Commits

During local development, temporary commits are acceptable:

```text
WIP: parser changes
fixup! feat(parser): add literal support
```

However, these should not normally remain in the final merged history.

Before merging, clean up temporary commits when appropriate.

---

## 9. Generated Files

Do not commit generated files, compiler outputs, temporary files, IDE metadata, or local build artifacts unless they are explicitly maintained as part of the repository.

Examples of files that generally should not be committed:

```text
*.o
*.obj
*.exe
*.dll
*.so
*.dylib
build/
dist/
tmp/
```

Repository-specific generated artifacts may be committed when required by the project's build or release process.

---

## 10. Language Semantics Changes

Changes that modify Red language behavior require additional care.

A change affecting:

* Syntax
* Evaluation rules
* Datatypes
* Functions
* Error behavior
* Type coercion
* Series semantics
* Evaluation order
* Module behavior
* Compatibility with Rebol/Red

must include appropriate regression tests.

If the behavior is intentionally incompatible with previous behavior, the Pull Request must explicitly document the compatibility impact.

---

## 11. Tests

Bug fixes should include a regression test whenever practical.

New functionality should include tests covering:

* Normal behavior.
* Boundary conditions.
* Invalid input.
* Error handling.
* Relevant platform-specific behavior.

A compiler/runtime change that cannot reasonably be tested should explain why in the Pull Request.

---

## 12. Releases

Release-related changes must not be mixed casually with unrelated development work.

Release commits should clearly identify the version:

```text
release: prepare Red 0.x.y
```

or:

```text
release(red): prepare 0.x.y
```

Version changes, changelogs, release notes, and generated release artifacts must follow the project's established release procedure.

---

## 13. Security-Sensitive Changes

Security fixes should avoid exposing vulnerability details in public commit messages or Pull Requests until disclosure is appropriate.

Do not commit:

* Credentials
* API keys
* Private certificates
* Access tokens
* Personal secrets
* Production configuration containing sensitive information

If a secret is accidentally committed, removing the file from the latest commit is not sufficient. Treat the secret as compromised and rotate it.

---

## 14. General Rules

The repository should maintain a history that is:

* Understandable
* Searchable
* Bisectable
* Revertible
* Reproducible

When choosing between a clever Git workflow and a boring predictable one, prefer the boring predictable one.

**Small, focused commits. Clear branches. Tested changes. Review before merge.**
