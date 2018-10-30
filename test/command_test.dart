import 'package:test/test.dart' as test;
import 'package:dart.smtp/smtp.dart' as smtp;
import 'package:tiny_parser/parser.dart' as tiny;
import 'dart:convert' show utf8;
import 'dart:async' show Future;

void main() {
  test.group('A group of tests', () {

    test.setUp(() {
    });

    test.test('HELO', () async {
      tiny.ParserReader reader = new tiny.ParserByteBuffer.fromList(utf8.encode("HELO google.com\r\n"), true);
      tiny.TinyParser parser = new tiny.TinyParser(reader);
      smtp.SmtpCommand message = await smtp.SmtpCommand.decode(parser);
      test.expect(message.value, "google.com");
      test.expect(message.name, "helo");
    });

   test.test('HELO 2', () async {
      tiny.ParserReader reader = new tiny.ParserByteBuffer.fromList(utf8.encode("HELO xxx\r\n"), true);
      tiny.TinyParser parser = new tiny.TinyParser(reader);
      smtp.SmtpCommand message = await smtp.SmtpCommand.decode(parser);
      test.expect(message.value, "xxx");
      test.expect(message.name, "helo");
    });

    test.test('EHLO', () async {
        tiny.ParserReader reader = new tiny.ParserByteBuffer.fromList(utf8.encode("EHLO google.com\r\n"), true);
        tiny.TinyParser parser = new tiny.TinyParser(reader);
        smtp.SmtpCommand message = await smtp.SmtpCommand.decode(parser);
        test.expect(message.value, "google.com");
        test.expect(message.name, "ehlo");
    });

    test.test('QUIT', () async {
        tiny.ParserReader reader = new tiny.ParserByteBuffer.fromList(utf8.encode("QUIT\r\n"), true);
        tiny.TinyParser parser = new tiny.TinyParser(reader);
        smtp.SmtpCommand message = await smtp.SmtpCommand.decode(parser);
        test.expect(message.value, "");
        test.expect(message.name, "quit");
    });

    test.test('QUIT Fuzzy', () async {
        tiny.ParserReader reader = new tiny.ParserByteBuffer.fromList(utf8.encode("QUIT \r\n"), true);
        tiny.TinyParser parser = new tiny.TinyParser(reader);
        smtp.SmtpCommand message = await smtp.SmtpCommand.decode(parser);
        test.expect(message.value, "");
        test.expect(message.name, "quit");
    });

    test.test('\r\n.\r\n', () async {
        tiny.ParserReader reader = new tiny.ParserByteBuffer.fromList(utf8.encode("xxxx\r\nyyyy\r\n.\r\nxx"), true);
        tiny.TinyParser parser = new tiny.TinyParser(reader);
        List<int> data = await smtp.SmtpDataCommand.decodeDataContent(parser);
        test.expect(utf8.decode(data), "xxxx\r\nyyyy");
    });
    
    test.test('ZZZ', () async {
      tiny.ParserByteBuffer reader = new tiny.ParserByteBuffer();
      tiny.TinyParser parser = new tiny.TinyParser(reader);
      
      smtp.SmtpCommand message;
      smtp.SmtpCommand.decode(parser).then((m){message = m;});
      reader.addBytes(utf8.encode("HELO google.com\r\n"));
      await new Future((){});
      test.expect(message.value, "google.com");
      test.expect(message.name, "helo");
    });
  });
}
