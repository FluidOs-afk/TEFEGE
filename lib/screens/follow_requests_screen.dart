import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart' show AppColors;
import '../models/user_model.dart';
import '../services/profile_service.dart';
import '../utils/image_utils.dart';
import 'profile_screen.dart';

class FollowRequestsScreen extends StatelessWidget {
  final UserModel owner;
  const FollowRequestsScreen({super.key, required this.owner});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: AppColors.bgCard,
        title: Text('Solicitudes de seguimiento',
            style: GoogleFonts.dmSans(fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: StreamBuilder<UserModel>(
        stream: ProfileService.instance.streamUser(owner.uid),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          final pending = snap.data?.pendingRequests ?? [];
          if (pending.isEmpty) {
            return Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.people_outline_rounded, size: 56, color: AppColors.textHint),
                const SizedBox(height: 14),
                Text('Sin solicitudes pendientes',
                    style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                Text('Cuando alguien quiera seguirte aparecerá aquí',
                    style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textHint),
                    textAlign: TextAlign.center),
              ]),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: pending.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (_, i) => _RequestTile(
              ownerUid: owner.uid,
              requesterUid: pending[i],
            ),
          );
        },
      ),
    );
  }
}

class _RequestTile extends StatefulWidget {
  final String ownerUid;
  final String requesterUid;
  const _RequestTile({required this.ownerUid, required this.requesterUid});

  @override
  State<_RequestTile> createState() => _RequestTileState();
}

class _RequestTileState extends State<_RequestTile> {
  bool _loading = false;

  Future<void> _accept() => _act(() =>
      ProfileService.instance.acceptFollowRequest(widget.ownerUid, widget.requesterUid));

  Future<void> _reject() => _act(() =>
      ProfileService.instance.rejectFollowRequest(widget.ownerUid, widget.requesterUid));

  Future<void> _act(Future<void> Function() fn) async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      await fn();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel>(
      future: ProfileService.instance.getUser(widget.requesterUid),
      builder: (context, snap) {
        final user = snap.data;
        return Container(
          color: AppColors.bgCard,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(children: [
            GestureDetector(
              onTap: user == null
                  ? null
                  : () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => ProfileScreen(userId: user.uid))),
              child: _buildAvatar(user),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: user == null
                    ? null
                    : () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => ProfileScreen(userId: user.uid))),
                child: user == null
                    ? const SizedBox(
                        height: 20,
                        child: LinearProgressIndicator(color: AppColors.primary))
                    : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(user.nombre,
                            style: GoogleFonts.dmSans(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: AppColors.textPrimary)),
                        const SizedBox(height: 2),
                        Text('@${user.username}',
                            style: GoogleFonts.dmSans(
                                fontSize: 12, color: AppColors.textHint)),
                      ]),
              ),
            ),
            const SizedBox(width: 8),
            if (_loading)
              const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
            else
              Row(mainAxisSize: MainAxisSize.min, children: [
                FilledButton(
                  onPressed: _accept,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text('Aceptar',
                      style: GoogleFonts.dmSans(fontWeight: FontWeight.w700, fontSize: 12)),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: _reject,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: Text('Rechazar',
                      style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: AppColors.textSec)),
                ),
              ]),
          ]),
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
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.accentBg,
        ),
      );
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
        gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryLight]),
      ),
      child: Center(
        child: Text(user.initials,
            style: GoogleFonts.dmSans(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
      ),
    );
  }
}
