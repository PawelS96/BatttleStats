import 'package:battlestats/app/app_state.dart';
import 'package:battlestats/app/app_viewmodel.dart';
import 'package:battlestats/models/player/platform.dart';
import 'package:battlestats/models/player/player.dart';
import 'package:battlestats/models/player/player_stats.dart';
import 'package:battlestats/screens/main/main_viewmodel.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'common/fakes.dart';
import 'common/mocks.dart';

void main() {
  test('Players should be sorted by name ascending', () {
    fakeAsync((async) {
      final player1 = Player(0, 'z_player', 'avatar', GamingPlatform.xboxone);
      final player2 = Player(1, 'a_player', 'avatar', GamingPlatform.pc);
      final player3 = Player(2, 'k_player', 'avatar', GamingPlatform.ps4);
      final player4 = Player(3, 'g_player', 'avatar', GamingPlatform.ps4);

      final savedPlayers = [player1, player2, player3, player4];

      final playerRepo = MockPlayerRepo();
      when(() => playerRepo.getPlayers()).thenAnswer((_) => Future.value(savedPlayers));

      final statsRepo = FakeStatsRepository();
      statsRepo.setPlayerStats([FakeStatsService.defaultStats]);

      final vm = MainViewModel(player3, statsRepo, playerRepo, MockAppViewModel());
      async.elapse(const Duration(milliseconds: 1));

      expect(vm.players, [player2, player4, player3, player1]);
    });
  });

  test('Player should be selected after being added', () {
    fakeAsync((async) {
      final player = Player(0, 'player', 'avatar', GamingPlatform.xboxone);
      final playerRepo = FakePlayerRepository(selectedPlayer: player);
      final statsRepo = FakeStatsRepository();
      statsRepo.setPlayerStats([FakeStatsService.defaultStats]);

      final appVM = AppViewModel(playerRepo);
      final vm = MainViewModel(player, statsRepo, playerRepo, appVM);
      async.elapse(const Duration(milliseconds: 1));

      final addedPlayer = Player(1, 'Added player', 'avatar', GamingPlatform.pc);

      playerRepo.addPlayer(addedPlayer);
      async.elapse(const Duration(milliseconds: 1));

      vm.onPlayerAdded(addedPlayer);

      async.elapse(const Duration(milliseconds: 1));

      expect(appVM.currentPlayer, addedPlayer);
    });
  });

  test('Deleted player should be removed from the list', () {
    fakeAsync((async) {
      final selectedPlayer = Player(0, 'player', 'avatar', GamingPlatform.xboxone);
      final otherPlayer = Player(1, 'other player', 'avatar', GamingPlatform.xboxone);
      final playerRepo = FakePlayerRepository(selectedPlayer: selectedPlayer);
      final statsRepo = FakeStatsRepository();
      statsRepo.setPlayerStats([FakeStatsService.defaultStats]);

      playerRepo.addPlayer(otherPlayer);

      final vm = MainViewModel(selectedPlayer, statsRepo, playerRepo, MockAppViewModel());
      async.elapse(const Duration(milliseconds: 1));

      vm.deletePlayer(otherPlayer);
      async.elapse(const Duration(milliseconds: 1));

      expect(vm.players, [selectedPlayer]);
    });
  });

  test('Deleting current player should select another one', () {
    fakeAsync((async) {
      final selectedPlayer = Player(0, 'player', 'avatar', GamingPlatform.xboxone);
      final otherPlayer = Player(1, 'other player', 'avatar', GamingPlatform.xboxone);
      final playerRepo = FakePlayerRepository(selectedPlayer: selectedPlayer);
      playerRepo.addPlayer(otherPlayer);
      final statsRepo = FakeStatsRepository();
      statsRepo.setPlayerStats([FakeStatsService.defaultStats]);
      final appVM = AppViewModel(playerRepo);

      final vm = MainViewModel(selectedPlayer, statsRepo, playerRepo, appVM);
      async.elapse(const Duration(milliseconds: 1));

      vm.deletePlayer(selectedPlayer);
      async.elapse(const Duration(milliseconds: 1));

      expect(appVM.currentPlayer, otherPlayer);
    });
  });

  test('Deleting the only player should change the app state', () {
    fakeAsync((async) {
      final selectedPlayer = Player(0, 'player', 'avatar', GamingPlatform.xboxone);
      final playerRepo = FakePlayerRepository(selectedPlayer: selectedPlayer);
      final appVM = AppViewModel(playerRepo);
      final statsRepo = FakeStatsRepository();
      statsRepo.setPlayerStats([FakeStatsService.defaultStats]);

      final vm = MainViewModel(selectedPlayer, statsRepo, playerRepo, appVM);
      async.elapse(const Duration(milliseconds: 1));

      vm.deletePlayer(selectedPlayer);
      async.elapse(const Duration(milliseconds: 1));

      expect(appVM.state is NoPlayerSelected, true);
    });
  });

  test('Should load player stats', () {
    fakeAsync((async) {
      final player = Player(0, 'name', 'avatar', GamingPlatform.ps4);
      final stats = PlayerStats(avatar: 'avatar', bestClass: 'assault', kills: 100, deaths: 50);
      final statsRepo = FakeStatsRepository();
      statsRepo.setPlayerStats([stats]);
      final playerRepo = FakePlayerRepository(selectedPlayer: player);
      final vm = MainViewModel(player, statsRepo, playerRepo, AppViewModel(playerRepo));

      async.elapse(const Duration(milliseconds: 1));
      expect(vm.stats, stats);
      expect(vm.isLoading, false);
    });
  });

  test('Should update stats after a successful refresh', () {
    fakeAsync((async) {
      final player = Player(0, 'name', 'avatar', GamingPlatform.ps4);
      final stats = PlayerStats(avatar: 'avatar', bestClass: 'assault', kills: 100, deaths: 50);
      final statsRepo = FakeStatsRepository();
      statsRepo.setPlayerStats([stats]);
      final playerRepo = FakePlayerRepository(selectedPlayer: player);
      final vm = MainViewModel(player, statsRepo, playerRepo, AppViewModel(playerRepo));

      async.elapse(const Duration(milliseconds: 1));
      final updatedStats =
          PlayerStats(avatar: 'avatar', bestClass: 'assault', kills: 200, deaths: 100);
      statsRepo.setPlayerStats([updatedStats]);

      vm.refresh();
      async.elapse(const Duration(milliseconds: 1));

      expect(vm.stats, updatedStats);
    });
  });

  test('Should display error when refresh fails and keep previous stats', () {
    fakeAsync((async) {
      final player = Player(0, 'name', 'avatar', GamingPlatform.ps4);
      final stats = PlayerStats(avatar: 'avatar', bestClass: 'assault', kills: 100, deaths: 50);

      final statsRepo = FakeStatsRepository();
      statsRepo.setPlayerStats([stats]);

      final playerRepo = FakePlayerRepository(selectedPlayer: player);
      final vm = MainViewModel(player, statsRepo, playerRepo, AppViewModel(playerRepo));

      async.elapse(const Duration(milliseconds: 1));
      final errors = <String>[];

      vm.errors.listen((event) {
        errors.add(event);
      });

      statsRepo.setPlayerStats([null]);

      vm.refresh();
      async.elapse(const Duration(milliseconds: 1));

      expect(vm.stats, stats);
      expect(errors.length, 1);
      expect(vm.isLoading, false);
    });
  });

  test('Should update stats after a successful retry', () {
    fakeAsync((async) {
      final player = Player(0, 'name', 'avatar', GamingPlatform.ps4);
      final statsRepo = FakeStatsRepository();
      statsRepo.setPlayerStats([null]);
      final playerRepo = FakePlayerRepository(selectedPlayer: player);
      final vm = MainViewModel(player, statsRepo, playerRepo, AppViewModel(playerRepo));

      async.elapse(const Duration(milliseconds: 1));

      final stats = PlayerStats(avatar: 'avatar', bestClass: 'assault', kills: 100, deaths: 50);
      statsRepo.setPlayerStats([stats]);

      vm.retry();
      async.elapse(const Duration(milliseconds: 1));
      expect(vm.stats, stats);
    });
  });

  test('Should display error when retry fails', () {
    fakeAsync((async) {
      final player = Player(0, 'name', 'avatar', GamingPlatform.ps4);
      final statsRepo = FakeStatsRepository();
      statsRepo.setPlayerStats([null]);
      final playerRepo = FakePlayerRepository(selectedPlayer: player);
      final vm = MainViewModel(player, statsRepo, playerRepo, AppViewModel(playerRepo));

      final errors = <String>[];

      vm.errors.listen((event) {
        errors.add(event);
      });

      vm.retry();
      async.elapse(const Duration(milliseconds: 1));

      expect(errors.length, 1);
      expect(vm.isLoading, false);
    });
  });
}
