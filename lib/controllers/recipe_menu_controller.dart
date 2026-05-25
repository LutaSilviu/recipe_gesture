import 'package:flutter/foundation.dart';

import '../app/app_constants.dart';
import '../models/recipe.dart';

/// Manages the currently selected recipe index in the grid.
///
/// Navigation rules (2-column grid):
///  - LEFT  – decrement index only if not in the first column.
///  - RIGHT – increment index only if not in the last column and item exists.
///  - UP    – decrement index by [gridColumns] if the target exists.
///  - DOWN  – increment index by [gridColumns] if the target exists.
class RecipeMenuController extends ChangeNotifier {
  final List<Recipe> _recipes;
  int _selectedIndex = 0;

  RecipeMenuController({required List<Recipe> recipes}) : _recipes = recipes;

  List<Recipe> get recipes => _recipes;
  int get selectedIndex => _selectedIndex;
  Recipe get selectedRecipe => _recipes[_selectedIndex];

  void moveLeft() {
    if (_selectedIndex % AppConstants.gridColumns > 0) {
      _selectedIndex--;
      notifyListeners();
    }
  }

  void moveRight() {
    final col = _selectedIndex % AppConstants.gridColumns;
    if (col < AppConstants.gridColumns - 1 &&
        _selectedIndex + 1 < _recipes.length) {
      _selectedIndex++;
      notifyListeners();
    }
  }

  void moveUp() {
    if (_selectedIndex - AppConstants.gridColumns >= 0) {
      _selectedIndex -= AppConstants.gridColumns;
      notifyListeners();
    }
  }

  void moveDown() {
    if (_selectedIndex + AppConstants.gridColumns < _recipes.length) {
      _selectedIndex += AppConstants.gridColumns;
      notifyListeners();
    }
  }

  /// Jump directly to an index (used by tap interaction).
  void moveToIndex(int index) {
    if (index >= 0 && index < _recipes.length && index != _selectedIndex) {
      _selectedIndex = index;
      notifyListeners();
    }
  }
}
