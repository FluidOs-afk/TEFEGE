import 'package:flutter/material.dart';
import '../models/user_post.dart';
import '../widgets/fashion_icon.dart';

class PostsService extends ChangeNotifier {
  PostsService._();
  static final PostsService instance = PostsService._();

  final List<UserPost> _posts = [
    UserPost(
      id: 'demo_1',
      title: 'Look de verano',
      description: 'Combinación perfecta para días calurosos. La clave está en los tonos pastel.',
      tags: ['verano', 'casual', 'OOTD'],
      category: FashionCategory.dress,
      gradient: const [Color(0xFF4A1275), Color(0xFF9C27B0)],
      wardrobeItems: const [
        PostWardrobeItem(name: 'Vestido Satinado', brand: 'H&M', bgColor: Color(0xFFE8F5EE), category: FashionCategory.dress),
        PostWardrobeItem(name: 'Tacones Negros', brand: 'Stradivarius', bgColor: Color(0xFFEEEEEE), category: FashionCategory.shoes),
        PostWardrobeItem(name: 'Bolso de Piel', brand: 'Massimo Dutti', bgColor: Color(0xFFFBEEE4), category: FashionCategory.accessory),
      ],
      likes: 42,
      comments: [
        PostComment(user: 'sofia.styles', text: '¡Preciosa combinación! Dónde es el vestido?', timeAgo: '2h'),
        PostComment(user: 'marta.fashion', text: 'Me encanta ese vestido satinado 😍', timeAgo: '1h'),
      ],
      createdAt: DateTime(2026, 5, 9),
    ),
    UserPost(
      id: 'demo_2',
      title: 'Outfit formal',
      description: 'Para la reunión del lunes. Smart casual en su máxima expresión.',
      tags: ['formal', 'trabajo', 'smartcasual'],
      category: FashionCategory.coat,
      gradient: const [Color(0xFF37474F), Color(0xFF78909C)],
      wardrobeItems: const [
        PostWardrobeItem(name: 'Blazer Oversize', brand: 'Zara', bgColor: Color(0xFFF5F0EB), category: FashionCategory.coat),
        PostWardrobeItem(name: 'Vaqueros Slouchy', brand: 'Mango', bgColor: Color(0xFFE3F2FD), category: FashionCategory.pants),
        PostWardrobeItem(name: 'Sneakers Blancas', brand: 'Nike', bgColor: Color(0xFFF3F4F6), category: FashionCategory.shoes),
      ],
      likes: 87,
      comments: [
        PostComment(user: 'lucia.vintage', text: 'El blazer oversize es una pasada 🔥', timeAgo: '5h'),
      ],
      createdAt: DateTime(2026, 5, 6),
    ),
    UserPost(
      id: 'demo_3',
      title: 'Zapatillas nuevas',
      description: 'Recién llegadas y ya son mis favoritas.',
      tags: ['sneakers', 'sport', 'Nike'],
      category: FashionCategory.shoes,
      gradient: const [Color(0xFF1B6B44), Color(0xFF3CB87A)],
      wardrobeItems: const [
        PostWardrobeItem(name: 'Sneakers Blancas', brand: 'Nike', bgColor: Color(0xFFF3F4F6), category: FashionCategory.shoes),
        PostWardrobeItem(name: 'Camiseta Básica', brand: 'Uniqlo', bgColor: Color(0xFFFFF8F0), category: FashionCategory.tops),
      ],
      likes: 23,
      comments: [],
      createdAt: DateTime(2026, 5, 3),
    ),
  ];

  List<UserPost> get posts => List.unmodifiable(_posts);
  int get count => _posts.length;

  void add(UserPost post) {
    _posts.insert(0, post);
    notifyListeners();
  }

  void remove(String id) {
    _posts.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  void toggleLike(String id) {
    final idx = _posts.indexWhere((p) => p.id == id);
    if (idx == -1) return;
    final p = _posts[idx];
    _posts[idx] = p.copyWith(
      isLiked: !p.isLiked,
      likes: p.isLiked ? p.likes - 1 : p.likes + 1,
    );
    notifyListeners();
  }

  void addComment(String postId, PostComment comment) {
    final idx = _posts.indexWhere((p) => p.id == postId);
    if (idx == -1) return;
    _posts[idx] = _posts[idx].copyWith(
      comments: [comment, ..._posts[idx].comments],
    );
    notifyListeners();
  }
}
