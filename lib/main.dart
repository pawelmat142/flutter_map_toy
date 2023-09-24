import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:flutter_map_toy/models/map_state.dart';
import 'package:flutter_map_toy/presentation/views/home_screen.dart';
import 'package:flutter_map_toy/presentation/styles/app_theme.dart';
import 'package:flutter_map_toy/services/get_it.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


void main() async {

  WidgetsFlutterBinding.ensureInitialized(); // Required by FlutterConfig

  await FlutterConfig.loadEnvVariables();

  AppGetIt.init();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<MapCubit>(create: (_) => MapCubit())
      ],
      child: const MyApp(),
    ),
  );



  // runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      title: 'Flutter Demo',
      theme: AppTheme.appLightTheme,

      scaffoldMessengerKey: GlobalKey<ScaffoldMessengerState>(),

      initialRoute: HomeScreen.id,
      routes: {
        HomeScreen.id: (context) => const HomeScreen(),
        // MapScreen.id: (context) => const MapScreen(),
      },
    );
  }
}