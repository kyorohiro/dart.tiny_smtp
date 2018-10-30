import 'package:dart.smtp/smtp.dart';
import 'dart:async' show Stream, Future;
import 'package:tiny_parser/parser.dart' as p;
import 'dart:convert' show utf8; 



class SmtpClientSession {

  SmtpSocket socket;
  p.TinyParser parser;
  p.ParserByteBuffer buffer;

  SmtpClientSession(this.socket) {
    parser = new p.TinyParser(buffer = new p.ParserByteBuffer());
    socket.input.listen((List<int> data){
      print(">>"+utf8.decode(data, allowMalformed: true)+"<<");
      buffer.addBytes(data);
    });
  }

  Future<dynamic> sendMessage(List<int> message) async {
    return await this.socket.add(message);
  }

  Future<SmtpResponse> receiveResponse() async {
      SmtpResponse message = SmtpResponse("none","");
      try {
        message = await SmtpResponse.decode(parser);
      } catch(e){
      }
      return message;
  }

  Future<String> startMail() async {
    
  }


}
