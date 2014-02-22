import java.util.LinkedList;

public class AirplaneQueue
{
    private LinkedList <Airplane> qu =new LinkedList<Airplane>();

    public Airplane removePlane()
    {
        return qu.remove();
    }
    public void addPlane(Airplane airplane)
    {
        qu.add(airplane);
    }

    public int size()
    {
        return qu.size();
    }

    public Airplane planeAt(int index) throws IndexOutOfBoundsException
    {//returns reference to the plane at the index
        return qu.get(index);

    }
}
