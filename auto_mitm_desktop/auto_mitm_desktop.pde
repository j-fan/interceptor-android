/*
  this is the interceptor
 run command line using
 processing-java.exe --sketch="D:\Adelruna2\Documents\sketchbook\interceptor\mitm" --run
 */


import controlP5.*;
import oscP5.*;
import netP5.*;
import java.util.StringTokenizer;

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
HashMap<String,String> antonyms;


void setup() {
  size(700, 1000);

  // start up networking
  oscP5 = new OscP5(this, listening);
  myNetAddressList.add(new NetAddress("255.255.255.255",broadcast));

  //set up outward message list
  outward_messages = new MessagesList(10, width-350, height-200);
  PFont font = createFont("arial", 20);
    textFont(font);

  //send these dummy messages or else phones refuse to connect :(
  sendOSC(new Message("connect plz",0));
  sendOSC(new Message("connect plz",1));
  
  readAntonyms();

}

void readAntonyms(){
  BufferedReader reader = createReader("wordnet-antonyms.txt");
  String line = "";
  //hash antonym pairs for better performance
  antonyms = new HashMap<String,String>(); 

  while(line != null){
    String[] pieces = split(line, TAB);
    //add antonymn pairs 
    if(pieces.length == 2){
      pieces[0].replaceAll("_"," ");
      pieces[1].replaceAll("_"," ");
      antonyms.put(pieces[0],pieces[1]);
      antonyms.put(pieces[1],pieces[0]);
    }
    try{
      line = reader.readLine(); 
    } catch (IOException e){
      line = null;
    }  
    
  }
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
 * intercept and alter message automatically
 */
void oscEvent(OscMessage theOscMessage) {
  if (theOscMessage.checkAddrPattern("/client")) {
    //connect(theOscMessage.netAddress().address());
    //make sure there is only one 'temp' placeholder in the
    //textfield at any time
    int id = theOscMessage.get(0).intValue();
    String text = theOscMessage.get(1).stringValue();
    modifyAndSend(id,text);
    
  }
}

void modifyAndSend(int id, String text){
    StringTokenizer st = new StringTokenizer(text);
    String modified = "";
    while (st.hasMoreTokens()) {
      String oldToken = st.nextToken();
      String newToken = antonyms.get(oldToken);
      modified += " ";
      if(newToken != null){
         modified += newToken; 
      } else {
        modified += oldToken;
      }
    }
    Message m = new Message(modified, id);
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