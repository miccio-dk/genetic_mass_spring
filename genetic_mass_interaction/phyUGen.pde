import java.util.Arrays;
import ddf.minim.UGen;

import shapes3d.utils.*;
import shapes3d.animation.*;
import shapes3d.*;

import miPhysics.*;

float fric = 0.00001;


int maxListeningPt;

public class PhyUGen extends UGen
{

  private String listeningPoint;

  private float oneOverSampleRate;
  public int center_x;
  public int center_y;
  private phyGenome genome;
  
  private int sample_rate;

  private PhysicalModel mdl;

  // strat with ony one constructor for the function.
  public PhyUGen(int SR, double offsX, double offsY)
  {
    super();
    // TODO use findCenter
    this.center_x = (int)offsX;
    this.center_y = (int)offsY;

    this.sample_rate = SR;

    this.genome = new phyGenome();

    this.mdl = new PhysicalModel(sample_rate, displayRate);
    mdl.setGravity(0.000);
    mdl.setFriction(fric);

    listeningPoint = "mass_5";
  }

  public PhysicalModel getModel() {
    return this.mdl;
  }

  phyGenome getGenome() {
    return this.genome;
  }



  void newPopulation() {
    synchronized(lock) { 

      this.genome.evolve(0.25, 0.02, 0.05);

      generateModel(center_x, center_y, genome);

    }
    generation++;
  }


  void generateModel(double offsX, double offsY, phyGenome genome) {
    // OLD ARGS: int dimX, int dimY, String mName, String lName, double masValue, double dist, double K_osc, double Z_osc, double K, double Z
    // add the masses to the model: name, mass, initial pos, init speed

    Vect3D X0, V0;

    println("Model object : " + this.mdl);

    synchronized(lock) {

      this.mdl =  new PhysicalModel(sample_rate, displayRate);
    mdl.setGravity(0.000);
    mdl.setFriction(fric);
      
      // add masses
      for (phyGene gene : genome.genes) {
        println("generating mass: " + gene.name);
        X0 = new Vect3D(gene.posX+offsX, gene.posY+offsY, 0.0);
        V0 = new Vect3D(0., 0., 0.);
        this.mdl.addOsc1D(gene.name, gene.masValue, gene.K_osc, gene.Z_osc, X0, V0);
      }

      // add springs
      for (phyGene gene : genome.genes) {
        for (String node2 : gene.conn) {
          if (node2 != null) {
            println("generating spring: " + gene.name + " " + node2);
            this.mdl.addSpringDamper1D(gene.name, 0, gene.K, gene.Z, gene.name, node2);
          }
        }
      }

      this.mdl.init();
    }
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
      if (this.mdl.matExists(listeningPoint)) {
        sample =(float)(this.mdl.getMatPosition(listeningPoint).z * 0.001);
      } else {
        sample = 0;
      }
      Arrays.fill(channels, sample);
    }
  }
}
