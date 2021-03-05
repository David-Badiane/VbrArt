class SkyObject{
  ArrayList<FFTline> elements;
  int RES = 2;
  float[] vals = new float[nBin];
  Vec2D center;
  float reactivity;


  SkyObject(Vec2D center, float rad, float[] spec){
    this.vals = spec;
    this.center = center;
    this.reactivity = random(10);
    elements = new ArrayList<FFTline>();
    for (int i =0; i<RES; i++){
      elements.add(new FFTline (vals, center));
    }
  }
  
  void update( float [] spec){
    arrayCopy(spec, vals);
    for ( FFTline e: elements){
      for ( int i = 0; i < nBin; i++) {} 
      e.fftVals = vals;
      e.displayPolygon();
    }
  }
  
}
