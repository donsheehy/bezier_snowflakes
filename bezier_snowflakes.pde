import processing.pdf.*;

int s = 400;
int pieces = 6;
int numPoints = 0;
Point[] points = new Point[300];
int MOVING = 0;
int STILL = 1;
int mode = MOVING;
int seedPoints = 8;
String filePrefix = pieces + "x" + seedPoints + "_";
int fileIndex = 0;

void setup() {
  size(2*s,2*s);
  smooth();
  background(0);
  stroke(255);
  frameRate(10);
  
  numPoints = seedPoints;
  for(int i  =0; i < numPoints; ++i) {
    points[i] = new Point(random(s/1.44), random(s/1.44));
    points[i].setVelocity(random(3)-1, random(3)-1);
  }
}

void draw() {
  if (mode==MOVING) {
    drawFrame();
    movePoints();
  }
}

void keyPressed() {
  if (key == ' ') {
    mode = (mode == MOVING) ? STILL : MOVING;
  }
  if (key == 'p') {
    writePDF(fileIndex++);
  }
}

void writePDF(int fileNum) {
  String filename = filePrefix + fileNum + ".pdf";
  beginRecord(PDF, filename);
  background(0);
  int steps = 16;
  for(int j = 0; j < numPoints; ++j) {
    points[j].backUp(steps);
  } 
  for(int i  =0; i < steps; ++i) {
    drawFrame();
    movePoints();
  }
  endRecord();
}

void movePoints() {
  for(int k = 0; k < numPoints; ++k) {
    points[k].move(); 
  }  
}


void drawFrame() {
  fill(0,0,0,32);
  rect(0,0,2*s, 2*s);
  noFill();
  stroke(200,200,255, 180);
  strokeWeight(3);
  bezierFlake(.4);
  stroke(200,200,255);
  strokeWeight(2);
  bezierFlake(.5);
  stroke(255,255,255,200);
  strokeWeight(1);
  bezierFlake(.65);

}

void bezierFlake(float m) {
  pushMatrix();
  translate(s,s);
  drawBezierCloserCurve(points, numPoints, m);
  popMatrix();
  pushMatrix();
  translate(s,s);
  scale(-1, 1);
  drawBezierCloserCurve(points, numPoints, m);
  popMatrix();
  
}

void mousePressed() {
  points[numPoints] = new Point(mouseX-s, mouseY-s);  
//  points[numPoints].drawAll(pieces);
  numPoints++;
}

Point avg(Point a, Point b) {
  return new Point((a.x + b.x)/2.0, (a.y + b.y)/2.0);
}

void myBezier(Point a, Point b, Point c,float m) {
  bezier(a.x, a.y, (m * a.x)+ ((1-m) * b.x), (m * a.y)+ ((1-m) * b.y), (m * c.x)+ ((1-m) * b.x), (m * c.y)+ ((1-m) * b.y), c.x, c.y);
}

void drawBezierCloserCurve(Point[] pts, int l, float m) {
  if (l>2) {
    Point s1, s2, p1, p2, p3;
    for (int j = 0; j < pieces; ++j) {
      for(int i = 2; i < l; ++i) {
        p1 = pts[i-2].rotated(j,pieces);
        p2 = pts[i-1].rotated(j,pieces);
        p3 = pts[i].rotated(j,pieces);
        s1 = avg(p1, p2);
        s2 = avg(p2, p3);
        myBezier(s1, p2, s2, m);
      }
      p1 = pts[l-2].rotated(j,pieces);
      p2 = pts[l-1].rotated(j,pieces);
      p3 = pts[0].rotated(j+1,pieces);
      s1 = avg(p1, p2);
      s2 = avg(p2, p3);
      myBezier(s1, p2, s2, m);
      p1 = pts[1].rotated(j+1,pieces);
      p2 = pts[l-1].rotated(j,pieces);
      p3 = pts[0].rotated(j+1,pieces);
      s1 = avg(p2, p3);
      s2 = avg(p1, p3);
      myBezier(s1, p3, s2, m);
    }
    p1 = pts[l-2].rotated(pieces-1,pieces);
    p2 = pts[l-1].rotated(pieces-1,pieces);
    s1 = avg(p1, p2);
    s2 = avg(p2, pts[0]);
    myBezier(s1, p2, s2, m);
    s1 = avg(p2, pts[0]);
    s2 = avg(pts[1], pts[0]);
    myBezier(s1, pts[0], s2, m);
    endShape();
  }
}

class Point {
  float x;
  float y;
  float vx;
  float vy;
  Point(float xx, float yy) {
    x = xx;
    y = yy;
    vx = 0;
    vy = 0;
  }  
  
  void setVelocity(float vxx, float vyy) {
    vx = vxx;
    vy = vyy;
  }
  
  //rotate the point by 2pi* j/k
  Point rotated(float j, float k) {     
     float angle = 2 * PI * (j / k);
     float a = cos(angle);
     float b = - sin(angle);
     return new Point(a*x - b*y, a*y + b*x); 
  }

  void draw(float j, float k) {
    ellipseMode(CENTER);
    noStroke();
    fill(255);
    float angle = 2 * PI * (j / k);
    pushMatrix();
    translate(s,s);
    rotate(angle);
    sliver(x,y);
    sliver(-x,y);
    popMatrix();
  }
  
  void drawAll(int p) {
//    p= 1;
    for(int i = 0; i < p; ++i) {
      draw(i, p);
    }
  }

  void move() {
    x += vx;
    y += vy;
    
    if(x > s/1.44 || x < 0) {vx = -vx; }
    if(y > s/1.44 || y < 0) {vy = -vy; }
  }

  void backUp(int steps) {
    vx = -vx;
    vy = -vy;
    for (int i = 0; i < steps; ++i) {
      move();
    }
    vx = -vx;
    vy = -vy;    
  }

  void lineTo(float a, float b) {
    pushMatrix();
    translate(s,s);
    line(x,y, a, b);
    popMatrix();
  }

  void sliver(float xx, float yy) {
    fill(100, 100, 255,50);
    ellipse(xx, yy, 30,5);    
    ellipse(xx, yy, 4, 20);    
    fill(150, 150, 255,70);
    ellipse(xx, yy, 32,7);    
    ellipse(xx, yy, 7 ,12);    
    fill(240, 240, 255,155);
    ellipse(xx, yy, 24,4);    
    ellipse(xx, yy, 3,8);    
  }

}

