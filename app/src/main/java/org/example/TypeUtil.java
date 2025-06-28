package org.example;

import java.awt.AWTException;
import java.awt.Robot;
import java.awt.event.KeyEvent;

public class TypeUtil {
    private final Robot robot;
    private int delay = 10;
    public static TypeUtil instance = new TypeUtil();

    private TypeUtil() {
        Robot tempRobot = null;
        try {
            tempRobot = new Robot();
            tempRobot.setAutoDelay(delay);
        } catch (AWTException e) {
            e.printStackTrace();
        }
        robot = tempRobot;
    }

    public void setDelay(int delay) {
        this.delay = delay;
    }

    public int getDelay() {
        return delay;
    }

    private boolean robotInitialized() {
        if (robot == null) System.out.println("Failed to initialize robot!");
        return robot != null;
    }

    public void typeString(String string, int count) {
        if (!robotInitialized()) return;
        for (int i = 0; i < count; i++) {
            typeString(string);
        }
    }

    public void typeString(String string) {
        if (!robotInitialized()) return;

        for (char c : string.toCharArray()) {
            pressAndRelease(c);
        }
        pressAndRelease(KeyEvent.VK_TAB);
        pressAndRelease(KeyEvent.VK_ENTER);
        robot.delay(delay);
    }

    private void pressAndRelease(char key) {
        if (!robotInitialized()) return;
        robot.keyPress(key);
        robot.keyRelease(key);
    }

    /*
     * KeyEvent constants
     */
    private void pressAndRelease(int key) {
        if (!robotInitialized()) return;
        robot.keyPress(key);
        robot.keyRelease(key);
    }
}
