## Release Process

The releases will be done through [Release Please]. This project uses the [Github Action version].

For triggering subsequent workflows, we use the **SBB-DAS** Github App with a private key stored in the
Github Actions secrets.

All configuration files for [Release Please] are found in the `./ci` directory.

Version is given in [release-please-manifest](./ci/.release-please-manifest.json), s. [CONTRIBUTING.md](CONTRIBUTING.md) for feature conventional commit.

### DAS Client

The release please PRs will carry the additional label `autorelease:das_client`. 
Merging this PR will trigger two workflows:

* [client_release_android](./.github/workflows/client_release_android.yml)
  * build all flavors on Android and release to Google Play Store
* [client_release_ios](./.github/workflows/client_release_ios.yml)
  * build all flavors on iOS and release to Testflight


[Release Please]: https://github.com/googleapis/release-please
[Github Action version]: https://github.com/googleapis/release-please-action