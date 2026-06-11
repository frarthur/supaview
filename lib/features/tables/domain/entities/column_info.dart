class ColumnInfo {
  ColumnInfo({
    required this.name,
    required this.dataType,
    required this.isNullable,
    required this.isPrimaryKey,
    this.defaultValue,
  });

  final String name;
  final String dataType;
  final bool isNullable;
  final bool isPrimaryKey;
  final String? defaultValue;

  bool get isNumeric =>
      dataType.contains('int') || dataType.contains('float') || dataType.contains('double') || dataType.contains('numeric') || dataType.contains('real');

  bool get isText =>
      dataType.contains('char') || dataType.contains('text') || dataType.contains('varchar');

  bool get isBoolean => dataType.contains('bool');

  bool get isDateTime =>
      dataType.contains('date') || dataType.contains('timestamp') || dataType.contains('time');

  bool get isJson => dataType.contains('json');

  bool get isArray => dataType.contains('_') || dataType.endsWith('[]');
}
