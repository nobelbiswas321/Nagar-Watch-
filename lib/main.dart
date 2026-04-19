import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_routes.dart';
import 'features/project_management/screens/project_list_screen.dart';
import 'features/project_management/screens/project_create_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nagarwatch',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: AppRoutes.projectList,
      routes: {
        AppRoutes.projectList: (context) => const ProjectListScreen(),
        AppRoutes.projectCreate: (context) => const ProjectCreateScreen(),
      },
    );
  }
}