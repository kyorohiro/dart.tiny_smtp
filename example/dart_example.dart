import 'package:dart.smtp/dartio.smtp.dart';
import 'package:dart.smtp/smtp.dart';
import 'dart:io' as io;

main() async {
  print('Hello World!!');
  List<io.InternetAddress> addrs = await io.InternetAddress.lookup("gmail.com");
  addrs.forEach((io.InternetAddress addr){
    print(addr.host+" : "+addr.address);
  });

  io.ServerSocket server = await io.ServerSocket.bind("0.0.0.0", 2525);
  server.listen((io.Socket socket) {
     SmtpServerSession session = new SmtpServerSession(new DartIOSmtpSocket(socket));
     session.start();
  });

  
}
