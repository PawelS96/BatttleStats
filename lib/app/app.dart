import 'package:battlestats/common/widgets/background_image.dart';
import 'package:battlestats/data/local/player_repository.dart';
import 'package:battlestats/data/remote/network_client.dart';
import 'package:battlestats/data/remote/player_service.dart';
import 'package:battlestats/data/remote/stats_service.dart';
import 'package:battlestats/screens/add_player/add_player_screen.dart';
import 'package:battlestats/screens/main/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_viewmodel.dart';

class BattleStatsApp extends StatelessWidget {
  const BattleStatsApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => PlayerService(NetworkClient())),
        Provider(create: (ctx) => PlayerRepository()),
        Provider(create: (ctx) => StatsService(NetworkClient())),
      ],
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: AppViewModel.of),
        ],
        child: MaterialApp(
          title: 'Battlestats',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          debugShowCheckedModeBanner: false,
          home: Consumer<AppViewModel>(
            builder: (ctx, vm, _) => vm.state.map<Widget>(
              noPlayerSelected: () => AddPlayerScreen(
                onAdded: ctx.read<AppViewModel>().changePlayer,
              ),
              playerSelected: (player) => MainScreen(
                key: Key(player.id.toString()),
                player: player,
              ),
              loading: () => Stack(
                children: const [
                  BackgroundImage(),
                  Center(
                    child: CircularProgressIndicator(),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
