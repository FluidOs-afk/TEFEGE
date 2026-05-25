import 'package:flutter/material.dart';
import '../widgets/fashion_icon.dart';

class PostComment {
  final String user;
  final String text;
  final String timeAgo;
  const PostComment({
    required this.user,
    required this.text,
    required this.timeAgo,
  });
}

class PostWardrobeItem {
  final String name;
  final String brand;
  final Color bgColor;
  final FashionCategory category;
  const PostWardrobeItem({
    required this.name,
    required this.brand,
    required this.bgColor,
    required this.category,
  });
}

class UserPost {
  final String id;
  final String userId;
  final String title;
  final String description;
  final List<String> tags;
  final FashionCategory category;
  final List<Color> gradient;
  final List<PostWardrobeItem> wardrobeItems;
  final DateTime createdAt;
  final int likes;
  final bool isLiked;
  final List<PostComment> comments;

  final String? imagePath;

  const UserPost({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.tags,
    required this.category,
    required this.gradient,
    required this.wardrobeItems,
    required this.createdAt,
    this.imagePath,
    this.likes = 0,
    this.isLiked = false,
    this.comments = const [],
  });

  UserPost copyWith({int? likes, bool? isLiked, List<PostComment>? comments}) {
    return UserPost(
      id: id,
      userId: userId,
      title: title,
      description: description,
      tags: tags,
      category: category,
      gradient: gradient,
      wardrobeItems: wardrobeItems,
      createdAt: createdAt,
      imagePath: imagePath,
      likes: likes ?? this.likes,
      isLiked: isLiked ?? this.isLiked,
      comments: comments ?? this.comments,
    );
  }
}
