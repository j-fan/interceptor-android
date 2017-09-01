/*
  this is the chat client
 run command line using
 processing-java.exe --sketch="D:\Adelruna2\Documents\sketchbook\interceptor\client" --run argu "12001"
 */


import controlP5.*;
import oscP5.*;
import netP5.*;

//interface
int bottomMargin = 100;
int topMargin = 100;
int leftMargin = 50;
int rightMargin = 50;
//messages
MessagesList messages;
//network
OscP5 oscP5;
int listening = 31000;
int broadcast = 12000;
int clientId = 0;
String sndPattern = "/client";
String  rcvPattern = "/interceptor";
NetAddress myBroadcastLocation;

void settings() {
  int w = displayWidth - 2;
  int h = displayHeight - 2;
  size(w, h);
}

void setup() {
  // start up networking
  oscP5 = new OscP5(this, listening);
  myBroadcastLocation = new NetAddress("192.168.0.4", broadcast);

  //use command line args if supplied for networking
  /*if(args != null){
   if(args.length == 3){
   listening = parseInt(args[1]); 
   println("listening on port "+args[1]);
   clientId = parseInt(args[2]);
   } else {
   println(args.length +
   " args were provided. expecting 3 arg (listening port, client id)."); 
   }
   }*/
  //init message data structures
  bottomMargin = displayHeight / 4;
  messages = new MessagesList(8, width-350, height);

  textSize(56);
  orientation(PORTRAIT);

  Looper.prepare();
}

void draw() {
  background(50);
  fill(255);
  messages.display();
}

/*
 * when message it submitted, send to inteceptor
 */
void submitMessage(String message) { 
  class submitTask implements Runnable {
    String message;
    public submitTask(String m) {
      message = m;
    }
    public void run() {
      OscMessage myOscMessage = new OscMessage(sndPattern);
      //placeholder for simulating 2 clients
      int clientId = (int)(random(0, 2));
      println(clientId);
      myOscMessage.add(clientId);
      myOscMessage.add(message);
      oscP5.send(myOscMessage, myBroadcastLocation);

      //temp for testing
      Message m = new Message(message, clientId);
      messages.add(m);
    }
  }
  Thread t = new Thread(new submitTask(message));
  t.start();
}



void oscEvent(OscMessage theOscMessage) {
  class acceptTask implements Runnable {
    OscMessage theOscMessage;
    public acceptTask(OscMessage o) {
      theOscMessage = o;
    }
    public void run() {
      //only accept messages from the interceptor
      if (theOscMessage.checkAddrPattern(rcvPattern)==true) {
        int id = theOscMessage.get(0).intValue();
        String text = theOscMessage.get(1).stringValue();
        Message m = new Message(text, id);
        messages.add(m);
      }
    }
  }
  Thread t = new Thread(new acceptTask(theOscMessage));
  t.start();
}