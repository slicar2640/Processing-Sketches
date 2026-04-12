package treesjava;

import java.awt.Canvas;
import java.awt.Dimension;
import java.awt.Graphics2D;
import java.awt.event.WindowEvent;
import java.awt.event.WindowListener;
import java.awt.image.BufferStrategy;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

import javax.swing.JDialog;
import javax.swing.JFrame;

public abstract class Widget extends Canvas implements WindowListener {
  protected GameManager gameManager;
  protected JDialog window;
  protected boolean windowOpen = false;
  protected BufferStrategy bs;
  protected Graphics2D graphics;
  protected ScheduledExecutorService schedule;

  public void openWindow(int x, int y, int width, int height) {
    if (windowOpen) {
      return;
    }
    windowOpen = true;
    JFrame managerFrame = gameManager.renderer.getFrame();
    window = new JDialog(managerFrame);
    setPreferredSize(new Dimension(width, height));
    window.setDefaultCloseOperation(JDialog.DISPOSE_ON_CLOSE);
    window.add(this);
    window.pack();
    window.setLocation(x, y);
    window.setVisible(true);
    window.setResizable(true);
    window.addWindowListener(this);
    setIgnoreRepaint(true);
    createBufferStrategy(2);
    bs = getBufferStrategy();
    graphics = (Graphics2D) bs.getDrawGraphics();
    setFocusable(false);

    schedule = Executors.newSingleThreadScheduledExecutor();
    schedule.scheduleAtFixedRate(this::render, 0, 1000 / 60, TimeUnit.MILLISECONDS);
  }

  private void render() {
    do {
      do {
        graphics = (Graphics2D) bs.getDrawGraphics();
        draw();
        graphics.dispose();
      } while (bs.contentsRestored());
      bs.show();
    } while (bs.contentsLost());
  }

  protected abstract void draw();

  @Override
  public void windowClosed(WindowEvent e) {
    schedule.shutdown();
    windowOpen = false;
  }

  @Override
  public void windowOpened(WindowEvent e) {
  }

  @Override
  public void windowClosing(WindowEvent e) {
  }

  @Override
  public void windowIconified(WindowEvent e) {
  }

  @Override
  public void windowDeiconified(WindowEvent e) {
  }

  @Override
  public void windowActivated(WindowEvent e) {
  }

  @Override
  public void windowDeactivated(WindowEvent e) {
  }
}
