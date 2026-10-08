import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/ui/l10n_ext.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/common.dart';
import 'auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(authControllerProvider.notifier)
          .login(_phone.text, _password.text);
    } on Object catch (e) {
      if (mounted) setState(() => _error = context.l10n.error(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    String? required(String? v) =>
        (v == null || v.trim().isEmpty) ? l10n.fieldRequired : null;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _Logo(),
                  const SizedBox(height: 20),
                  Text(
                    l10n.appTitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.loginSubtitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    key: const Key('login.phone'),
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.telephoneNumber],
                    style: theme.textTheme.bodyLarge,
                    decoration: InputDecoration(
                      labelText: l10n.phoneLabel,
                      hintText: '+374 91 000 007',
                      prefixIcon: const Icon(Icons.phone),
                      border: const OutlineInputBorder(),
                    ),
                    validator: required,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    key: const Key('login.password'),
                    controller: _password,
                    obscureText: _obscure,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.password],
                    onFieldSubmitted: (_) => _submit(),
                    style: theme.textTheme.bodyLarge,
                    decoration: InputDecoration(
                      labelText: l10n.passwordLabel,
                      prefixIcon: const Icon(Icons.lock),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: required,
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    MessageBanner(
                      message: _error!,
                      color: AppColors.error,
                      icon: Icons.error_outline,
                    ),
                  ],
                  const SizedBox(height: 24),
                  PrimaryButton(
                    key: const Key('login.submit'),
                    label: l10n.loginButton,
                    loading: _busy,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(l10n.forgotPassword),
                        content: Text(l10n.forgotPasswordBody),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(l10n.ok),
                          ),
                        ],
                      ),
                    ),
                    child: Text(l10n.forgotPassword),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Placeholder mark until the final NEST logo is supplied.
class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.charcoal, width: 4),
      ),
      alignment: Alignment.center,
      child: const Text(
        'N',
        style: TextStyle(
          fontSize: 56,
          fontWeight: FontWeight.w900,
          color: AppColors.charcoal,
        ),
      ),
    ),
  );
}

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _repeat = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _repeat.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(authControllerProvider.notifier)
          .changePassword(_current.text, _next.text);
    } on Object catch (e) {
      if (mounted) showMessage(context, context.l10n.error(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    InputDecoration deco(String label) =>
        InputDecoration(labelText: label, border: const OutlineInputBorder());
    return Scaffold(
      appBar: AppBar(title: Text(l10n.changePasswordTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _form,
          child: Column(
            children: [
              Text(
                l10n.changePasswordBody,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _current,
                obscureText: true,
                decoration: deco(l10n.currentPassword),
                validator: (v) => (v ?? '').isEmpty ? l10n.fieldRequired : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _next,
                obscureText: true,
                decoration: deco(l10n.newPassword),
                validator: (v) =>
                    (v ?? '').length < 8 ? l10n.passwordTooShort : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _repeat,
                obscureText: true,
                decoration: deco(l10n.repeatPassword),
                validator: (v) =>
                    v != _next.text ? l10n.passwordsDoNotMatch : null,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: l10n.savePassword,
                loading: _busy,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
