package secret_stash.controller;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.Properties;
import java.util.Set;

import secret_stash.model.StashData;
import secret_stash.view.EditView;
import secret_stash.view.LockedView;
import secret_stash.view.UnlockedView;
import secret_stash.view.ViewFrame;

public class Controller {

    private static final String STASH_PATH_PROP = "stash_at";
    private ViewFrame frame;
    private StashData stashData;
    private String stashFilePath;
    private String unlockPassword;
    private FileHandler fileHandler;
    private Properties props;

    public Controller(ViewFrame frame) {
        this.frame = frame;
        this.fileHandler = new FileHandler();
        try {
            this.props = fileHandler.parseConfig();
        } catch (FileNotFoundException e) {
            // no big deal; file just hasn't been created for the first time
            this.props = new Properties();
        } catch (IOException e) {
            e.printStackTrace(); // TODO maybe show warning?
            this.props = new Properties();
        }
    }


    // may return null if not found
    public String getStashPath() {
        return props.getProperty(STASH_PATH_PROP);
    }


    public boolean createStash(String path) throws Exception {
        return fileHandler.createStash(path);
    }


    public void lock() throws Exception {
        fileHandler.storeStash(stashFilePath, unlockPassword, stashData);
        frame.setView(new LockedView(this));
    }


    public void unlock(String filePath, String password) throws Exception {
        if (filePath.isEmpty())
            throw new Exception("Provide a path to a stash file");
        if (password.isEmpty())
            throw new Exception("No password given");

        try {
            props.setProperty(STASH_PATH_PROP, filePath);
            fileHandler.storeConfig(props);
        } catch (FileNotFoundException e) {
            props.remove(STASH_PATH_PROP);
            throw new Exception("Invalid stash file");
        } catch (IOException e) {
            props.remove(STASH_PATH_PROP);
            e.printStackTrace(); // TODO maybe show warning?
        }

//        try {
//            stashData = fileHandler.parseStash(filePath, password);
//        } catch (Exception e) {
//            throw new Exception("Unable to read stash file");
//        }
        stashData = fileHandler.parseStash(filePath, password);

        this.stashFilePath = filePath;
        this.unlockPassword = password;
        this.frame.setView(new UnlockedView(this));
    }


    public void add() {
        frame.setView(new EditView(this));
    }


    public void edit(String name) {
        String[] data = stashData.getValues(name);
        frame.setView(new EditView(this, name, data[0], data[1]));
    }


    public void update(String name,
                       String username,
                       String password) throws Exception {
        if (name.isEmpty())
            throw new Exception("Provide a name.");
        if (username.isEmpty())
            throw new Exception("Provide a username");
        if (password.isEmpty())
            throw new Exception("Provide a password");

        stashData.update(name, username, password);
        frame.setView(new UnlockedView(this));
    }


    // caller should update view immediately after this call
    public void remove(String name) {
        stashData.remove(name);
    }


    // called by view when it's time to return to menu
    public void cancel() {
        frame.setView(new UnlockedView(this));
    }


    // TODO finish implementing me
    public void help() {
        frame.dialog("No help yet.");
    }


    public Set<String> getNames() {
        return stashData.getNames();
    }
}
