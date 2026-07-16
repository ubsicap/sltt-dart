import 'websocket_management_client.dart';

/// Catch-all for any message whose "action" doesn't match a declared route
/// (e.g. a client-side keepalive ping). Just acks so the client can confirm
/// the socket is alive.
Future<Map<String, dynamic>> wsDefaultHandler(
  Map<String, dynamic> event, {
  required WebsocketManagementClient management,
}) async {
  final requestContext = (event['requestContext'] as Map)
      .cast<String, dynamic>();
  final connectionId = requestContext['connectionId'] as String;

  await management.send(connectionId, {'action': 'pong'});
  return {'statusCode': 200};
}
