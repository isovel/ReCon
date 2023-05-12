import 'package:contacts_plus_plus/client_holder.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sClient = ClientHolder.of(context).settingsClient;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text("Settings"),
      ),
      body: ListView(
        children: [
          const ListSectionHeader(name: "Notifications"),
          BooleanSettingsTile(
            title: "Enable Notifications",
            initialState: !sClient.currentSettings.notificationsDenied.valueOrDefault,
            onChanged: (value) async => await sClient.changeSettings(sClient.currentSettings.copyWith(notificationsDenied: !value)),
          ),
          const ListSectionHeader(name: "Other"),
          ListTile(
            trailing: const Icon(Icons.logout),
            title: const Text("Sign out"),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) =>
                    AlertDialog(
                      title: Text("Are you sure you want to sign out?", style: Theme
                          .of(context)
                          .textTheme
                          .titleLarge,),
                      actions: [
                        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("No")),
                        TextButton(
                          onPressed: () async {
                            await ClientHolder.of(context).apiClient.logout(context);
                          },
                          child: const Text("Yes"),
                        ),
                      ],
                    ),
              );
            },
          ),
          ListTile(
            trailing: const Icon(Icons.info_outline),
            title: const Text("About Contacts++"),
            onTap: () async {
              showAboutDialog(
                context: context,
                applicationVersion: (await PackageInfo.fromPlatform()).version,
                applicationIcon: InkWell(
                  onTap: () async {
                    if (!await launchUrl(Uri.parse("https://github.com/Nutcake/contacts-plus-plus"), mode: LaunchMode.externalApplication)) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to open link.")));
                      }
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    constraints: const BoxConstraints(maxWidth: 64),
                    child: Image.asset("assets/images/logo512.png"),
                  ),
                ),
                applicationLegalese: "Created by Nutcake with love <3",
              );
            },
          )
        ],
      ),
    );
  }
}

class ListSectionHeader extends StatelessWidget {
  const ListSectionHeader({required this.name, super.key});

  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(name, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              color: Colors.white12,
              height: 1,
            ),
          )
        ],
      ),
    );
  }
}

class BooleanSettingsTile extends StatefulWidget {
  const BooleanSettingsTile({required this.title, required this.initialState, required this.onChanged, super.key});

  final String title;
  final bool initialState;
  final Function(bool) onChanged;

  @override
  State<StatefulWidget> createState() => _BooleanSettingsTileState();
}

class _BooleanSettingsTileState extends State<BooleanSettingsTile> {
  late bool state = widget.initialState;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      trailing: Switch(
        onChanged: (value) async {
          await widget.onChanged(value);
          setState(() {
            state = value;
          });
        },
        value: state,
      ),
      title: Text(widget.title),
      onTap: () async {
        await widget.onChanged(!state);
        setState(() {
          state = !state;
        });
      },
    );
  }

}