/*
This program is simplified version of the Processing tool created for a project created by Erin Hunt and Molly Mason for the 
Spring 2020 Course SCI 6364 Enactive Design with help from Jose Luis Garcia del Castillo Lopez and Zach Seibold. More information 
regarding the course and the project can be found at the links below.

https://erinlhunt.com/drawing-dialogues
https://www.gsd.harvard.edu/course/enactive-design-creative-applications-through-concurrent-human-machine-interaction-spring-2020/
*/


import processing.serial.*;   

//List of Points Plotted When the Mouse is Pressed
ArrayList<Polyline> polys;

//Tool Height
int zToolHeight = 50;

//Pen Up Distance
int penUpDistance = 5;

//Printer Speed
int printerSpeed = 500;

int standBy = 0;

/*Scaling the coordinates from the 
Processing canvas to fit on the printer bed*/
int bedScale = 2;



PrinterCommunication printer;

void setup() {
  size(620, 510); // CNC Bounds (310mm x 255mm) * 2                         
  background(0);
  textAlign(LEFT, TOP);
  polys = new ArrayList(); 

  // Create printer comm object
    String portName = Serial.list()[0]; //list serial ports
    printer = new PrinterCommunication(this, portName, 115200);
  
}

void draw() {                 
  background(0);
  fill(255);

  text("COMMANDS", 20, 20);
  text("Press F to INCREASE and G to DECREASE the MOVE SPEED of the printer", 20, 40);
  text("Press H to HOME the printer", 20, 60);
  text("Press C to CLEAR the canvas", 20, 80);
  text("Press P for POLYLINE", 20, 100);



  //Draw Continuous polylines
  stroke(255);
  strokeWeight(3);
  noFill();
  for (Polyline pol : polys) {
    pol.render();
  }
  // See if printer needs to read and do something with response
    printer.checkReadings();
}   

void mousePressed() {
  Polyline pol = new Polyline();
  polys.add(pol);
  println("Started new polyline");
}

void mouseDragged() {
  Polyline lastPoly = polys.get(polys.size() - 1);
  lastPoly.addPoint(mouseX, mouseY);
}

  StringList polyGCode;
  Polyline lastPoly;
  
void mouseReleased() {
  if (polys.size() == 0) return;
  
  lastPoly = polys.get(polys.size() - 1);
  println("Finished drawing poly with " + lastPoly.getPointCount() + " points");
}


void keyPressed() {                           
  if (key == 'h' || key == 'H') {     
    //Send Home Command
    printer.send("G0 X0 Y0" + "\n"); 
  } 
  else if (key == 'c' || key == 'C') {
    println("Clearing all previous " + polys.size() + " polylines");
    polys.clear(); 
  }
  else if (key == 'p' || key == 'P'){
    polyGCode = lastPoly.polylineGCode();
    printer.sendBlock(polyGCode);
    println("Plotting a Polyline");
  }
  else if (key == 'd') {
    printer.sendNextBlock();
  }
  else if (key == 'z') {
    printer.send("M114");
  }
  else if (key == 'i') {
    printer.send("M111 S0");
  }
}
