# Coding Guidelines

Coding standards and conventions for the Red project. These rules apply to source code, scripts, tests, tooling, and supporting files unless a more specific project convention overrides them.

## 1. General Principles

* Prefer readable, idiomatic Red over clever or unnecessarily compact code.
* Keep functions and blocks small enough to understand without excessive scrolling.
* Favor simple data transformations and Red's native series/block operations over manual bookkeeping.
* Avoid introducing abstractions until they solve a real, recurring problem.
* Follow existing conventions in the surrounding code before introducing a new pattern.
* Do not optimize prematurely. Prefer correctness and clarity unless performance is an established concern.
* Comments should explain **why**, not simply restate what the code does.

## 2. File Naming

Use lowercase names with hyphens for Red source files.

```text
lexer.red
parser.red
type-checker.red
http-client.red
test-parser.red
```

Use descriptive names that communicate the file's responsibility.

Avoid:

```text
Parser.red
parser_utils.red
misc.red
stuff.red
thing.red
```

Test files should normally use the `test-` prefix:

```text
test-parser.red
test-lexer.red
test-runtime.red
```

## 3. Formatting

### Indentation

* Use **4 spaces** for indentation.
* Do not use tabs.
* Keep indentation consistent within nested blocks.

```red
parse-file: func [file [file!]] [
    data: read file

    if empty? data [
        return none
    ]

    parse-data data
]
```

### Line Length

Prefer lines under **100 characters**.

Long expressions should be broken at logical boundaries rather than arbitrarily.

```red
result: process-data
    input
    options
    context
```

Do not sacrifice readability merely to satisfy the limit.

### Whitespace

Use one space around operators and after commas.

```red
result: value + offset
items: copy [one two three]
```

Avoid unnecessary whitespace:

```red
result:value+offset
```

## 4. Naming

Use lowercase names with hyphens.

```red
source-file
token-type
parse-expression
load-config
```

Do not use snake_case or camelCase for normal Red identifiers.

```red
; Avoid
source_file
tokenType
parseExpression
```

### Constants

Project-wide constants should use descriptive uppercase names when the value is conceptually constant.

```red
MAX-TOKEN-SIZE: 4096
DEFAULT-PORT: 8080
VERSION: "1.0.0"
```

Do not use uppercase merely because a value happens to be assigned once.

### Functions

Function names should describe an action or operation.

```red
parse-token
read-source
emit-code
validate-config
```

Predicates should generally read naturally as questions.

```red
valid-token?
empty-input?
has-errors?
```

## 5. Functions

Prefer explicit argument specifications.

```red
parse-token: func [
    token [string!]
    /local result
][
    ...
]
```

Use type specifications when they communicate an important contract.

Avoid unnecessarily broad or restrictive specifications when the function intentionally accepts multiple Red types.

### Refinements

Use refinements when they represent meaningful variations of an operation.

```red
load-file: func [
    path [file!]
    /binary
][
    either binary [
        read/binary path
    ][
        read path
    ]
]
```

Do not create refinements solely to avoid writing a separate function.

## 6. Blocks and Data

Remember that blocks are both executable code and data in Red.

Prefer direct block operations when they make the intent clearer.

```red
names: ["alice" "bob" "charlie"]
append names "dave"
```

Avoid unnecessary conversions or temporary structures.

```red
; Prefer
foreach item items [
    process item
]

; Over unnecessary manual indexing
repeat index length? items [
    process pick items index
]
```

Use `copy` deliberately when ownership or mutation matters.

```red
result: copy source
append result value
```

Do not assume assignment automatically creates an independent copy of a series.

## 7. Conditionals

Prefer Red's expression-oriented constructs when they improve clarity.

```red
status: either valid? input [
    'valid
][
    'invalid
]
```

Use `unless` when it naturally expresses the condition.

```red
unless connected? socket [
    connect socket
]
```

Avoid deeply nested conditionals. Use early returns or guard conditions when appropriate.

```red
parse: func [input [string!]] [
    if empty? input [
        return none
    ]

    if invalid? input [
        return none
    ]

    parse-valid-input input
]
```

## 8. Errors and Failure Handling

Do not silently ignore errors.

Failures should either:

* be propagated,
* be explicitly handled,
* or be intentionally converted into a documented fallback.

Use `try`, `attempt`, or explicit error handling according to the semantics required by the operation.

Do not use `attempt` merely to suppress errors you have not considered.

```red
result: try [
    read file
]

if error? result [
    print rejoin ["Unable to read " file]
]
```

For library code, avoid printing errors directly unless logging/output is explicitly part of the API.

## 9. Type Handling

Use Red's type system instead of relying on implicit assumptions.

Prefer:

```red
if string? value [
    process-string value
]
```

over fragile assumptions about the value's type.

When multiple types are intentionally supported, make that behavior explicit in the function contract and implementation.

## 10. Parsing and Evaluation

Code that parses, evaluates, compiles, or transforms Red values must clearly distinguish between:

* source text,
* Red values,
* blocks representing code,
* and evaluated results.

Do not evaluate arbitrary input merely to inspect its structure.

Prefer structural operations such as `load`, `parse`, `find`, `select`, and series traversal where appropriate.

Any use of `do`, `reduce`, or other evaluation mechanisms on external/untrusted input must be treated as a security-sensitive operation.

## 11. Mutability

Be deliberate about mutation.

Prefer local mutation when it makes an algorithm simpler, but avoid unexpectedly modifying values supplied by callers.

```red
normalize: func [items [block!]] [
    result: copy items

    ; mutate result, not caller-owned data
    ...
    
    result
]
```

Document functions that intentionally mutate caller-provided series.

## 12. Comments and Documentation

Comments should explain intent, constraints, or non-obvious behavior.

Good:

```red
; Keep the original block intact because callers may reuse it.
tokens: copy input
```

Bad:

```red
; Copy the input
tokens: copy input
```

Public APIs should have documentation describing:

* what the function does,
* accepted argument types,
* refinements,
* return values,
* side effects,
* and important failure conditions.

## 13. Modules and Imports

Keep imports/directives organized and minimal.

Remove unused dependencies.

Avoid importing an entire subsystem when only a small, independent component is required.

Keep module dependencies directional and avoid unnecessary circular dependencies.

## 14. Tests

Tests should be deterministic and independent of execution order.

Test normal behavior as well as:

* empty input,
* invalid input,
* boundary values,
* unexpected types,
* failure paths,
* and regression cases.

Name tests after the behavior they verify.

```red
test-empty-input: func [] [
    ...
]

test-invalid-token: func [] [
    ...
]
```

A bug fix should generally include a regression test when practical.

## 15. Source Layout

Prefer organizing source code by responsibility.

Example:

```text
src/
    lexer.red
    parser.red
    evaluator.red
    runtime.red
    errors.red

tests/
    test-lexer.red
    test-parser.red
    test-evaluator.red
    test-runtime.red

scripts/
    build.red
    test.red
```

Avoid large miscellaneous files containing unrelated functionality.

## 16. CLI and User-Facing Output

Command-line output should be concise and predictable.

Use consistent wording for errors, warnings, and status messages.

Errors should provide enough context to identify the operation that failed.

```text
error: unable to parse source file: example.red
```

Do not include internal implementation details in user-facing errors unless they are useful for diagnosing the problem.

## 17. Performance

Red's series and value semantics should be considered when writing performance-sensitive code.

Avoid unnecessary:

* copying,
* repeated conversions,
* parsing,
* allocations,
* and traversal of the same series.

However, do not replace clear code with obscure micro-optimizations without evidence that performance matters.

For performance-critical code, document the reason for the non-obvious implementation.

## 18. Security

Treat external input as untrusted.

This includes:

* files,
* command-line arguments,
* network data,
* environment variables,
* configuration files,
* and dynamically supplied Red code.

Never execute untrusted input with evaluation primitives without an explicit security boundary.

Avoid embedding credentials, API keys, private keys, or other secrets in source code.

## 19. Git and Changes

Keep commits focused.

A commit should generally represent one logical change.

Avoid mixing:

* formatting-only changes,
* unrelated refactors,
* dependency upgrades,
* and functional changes

in the same commit unless there is a good reason.

Do not commit generated files unless they are explicitly tracked by the project.

## 20. Pull Requests

Pull requests should:

* describe the problem being solved,
* explain the implementation at a high level,
* include relevant tests,
* mention compatibility concerns,
* and call out breaking changes.

New public APIs should include documentation and tests.

Reviewers should prioritize correctness, maintainability, security, and compatibility over personal stylistic preferences.

## 21. Rule of Thumb

When a rule conflicts with readability, correctness, or idiomatic Red, prefer the implementation that is easiest for another Red developer to understand and maintain.

**Readable Red is better than clever Red.**
