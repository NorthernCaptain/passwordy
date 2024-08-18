
import 'package:flutter/material.dart';
import 'package:passwordy/screens/add_secret_screen.dart';
import 'package:passwordy/service/db/database.dart';
import 'package:passwordy/service/db/datavalues_dao.dart';
import 'package:passwordy/service/db/db_vault.dart';
import 'package:passwordy/service/enums.dart';
import 'package:passwordy/widgets/circle_icon.dart';
import 'package:passwordy/widgets/display/display_field.dart';
import 'package:passwordy/widgets/display/display_otp.dart';

class DisplaySecretScreen extends StatefulWidget {
  final Template template;

  const DisplaySecretScreen({super.key, required this.template});

  @override
  _DisplaySecretScreenState createState() => _DisplaySecretScreenState();
}

class _DisplaySecretScreenState extends State<DisplaySecretScreen> {
  late TitleDisplayRow _TitleDisplayRow;
  late List<BaseDisplayDetailRow> _detailRows;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _detailRows = [];
    _TitleDisplayRow = TitleDisplayRow(template: widget.template);
    _loadData();
  }

  Future<void> _loadData() async {
    final dataWithTemplates = await Vault.vault.dataValuesDao
        ?.getDataWithTemplate(widget.template.id, onlyData: true) ?? [];
    setState(() {
      _detailRows = dataWithTemplates.map((dwt) => BaseDisplayDetailRow(data: dwt)).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Secret'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => edit(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TitleDisplayRow,
            const SizedBox(height: 32),
            _buildDetailsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_detailRows.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    return ListView(
      shrinkWrap: true,
      children: _detailRows,
    );
  }

  Future<void> edit(BuildContext context) async {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => AddSecretScreen(template: widget.template),
      ),
    );
  }
}

class BaseDisplayDetailRow extends StatelessWidget {
  final DataWithTemplate data;

  const BaseDisplayDetailRow({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    switch(data.templateDetail.fieldType) {
      case FieldType.token:
        return DisplayOTP(data: data);
      case FieldType.pinCode:
      case FieldType.password:
        return DisplayField(label: data.templateDetail.title, value: data.dataValue!.value, isObscurable: true);
      default:
        return DisplayField(label: data.templateDetail.title, value: data.dataValue!.value);
    }
  }
}

class TitleDisplayRow extends StatelessWidget {
  final Template template;

  const TitleDisplayRow({super.key, required this.template,});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleIcon(
          iconName: template.icon,
          backgroundColor: template.color,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DisplayField(label: "Title", value: template.title),
              DisplayField(label: "Category", value: template.category ?? ""),
            ],
          ),
        ),
      ],
    );
  }
}

