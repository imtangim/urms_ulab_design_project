// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';


class AuthResponseHeader {
  final String xPoweredBy;
  final String cacheControl;
  final String setCookie;
  final String date;
  final String contentLength;
  final String pragma;
  final String contentType;
  final String server;
  final String expires;

  AuthResponseHeader({
    required this.xPoweredBy,
    required this.cacheControl,
    required this.setCookie,
    required this.date,
    required this.contentLength,
    required this.pragma,
    required this.contentType,
    required this.server,
    required this.expires,
  });

  factory AuthResponseHeader.fromMap(Map<String, dynamic> map) {
    return AuthResponseHeader(
      xPoweredBy: map['x-powered-by'] as String,
      cacheControl: map['cache-control'] as String,
      setCookie: map['set-cookie'] as String,
      date: map['date'],
      contentLength: map['content-length'],
      pragma: map['pragma'] as String,
      contentType: map['content-type'] as String,
      server: map['server'] as String,
      expires: map['date'],
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'x-powered-by': xPoweredBy,
      'cache-control': cacheControl,
      'set-cookie': setCookie,
      'date': date,
      'content-length': contentLength,
      'pragma': pragma,
      'content-type': contentType,
      'server': server,
      'expires': expires,
    };
  }

  String toJson() => json.encode(toMap());

  factory AuthResponseHeader.fromJson(String source) =>
      AuthResponseHeader.fromMap(json.decode(source) as Map<String, dynamic>);
}
