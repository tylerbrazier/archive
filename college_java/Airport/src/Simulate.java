import java.util.Scanner;

public class Simulate 
{

    public static void main(String[] args)
    {
        Clock masterClock;
        ControlTower tower;
        Runway[] runways;
        ThinAir generator;
        Scanner keyReader =new Scanner(System.in);
        int inputAveDepArivRate;
        int inputAveDepArivTime;
        int numOfRunways;
        int simulationTime;

        System.out.println("~~~~~~CONTROL TOWER SIMULATION~~~~~~");

        do
        {
            System.out.println("First, how often (on average) will a plane request to arrive/depart?");
            inputAveDepArivRate =keyReader.nextInt();
        }while(inputAveDepArivRate <=0);

        do
        {
            System.out.println("Second, what is the average amount of time for an airplane to arrive/depart?");
            inputAveDepArivTime =keyReader.nextInt();
        }while(inputAveDepArivTime <=0);

        do
        {
            System.out.println("Next, how many runways will the control tower regulate?");
            numOfRunways =keyReader.nextInt();
        }while(numOfRunways <=0);

        do
        {
            System.out.println("Finally, how long should this simulator run for (how many ticks)?");
            simulationTime =keyReader.nextInt();
        }while(simulationTime <=0);
        //finished asking user for input

        masterClock =new Clock();
        runways =new Runway[numOfRunways];
        for(int i=0; i <numOfRunways; ++i)
        {
            runways[i] =new Runway("Runway" + i);
            masterClock.addListener(runways[i]);
        }

        generator =new ThinAir(inputAveDepArivRate, inputAveDepArivTime);
        masterClock.addListener(generator);

        tower =new ControlTower(runways, generator);
        masterClock.addListener(tower);


        //the last thing you're gonna do is:
        masterClock.run(simulationTime);
        tower.report();
        System.out.println("~~~End of Simulation~~~");
    }





}
