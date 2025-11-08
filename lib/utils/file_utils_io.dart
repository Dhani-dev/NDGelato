import 'dart:io';

/// Returns a File for non-web platforms.
File createFile(String path) => File(path);
