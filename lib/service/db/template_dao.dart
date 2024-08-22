import 'package:drift/drift.dart';
import 'package:passwordy/service/db/database.dart';
import 'package:passwordy/service/db/db_vault.dart';
import 'package:passwordy/service/enums.dart';
import 'package:passwordy/service/utils.dart';

part 'template_dao.g.dart';

@DriftAccessor(tables: [Templates, TemplateDetails])
class TemplateDao extends DatabaseAccessor<VaultDatabase> with _$TemplateDaoMixin {
  // this constructor is required so that the main database can create an instance
  // of this object.
  TemplateDao(super.db);

  Future<Template> insertTemplate(
      TemplatesCompanion template,
      List<TemplateDetailsCompanion> details
      ) async {
    final Template row = await into(templates).insertReturning(template);
    for (final detail in details) {
      await into(templateDetails).insert(
        detail.copyWith(templateId: Value(row.id)),
      );
    }
    return row;
  }

  Future<void> updateTemplate(Template template) async {
    await update(templates).replace(template);
  }

  Future<List<Template>> getActiveTemplates() async {
    return
      (select(templates)
        ..where((t) => t.isVisible.equals(true) & t.isDeleted.equals(false) & t.isData.equals(false))
        ..orderBy([(t) => OrderingTerm(expression: t.sort)])).get();
  }

  Future<List<Template>> getActiveTokenTemplates() async {
    final query = select(templates).join([
      innerJoin(templateDetails, templateDetails.templateId.equalsExp(templates.id)),
    ]);

    query.where(templates.isVisible.equals(true)
    & templates.isDeleted.equals(false)
    & templates.isData.equals(false));

    query.where(templateDetails.fieldType.equals(FieldType.token.name));

    query.orderBy([OrderingTerm.asc(templates.title)]);

    query.groupBy([templates.id]);

    return query.map((row) => row.readTable(templates)).get();
  }

  Future<List<TemplateDetail>> getTemplateDetails(String templateId) async {
    return
      (select(templateDetails)
        ..where((td) => td.templateId.equals(templateId) & td.isDeleted.equals(false))
        ..orderBy([(td) => OrderingTerm(expression: td.sort)])).get();
  }

  Future<void> updateTemplateDetail(TemplateDetail detail) async {
    await update(templateDetails).replace(detail);
  }

  Future<(Map<String, String> old2new, Template template)>
  cloneTemplate(Template template, { bool isVisible = false, bool isData = false }) async {
    final Map<String, String> old2new = {};
    final newTemplate = template.copyWith(id: generateId(), isVisible: isVisible, isData: isData);
    await into(templates).insert(newTemplate);
    final details = await getTemplateDetails(template.id);
    for (final detail in details) {
      final newId = generateId();
      old2new[detail.id] = newId;
      await into(templateDetails).insert(detail.copyWith(id: newId, templateId: newTemplate.id));
    }
    return (old2new, newTemplate);
  }

  Future<void> deleteTemplate(Template template) async {
    await update(templates).replace(template.copyWith(isDeleted: true));
  }

  Future<void> insertDefaults() async {
    await insertTemplate(
      TemplatesCompanion.insert(title: "Email account", category: const Value("Email account"), icon: "email", color: "#1010D0", sort: 1)
      , [
      TemplateDetailsCompanion.insert(title: "Email", fieldType: FieldType.email, sort: 1, templateId: ''),
      TemplateDetailsCompanion.insert(title: "Password", fieldType: FieldType.password, sort: 2, templateId: ''),
      TemplateDetailsCompanion.insert(title: "Website", fieldType: FieldType.url, sort: 3, templateId: ''),
      TemplateDetailsCompanion.insert(title: "User name", fieldType: FieldType.text, sort: 4, templateId: ''),
      TemplateDetailsCompanion.insert(title: "Notes", fieldType: FieldType.note, sort: 5, templateId: ''),
    ],
    );
    await insertTemplate(
      TemplatesCompanion.insert(title: "Web site", category: const Value("Web site"), icon: "web", color: "#10F010", sort: 2)
      , [
      TemplateDetailsCompanion.insert(title: "Web site", fieldType: FieldType.url, sort: 1, templateId: ''),
      TemplateDetailsCompanion.insert(title: "User name", fieldType: FieldType.text, sort: 2, templateId: ''),
      TemplateDetailsCompanion.insert(title: "Password", fieldType: FieldType.password, sort: 3, templateId: ''),
      TemplateDetailsCompanion.insert(title: "Email", fieldType: FieldType.email, sort: 4, templateId: ''),
      TemplateDetailsCompanion.insert(title: "Notes", fieldType: FieldType.note, sort: 5, templateId: ''),
    ],
    );
    await insertTemplate(
      TemplatesCompanion.insert(title: "Credit card", category: const Value("Credit card"), icon: "credit_card", color: "#D01010", sort: 3)
      , [
      TemplateDetailsCompanion.insert(title: "Bank", fieldType: FieldType.capText, sort: 1, templateId: ''),
      TemplateDetailsCompanion.insert(title: "Card number", fieldType: FieldType.number, sort: 2, templateId: ''),
      TemplateDetailsCompanion.insert(title: "Secret code", fieldType: FieldType.pinCode, sort: 3, templateId: ''),
      TemplateDetailsCompanion.insert(title: "Phone", fieldType: FieldType.phone, sort: 4, templateId: ''),
      TemplateDetailsCompanion.insert(title: "Notes", fieldType: FieldType.note, sort: 5, templateId: ''),
    ],
    );
    await insertTemplate(
      TemplatesCompanion.insert(title: "Bank account", category: const Value("Bank account"), icon: "account_balance", color: "#F0F010", sort: 3)
      , [
      TemplateDetailsCompanion.insert(title: "Bank", fieldType: FieldType.capText, sort: 1, templateId: ''),
      TemplateDetailsCompanion.insert(title: "Route number", fieldType: FieldType.number, sort: 2, templateId: ''),
      TemplateDetailsCompanion.insert(title: "Account number", fieldType: FieldType.number, sort: 3, templateId: ''),
      TemplateDetailsCompanion.insert(title: "Phone", fieldType: FieldType.phone, sort: 4, templateId: ''),
      TemplateDetailsCompanion.insert(title: "Notes", fieldType: FieldType.note, sort: 5, templateId: ''),
    ],
    );
    await insertTemplate(
      TemplatesCompanion.insert(title: "One time password (2FA)", category: const Value("One time password"), icon: "generating_tokens", color: "#D010F0", sort: 3)
      , [
      TemplateDetailsCompanion.insert(title: "Account name", fieldType: FieldType.capText, sort: 1, templateId: ''),
      TemplateDetailsCompanion.insert(title: "Secret key", fieldType: FieldType.token, sort: 2, templateId: ''),
      TemplateDetailsCompanion.insert(title: "Notes", fieldType: FieldType.note, sort: 3, templateId: ''),
    ],
    );
  }
}
