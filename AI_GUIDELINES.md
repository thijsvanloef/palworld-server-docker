# AI Usage Guidelines for Contributors

I welcome contributions to **palworld-server-docker**! Whether you are fixing bugs, adding support for new Palworld server features, or improving documentation, we appreciate your time and effort. 

I recognize that AI coding assistants (such as GitHub Copilot, ChatGPT, Claude, Cursor, etc.) are helpful tools for modern development and I encourage their use. However, **AI models often lack the broader architectural context**, which can lead to redundant code, broken integrations between Docker and internal scripts, and deviations from our quality standards.

If you use AI tools to assist in writing your pull request (PR), you must adhere to the following guidelines.

## **Respect Multi-Host & Multi-Architecture Reality**

This container is run across a massive variety of hosts, configurations, and CPU architectures in the wild. A sample of supported environments includes:

* **Linux** (Ubuntu / Debian)
* **Windows** 10, 11
* **macOS** (including Apple Silicon M1 / M2 / M3 / M4 / M5 chips)
* **Raspberry Pi** 4 / 5
* **CPU Architectures:** Both x64 and ARM64

AI tools frequently suggest platform-specific commands (e.g., GNU-only flags, x86-only binaries, or Linux-specific pathing) that will silently break on other systems. You must ensure any generated bash scripts, Docker commands, or file interactions are fully cross-platform and tested against ARM64/x64 compatibility (Github Actions will verify this).

## **Technical & Code Quality Standards**

All PRs—whether written by humans or AI—must pass our automated CI/CD checks and adhere to our strict repository standards:

### **Shell Scripting (`scripts/`)**

* **ShellCheck Compliance:** All bash/sh scripts must pass linting defined in our `.shellcheckrc`. AI often writes non-compliant bash (e.g., unquoted variables, ignoring exit codes).
* **Permission Awareness:** Keep in mind that users may run this container as root or as a non-root user (`PUID`/`PGID` overrides). AI-generated script modifications must not break non-root execution permissions or assume default root ownership.

### **Environment Variables & Configuration**

If your PR introduces or modifies an environment variable (e.g., adding a new server startup argument or feature flag), AI tools almost always forget to wire it across the full stack. You must manually ensure:
1. The variable is properly ingested in the startup scripts (`scripts/`).
2. It is added with sensible defaults to `.env.example`.
3. It is documented in the **Environment Variables** table in `README.md` (including Default Value, Allowed Values, and Version Added).
4. It is documented in the **Environment Variables** table in `docs/` (including Default Value, Allowed Values, and Version Added).
5. It is added to the scripts that generate the .ini file for the Palworld server (`scripts/compile-settings.sh`).
6. If a new setting is added to the .ini file, it also needs to be added to the PalWorldSettings.ini.template.
7. It is compatible with existing Kubernetes setups (`kubernetes/`) and Docker Compose examples (`compose.yaml`).

## **No "Drive-By" AI Refactoring**

Please do not open PRs that consist solely of AI-generated refactorings, style tweaks, or code reformatting on working scripts unless tied to an active, documented bug or performance issue.
Also please do not alter code or scripts that are not directly related to your PR's purpose. This includes:

* Changing variable names, function names, or file names
* Reformatting code or scripts (e.g., changing indentation, line breaks, or spacing)
* Rewriting code or scripts for style or personal preference

## **PR Disclosure**

If a significant portion of your PR was generated or refactored using an AI tool, please include a brief disclosure in your Pull Request description.
