/*
  this is the interceptor
 run command line using
 processing-java.exe --sketch="D:\Adelruna2\Documents\sketchbook\interceptor\mitm" --run
 */


import controlP5.*;
import oscP5.*;
import netP5.*;

//interface

String message = "";
int bottomMargin = 100;
int leftMargin = 50;
int rightMargin = 50;
int topMargin = 100;

//messages
MessagesList inward_messages;
MessagesList outward_messages;
boolean updateTextfield = false;
//network
OscP5 oscP5;
int listening = 31000;
int broadcast = 31000;
String sndPattern = "/interceptor";
NetAddressList myNetAddressList = new NetAddressList();

void settings() {
  int w = displayWidth - 2;
  int h = displayHeight - 2;
  size(w, h, P2D); //p2d is workaround for threading issue in defaukt renderer
}

void setup() {

  // start up networking
  oscP5 = new OscP5(this, listening);
  
  //UI stuff
  bottomMargin = displayHeight / 4;
  topMargin = displayHeight / 12;
  textSize(56);
  orientation(PORTRAIT);
  
  //init message data structures
  /*collects unmodified messages going in, works like queue
   *is it a waiting list to messages to be modified
    message 0 is the oldest*/
  inward_messages = new MessagesList(3, width-350, height); 
  //sends out modified messages and keeps a history of them to display
  outward_messages = new MessagesList(10, width-350, height);

  blast();
  Looper.prepare();
}

void draw() {
  background(50);
  outward_messages.display();
  /*
   * to update textfield, load the oldest inward message
   * and set the color according to id and text
   */
  if (updateTextfield) {
    Message oldest = inward_messages.getOldest();
    String[] colorsA = {"#AAFFFE","#C8C8C8"};
    //color c = inward_messages.getColor(oldest);
    //modifiedText.setText(oldest.text);
    //modifiedText.setColorBackground(c);
    //modifiedText.setLabel("edit the message from client "+oldest.id);
    //to update android UI, must run on ui thread
    class uiTask implements Runnable {
      String col;
      String text;
      public uiTask(String t, String c) {
        text = t;
        col = c;
      }
      public void run() {
        edit.setBackgroundColor(Color.parseColor(col));
        edit.setText(text);
      }
    }
    act.runOnUiThread(new uiTask(oldest.text,colorsA[oldest.id]));

    println(oldest.text);
    updateTextfield = false;
  }
  drawTitle();
}

void drawTitle(){
  textSize(100);
  fill(255);
  text("YOU ARE THE INTERCEPTOR",leftMargin,leftMargin,
       displayWidth-leftMargin-rightMargin,350);
  textSize(56);
}

/*
 * create a new modified message when user submits
 * to add to the outwards list
 * remove from inwards list
 * load the next inward message in textbox
 */

void submitModifiedMessage(String s) {
  class submitTask implements Runnable {
    String text;
    public submitTask(String s) {
      text = s;
    }
    public void run() {  
      Message m;
      m = new Message(text, inward_messages.getOldest().id);
      outward_messages.add(m);
      sendOSC(m);
      updateTextfield = true;
      inward_messages.removeOldest();
    }
  }
  Thread t = new Thread(new submitTask(s));
  t.start();
}

/*
 * handle textfield message contents when user submits via 'enter'
 */
void controlEvent(ControlEvent theEvent) {
  if (theEvent.isAssignableFrom(Textfield.class)) {
    String event = theEvent.getName();
    if (event.equals("message")) {
      String s =theEvent.getStringValue();
      submitModifiedMessage(s);
    }
  }
}

void sendOSC(Message m) {
  OscMessage myOscMessage = new OscMessage(sndPattern);
  myOscMessage.add(m.id);
  myOscMessage.add(m.text);
  oscP5.send(myOscMessage, myNetAddressList);
}

/*
 * intercept messages from clients & add the to inwards list
 * send oldest in inwards_messages when it is full
 * also tries to add new clients to send to when it sees a ip for first time
 */
void oscEvent(OscMessage theOscMessage) {
  class acceptTask implements Runnable {
    OscMessage theOscMessage;
    public acceptTask(OscMessage o) {
      theOscMessage = o;
    }
    public void run() {
      //println("mitm got a message");
      if (theOscMessage.checkAddrPattern("/client")) {
        //make sure there is only one 'temp' placeholder in the
        //textfield at any time
        int id = theOscMessage.get(0).intValue();
        String text = theOscMessage.get(1).stringValue();
        Message m = new Message(text, id);
        if (inward_messages.isFull()) {
          Message oldest = inward_messages.getOldest();
          outward_messages.add(oldest);
          sendOSC(oldest);
          inward_messages.removeOldest();
        }
        inward_messages.add(m); 
        updateTextfield = true;
      }
    }
  }
  Thread t = new Thread(new acceptTask(theOscMessage));
  t.start();
}

void blast() {
  OscMessage myOscMessage = new OscMessage("blast");
  NetAddress blasting = new NetAddress("255.255.255.255", broadcast);
  oscP5.send(myOscMessage, blasting);  
  myNetAddressList.add(new NetAddress(blasting));
}