import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SettingsPanel extends StatefulWidget {
  const SettingsPanel({Key? key}) : super(key: key);

  @override
  State<SettingsPanel> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<SettingsPanel> {
  String _selectedLanguage = 'English';
  double _voiceSpeed = 1.0;
  String _wakeWord = 'Hey AC AI';
  bool _voiceFeedback = true;
  String _theme = 'Dark';
  String _orbColor = 'Cyan';
  String _effects = 'High';
  bool _backgroundMode = true;
  bool _notifications = true;
  bool _autoStart = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.bgSecondary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.textSecondary.withOpacity(0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Icon(Icons.settings, color: AppTheme.primaryCyan),
                const SizedBox(width: 12),
                Text(
                  'Settings',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                _buildSection(
                  '🎤 VOICE',
                  [
                    _buildDropdown(
                      'Language',
                      _selectedLanguage,
                      ['English', 'Hindi', 'Spanish', 'French'],
                      (value) => setState(() => _selectedLanguage = value!),
                    ),
                    _buildSlider(
                      'Voice Speed',
                      _voiceSpeed,
                      0.5,
                      2.0,
                      (value) => setState(() => _voiceSpeed = value),
                      labels: ['Slow', 'Medium', 'Fast'],
                    ),
                    _buildTextField(
                      'Wake Word',
                      _wakeWord,
                      (value) => setState(() => _wakeWord = value),
                    ),
                    _buildSwitch(
                      'Voice Feedback',
                      _voiceFeedback,
                      (value) => setState(() => _voiceFeedback = value),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSection(
                  '🎨 APPEARANCE',
                  [
                    _buildDropdown(
                      'Theme',
                      _theme,
                      ['Dark', 'Light', 'Auto'],
                      (value) => setState(() => _theme = value!),
                    ),
                    _buildDropdown(
                      'Orb Color',
                      _orbColor,
                      ['Cyan', 'Blue', 'Purple', 'Green'],
                      (value) => setState(() => _orbColor = value!),
                    ),
                    _buildDropdown(
                      'Effects',
                      _effects,
                      ['High', 'Medium', 'Low'],
                      (value) => setState(() => _effects = value!),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSection(
                  '📱 BEHAVIOR',
                  [
                    _buildSwitch(
                      'Background Mode',
                      _backgroundMode,
                      (value) => setState(() => _backgroundMode = value),
                    ),
                    _buildSwitch(
                      'Notifications',
                      _notifications,
                      (value) => setState(() => _notifications = value),
                    ),
                    _buildSwitch(
                      'Auto-Start',
                      _autoStart,
                      (value) => setState(() => _autoStart = value),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSection(
                  'ℹ️ ABOUT',
                  [
                    _buildInfoRow('Version', '1.0.0'),
                    _buildInfoRow('Developer', 'AC AI Team'),
                    _buildInfoRow('Build', '2024.01.15'),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryCyan,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppTheme.bgElevated,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.primaryCyan.withOpacity(0.3)),
            ),
            child: DropdownButton<String>(
              value: value,
              items: items.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(fontFamily: 'RobotoMono'),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
              underline: const SizedBox(),
              dropdownColor: AppTheme.bgElevated,
              icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primaryCyan),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged, {
    List<String>? labels,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodyLarge),
              if (labels != null)
                Text(
                  _getSpeedLabel(value, labels),
                  style: TextStyle(
                    fontFamily: 'RobotoMono',
                    color: AppTheme.primaryCyan,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppTheme.primaryCyan,
              inactiveTrackColor: AppTheme.primaryCyan.withOpacity(0.3),
              thumbColor: AppTheme.primaryCyan,
              overlayColor: AppTheme.primaryCyan.withOpacity(0.2),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: labels != null ? labels.length - 1 : 10,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  String _getSpeedLabel(double value, List<String> labels) {
    if (value < 1.0) return labels[0];
    if (value < 1.5) return labels[1];
    return labels[2];
  }

  Widget _buildTextField(
    String label,
    String value,
    ValueChanged<String> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 8),
          TextField(
            controller: TextEditingController(text: value),
            onChanged: onChanged,
            style: const TextStyle(fontFamily: 'RobotoMono'),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppTheme.bgElevated,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppTheme.primaryCyan.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppTheme.primaryCyan.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppTheme.primaryCyan),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitch(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryCyan,
            activeTrackColor: AppTheme.primaryCyan.withOpacity(0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'RobotoMono',
              color: AppTheme.primaryCyan,
            ),
          ),
        ],
      ),
    );
  }
}
