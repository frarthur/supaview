import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:supaview/app.dart';
import 'package:supaview/core/services/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveService.init();

  await Supabase.initialize(
    url: '',
    publishableKey: '',
  );

  runApp(
    const ProviderScope(
      child: SupaViewApp(),
    ),
  );
}
