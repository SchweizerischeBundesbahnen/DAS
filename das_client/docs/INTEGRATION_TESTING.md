# Integration Testing

- integration tests live inside `app/integration_test`
- the entry point is `app/integration_test/app_test.dart`
- test bodies MUST contain an id, run the `root` script in the parent directory
  `../scripts/test_title_has_id_no_whitespace.mjs` to add missing ids
- test bodies SHOULD contain the `|tests:< GH ISSUE NUMBER>` field - prompt the user in case not known and desired to
  add
- integration tests mock all remote connections except the connection to the sfera brocker 

