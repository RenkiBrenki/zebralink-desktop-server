package si.elektroet;

import java.awt.AWTException;
import java.awt.Robot;
import java.awt.event.KeyEvent;
import java.util.Objects;

public class TypeUtil {
    private final Robot robot;
    private int delay = 10;

    public TypeUtil() throws AWTException {
        this.robot = new Robot();
        robot.setAutoDelay(delay);
    }

    public void setDelay(int delay) {
        this.delay = delay;
    }

    public int getDelay() {
        return delay;
    }

    public void typeString(String string, int count) {
        Objects.requireNonNull(string);
        Objects.requireNonNull(count);

        for (int i = 0; i < count; i++) {
            typeString(string);
        }
    }

    public void typeString(String string) {
        for (char c : string.toCharArray()) {
            pressAndRelease(c);
        }
        pressAndRelease(KeyEvent.VK_TAB);
        pressAndRelease(KeyEvent.VK_ENTER);
        robot.delay(delay);
    }

    private void pressAndRelease(char key) {
        robot.keyPress(key);
        robot.keyRelease(key);
        robot.delay(10);
    }

    /*
     * KeyEvent constants
     */
    private void pressAndRelease(int key) {
        robot.keyPress(key);
        robot.keyRelease(key);
        robot.delay(10);
    }
}
