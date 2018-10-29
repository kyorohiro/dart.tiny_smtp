//import 'package:dart/dart.dart';
import 'package:dart.smtp/smtp.dart';
import 'dart:io' as io;
import 'dart:async' show Stream;
import 'package:tiny_parser/parser.dart' as p;
import 'dart:convert' show utf8; 

main() async {
  print('Hello World!!');
  List<io.InternetAddress> addrs = await io.InternetAddress.lookup("gmail.com");
  addrs.forEach((io.InternetAddress addr){
    print(addr.host+" : "+addr.address);
  });

  io.ServerSocket server = await io.ServerSocket.bind("0.0.0.0", 2525);
  server.listen((io.Socket socket) {
     SmtpSession session = new SmtpSession(SmtpSocket(socket));
     session.start();
  });

  
}

class SmtpSocket {
  io.Socket socket;

  SmtpSocket(this.socket) {
  }

  Stream<List<int>> get input => socket;

  void add(List<int> data) { socket.add(data);}


}

class SmtpSession {

  String domainName;
  SmtpSocket socket;
  p.TinyParser parser;
  p.ParserByteBuffer buffer;

  bool channelIsOpen = false;
  String hostname;
  String fromAddress;
  String toAddress;


  SmtpSession(this.socket,{this.domainName:"kyorohiro.info"}) {
    parser = new p.TinyParser(buffer = new p.ParserByteBuffer());
    socket.input.listen((List<int> data){
      print(">>"+utf8.decode(data)+"<<");
      buffer.addBytes(data);
    });
  }

  start() async {
    socket.add(utf8.encode("220 ${domainName} SMTP dart.smtp@kyorohiro\r\n"));
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
          break;
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
          SmtpDataCommand.decodeDataContent(parser);
          break;
        case "none":
          socket.add(utf8.encode("500 Syntax error, command unrecognized\r\n"));
          break;
        default:
          socket.add(utf8.encode("502 Command not implemented\r\n"));          
          break;
      }
    } while(true);
  }

}
/*
      4.2.1.  REPLY CODES BY FUNCTION GROUPS

         500 Syntax error, command unrecognized
            [This may include errors such as command line too long]
         501 Syntax error in parameters or arguments
         502 Command not implemented
         503 Bad sequence of commands
         504 Command parameter not implemented

         211 System status, or system help reply
         214 Help message
            [Information on how to use the receiver or the meaning of a
            particular non-standard command; this reply is useful only
            to the human user]

         220 <domain> Service ready
         221 <domain> Service closing transmission channel
         421 <domain> Service not available,
             closing transmission channel
            [This may be a reply to any command if the service knows it
            must shut down]

         250 Requested mail action okay, completed
         251 User not local; will forward to <forward-path>
         450 Requested mail action not taken: mailbox unavailable
            [E.g., mailbox busy]
         550 Requested action not taken: mailbox unavailable
            [E.g., mailbox not found, no access]
         451 Requested action aborted: error in processing
         551 User not local; please try <forward-path>
         452 Requested action not taken: insufficient system storage
         552 Requested mail action aborted: exceeded storage allocation
         553 Requested action not taken: mailbox name not allowed
            [E.g., mailbox syntax incorrect]
         354 Start mail input; end with <CRLF>.<CRLF>
         554 Transaction failed
         */