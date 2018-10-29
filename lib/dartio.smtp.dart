library smtp;

export 'smtp.dart';

import 'package:dart.smtp/smtp.dart';
import 'dart:io' as io;
import 'dart:async' show Stream, Future;

class DartIOSmtpSocket implements SmtpSocket{
  io.Socket socket;
  DartIOSmtpSocket(this.socket) {}
  Stream<List<int>> get input => socket;
  void add(List<int> data) { socket.add(data);}
  Future<dynamic> close() { return socket.close();}
}