// Conditional export for upload service - chooses platform-specific implementation
export 'upload_service_stub.dart'
    if (dart.library.io) 'upload_service_mobile.dart'
    if (dart.library.html) 'upload_service_web.dart';
