import 'package:dart.smtp/smtp.dart';
import 'dart:async' show Stream, Future;
import 'package:tiny_parser/parser.dart' as p;
import 'dart:convert' show utf8; 


class SmtpServerSession {

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

  SmtpServerSession(this.socket, {this.domainName:"kyorohiro.info"}) {
    parser = new p.TinyParser(buffer = new p.ParserByteBuffer());
    socket.input.listen((List<int> data){
      print(">>"+utf8.decode(data, allowMalformed: true)+"<<");
      buffer.addBytes(data);
    }, onDone: (){socket.close();}, onError: (e){socket.close();});
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

  start() async { 
    print("server_session#start --1--");
    mode = SmtpSessionMode.server; 
    try {
      socket.add(utf8.encode("220 ${domainName} SMTP dart.smtp@kyorohiro\r\n"));
      await  onServerLoop();
      print("server_session#start --2--");
    } catch(e){
    } finally {
      print("server_session#start --3--");
      socket.close();
    }
  }


  Future<SmtpSessionMode> onServerLoop() async {
      outer:
      do {
        //
        SmtpCommand message = await receiveResponse();

        //
        print("##"+message.name);
        switch(message.name){
          case "helo":
            channelIsOpen = false;
            hostname = message.value.trim();
            if(hostname.length > 0){
              channelIsOpen = true;
              sendMessage(utf8.encode("250 ok ${domainName}\r\n"));
            } else {
              sendMessage(utf8.encode("501 Syntax error\r\n"));
            }
            break;
          case "quit":
            this.channelIsOpen = false;
            sendMessage(utf8.encode("250 ok\r\n"));
            break outer;
          case "mail":
            if(message.valueFromKey("from").length > 0){
              this.fromAddress = message.valueFromKey("from");
              sendMessage(utf8.encode("250 ok ${this.fromAddress}\r\n"));
            } else {
              sendMessage(utf8.encode("501 Syntax error\r\n"));
            }
            break;
          case "rcpt":
            if(message.valueFromKey("to").length > 0){
              this.toAddress = message.valueFromKey("to");
              sendMessage(utf8.encode("250 ok ${this.toAddress}\r\n"));
            } else {
              sendMessage(utf8.encode("501 Syntax error\r\n"));
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
            sendMessage(utf8.encode("250 ok \r\n"));
            break;
          case "noop":
          case "help":
            sendMessage(utf8.encode("250 ok \r\n"));
            break;
          case "none":
            sendMessage(utf8.encode("500 Syntax error, command unrecognized\r\n"));
            break;
          case "turn":
            //socket.add(utf8.encode("250 ok \r\n"));
            //return SmtpSessionMode.client;
          case "send":
          case "soml":
          case "saml":
          default:
            sendMessage(utf8.encode("502 Command not implemented\r\n"));          
            break;
        }
      } while(true);

      return SmtpSessionMode.quit;
  }

}
