import 'package:fake_async/fake_async.dart';

Future<void> processStreams({FakeAsync? fakeAsync}) async {
  if (fakeAsync != null) {
    fakeAsync.elapse(const Duration(milliseconds: 5));
  } else {
    await Future.delayed(Duration.zero);
  }
}
