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
      tiny.ParserReader reader = new tiny.ParserByteBuffer.fromList(utf8.encode("HELO google.com\r\n"), true);
      tiny.TinyParser parser = new tiny.TinyParser(reader);
      smtp.SmtpCommand message = await smtp.SmtpCommand.decode(parser);
      test.expect(message.value, "google.com");
      test.expect(message.name, "helo");
      print("call e test");
    });

  });
}
