import java.util.Arrays;
import ddf.minim.UGen;

import miPhysics.*;

int dimX = 25;
int dimY = 25;

float m = 1.0;
float k = 0.2;
float z = 0.0001;
float dist = 25;
float z_tension = 25;
float fric = 0.00001;
float grav = 0.;

int listeningPoint = 15;
int excitationPoint = 10;

int maxListeningPt;

public class PhyUGen extends UGen
{
  
  private String listeningPoint;

  private float oneOverSampleRate;
  public int center_x;
  public int center_y;
  public phyGenome genome;

  PhysicalModel mdl;

  // strat with ony one constructor for the function.
  public PhyUGen(int sampleRate, phyGenome genome, double offsX, double offsY)
  {
    super();
    // TODO use findCenter
    this.center_x = (int)offsX;
    this.center_y = (int)offsY;
    this.genome = genome;
    
    this.mdl = new PhysicalModel(sampleRate, displayRate);
    mdl.setGravity(0.000);
    mdl.setFriction(fric);

    generateMesh2(mdl, offsX, offsY, genome, "osc", "spring");

    listeningPoint = "mass_5";

    this.mdl.init();
  }

  /**
   * This routine will be called any time the sample rate changes.
   */
  protected void sampleRateChanged()
  {
    oneOverSampleRate = 1 / sampleRate();
    this.mdl.setSimRate((int)sampleRate());
  }

  @Override
  protected void uGenerate(float[] channels)
  {
    float sample;
    synchronized(lock) {
      this.mdl.computeStep();
  
      // calculate the sample value
      if(this.mdl.matExists(listeningPoint)) {
        sample =(float)(this.mdl.getMatPosition(listeningPoint).z * 0.01);
      } else {
        sample = 0;
      }
      Arrays.fill(channels, sample);
    }
  }
}
