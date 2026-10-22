<div align="center">

<img src="https://codeberg.org/sharkaccino/vincent/raw/branch/main/resources/vincent/icon.png" height="150px">

# Vincent

### A simple, modern, cross-platform image editor.

[![License: GPLv3](https://img.shields.io/badge/license-GPLv3-blue)](LICENSE) [![Issues](https://codeberg.org/sharkaccino/vincent/badges/issues/open.svg)](../../../issues) [![Releases](https://codeberg.org/sharkaccino/vincent/badges/release.svg)](../../../releases)

[![Bluesky](https://img.shields.io/badge/Bluesky-ffffff?logo=bluesky)](https://bsky.app/profile/vincentproject.bsky.social)

</div>

## Development Status

**This project is a work-in-progress.** Many features WILL be bugged, or outright non-functional at this point in development. **You have been warned!**

[![Snapshot Builds](https://img.shields.io/badge/download%20snapshot%20builds-orange)](../../../actions?workflow=dist-snapshot.yml)

<!-- 🔴🔵🟡🟢  -->

| Feature | Status |
| :-- | :--- |
| Basic canvas controls | 🟢 |
| Basic brush and eraser tools | 🟢 |
| Basic selection tools | 🔴 |
| Basic flood tools | 🔴 |
| Basic configuration/options menu | 🔵 |
| Sidebars and UI panels | 🔵 |
| Multi-project state management | 🟢 |
| Image layers | 🟡 |
| Layer effects | 🔴 |
| Edit history (undo/redo) | 🔴 |
| Save/load project files | 🟡\* |
| Plug-in Support | 🔵\*\* |

- 🔴 = Not started
- 🔵 = In progress
- 🟡 = On hold
- 🟢 = Complete

\*basic images can be loaded and saved, but no options for quality, bit depth, etc are presented.

\*\*mostly already functional, just missing some compatibility checks and documentation.

## Bug Reports & Code Contributions

If you're here to submit a bug report, please use the [issues page](../../../issues). Before opening a new issue, **please take the time to search for your issue to make sure nobody else has reported it already.** Help us reduce duplicates!

For those who would like to contribute more directly, check out the [contributing guidelines](CONTRIBUTING.md).

## License
Vincent is a [GPLv3 licensed](LICENSE) open-source project, with the following exceptions:

### `/resources/vincent`
Vincent's branding assets and logos are NOT free to use, and are included for reference only.

### `/resources/fonts`
Included fonts have their own licenses, which you can find in their respective directories.

### `/resources/icons`
Vincent uses [Tabler icons](https://tabler.io/icons), which are [MIT licensed.](/resources/icons/LICENSE)