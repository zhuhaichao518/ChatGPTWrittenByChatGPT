import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _useGpt4 = true;
  bool _keepMemory = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _useGpt4 = prefs.getBool('useGpt4') ?? true;
      _keepMemory = prefs.getBool('keepMemory') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('useGpt4', _useGpt4);
    prefs.setBool('keepMemory',_keepMemory);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Colors.blue.shade900,
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('Use GPT-4 Model'),
            trailing: Switch(
              value: _useGpt4,
              onChanged: (bool value) {
                setState(() {
                  _useGpt4 = value;
                });
                _saveSettings();
              },
            ),
          ),
          ListTile(
            title: Text('Keep Memory'),
            trailing: Switch(
              value: _keepMemory,
              onChanged: (bool value) {
                setState(() {
                  _keepMemory = value;
                });
                _saveSettings();
              },
            ),
          ),
        ],
      ),
    );
  }
}
