// Class Particle extends the class "VerletParticle2D"

class Particle extends VerletParticle2D {
  // Members
  float r;
  int life = 255;
  Vec2D location;
  boolean token = true; // to deal with infiniteConsume
  
  // Constructors
  Particle (Vec2D loc) {
    super(loc);
    this.location = new Vec2D(loc.x, loc.y);
    r = 2;
    physics.addParticle(this);
    physics.addBehavior(new AttractionBehavior2D(this, r, -10)); //(p, distance, strength)
    // the strength of the latter can control the attraction or repulsion btwn particle system 
}

  Particle (Vec2D loc, float attrForce) {
    super(loc);
    this.location = new Vec2D(loc.x, loc.y);
    r = 2;
    physics.addParticle(this);
    physics.addBehavior(new AttractionBehavior2D(this, r, attrForce)); //(p, distance, strength)
    // the strength of the latter can control the attraction or repulsion btwn particle system 
}

  // see particle - standard
  void display () {
    fill (color(255,255,255,life));
    noStroke();
    ellipse (x, y, r, r);
  }
  // see particle - give it a color
  void displayColor (color c) {
    color f = color(red(c), green(c), blue(c), life);
    fill (f);
    noStroke();
    ellipse (x, y, r, r);
  }
  // takes away one life point
  void consume(){
    if (isDead()) physics.removeParticle(this);
    else life -=1 ;
  }
  // takes away 30 life points
  void fastConsume(){
    if (isDead()) physics.removeParticle(this);
    else life -=30 ;
  }
  // variates life in a cycle with randomicity
  void infiniteConsume(){
    life = (int) (life + random(5 )) %225 ;
  }
  // check if particle is dead
  boolean isDead(){
    if(life ==  0) { return true;}
    else return false;
  }
}
