// One of the complex classes representing a vibrating element - five strings instrument simulation //<>//

import processing.opengl.*;
import toxi.physics2d.*;
import toxi.geom.*;
import java.util.List;

class VibString {
  // members
  ArrayList<Strings> strings;
  ArrayList <Particle> particleAnimation;
  int STRING_RES=50;  // number of nodes for string
  int colVar = 28;
  
  // contructor - its complexity is in the function initPhysics()
  VibString() {
    this.strings = new ArrayList<Strings>();
    this.particleAnimation =  new ArrayList<Particle>();
    initPhysics();
  }
  
  // called in the constructor and in create()
  // builds our string instrument correctly setting initial and ending positions of each string
  void initPhysics() {
    // remove Behaviors
    int nBehaviors = physics.behaviors.size();
    for (int i =nBehaviors-1; i>=0; i--) {
      physics.behaviors.remove(physics.behaviors.get(i));
    }
    physics.setDrag(0.1);
    // compute starting and ending points for strings
    float distStrStart = (height/3)/3;
    float distStrEnd = (height/1.5)/3;
    int count = -2;
    for (int i =0; i < 5; i++) {
      if ( i < 3) {
        Vec2D startingPoint = new Vec2D(abs(count) * distStrStart, height);
        Vec2D endingPoint =new Vec2D(width, abs(count) * distStrEnd);
        strings.add(new Strings(STRING_RES, startingPoint, endingPoint)) ;
      } 
      else {
        Vec2D startingPoint = new Vec2D(0, height - count * distStrStart);
        Vec2D endingPoint =new Vec2D(width - count*distStrEnd*width/height, 0);
        strings.add(new Strings(STRING_RES, startingPoint, endingPoint)) ;
      }
      count += 1;
    }
  }
  
  // update
  void update() {
    // wooden dynamic background
    background(94, 75, 52);
    stroke(colVar%52, colVar%42, colVar%29, (colVar+100)%256);
    for (int i = 0; i< width/5+height; i++) {
      line(i*5-height, 0, i*2-height, height);
    }
    physics.update();
    // draw all strings
    float wdt = 3;
    for (int i =strings.size()-1; i >= 0; i--){
      Strings s = strings.get(i);
      s.display(wdt);
      // if mousePressed and there is a selected particle, send message, just once per plucking
      if(mousePressed){ 
          if (s.selectedParticle!=null) {
            s.selectedParticle.set(mouseX,mouseY);
            send(abs(i-4));
        }
      }
      wdt -= 0.3; 
    }
    react();
    colVar +=1;  // update color variable
  }
  
  // react to the plucking with particles generation
  void react() {
    for ( int stringInd = 0; stringInd< strings.size(); stringInd++){
       Strings s = strings.get(stringInd);
       float theta = 0 ;
       for ( int i = 5; i < s.nodes.size()-5; i++){
         Particle p1 = s.nodes.get(i);
         if (p1.getVelocity().magnitude() > 70 ){                               // threshold for particles generation
           Particle pAnimation = new Particle(p1.getPreviousPosition(),-0.05);
           particleAnimation.add(pAnimation);
           pAnimation.addForce(p1.getVelocity().getRotated(theta).scale(0.07));
         }
       theta = theta + 15;
       }
     }
   // consume Particles
     for (int i = particleAnimation.size()-1; i>=0; i-- ){
       Particle pAnimation = particleAnimation.get(i);
       pAnimation.displayColor(color(205, 164, 52));
       if(pAnimation.isDead()) particleAnimation.remove(i);
         pAnimation.fastConsume();
       }
     }
  // remove most of the elements in order to save memory
  void die() {
    int nBehaviors = physics.behaviors.size();
    for (int i =nBehaviors-1; i>=0; i--) {
      physics.behaviors.remove(physics.behaviors.get(i));
    }
    for (int i = strings.size()-1; i>=0; i--) {
      Strings s = strings.get(i);
      for ( int j = s.springs.size()-1; j <= 0; j--) {
        physics.removeSpring(s.springs.get(j));
        physics.removeParticle(s.nodes.get(j));
        s.springs.remove(j);
        s.nodes.remove(j);
      }
      strings.remove(s);
    }
  }
  // recreate most of the elements
  void create() {
    int nBehaviors = physics.behaviors.size();
    for (int i =nBehaviors-1; i>=0; i--) {
      physics.behaviors.remove(physics.behaviors.get(i));
    }
    physics.setDrag(0.01);
    physics.addBehavior(new GravityBehavior2D(new Vec2D (0,0.1)));
    float distStrStart = (height/3)/3;
    float distStrEnd = (height/1.5)/3;
    int count = -2;
    for (int i =0; i < 5; i++) {
      if ( i < 3) {
        Vec2D startingPoint = new Vec2D(abs(count) * distStrStart, height);
        Vec2D endingPoint =new Vec2D(width, abs(count) * distStrEnd);
        strings.add(new Strings(STRING_RES, startingPoint, endingPoint)) ;
      } 
      else {
        Vec2D startingPoint = new Vec2D(0, height - count * distStrStart);
        Vec2D endingPoint =new Vec2D(width - count*distStrEnd*width/height, 0);
        strings.add(new Strings(STRING_RES, startingPoint, endingPoint)) ;
      }
      count += 1;
    }
    initMusic();
  }
  
  // send OSC control message
  void send(int pluckedString){
  Object [] args = {pluckedString*5};
  OSCsendMessage("/Control/StringPlucked", args);
  }
  
  // send OSC init background message
  void initMusic(){
  Object [] args = {};
  OSCsendMessage("/Background/Strings", args);
  }
}
