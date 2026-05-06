import 'package:flutter/material.dart';

class PostModel {
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
  final String placeholderEmoji;
  final bool isLiked;

  const PostModel({
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
    required this.placeholderEmoji,
    required this.isLiked,
  });

  PostModel copyWith({
    bool? isLiked,
    int? likes,
  }) {
    return PostModel(
      username: username,
      avatar: avatar,
      avatarColor: avatarColor,
      timeAgo: timeAgo,
      outfitTitle: outfitTitle,
      description: description,
      likes: likes ?? this.likes,
      comments: comments,
      tags: tags,
      placeholderColor: placeholderColor,
      placeholderEmoji: placeholderEmoji,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
