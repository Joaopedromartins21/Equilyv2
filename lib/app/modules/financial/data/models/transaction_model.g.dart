// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransactionModelAdapter extends TypeAdapter<TransactionModel> {
  @override
  final int typeId = 2;

  @override
  TransactionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TransactionModel(
      id: fields[0] as String,
      title: fields[1] as String,
      amount: fields[2] as double,
      type: fields[3] as TransactionTypeModel,
      category: fields[4] as TransactionCategoryModel,
      date: fields[5] as DateTime,
      description: fields[6] as String?,
      accountId: fields[7] as String?,
      isInstallment: fields[8] as bool,
      installmentTotal: fields[9] as int?,
      installmentCurrent: fields[10] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, TransactionModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.date)
      ..writeByte(6)
      ..write(obj.description)
      ..writeByte(7)
      ..write(obj.accountId)
      ..writeByte(8)
      ..write(obj.isInstallment)
      ..writeByte(9)
      ..write(obj.installmentTotal)
      ..writeByte(10)
      ..write(obj.installmentCurrent);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TransactionTypeModelAdapter extends TypeAdapter<TransactionTypeModel> {
  @override
  final int typeId = 0;

  @override
  TransactionTypeModel read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TransactionTypeModel.income;
      case 1:
        return TransactionTypeModel.expense;
      default:
        return TransactionTypeModel.income;
    }
  }

  @override
  void write(BinaryWriter writer, TransactionTypeModel obj) {
    switch (obj) {
      case TransactionTypeModel.income:
        writer.writeByte(0);
        break;
      case TransactionTypeModel.expense:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionTypeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TransactionCategoryModelAdapter
    extends TypeAdapter<TransactionCategoryModel> {
  @override
  final int typeId = 1;

  @override
  TransactionCategoryModel read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TransactionCategoryModel.salary;
      case 1:
        return TransactionCategoryModel.investment;
      case 2:
        return TransactionCategoryModel.food;
      case 3:
        return TransactionCategoryModel.transport;
      case 4:
        return TransactionCategoryModel.entertainment;
      case 5:
        return TransactionCategoryModel.health;
      case 6:
        return TransactionCategoryModel.education;
      case 7:
        return TransactionCategoryModel.shopping;
      case 8:
        return TransactionCategoryModel.bills;
      case 9:
        return TransactionCategoryModel.other;
      default:
        return TransactionCategoryModel.salary;
    }
  }

  @override
  void write(BinaryWriter writer, TransactionCategoryModel obj) {
    switch (obj) {
      case TransactionCategoryModel.salary:
        writer.writeByte(0);
        break;
      case TransactionCategoryModel.investment:
        writer.writeByte(1);
        break;
      case TransactionCategoryModel.food:
        writer.writeByte(2);
        break;
      case TransactionCategoryModel.transport:
        writer.writeByte(3);
        break;
      case TransactionCategoryModel.entertainment:
        writer.writeByte(4);
        break;
      case TransactionCategoryModel.health:
        writer.writeByte(5);
        break;
      case TransactionCategoryModel.education:
        writer.writeByte(6);
        break;
      case TransactionCategoryModel.shopping:
        writer.writeByte(7);
        break;
      case TransactionCategoryModel.bills:
        writer.writeByte(8);
        break;
      case TransactionCategoryModel.other:
        writer.writeByte(9);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionCategoryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
