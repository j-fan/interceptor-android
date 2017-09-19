/*
  MessagesList stores and displays a fixed number of messages
 that all fit in a rectangular area specified by displayH
 and displayW
 */

class MessagesList {
  ArrayList<Message> messageList;
  int maxSize;
  int displayW; 
  int displayH;
  int boxH;
  color[] colors = {color(#AAFFFE), color(200)};

  MessagesList(int size, int w, int h) {
    messageList = new ArrayList<Message>();
    displayW = w; 
    displayH = h;
    maxSize = size;
    boxH = displayH / size ;
  }

  void add(Message m) {
    if (messageList.size()>=maxSize) {
      messageList.remove(maxSize-1);
    }

    messageList.add(0, m);
  }


  
  String toString() {
    String str = "printing messagelist...\n";
    for (Message m : messageList) {
      str += "\"" + m.text + "\"" + " id:"+ m.id + "\n";
    }
    return str;
  }


  boolean isFull() {
    return messageList.size() == maxSize;
  }

  boolean isEmpty() {
    return messageList.size() == 0;
  }

  void removeOldest() {
    if (!messageList.isEmpty()) {
      messageList.remove(messageList.size()-1);
    }
  }

  color getColor(Message m) {
    return colors[m.id % 2];
  }
  color getColor(int i) {
    return colors[i % 2];
  }  
  void display() {
    for (int i=0; i<messageList.size(); i++) {
      int id = messageList.get(i).id % 2;
      color c = colors[id];
      fill(c);
      noStroke();
      //h is used to scale box according to message length
      String text = messageList.get(i).text;
      int h = (text.length() / 35 + 1) * 30;
      int xStart;
      if (id == 0) {
        xStart = width-rightMargin-displayW;
      } else {
        xStart = leftMargin;
      }
      rect(xStart, boxH*(maxSize-i), displayW, h);
      fill(color(0));
      text(text, xStart+10, boxH*(maxSize-i), displayW-25, h);
    }
  }
}