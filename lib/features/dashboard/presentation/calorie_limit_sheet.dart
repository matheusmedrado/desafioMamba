import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../domain/calorie_limit.dart';
import 'today_summary.dart';

/// Opens the form to change the daily calorie limit.
///
/// The sheet saves before closing, so a failed save keeps what was typed.
Future<void> showCalorieLimitSheet(
  BuildContext context, {
  required int currentLimit,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => CalorieLimitSheet(currentLimit: currentLimit),
  );
}

class CalorieLimitSheet extends ConsumerStatefulWidget {
  const CalorieLimitSheet({super.key, required this.currentLimit});

  final int currentLimit;

  @override
  ConsumerState<CalorieLimitSheet> createState() => _CalorieLimitSheetState();
}

class _CalorieLimitSheetState extends ConsumerState<CalorieLimitSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _limitController = TextEditingController(
    text: widget.currentLimit.toString(),
  );

  var _autovalidate = AutovalidateMode.disabled;
  var _saving = false;
  String? _error;

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    if (!_formKey.currentState!.validate()) {
      setState(() => _autovalidate = AutovalidateMode.onUserInteraction);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await ref
          .read(calorieLimitControllerProvider.notifier)
          .change(int.parse(_limitController.text.trim()));
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = 'Could not save the limit. Try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      // Keeps the form above the keyboard.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: Form(
            key: _formKey,
            autovalidateMode: _autovalidate,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Daily calorie limit', style: textTheme.titleLarge),
                const SizedBox(height: 6),
                Text(
                  'A day is within goal when its calories stay at or under '
                  'this limit and a fast reaches its goal.',
                  style: textTheme.bodySmall,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _limitController,
                  validator: CalorieLimit.validate,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  onFieldSubmitted: (_) => _save(),
                  decoration: const InputDecoration(
                    suffixText: 'kcal',
                    helperText: 'Whole numbers, 500 to 5,000',
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: textTheme.bodySmall?.copyWith(
                      color: MambaColors.danger,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: Text(_saving ? 'Saving...' : 'Save limit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
