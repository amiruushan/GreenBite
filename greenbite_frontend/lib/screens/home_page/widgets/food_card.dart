import 'package:flutter/material.dart';
import 'package:greenbite_frontend/screens/food_detail_screen/food_detail_screen.dart';
import 'package:greenbite_frontend/screens/home_page/models/food_item.dart';

class FoodCard extends StatelessWidget {
  final FoodItem foodItem;
  final bool isFavorite;
  final VoidCallback onFavoritePressed;

  const FoodCard({
    super.key,
    required this.foodItem,
    required this.isFavorite,
    required this.onFavoritePressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FoodDetailScreen(foodItem: foodItem),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        margin: EdgeInsets.zero,
        color: isDarkMode ? Colors.grey[950] : Colors.grey[100],
        child: Padding(
          padding:
              const EdgeInsets.all(8.0), // ✅ Reduce padding for tighter layout
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // ✅ Ensure minimal height
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  foodItem.photo,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 120,
                      color: theme.colorScheme.surface,
                      child: Icon(
                        Icons.broken_image,
                        color: theme.colorScheme.onSurface,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8), // ✅ Less space between image & text
              Text(
                foodItem.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: isDarkMode
                      ? Colors.white
                      : Colors.black, // ✅ Dynamic color
                  fontWeight: FontWeight.bold,
                  fontSize: 16, // ✅ Make font consistent
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                foodItem.restaurant,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDarkMode
                      ? Colors.grey[400]
                      : Colors.grey[700], // ✅ Adjust contrast
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4), // ✅ Reduce unnecessary space
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "\$${foodItem.price.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.grey[400],
                    ),
                    onPressed: onFavoritePressed,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
