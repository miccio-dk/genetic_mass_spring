
import ddf.minim.*;
import ddf.minim.ugens.*;
import peasy.*;

int displayRate = 60;

int mouseDragged = 0;

int gridSpacing = 2;
float spacing = 15;

int xOffset= 50;
int yOffset= 50;

private Object lock = new Object();


PeasyCam cam;

float percsize = 200;

Minim minim;

int NUM_SPECIMEN = 8;
phyGenome[] genome = new phyGenome[NUM_SPECIMEN];
PhyUGen[] simUGen = new PhyUGen[NUM_SPECIMEN];
Gain[] gain = new Gain[NUM_SPECIMEN];

Summer sum;
AudioOutput out;

float speed = 0;
float pos = 100;

String lastExctNode;
String lastExctModel;


///////////////////////////////////////

void setup()
{
  //size(1000, 700, P3D);
  fullScreen(P3D,2);
  cam = new PeasyCam(this, 100);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(2500);
  
  minim = new Minim(this);
  
  // use the getLineOut method of the Minim object to get an AudioOutput object
  out = minim.getLineOut();
  
  sum = new Summer();
  for(int i=0; i<NUM_SPECIMEN; i++) {
    // start the Gain at 0 dB, which means no change in amplitude
    gain[i] = new Gain(0);
    // create a physicalModel UGEN
    genome[i] = new phyGenome();
    genome[i].randomize();
    simUGen[i] = new PhyUGen(44100, genome[i], 0, 100*i);
    // patch the Oscil to the output
    simUGen[i].patch(gain[i]).patch(sum);
  }
  sum.patch(out);
  
  //simUGen.mdl.triggerForceImpulse("mass"+(excitationPoint), 0, 1, 0);
  cam.setDistance(500);  // distance from looked-at point

}

void draw()
{
  camera(width/2.0, height/2.0, (height/2.0) / tan(PI*30.0 / 180.0), width/2, height/2.0, 0, 0, 1, 0);

  //mdl.draw_physics();

  background(0);

  pushMatrix();
  translate(xOffset,yOffset, 0.);
  for(int i=0; i<NUM_SPECIMEN; i++) {
    renderLinks(simUGen[i].mdl);
  }
  popMatrix();

  fill(255);
  textSize(13); 

  text("Friction: " + fric, 100, 100, 50);
  text("Zoom: " + zZoom, 100, 120, 50);
  text("Last Exct: " + lastExctModel + "." + lastExctNode, 100, 140, 50);

  
  if (mouseDragged == 1){
    println(mouseX, mouseY);
    if(mouseButton == LEFT)
      engrave(mouseX, mouseY);
  }
}


void engrave(float mX, float mY){
  String matName = "mass_" + int(mX / (width/30));
  int index = int((mY) / (height / (NUM_SPECIMEN-1)));
  println("exciting " + index + "." + matName);
  if(simUGen[index].mdl.matExists(matName)) {
    lastExctModel = "" + index;
    lastExctNode = matName;
    simUGen[index].mdl.triggerForceImpulse(matName, 0. , 0., 15.);
  }
}


void mouseDragged() {
  mouseDragged = 1;
  
}

void mouseReleased() {
  mouseDragged = 0;
}



void keyPressed() {
  if (key == ' ') {
    for(int i=0; i<NUM_SPECIMEN; i++) {
      simUGen[i].mdl.setGravity(-0.001);
    }
  }
  if(keyCode == UP) {
    fric += 0.00005;
    synchronized(lock) {
      for(int i=0; i<NUM_SPECIMEN; i++) {
        simUGen[i].mdl.setFriction(fric);
      }
    }
    println(fric);
  }
  else if (keyCode == DOWN){
    fric -= 0.00005;
    fric = max(fric, 0);
    for(int i=0; i<NUM_SPECIMEN; i++) {
      simUGen[i].mdl.setFriction(fric);
    }
    println(fric);
  }
  else if (keyCode == LEFT){
    zZoom += 0.1;
  }
  else if (keyCode == RIGHT){
    zZoom -= 0.1;
  }
}

void keyReleased() {
  if (key == ' ') {
    for(int i=0; i<NUM_SPECIMEN; i++) {
      simUGen[i].mdl.setGravity(0.000);
    }
  }
}
