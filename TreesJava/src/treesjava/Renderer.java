package treesjava;

import java.awt.BasicStroke;
import java.awt.Canvas;
import java.awt.Color;
import java.awt.Dimension;
import java.awt.Graphics2D;
import java.awt.Paint;
import java.awt.Stroke;
import java.awt.geom.Line2D;
import java.awt.geom.Rectangle2D;
import java.awt.image.BufferStrategy;

import javax.swing.JFrame;

public class Renderer extends Canvas {
  public int width, height;
  public GameManager gameManager;
  private JFrame frame;
  private Graphics2D graphics;
  private BufferStrategy bs;

  private Paint strokePaint;
  private Paint fillPaint;

  public Renderer(int width, int height, GameManager gameManager) {
    this.width = width;
    this.height = height;
    this.gameManager = gameManager;
    setPreferredSize(new Dimension(width, height));
    frame = new JFrame("Trees");
    frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
    frame.add(this);
    frame.pack();
    frame.setLocationRelativeTo(null);
    frame.setVisible(true);
    frame.setResizable(false);
    setIgnoreRepaint(true);
    createBufferStrategy(2);
    bs = getBufferStrategy();
    graphics = (Graphics2D) bs.getDrawGraphics();
    setFocusable(true);
    requestFocus();
  }

  public JFrame getFrame() {
    return frame;
  }

  public void render() {
    do {
      do {
        graphics = (Graphics2D) bs.getDrawGraphics();
        draw();
        graphics.dispose();
      } while (bs.contentsRestored());
      bs.show();
    } while (bs.contentsLost());
  }

  public void draw() {
    background(Color.BLACK);
    gameManager.drawGrid();
    gameManager.drawCameraBar();
  }

  public void background(Paint p) {
    graphics.setPaint(p);
    graphics.fillRect(0, 0, getWidth(), getHeight());
  }

  public void stroke(Paint p) {
    strokePaint = p;
  }

  public void noStroke() {
    strokePaint = null;
  }

  public void strokeWeight(float w) {
    graphics.setStroke(new BasicStroke(w, BasicStroke.CAP_ROUND, BasicStroke.JOIN_MITER));
  }

  public void strokeStyle(Stroke style) {
    graphics.setStroke(style);
  }

  public void fill(Paint p) {
    fillPaint = p;
  }

  public void noFill() {
    fillPaint = null;
  }

  public void point(float x, float y) {
    if (strokePaint == null)
      return;
    graphics.setPaint(strokePaint);
    graphics.drawLine((int) x, (int) y, (int) x, (int) y);
  }

  public void line(float x1, float y1, float x2, float y2) {
    if (strokePaint == null)
      return;
    graphics.setPaint(strokePaint);
    graphics.draw(new Line2D.Float(x1, y1, x2, y2));
  }

  public void rect(float x, float y, float w, float h) {
    if (fillPaint != null) {
      graphics.setPaint(fillPaint);
      graphics.fill(new Rectangle2D.Float(x, y, w, h));
    }
    if (strokePaint != null) {
      graphics.setPaint(strokePaint);
      graphics.draw(new Rectangle2D.Float(x, y, w, h));
    }
  }
}
