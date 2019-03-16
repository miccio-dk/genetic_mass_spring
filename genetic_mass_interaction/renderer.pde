PApplet app;
float zZoom = 1;


void drawLine(Vect3D pos1, Vect3D pos2) {
  line((float)pos1.x, 
    (float)pos1.y, 
    zZoom *(float)pos1.z, 
    (float)pos2.x, 
    (float)pos2.y, 
    zZoom * (float)pos2.z);
}

void renderLinks(PhysicalModel mdl, int r, int g, int b) {
  for ( int i = 0; i < (mdl.getNumberOfLinks()); i++) {
    switch (mdl.getLinkTypeAt(i)) {
    case SpringDamper1D:
      strokeWeight(2);
      stroke(r, g, b);
      // strokeWeight(mdl.getLinkDampingAt(i));
      drawLine(mdl.getLinkPos1At(i), mdl.getLinkPos2At(i));
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
