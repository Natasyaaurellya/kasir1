import 'package:flutter/material.dart';
import 'package:kasir/home.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login.dart';

import 'package:supabase_flutter/supabase_flutter.dart';



Future<void> main() async {
  await Supabase.initialize(
    url: 'https://cgpmbqbwcogcmxmdxazn.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNncG1icWJ3Y29nY214bWR4YXpuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzYxMzQzODUsImV4cCI6MjA1MTcxMDM4NX0.4EhVe-YP-D0vvQbFtO7qYD_U38_QcwBqC-VaX07ZnIg',
  );
  runApp(MyApp());
}

        
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      // home: LoginScreen(), // Login screen as the initial screen
      home: LoginScreen(), // Login screen as the initial screen
    );
    
  }
}
