import 'websocket_connections_repository.dart';

Future<Map<String, dynamic>> wsDisconnectHandler(
  Map<String, dynamic> event, {
  required WebsocketConnectionsRepository connections,
}) async {
  final requestContext = (event['requestContext'] as Map)
      .cast<String, dynamic>();
  final connectionId = requestContext['connectionId'] as String;

  await connections.deleteConnectionAndSubscriptions(connectionId);
  return {'statusCode': 200};
}
