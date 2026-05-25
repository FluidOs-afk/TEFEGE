import 'package:flutter/material.dart';
import '../widgets/fashion_icon.dart';

class PostModel {
  final String userId;
  final String username;
  final String avatar;
  final Color avatarColor;
  final String timeAgo;
  final String outfitTitle;
  final String description;
  final int likes;
  final int comments;
  final List<String> tags;
  final Color placeholderColor;
  final Color placeholderColorEnd;
  final FashionCategory fashionCategory;
  final bool isLiked;

  const PostModel({
    required this.userId,
    required this.username,
    required this.avatar,
    required this.avatarColor,
    required this.timeAgo,
    required this.outfitTitle,
    required this.description,
    required this.likes,
    required this.comments,
    required this.tags,
    required this.placeholderColor,
    required this.placeholderColorEnd,
    required this.fashionCategory,
    required this.isLiked,
  });

  PostModel copyWith({bool? isLiked, int? likes, int? comments}) {
    return PostModel(
      userId: userId,
      username: username,
      avatar: avatar,
      avatarColor: avatarColor,
      timeAgo: timeAgo,
      outfitTitle: outfitTitle,
      description: description,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      tags: tags,
      placeholderColor: placeholderColor,
      placeholderColorEnd: placeholderColorEnd,
      fashionCategory: fashionCategory,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
