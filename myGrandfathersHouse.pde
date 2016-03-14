/**
 * m02e_scanPainter_large
 * 
 * really big image from a (relatively) small video  
 *
 */

import java.io.*;
import processing.video.*;
PImage slices, composite, lastFrame;

float aspectRatio;
//int targetSize[] = { 7200, 4051 };
int targetSize[] = { 3840, 2560 };
float scale;

int numSlices = 8;
int sliceWidth;

boolean capture = false;

Movie movie;

void setup() {
  size(3840, 2560);
  selectInput("Pick a movie", "movieSelected");
  println("Loading movie...");
  while ( movie == null ) {
    // Wait for the movie to load
    delay(30);
  }
  println("Loaded");
  delay(100);
  movie.loop();
  movie.read();
  println(movie.width + "*" + movie.height);
  aspectRatio = float(movie.width)/movie.height;
  println(aspectRatio);
  scale = float(targetSize[0])/movie.width;
  println(scale);
//  int windowHeight = int(min(movie.height, 720));
  int windowHeight = movie.height;
  int windowWidth = int(aspectRatio * windowHeight);
  //size(targetSize[0], targetSize[1]);
  background(0);
  slices = createImage(targetSize[0], targetSize[1], ARGB);
  composite = createImage(targetSize[0], targetSize[1], ARGB);
  lastFrame = createImage(width, height, ARGB);
  sliceWidth = int(targetSize[0]/numSlices);
  println("Slice width: " + sliceWidth);
}

void movieSelected(File selection) {
  println("Loading movie...");
  if ( selection == null ) {
      movie = new Movie(this, sketchPath("") + "../media/segments/01-01-taxis.mov");
  } else {
      movie = new Movie(this, selection.getAbsolutePath());
      println("Got your selection");
  }
}

void movieEvent(Movie m) {
  m.read();
}

void draw() {
  if ( movie != null ) {
    tint(255, 255);
    image(lastFrame, 0, 0, width, height);
    tint(255, map(mouseX, 0, 1000, 0, 255));
    image(movie, 0, 0, width, height);
    for( int outer = 0; outer < slices.width; outer += sliceWidth ) {
      float c[][] = new float[movie.height][3];
      for (int i = 0; i < c.length; i++) {
        color _c = movie.get(int(outer/scale), i);
        c[i][0] = red(_c);
        c[i][1] = green(_c);
        c[i][2] = blue(_c);
      }
//      println("c: " + c.length);
      for ( int j = 0; j < sliceWidth; j++ ) {
        if ( outer + j < slices.width ) {
          for (int i = 0; i < slices.height; i++) {
            int ref = min(int(float(i)/scale), c.length - 1);
//            println(i + " " + ref); 
            color _c = color(c[ref][0], c[ref][1], c[ref][2], 255-j/3);
            slices.set(outer + j, i, _c);
          }
        }
      }
    }
    image(slices, 0, 0, width, height);
    if ( capture ) {
      save(frameCount + ".jpg" );
      capture = false;
    }
    delay(30);
    lastFrame.copy();
    tint(255,255);
    image(lastFrame, 10, 10, 600, 900);
  }
}

void keyPressed() {
  switch(key) {
    case 'c':
      capture = true;
      break;
    default:
      break;
  }
}