import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:supaview/app.dart';
import 'package:supaview/core/services/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveService.init();

  runApp(
    const ProviderScope(
      child: SupaViewApp(),
    ),
  );
}
