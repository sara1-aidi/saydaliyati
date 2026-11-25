import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 0 = Store, 1 = Cart, 2 = Orders, 3 = Profile
final clientTabProvider = StateProvider<int>((ref) => 0);
