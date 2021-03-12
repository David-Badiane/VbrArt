// One of the complex classes representing a vibrating element - spherical waves in water simulation

import toxi.color.*;

class WaterDrops{
  // members
  int cols;
  int rows;
  int counter = 1;
  ArrayList <float[][]> current;
  ArrayList <float[][]> previous;

  float dampWave = 0.95;    // damping of the wave 
  float dampText = 0.987;   // damping for grating texture for our water
  ColorGradient gradient = new ColorGradient();
  ToneMap toneMap;

  // constructor for actual background
  WaterDrops() {
    this.cols = width;
    this.rows = height;
    this.current = new ArrayList <float[][]> ();
    this.previous = new ArrayList <float[][]> ();
    //this.controlValue = 1;
    current.add( new float[cols][rows]);
    previous.add(new float[cols][rows]);
    
    TColor c1 = (TColor)NamedColor.LIGHTSTEELBLUE;
    TColor c2 = (TColor)NamedColor.MIDNIGHTBLUE;
    TColor c3 = (TColor)NamedColor.LIGHTSKYBLUE;
    gradient.addColorAt(0, c1.setAlpha(0.1));
    gradient.addColorAt(125, c2.setAlpha(0.4));
    gradient.addColorAt(255, c3.setAlpha(0.2));
    toneMap = new ToneMap(0, 1, gradient);  
    initialize();
  }
  
  // constructor for the intro background
  WaterDrops(float dampWave) {
    this.cols = width;
    this.rows = height;
    this.current = new ArrayList <float[][]> ();
    this.previous = new ArrayList <float[][]> ();
    this.dampWave = dampWave;
    dampText = 0.998;
    //this.controlValue = 1;
    current.add( new float[cols][rows]);
    previous.add(new float[cols][rows]);
    
    TColor c1 = (TColor)NamedColor.BLACK;
    TColor c2 = (TColor)NamedColor.MIDNIGHTBLUE;
    TColor c3 = (TColor)NamedColor.WHITE;
    gradient.addColorAt(0, c1.setAlpha(0.5));
    gradient.addColorAt(125, c2.setAlpha(0.4));
    gradient.addColorAt(255, c3.setAlpha(0.5));
    toneMap = new ToneMap(0, 1, gradient);  
    initialize();
    for( int radius = 50; radius < (int) height/2; radius += 150){
          for(float angle = 0; angle < 2*3.14; angle +=3.14/16){
          Vec2D stimOut = new Vec2D(width/2 + radius*cos(angle), height/2 + radius*sin(angle));
          stimulus(stimOut,3);
        }
      }
  }
  
  // starting animation
  void initialize(){
    for (int i = 1; i < cols-1; i += (int) random(10)) {
      for (int j = 1; j < rows-1; j += (int) random(10)) {
        current.get(0)[i][j] = random(j%4);
      }
    }
  }
  
  // apply a stimulus 
  void stimulus( Vec2D pos, float amplitude){
     int idx = (int)constrain(pos.x,2,width-2);
     int idy = (int)constrain(pos.y,2,height-2);
     previous.get(0)[idx][idy] = amplitude;
     previous.get(0)[idx-1][idy-1] = amplitude; 
  }
  
  // wave ropagation
  void propagate() { 
    background(0);
    loadPixels();
    
    for (int i = 1; i < cols-1; i++) {
      for (int j = 1; j < rows-1; j++) {
        // finite differences equation
        current.get(0)[i][j] = (
          previous.get(0)[i-1][j] + 
          previous.get(0)[i+1][j] +
          previous.get(0)[i][j-1] + 
          previous.get(0)[i][j+1]) / 2 -
          current.get(0)[i][j];
        int index = i + j * cols;
        if(current.get(0)[i][j] >= 3 ) {
          current.get(0)[i][j] = current.get(0)[i][j] * dampWave; 
          pixels[index] = color(current.get(0)[i][j]-50,current.get(0)[i][j],current.get(0)[i][j]+50);
        }
        else { 
          current.get(0)[i][j] = current.get(0)[i][j] * dampText; 
          pixels[index] = color(toneMap.getARGBToneFor(current.get(0)[i][j]));
        }
      }
    }
    
    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {
        int index = i + j * cols;
        if( i == 0 || j ==0 || i == cols-1 || j == rows-1) pixels[index] = color(toneMap.getARGBToneFor(current.get(0)[i][j]));
      }
    }
    updatePixels();
    float[][] temp = previous.get(0);
    previous.remove(0);
    previous.add(current.get(0));
    current.remove(0);
    current.add(temp);
  }
  
  // remove most of the elements in order to save memory
  void die(){
    for( int i = current.size()-1; i >=0; i--){
      current.remove(i);
    }
    for( int i = previous.size()-1; i >=0; i--){
      previous.remove(i);
    }
  }
  
  // recreate most of the elements
  void create(){
    current.add(new float [cols][rows]);
    previous.add(new float [cols][rows]);
    initialize();
    for( int radius = 20; radius < (int) height/2; radius += 100){
        for(float angle = 0; angle < 2*3.14; angle +=3.14/4){
        Vec2D stimOut = new Vec2D(width/2 + radius*cos(angle), height/2 + radius*sin(angle));
        stimulus(stimOut,20);
        propagate();
      }
    }
    initMusic();
  }
  
  // send OSC control message
  void send(int touch, float x, float y) {
  Object [] args = {touch, (constrain(x, -600,600)/1200.)+0.5, (constrain(y, -600, 600)/1200.)+0.5};
  OSCsendMessage("/Control/waterDrop", args);
  }
  
  // send OSC background message
  void initMusic(){
  Object [] args = {};
  OSCsendMessage("/Background/Water", args);
  }
}
