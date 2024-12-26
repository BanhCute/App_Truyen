import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'src/app.dart';
import 'bloc/session_cubit.dart';
import 'src/providers/theme_provider.dart';

Future<void> main() async {
  await dotenv.load();

  runApp(
    BlocProvider(
      create: (_) => SessionCubit(),
      child: ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: const MyApp(),
      ),
    ),
  );
}
