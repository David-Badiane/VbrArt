// One of the complex classes representing a vibrating element - Sunset on the sea with music related objects

import toxi.geom.*;
import toxi.physics2d.*;
import toxi.physics2d.behaviors.*;
import processing.sound.*;
import toxi.color.*;

class Sunset{
  // members - graphic
  CA ca; 
  ArrayList<FFTline> lines;
  ArrayList<SkyObject> ufos;
  ArrayList<CA> suns;
  float[] spectrum = new float[nBin];
  boolean state = false;
  float step;
  float [][] sea;
  ColorGradient seaColors; 
  ToneMap toneMap;
  // members - music
  String [] modesNames = {"Dorian", "Lydian","Major", "Blues1", "Blues2", "Minor"};
  int modSelect = 0;
  // adjust SCL modal scale
  int modalAdjust[][] = {
                 {0,0,0,0,0,     0,0,0,0,0,     0,0},     //------ dorian
                 {0,0,1,0,0,     0,0,0,0,0,     0, 0},   //------ lydian
                 {0,0,1,0,0,     1,0,0,0,-1,    -2,-2},    //------ major
                 {0,-4,0,0,0,  -3,0,0,-3,0,    0,1},    //------ blues1
                 {0,-4,0,0,-12, -5,0,0,1,0,    0,0},     //------ blues2
                 {0,0,0,0,0,    -1,0,0,0,-2    -2,-2}     //------ minor
          };
  // notes role - duration wil be chosen from SCL in a different way accordingly to its role
  // t = tonic // c = chord // s = scale //  a = approach // d = dominant
  String roleNote[][] = {
                 { "t","s","c","s","d",  "s","s","t","s","s",  "d","a",},    //------ dorian
                 { "t","s","c","s","d",  "s","a","t","s","s",  "d","s",},    //------ lydian
                 { "t","a","c","s","d",  "s","a","t","s","s",  "d","s",},    //------ major
                 { "t","s","c","t","t",  "a","a","t","a","s",  "c","a",},    //------ blues1
                 { "t","s","c","s","t",  "t","s","t","t","t",  "s","a",},    //------ blues2
                 { "t","a","c","s","d",  "s","a","t","a","c",  "s","d",}     //------ minor
          };
          
  // constructor
  Sunset() {
    suns = new ArrayList<CA>();
    lines = new ArrayList<FFTline>(); 
    ufos = new ArrayList<SkyObject>();  
    addUfos();
    suns.add(new CA(width/2, height/2, 125));
    lines.add(new FFTline (spectrum));
    
    this.seaColors = new ColorGradient(); 
    formGradient();
    this.toneMap = new ToneMap(0, (int) (0.435*height), seaColors);
    this.sea = new float[width][(int)(0.435* height)];
    for (int i =0; i< width; i++){
      for (int j =0; j < (int) (0.435*height); j++){
      sea[i][j] = j;
     }
    }
    arrayCopy(spec, spectrum);
  }
  
  // update sunset
  void update() {
    // sky background - static
    int b = 280;
    for (int i = 0; i<(int)(0.568*height);i++){
        stroke(i +30,i/2+i/4+30,b/2-30);
        line(0,i,width,i);
      }
    // sea background - dynamic
    for (int i = 0; i<width;i++){
      for(int j = 0; j <(int) (0.435*height); j++){
        noStroke();
        fill(toneMap.getARGBToneFor(sea[i][j]));
        rect(i,height - j,1,1);
        sea[i][j] = (sea[i][j]+10 )%(int) (0.434*height);
      }
    }
    
    // update spectrum array and generate line and
    arrayCopy(spec, spectrum);
    generateLine();
    
    // sun display and updating ( with medium timer of 500 ms)
    suns.get(0).display();
    if(millis()>= midT.count * midT.T){
        midT.count +=1;
        suns.get(0).generate();
    }
    
    // update FFT lines
    for (int i = lines.size()-1 ; i >= 0; i--){
    FFTline lin = lines.get(i);
    if(lin.ref.y <= height*(1- 0.42)){lines.remove(i);}
    lin.update();
    lin.display();
    }
    
    // update stars
    for ( SkyObject u: ufos){
      u.update(spectrum);
    }
  }
  
  // generate a new line
  void generateLine(){
    lines.add(new FFTline (spectrum));
  } //<>//
  
  // remove most of elements in order to save memory
  void die(){
  for (int i = suns.size()-1; i >=0; i--){ suns.remove(i);}
  for (int i = lines.size()-1; i >=0; i--){lines.remove(i);}
  for (int i = ufos.size()-1; i >=0; i--){ufos.remove(i);}
  Object [] args = {false};
  OSCsendMessage("/Control/pythonListen", args);
  Object [] argsPy = {modesNames[modSelect], false};
  sendPy(argsPy);
  }
  
  // recreate elements
  void create(){
    suns.add(new CA(width/2, height/2, 125));
    lines.add(new FFTline (spectrum));
    addUfos();
    initMusic();
  }
  
  // update music mode (both governed by modSelect)
  void nextMode(){
    modSelect = (modSelect + 1)%( modesNames.length -1);
  }
  
  // refillage of cells and change how colorgradient is taken
  void refillAndChangeColors(){
     suns.get(0).mapwidth = ( suns.get(0).mapwidth+1)%100;
     suns.get(0).scrumble((modSelect+6)%9);
  }
  
  // form colorGradient
  void formGradient(){
    TColor c1 = (TColor)NamedColor.MIDNIGHTBLUE;;
    TColor c2 = (TColor)NamedColor.DARKBLUE;
    TColor c3 = (TColor)NamedColor.DARKSLATEBLUE;
    TColor c4 = (TColor)NamedColor.DARKBLUE;
    TColor c5 = (TColor)NamedColor.MIDNIGHTBLUE;
    
    seaColors.addColorAt(0, c1.setAlpha(0.8));
    seaColors.addColorAt(35, c2.setAlpha(0.5));
    seaColors.addColorAt(55, c3.setAlpha(0.9));
    seaColors.addColorAt(65, c4.setAlpha(0.5));
    seaColors.addColorAt(75, c3.setAlpha(0.9));
    seaColors.addColorAt(80, c2.setAlpha(0.5));
    seaColors.addColorAt(90, c2.setAlpha(0.5));
    seaColors.addColorAt(95, c3.setAlpha(0.9));
    seaColors.addColorAt(100, c4.setAlpha(0.5));
    seaColors.addColorAt(105, c3.setAlpha(0.9));
    seaColors.addColorAt(125, c2.setAlpha(0.5));
    seaColors.addColorAt(135, c3.setAlpha(0.9));
    seaColors.addColorAt(145, c4.setAlpha(0.5));
    seaColors.addColorAt(165, c3.setAlpha(0.9));
    seaColors.addColorAt(170, c3.setAlpha(0.9));
    seaColors.addColorAt(200, c4.setAlpha(0.5));
    seaColors.addColorAt(175, c2.setAlpha(0.5));
    seaColors.addColorAt(205, c3.setAlpha(0.9));
    seaColors.addColorAt(220, c4.setAlpha(0.5));
    seaColors.addColorAt(255, c5.setAlpha(0.8));
  }
  
  // add sky objects (stars)
  void addUfos(){
    for( int i =0; i<10; i++) {
    ufos.add( new SkyObject(new Vec2D( random(0,width/3),random(0,height/2)), 10, spectrum));
    }
    for( int i =0; i<10; i++) {
    ufos.add( new SkyObject(new Vec2D( random(2*width/3,width),random(0,height/2)), 10, spectrum));
    }
    for( int i =0; i<10; i++) {
    ufos.add( new SkyObject(new Vec2D( random(width/3,2*width/3),random(0,height/5)), 10, spectrum));
    }
  }
  
  // send control OSC messages both to SCL and Python
  void send(){
    // Let's send the mode of the melody
    Object [] argsMode = new Object [modalAdjust[0].length + 1];
    argsMode[0] = modesNames[modSelect];
    
    for(int i =1; i < modalAdjust[0].length+1; i++){
      argsMode[i] = modalAdjust[modSelect][i-1]; 
    }
    OSCsendMessage("/Control/sunModeChange/Mode", argsMode);
    
    // Let's send the role of the notes of the selected mode 
    Object [] argsRole = new Object [modalAdjust[0].length + 1];
    argsRole[0] = modesNames[modSelect];
    for(int i =1; i < roleNote[0].length+1; i++){
      argsRole[i] = roleNote[modSelect][i-1]; 
    }
    OSCsendMessage("/Control/sunModeChange/Role", argsRole);
    Object [] args = {modesNames[modSelect]};
    sendPy(args);
  }
  
  // function to send to Python
  void sendPy(Object [] args) {
    pyOSCsendMessage("/Python/sunMode", args);
  }
  
  // send initial background osc message
  void initMusic(){   
    Object [] args = { true};
    OSCsendMessage("/Background/Sunset", args);
    }
  }
