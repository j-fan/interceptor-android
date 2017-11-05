/*
  MessagesList stores and displays a fixed number of messages
  that all fit in a rectangular area specified by displayH
  and displayW
*/

class MessagesList{
  ArrayList<Message> messageList;
  int maxSize;
  int displayW; 
  int displayH;
  int boxH;
  color[] colors = {color(#AAFFFE),color(#C8C8C8),color(#E98A14)};
   
  MessagesList(int size, int w, int h){
    messageList = new ArrayList<Message>();
    displayW = w; 
    displayH = h;
    maxSize = size;
    boxH = (displayH - topMargin - bottomMargin) / size ;
  }
  
  void add(Message m){
    if(messageList.size()>=maxSize){
      messageList.remove(maxSize-1);
    }
    messageList.add(0,m);
    
  }
  
  void display(){
    for(int i=0; i<messageList.size();i++){
        // id = client id
        int id = messageList.get(i).id;
        color c = colors[id];
        fill(c);
        noStroke();
        String text = messageList.get(i).text;
        int h = 80;
        int xStart;
        xStart = leftMargin;
        
        //draw message box
        rect(xStart,topMargin +(boxH*(maxSize-i)), displayW,h);
        fill(color(0));
        //draw message text
        text(text,xStart+10,topMargin +(boxH*(maxSize-i))+10, displayW-10,h-10);
    }
    
  }
  
}