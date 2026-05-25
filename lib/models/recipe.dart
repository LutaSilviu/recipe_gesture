/// Data model for a recipe.
class Recipe {
  final String id;
  final String title;
  final String emoji;
  final String time;
  final String difficulty;
  final String description;
  final List<String> ingredients;
  final List<String> steps;

  const Recipe({
    required this.id,
    required this.title,
    required this.emoji,
    required this.time,
    required this.difficulty,
    required this.description,
    required this.ingredients,
    required this.steps,
  });
}
