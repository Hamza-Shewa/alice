import 'package:alice/core/alice_core.dart';
import 'package:alice/helper/alice_watcher.dart';
import 'package:alice/model/alice_translation.dart';
import 'package:alice/ui/common/alice_app_bar.dart';
import 'package:alice/ui/common/alice_context_ext.dart';
import 'package:alice/ui/common/alice_detail_widgets.dart';
import 'package:alice/ui/common/alice_dialog.dart';
import 'package:alice/ui/common/alice_page.dart';
import 'package:alice/ui/common/alice_scroll_behavior.dart';
import 'package:alice/ui/common/alice_settings.dart';
import 'package:alice/ui/common/alice_theme.dart';
import 'package:alice/ui/common/alice_watcher_widgets.dart';
import 'package:flutter/material.dart';

/// Page where the user chooses which response fields are watched and what
/// their values mean.
class AliceWatcherPage extends StatefulWidget {
  const AliceWatcherPage({super.key, required this.core});

  final AliceCore core;

  @override
  State<AliceWatcherPage> createState() => _AliceWatcherPageState();
}

class _AliceWatcherPageState extends State<AliceWatcherPage>
    with AliceSettingsListenerMixin {
  AliceWatcher get _watcher => AliceWatcher.instance;

  @override
  Widget build(BuildContext context) {
    final List<AliceWatchedField> fields = _watcher.fields;
    return AlicePage(
      core: widget.core,
      child: Builder(
        builder:
            (BuildContext context) => Scaffold(
              appBar: AliceAppBar(
                title: Text(context.i18n(AliceTranslationKey.watcher)),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.restart_alt),
                    tooltip: context.i18n(AliceTranslationKey.watcherReset),
                    onPressed: () => _confirmReset(context),
                  ),
                ],
              ),
              body: ScrollConfiguration(
                behavior: AliceScrollBehavior(),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  children: [
                    _Description(
                      text: context.i18n(
                        AliceTranslationKey.watcherDescription,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (fields.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Text(
                            context.i18n(AliceTranslationKey.watcherNoFields),
                          ),
                        ),
                      ),
                    for (final AliceWatchedField field in fields) ...[
                      _FieldCard(
                        key: ObjectKey(field),
                        field: field,
                        initiallyExpanded: fields.length == 1,
                        onChanged: _onChanged,
                        onDelete: () {
                          _watcher.fields.remove(field);
                          _onChanged();
                        },
                      ),
                      const SizedBox(height: 12),
                    ],
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: FilledButton.icon(
                        icon: const Icon(Icons.add),
                        label: Text(
                          context.i18n(AliceTranslationKey.watcherAddField),
                        ),
                        onPressed: () => _addField(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ),
    );
  }

  /// Saves the change and refreshes the page via [AliceSettingsListenerMixin].
  void _onChanged() {
    _watcher.changed();
  }

  Future<void> _confirmReset(BuildContext context) {
    return AliceGeneralDialog.show(
      context: context,
      title: context.i18n(AliceTranslationKey.watcherReset),
      description: context.i18n(AliceTranslationKey.watcherResetConfirm),
      firstButtonTitle: context.i18n(AliceTranslationKey.callsListNo),
      secondButtonTitle: context.i18n(AliceTranslationKey.callsListYes),
      secondButtonAction: _watcher.reset,
    );
  }

  Future<void> _addField(BuildContext context) async {
    final String? path = await showDialog<String>(
      context: context,
      builder:
          (BuildContext dialogContext) => Theme(
            data: AliceTheme.getTheme(
              brightness: AliceTheme.resolveBrightness(context),
            ),
            child: const _AddFieldDialog(),
          ),
    );
    if (path == null || path.trim().isEmpty) {
      return;
    }
    _watcher.fields.add(
      AliceWatchedField(path: path.trim(), values: [AliceWatchedValue()]),
    );
    _onChanged();
  }
}

/// Dialog which asks for the name of a new watched field. It owns its text
/// controller, so it is disposed only after the dialog is gone.
class _AddFieldDialog extends StatefulWidget {
  const _AddFieldDialog();

  @override
  State<_AddFieldDialog> createState() => _AddFieldDialogState();
}

class _AddFieldDialogState extends State<_AddFieldDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.i18n(AliceTranslationKey.watcherAddField)),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textDirection: TextDirection.ltr,
        decoration: InputDecoration(
          labelText: context.i18n(AliceTranslationKey.watcherFieldName),
          hintText: context.i18n(AliceTranslationKey.watcherFieldHint),
        ),
        onSubmitted: (String value) => Navigator.pop(context, value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: Text(context.i18n(AliceTranslationKey.watcherAddField)),
        ),
      ],
    );
  }
}

/// Card which explains what the watcher does.
class _Description extends StatelessWidget {
  const _Description({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return AliceOutlinedCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.visibility_outlined,
            color: theme.colorScheme.primary,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

/// Expandable panel of one watched field.
class _FieldCard extends StatelessWidget {
  const _FieldCard({
    super.key,
    required this.field,
    required this.initiallyExpanded,
    required this.onChanged,
    required this.onDelete,
  });

  final AliceWatchedField field;
  final bool initiallyExpanded;
  final VoidCallback onChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return AliceCollapsibleSection(
      icon: Icons.visibility_outlined,
      title: field.path.isEmpty ? '—' : field.path,
      count: field.values.length,
      initiallyExpanded: initiallyExpanded,
      action:
          field.useAsStatus
              ? Icon(
                Icons.check_circle,
                size: 20,
                color: theme.colorScheme.primary,
              )
              : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            initialValue: field.path,
            textDirection: TextDirection.ltr,
            decoration: InputDecoration(
              isDense: true,
              border: const OutlineInputBorder(),
              labelText: context.i18n(AliceTranslationKey.watcherFieldName),
              hintText: context.i18n(AliceTranslationKey.watcherFieldHint),
            ),
            onChanged: (String value) {
              field.path = value;
              onChanged();
            },
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.i18n(AliceTranslationKey.watcherUseAsStatus),
                      style: theme.textTheme.bodyLarge,
                    ),
                    Text(
                      context.i18n(AliceTranslationKey.watcherUseAsStatusHint),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: field.useAsStatus,
                activeTrackColor: AliceTheme.lightRed,
                onChanged: (bool value) {
                  field.useAsStatus = value;
                  onChanged();
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            context.i18n(AliceTranslationKey.watcherValues),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          if (field.values.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                context.i18n(AliceTranslationKey.watcherNoValues),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          for (final AliceWatchedValue value in field.values) ...[
            _ValueRow(
              key: ObjectKey(value),
              value: value,
              onChanged: onChanged,
              onDelete: () {
                field.values.remove(value);
                onChanged();
              },
            ),
            const SizedBox(height: 8),
          ],
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.add, size: 18),
                label: Text(context.i18n(AliceTranslationKey.watcherAddValue)),
                onPressed: () {
                  field.values.add(AliceWatchedValue());
                  onChanged();
                },
              ),
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                ),
                icon: const Icon(Icons.delete_outline, size: 18),
                label: Text(context.i18n(AliceTranslationKey.watcherDelete)),
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// One value of a watched field: the value, its meaning and an outcome.
class _ValueRow extends StatelessWidget {
  const _ValueRow({
    super.key,
    required this.value,
    required this.onChanged,
    required this.onDelete,
  });

  final AliceWatchedValue value;
  final VoidCallback onChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color color = aliceWatchOutcomeColor(context, value.outcome);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(10),
        color: color.withValues(alpha: 0.05),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 88,
                child: TextFormField(
                  initialValue: value.value,
                  textDirection: TextDirection.ltr,
                  decoration: InputDecoration(
                    isDense: true,
                    border: const OutlineInputBorder(),
                    labelText: context.i18n(AliceTranslationKey.watcherValue),
                  ),
                  onChanged: (String text) {
                    value.value = text;
                    onChanged();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  initialValue: value.meaning,
                  decoration: InputDecoration(
                    isDense: true,
                    border: const OutlineInputBorder(),
                    labelText: context.i18n(AliceTranslationKey.watcherMeaning),
                  ),
                  onChanged: (String text) {
                    value.meaning = text;
                    onChanged();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<AliceWatchOutcome>(
                    isExpanded: true,
                    value: value.outcome,
                    items: [
                      for (final AliceWatchOutcome outcome
                          in AliceWatchOutcome.values)
                        DropdownMenuItem<AliceWatchOutcome>(
                          value: outcome,
                          child: Row(
                            children: [
                              Icon(
                                aliceWatchOutcomeIcon(outcome),
                                size: 18,
                                color: aliceWatchOutcomeColor(context, outcome),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  aliceWatchOutcomeLabel(context, outcome),
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                    onChanged: (AliceWatchOutcome? outcome) {
                      if (outcome != null) {
                        value.outcome = outcome;
                        onChanged();
                      }
                    },
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                tooltip: context.i18n(AliceTranslationKey.watcherDelete),
                visualDensity: VisualDensity.compact,
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
