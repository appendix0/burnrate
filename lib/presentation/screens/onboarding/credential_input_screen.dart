import 'package:burnrate/core/constants/app_colors.dart';
import 'package:burnrate/core/constants/service_metadata.dart';
import 'package:burnrate/core/constants/storage_keys.dart';
import 'package:burnrate/data/models/credential.dart';
import 'package:burnrate/data/models/service_type.dart';
import 'package:burnrate/presentation/providers/credential_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CredentialInputScreen extends ConsumerStatefulWidget {
  const CredentialInputScreen({super.key, required this.remaining});

  /// Service names (ServiceType.name) still to be configured, current is first.
  final List<String> remaining;

  @override
  ConsumerState<CredentialInputScreen> createState() =>
      _CredentialInputScreenState();
}

class _CredentialInputScreenState extends ConsumerState<CredentialInputScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;
  bool _obscure = true;

  // Credential controllers
  final _apiKeyCtrl = TextEditingController();
  final _projectIdCtrl = TextEditingController();
  final _accessKeyIdCtrl = TextEditingController();
  final _secretKeyCtrl = TextEditingController();
  final _regionCtrl = TextEditingController();
  final _tenancyOcidCtrl = TextEditingController();
  final _userOcidCtrl = TextEditingController();
  final _fingerprintCtrl = TextEditingController();
  final _privateKeyCtrl = TextEditingController();

  // Capacity controller (shared across all service types)
  final _capacityCtrl = TextEditingController();

  ServiceType get _currentType =>
      ServiceType.values.byName(widget.remaining.first);

  int get _remaining => widget.remaining.length;

  @override
  void dispose() {
    _apiKeyCtrl.dispose();
    _projectIdCtrl.dispose();
    _accessKeyIdCtrl.dispose();
    _secretKeyCtrl.dispose();
    _regionCtrl.dispose();
    _tenancyOcidCtrl.dispose();
    _userOcidCtrl.dispose();
    _fingerprintCtrl.dispose();
    _privateKeyCtrl.dispose();
    _capacityCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final credRepo = ref.read(credentialRepositoryProvider);
    final capacityRepo = ref.read(capacityRepositoryProvider);

    await credRepo.save(_buildCredential());
    ref.invalidate(configuredServicesProvider);

    final capacityText = _capacityCtrl.text.trim();
    if (capacityText.isNotEmpty) {
      final capacity = double.tryParse(capacityText);
      if (capacity != null && capacity > 0) {
        await capacityRepo.set(_currentType, capacity);
      }
    }

    final next = widget.remaining.sublist(1);
    if (next.isEmpty) {
      await ref
          .read(sharedPreferencesProvider)
          .setBool(StorageKeys.onboardingComplete, true);
      if (mounted) context.go('/dashboard');
    } else {
      if (mounted) {
        context.pushReplacement('/onboarding/credentials', extra: next);
      }
    }
  }

  Credential _buildCredential() {
    return switch (_currentType) {
      ServiceType.anthropic =>
        AnthropicCredential(apiKey: _apiKeyCtrl.text.trim()),
      ServiceType.openai =>
        OpenAICredential(apiKey: _apiKeyCtrl.text.trim()),
      ServiceType.gemini => GeminiCredential(
          apiKey: _apiKeyCtrl.text.trim(),
          projectId: _projectIdCtrl.text.trim().isEmpty
              ? null
              : _projectIdCtrl.text.trim(),
        ),
      ServiceType.aws => AWSCredential(
          accessKeyId: _accessKeyIdCtrl.text.trim(),
          secretAccessKey: _secretKeyCtrl.text.trim(),
          region: _regionCtrl.text.trim(),
        ),
      ServiceType.oracle => OCICredential(
          tenancyOcid: _tenancyOcidCtrl.text.trim(),
          userOcid: _userOcidCtrl.text.trim(),
          fingerprint: _fingerprintCtrl.text.trim(),
          privateKeyPem: _privateKeyCtrl.text.trim(),
          region: _regionCtrl.text.trim(),
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final meta = kServiceMeta[_currentType]!;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                // Service header
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: meta.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(meta.icon, color: meta.color, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(meta.displayName,
                            style: theme.textTheme.titleLarge),
                        Text(
                          '$_remaining service${_remaining == 1 ? '' : 's'} remaining',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Credential fields
                ..._buildCredentialFields(),
                const SizedBox(height: 24),
                // Capacity section
                _SectionLabel(
                  label: 'Usage limit',
                  subtitle: _capacityLabel,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _capacityCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 14),
                  decoration: const InputDecoration(
                    labelText: 'Amount (USD) — optional',
                    hintText: '100.00',
                    prefixText: '\$ ',
                    prefixStyle: TextStyle(
                        color: AppColors.textSecondary, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 8),
                _SecurityNote(type: _currentType),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(_remaining > 1 ? 'Save & Continue' : 'Save & Finish'),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String get _capacityLabel => switch (_currentType) {
        ServiceType.anthropic || ServiceType.openai || ServiceType.gemini =>
          'How many USD in credits did you purchase?',
        ServiceType.aws || ServiceType.oracle =>
          'What is your monthly cloud budget in USD?',
      };

  List<Widget> _buildCredentialFields() {
    return switch (_currentType) {
      ServiceType.anthropic || ServiceType.openai => [
          _ApiKeyField(
            controller: _apiKeyCtrl,
            obscure: _obscure,
            onToggle: () => setState(() => _obscure = !_obscure),
          ),
        ],
      ServiceType.gemini => [
          _ApiKeyField(
            controller: _apiKeyCtrl,
            obscure: _obscure,
            onToggle: () => setState(() => _obscure = !_obscure),
          ),
          const SizedBox(height: 14),
          _Field(
            controller: _projectIdCtrl,
            label: 'GCP Project ID (optional)',
            hint: 'my-project-123',
            required: false,
          ),
        ],
      ServiceType.aws => [
          _Field(
            controller: _accessKeyIdCtrl,
            label: 'Access Key ID',
            hint: 'AKIAIOSFODNN7EXAMPLE',
          ),
          const SizedBox(height: 14),
          _Field(
            controller: _secretKeyCtrl,
            label: 'Secret Access Key',
            hint: '••••••••••••••••',
            obscure: true,
          ),
          const SizedBox(height: 14),
          _Field(
            controller: _regionCtrl,
            label: 'Region',
            hint: 'us-east-1',
          ),
        ],
      ServiceType.oracle => [
          _Field(
            controller: _tenancyOcidCtrl,
            label: 'Tenancy OCID',
            hint: 'ocid1.tenancy.oc1...',
          ),
          const SizedBox(height: 14),
          _Field(
            controller: _userOcidCtrl,
            label: 'User OCID',
            hint: 'ocid1.user.oc1...',
          ),
          const SizedBox(height: 14),
          _Field(
            controller: _fingerprintCtrl,
            label: 'Key Fingerprint',
            hint: 'aa:bb:cc:dd:...',
          ),
          const SizedBox(height: 14),
          _Field(
            controller: _regionCtrl,
            label: 'Region',
            hint: 'us-ashburn-1',
          ),
          const SizedBox(height: 14),
          _Field(
            controller: _privateKeyCtrl,
            label: 'Private Key (PEM)',
            hint: '-----BEGIN RSA PRIVATE KEY-----\n...',
            maxLines: 6,
            keyboardType: TextInputType.multiline,
          ),
        ],
    };
  }
}

// ── Reusable widgets ──────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.subtitle});
  final String label;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(subtitle,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 13)),
      ],
    );
  }
}

class _ApiKeyField extends StatelessWidget {
  const _ApiKeyField({
    required this.controller,
    required this.obscure,
    required this.onToggle,
  });

  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: 'API Key',
        hintText: 'sk-••••••••••••••••',
        suffixIcon: IconButton(
          icon: Icon(
            obscure
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: AppColors.textSecondary,
            size: 18,
          ),
          onPressed: onToggle,
        ),
      ),
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? 'API key is required' : null,
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    this.obscure = false,
    this.required = true,
    this.maxLines = 1,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final bool obscure;
  final bool required;
  final int maxLines;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(
          color: AppColors.textPrimary, fontSize: 14, fontFamily: 'monospace'),
      decoration: InputDecoration(labelText: label, hintText: hint),
      validator: required
          ? (v) =>
              (v == null || v.trim().isEmpty) ? '$label is required' : null
          : null,
    );
  }
}

class _SecurityNote extends StatelessWidget {
  const _SecurityNote({required this.type});
  final ServiceType type;

  String get _note => switch (type) {
        ServiceType.aws =>
          'Use an IAM user with only the ce:GetCostAndUsage permission.',
        ServiceType.oracle =>
          'Your private key is stored in the device Keystore/Keychain and never leaves your device.',
        _ =>
          'Credentials are stored in the device Keystore/Keychain and never leave your device.',
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lock_outline,
              color: AppColors.textSecondary, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(_note,
                style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.5)),
          ),
        ],
      ),
    );
  }
}
