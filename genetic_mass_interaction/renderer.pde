PApplet app;
float zZoom = 5;


void drawLine(Vect3D pos1, Vect3D pos2) {
  line((float)pos1.x, 
    (float)pos1.y, 
    zZoom *(float)pos1.z, 
    (float)pos2.x, 
    (float)pos2.y, 
    zZoom * (float)pos2.z);
}

void drawLine2(Vect3D pos1, Vect3D pos2, float dist) {
  line((float)pos1.x, 
    (float)pos1.y+dist, 
    zZoom *(float)pos1.z, 
    (float)pos2.x, 
    (float)pos2.y+dist, 
    zZoom * (float)pos2.z);
}

void renderLinks(PhysicalModel mdl, boolean isSelected, float force, String name) {
  float blend = force / 10.0;
  int colorStifIdle = #44CCFF;
  int colorDampIdle = #38A7D1;
  //                            idle                selected
  int colorStifOrig = !isSelected ? colorStifIdle : lerpColor(colorStifIdle, #FF4444, blend);
  int colorDampOrig = !isSelected ? colorDampIdle : lerpColor(colorDampIdle, #FF4444, blend);
  for (int i = 0; i < (mdl.getNumberOfLinks()); i++) {
    int colorStif = colorStifOrig;
    int colorDamp = colorDampOrig;
    if(isSelected) {
      if(name.equals(mdl.getLinkNameAt(i))) {
        colorStif = #ffeeee;
        colorDamp = #ffeeee;
      } else {
        colorStif = colorStifOrig;
        colorDamp = colorDampOrig;
      }
    }
    switch (mdl.getLinkTypeAt(i)) {
    case SpringDamper1D:
      // show stiffness
      stroke(colorStif);
      float thicknessStif = 0.5 + (float)Math.abs(mdl.getLinkStiffnessAt(i) - 0.99) / 0.95 * 1.5;
      strokeWeight(thicknessStif);
      drawLine(mdl.getLinkPos1At(i), mdl.getLinkPos2At(i));
      
      // show damping
      stroke(colorDamp);
      float thicknessDamp = 0.5 + (float)Math.abs(mdl.getLinkDampingAt(i) - 5e-5) / 1e-4 * 1.5;
      strokeWeight(thicknessDamp);
      drawLine2(mdl.getLinkPos1At(i), mdl.getLinkPos2At(i), thicknessStif/2);
      //println(thicknessDamp + " ");
      break;
    case UNDEFINED:
      break;
    }
  }
}

void renderModelMasses(PhysicalModel mdl) {
  PVector v;
  synchronized(lock) { 
    for ( int i = 0; i < mdl.getNumberOfMats(); i++) {
      v = mdl.getMatPosAt(i).toPVector().mult(100.);
      pushMatrix();
      translate(v.x, v.y, v.z);
      sphere(100);
      popMatrix();
      
    }
  }
}
