**Build System Agent Instructions**

**Overview:**
- **Purpose:** Concise, reproducible instructions for agents and contributors to build the Redlinks executable and understand the repository's build system.
- **Primary artifacts:** the build orchestrator [build.red](build.red#L1-L200), the PowerShell helper [helper/build-helper.ps1](helper/build-helper.ps1#L1-L200), and the compiler input [redlinks.red](redlinks.red#L1-L200).

**Prerequisites:**
- **`redc` (Red compiler):** Install the Red toolchain and ensure `redc` is on your `PATH` (Windows: place `redc.exe` in a folder on `PATH`).
- **PowerShell (Windows):** Required to run `helper/build-helper.ps1` and the helper called by `build.red`.
- **Working directory:** Run commands from the repository root (where [build.red](build.red#L1-L200) lives).

**Quick build (recommended, reproducible):**
- **Direct compile (same as CI):**

```
redc -c redlinks.red
```

- After the command completes, the produced artifact is `redlinks.exe` in the repo root (see [appveyor.yml](appveyor.yml#L1-L40) for the CI artifact definition).

**Build via helper script (explicit, mirrors `build.red` internal step):**
- The included helper is `helper/build-helper.ps1`. It wraps the `redc` invocation and is called by the Red orchestrator.
- Example (PowerShell):

```
powershell -ExecutionPolicy Bypass -File helper/build-helper.ps1 redlinks.red bin/redlinks.exe
```

- Confirm output: `bin\\redlinks.exe` should exist after the helper finishes.

**Using the Red orchestrator (`build.red`):**
- `build.red` is a Red script that sets `output` and invokes `helper/build-helper.ps1` to perform compilation. If you prefer the orchestrated flow, execute the script with your Red runtime. Two safe approaches:
  - Run the helper directly (recommended) as shown above.
  - Or run the Red script using your installed Red runtime. If your installation exposes a `red` or `redc` runner that can execute scripts, invoke that runner with `build.red` as the entrypoint.

**.buildignore and ignored files:**
- The file [%.buildignore](.buildignore#L1-L10) lists repository files the build orchestrator will ignore. By default `.buildignore` in this repo includes `build.red` so the build script itself won't be treated as an input to compilation.

**CI notes:**
- AppVeyor builds the project using the Red toolchain and compiles `redlinks.red` directly (see [appveyor.yml](appveyor.yml#L1-L40)). The CI run downloads a Windows Red toolchain and runs `redc.exe -c redlinks.red`.
- The CI artifact name is defined in `appveyor.yml` and matches the produced `redlinks.exe` binary.

**Troubleshooting:**
- `redc` not found: ensure the Red toolchain is installed and `redc`/`redc.exe` is on your `PATH`. On Windows you can download the toolchain from the Red project site and place `redc.exe` alongside your build tools.
- Permission / ExecutionPolicy errors when running `build-helper.ps1`: run PowerShell as Administrator or use `-ExecutionPolicy Bypass` as shown above.
- Output file not created: check the helper invocation and ensure `redc` exit code is zero. The helper script returns the compiler's exit code on failure.

**What agents should do (concrete checklist):**
- **Verify prerequisites:** check `redc` in `PATH` and PowerShell availability.
- **Run direct compile:** `redc -c redlinks.red` and validate `redlinks.exe` exists.
- **If using orchestrator:** run the helper or the `build.red` script and confirm `bin/redlinks.exe` or configured `output` exists.
- **Inspect CI config:** consult [appveyor.yml](appveyor.yml#L1-L40) for reproducing CI steps locally.

**Maintainer tips:**
- Keep `output` in [build.red](build.red#L1-L20) in sync with release packaging and installer scripts.
- Add important build inputs to `.buildignore` only when you intentionally want the build system to skip them.

**Contact / Links:**
- See repository README for higher-level project info.

---

This document is intended to be a minimal, reproducible guide agents and contributors can follow to build the project locally and mirror CI behavior.
