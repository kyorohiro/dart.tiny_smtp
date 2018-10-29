import 'package:tiny_parser/parser.dart' show TinyParser;
import 'dart:async' show Future;
import 'dart:async' show Stream;
import 'dart:async' show StreamController;
import 'dart:convert' show utf8;


typedef decodeFunc (TinyParser p);

class SmtpMessage {
  String action;
  String value;

  SmtpMessage(){
  }

  static Future<SmtpMessage> decode(TinyParser parser) async {
    try {
      parser.push();
      return await SmtpMessage._decodeBase(parser);
    } catch (e) {
      parser.back();
    }finally {
      parser.pop();
    }
    throw "";
  }

  // HELO <SP> <domain> <CRLF>
  // MAIL <SP> FROM:<reverse-path> <CRLF>
  // RCPT <SP> TO:<forward-path> <CRLF>
  // DATA <CRLF>
  // RSET <CRLF>
  // SEND <SP> FROM:<reverse-path> <CRLF>
  // SOML <SP> FROM:<reverse-path> <CRLF>
  // SAML <SP> FROM:<reverse-path> <CRLF>
  // VRFY <SP> <string> <CRLF>
  // EXPN <SP> <string> <CRLF>
  // HELP [<SP> <string>] <CRLF>
  // NOOP <CRLF>
  // QUIT <CRLF>
  // TURN <CRLF>
  // TURN <CRLF>
  static Future<SmtpMessage> _decodeBase(TinyParser parser) async {
    String action = "";
    String value = "";

    action = await decodeBySpaceAndCrlf(parser);
    if(0x20 == parser.readByteSync(moveOffset: false)) {
      await parser.moveOffset(1);
      value = await decodeByCRLF(parser);
    }
    await decodeCRLF(parser);
    return new SmtpMessage()
      ..action = action.toLowerCase()
      ..value = value;
  }

  static Future<String> decodeCRLF(TinyParser parser) async {
    return parser.nextString("\r\n");
  }

  static Future<String> decodeByCRLF(TinyParser parser) async {
    int index = parser.index;
    while(true) {
      try {
        parser.push();
        if(0xd == await parser.readByte() && 0xa == await parser.readByte()){
          parser.back();
          break;
        }
      } catch(e){
      } finally {
        parser.pop();
      }
      await parser.getBytes(1);
    }
    return utf8.decode(await parser.buffer.getBytes(index,parser.index-index),allowMalformed: true);
  }

  static Future<String> decodeBySpaceAndCrlf(TinyParser parser) async {
    int index = parser.index;
    int tmp = 0;
    while(true) {
      try {
        parser.push();
        tmp = await parser.readByte();
        // space
        if(tmp == 0x20) {
          parser.back();
          break;
        }
        // crlf
        else if(tmp == 0xd && await parser.readByte() == 0xa) {
          parser.back();
          break;
        }
      } catch(e){} finally {
        parser.pop();
      }
      await parser.getBytes(1);
    }
    return utf8.decode(await parser.buffer.getBytes(index,parser.index-index),allowMalformed: true);
  }

  static Future<List<int>> decodeDataContent(TinyParser parser) async {
    List<int> tmp = List<int>(5);
    int start = parser.index;
    int end = start;
    try {
      parser.push();
      do {
        if(!parser.hasBuffer(5)) {
          await parser.waitByBuffered(5);
        } 
        parser.readBytesSync(5, tmp, moveOffset: false);
        if(tmp[0] == 0x0d && tmp[1] == 0x0a && tmp[2] == 0x2e
          && tmp[3] == 0x0d && tmp[4] == 0x0a) {
          break;
        } 
        parser.moveOffset(1);
      } while(true);
      parser.pop();
      end = parser.index;
      parser.resetIndex(start);
      return parser.getBytes(end-start);
    } catch (e){
      parser.back();
      parser.pop();
      throw e;
    } 
  }

  static Stream<List<int>> decodeDotaStream(TinyParser parser) {
    StreamController<List<int>> controller = new StreamController<List<int>>();
    new Future(() async{
      while(true) {
        try {
          await parser.nextString("\r\n.\r\n");
          controller.close();
          break;
        } catch(e){
        }
        controller.add(await parser.getBytes(1));
      }
    });
    return controller.stream;
  }
}