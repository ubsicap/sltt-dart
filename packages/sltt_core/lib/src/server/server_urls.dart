import 'server_ports.dart';

// Cloud Dev URL for production AWS Lambda endpoint
const String kCloudDevUrl =
    'https://u1e8wbi87a.execute-api.us-east-1.amazonaws.com/dev';

// Localhost URLs for local development servers
const String kLocalhostDownsyncsUrl = 'http://localhost:$kDownsyncsPort';
const String kLocalhostOutsyncsUrl = 'http://localhost:$kOutsyncsPort';
const String kLocalhostCloudStorageUrl = 'http://localhost:$kCloudStoragePort';
