// Ecilaes - Cross-platform music player
// Copyright (c) 2026 hxprlee
// SPDX-License-Identifier: MIT
import 'package:flutter/material.dart';
import '../../signals/settings_signal.dart';
import '../../services/scrobble_service.dart';
import 'app_dialog.dart';

class LastFmAuthDialog extends StatefulWidget {
  const LastFmAuthDialog({super.key});

  @override
  State<LastFmAuthDialog> createState() => _LastFmAuthDialogState();
}

class _LastFmAuthDialogState extends State<LastFmAuthDialog> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() => _error = 'Please enter username and password');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await scrobbleService.authenticate(username, password);

    if (!mounted) return;

    if (result != null) {
      settingsSignal.updateLastFmSession(result['username'], result['key']);
      Navigator.of(context).pop();
    } else {
      setState(() {
        _isLoading = false;
        _error = 'Authentication failed. Please check your credentials.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: 'Last.fm Scrobbling',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Connect your Last.fm account to automatically scrobble the tracks you play.',
            style: TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _usernameController,
            decoration: const InputDecoration(
              labelText: 'Username',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _passwordController,
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            obscureText: true,
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Connect'),
        ),
      ],
    );
  }
}
