import 'dart:convert';

import 'package:flutter/services.dart';

class SecretService {
  final String clientSecret;

  SecretService({this.clientSecret});

  factory SecretService.fromJson(Map<String, dynamic> jsonMap) {
    return new SecretService(clientSecret: jsonMap['client_secret']);
  }

  static Future<SecretService> getApiKeys() async {
    return rootBundle.loadStructuredData(
        'secrets.json',
        (jsonSecrets) async =>
            SecretService.fromJson(json.decode(jsonSecrets)));
  }
}
