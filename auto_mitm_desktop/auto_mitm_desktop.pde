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
//messages
MessagesList outward_messages;
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


  outward_messages = new MessagesList(10, width-350, height-200);
  PFont font = createFont("arial", 20);
    textFont(font);

  //send these dummy messages or else phones refuse to connect :(
  sendOSC(new Message("connect plz",0));
  sendOSC(new Message("connect plz",1));

}

void draw() {
  background(50);
  fill(255);
  outward_messages.display();


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
    modifyAndSend(id,text);
    
  }
}

void modifyAndSend(int id, String text){
    Message m = new Message(text, id);
    outward_messages.add(m); 
    sendOSC(m);
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