// Conditional export: on IO platforms this will re-export the IO implementation,
// on web it will re-export a web-safe stub.
export 'file_utils_io.dart' if (dart.library.html) 'file_utils_web.dart';
