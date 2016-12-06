/**
 * My Grandfather's House
 * 
 * really big image from a (relatively) small video  
 *
 */

import java.io.*;
import processing.video.*;

// Config: you need to set the output image size manually if you don't want to edit, but the sketch will fit the image to the window size.
/*
 Target size is set with the size() function at the beginning of setup(). Included here for reference and a reminder only.
 int width = 3840;
 int height = 2560;
*/
int numSlices = 8;

// Variables and objects
PImage slices, inset;

float aspectRatio, windowRatio, scale;
float alpha = 255, playbackSpeed = 1;
int imageWidth, imageHeight, insetWidth, insetHeight, sliceWidth;

boolean capture = false;
boolean freeze = false;

Movie movie;

void setup() {
  size(3840, 2160);
  
  // 0. Figure out the window
  windowRatio = float(width) / height;
  println("Window aspect ratio: " + windowRatio);
  insetWidth = 1000;
  insetHeight = int(insetWidth * (1 / windowRatio));
  println("Inset: " + insetWidth + "*" + insetHeight);

  // 1. Load the movie
  selectInput("Pick a movie", "movieSelected");
  println("Loading movie...");
  while ( movie == null ) {
    // Wait for the movie to load
    delay(30);
  }
  println("Loaded");
  delay(100);
  
  // 2. Get movie dimensions and aspect ratio
  //movie.loop();
  movie.play();
  //movie.pause();
  movie.read();
  println("Movie loaded: " + movie.width + "*" + movie.height);
  aspectRatio = float(movie.width)/movie.height;
  println("Aspect ratio: " + aspectRatio);
  
  // 3. Figure out scale and image sizes
  float scaleX = float(width)/movie.width;
  float scaleY = float(height)/movie.height;
  scale = min(scaleX, scaleY);
  println("Scale: " + scale);
  imageWidth = int(movie.width * scale);
  imageHeight = int(movie.height * scale);
  
  // 4. Make the image objects
  slices = createImage(imageWidth, imageHeight, ARGB);
  inset = createImage(imageWidth, imageHeight, ARGB);
  sliceWidth = int(width/numSlices);
  println("Slice width: " + sliceWidth);

  // Load the first frame
  background(0);
  image(movie, 0, 0, imageWidth, imageHeight);
  inset = get();
}

void movieSelected(File selection) {
  println("Loading movie...");
  if ( selection == null ) {
    println("I need a movie to run!");
    exit();
  } else {
    movie = new Movie(this, selection.getAbsolutePath());
    println("Loaded " + selection.getAbsolutePath());
  }
}

void movieEvent(Movie m) {
  m.read();
}

void draw() {
  if ( movie != null ) {
    float position = (frameCount / 30.0) * playbackSpeed % movie.duration();
    movie.jump(position);
    tint(255, 255);
    image(inset, 0, 0, width, height);
    if (!freeze) alpha = map(mouseX, 0, 1000, 0, 255);
    tint(255, alpha);
    image(movie, 0, 0, imageWidth, imageHeight);
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
    image(slices, 0, 0, imageWidth, imageHeight);
    if ( capture ) {
      save(frameCount + ".tif" );
      //capture = false;
    }
    delay(30);
    inset = get();
    background(0);
    tint(255,255);
    image(inset, 10, 10, insetWidth, insetHeight);
    fill(255);
    text("Alpha: " + alpha, 10, insetHeight + 40);
    text("Freeze: " + freeze, 10, insetHeight + 60);
    text("Position: " + position, 10, insetHeight + 80);
    text("Playback speed: " + playbackSpeed, 10, insetHeight + 100);
    if (capture) {
      text("Capturing", 10, insetHeight + 110);
      capture = false;
    }
  }
}

void keyPressed() {
  switch(key) {
    case 'c':
      capture = true;
      break;
    case 'f':
      freeze = !freeze;
      break;
    case 'w':
      playbackSpeed -= .2;
      break;
    case 'e':
      playbackSpeed += .2;
      break;
    case 'r':
      playbackSpeed = 1;
      break;
    case 'q':
      exit();
      break;
    default:
      break;
  }
}