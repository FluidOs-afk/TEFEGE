import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart' show AppColors;
import '../models/user_model.dart';
import '../services/profile_service.dart';
import '../utils/image_utils.dart';
import 'profile_screen.dart';

class FollowersScreen extends StatelessWidget {
  final String title;
  final List<String> uids;
  final String currentUid;

  const FollowersScreen({
    super.key,
    required this.title,
    required this.uids,
    required this.currentUid,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: AppColors.bgCard,
        title: Text(title, style: GoogleFonts.dmSans(fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: uids.isEmpty
          ? Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.people_outline_rounded, size: 56, color: AppColors.textHint),
                const SizedBox(height: 14),
                Text('Nadie aquí todavía',
                    style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary)),
              ]),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: uids.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (_, i) => _UserRow(uid: uids[i], currentUid: currentUid),
            ),
    );
  }
}

class _UserRow extends StatelessWidget {
  final String uid;
  final String currentUid;
  const _UserRow({required this.uid, required this.currentUid});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel>(
      future: ProfileService.instance.getUser(uid),
      builder: (context, snap) {
        final user = snap.data;
        return GestureDetector(
          onTap: user == null
              ? null
              : () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => ProfileScreen(userId: user.uid))),
          child: Container(
            color: AppColors.bgCard,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(children: [
              _buildAvatar(user),
              const SizedBox(width: 12),
              user == null
                  ? const Expanded(
                      child: SizedBox(
                          height: 20,
                          child: LinearProgressIndicator(color: AppColors.primary)))
                  : Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(user.nombre,
                            style: GoogleFonts.dmSans(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: AppColors.textPrimary)),
                        const SizedBox(height: 2),
                        Text('@${user.username}',
                            style: GoogleFonts.dmSans(
                                fontSize: 12, color: AppColors.textHint)),
                        if (user.bio.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(user.bio,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.dmSans(
                                  fontSize: 11, color: AppColors.textSec)),
                        ],
                      ]),
                    ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textHint, size: 20),
            ]),
          ),
        );
      },
    );
  }

  Widget _buildAvatar(UserModel? user) {
    const size = 48.0;
    if (user == null) {
      return Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.accentBg));
    }
    if (user.avatarBase64.isNotEmpty) {
      return ClipOval(
          child: SizedBox(
              width: size, height: size, child: ImageUtils.imageFromBase64(user.avatarBase64)));
    }
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryLight])),
      child: Center(
        child: Text(user.initials,
            style: GoogleFonts.dmSans(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
      ),
    );
  }
}
