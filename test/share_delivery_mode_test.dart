import 'package:flutter_test/flutter_test.dart';
import 'package:jospar/core/services/share_delivery_mode.dart';

void main() {
  test('extracts hash from current short HTTPS link', () {
    expect(
      extractShareHash(Uri.parse('https://jospar.kz/s/hash-1')),
      'hash-1',
    );
  });

  test('extracts hash from custom deep link and ignores its mode', () {
    expect(
      extractShareHash(
        Uri.parse('jospar://share?hash=hash-2&mode=duplicate'),
      ),
      'hash-2',
    );
  });

  test('supports legacy HTTPS link for backwards compatibility', () {
    expect(
      extractShareHash(
        Uri.parse('https://jospar.kz/share/hash-3?mode=duplicate'),
      ),
      'hash-3',
    );
  });

  test('extracts hash after GoRouter converts a universal link to a path', () {
    expect(extractShareHash(Uri.parse('/s/hash-4')), 'hash-4');
    expect(extractShareHash(Uri.parse('/share/hash-5')), 'hash-5');
  });

  test('missing mode defaults to collaboration', () {
    expect(
      ShareDeliveryMode.fromValue(null),
      ShareDeliveryMode.collaborate,
    );
  });
}
