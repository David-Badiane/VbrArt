class TextWriter{
  int startTime;
  int duration;
  String text;
  int size;
  int life;
  int timer = 255;
  PFont fontz;
  Vec2D position;
  
  TextWriter( String text, Vec2D pos){
    this.startTime = millis();
    this.duration = 5;
    this.text = text;
    this.size = 14;
    this.position = pos;
    this.fontz = createFont("Potra.ttf", size);
    textFont(fontz);
  }
  
  void changeText(String myText){
    text = myText;
  }
  
  void updateAndDisplay(){ 
    fill(255,255,255,70);
    text(text, position.x,position.y);
  }
  
  
}
