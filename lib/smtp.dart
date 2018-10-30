library smtp;

import 'dart:async' show Stream, Future;

export 'src/command.dart';
export 'src/server_session.dart';
export 'src/client_session.dart';

abstract class SmtpSocket {
  Stream<List<int>> get input;
  void add(List<int> data);
  Future<dynamic> close();
}


enum SmtpSessionMode {
  server,
  client,
  quit
}
