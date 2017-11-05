/*
 * this is the client, to be run on android
 * it's job is to send, recieve and show messages
 * it sends and renders messages based on client id
 * it only supports id 0-2, which is 3 clients 
 * it doesn't attempt to handle case where the is >3 clients
 * you might notice that there is duplications of colorsA[]
 * and colors[] arrays since there seems to be some 
 * incompatiability with Processing and android's threads
 * causing globals to be uninitialised (no idea why)
 *
 * messages may not be recieved if you are on a network 
 * flagged as public on your OS
 */

import controlP5.*;
import oscP5.*;
import netP5.*;

int clientId = 1;

//interface
int bottomMargin = 100;
int topMargin = 100;
int leftMargin = 50;
int rightMargin = 50;
//change processing color array if this android colors also changes
String[] colorsA = {"#AAFFFE","#C8C8C8","#E98A14"};


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
  messages = new MessagesList(8, width-200, height);

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
  color[] colors = {color(#AAFFFE),color(#C8C8C8),color(#E98A14)};
 
  String t = "YOU ARE ";
  if(clientId==0){
    t += "BLUE";
    textSize(130);
  } else if (clientId==1){
    t += "GREY";
    textSize(130);
  } else {
    t += "ORANGE"; 
    textSize(100);
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

      OscMessage myOscMessage = new OscMessage(sndPattern);
      
      myOscMessage.add(clientId);
      myOscMessage.add(message);
      oscP5.send(myOscMessage, myBroadcastLocation);

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