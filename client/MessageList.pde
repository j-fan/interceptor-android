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
  color[] colors = {color(#AAFFFE),color(200)};
   
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
        int id = messageList.get(i).id % 2;
        color c = colors[id];
        fill(c);
        noStroke();
        //h is used to scale box according to message length
        String text = messageList.get(i).text;
        int h = (text.length() / 35 + 1) * 80;
        int xStart;
        if(id == 0){
          xStart = width-rightMargin-displayW;
        } else {
          xStart = leftMargin;
        }
        rect(xStart,topMargin +(boxH*(maxSize-i)), displayW,h);
        fill(color(0));
        text(text,xStart+10,topMargin +(boxH*(maxSize-i))+10, displayW-10,h-10);
    }
    
  }
  
}