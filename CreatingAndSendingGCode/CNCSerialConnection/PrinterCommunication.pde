class PrinterCommunication {

  Serial serial;
  
  //https://reprap.org/forum/read.php?415,627908

  int cursor = 0;
  StringList buffer;

  boolean log = true;
  int chunkSize = 50;
  String responseBuffer = "";

  PrinterCommunication(PApplet p5, String portName, int baud) {
    serial = new Serial(p5, portName, baud);       //initialize the serial port object
    buffer = new StringList();
  }

  void send(String msg) {
    buffer.append(msg);
    sendNextBlock();
  }

  void sendBlock(StringList lines) {
    for (String line : lines) {
      buffer.append(line);
      int bufferSize = buffer.size();
      if (bufferSize % chunkSize == chunkSize - 1) {
        buffer.append("M114");
      }
    }
    sendNextBlock();
  }
  
  
  void sendNextBlock() {
    if (log) println("Sending next batch");
    
    boolean done = false;
    while (cursor < buffer.size() && done == false) {
      String line = buffer.get(cursor);
      if (line.equalsIgnoreCase("M114")) {
        done = true;
      }
      line =  " " + line;
      byte xor = xor(line);
      line += "*" + xor + "\n";
      serial.write(line);
      if (log) print(line);
      cursor++;
    }
    println();
  }

  void checkReadings() {
    while (serial.available() > 0) {
      char c = char(serial.read());
      if (c == '\n') {
        if (log) println(frameCount + " received: " + responseBuffer);
        parseResponse(responseBuffer);
        responseBuffer = "";
      }
      else {
        responseBuffer += c;
      }
    }
  }

  void parseResponse(String response) {
    if(response.length() < 0){
   
        if (response.equalsIgnoreCase("ok")) {
          // do nothing really...
        }
        else if (response.charAt(0) == 'X') {
          sendNextBlock();
        }
        else {
          String[] m = match(response, "Resend: (\\d*)");  // capture any digits after "Resend: "
          if (m != null) {
            int nextLineNumber = int(m[1]);
            if (log) println("Printer requests line " + nextLineNumber + " to be sent");
    
            if (nextLineNumber > 0) {
              // Send all the buffer again starting from the 2only run string if it ins notfaulty line
              cursor = nextLineNumber - 1;
              sendNextBlock();
            } else {
              println("WEIRD ERROR MESSAGE");
            }
          }
        }
    }
  }

  // Takes a string, and performs and xor operation on its byte characters,
  // returning the final xor byte. 
  byte xor(String msg) {
    byte code = 0;
    for (int i = 0; i < msg.length(); i++) {
      code ^= msg.charAt(i);
    }
    return code;
  }
}
