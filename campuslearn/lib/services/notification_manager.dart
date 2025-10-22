// Conditional export for notification manager - chooses platform-specific implementation
export 'notification_manager_stub.dart'
    if (dart.library.io) 'notification_manager_mobile.dart';
