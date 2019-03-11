
// simple "gene", composed of a mass node and spring-damper-connections to other nodes
public class phyGene
{
  public String name;
  public int posX, posY;
  public double masValue;
  public double K_osc, Z_osc;
  public double K, Z;
  public String[] conn;  
  
  public phyGene(String name, int conns)
  {
    this.name = name;
    this.conn = new String[conns];
  }
  
  public void mutate(float mutationAmount)
  {
    posX = (int)randomizeValue(posX, mutationAmount);
    posY = (int)randomizeValue(posY, mutationAmount);

    masValue = randomizeValue(masValue, mutationAmount);
    K_osc = randomizeValue(K_osc, mutationAmount);
    Z_osc = randomizeValue(Z_osc, mutationAmount);
    K = randomizeValue(K, mutationAmount);
    Z = randomizeValue(Z, mutationAmount);
    // TODO mutate connections!
  }
  
  public void randomize()
  {
    Random rand = new Random();
    posX = rand.nextInt(300) - 150;
    posY = rand.nextInt(100) - 50;
    masValue = (1 + rand.nextFloat() * 10);
    K_osc = 0.006 + rand.nextFloat() * 0.0006;
    Z_osc = 0.00001 + rand.nextFloat() * 0.000001;
    K = 0.09 + rand.nextFloat() * 0.009;
    Z = 0.0001 + rand.nextFloat() * 0.00001;
    // TODO randomize connections!
  }
  
  // mutate a gene: randomly add or substract up to mutationAmount percent to each param
  private double randomizeValue(double value, float mutationAmount)
  {
    Random rand = new Random();
    double min = -mutationAmount;
    double max = mutationAmount;
    double v = min + rand.nextDouble() * (max - min);
    println("Mutation amount: " + v);
    return value + (value*v);
  }
  
  
}
