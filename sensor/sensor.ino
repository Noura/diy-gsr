/*
Galvanic Skin Response meter
Chris Kairalla
 */
#define smooth 32  //2 smooths the last two nums, 3 smooths the last 3...
int analogValueSmooth = 0;
int thresh = 10;
int smoothArray[smooth];
//set baud rate
int baud = 9600;
boolean bluetooth = false;

#define SENSOR_PIN 0

void setup()
{
  Serial.begin(baud);
}

int smoothReading = 0;
void loop() {
  addToArray();
  //smoothReading = 0.5 * findAverage() + 0.5 * smoothReading;
  smoothReading = findAverage();
  //smoothReading = filter();
  Serial.print(1023 - smoothReading);
  Serial.print(",");
  delay(10);
}

void addToArray(){
  for (int i = smooth-1; i >= 1; i--){
    smoothArray[i] = smoothArray[i-1]; //shift every num up one slot
  }
  smoothArray[0] = analogRead(SENSOR_PIN);
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

// filtering
float coeffs[] = { 0.00414511,  0.00473141,  0.00632767,  0.00892322,
  0.01245632,  0.01681584,
  0.02184562,  0.02735137,  0.03310961,  0.03887846,  0.04440942,  0.04945972,
  0.0538046,   0.05724864,  0.05963576,  0.06085723,  0.06085723,  0.05963576,
  0.05724864,  0.0538046,   0.04945972,  0.04440942,  0.03887846,  0.03310961,
  0.02735137,  0.02184562,  0.01681584,  0.01245632,  0.00892322,  0.00632767,
  0.00473141,  0.00414511};

float filter() {
  int res = 0;
  for (int i = 0; i < smooth; i++) {
    res += coeffs[i] * smoothArray[i];
  }
  return res;
}

