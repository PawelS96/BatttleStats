import 'package:battlestats/data/local/preferences.dart';
import 'package:battlestats/data/repository/repository.dart';
import 'package:battlestats/data/repository/stats_repository.dart';
import 'package:battlestats/models/player/player.dart';
import 'package:battlestats/models/weapons/weapon_sort_mode.dart';
import 'package:battlestats/models/weapons/weapon_stats.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WeaponsViewModel with ChangeNotifier {
  final Player _player;
  final StatsRepository _repository;
  final Preferences _preferences;

  WeaponsViewModel(this._player, this._repository, this._preferences) {
    _loadData();
  }

  factory WeaponsViewModel.of(BuildContext context, Player player) {
    return WeaponsViewModel(
      player,
      context.read<StatsRepository>(),
      context.read<Preferences>(),
    );
  }

  List<WeaponStats> _allWeapons = [];
  List<WeaponStats> weapons = [];
  var isLoading = true;
  var sortMode = WeaponSortMode.kills;
  var selectedWeaponTypes = <String>[];

  bool get isError => !isLoading && _allWeapons.isEmpty;

  void _loadData() async {
    sortMode = await _preferences.getWeaponsSortMode() ?? WeaponSortMode.kills;
    _repository.getWeaponStats(_player).listen((data) {
      _onDataLoaded(data ?? []);
      isLoading = false;
      notifyListeners();
    });
  }

  Future<void> refresh() async {
    _repository.getWeaponStats(_player, accessType: DataAccessType.onlyRemote).listen((data) {
      if (data != null) {
        _onDataLoaded(data);
        notifyListeners();
      }
    });
  }

  Future<void> retry() async {
    isLoading = true;
    notifyListeners();
    _repository.getWeaponStats(_player).listen((data) {
      if (data != null) {
        _onDataLoaded(data);
      }
      isLoading = false;
      notifyListeners();
    });
  }

  void _onDataLoaded(List<WeaponStats> newData) {
    final isEmpty = _allWeapons.isEmpty;
    _allWeapons = newData;
    weapons = _allWeapons.toList();

    if (isEmpty) {
      selectedWeaponTypes = weaponTypes;
    }

    _filterItems();
    _sortItems(sortMode);
  }

  void onSortModeClicked(WeaponSortMode mode) {
    sortMode = mode;
    _sortItems(mode);
    notifyListeners();
    _preferences.setWeaponsSortMode(mode);
  }

  void selectAllTypes() {
    selectedWeaponTypes = weaponTypes.toList();
    _filterItems();
    _sortItems(sortMode);
    notifyListeners();
  }

  void selectNoTypes() {
    selectedWeaponTypes = [];
    _filterItems();
    _sortItems(sortMode);
    notifyListeners();
  }

  List<String> get weaponTypes {
    return _allWeapons.map((e) => e.type).toSet().toList()..sort();
  }

  void onWeaponTypeClicked(String type) {
    if (selectedWeaponTypes.contains(type)) {
      selectedWeaponTypes.remove(type);
    } else {
      selectedWeaponTypes.add(type);
    }
    _filterItems();
    _sortItems(sortMode);
    notifyListeners();
  }

  void _filterItems() {
    weapons = _allWeapons.where((e) => selectedWeaponTypes.contains(e.type)).toList();
  }

  void _sortItems(WeaponSortMode mode) {
    switch (mode) {
      case WeaponSortMode.name:
        weapons.sort((a, b) => a.weaponName.toLowerCase().compareTo(b.weaponName.toLowerCase()));
        break;
      case WeaponSortMode.kills:
        weapons.sort((a, b) => b.kills.compareTo(a.kills));
        break;
      case WeaponSortMode.kpm:
        weapons.sort((a, b) => b.killsPerMinute.compareTo(a.killsPerMinute));
        break;
      case WeaponSortMode.time:
        weapons.sort((a, b) => b.timeEquipped.compareTo(a.timeEquipped));
        break;
    }
  }
}
