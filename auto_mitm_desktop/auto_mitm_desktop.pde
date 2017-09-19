/*
  this is the interceptor
 run command line using
 processing-java.exe --sketch="D:\Adelruna2\Documents\sketchbook\interceptor\mitm" --run
 */


import controlP5.*;
import oscP5.*;
import netP5.*;

//interface
ControlP5 cp5;
String message = "";
int bottomMargin = 100;
int leftMargin = 50;
int rightMargin = 50;
Textfield modifiedText;
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


void setup() {
  size(700, 1000);

  // start up networking
  oscP5 = new OscP5(this, listening);
   myNetAddressList.add(new NetAddress("255.255.255.255",broadcast));

  //init message data structures
  
  //collects unmodified messages going in, works like queue
  //is it a waiting list to messages to be modified
  //message 0 is the oldest
  inward_messages = new MessagesList(6, width-350, height-200); 
  //sends out modified messages and keeps a history of them to display
  outward_messages = new MessagesList(10, width-350, height-200);

  //init interface
  PFont font = createFont("arial", 20);
  cp5 = new ControlP5(this);
  modifiedText = cp5.addTextfield("message")
    .setColorBackground(color(200))
    .setColorForeground(color(200))
    .setColorActive(color(#D1FF5F))
    .setColor(color(0))
    .setPosition(leftMargin, height-bottomMargin)
    .setSize(350, 40)
    .setFont(createFont("arial", 16))
    .setAutoClear(true)
    .setLabel("message")
    .setText("");
  ;

  cp5.addBang("bang")
    .setColorBackground(color(200))
    .setColorForeground(color(200))
    .setColorActive(color(#D1FF5F))
    .setPosition(405, height-bottomMargin)
    .setSize(80, 40)
    .setTriggerEvent(Bang.RELEASE)
    .setLabel("submit")
    .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
    .setFont(createFont("arial", 16))
    ;    

  textFont(font);
}

void draw() {
  background(50);
  fill(255);
  outward_messages.display();
  /*
   * to update textfield, load the oldest inward message
   * and set the color according to id and text
   */
  if (updateTextfield) {
    Message oldest = inward_messages.getOldest();
    color c = inward_messages.getColor(oldest);
    modifiedText.setText(oldest.text);
    modifiedText.setColorBackground(c);
    modifiedText.setLabel("edit the message from client "+oldest.id);
    updateTextfield = false;
  }
}



/*
 * create a new modified message when user submits
 * to add to the outwards list
 * remove from inwards list
 * load the next inward message in textbox
 */

void submitModifiedMessage(Message m) {
  outward_messages.add(m);
  sendOSC(m);
  updateTextfield = true;
  inward_messages.removeOldest();
}

/*
 * handle textfield message contents when user submits via 'enter'
 */
void controlEvent(ControlEvent theEvent) {
  if (theEvent.isAssignableFrom(Textfield.class)) {
    String event = theEvent.getName();
    if (event.equals("message")) {
      String s =theEvent.getStringValue();
      Message m;
      m = new Message(s,inward_messages.getOldest().id);
      submitModifiedMessage(m);
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
  if (theOscMessage.checkAddrPattern("/client")) {
    connect(theOscMessage.netAddress().address());
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

private void connect(String theIPaddress) {
  if (!myNetAddressList.contains(theIPaddress, broadcast)) {
    myNetAddressList.add(new NetAddress(theIPaddress, broadcast));
    println("### adding "+theIPaddress+" to the list.");
  } else {
    println("### "+theIPaddress+" is already connected.");
  }
  println("### currently there are "+myNetAddressList.list().size()+" remote locations connected.");
}

/*
 * handle textfield message contents when user submits via 'send' button
 */
public void bang() {
  Message m = new Message(cp5.get(Textfield.class, "message").getText(), 0);
  submitModifiedMessage(m);
}