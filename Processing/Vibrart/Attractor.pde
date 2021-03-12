// class extended from toxiclibs attractors, attracts/repels particles

class Attractor extends VerletParticle2D {
  // Members
  float r;  // radius
  AttractionBehavior2D behavior;
  float force;
  float field;
  
  // Constructors
  Attractor (Vec2D loc) {
    super (loc);
    r = 24;
    //physics.addParticle(this);
    this.behavior = new AttractionBehavior2D(this, 100, -0.9);
    physics.addBehavior(this.behavior);
  }
  
  Attractor (Vec2D loc, float span, float force) {
    super (loc);
    r = 24;
    this.force = force;
    this.field = span;
    //physics.addParticle(this);
    physics.addBehavior(new AttractionBehavior2D(this,span,force));
  }
  // see the attractor - for debug in this case
  void display (color c, float r) {
    fill(c);
    this.r = r;
    ellipse (x, y, r, r);
  }
  // get rid of the given attractor
  void destroy (){
   int nBehaviors = physics.behaviors.size();
   for (int i =0; i< nBehaviors; i++){
     physics.behaviors.remove(physics.behaviors.get(0));
   }
  }

}
