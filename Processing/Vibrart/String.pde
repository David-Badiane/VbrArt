// String like objects made by verletSprings2D 

class Strings {
  // Members
  ArrayList <Particle> nodes;
  ArrayList <VerletSpring2D> springs;
  int Nnodes;
  Vec2D start;
  Vec2D end;
  float theta;
  float len;
  boolean doOnce = false;
  Particle selectedParticle;
  float SNAP_DIST = 30 * 30; // squared snap distance for mouse selection
  
  // constructor - very complicated in order to realize whatever geometry of the line
  Strings(int STRING_RES, Vec2D init, Vec2D finish){
    // set ArrayLists
    this.nodes =  new ArrayList<Particle>();
    this.springs = new ArrayList<VerletSpring2D>();
    // set other members
    this.start = new Vec2D(init.x, init.y);
    this.end = new Vec2D(finish.x, finish.y);
    this.Nnodes = STRING_RES;
    this.len = start.sub(finish).magnitude();
    this.theta = atan((finish.y - init.y)/(finish.x-init.x));
    // the length of each element
    float delta = len/(STRING_RES -1);
    
    // let's start building the string
    for(int i=0; i<STRING_RES; i++) {
      Vec2D loc = new Vec2D(init.x + i*delta*cos(theta), init.y + i*delta*sin(theta));  // location of particles, polar coords
      Particle p = new Particle(loc);
      nodes.add(p);
      physics.addParticle(p);
      physics.addBehavior(new AttractionBehavior2D(p,delta,-8));
      if (i>0) {
          VerletSpring2D s;
          Particle q = nodes.get(i-1);
          s=new VerletSpring2D(p,q,delta*0.25,1.5);
          physics.addSpring(s);
          springs.add(s);
        }
      }
      nodes.get(0).lock();
      nodes.get(nodes.size()-1).lock(); 
    }
   
  // display the string with given weight
  void display( float strokeWgt){
   for (int i = 1; i< nodes.size(); i++ ){
     stroke(205, 164, 52, 170); 
     Particle p1 = nodes.get(i-1);
      Particle p2 = nodes.get(i);
      strokeWeight(strokeWgt);
      line(p1.x,p1.y, p2.x, p2.y);
      strokeWeight(0.5); 
      
      if(selectedParticle != null && i < nodes.size()-1){
      if(!p2.equals(selectedParticle)){
        p2.unlock();
      }
      }
    }
  }
  
  // pluck the string
  void pluck(Vec2D point){
    for(int i=1; i<nodes.size()-1; i++) {
        Particle p= nodes.get(i);
        // using distanceToSquared() is faster than distanceTo()
        if (point.distanceToSquared(p)<SNAP_DIST) {
          // lock it and store for further reference
          selectedParticle = p;
          p.lock();
          p.set(point);
          // force quit the loop
          break;
       } 
    }
  }
  
  // pluck the string via leap
  boolean pluckLeap(Vec2D point){
    for(int i=1; i<nodes.size()-1; i++) {
        Particle p = nodes.get(i);
        // using distanceToSquared() is faster than distanceTo()
        if (point.distanceToSquared(p)<0.1*SNAP_DIST) {
          // lock it and store for further reference
          selectedParticle = p;
          p.lock();
          p.set(point);
       } 
    }
    if(selectedParticle != null) return true;
    else return false;
  } //<>//
} 
