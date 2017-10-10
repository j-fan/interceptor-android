/*
  this is the interceptor
 run command line using
 processing-java.exe --sketch="D:\Adelruna2\Documents\sketchbook\interceptor\mitm" --run
 */


import controlP5.*;
import oscP5.*;
import netP5.*;
import java.util.StringTokenizer;
import java.util.Date;

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
HashMap<String,ArrayList<String>> antonyms;
PrintWriter output;


void setup() {
  size(700, 1000);

  // start up networking
  oscP5 = new OscP5(this, listening);
  myNetAddressList.add(new NetAddress("255.255.255.255",broadcast));

  //set up outward message list
  outward_messages = new MessagesList(14, width-350, height-100);
  PFont font = createFont("arial", 20);
    textFont(font);

  //send these dummy messages or else phones refuse to connect :(
  sendOSC(new Message("connect plz",0));
  sendOSC(new Message("connect plz",1));
  
  readAntonyms();
  createLog();

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

void keyPressed() {
  endLog();
  exit();
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
      float chance = random(0,1);
      ArrayList<String> newTokens = antonyms.get(oldToken.toLowerCase());
      modified += " ";
      if(newTokens == null || newTokens.size() == 0 || chance>0.7){
        modified += oldToken;
        continue;  
      }
      println(newTokens.get(0));
      String newToken = newTokens.get(0);
      modified += newToken; 
    }
    addLog(id,modified);
    Message m = new Message(modified, id);
    outward_messages.add(m); 
    sendOSC(m);
}
void readAntonyms(){
  BufferedReader reader = createReader("wordnet-antonyms.txt");
  String line = "";
  //hash antonym pairs for better performance
  antonyms = new HashMap<String,ArrayList<String>>(); 

  while(line != null){
    String[] pieces = split(line, TAB);
    //add antonymn pairs 
    if(pieces.length == 2){
      pieces[0].replaceAll("_"," ");
      pieces[1].replaceAll("_"," ");
      
      pieces[0].replaceAll("-"," ");
      pieces[1].replaceAll("-"," ");
      
      /* add antonyms to a list so that we can have mutiple mappings to one word*/
      ArrayList<String> matchingList1 = antonyms.get(pieces[0]);
      ArrayList<String> matchingList2 = antonyms.get(pieces[0]);
      if(matchingList1 == null){
        matchingList1 = new ArrayList<String>(); 
      }
      if(matchingList2 == null){
        matchingList2 = new ArrayList<String>(); 
      }
      matchingList1.add(pieces[1]);
      matchingList2.add(pieces[0]);
      antonyms.put(pieces[0],matchingList1);
      antonyms.put(pieces[1],matchingList2);
    }
    try{
      line = reader.readLine(); 
    } catch (IOException e){
      line = null;
    }  
    
  }

}

void exit() {
  endLog();
} 

String mydate()
{
  Date d = new Date();
  String date = new java.text.SimpleDateFormat("hh-mm-sa_dd_MMM").format(d);
  return date;
} 

void createLog(){
  output = createWriter(mydate()+".txt"); 
}

void endLog(){
  output.flush(); 
  output.close(); // Finishes the file
}

void addLog(int clientid,String message){
  output.println("client "+clientid+": "+message);
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