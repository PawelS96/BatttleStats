import 'dart:async';

import 'package:battlestats/app/app_viewmodel.dart';
import 'package:battlestats/common/contants/app_colors.dart';
import 'package:battlestats/common/utils/snackbar_util.dart';
import 'package:battlestats/common/utils/text_formatter.dart';
import 'package:battlestats/common/widgets/background_image.dart';
import 'package:battlestats/models/player/player.dart';
import 'package:battlestats/models/player/player_stats.dart';
import 'package:battlestats/screens/add_player/add_player_screen.dart';
import 'package:battlestats/screens/main/main_viewmodel.dart';
import 'package:battlestats/screens/main/player_list_item.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  final Player player;

  const MainScreen({
    Key? key,
    required this.player,
  }) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late MainViewModel vm;

  late StreamSubscription<String> errorSub;

  @override
  void initState() {
    super.initState();
    vm = MainViewModel.of(context, widget.player);
    errorSub = vm.errors.listen((msg) => showSnackBarMessage(context, msg));
  }

  @override
  void dispose() {
    errorSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: vm,
      child: Consumer<MainViewModel>(
        builder: (ctx, vm, _) => Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              const BackgroundImage(),
              SafeArea(top: false, child: _content(vm)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _content(MainViewModel vm) {
    if (vm.isLoading) {
      return SizedBox.expand(
        child: Column(
          children: [
            _header(),
            const Spacer(),
            const CircularProgressIndicator(),
            const Spacer(),
          ],
        ),
      );
    }

    final stats = vm.stats;

    if (stats == null) {
      return SizedBox.expand(
        child: Column(
          children: [
            _header(),
            const Spacer(),
            _error(),
            const Spacer(),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: vm.refresh,
      child: SizedBox.expand(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _header(),
              _stats(stats),
            ],
          ),
        ),
      ),
    );
  }

  Widget _error() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        const Text(
          'Something went wrong',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 18),
        ),
        const SizedBox(height: 8),
        MaterialButton(
          onPressed: vm.retry,
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 2, color: Colors.white),
            borderRadius: BorderRadius.circular(25),
          ),
          child: const Text(
            'Try again',
            style: TextStyle(
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _changePlayerButton() {
    return MaterialButton(
      onPressed: _showPlayerList,
      shape: RoundedRectangleBorder(
        side: const BorderSide(width: 2, color: AppColors.textPrimary),
        borderRadius: BorderRadius.circular(25),
      ),
      child: const Text(
        "Change player",
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _header() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 80),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CachedNetworkImage(
            imageBuilder: (ctx, image) => CircleAvatar(backgroundImage: image, radius: 50),
            placeholder: (_, __) => const SizedBox(
              width: 100,
              height: 100,
              child: CircularProgressIndicator(),
            ),
            imageUrl: widget.player.avatar ?? '',
            errorWidget: (ctx, _, __) => Container(
              padding: const EdgeInsets.all(8),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 80,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 4),
                borderRadius: const BorderRadius.all(Radius.circular(75)),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            widget.player.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
        ),
        _changePlayerButton(),
      ],
    );
  }

  Widget _stats(PlayerStats stats) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                _statsText(title: 'SCORE/MIN', value: stats.scorePerMinute?.toInt() ?? 0),
                _statsText(title: 'WINS', value: stats.winPercent ?? '0.0%'),
                _statsText(title: 'KILLS', value: stats.kills ?? 0),
              ],
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                _statsText(title: 'KILLS/MIN', value: stats.killsPerMinute ?? 0),
                _statsText(title: 'TIME', value: formatTime((stats.secondsPlayed ?? 0) * 1000)),
                _statsText(title: 'DEATHS', value: stats.deaths ?? 0),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _statsText({
    required String title,
    required dynamic value,
  }) {
    return Flexible(
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          FittedBox(
            child: Text(
              value.toString(),
              style: const TextStyle(fontSize: 32, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddPlayer() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => AddPlayerScreen(
          onAdded: (player) {
            Navigator.pop(context);
            vm.onPlayerAdded(player);
          },
          showKeyboard: true,
        ),
      ),
    );
  }

  void _showPlayerList() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      builder: (sheetContext) {
        final appVM = sheetContext.watch<AppViewModel>();
        return ChangeNotifierProvider.value(
          value: vm,
          child: Consumer<MainViewModel>(
            builder: (ctx, vm, _) => SingleChildScrollView(
              child: SafeArea(
                child: Column(
                  children: [
                    AddPlayerListItem(
                      onClick: () {
                        Navigator.pop(sheetContext);
                        _showAddPlayer();
                      },
                    ),
                    for (var player in vm.players)
                      PlayerListItem(
                        player: player,
                        isSelected: player == appVM.currentPlayer,
                        onClick: (player) {
                          Navigator.pop(sheetContext);
                          vm.selectPlayer(player);
                        },
                        onClickDelete: (player) {
                          if (vm.players.length == 1) {
                            Navigator.pop(sheetContext);
                          }
                          vm.deletePlayer(player);
                        },
                      )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
