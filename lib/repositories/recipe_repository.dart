import '../models/recipe.dart';

/// Provides the demo recipe data.
class RecipeRepository {
  RecipeRepository._();

  static const List<Recipe> recipes = [
    Recipe(
      id: '1',
      title: 'Paste Carbonara',
      emoji: '🍝',
      time: '20 min',
      difficulty: 'Easy',
      description:
          'Classic Italian pasta with creamy egg sauce, crispy guanciale, '
          'and pecorino romano cheese. A Roman staple that is simple yet '
          'incredibly flavourful.',
      ingredients: [
        '400 g spaghetti',
        '200 g guanciale (or pancetta)',
        '4 egg yolks + 2 whole eggs',
        '100 g pecorino romano, grated',
        '50 g parmesan, grated',
        'Black pepper to taste',
        'Salt for pasta water',
      ],
      steps: [
        'Bring a large pot of salted water to boil and cook the spaghetti al dente.',
        'Cut the guanciale into small strips and fry in a dry pan until crispy.',
        'Whisk egg yolks, whole eggs, pecorino, and parmesan together in a bowl.',
        'Drain pasta, reserving a cup of pasta water.',
        'Toss hot pasta with guanciale off the heat.',
        'Add the egg-cheese mixture, tossing quickly so the eggs thicken but don\'t scramble.',
        'Add a splash of pasta water if needed. Serve with extra pepper.',
      ],
    ),
    Recipe(
      id: '2',
      title: 'Pizza Margherita',
      emoji: '🍕',
      time: '35 min',
      difficulty: 'Medium',
      description:
          'Simple Neapolitan pizza with tomato sauce, fresh mozzarella, '
          'basil, and a drizzle of olive oil on a thin, crispy crust.',
      ingredients: [
        '300 g pizza dough (store-bought or homemade)',
        '200 ml crushed San Marzano tomatoes',
        '200 g fresh mozzarella',
        'Fresh basil leaves',
        '2 tbsp extra-virgin olive oil',
        '1 tsp salt',
        'Pinch of sugar',
      ],
      steps: [
        'Preheat oven to the highest setting (250 °C / 480 °F) with a baking stone if available.',
        'Season crushed tomatoes with salt and a pinch of sugar.',
        'Stretch dough into a round shape on a floured surface.',
        'Spread a thin layer of tomato sauce, leaving a border for the crust.',
        'Tear mozzarella and distribute evenly.',
        'Bake for 8-12 minutes until the crust is golden and cheese is bubbling.',
        'Top with fresh basil and a drizzle of olive oil before serving.',
      ],
    ),
    Recipe(
      id: '3',
      title: 'Pancakes',
      emoji: '🥞',
      time: '15 min',
      difficulty: 'Easy',
      description:
          'Fluffy American-style pancakes perfect for a weekend breakfast. '
          'Serve with maple syrup, fresh berries, or a pat of butter.',
      ingredients: [
        '200 g flour',
        '2 tbsp sugar',
        '1 tsp baking powder',
        '½ tsp baking soda',
        '1 pinch salt',
        '1 egg',
        '300 ml buttermilk',
        '30 g melted butter',
      ],
      steps: [
        'Mix flour, sugar, baking powder, baking soda, and salt in a large bowl.',
        'In a separate bowl, whisk egg, buttermilk, and melted butter.',
        'Pour wet ingredients into dry and stir until just combined (lumps are OK).',
        'Heat a non-stick pan over medium heat and lightly grease.',
        'Pour ~¼ cup batter per pancake. Cook until bubbles form on the surface.',
        'Flip and cook another 1-2 minutes until golden.',
        'Serve stacked with maple syrup, berries, or your favourite topping.',
      ],
    ),
    Recipe(
      id: '4',
      title: 'Salată Caesar',
      emoji: '🥗',
      time: '10 min',
      difficulty: 'Easy',
      description:
          'Crisp romaine lettuce tossed with a tangy Caesar dressing, '
          'crunchy croutons, and shaved parmesan. A timeless side or main.',
      ingredients: [
        '1 large romaine lettuce',
        '100 g croutons',
        '50 g parmesan, shaved',
        '2 anchovy fillets (optional)',
        '1 clove garlic, minced',
        '1 egg yolk',
        '2 tbsp lemon juice',
        '1 tsp Dijon mustard',
        '100 ml olive oil',
        'Salt & pepper to taste',
      ],
      steps: [
        'Wash and chop the romaine lettuce into bite-sized pieces.',
        'For dressing: blend anchovy, garlic, egg yolk, lemon juice, and mustard.',
        'Slowly drizzle olive oil while blending to emulsify.',
        'Season dressing with salt and pepper.',
        'Toss lettuce with dressing until evenly coated.',
        'Top with croutons and shaved parmesan.',
        'Serve immediately while croutons are still crunchy.',
      ],
    ),
    Recipe(
      id: '5',
      title: 'Supă cremă de legume',
      emoji: '🥣',
      time: '30 min',
      difficulty: 'Medium',
      description:
          'A velvety cream soup packed with seasonal vegetables. '
          'Comforting, healthy, and perfect for lunch or dinner.',
      ingredients: [
        '2 carrots, diced',
        '2 potatoes, diced',
        '1 zucchini, diced',
        '1 onion, chopped',
        '2 cloves garlic, minced',
        '1 L vegetable broth',
        '100 ml cream',
        '2 tbsp olive oil',
        'Salt, pepper, nutmeg to taste',
      ],
      steps: [
        'Heat olive oil in a large pot and sauté onion until translucent.',
        'Add garlic and cook for 30 seconds.',
        'Add carrots, potatoes, and zucchini; stir for 2 minutes.',
        'Pour in vegetable broth, bring to a boil, then simmer 15-20 minutes.',
        'Blend with an immersion blender until smooth.',
        'Stir in cream, season with salt, pepper, and a pinch of nutmeg.',
        'Serve hot with crusty bread on the side.',
      ],
    ),
    Recipe(
      id: '6',
      title: 'Burger Homemade',
      emoji: '🍔',
      time: '25 min',
      difficulty: 'Medium',
      description:
          'Juicy homemade beef burger with all the classic fixings. '
          'Nothing beats a freshly grilled patty on a toasted bun.',
      ingredients: [
        '500 g ground beef (80/20)',
        '4 burger buns',
        '4 slices cheddar cheese',
        '1 tomato, sliced',
        '4 lettuce leaves',
        '1 red onion, sliced into rings',
        'Pickles',
        'Ketchup & mustard',
        'Salt & pepper',
      ],
      steps: [
        'Divide beef into 4 portions and shape into patties slightly wider than the buns.',
        'Season both sides generously with salt and pepper.',
        'Grill or pan-fry over high heat for 3-4 minutes per side.',
        'Place a slice of cheddar on each patty in the last minute of cooking.',
        'Toast the buns lightly on the grill or in a pan.',
        'Assemble: bottom bun, lettuce, patty with cheese, tomato, onion, pickles.',
        'Add ketchup and mustard, top with the bun, and serve immediately.',
      ],
    ),
  ];
}
