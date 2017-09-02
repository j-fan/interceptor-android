/*
  this is the chat client
 run command line using
 processing-java.exe --sketch="D:\Adelruna2\Documents\sketchbook\interceptor\client" --run argu "12001"
 */

import controlP5.*;
import oscP5.*;
import netP5.*;

int clientId = 0;

//interface
int bottomMargin = 100;
int topMargin = 100;
int leftMargin = 50;
int rightMargin = 50;
//change processing color array if this android colors also changes
String[] colorsA = {"#AAFFFE","#C8C8C8"};


//messages
MessagesList messages;

//network
OscP5 oscP5;
int listening = 31000;
int broadcast = 31000;
String sndPattern = "/client";
String  rcvPattern = "/interceptor";
NetAddress myBroadcastLocation;
String remoteAddress = "255.255.255.255";

void settings() {
  int w = displayWidth - 2;
  int h = displayHeight - 2;
  size(w, h,P2D); //p2d is workaround for threading issue in defaukt renderer
}

void setup() {

  //init message data structures
  bottomMargin = displayHeight / 4;
  topMargin = displayHeight / 10;
  messages = new MessagesList(8, width-350, height);

  textSize(56);
  orientation(PORTRAIT);

  // start up networking
  oscP5 = new OscP5(this, listening);
  myBroadcastLocation = new NetAddress("255.255.255.255", broadcast);

  Looper.prepare();
}

void draw() {
  background(50);
  messages.display();
  drawTitle();
}

void drawTitle(){
  //unfortunately have to declare colors array here
  //due to issues of it rendering black for all
  color[] colors = {color(#AAFFFE),color(#C8C8C8)};
  textSize(130);
  String t = "YOU ARE ";
  if(clientId==0){
    t += "BLUE";
  } else {
    t += "GREY";
  }
  fill(colors[clientId]);
  text(t,leftMargin,topMargin);
  textSize(56);
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
      //println("submit");
      OscMessage myOscMessage = new OscMessage(sndPattern);
      
      //placeholder for simulating 2 clients
      //int clientId = (int)(random(0, 2));
      
      //println(clientId);
      myOscMessage.add(clientId);
      myOscMessage.add(message);
      oscP5.send(myOscMessage, myBroadcastLocation);

      //temp for testing. show message immediately.
      //Message m = new Message(message, clientId);
      //messages.add(m);
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
      println("client got message");
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