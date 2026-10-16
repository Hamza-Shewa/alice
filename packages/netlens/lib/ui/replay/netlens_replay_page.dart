import 'package:netlens/core/netlens_core.dart';
import 'package:netlens/model/netlens_http_call.dart';
import 'package:netlens/model/netlens_replay_request.dart';
import 'package:netlens/model/netlens_translation.dart';
import 'package:netlens/ui/common/netlens_app_bar.dart';
import 'package:netlens/ui/common/netlens_context_ext.dart';
import 'package:netlens/ui/common/netlens_page.dart';
import 'package:netlens/ui/common/netlens_scroll_behavior.dart';
import 'package:netlens/ui/common/netlens_theme.dart';
import 'package:flutter/material.dart';

/// Page where a caught call can be edited and sent again with the client
/// which made it.
class NetLensReplayPage extends StatefulWidget {
  const NetLensReplayPage({super.key, required this.call, required this.core});

  final NetLensHttpCall call;
  final NetLensCore core;

  @override
  State<NetLensReplayPage> createState() => _NetLensReplayPageState();
}

class _NetLensReplayPageState extends State<NetLensReplayPage> {
  static const List<String> _methods = [
    'GET',
    'POST',
    'PUT',
    'PATCH',
    'DELETE',
    'HEAD',
    'OPTIONS',
  ];

  late NetLensReplayRequest _original;
  late String _method;
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _headersController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  String? _urlError;
  String? _headersError;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _original = NetLensReplayRequest.fromCall(widget.call);
    _reset();
  }

  @override
  void dispose() {
    _urlController.dispose();
    _headersController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  /// Fills the form with the original call.
  void _reset() {
    _method = _original.method;
    _urlController.text = _original.url;
    _headersController.text = NetLensReplayRequest.headersToText(
      _original.headers,
    );
    _bodyController.text = _original.body ?? '';
    _urlError = null;
    _headersError = null;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<String> methods = [
      ..._methods,
      if (!_methods.contains(_method)) _method,
    ];
    return NetLensPage(
      core: widget.core,
      child: Scaffold(
        appBar: NetLensAppBar(
          title: Text(context.i18n(NetLensTranslationKey.replayAction)),
          actions: [
            IconButton(
              icon: const Icon(Icons.restart_alt),
              tooltip: context.i18n(NetLensTranslationKey.replayReset),
              onPressed: _sending ? null : () => setState(_reset),
            ),
          ],
        ),
        body: ScrollConfiguration(
          behavior: NetLensScrollBehavior(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              if (_original.omitsFormData) ...[
                _Warning(
                  text: context.i18n(
                    NetLensTranslationKey.replayFormDataWarning,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              DropdownButtonFormField<String>(
                // Keyed by the method, so reset shows the original method.
                key: ValueKey<String>('netlens_replay_method_$_method'),
                // `initialValue` replaces this from Flutter 3.35, but NetLens
                // still supports Flutter 3.29.
                // ignore: deprecated_member_use
                value: _method,
                decoration: InputDecoration(
                  labelText: context.i18n(NetLensTranslationKey.replayMethod),
                  border: const OutlineInputBorder(),
                ),
                items: [
                  for (final String method in methods)
                    DropdownMenuItem(value: method, child: Text(method)),
                ],
                onChanged:
                    (String? method) =>
                        setState(() => _method = method ?? _method),
              ),
              const SizedBox(height: 16),
              _CodeField(
                key: const Key('netlens_replay_url'),
                controller: _urlController,
                label: context.i18n(NetLensTranslationKey.replayUrl),
                errorText: _urlError,
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              _CodeField(
                key: const Key('netlens_replay_headers'),
                controller: _headersController,
                label: context.i18n(NetLensTranslationKey.replayHeaders),
                helperText: context.i18n(
                  NetLensTranslationKey.replayHeadersHint,
                ),
                errorText: _headersError,
                maxLines: 10,
              ),
              const SizedBox(height: 16),
              _CodeField(
                key: const Key('netlens_replay_body'),
                controller: _bodyController,
                label: context.i18n(NetLensTranslationKey.replayBody),
                maxLines: 16,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                key: const Key('netlens_replay_send'),
                style: FilledButton.styleFrom(
                  backgroundColor: NetLensTheme.lightRed,
                  foregroundColor: NetLensTheme.white,
                  minimumSize: const Size.fromHeight(48),
                  textStyle: theme.textTheme.titleMedium,
                ),
                onPressed: _sending ? null : _send,
                icon:
                    _sending
                        ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: NetLensTheme.white,
                          ),
                        )
                        : const Icon(Icons.send),
                label: Text(context.i18n(NetLensTranslationKey.replaySend)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Validates the form and sends the request. Goes back to the call when
  /// the request was sent.
  Future<void> _send() async {
    final String url = _urlController.text.trim();
    final Uri? uri = Uri.tryParse(url);
    final bool isValidUrl = uri != null && uri.hasScheme && uri.host.isNotEmpty;
    final ({Map<String, String> headers, int? invalidLine}) parsed =
        NetLensReplayRequest.parseHeaders(_headersController.text);
    setState(() {
      _urlError =
          isValidUrl
              ? null
              : context.i18n(NetLensTranslationKey.replayInvalidUrl);
      _headersError =
          parsed.invalidLine == null
              ? null
              : context
                  .i18n(NetLensTranslationKey.replayInvalidHeader)
                  .replaceAll('[line]', '${parsed.invalidLine}');
    });
    if (!isValidUrl || parsed.invalidLine != null) {
      return;
    }

    final NetLensReplayRequest request = NetLensReplayRequest(
      method: _method,
      url: url,
      headers: parsed.headers,
      body: _bodyController.text.isEmpty ? null : _bodyController.text,
    );
    final ScaffoldMessengerState? messenger = ScaffoldMessenger.maybeOf(
      context,
    );
    final NavigatorState navigator = Navigator.of(context);
    setState(() => _sending = true);
    String message = context.i18n(NetLensTranslationKey.replaySent);
    try {
      await widget.core.replay(widget.call, request);
    } catch (error) {
      // An error response is caught by NetLens as a new call too, so the error
      // only explains why the request ended.
      if (mounted) {
        message = context
            .i18n(NetLensTranslationKey.replayFailed)
            .replaceAll('[error]', '$error');
      }
    }
    if (!mounted) {
      return;
    }
    setState(() => _sending = false);
    navigator.pop();
    messenger
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }
}

/// Monospace multi-line text field for technical values.
class _CodeField extends StatelessWidget {
  const _CodeField({
    super.key,
    required this.controller,
    required this.label,
    this.helperText,
    this.errorText,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final String? helperText;
  final String? errorText;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: 1,
      maxLines: maxLines,
      keyboardType: TextInputType.multiline,
      autocorrect: false,
      enableSuggestions: false,
      textDirection: TextDirection.ltr,
      style: const TextStyle(
        fontFamily: 'monospace',
        fontFamilyFallback: ['Courier', 'Menlo'],
        fontSize: 13,
      ),
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        helperMaxLines: 2,
        errorText: errorText,
        errorMaxLines: 3,
        border: const OutlineInputBorder(),
        alignLabelWithHint: true,
      ),
    );
  }
}

/// Box which warns about a limitation of the form.
class _Warning extends StatelessWidget {
  const _Warning({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final Color color = NetLensTheme.getStatusColor(context, 300);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_outlined, size: 20, color: color),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
