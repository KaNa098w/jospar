enum ShareDeliveryMode {
  collaborate,
  duplicate;

  String get queryValue => switch (this) {
        ShareDeliveryMode.collaborate => 'collaborate',
        ShareDeliveryMode.duplicate => 'duplicate',
      };

  static ShareDeliveryMode fromValue(String? value) {
    return value == ShareDeliveryMode.duplicate.queryValue || value == 'copy'
        ? ShareDeliveryMode.duplicate
        : ShareDeliveryMode.collaborate;
  }
}

String? extractShareHash(Uri uri) {
  final isJosparWebLink =
      uri.scheme == 'https' && uri.host.toLowerCase() == 'jospar.kz';
  final isInternalRoute = uri.scheme.isEmpty && uri.host.isEmpty;
  if ((isJosparWebLink || isInternalRoute) &&
      uri.pathSegments.length == 2 &&
      (uri.pathSegments.first == 's' || uri.pathSegments.first == 'share')) {
    return uri.pathSegments[1];
  }
  if (uri.scheme == 'jospar' && uri.host == 'share') {
    return uri.queryParameters['hash'];
  }
  return null;
}
