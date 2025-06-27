# DAS Client Coding Standards

This application uses the code style defined in
the [Flutter Wiki](https://github.com/flutter/flutter/blob/master/docs/contributing/Style-guide-for-Flutter-repo.md).
The recommendations are mandatory and should always be followed unless there is a good reason not to do so. However,
this must be approved by all developers.

## Coding Style

We prefer to use the following coding style principles:

* Define private methods (e.g., `_header()`) inside widgets instead of creating separate private widget classes (e.g., `_Header()`) in the same file.
* We create public widgets if they are used in multiple places across the application or if readability (ex. Widget to big) is improved over private methods.
* We prefer using `_widget` as a naming convention instead of prefixing with build (e.g., `_buildWidget`).

## Formatting

Notable difference: Line length is set to 120 characters. Please adapt your IDE configuration accordingly.
For formatting XML test files, contact a developer for custom Android Studio XML formatting setup.