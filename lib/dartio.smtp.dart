library smtp;

import 'dart:io' as io;
import 'dart:async' show Stream, Future;

import 'smtp.dart';

class DartIOSmtpSocket implements SmtpSocket {
  io.Socket socket;
  DartIOSmtpSocket(this.socket) {}
  Stream<List<int>> get input => socket;
  void add(List<int> data) { socket.add(data);}
  Future<dynamic> close() { return socket.close();}
}

class SimpleSmtpClient {
  io.Socket socket;
  String host;
  int port;

  SimpleSmtpClient(this.host, {this.port:25}) {
  }

  Future<dynamic> connect() async {
    this.socket = await io.Socket.connect(host, port);
  }



  Future<dynamic> start() async {
    if(this.socket == null) {
      await connect();
    }
    //..
  }

  Future<dynamic> stop() async {
    var o = await socket.close();
    socket = null;
    return o;
  }
}

class SimpleSmtpServer {

  io.ServerSocket server;


  Future<dynamic> start() async {
  server = await io.ServerSocket.bind("0.0.0.0", 2525);
    server.listen((io.Socket socket) {
      SmtpSocket smtpSocket = new DartIOSmtpSocket(socket);
      SmtpServerSession session = new SmtpServerSession(smtpSocket);
      session.startServer();
    });
  }

  Future<dynamic> stop() async {
    return server.close();
  }
}