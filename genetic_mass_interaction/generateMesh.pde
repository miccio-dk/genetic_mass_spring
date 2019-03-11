
void generateMesh2(PhysicalModel mdl, double offsX, double offsY, phyGenome genome, String mName, String lName) {
  // OLD ARGS: int dimX, int dimY, String mName, String lName, double masValue, double dist, double K_osc, double Z_osc, double K, double Z
  // add the masses to the model: name, mass, initial pos, init speed
  String masName;
  String solName;
  Vect3D X0, V0;

  // add masses
  for (phyGene gene : genome.genes) {
    // println("generating mass: " + gene.name);
    X0 = new Vect3D(gene.posX+offsX, gene.posY+offsY, 0.0);
    V0 = new Vect3D(0., 0., 0.);
    mdl.addOsc1D(gene.name, gene.masValue, gene.K_osc, gene.Z_osc, X0, V0);
  }

  // add springs
  for (phyGene gene : genome.genes) {
    for (String node2 : gene.conn) {
      if(node2 != null) {
        // println("generating spring: " + gene.name + " " + node2);
        mdl.addSpringDamper1D(gene.name, 0, gene.K, gene.Z, gene.name, node2);
      }
    }
  }
}




float zZoom = 1;




void drawLine(Vect3D pos1, Vect3D pos2){
line((float)pos1.x, (float)pos1.y, zZoom *(float)pos1.z, (float)pos2.x, (float)pos2.y, zZoom * (float)pos2.z);
}

void renderLinks(PhysicalModel mdl, int r, int g, int b){
  stroke(255, 255, 0);
  strokeWeight(2);
  for( int i = 0; i < (mdl.getNumberOfLinks()); i++){
    switch (mdl.getLinkTypeAt(i)){
      case Spring3D:
        stroke(0, 255, 0);
        drawLine(mdl.getLinkPos1At(i), mdl.getLinkPos2At(i));
        break;
      case SpringDamper1D:
        stroke(r, g, b);
        drawLine(mdl.getLinkPos1At(i), mdl.getLinkPos2At(i));
        break;
      case Damper3D:
        stroke(125, 125, 125);
        drawLine(mdl.getLinkPos1At(i), mdl.getLinkPos2At(i));
        break; 
      case SpringDamper3D:
        stroke(100+10*zZoom*(float)mdl.getLinkPos1At(i).z,0, 255);
        drawLine(mdl.getLinkPos1At(i), mdl.getLinkPos2At(i));
        break;
      case Rope3D:
        stroke(210, 235, 110);
        drawLine(mdl.getLinkPos1At(i), mdl.getLinkPos2At(i));
        break;
      case Contact3D:
        break; 
      case PlaneContact3D:
        break;
      case UNDEFINED:
        break;
    }
  }
}
