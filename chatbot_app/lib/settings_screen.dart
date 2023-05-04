import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _useGpt4 = true;
  bool _keepMemory = false;
  bool _useProxy = false;
  String _portNumber = '4780';
  String _temperature = '0.1';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _useGpt4 = prefs.getBool('useGpt4') ?? true;
      _keepMemory = prefs.getBool('keepMemory') ?? false;
      _useProxy = prefs.getBool('useProxy') ?? false;
      _portNumber = prefs.getString('portNumber') ?? '';
      _temperature = prefs.getString('temperature') ?? '0.1';
    });
  }

  Future<void> _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('useGpt4', _useGpt4);
    prefs.setBool('keepMemory', _keepMemory);
    prefs.setBool('useProxy', _useProxy);
    prefs.setString('portNumber', _portNumber);
    prefs.setString('temperature', _temperature);
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
            title: Text('Use GPT-4 Model 关了就是GPT3.5'),
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
            title: Text('Keep Memory 启用上下文 会产生较高的费用'),
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
          ListTile(
            title: Text('Use Proxy 启用代理 需要你自己有vpn'),
            trailing: Switch(
              value: _useProxy,
              onChanged: (bool value) {
                setState(() {
                  _useProxy = value;
                });
                _saveSettings();
              },
            ),
          ),
          ListTile(
            title: Text('Port Number 本地代理的端口号'),
            trailing: SizedBox(
              width: 100,
              child: TextField(
                keyboardType: TextInputType.number,
                onChanged: (String value) {
                  _portNumber = value;
                  _saveSettings();
                },
                controller: TextEditingController(text: _portNumber),
              ),
            ),
          ),
          ListTile(
            title: Text('Temperature 0-1之间,越大越有创造力'),
            trailing: SizedBox(
              width: 100,
              child: TextField(
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onChanged: (String value) {
                  _temperature = value;
                  _saveSettings();
            },
            controller: TextEditingController(text: _temperature),
          ),
        ),
      ),
    ],
  ),
);
}
}