import 'package:test/test.dart' as test;
import 'package:dart.smtp/dartio.smtp.dart' as smtp;
import 'package:dart.smtp/smtp.dart' as smtp;

import 'package:tiny_parser/parser.dart' as tiny;
import 'dart:convert' show utf8;
import 'dart:async' show Future;


void main() {
  smtp.SimpleSmtpServer server = null;
  test.group('A group of tests', () {

    test.setUp(() async {
      print("call s setUp");
      server = new smtp.SimpleSmtpServer();
      await server.start();
      print("call e setUp");
    });
    test.tearDown(() async {
      print("call s tearDown");
      await server.stop();
      print("call e tearDown");
    });
    test.test('HELO', () async {
      print("call s test");
      
      smtp.SimpleSmtpClient client = new smtp.SimpleSmtpClient(host: "0.0.0.0", port: 2525);
      await client.connect();
      
      smtp.SmtpResponse response = null;
      response =  await client.session.receiveResponse();
      print("### 1 # ${response.name} ${response.value}");

      await client.session.sendMessage(utf8.encode("HELO xxxxx\r\n"));
      response = await client.session.receiveResponse();

      print("### 2 # ${response.name} ${response.value}");
      
      await client.close();
      
      print("call e test");
    });

  });
}
