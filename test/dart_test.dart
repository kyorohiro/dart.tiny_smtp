import 'package:test/test.dart' as test;
import 'package:dart.smtp/smtp.dart' as smtp;
import 'package:tiny_parser/parser.dart' as tiny;
import 'dart:convert' show utf8;

void main() {
  test.group('A group of tests', () {

    test.setUp(() {
    });

    test.test('HELO', () async {
      tiny.ParserReader reader = new tiny.ParserByteBuffer.fromList(utf8.encode("HELO google.com\r\n"), true);
      tiny.TinyParser parser = new tiny.TinyParser(reader);
      smtp.SmtpMessage message = await smtp.SmtpMessage.decode(parser);
      test.expect(message.value, "google.com");
      test.expect(message.action, "helo");
    });

    test.test('EHLO', () async {
        tiny.ParserReader reader = new tiny.ParserByteBuffer.fromList(utf8.encode("EHLO google.com\r\n"), true);
        tiny.TinyParser parser = new tiny.TinyParser(reader);
        smtp.SmtpMessage message = await smtp.SmtpMessage.decode(parser);
        test.expect(message.value, "google.com");
        test.expect(message.action, "ehlo");
    });

    test.test('QUIT', () async {
        tiny.ParserReader reader = new tiny.ParserByteBuffer.fromList(utf8.encode("QUIT\r\n"), true);
        tiny.TinyParser parser = new tiny.TinyParser(reader);
        smtp.SmtpMessage message = await smtp.SmtpMessage.decode(parser);
        test.expect(message.value, "");
        test.expect(message.action, "quit");
    });

    test.test('QUIT Fuzzy', () async {
        tiny.ParserReader reader = new tiny.ParserByteBuffer.fromList(utf8.encode("QUIT \r\n"), true);
        tiny.TinyParser parser = new tiny.TinyParser(reader);
        smtp.SmtpMessage message = await smtp.SmtpMessage.decode(parser);
        test.expect(message.value, "");
        test.expect(message.action, "quit");
    });
  });
}
