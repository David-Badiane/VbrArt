import toxi.geom.*;
import toxi.physics2d.*;
import toxi.physics2d.behaviors.*;

class Plate{
ArrayList<Particle> particles;
ArrayList <Attractor> attractors;
ArrayList<Vec2D> startPos;    // each time it restarts we put same positions
Rect rect; // world bounds
Attractor a;
float w = width;
float h = height;
int nAttr;
int nParticles = 2000;
int totalLife;
float [][] modes = {
                  // idle state to compute intervals
                  {},
                  //first mode
                  { 9*w/20, h/2, 11*w/20, h/2},
                  //second mode 
                  {0.28*w, 0.42*h, 0.28*w,   0.58*h,
                   0.72*w, 0.42*h ,0.72*w,   0.58*h,
                   0.72*w, 0.5*h ,0.28*w,   0.5*h},
                  //third mode
                  {w/2,      0.3*h,    w/2, 0.7*h,
                   0.46*w,   0.3*h, 0.42*w, 0.3*h,
                   0.38*w,   0.3*h, 0.34*w, 0.3*h,
                   0.54*w,   0.3*h, 0.58*w, 0.3*h,
                   0.62*w,   0.3*h, 0.66*w, 0.3*h,
                   0.54*w,   0.7*h, 0.58*w, 0.7*h,
                   0.62*w,   0.7*h, 0.66*w, 0.7*h,
                   0.46*w,   0.7*h, 0.42*w, 0.7*h,
                   0.38*w,   0.7*h, 0.34*w, 0.7*h},
                  //fourth mode
                   {w/4,    h/4, w/4,    3*h/4,
                    3*w/4,  h/4, 3*w/4,  3*h/4,
                    0.3*w,  h/4, 0.3*w,    3*h/4,
                    0.7*w,  h/4, 0.7*w,  3*h/4
                    },
                  //fifth mode
                  { w/6,   h/4,   w/2,    h/4, 5*w/6,   h/4,
                    w/6,   3*h/4, w/2,  3*h/4, 5*w/6, 3*h/4,
                    w/6,   0.3*h, w/2,  0.3*h, 5*w/6, 0.3*h,
                    w/6,   0.7*h, w/2,  0.7*h, 5*w/6, 0.7*h},
                  //sixth mode
                  { w/8,   h/2,    3*w/8,    h/2, 5*w/8,    h/2, 7*w/8,    h/2,
                    w/8,   0.46*h, 3*w/8, 0.46*h, 5*w/8, 0.46*h, 7*w/8, 0.46*h,
                    w/8,   0.42*h, 3*w/8, 0.42*h, 5*w/8, 0.42*h, 7*w/8, 0.42*h,
                    w/8,   0.38*h, 3*w/8, 0.38*h, 5*w/8, 0.38*h, 7*w/8, 0.38*h,
                    w/8,   0.34*h, 3*w/8, 0.34*h, 5*w/8, 0.34*h, 7*w/8, 0.34*h,
                    w/8,   0.30*h, 3*w/8, 0.30*h, 5*w/8, 0.30*h, 7*w/8, 0.30*h,
                    w/8,   0.26*h, 3*w/8, 0.26*h, 5*w/8, 0.26*h, 7*w/8, 0.26*h,
                    w/8,   0.22*h, 3*w/8, 0.22*h, 5*w/8, 0.22*h, 7*w/8, 0.22*h,
                    w/8,   0.54*h, 3*w/8, 0.54*h, 5*w/8, 0.54*h, 7*w/8, 0.54*h,
                    w/8,   0.58*h, 3*w/8, 0.58*h, 5*w/8, 0.58*h, 7*w/8, 0.58*h,
                    w/8,   0.62*h, 3*w/8, 0.62*h, 5*w/8, 0.62*h, 7*w/8, 0.62*h,
                    w/8,   0.66*h, 3*w/8, 0.66*h, 5*w/8, 0.66*h, 7*w/8, 0.66*h,
                    w/8,   0.70*h, 3*w/8, 0.70*h, 5*w/8, 0.70*h, 7*w/8, 0.70*h,
                    w/8,   0.74*h, 3*w/8, 0.74*h, 5*w/8, 0.74*h, 7*w/8, 0.74*h,
                    w/8,   0.78*h, 3*w/8, 0.78*h, 5*w/8, 0.78*h, 7*w/8, 0.78*h},
                  // seventh mode
                  { 0.48*w,  h/8,   0.52*w,  h/8,
                    0.48*w,  3*h/8, 0.52*w,  3*h/8, 
                    0.48*w,  5*h/8, 0.52*w,  5*h/8,
                    0.48*w,  7*h/8, 0.52*w,  7*h/8,
                    0.42*w,  h/8,   0.58*w,  h/8,
                    0.42*w,  3*h/8, 0.58*w,  3*h/8, 
                    0.42*w,  5*h/8, 0.58*w,  5*h/8,
                    0.42*w,  7*h/8, 0.58*w,  7*h/8,
                    0.38*w,  h/8,   0.62*w,  h/8,
                    0.38*w,  3*h/8, 0.62*w,  3*h/8, 
                    0.38*w,  5*h/8, 0.62*w,  5*h/8,
                    0.38*w,  7*h/8, 0.62*w,  7*h/8,
                    0.34*w,  h/8,   0.66*w,  h/8,
                    0.34*w,  3*h/8, 0.66*w,  3*h/8, 
                    0.34*w,  5*h/8, 0.66*w,  5*h/8,
                    0.34*w,  7*h/8, 0.66*w,  7*h/8,
                    0.3*w,  h/8,   0.7*w,  h/8,
                    0.3*w,  3*h/8, 0.7*w,  3*h/8, 
                    0.3*w,  5*h/8, 0.7*w,  5*h/8,
                    0.3*w,  7*h/8, 0.7*w,  7*h/8,
                    0.26*w,  h/8,   0.74*w,  h/8,
                    0.26*w,  3*h/8, 0.74*w,  3*h/8, 
                    0.26*w,  5*h/8, 0.74*w,  5*h/8,
                    0.26*w,  7*h/8, 0.74*w,  7*h/8}
                 };
  int freq;
  float [] eigenfreqz = {0, 100, 140, 179, 220, 310, 400, 440, 4001};
  int mode;
  float [] field = {0,w/4, 120, 90, 110, 90, 70, 55};        // fields of attractors for each mode
  float [] scaleForce = {0,1, 0.8,0.8, 0.9, 0.7, 0.9,0.7};   // fine adjustment of resonance for each mode
  float myInterval [] = new float[2];
  float deviation [] = new float[9];
  float band;

  Plate(){
    physics.setDrag(0.6);
    physics.setWorldBounds(rect);
    particles = new ArrayList<Particle>();
    startPos= new ArrayList<Vec2D>();
    for (int i = 0; i < nParticles; i++) {
      startPos.add(new Vec2D(random(width),random(height)));
      particles.add(new Particle(startPos.get(i)));
      Particle p = particles.get(i);
      this.totalLife += p.life;
    } 
    attractors = new ArrayList <Attractor>(); 
    rect = new Rect(0,0,width,height);
    this.freq =100;
  }
  
  
boolean isBetween( float num, float a, float b){
  if(num >=a && num <=b)  return true;
  else                    return false;
}

void update () {
  display();
  for ( int i=0; i < eigenfreqz.length; i++){
    deviation[i] = eigenfreqz[i] - freq; 
  }
  
  for ( int i=1; i < eigenfreqz.length-1; i++){
    if (deviation[i-1] <0 && deviation[i] >=0 ){
      myInterval[0] = eigenfreqz[i-1];
      myInterval[1] = eigenfreqz[i];
      band = myInterval[1] - myInterval[0]; 
      mode = i;
    }
  } 
  float myDev[] = new float[2];
  
  if (isBetween(freq, myInterval[0], myInterval[1])){
     myDev[0] = freq - myInterval[0];
     myDev[1] = freq - myInterval[1];
     
     if(abs(myDev[0]) < abs(myDev[1]) && myDev[0]<2*band/5) {
        mode = mode-1;
        float res = 1/(abs(myDev[0])+ 0.1);
        chladni(mode, field[mode], res*scaleForce[mode], res/30);
      }
      else if(abs(myDev[0]) > abs(myDev[1]) && myDev[1]<2*band/5) {
        float res = 1/(abs(myDev[1])+ 0.1);
        chladni(mode, field[mode], res*scaleForce[mode], res/30);
      }
      else {scrumble(myDev[0] * 0.1, myDev[1]*0.1,2);}
    
  }
  /*
  switch(freq){
  case 100:
  nAttr = attractors.size();
  if(nAttr>0){
    
    for (int i =0; i < nAttr; i++){
    attractors.remove(0);}
  }    
  for (int i = 0; i < modes[0].length/2; i++){
  attractors.add(new Attractor(new Vec2D( modes[0][2*i], modes[0][2*i+1]),w/3, -0.3));
  }
  for (int i = 0; i < modes[0].length/2; i++){
  attractors.add(new Attractor(new Vec2D( modes[0][2*i], modes[0][2*i+1]),w/2, 0.1));
  } 
 
  break;
  
  case 110:
  scrumble();
  break;
  
  case 120:
  chladni(1,120); //<>// //<>//
  break;
  
  case 130:
  scrumble();
  break;
 
  case 140:
  chladni(2,90); //<>// //<>//
  break;
  
  case 150:
  scrumble();
  break;
  
  case 160:
  chladni(3,110); //<>// //<>//
  break;
  
  case 170:
  scrumble();
  break;
  
  case 180:
  chladni(4,90);  //<>// //<>//
  break;
  
  case 190:
  scrumble();
  break;
  
  case 200:
  chladni(5,70); //<>// //<>//
  break;
  
  case 210:
  scrumble();
  break;
  
  case 220:
  chladni(6,55);
  break;
  }
  */
}


void display(){
  background (0,0,0,150); 
  physics.update ();
  for (Attractor a: attractors){
  if (a.force<=0){
    //a.display(color(155,155,0,200), field[mode]);
  }
  if (a.force>0){
    //a.display(color(255,155,100,200), 50);
    }
  }  
  for (Particle p: particles) {
    p.infiniteConsume();
    p.display();
    Vec2D vel = p.getVelocity();
    if(vel.magnitude() <= 1){
      p.addVelocity(vel.jitter(1,1));
    }
  } //<>// //<>//
}


void chladni(int mode, float field, float repForce, float attrForce){
  physics.setDrag(0.6);
  nAttr = attractors.size();
  if(nAttr>0){
    for (int i =0; i < nAttr; i++){
      attractors.get(0).destroy();
      attractors.remove(0);}
  }  
  for (int i = 0; i < modes[mode].length/2 ; i++){
  attractors.add(new Attractor(new Vec2D( modes[mode][2*i], modes[mode][2*i+1]),field, -repForce));
  }
  for (int i = 0; i < modes[mode].length/2; i++){
  attractors.add(new Attractor(new Vec2D( modes[mode][2*i], modes[mode][2*i+1]),w/5, attrForce));
  }
}


void scrumble(float jitter, float force, float scaleVel) {
  physics.setDrag(0.05);
  nAttr = attractors.size();
  if(nAttr>0){
  attractors.get(0).destroy();
  for (int i =0; i < nAttr; i++)
  {attractors.remove(0);}}
    
  for (Particle p: particles) {
    Vec2D vel = p.getVelocity();
    if(vel.magnitude() <= 0.8){
      p.addVelocity(vel.jitter(random(-jitter,jitter),random(-jitter,jitter)));
    }
    if(vel.magnitude() <0.1){
      p.addForce(new Vec2D(random(-force,force), random(-force,force)));
    }
    p.scaleVelocity(random(0.01,1.5));
  }
}


void die(){
  for(Particle p: particles) { p.consume(); p.display();}
  for (int i = particles.size() -1; i>=0; i--){
    physics.removeParticle(particles.get(i));
    particles.remove(i);
  }
  physics.update();
  if(nAttr>0){
    for (int i =0; i < nAttr; i++){
      attractors.get(0).destroy();
      attractors.remove(0);}
      nAttr = attractors.size();
  }
}


void create(){
  for (int i = 0; i < nParticles; i++) {
    particles.add(new Particle(startPos.get(i)));
  } 
  scrumble(4,10,10);
  initMusic();
}

void send(){
  Object [] args = {freq};
  OSCsendMessage("/Control/setFreq", args);
  }
  
void initMusic(){
  Object [] args = {1, freq};
  OSCsendMessage("/Background/Plate", args);
  }
void nextFreq(int delta){
  freq += delta;
  if(freq <40) freq = 4000;
  if(freq >4000) freq =40;
}
}
