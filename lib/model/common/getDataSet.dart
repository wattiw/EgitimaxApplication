class GetDataSet {
  String query;
  List<SqlParameter> parameters;
  int commandType;
  int getNoSqlData;
  GetDataSet(this.query, this.parameters, this.commandType,this.getNoSqlData);

  Map<String, dynamic> toMap() {
    return {
      'query': query,
      'parameters': parameters.map((param) => param.toMap()).toList(),
      'commandType': commandType,
      'getNoSqlData': getNoSqlData,
    };
  }
}

class SqlParameter {
  String name;
  dynamic value;

  SqlParameter(this.name, this.value);

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'value': value.toString(),
    };
  }
}

