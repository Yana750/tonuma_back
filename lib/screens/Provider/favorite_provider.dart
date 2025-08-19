import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/product_model.dart';

class FavoriteProvider extends ChangeNotifier {
  final List<Product> _favorites = [];
  final _supabase = Supabase.instance.client;

  List<Product> get favorites => _favorites;

  Future<void> toggleFavorite(Product product) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    final isFavorite = _favorites.any((p) => p.id == product.id);

    if (isFavorite) {
      // Удаляем из избранного
      await _supabase
          .from('favorites')
          .delete()
          .eq('user_id', userId)
          .eq('product_id', product.id);

      _favorites.removeWhere((p) => p.id == product.id);
    } else {
      // Добавляем в избранное
      await _supabase.from('favorites').insert({
        'user_id': userId,
        'product_id': product.id,
      });

      _favorites.add(product);
    }
    notifyListeners();
  }

  bool isExist(Product product) {
    return _favorites.any((p) => p.id == product.id);
  }

  Future<void> loadFavorites(List<Product> allProducts) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final data = await _supabase
          .from('favorites')
          .select('product_id')
          .eq('user_id', userId);

      final List<String> productIds = (data as List)
          .map((item) => item['product_id'] as String)
          .toList();

      _favorites.clear();
      _favorites.addAll(
        allProducts.where((product) => productIds.contains(product.id)),
      );

      notifyListeners();
    } catch (e) {
      print('Ошибка загрузки избранных товаров: $e');
    }
  }

  static FavoriteProvider of(BuildContext context, {bool listen = true}) {
    return Provider.of<FavoriteProvider>(context, listen: listen);
  }
}
