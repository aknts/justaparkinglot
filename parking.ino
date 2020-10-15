// Variables

// First we setup our variables
// One variable for each output plus two more (FFLOOR and SFLOOR) to host the status of the first floor, if it is filled or not 
int CARS = 0;
int AVAILABLE = 15;
int IN = 0;
int OUT0 = 0;
int OUT1 = 0;
int FFLOOR = 0;
int SFLOOR = 0;


// Functions

// A function to simulate printing a decimal number to a 4bit output using two variables
// Variable i is the number that we want to print
// Variable sb is the "starting bit" or to be precise the starting digital output on the Arduino
// After we get our starting output we use the next three digital outputs to "print" our 4bit number
// Before writing to the outputs we calculate the decimal number to binary.
void printValue(int i, int sb)
{
   int a=i%2;      // calculate LSB   
   int b=i/2 %2;     
   int c=i/4 %2;        
   int d=i/8 %2;  //calculate MSB
   digitalWrite(sb,d);   //write MSB
   digitalWrite(sb+1,c);   
   digitalWrite(sb+2,b);    
   digitalWrite(sb+3,a);  // write LSB  
}

void setup()
{
  
  // Debugging
  
  // Initiate Serial communication.
  Serial.begin(9600);

  // Inputs
  
  // Pins 14-16 are pins A0-A3 on the board, we use this cause digital pins 0 and 1 stay HIGH if serial output is initiated and cannot be used.
  // Pin 2 wasn't used because I wanted all the inputs to be grouped in close pins.
  // This pins are going to the push buttons that control/simulate the cars
  // Pin 14 is OUT1, 15 is OUT2 and 16 is our IN. 
  pinMode(14, INPUT);
  pinMode(15, INPUT);
  pinMode(16, INPUT);


  // Outputs
  
  // All are connected to leds with different color.
  // Pins 3-5 are the outputs of the system.
  // Pin 3 is the availability on the first floor.
  // Pin 4 is the availability on the second floor.
  // Pin 5 corresponds to the garage status if it is full or not.
  // We setup all the outputs to low to avoid random states at initilization.
  pinMode(3, OUTPUT);
  digitalWrite(3, LOW);
  pinMode(4, OUTPUT);
  digitalWrite(4, LOW);
  pinMode(5, OUTPUT);
  digitalWrite(5, LOW);

  // Range of 4 outputs to print the CARS value in binary
  // We setup all the outputs to low to avoid random states at initilization.
  pinMode(6, OUTPUT);
  digitalWrite(6, LOW);
  pinMode(7, OUTPUT);
  digitalWrite(7, LOW);
  pinMode(8, OUTPUT);
  digitalWrite(8, LOW);
  pinMode(9, OUTPUT);
  digitalWrite(9, LOW);

  // Range of 4 outputs to print the AVAILABLE value in binary 
  // We setup all the outputs to low to avoid random states at initilization. 
  pinMode(10, OUTPUT);
  digitalWrite(10, LOW);
  pinMode(11, OUTPUT);
  digitalWrite(11, LOW);
  pinMode(12, OUTPUT);
  digitalWrite(12, LOW);
  pinMode(13, OUTPUT);
  digitalWrite(13, LOW);
}

void loop()
{
  // Receiving input
  // While runnning we check our input pins and setup the corresponding variables, also print to serial for debugging.
  OUT0 = digitalRead(14);
  Serial.print("OUT0=");
  Serial.println(OUT0);
  OUT1 = digitalRead(15);
  Serial.print("OUT1=");
  Serial.println(OUT1);
  IN = digitalRead(16);
  Serial.print("IN=");
  Serial.println(IN);
  
  Serial.print("AVAILABLE=");
  Serial.println(AVAILABLE);
  
  Serial.print("CARS=");
  Serial.println(CARS);
  
  Serial.print("FFLOOR=");
  Serial.println(FFLOOR);
  
  Serial.print("SFLOOR=");
  Serial.println(SFLOOR);

  // Calculations
  // Depending the input that we have in each cycle we change the values of CARS and AVAILABLE (park spots).
  if (IN == 1 && AVAILABLE > 0) {
    CARS += 1;
    AVAILABLE -= 1;
    if (FFLOOR < 8) {
    	FFLOOR += 1;
    } else {
    	SFLOOR += 1;
    }
  }
  if (OUT0 == 1 && AVAILABLE < 15 && FFLOOR > 0 && FFLOOR <= 8) {
    AVAILABLE += 1;
    CARS -= 1;
    FFLOOR -= 1;
  }
  if (OUT1 == 1 && AVAILABLE < 15 && SFLOOR > 0 && SFLOOR <= 7) {
    AVAILABLE += 1;
    CARS -= 1;
    SFLOOR -= 1;
  }

  // Led/output  manipulation
  // Depending of the value of AVAILABLE we change the state of the connected LEDS
  // In each check we set up all three LEDS representing the avalability of each floor and the garage to avoid false values when switching between floor states
  if (FFLOOR < 8) {
    digitalWrite(3, HIGH);
    digitalWrite(4, LOW);
    digitalWrite(5, LOW);
  }
  if (FFLOOR >= 8 && SFLOOR < 7) {
    digitalWrite(3, LOW);
    digitalWrite(4, HIGH);
    digitalWrite(5, LOW);
  }
  if (AVAILABLE == 0) {
    digitalWrite(3, LOW);
    digitalWrite(4, LOW);
    digitalWrite(5, HIGH);
  } 

  // Main output block
  // Using the specific function, we "print" in each cycle the "4bit" variables to the specified outputs.
  // We don't use any checks to see if there was a change or not from last time and decide to print or not.
  // Cheaper and cleaner, the previous checks have the same effect.
  printValue(CARS,6);
  printValue(AVAILABLE,10);

  // Delay for debugging.
  // Changing this makes the system more prune to delays.
  // If a bigger value is chosen then each push button must be pressed more to register a change.
  // Please monitor the serial console to see if the value of CARS and AVAILABLE has chaged before letting it off.
  delay(500);
}