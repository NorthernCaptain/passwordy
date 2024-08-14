import 'package:flutter/material.dart';
import 'package:passwordy/screens/add_secret_screen.dart';
import 'package:passwordy/service/db/db_vault.dart';
import 'package:passwordy/service/db/database.dart';
import 'package:passwordy/widgets/circle_icon.dart';

class NewItemChooser extends StatefulWidget {
  final Function(Template) onItemSelected;
  final Vault vault;

  const NewItemChooser(
      {super.key, required this.onItemSelected, required this.vault});

  @override
  _NewItemChooserState createState() => _NewItemChooserState();
}

class _NewItemChooserState extends State<NewItemChooser> {
  Future<List<Template>>? templates;

  @override
  initState() {
    super.initState();
    setState(() {
      templates = widget.vault.getActiveTemplates();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6, // 60% of screen height
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(
        children: <Widget>[
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Add New',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child:
            FutureBuilder<List<Template>>(
              future: templates,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final results = snapshot.data!;

                  return ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      return _buildItem(context, results[index]);
                    },
                  );
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, Template template) {
    return ListTile(
      leading: CircleIcon(iconName: template.icon, backgroundColor: template.color),
      title: Text(template.title),
      onTap: () {
        Navigator.pop(context);
        widget.onItemSelected(template);
        Navigator.push(context, MaterialPageRoute(builder: (_) => AddSecretScreen(template: template)));
      },
    );
  }
}