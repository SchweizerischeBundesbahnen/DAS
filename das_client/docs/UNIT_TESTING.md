# Unit Testing

- Use GIVEN/WHEN/THEN structure inside each test body.
- Name tests `methodName_whenX_thenY`.
- Use `fake_async` for anything time-based or debounced (timers, `Stream.debounceTime`, etc.) instead of real
  `Future.delayed`/waiting.
- Mock with `mockito` where a package already depends on it.

Run tests:

```sh
fvm dart run melos test                      # every package with a test/ dir
cd <package> && fvm flutter test --no-pub    # a single package
```
