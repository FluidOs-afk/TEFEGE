import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart' show AppColorsExt;
import '../models/user_model.dart';
import '../services/profile_service.dart';
import '../widgets/avatar_with_frame.dart';
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
      appBar: AppBar(
        title: Text(title, style: GoogleFonts.dmSans(fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: uids.isEmpty
          ? Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.people_outline_rounded, size: 56, color: context.colTextHint),
                const SizedBox(height: 14),
                Text('Nadie aquí todavía',
                    style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w700, fontSize: 16, color: context.colText)),
              ]),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: uids.length,
              separatorBuilder: (context, i) => Divider(height: 1, color: context.colBorder),
              itemBuilder: (context, i) => _UserRow(uid: uids[i], currentUid: currentUid),
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
        final isLoading = !snap.hasData;

        return GestureDetector(
          onTap: user == null
              ? null
              : () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => ProfileScreen(userId: user.uid))),
          child: Container(
            color: context.colBgCard,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(children: [
              // Avatar
              if (isLoading)
                Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: context.colAccentBg))
              else
                AvatarWithFrame(
                  base64: user!.avatarBase64.isNotEmpty ? user.avatarBase64 : null,
                  frameStyle: user.frameStyle,
                  radius: 24,
                  initials: user.initials,
                ),
              const SizedBox(width: 12),

              // Info
              if (isLoading)
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(height: 14, width: 120, decoration: BoxDecoration(
                        color: context.colBorder, borderRadius: BorderRadius.circular(4))),
                    const SizedBox(height: 6),
                    Container(height: 11, width: 80, decoration: BoxDecoration(
                        color: context.colBorder, borderRadius: BorderRadius.circular(4))),
                  ]),
                )
              else
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(user!.nombre,
                        style: GoogleFonts.dmSans(
                            fontWeight: FontWeight.w800, fontSize: 14, color: context.colText)),
                    const SizedBox(height: 2),
                    Text('@${user.username}',
                        style: GoogleFonts.dmSans(fontSize: 12, color: context.colTextHint)),
                    if (user.bio.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(user.bio,
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.dmSans(fontSize: 11, color: context.colTextSec)),
                    ],
                  ]),
                ),

              Icon(Icons.chevron_right_rounded, color: context.colTextHint, size: 20),
            ]),
          ),
        );
      },
    );
  }
}
