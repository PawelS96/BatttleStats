import 'package:battlestats/data/local/player_repository.dart';
import 'package:battlestats/data/local/preferences.dart';
import 'package:battlestats/data/remote/stats_service.dart';
import 'package:battlestats/data/repository/repository.dart';
import 'package:battlestats/data/repository/stats_repository.dart';
import 'package:battlestats/models/classes/class_stats.dart';
import 'package:battlestats/models/game_modes/game_mode_stats.dart';
import 'package:battlestats/models/player/platform.dart';
import 'package:battlestats/models/player/player.dart';
import 'package:battlestats/models/player/player_stats.dart';
import 'package:battlestats/models/progress/progress_stats.dart';
import 'package:battlestats/models/vehicles/vehicle_sort_mode.dart';
import 'package:battlestats/models/vehicles/vehicle_stats.dart';
import 'package:battlestats/models/weapons/weapon_sort_mode.dart';
import 'package:battlestats/models/weapons/weapon_stats.dart';

class FakePlayerRepository implements PlayerRepository {
  Player? _selectedPlayer;
  final _players = <Player>[];

  FakePlayerRepository({Player? selectedPlayer}) {
    _selectedPlayer = selectedPlayer;
    if (selectedPlayer != null) {
      _players.add(selectedPlayer);
    }
  }

  @override
  Future<void> addPlayer(Player player) async {
    _players.add(player);
  }

  @override
  Future<void> deletePlayer(Player player) async {
    _players.remove(player);
  }

  @override
  Future<List<Player>> getPlayers() async {
    return _players;
  }

  @override
  Future<Player?> getSelectedPlayer() async {
    return _selectedPlayer;
  }

  @override
  Future<void> setSelectedPlayer(Player? player) async {
    _selectedPlayer = player;
  }
}

class FakeStatsService implements StatsService {
  static final defaultStats = PlayerStats.fromJson({});

  final PlayerStats? stats;
  final List<WeaponStats>? weaponStats;
  final List<VehicleStats>? vehicleStats;
  final List<ClassStats>? classStats;
  final List<GameModeStats>? gameModeStats;
  final List<ProgressStats>? progressStats;

  FakeStatsService({
    this.stats,
    this.weaponStats,
    this.vehicleStats,
    this.classStats,
    this.gameModeStats,
    this.progressStats,
  });

  @override
  Future<PlayerStats?> getPlayerStats(int playerId, GamingPlatform platform) async {
    return stats;
  }

  @override
  Future<List<WeaponStats>?> getWeaponStats(int playerId, GamingPlatform platform) async {
    return weaponStats;
  }

  @override
  Future<List<VehicleStats>?> getVehicleStats(int playerId, GamingPlatform platform) async {
    return vehicleStats;
  }

  @override
  Future<List<ClassStats>?> getClassStats(int playerId, GamingPlatform platform) async {
    return classStats;
  }

  @override
  Future<List<GameModeStats>?> getGameModeStats(int playerId, GamingPlatform platform) async {
    return gameModeStats;
  }

  @override
  Future<List<ProgressStats>?> getProgressStats(int playerId, GamingPlatform platform) async {
    return progressStats;
  }
}

class FakePreferences implements Preferences {
  WeaponSortMode? _weaponSortMode;
  VehicleSortMode? _vehicleSortMode;

  @override
  Future<WeaponSortMode?> getWeaponsSortMode() {
    return Future.value(_weaponSortMode);
  }

  @override
  Future<void> setWeaponsSortMode(WeaponSortMode mode) async {
    _weaponSortMode = mode;
  }

  @override
  Future<VehicleSortMode?> getVehiclesSortMode() {
    return Future.value(_vehicleSortMode);
  }

  @override
  Future<void> setVehiclesSortMode(VehicleSortMode mode) async {
    _vehicleSortMode = mode;
  }
}

class FakeStatsRepository implements StatsRepository {
  var playerStats = <PlayerStats?>[];
  var weaponStats = <List<WeaponStats>?>[];
  var vehicleStats = <List<VehicleStats>?>[];
  var classStats = <List<ClassStats>?>[];
  var gameModeStats = <List<GameModeStats>?>[];
  var progressStats = <List<ProgressStats>?>[];

  FakeStatsRepository();

  void setPlayerStats(List<PlayerStats?> newValues) {
    playerStats = newValues.toList();
  }

  void setWeaponsStats(List<List<WeaponStats>?> newValues) {
    weaponStats = newValues.toList();
  }

  void setVehiclesStats(List<List<VehicleStats>?> newValues) {
    vehicleStats = newValues.toList();
  }

  void setClassStats(List<List<ClassStats>?> newValues) {
    classStats = newValues.toList();
  }

  void setGameModeStats(List<List<GameModeStats>?> newValues) {
    gameModeStats = newValues.toList();
  }

  void setProgressStats(List<List<ProgressStats>?> newValues) {
    progressStats = newValues.toList();
  }

  @override
  Stream<PlayerStats?> getPlayerStats(
    Player player, {
    DataAccessType accessType = DataAccessType.localAndRemote,
  }) {
    return Stream.fromIterable(playerStats);
  }

  @override
  Stream<List<ClassStats>?> getClassStats(
    Player player, {
    DataAccessType accessType = DataAccessType.localAndRemote,
  }) {
    return Stream.fromIterable(classStats);
  }

  @override
  Stream<List<VehicleStats>?> getVehicleStats(
    Player player, {
    DataAccessType accessType = DataAccessType.localAndRemote,
  }) {
    return Stream.fromIterable(vehicleStats);
  }

  @override
  Stream<List<WeaponStats>?> getWeaponStats(
    Player player, {
    DataAccessType accessType = DataAccessType.localAndRemote,
  }) {
    return Stream.fromIterable(weaponStats);
  }

  @override
  Stream<List<GameModeStats>?> getGameModeStats(
    Player player, {
    DataAccessType accessType = DataAccessType.localAndRemote,
  }) {
    return Stream.fromIterable(gameModeStats);
  }

  @override
  Stream<List<ProgressStats>?> getProgressStats(
      Player player, {
        DataAccessType accessType = DataAccessType.localAndRemote,
      }) {
    return Stream.fromIterable(progressStats);
  }


  @override
  Future<void> clearCache(Player player) {
    playerStats = [];
    weaponStats = [];
    vehicleStats = [];
    classStats = [];
    gameModeStats = [];
    progressStats = [];
    return Future.value(null);
  }
}
