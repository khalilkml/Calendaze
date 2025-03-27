import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'event_provider.dart';
import 'notification_service.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().initialize();
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => EventProvider(),
      child: Consumer<EventProvider>(
        builder: (context, provider, child) {
          return MaterialApp(
            title: 'Calendaze',
            theme: provider.isDarkMode
                ? ThemeData.dark().copyWith(
                    primaryColor: Colors.blueGrey,
                    colorScheme: ThemeData.dark().colorScheme.copyWith(
                      secondary: Colors.tealAccent,
                    ),
                  )
                : ThemeData.light().copyWith(
                    primaryColor: Colors.blue,
                    colorScheme: ThemeData.light().colorScheme.copyWith(
                      secondary: Colors.lightBlueAccent,
                    ),
                  ),
            home: SplashScreen(),
          );
        },
      ),
    );
  }
}