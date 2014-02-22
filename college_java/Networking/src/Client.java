import java.io.*;
import java.net.*;

public class Client {

    private static final int PORT = 9999;
    private static final int TIMEOUT = 0; //zero indicates infinite timeout

    private Socket socket;
    private ObjectInputStream input;
    private ObjectOutputStream output;
    private MessageListener listener;

    public void setListener(MessageListener ml){
        this.listener = ml;
    }
    private void message(String text){
        if(listener != null) listener.message(text);
    }

    //returns true if success
    public boolean connect(String host){
        try{
            message("Attempting to connect...");
            socket = new Socket(InetAddress.getByName(host), PORT);
            socket.setSoTimeout(TIMEOUT);
            message("Connection recieved from: " 
                    + socket.getInetAddress().getHostName());
            message("Creating input and output streams.");
            
            output = new ObjectOutputStream(socket.getOutputStream());
            output.flush();
            input = new ObjectInputStream(socket.getInputStream());
            message("Got streams.");
            
            return true;
        }
        catch(SocketTimeoutException ste){
            message("Connection timed out.");
            return false;
        }
        catch(Exception e){
            message(e.getMessage());
            return false;
        }
    }

    public void sendFile(File file){
        Boolean ok;
        try{
            message("Sending file name.");
            output.writeObject(file.getName());
            output.flush();

            ok = (Boolean) input.readObject();

            if(ok){
                message("Sending file size.");
                output.writeObject(file.length());
                output.flush();
            }

            ok = (Boolean) input.readObject();

            if(ok){
                message("Loading file data...");
                byte[] bytes = new byte[(int)file.length()];
                FileInputStream fis = new FileInputStream(file);
                BufferedInputStream bis = new BufferedInputStream(fis);
                bis.read(bytes, 0, bytes.length);
                message("Sending file data...");
                for(int i=0; i<bytes.length; i++){
                    output.writeObject(new Byte(bytes[i]));
                    output.flush();
                }
            }

            ok = (Boolean) input.readObject();

            if(ok) message("Success!");
            else message("Something went wrong...");

        }
        catch(Exception e){
            message(e.getMessage());
        }
    }

    public void closeConnection(){
        try{
            if(input != null) input.close();
            if(output != null) output.close();
            if(socket != null) socket.close();
        }
        catch(Exception e){
            message("Error closing socket or stream.");
        }
    }

    public static void main(String[] args){
        Client client = new Client();
        new ClientGUI(client);
    }
}
