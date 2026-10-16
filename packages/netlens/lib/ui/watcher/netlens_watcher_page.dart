import 'package:netlens/core/netlens_core.dart';
import 'package:netlens/helper/netlens_watcher.dart';
import 'package:netlens/model/netlens_translation.dart';
import 'package:netlens/ui/common/netlens_app_bar.dart';
import 'package:netlens/ui/common/netlens_context_ext.dart';
import 'package:netlens/ui/common/netlens_detail_widgets.dart';
import 'package:netlens/ui/common/netlens_dialog.dart';
import 'package:netlens/ui/common/netlens_page.dart';
import 'package:netlens/ui/common/netlens_scroll_behavior.dart';
import 'package:netlens/ui/common/netlens_settings.dart';
import 'package:netlens/ui/common/netlens_theme.dart';
import 'package:netlens/ui/common/netlens_watcher_widgets.dart';
import 'package:flutter/material.dart';

/// Page where the user chooses which response fields are watched and what
/// their values mean.
class NetLensWatcherPage extends StatefulWidget {
  const NetLensWatcherPage({super.key, required this.core});

  final NetLensCore core;

  @override
  State<NetLensWatcherPage> createState() => _NetLensWatcherPageState();
}

class _NetLensWatcherPageState extends State<NetLensWatcherPage>
    with NetLensSettingsListenerMixin {
  NetLensWatcher get _watcher => NetLensWatcher.instance;

  @override
  Widget build(BuildContext context) {
    final List<NetLensWatchedField> fields = _watcher.fields;
    return NetLensPage(
      core: widget.core,
      child: Builder(
        builder:
            (BuildContext context) => Scaffold(
              appBar: NetLensAppBar(
                title: Text(context.i18n(NetLensTranslationKey.watcher)),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.restart_alt),
                    tooltip: context.i18n(NetLensTranslationKey.watcherReset),
                    onPressed: () => _confirmReset(context),
                  ),
                ],
              ),
              body: ScrollConfiguration(
                behavior: NetLensScrollBehavior(),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  children: [
                    _Description(
                      text: context.i18n(
                        NetLensTranslationKey.watcherDescription,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (fields.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Text(
                            context.i18n(NetLensTranslationKey.watcherNoFields),
                          ),
                        ),
                      ),
                    for (final NetLensWatchedField field in fields) ...[
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
                          context.i18n(NetLensTranslationKey.watcherAddField),
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

  /// Saves the change and refreshes the page via [NetLensSettingsListenerMixin].
  void _onChanged() {
    _watcher.changed();
  }

  Future<void> _confirmReset(BuildContext context) {
    return NetLensGeneralDialog.show(
      context: context,
      title: context.i18n(NetLensTranslationKey.watcherReset),
      description: context.i18n(NetLensTranslationKey.watcherResetConfirm),
      firstButtonTitle: context.i18n(NetLensTranslationKey.callsListNo),
      secondButtonTitle: context.i18n(NetLensTranslationKey.callsListYes),
      secondButtonAction: _watcher.reset,
    );
  }

  Future<void> _addField(BuildContext context) async {
    final String? path = await showDialog<String>(
      context: context,
      builder:
          (BuildContext dialogContext) => Theme(
            data: NetLensTheme.getTheme(
              brightness: NetLensTheme.resolveBrightness(context),
            ),
            child: const _AddFieldDialog(),
          ),
    );
    if (path == null || path.trim().isEmpty) {
      return;
    }
    _watcher.fields.add(
      NetLensWatchedField(path: path.trim(), values: [NetLensWatchedValue()]),
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
      title: Text(context.i18n(NetLensTranslationKey.watcherAddField)),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textDirection: TextDirection.ltr,
        decoration: InputDecoration(
          labelText: context.i18n(NetLensTranslationKey.watcherFieldName),
          hintText: context.i18n(NetLensTranslationKey.watcherFieldHint),
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
          child: Text(context.i18n(NetLensTranslationKey.watcherAddField)),
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
    return NetLensOutlinedCard(
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

  final NetLensWatchedField field;
  final bool initiallyExpanded;
  final VoidCallback onChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return NetLensCollapsibleSection(
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
              labelText: context.i18n(NetLensTranslationKey.watcherFieldName),
              hintText: context.i18n(NetLensTranslationKey.watcherFieldHint),
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
                      context.i18n(NetLensTranslationKey.watcherUseAsStatus),
                      style: theme.textTheme.bodyLarge,
                    ),
                    Text(
                      context.i18n(
                        NetLensTranslationKey.watcherUseAsStatusHint,
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: field.useAsStatus,
                activeTrackColor: NetLensTheme.lightRed,
                onChanged: (bool value) {
                  field.useAsStatus = value;
                  onChanged();
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            context.i18n(NetLensTranslationKey.watcherValues),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          if (field.values.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                context.i18n(NetLensTranslationKey.watcherNoValues),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          for (final NetLensWatchedValue value in field.values) ...[
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
                label: Text(
                  context.i18n(NetLensTranslationKey.watcherAddValue),
                ),
                onPressed: () {
                  field.values.add(NetLensWatchedValue());
                  onChanged();
                },
              ),
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                ),
                icon: const Icon(Icons.delete_outline, size: 18),
                label: Text(context.i18n(NetLensTranslationKey.watcherDelete)),
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

  final NetLensWatchedValue value;
  final VoidCallback onChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color color = netLensWatchOutcomeColor(context, value.outcome);
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
                    labelText: context.i18n(NetLensTranslationKey.watcherValue),
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
                    labelText: context.i18n(
                      NetLensTranslationKey.watcherMeaning,
                    ),
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
                  child: DropdownButton<NetLensWatchOutcome>(
                    isExpanded: true,
                    value: value.outcome,
                    items: [
                      for (final NetLensWatchOutcome outcome
                          in NetLensWatchOutcome.values)
                        DropdownMenuItem<NetLensWatchOutcome>(
                          value: outcome,
                          child: Row(
                            children: [
                              Icon(
                                netLensWatchOutcomeIcon(outcome),
                                size: 18,
                                color: netLensWatchOutcomeColor(
                                  context,
                                  outcome,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  netLensWatchOutcomeLabel(context, outcome),
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
                    onChanged: (NetLensWatchOutcome? outcome) {
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
                tooltip: context.i18n(NetLensTranslationKey.watcherDelete),
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
