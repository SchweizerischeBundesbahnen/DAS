import 'package:flutter_test/flutter_test.dart';
import 'package:preload/component.dart';

void main() {
  final files = <S3File>[
    S3File(name: 'a.txt', eTag: '1', size: 10, status: .initial),
    S3File(name: 'b.txt', eTag: '2', size: 20, status: .downloaded),
    S3File(name: 'c.txt', eTag: '3', size: 30, status: .error),
    S3File(name: 'd.txt', eTag: '4', size: 40, status: .downloaded),
    S3File(name: 'e.txt', eTag: '5', size: 50, status: .error),
    S3File(name: 'f.txt', eTag: '6', size: 60, status: .error),
  ];

  test('whereStatus_whenCalled_thenReturnsCorrectList', () {
    expect(files.whereStatus(.initial).length, 1);
    expect(files.whereStatus(.downloaded).length, 2);
    expect(files.whereStatus(.error).length, 3);
    expect(files.whereStatus(.corrupted), isEmpty);
  });
}
