import 'package:flutter/material.dart';

class NewItemChooser extends StatelessWidget {
  final Function(String) onItemSelected;

  const NewItemChooser({Key? key, required this.onItemSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6, // 60% of screen height
      child: Column(
        children: <Widget>[
          SizedBox(height: 10),
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Add New',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                _buildItem(context, Icons.note_add, 'Add Note'),
                _buildItem(context, Icons.photo_camera, 'Take Photo'),
                _buildItem(context, Icons.photo_library, 'Add from Gallery'),
                _buildItem(context, Icons.file_upload, 'Upload File'),
                _buildItem(context, Icons.link, 'Add Link'),
                _buildItem(context, Icons.list, 'Create List'),
                _buildItem(context, Icons.event, 'Add Event'),
                _buildItem(context, Icons.location_on, 'Add Location'),
                _buildItem(context, Icons.note_add, 'Add Note'),
                _buildItem(context, Icons.photo_camera, 'Take Photo'),
                _buildItem(context, Icons.photo_library, 'Add from Gallery'),
                _buildItem(context, Icons.file_upload, 'Upload File'),
                _buildItem(context, Icons.link, 'Add Link'),
                _buildItem(context, Icons.list, 'Create List'),
                _buildItem(context, Icons.event, 'Add Event'),
                _buildItem(context, Icons.location_on, 'Add Location'),
                // Add more items as needed
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, IconData icon, String label) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: () {
        Navigator.pop(context);
        onItemSelected(label);
      },
    );
  }
}