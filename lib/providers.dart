import 'package:flutter_riverpod/flutter_riverpod.dart';

final soundOnProvider = Provider((ref) => true);
final chuyinOnProvider = Provider((ref) => true);

final gradeProvider = StateProvider<int>((ref) => 1);
final publisherCodeProvider = StateProvider<int>((ref) => 0);