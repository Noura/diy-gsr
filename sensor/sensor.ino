/*
Galvanic Skin Response meter
Chris Kairalla
 */
#define smooth 50     //2 smooths the last two nums, 3 smooths the last 3...
int oldReading = 0;    // variable to hold the old analog value
int analogValueSmooth = 0;
int thresh = 10;
int smoothArray[smooth];
//set baud rate
int baud = 9600;
boolean bluetooth = false;

#define SENSOR_PIN 0

void setup()
{
  Serial.begin(baud);	// opens serial port, sets data rate to 19200 bps
  //if (bluetooth){
  //Serial.print("+++");
  //Serial.print("\n");//print cr
  //Serial.print("ATSN,cdkBluetooth");
  //Serial.print("\n");//print cr
  //}
}

int smoothReading = 0;
void loop() {
  addToArray();
  //smoothReading = 0.5 * findAverage() + 0.5 * smoothReading;
  smoothReading = findAverage();
  Serial.print(1023 - smoothReading);
  Serial.print(",");
  delay(10);
}

/*
void loop() {
    int smoothReading;
    for (int i = 0; i < 1000; i++) {
      addToArray();
      smoothReading = findAverage();
    }
    if (smoothReading > -1){
      int diff = smoothReading - oldReading;
     //the op amp inverts, so we're flipping the numbers
     Serial.print(1023-smoothReading);
     Serial.print(","); //print comma
    }
    oldReading = smoothReading;
}*/

void addToArray(){
      for (int i = smooth-1; i >= 1; i--){
        smoothArray[i] = smoothArray[i-1]; //shift every num up one slot
      }
   smoothArray[0] = analogRead(SENSOR_PIN);  //add latest reading into slot 5
}

//finds the average of all the values in the array
int findAverage(){
  int average = 0;
  for (int i = 0; i < smooth; i++){
    average += smoothArray[i];
  }
  average = average / smooth;
  return average;
}


