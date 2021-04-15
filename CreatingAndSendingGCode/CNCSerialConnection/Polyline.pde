class Polyline {

  ArrayList<PVector> points;
  int type;
  boolean wasSentToPrinter = false;

  Polyline() {
    points = new ArrayList<PVector>();
  }

  void addPoint(float x, float y) {
    points.add(new PVector(x, y));
  }

  void render() {
    beginShape();
    PVector p;
    for (int i = 0; i < points.size(); i++) {
      p = points.get(i);
      vertex(p.x, p.y);
    }
    endShape();
  }

  int getPointCount() {
    return points.size();
  }

  StringList polylineGCode() {  
    //POLYLINE

    StringList gCode = new StringList();

    for (int i = 0; i < points.size(); i++) {
      PVector p = points.get(i);

      //Keeps the Pen Raised until it gets to the first point
      if (i == 0) {
        p = points.get(i);
        String lineStart = "G0 X" + (p.x/bedScale) + " Y" + (p.y/bedScale) + " Z" + (zToolHeight + penUpDistance) + "\n";
        gCode.append(lineStart);
      }

      /*
      PVector is in screen coorindate space so the point is scaled by the Scale Factor to make sure
       that the drawing stays within the boundary of the printer's bed.
       */
      String line = "G0 X" + (p.x/bedScale) + " Y" + (p.y/bedScale) + " Z" + zToolHeight + " F" + printerSpeed  + "" + "\n";

      gCode.append(line);
    }

    //Raise the Pen up when the last point is reached and amend the list with the additional command.
    for (int i = 0; i < points.size(); i++) {
      if (i == points.size()-1) {
        PVector p = points.get(i);
        String lineEnd = "G0 X" + (p.x/bedScale) + " Y" + (p.y/bedScale) + " Z" + (zToolHeight + penUpDistance) + " F" + printerSpeed  + "" + "\n";
        gCode.append(lineEnd);
      }
    }
    return gCode;
    }
}
