import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/mamba_icon.dart';
import '../../../app/theme.dart';
import '../../../core/clock.dart';
import '../../../core/formatting.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/meal.dart';
import '../domain/meal_validator.dart';
import 'meals_controller.dart';

enum MealFormResult { added, updated, deleteRequested }

/// Opens the add form, or the edit form when [meal] is given.
///
/// The sheet saves before closing, so a failed save keeps what was typed.
Future<MealFormResult?> showMealFormSheet(BuildContext context, {Meal? meal}) {
  return showModalBottomSheet<MealFormResult>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => MealFormSheet(meal: meal),
  );
}

/// Returns true to delete, false to go back to the form, or null if the sheet
/// was dismissed.
Future<bool?> showDeleteMealSheet(BuildContext context, Meal meal) {
  return showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      final l10n = AppLocalizations.of(context)!;
      final textTheme = Theme.of(context).textTheme;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.deleteThisMeal, style: textTheme.titleLarge),
              const SizedBox(height: 6),
              Text(
                l10n.deleteMealBody(meal.name),
                style: textTheme.bodyMedium?.copyWith(
                  color: MambaColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(l10n.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: FilledButton.styleFrom(
                        backgroundColor: MambaColors.danger,
                        foregroundColor: MambaColors.textPrimary,
                      ),
                      child: Text(l10n.delete),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

class MealFormSheet extends ConsumerStatefulWidget {
  const MealFormSheet({super.key, this.meal});

  final Meal? meal;

  @override
  ConsumerState<MealFormSheet> createState() => _MealFormSheetState();
}

class _MealFormSheetState extends ConsumerState<MealFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(text: widget.meal?.name);
  late final _caloriesController = TextEditingController(
    text: widget.meal?.calories.toString(),
  );
  // A new meal is saved with the time of the tap on Save. The time shown here
  // is when the sheet opened, which is the same minute in practice.
  late final _time = widget.meal?.eatenAt ?? ref.read(clockProvider).now();

  var _autovalidate = AutovalidateMode.disabled;
  var _saving = false;
  var _failed = false;

  bool get _editing => widget.meal != null;

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
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
      _failed = false;
    });

    final controller = ref.read(mealsControllerProvider.notifier);
    final name = _nameController.text;
    final calories = int.parse(_caloriesController.text.trim());
    try {
      final meal = widget.meal;
      if (meal == null) {
        await controller.add(name: name, calories: calories);
      } else {
        await controller.edit(meal, name: name, calories: calories);
      }
      if (!mounted) return;
      Navigator.of(context)
          .pop(_editing ? MealFormResult.updated : MealFormResult.added);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _failed = true;
      });
    }
  }

  String? _nameError(AppLocalizations l10n, String? value) {
    return switch (MealValidator.name(value)) {
      null => null,
      MealFieldError.nameRequired => l10n.errorMealName,
      MealFieldError.nameTooLong => l10n.errorMealNameTooLong(
        MealValidator.maxNameLength,
      ),
      MealFieldError.calories => null,
    };
  }

  String? _caloriesError(AppLocalizations l10n, String? value) {
    return MealValidator.calories(value) == null
        ? null
        : l10n.errorMealCalories(formatThousands(MealValidator.maxCalories));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                Text(
                  _editing ? l10n.editMealTitle : l10n.addMeal,
                  style: textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const MambaIcon(
                      MambaIcons.clock,
                      size: 16,
                      color: MambaColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.mealTimeRecorded(formatClockTime(_time)),
                        style: textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _FieldLabel(l10n.mealNameLabel),
                TextFormField(
                  controller: _nameController,
                  validator: (value) => _nameError(l10n, value),
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(
                      MealValidator.maxNameLength,
                    ),
                  ],
                  decoration: InputDecoration(hintText: l10n.mealNameHint),
                ),
                const SizedBox(height: 16),
                _FieldLabel(l10n.caloriesLabel),
                TextFormField(
                  controller: _caloriesController,
                  validator: (value) => _caloriesError(l10n, value),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  onFieldSubmitted: (_) => _save(),
                  decoration: InputDecoration(
                    hintText: '0',
                    suffixText: l10n.kcal,
                    helperText: l10n.caloriesHelper,
                  ),
                ),
                if (_failed) ...[
                  const SizedBox(height: 12),
                  Text(
                    l10n.mealSaveError,
                    style: textTheme.bodySmall?.copyWith(
                      color: MambaColors.danger,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: Text(
                    _saving
                        ? l10n.saving
                        : _editing
                        ? l10n.saveChanges
                        : l10n.saveMeal,
                  ),
                ),
                if (_editing) ...[
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: _saving
                        ? null
                        : () =>
                              Navigator.of(context)
                                  .pop(MealFormResult.deleteRequested),
                    style: TextButton.styleFrom(
                      foregroundColor: MambaColors.danger,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    icon: const MambaIcon(
                      MambaIcons.trash,
                      size: 20,
                      color: MambaColors.danger,
                    ),
                    label: Text(l10n.deleteMeal),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: Theme.of(context).textTheme.labelMedium),
    );
  }
}
