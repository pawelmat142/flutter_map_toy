import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:flutter_map_toy/global/drawing/drawing_state.dart';
import 'package:flutter_map_toy/global/hive.dart';
import 'package:flutter_map_toy/global/wizard/wizard_state.dart';
import 'package:flutter_map_toy/models/map_cubit.dart';
import 'package:flutter_map_toy/presentation/dialogs/app_drawing.dart';
import 'package:flutter_map_toy/presentation/views/home_screen.dart';
import 'package:flutter_map_toy/presentation/styles/app_theme.dart';
import 'package:flutter_map_toy/presentation/views/map_screen/map_screen.dart';
import 'package:flutter_map_toy/presentation/views/saved_maps_screen.dart';
import 'package:flutter_map_toy/services/get_it.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized(); // Required by FlutterConfig

  await FlutterConfig.loadEnvVariables(); // environment variables initialization

  AppGetIt.init(); //DI initialization

  await AppHive.initBoxes(); // local database initialization

  runApp(

    /// BLOC initialization
    MultiBlocProvider(
      providers: [
        BlocProvider<MapCubit>(create: (_) => MapCubit()),
        BlocProvider<WizardCubit>(create: (_) => WizardCubit()),
        BlocProvider<DrawingCubit>(create: (_) => DrawingCubit(AppDrawing()))
      ],

  /// MAIN WIDGET
    child: const MyApp(),
    ),
  );
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
        MapScreen.id: (context) => const MapScreen(),
        SavedMapsScreen.id: (context) => const SavedMapsScreen(),
      },
    );
  }
}