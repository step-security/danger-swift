[![StepSecurity Maintained Action](https://raw.githubusercontent.com/step-security/maintained-actions-assets/main/assets/maintained-action-banner.png)](https://docs.stepsecurity.io/actions/stepsecurity-maintained-actions)

<p align="center">
<img src="https://danger.systems/images/js/danger-js-sw-logo-hero-cachable@2x.png" width=350 /></br>
Formalize your Pull Request etiquette.
</p>

Write your Dangerfiles in Swift.

### Requirements

Latest version requires Swift 5.8

If you are using an older Swift, use the supported version according to next table.

| Swift version | Danger support version |
| ------------- | ---------------------- |
| 5.5-5.7       | v3.18.1                |
| 5.4           | v3.15.0                |
| 5.3           | v3.13.0                |
| 5.2           | v3.11.1                |
| 5.1           | v3.8.0                 |
| 4.2           | v2.0.7                 |
| 4.1           | v0.4.1                 |
| 4.0           | v0.3.6                 |

### What it looks like today

You can make a Dangerfile that looks through PR metadata, it's fully typed.

```swift
import Danger

let danger = Danger()
let allSourceFiles = danger.git.modifiedFiles + danger.git.createdFiles

let changelogChanged = allSourceFiles.contains("CHANGELOG.md")
let sourceChanges = allSourceFiles.first(where: { $0.hasPrefix("Sources") })

if !changelogChanged && sourceChanges != nil {
  warn("No CHANGELOG entry added.")
}

// You can use these functions to send feedback:
message("Highlight something in the table")
warn("Something pretty bad, but not important enough to fail the build")
fail("Something that must be changed")

markdown("Free-form markdown that goes under the table, so you can do whatever.")
```

### GitHub Actions

Add `step-security/danger-swift` to your workflow:

```yml
jobs:
  build:
    runs-on: ubuntu-latest
    name: "Run Danger"
    steps:
      - uses: actions/checkout@v4
      - name: Danger
        uses: step-security/danger-swift@v3
        with:
            args: --failOnErrors --no-publish-check
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### Pre-built Docker images

Two pre-built images are available:
- https://github.com/orgs/step-security/packages/container/package/danger-swift
- https://github.com/orgs/step-security/packages/container/package/danger-swift-with-swiftlint (Danger + Swiftlint)

To use one directly with the `docker://` prefix:

```yml
jobs:
  build:
    runs-on: ubuntu-latest
    name: "Run Danger"
    steps:
      - uses: actions/checkout@v4
      - name: Danger
        uses: docker://ghcr.io/step-security/danger-swift:3.15.0
        with:
            args: --failOnErrors --no-publish-check
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```
