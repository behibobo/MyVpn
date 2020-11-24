import 'package:qrscan_example/models/server.dart';

class Connection {
  final String region;
  final List<Server> servers;

  Connection({this.region, this.servers});

  factory Connection.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['servers'] as List;
    List<Server> serverList = list.map((i) => Server.fromJson(i)).toList();

    return Connection(region: parsedJson['region'], servers: serverList);
  }
}
