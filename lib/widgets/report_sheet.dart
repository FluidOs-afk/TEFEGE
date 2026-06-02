import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart' show AppColors, AppColorsExt;
import '../models/report_model.dart';
import '../services/report_service.dart';

const _kReasons = [
  (ReportReason.spam, 'Spam o contenido repetitivo'),
  (ReportReason.hateSpeech, 'Lenguaje ofensivo u odio'),
  (ReportReason.inappropriate, 'Contenido inapropiado'),
  (ReportReason.harassment, 'Acoso o intimidación'),
  (ReportReason.other, 'Otro motivo'),
];

Future<void> showReportSheet(
  BuildContext parentContext, {
  required String reporterId,
  required String targetId,
  required ReportTargetType targetType,
}) async {
  await showModalBottomSheet<void>(
    context: parentContext,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => _ReportSheetContent(
      parentContext: parentContext,
      reporterId: reporterId,
      targetId: targetId,
      targetType: targetType,
    ),
  );
}

class _ReportSheetContent extends StatefulWidget {
  final BuildContext parentContext;
  final String reporterId;
  final String targetId;
  final ReportTargetType targetType;

  const _ReportSheetContent({
    required this.parentContext,
    required this.reporterId,
    required this.targetId,
    required this.targetType,
  });

  @override
  State<_ReportSheetContent> createState() => _ReportSheetContentState();
}

class _ReportSheetContentState extends State<_ReportSheetContent> {
  ReportReason? _selectedReason;
  final _descCtrl = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedReason == null) return;
    setState(() => _sending = true);
    try {
      await ReportService.instance.submitReport(ReportModel(
        id: '',
        reporterId: widget.reporterId,
        targetId: widget.targetId,
        targetType: widget.targetType,
        reason: _selectedReason!,
        description: _descCtrl.text.trim(),
        createdAt: DateTime.now(),
      ));
      if (mounted) Navigator.of(context).pop();
      if (widget.parentContext.mounted) {
        ScaffoldMessenger.of(widget.parentContext).showSnackBar(
          SnackBar(
            content: Text(
              'Denuncia enviada. La revisaremos en breve.',
              style: GoogleFonts.dmSans(),
            ),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (_) {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: context.colBgCard,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: context.colBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Denunciar contenido',
                    style: GoogleFonts.dmSans(
                        fontSize: 18, fontWeight: FontWeight.w800,
                        color: context.colText)),
                const SizedBox(height: 4),
                Text('Ayúdanos a mantener OUTFY seguro',
                    style: GoogleFonts.dmSans(
                        color: context.colTextSec, fontSize: 13)),
                const SizedBox(height: 14),
                RadioGroup<ReportReason>(
                  groupValue: _selectedReason,
                  onChanged: (v) => setState(() => _selectedReason = v),
                  child: Column(
                    children: _kReasons.map((entry) => RadioListTile<ReportReason>(
                      value: entry.$1,
                      title: Text(entry.$2,
                          style: GoogleFonts.dmSans(
                              fontSize: 14, color: context.colText)),
                      activeColor: AppColors.primary,
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    )).toList(),
                  ),
                ),
                if (_selectedReason == ReportReason.other) ...[
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descCtrl,
                    maxLines: 2,
                    style: GoogleFonts.dmSans(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Describe el problema (opcional)',
                      hintStyle: GoogleFonts.dmSans(
                          color: context.colTextHint, fontSize: 13),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: context.colBorder)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: context.colBorder)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: AppColors.primary, width: 1.5)),
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (_selectedReason == null || _sending)
                        ? null
                        : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _sending
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : Text('Enviar denuncia',
                            style: GoogleFonts.dmSans(
                                fontWeight: FontWeight.w700, fontSize: 15)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
