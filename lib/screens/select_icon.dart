import 'dart:math';

import 'package:flutter/material.dart';
import 'package:passwordy/service/icon_mapping.dart';
import 'package:passwordy/widgets/circle_icon.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class SelectIconScreen extends StatefulWidget {
  final String? initialIconName;
  final String? initialColor;

  const SelectIconScreen({
    super.key,
    this.initialIconName,
    this.initialColor
  });

  @override
  _SelectIconScreenState createState() => _SelectIconScreenState();
}

class _SelectIconScreenState extends State<SelectIconScreen> {
  late String _searchQuery;
  late TextEditingController _searchController;
  late Color _selectedColor;

  String get _selectedColorHex => '#${_selectedColor.value.toRadixString(16).substring(2).padLeft(6, '0')}';

  @override
  void initState() {
    super.initState();
    _searchQuery = widget.initialIconName ?? '';
    _searchController = TextEditingController(text: _searchQuery);
    _selectedColor = widget.initialColor != null
        ? Color(int.parse(widget.initialColor!.substring(1), radix: 16) + 0xFF000000)
        : Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    List<MapEntry<String, IconData>> filteredIcons = IconMapping.iconMap.entries
        .where((entry) => entry.key.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Icon'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _showColorPicker,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _selectedColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search icons...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = max(3, (constraints.maxWidth / 120).floor());
                return GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 1,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: filteredIcons.length,
                  itemBuilder: (context, index) {
                    final iconEntry = filteredIcons[index];
                    return _buildIconCard(iconEntry.key, iconEntry.value);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconCard(String iconName, IconData icon) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.pop(
              context, {'iconName': iconName, 'color': _selectedColorHex});
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleIcon(
              iconName: iconName,
              backgroundColor: _selectedColorHex,
            ),
            SizedBox(height: 38,
              child:
            Padding(padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
              child:
              Text(
                iconName,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
            )
            ),
          ],
        ),
      ),
    );
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _selectedColor,
              onColorChanged: (Color color) {
                setState(() {
                  _selectedColor = color;
                });
              },
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Done'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
