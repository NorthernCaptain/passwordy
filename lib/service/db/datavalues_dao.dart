import 'package:drift/drift.dart';
import 'package:passwordy/service/db/database.dart';
import 'package:passwordy/service/enums.dart';

part 'datavalues_dao.g.dart';

class DataWithTemplate {
  final DataValue? dataValue;
  final TemplateDetail templateDetail;

  DataWithTemplate(this.dataValue, this.templateDetail);
}

class DataWithAllTemplate {
  final DataValue? dataValue;
  final TemplateDetail templateDetail;
  final Template template;

  DataWithAllTemplate(this.dataValue, this.template, this.templateDetail);
}

@DriftAccessor(tables: [DataValues, Templates, TemplateDetails])
class DataValuesDao extends DatabaseAccessor<VaultDatabase> with _$DataValuesDaoMixin {
  // this constructor is required so that the main database can create an instance
  // of this object.
  DataValuesDao(super.db);

  Future<DataValue> insertDataValue(DataValuesCompanion dataValue) async {
    return into(dataValues).insertReturning(dataValue);
  }

  Future<void> updateDataValue(DataValue dataValue) async {
    await update(dataValues).replace(dataValue);
  }

  Future<DataValue?> getDataValue(String id) async {
    final dataValue = await (select(dataValues)..where((dv) => dv.id.equals(id))).getSingleOrNull();
    return dataValue;
  }

  Future<List<DataWithTemplate>> getAllDataWithTemplates() {
    final query = select(dataValues).join([
      innerJoin(templateDetails, templateDetails.id.equalsExp(dataValues.templateDetailId)),
    ]);

    // Add condition to filter out deleted template details
    query.where(templateDetails.isDeleted.equals(false));

    // Add ordering by templateDetails.sort
    query.orderBy([OrderingTerm.asc(templateDetails.sort)]);

    return query.map((row) {
      return DataWithTemplate(
        row.readTableOrNull(dataValues),
        row.readTable(templateDetails),
      );
    }).get();
  }

  Future<List<DataWithTemplate>> getDataWithTemplate(String templateId, {bool onlyData = false}) {
    final query = select(templateDetails).join([
        leftOuterJoin(dataValues,
            dataValues.templateDetailId.equalsExp(templateDetails.id)),
      ]);

    query
      .where(templateDetails.templateId.equals(templateId));
    if(onlyData) {
      query.where(dataValues.id.isNotNull());
    }

    query
      .orderBy([OrderingTerm.asc(templateDetails.sort)]);

    return query.map((row) {
      return DataWithTemplate(
        row.readTableOrNull(dataValues),
        row.readTable(templateDetails),
      );
    }).get();
  }

  Future<List<Template>> getActiveDataTemplates({String filter = ""}) async {
    final query = select(templates).join([
      innerJoin(templateDetails, templateDetails.templateId.equalsExp(templates.id)),
      innerJoin(dataValues, dataValues.templateId.equalsExp(templates.id)),
    ]);

    query.where(templates.isVisible.equals(true)
      & templates.isDeleted.equals(false)
      & templates.isData.equals(true));

    if (filter.isNotEmpty) {
      query.where(templateDetails.title.like('%$filter%')
      | templates.title.like('%$filter%')
      | templates.category.like('%$filter%')
      | dataValues.value.like('%$filter%'));
    }

    query.orderBy([OrderingTerm.asc(templates.title)]);

    query.groupBy([templates.id]);

    return query.map((row) => row.readTable(templates)).get();
  }

  Stream<List<Template>> watchActiveDataTemplates({String filter = ""}) {
    final query = select(templates).join([
      innerJoin(templateDetails, templateDetails.templateId.equalsExp(templates.id)),
      innerJoin(dataValues, dataValues.templateId.equalsExp(templates.id)),
    ]);

    query.where(templates.isVisible.equals(true)
    & templates.isDeleted.equals(false)
    & templates.isData.equals(true));

    if (filter.isNotEmpty) {
      query.where(templateDetails.title.like('%$filter%')
      | templates.title.like('%$filter%')
      | templates.category.like('%$filter%')
      | dataValues.value.like('%$filter%'));
    }

    query.orderBy([OrderingTerm.asc(templates.title)]);

    query.groupBy([templates.id]);

    return query.map((row) => row.readTable(templates)).watch();
  }

  Stream<List<DataWithAllTemplate>> watchActiveTokenTemplates() {
    final query = select(templates).join([
      innerJoin(templateDetails, templateDetails.templateId.equalsExp(templates.id)),
      innerJoin(dataValues, dataValues.templateId.equalsExp(templates.id)),
    ]);

    query.where(templates.isVisible.equals(true)
    & templates.isDeleted.equals(false)
    & templates.isData.equals(true));

    query.where(templateDetails.fieldType.equals(FieldType.token.name));

    query.orderBy([OrderingTerm.asc(templates.title)]);

    query.groupBy([templates.id]);

    return query.map((row) => DataWithAllTemplate(
        row.readTableOrNull(dataValues),
        row.readTable(templates),
        row.readTable(templateDetails),
    )).watch();
  }
}
