import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/api_endpoints.dart';
import '../core/constants/app_colors.dart';
import '../core/services/api_service.dart';
import '../providers/app_provider.dart';

class ServerSettingsDialog extends StatefulWidget {
  const ServerSettingsDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ServerSettingsDialog(),
    );
  }

  @override
  State<ServerSettingsDialog> createState() => _ServerSettingsDialogState();
}

class _ServerSettingsDialogState extends State<ServerSettingsDialog> {
  late final TextEditingController _urlController;
  bool _isTesting = false;
  String? _testResult;
  bool? _testSuccess;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: ApiService.baseUrl);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    setState(() {
      _isTesting = true;
      _testResult = null;
      _testSuccess = null;
    });

    final res = await ApiService.checkHealth(_urlController.text.trim());

    if (mounted) {
      setState(() {
        _isTesting = false;
        _testSuccess = res['success'] as bool;
        _testResult = res['message'] as String;
      });
    }
  }

  Future<void> _saveAndClose() async {
    final url = _urlController.text.trim();
    if (url.isNotEmpty) {
      await ApiService.setBaseUrl(url);
    } else {
      await ApiService.resetBaseUrl();
    }
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Server URL updated successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final isDark = app.isDarkMode;
    final fontScale = app.fontScale;

    final presets = [
      {
        'label': 'Cloud (Render)',
        'url': ApiEndpoints.baseUrl,
      },
      {
        'label': 'Android Emulator',
        'url': 'http://10.0.2.2:5000/api/v1',
      },
      {
        'label': 'Localhost',
        'url': 'http://localhost:5000/api/v1',
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20 * fontScale,
        right: 20 * fontScale,
        top: 20 * fontScale,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24 * fontScale,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: 16 * fontScale),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.dns_rounded, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Server Configuration',
                      style: TextStyle(
                        fontSize: 18 * fontScale,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    Text(
                      'Set backend API host or diagnose network connection',
                      style: TextStyle(
                        fontSize: 12 * fontScale,
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20 * fontScale),

          // Input field
          TextField(
            controller: _urlController,
            style: TextStyle(
              fontSize: 14 * fontScale,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
            decoration: InputDecoration(
              labelText: 'Backend Base URL',
              hintText: 'https://rentezzi-server-v2.onrender.com/api/v1',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.link_rounded),
            ),
          ),
          SizedBox(height: 12 * fontScale),

          // Presets
          Wrap(
            spacing: 8,
            children: presets.map((p) {
              final isSelected = _urlController.text == p['url'];
              return ChoiceChip(
                label: Text(
                  p['label']!,
                  style: TextStyle(
                    fontSize: 12 * fontScale,
                    color: isSelected ? Colors.white : AppColors.primary,
                  ),
                ),
                selected: isSelected,
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.primary.withOpacity(0.08),
                onSelected: (_) {
                  setState(() {
                    _urlController.text = p['url']!;
                    _testResult = null;
                  });
                },
              );
            }).toList(),
          ),
          SizedBox(height: 16 * fontScale),

          // Test result card
          if (_testResult != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _testSuccess == true
                    ? AppColors.success.withOpacity(0.12)
                    : AppColors.destructive.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _testSuccess == true
                      ? AppColors.success.withOpacity(0.4)
                      : AppColors.destructive.withOpacity(0.4),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _testSuccess == true ? Icons.check_circle_rounded : Icons.error_rounded,
                    color: _testSuccess == true ? AppColors.success : AppColors.destructive,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _testResult!,
                      style: TextStyle(
                        fontSize: 13 * fontScale,
                        color: _testSuccess == true ? AppColors.success : AppColors.destructive,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16 * fontScale),
          ],

          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isTesting ? null : _testConnection,
                  icon: _isTesting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.network_ping_rounded),
                  label: Text(_isTesting ? 'Testing...' : 'Test Connection'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _saveAndClose,
                  icon: const Icon(Icons.save_rounded),
                  label: const Text('Save & Apply'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
