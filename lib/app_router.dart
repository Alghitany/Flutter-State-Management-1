import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:week1/business_logic/cubit/characters_cubit.dart';
import 'package:week1/data/repository/characters_repository.dart';
import 'package:week1/data/web_services/characters_web_services.dart';
import 'package:week1/presentation/screens/characters_details.dart';
import 'package:week1/presentation/screens/characters_screen.dart';

import 'constants/strings.dart';
import 'data/models/characters.dart';

class AppRouter {

  late CharactersRepository charactersRepository;
  late CharactersCubit charactersCubit;

  AppRouter() {
    charactersRepository = CharactersRepository(CharactersWebServices());
    charactersCubit = CharactersCubit(charactersRepository);
  }

  Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case charactersScreen:
        return MaterialPageRoute(builder: (_) =>
            BlocProvider(
              create: (BuildContext context) => charactersCubit,
              child: const CharactersScreen(),
            ),
        );

      case charactersDetailsScreen:
        final character = settings.arguments as Character;
        return MaterialPageRoute(builder: (_) =>
            CharacterDetailsScreen(
                character: character)
        );
    }
    return null;
  }
}