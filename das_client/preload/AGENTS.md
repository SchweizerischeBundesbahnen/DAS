# preload – Agent Guide

Downloads journey-data ZIP bundles from AWS S3 ahead of time so a journey is available offline, unzips them, and feeds
the result into `sfera`'s local repository. Uses AWS credentials distributed via `settings`.

