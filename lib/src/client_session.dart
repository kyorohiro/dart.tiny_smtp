import 'package:dart.smtp/smtp.dart';
import 'dart:async' show Stream, Future;
import 'package:tiny_parser/parser.dart' as p;
import 'dart:convert' show utf8; 



class SmtpClientSession {

  String domainName;
  SmtpSocket socket;
  p.TinyParser parser;
  p.ParserByteBuffer buffer;

  bool channelIsOpen = false;
  String hostname;
  String fromAddress;
  String toAddress;
  List<int> data;

  SmtpSessionMode mode = SmtpSessionMode.server; 

  SmtpClientSession(this.socket,{this.domainName:"kyorohiro.info"}) {
    parser = new p.TinyParser(buffer = new p.ParserByteBuffer());
    socket.input.listen((List<int> data){
      print(">>"+utf8.decode(data, allowMalformed: true)+"<<");
      buffer.addBytes(data);
    });
  }

  Future<dynamic> sendMessage(List<int> message) async {
    return await this.socket.add(message);
  }

  Future<SmtpCommand> receiveResponse() async {
      SmtpCommand message = SmtpCommand("none","");
      try {
        message = await SmtpCommand.decode(parser);
      } catch(e){
      }
      return message;
  }

  startServer() async {    
    mode = SmtpSessionMode.server; 
    try {
      socket.add(utf8.encode("220 ${domainName} SMTP dart.smtp@kyorohiro\r\n"));
      SmtpSessionMode ret = await  onServerLoop();
      if(ret == SmtpSessionMode.client) {
        startClient();
      } else {
        socket.close();
      } 
    } catch(e){
      socket.close();
    } finally {
    }
  }

  startClient() async {
    mode = SmtpSessionMode.client; 
    try {
      socket.add(utf8.encode("220 ${domainName} SMTP dart.smtp@kyorohiro\r\n"));
      SmtpSessionMode ret = await  onServerLoop();
      if(ret == SmtpSessionMode.client) {
        startClient();
      } else {
        socket.close();
      } 
    } catch(e){
      socket.close();
    } finally {
    }
  }

  onClientLoop() async {
    
  }

  Future<SmtpSessionMode> onServerLoop() async {
      outer:
      do {
        SmtpCommand message = SmtpCommand("none","");
        try {
          message = await SmtpCommand.decode(parser);
        } catch(e){
        }
        print("##"+message.name);
        switch(message.name){
          case "helo":
            channelIsOpen = false;
            hostname = message.value.trim();
            if(hostname.length > 0){
              channelIsOpen = true;
              socket.add(utf8.encode("250 ok ${domainName}\r\n"));
            } else {
              socket.add(utf8.encode("501 Syntax error\r\n"));
            }
            break;
          case "quit":
            this.channelIsOpen = false;
            socket.add(utf8.encode("250 ok\r\n"));
            break outer;
          case "mail":
            if(message.valueFromKey("from").length > 0){
              this.fromAddress = message.valueFromKey("from");
              socket.add(utf8.encode("250 ok ${this.fromAddress}\r\n"));
            } else {
              socket.add(utf8.encode("501 Syntax error\r\n"));
            }
            break;
          case "rcpt":
            if(message.valueFromKey("to").length > 0){
              this.toAddress = message.valueFromKey("to");
              socket.add(utf8.encode("250 ok ${this.toAddress}\r\n"));
            } else {
              socket.add(utf8.encode("501 Syntax error\r\n"));
            }
            break;
          case "data":
            socket.add(utf8.encode("354 End data with <CR><LF>.<CR><LF>\r\n"));
            data = await SmtpDataCommand.decodeDataContent(parser);
            break;
          case "reset":
            hostname = "";
            fromAddress = "";
            toAddress = "";
            data.clear();
            socket.add(utf8.encode("250 ok \r\n"));
            break;
          case "noop":
          case "help":
            socket.add(utf8.encode("250 ok \r\n"));
            break;
          case "none":
            socket.add(utf8.encode("500 Syntax error, command unrecognized\r\n"));
            break;
          case "turn":
            socket.add(utf8.encode("250 ok \r\n"));
            return SmtpSessionMode.client;
          case "send":
          case "soml":
          case "saml":
          default:
            socket.add(utf8.encode("502 Command not implemented\r\n"));          
            break;
        }
      } while(true);

      return SmtpSessionMode.quit;
  }

}
