import processing.serial.*;

int reading = 0;
Serial mySerial;
String inString;  // in from Serial
int lf = 10;      // ASCII linefeed
int cr = 13;      //ASCII CR
int comma = 44;   //ASCII Comma
int x = 5;
int ltX = 0;  //x position for ltgraph
int ltY = 100;  //y position for ltgraph

int lineRange = 1; //how far the line is between readings
int lastRead=0;  //last point read
int currentRead=0;  //last point read
boolean gathering = false;  //some vague attempt to sync incoming data
//find height and valley of wave
int waveHigh = 0;
int waveLow = 0;
int mean = 0; //the mean of the wave, or (waveHigh + waveLow / 2)
//frequency of wave
float freq =0f;

//absolute high and low to draw the wave
int absHigh = 600;
int absLow =20;
int absRange = absHigh-absLow;
float normAbsRange = (float)absRange/1023f;

int highValue = absHigh;  //the height of the reading.  Touch sensors to set this.  Up arrow sets.
int lowValue = absLow;      //the base of the reading.  Sensors are not attached at all to set this.  Down arrow sets.
int valueRange = highValue-lowValue;

//buffer arrays
int[] readingBuffer = new int[width];
int readingBufferCounter = 0; //keeps track of which slot to put the new reading
int[] ltBuffer = new int[500];  //keeps track of long term data
ArrayList ltData = new ArrayList();  //holds the data to be written to the file
int ltCounter = 0;
boolean ltCalc = false;

//timestamp
long beginning= 0;
long start = 0;
int fadeCounter = 0;
boolean logging = false;

PFont font;

void setup(){
  // The font must be located in the sketch's 
  // "data" directory to load successfully
  font = loadFont("Arial-BoldMT-18.vlw"); 
  textFont(font, 18); 
  //init arrays
  for (int i = 0; i < readingBuffer.length; i++){
    readingBuffer[i] = 0; 
  }
  println(Serial.list());
  
  size(800, 800);
  noStroke();
  background(0);
  mySerial = new Serial(this, Serial.list()[2],9600);
  mySerial.bufferUntil(',');  //comma is the end of data
  stroke(255);
  frameRate(80);
  beginning = millis();
}


void draw(){
  calcWaveData();
  fill (0,0,0,2);//make trails
  noStroke();
  if (fadeCounter%3 ==0){
    rect(0,height-absHigh,width,height-absLow);
  }
  fill(255,255,255,255);
  stroke(255,255,255,255);
  line(x-lineRange,height-lastRead, x, height-currentRead);
  //draw the abs height lines
  stroke(255,255,255,255);
  line (0,height-absHigh, width, height-absHigh);
  line (0,height-absLow, width, height-absLow);
  x = x+lineRange;
  if (x > width)   //if it goes offscreen, loop back to the left
    x = 0;
  lastRead = currentRead;
  fadeCounter++;
}

void calcWaveData(){
  currentRead = (int) scaleReading();
  if (logging){
    ltBuffer[ltCounter] = currentRead;
    long currMillis = millis();
    if (currMillis-beginning > 1000){
      int sum = 0;
      for (int i = 0; i <=ltCounter; i++){
        sum += ltBuffer[i];
      }
      int avg = (int)(sum/(ltCounter+1));
      ltData.add(new Integer (avg));
     // println("added"+ (Integer) ltData.get(ltData.size()-1)+".  counter is at "+ltCounter);
      beginning = millis();
      if (ltData.size() > 1){
      Integer in= (Integer) ltData.get(ltData.size()-2);
      int ltLast = in.intValue();
      drawLTLine(avg, ltLast);
      eraseText();
      fill(255,255,255,255);
       text("Current Reading "+avg, 15, 195);
      ltCounter = -1;
      }
    }
    ltCounter++;
  }
}

void drawLTLine(int ltCurrent, int ltLast){
 //draws the long term lines
   // fill(255,255,255,255);
  stroke(255,0,0,255);
  ltCurrent = (int)((float)ltCurrent *0.5f);
    ltLast = (int)((float)ltLast *0.5f);
  line(ltX-lineRange,(absHigh-ltLast)-(absRange-60), ltX, (absHigh-ltCurrent)-(absRange-60));
  ltX +=2;
}

void eraseTop(){
  noStroke();
 fill(0,0,0,255);
 rect(0,0,width, height-absHigh-1); 
}
void eraseText(){
  noStroke();
 fill(0,0,0,255);
 rect(0,180,width, 20); 
}
float scaleReading(){
  float scale1;
  float scale2;
  float valueRangeScale = (1023f/(float)valueRange);
  scale1 = (float)(reading-lowValue) * valueRangeScale;
  scale2 = (float) scale1 * (normAbsRange) + absLow;
  // print("valueRange =" +valueRange);
  // println("reading = "+reading+"  value range scale = "+valueRangeScale+"   scale1 = "+ scale1+"   scale2= "+scale2);
  return scale2;
}


void serialEvent(Serial p) {
  gathering = true;
  while (mySerial.available() > 0) {
    char inByte = mySerial.readChar();
    if (inByte != ','){ 
      inString = inString + inByte;
    } 
    else {
      reading = int(inString);
      //println(inString);
      inString = "";
    }
  }
  gathering = false;
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      //divide reading by 1023, to get the normalized reading.
      // float rangeHigh = reading*normAbsRange;
      highValue =reading;
      valueRange = highValue-lowValue;
      println("high value = "+highValue);
    }      
    if (keyCode == DOWN) {
      lowValue = reading;
      valueRange = highValue-lowValue;
      println("low value = "+lowValue);
    }
  }
  if (key == ' '){
    ltData = new ArrayList();
    println("logging data");
    eraseTop();
    beginning = millis();
    logging = true;
  } 
  if (key == 's'){
    println("saving data");
    String[] ltArray = new String[ltData.size()];
    for (int i = 0; i < ltArray.length; i++){
      Integer in= (Integer) ltData.get(i);
      ltArray[i] = (in.toString()); 
    }
    saveStrings("cdkGSR_"+millis()+".txt", ltArray);
    logging = false;
    ltData = new ArrayList();
  }

}