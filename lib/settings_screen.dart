// lib/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _profileController = TextEditingController();
  final TextEditingController _customApiController = TextEditingController();
  String _selectedProvider = "Gemini";

  void _showAddProfileModal(BuildContext context, AppState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF121824),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Create New User Matrix Workspace", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            TextField(
              controller: _profileController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(hintText: "Enter Profile Name", hintStyle: TextStyle(color: Colors.grey)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_profileController.text.isNotEmpty) {
                  state.createNewProfile(_profileController.text.trim());
                  _profileController.clear();
                  Navigator.pop(context);
                }
              },
              child: const Text("Initialize Identity"),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("System Settings Matrix", style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 100),
        children: [
          // 🧠 1. MULTI-USER PROFILES SECTION
          _buildSectionHeader("USER ACCOUNT PROFILES"),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFF121824), borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Active Identity: ${appState.activeProfile.name}", style: const TextStyle(fontWeight: FontWeight.bold)),
                    TextButton(onPressed: () => _showAddProfileModal(context, appState), child: const Text("+ Add Profile", style: TextStyle(color: Color(0xFF4DA3FF)))),
                  ],
                ),
                const Divider(color: Color(0xFF1A2336)),
                DropdownButton<int>(
                  value: appState.profiles.indexWhere((p) => p.id == appState.activeProfile.id),
                  dropdownColor: const Color(0xFF121824),
                  isExpanded: true,
                  items: List.generate(appState.profiles.length, (index) {
                    return DropdownMenuItem(value: index, child: Text(appState.profiles[index].name, style: const TextStyle(color: Colors.white)));
                  }),
                  onChanged: (val) => val != null ? appState.switchProfile(val) : null,
                )
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 🤖 2. ARTIFICIAL INTELLIGENCE CORE ROUTING
          _buildSectionHeader("INTELLIGENCE ENGINE ENGINE CONFIGURATION"),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFF121824), borderRadius: BorderRadius.circular(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Target AI API Provider Model"),
                    DropdownButton<String>(
                      value: _selectedProvider,
                      dropdownColor: const Color(0xFF121824),
                      items: ["Gemini", "Custom OpenAPI"].map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(color: Colors.white)))).toList(),
                      onChanged: (v) => v != null ? setState(() => _selectedProvider = v) : null,
                    )
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _customApiController..text = appState.apiKey,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 13),
                  decoration: const InputDecoration(
                    labelText: "Secure API Access Auth Key Token", 
                    labelStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder()
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4DA3FF)),
                  onPressed: () => appState.updateApiKey(_customApiController.text.trim(), _selectedProvider),
                  child: const Text("Save Core Keys", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 🎨 3. INTERFACE RENDERING ENVIRONMENT
          _buildSectionHeader("THEME & VISUAL IDENTITY TYPOGRAPHY"),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFF121824), borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text("Dark-First Display Slate Mode"),
                  value: appState.isDarkMode,
                  activeThumbColor: const Color(0xFF2EE59D),
                  onChanged: (val) => appState.toggleTheme(val),
                ),
                const Divider(color: Color(0xFF1A2336)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Font Family Matrix"),
                    DropdownButton<String>(
                      value: appState.currentFont,
                      dropdownColor: const Color(0xFF121824),
                      items: ["Inter", "SF Pro", "monospace"].map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(color: Colors.white)))).toList(),
                      onChanged: (v) => v != null ? appState.updateTypography(v, appState.fontSize) : null,
                    )
                  ],
                ),
                const Divider(color: Color(0xFF1A2336)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Interface Base Font Size"),
                    Slider(
                      value: appState.fontSize,
                      min: 12.0,
                      max: 20.0,
                      divisions: 4,
                      label: appState.fontSize.toString(),
                      onChanged: (v) => appState.updateTypography(appState.currentFont, v),
                    )
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 🔔 4. ALERT BROADCAST METRIC RULES
          _buildSectionHeader("COMMUNICATION SYSTEM TELEMETRY"),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFF121824), borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text("Transaction SMS Stream Push"),
                  value: appState.txAlerts,
                  onChanged: (v) => appState.toggleNotificationSettings("tx", v),
                ),
                SwitchListTile(
                  title: const Text("Budget Over-Velocity Boundary Warnings"),
                  value: appState.budgetAlerts,
                  onChanged: (v) => appState.toggleNotificationSettings("budget", v),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
      ),
    );
  }
}