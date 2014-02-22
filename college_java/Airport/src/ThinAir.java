import java.util.Random;

public class ThinAir implements ClockListener
{//airplanes appear out of thin air

    //data
    private Random random;
    private int productionRateCounter;
    private int inputAverageTime;
    private Airplane currentPlane;
    private int planeCounter;

    public ThinAir(int oldRate, int oldTime)
    {
        random =new Random();
        productionRateCounter =newAverageOf(oldRate);
        inputAverageTime =oldTime;
        currentPlane =null;
        planeCounter =0;
    }
    public ThinAir()
    {
        this(10, 10);
    }

    //methods
    public Airplane retrievePlane()
    {//remember, this method will return null if generator 
        //doesn't have a plane (checking to see if generator 
        //has a plane is a precondition)
        Airplane tempReference =currentPlane;
        currentPlane =null;
        return tempReference;
    }

    public boolean hasPlane()
    {
        if(currentPlane ==null) return false;

        else return true;
    }

    private int newAverageOf(int number)
    {
        int half =number/2;
        int value =(1+ (random.nextInt(number +half) +(random.nextInt(number -half))));

        //limit return value
        if(value > (number +half)) return number +half;
        if(value < (number -half)) return number -half;
        return value;
    }

    public String preEvent(int useless)
    {
        return "";
    }
    public String event(int currentTick)
    {//generates a plane if not already holding one at an average rate based on user input

        if(!hasPlane() && currentTick ==productionRateCounter)
        {
            productionRateCounter++;
            int newAverageTime =newAverageOf(inputAverageTime);

            boolean arrivingOrDeparting; //50/50 chance of generating an arriving or departing plane
            if(random.nextInt(2) ==1) arrivingOrDeparting =true;
            else arrivingOrDeparting =false;

            currentPlane =new Airplane("Airplane" +planeCounter, newAverageTime, arrivingOrDeparting);
            planeCounter++;

            if(arrivingOrDeparting) return currentPlane.toString()+ " requests landing on a runway.";

            else return currentPlane.toString()+ " requests to depart on a runway.";

        }
        else if(this.hasPlane() && currentTick ==productionRateCounter)
        {
            return "Plane was not generated as scheduled! " +
            "Control tower must accept previously generated plane first.";
        }
        return ""; 
    }

    public Airplane refToCurrentPlane()
    {//returns null if currentplane is null
        return currentPlane;
    }
    //end of methods

}
