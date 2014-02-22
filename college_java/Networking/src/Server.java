import java.io.*;
import java.net.*;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class Server {

    private static final int PORT = 9999;
    private static final int TIMEOUT = 0; //zero indicates infinite timeout
    private static final String FILE_SEPARATOR = System.getProperty("file.separator");
    private static final String DEST_DIR = System.getProperty("user.home");

    private ServerSocket serverSocket;
    private ExecutorService executor;

    private Server(){
        executor = Executors.newCachedThreadPool();
        Socket socket;
        try{
            serverSocket = new ServerSocket(PORT);
            serverSocket.setSoTimeout(TIMEOUT); 
            while(true){
                System.out.println("Waiting for connection...");
                socket = serverSocket.accept();
                System.out.println("Connection recieved from: " 
                        + socket.getInetAddress().getHostName());
                executor.execute(new ServerConnection(socket));
            }
        }
        catch(SocketTimeoutException ste){
            System.err.println("Connection timed out.");
            if(serverSocket != null){
                try{ serverSocket.close(); }
                catch(Exception e){ e.printStackTrace(); }
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }
    
    private synchronized void writeFile(String fileName, byte[] fileData){
        //check if file already exists
        //if it does, append a number to the beginning of the filename
        String path = DEST_DIR + FILE_SEPARATOR + fileName;
        File checkFile = new File(path);
        int appendCounter = 0;
        while (checkFile.exists()) {
            path = DEST_DIR + FILE_SEPARATOR + appendCounter++ + fileName;
            checkFile = new File(path);
        }

        try {
            FileOutputStream fos = new FileOutputStream(path);
            BufferedOutputStream bos = new BufferedOutputStream(fos);
            bos.write(fileData);
            bos.flush();
            bos.close();
            
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private class ServerConnection implements Runnable{
        
        private Socket socket;
        private String hostname;
        private ObjectOutputStream output;
        private ObjectInputStream input;
        private boolean error;
        
        public ServerConnection(Socket s){
            socket = s;
            error = false;
            hostname = socket.getInetAddress().getHostName();
        }
        
        @Override
        public void run(){
            String fileName = null;
            Long fileSize = null;
            byte[] fileData = null;
            getStreams();
            if(!error) fileName = getFileName();
            if(!error) fileSize = getFileSize();
            if(!error) fileData = getFileData(fileSize.intValue());
            if(!error) writeFile(fileName, fileData); 
            if(!error) closeConnection();
        }
        
        private void getStreams(){
            try{
                output = new ObjectOutputStream(socket.getOutputStream());
                output.flush();
                input = new ObjectInputStream(socket.getInputStream());
                System.out.println("Got input and output streams with "+hostname);
            }
            catch(Exception e){
                err("Error creating input or output stream with "+hostname);
            }
        }
        
        private String getFileName(){
            String fileName = null;
            try{
                fileName = (String) input.readObject();
                System.out.println("Got filename from "+hostname);
                respond(true);
            }
            catch(Exception e){
                err("Did not recieve file name from "+hostname);
            }
            return fileName;
        }
        
        private Long getFileSize(){
            Long fileSize = null;
            try{
                 fileSize = (Long) input.readObject();
                 System.out.println("Got file size from "+hostname);
                 respond(true);
            }
            catch(Exception e){
                err(e.getMessage());
            }
            return fileSize;
        }
        
        private byte[] getFileData(int bufferSize){
            byte[] bytes = null;
            try{
                bytes = new byte[bufferSize];
                for(int i=0; i<bufferSize; i++){
                    bytes[i] = (Byte) input.readObject();
                }
                System.out.println("Got file data from "+hostname);
                respond(true);
            }
            catch(Exception e){
                err(e.getMessage());
            }
            return bytes;
        }
        
        private void closeConnection(){
            try{
                if(input != null){
                    input.close();
                    System.out.println("Closed input stream with "+hostname);
                }
                if(output != null){
                    output.close();
                    System.out.println("Closed output stream with "+hostname);
                }
                if(socket != null){
                    socket.close();
                    System.out.println("Closed socket with "+hostname);
                }
            }
            catch(Exception e){
                System.err.println("Error closing socket or stream with "+hostname);
            }
        }
        
        private void respond(boolean ok){
            try{
                output.writeObject(new Boolean(ok));
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }
        
        private void err(String message){
            error = true;
            if(output != null) respond(false);
            System.err.println("Error occurred with "+hostname);
            System.err.println(message);
            closeConnection();
        }
        
        
    }//end of inner class

    public static void main(String[] args) {
        new Server();
    }
}
