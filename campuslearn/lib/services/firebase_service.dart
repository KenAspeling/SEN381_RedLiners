// Export the appropriate Firebase service based on platform
export 'firebase_service_stub.dart'
    if (dart.library.io) 'firebase_service_mobile.dart';
