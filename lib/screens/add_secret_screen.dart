import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:passwordy/service/db/database.dart';
import 'package:passwordy/service/log.dart';
import 'package:passwordy/service/utils.dart';
import 'package:passwordy/widgets/circle_icon.dart';
import 'package:passwordy/service/db/db_vault.dart';
import 'package:passwordy/widgets/edit/edit_detail_row.dart';
import 'package:passwordy/widgets/edit/text_edit.dart';

class AddSecretScreen extends StatefulWidget {
  final Template template;

  const AddSecretScreen({super.key, required this.template});

  @override
  _AddSecretScreenState createState() => _AddSecretScreenState();
}

class _AddSecretScreenState extends State<AddSecretScreen> {
  late TitleRow _titleRow;
  late List<BaseEditDetailRow> _detailRows;
  bool _isLoading = true;
  bool _resorted = false;

  @override
  void initState() {
    super.initState();
    _detailRows = [];
    _titleRow = TitleRow(template: widget.template, nextFocus: () {
      final firstDetailRow = _detailRows.first;
      if (firstDetailRow is TextEdit) {
        firstDetailRow.focusNode.requestFocus();
      }
    });
    _loadData();
  }

  Future<void> _loadData() async {
    final dataWithTemplates = await Vault.vault.dataValuesDao
        ?.getDataWithTemplate(widget.template.id) ?? [];
    setState(() {
      int idx = 0;
      _detailRows = dataWithTemplates.map((dwt) {
        if (idx < dataWithTemplates.length - 1) {}
        final index = idx + 1;
        final row = BaseEditDetailRow.create(data: dwt, nextFocus:
        index < dataWithTemplates.length
            ? () {
          final nextDetailRow = _detailRows[index];
          if (nextDetailRow is TextEdit) {
            nextDetailRow.focusNode.requestFocus();
          }
        } : null);
        idx++;
        return row;
      }).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.template.isData ? 'Edit Secret' : 'Add Secret'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => save(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _titleRow,
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

    return ReorderableListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: _detailRows,
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          final BaseEditDetailRow item = _detailRows.removeAt(oldIndex);
          _detailRows.insert(newIndex, item);

          // Update sort values
          for (int i = 0; i < _detailRows.length; i++) {
            _detailRows[i].updateSort(i + 1);
          }
          _resorted = true;
        });
      },
    );
  }

  Future<void> updateCard() async {
    final db = Vault.vault.db;
    if (db == null) {
      snackError(context, 'Database not available');
      return;
    }

    lg?.i('Updating card ${widget.template.id}');
    try {
      await db.transaction(() async {
        // Update existing template
        if (_titleRow.isValueChanged) {
          lg?.i('Updating template header ${widget.template.id}');
          Template updatedTemplate;
          updatedTemplate = widget.template.copyWith(
            title: _titleRow.title,
            category: drift.Value(_titleRow.category),
          );
          await db.update(db.templates).replace(updatedTemplate);
        }

        // Update or create DataValues for input fields
        for (var detailRow in _detailRows) {
          if (!detailRow.isValueChanged) continue;

          lg?.i('Updating data value ${detailRow.data.dataValue?.id}');
          final dataVal = detailRow.data.dataValue;
          if (dataVal != null) {
            await db.dataValuesDao.updateDataValue(
                dataVal.copyWith(value: detailRow.valueToStore));
          } else {
            await db.dataValuesDao.insertDataValue(
              DataValuesCompanion.insert(
                value: detailRow.valueToStore,
                templateId: widget.template.id,
                templateDetailId: detailRow.data.templateDetail.id,
              ),
            );
          }
        }

        // Update template details sort values
        if (_resorted) {
          lg?.i('Updating template details sort values ${widget.template.id}');
          for (var i = 0; i < _detailRows.length; i++) {
            final detailRow = _detailRows[i];
            await db.templateDao.updateTemplateDetail(
                detailRow.data.templateDetail.copyWith(sort: i + 1));
          }
        }
      });

      if (mounted) {
        snackInfo(context, 'Secret saved successfully');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) snackError(context, 'Error saving secret: $e');
    }
  }

  Future<void> createCard() async {
    final db = Vault.vault.db;
    if (db == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Database not available')),
      );
      return;
    }

    lg?.i('Creating card');
    try {
      await db.transaction(() async {
        Template updatedTemplate;
        Map<String, String> old2new;
        // Clone the template and set isData to true
        (old2new, updatedTemplate) = await db.templateDao.cloneTemplate(
          widget.template,
          isData: true,
          isVisible: true,
        );
        updatedTemplate = updatedTemplate.copyWith(
          title: _titleRow.title,
          category: drift.Value(_titleRow.category),
        );
        await db.templateDao.updateTemplate(updatedTemplate);

        // Update or create DataValues for input fields
        for (var detailRow in _detailRows) {
          if (!detailRow.isValueChanged) continue;
          lg?.i('Inserting data value ${detailRow.valueToStore}');
          await db.dataValuesDao.insertDataValue(
            DataValuesCompanion.insert(
              value: detailRow.valueToStore,
              templateId: updatedTemplate.id,
              templateDetailId: old2new[detailRow.data.templateDetail.id]!,
            ),
          );
        }

        // Update template details sort values
        if (_resorted) {
          lg?.i('Updating template details sort values ${updatedTemplate.id}');
          for (var i = 0; i < _detailRows.length; i++) {
            final detailRow = _detailRows[i];
            await db.templateDao.updateTemplateDetail(
                detailRow.data.templateDetail.copyWith(sort: i + 1,
                    templateId: updatedTemplate.id,
                    id: old2new[detailRow.data.templateDetail.id]!));
          }
        }
      });

      if (mounted) {
        snackInfo(context, 'Secret saved successfully');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) snackError(context, 'Error saving secret: $e');
    }
  }

  Future<void> save(BuildContext context) async {
    try {
      if (_titleRow.title.isEmpty) {
        snackError(context, 'Title cannot be empty');
        _titleRow.titleFocus.requestFocus();
        return;
      }
      for (var row in _detailRows) {
        try {
          row.validate();
        } catch (e) {
          row.focusNode?.requestFocus();
          rethrow;
        }
      }
    } catch (e) {
      if(e is FormatException) {
        snackError(context, e.message);
      }
      return;
    }
    if (widget.template.isData) {
      await updateCard();
    } else {
      await createCard();
    }
  }
}

class TitleRow extends StatefulWidget {
  final Template template;
  final Function()? nextFocus;
  get title => (key! as GlobalKey<TitleRowState>).currentState!.title.toString().trim();
  get titleFocus => (key! as GlobalKey<TitleRowState>).currentState!.titleFocus;
  get category => (key! as GlobalKey<TitleRowState>).currentState!.category.toString().trim();

  bool get isValueChanged => title != template.title || category != (template.category ?? "");

  TitleRow({required this.template, this.nextFocus}) : super(key: GlobalKey<TitleRowState>());

  @override
  TitleRowState createState() => TitleRowState();
}

class TitleRowState extends State<TitleRow> {
  late TextEditingController titleController;
  late TextEditingController categoryController;
  final titleFocus = FocusNode();
  final categoryFocus = FocusNode();

  get title => titleController.text.trim();
  get category => categoryController.text.trim();

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.template.isData ? widget.template.title : "");
    categoryController = TextEditingController(text: widget.template.category);
    if(!widget.template.isData) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusScope.of(context).requestFocus(titleFocus);
      });
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    categoryController.dispose();
    titleFocus.dispose();
    categoryFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleIcon(
          iconName: widget.template.icon,
          backgroundColor: widget.template.color,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: titleController,
                focusNode: titleFocus,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) {
                  FocusScope.of(context).requestFocus(categoryFocus);
                },
              ),
              const SizedBox(height: 8),
              TextField(
                controller: categoryController,
                focusNode: categoryFocus,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => widget.nextFocus?.call(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

