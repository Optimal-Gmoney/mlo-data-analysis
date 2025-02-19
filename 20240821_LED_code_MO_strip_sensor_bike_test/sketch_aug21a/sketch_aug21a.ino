const int pwmPin = 3;  // PWM pin (you can change this to any PWM pin)
int inputValue = 50;
int pwmValue = map(inputValue, 0, 100, 0, 255);

void setup() {
  Serial.begin(9600);  // Start serial communication at 9600 baud
  pinMode(pwmPin, OUTPUT);  // Set the PWM pin as an output
  analogWrite(pwmPin, pwmValue);
  Serial.println("Please enter an intensity value between 0 and 100 percent.");
  Serial.println("Note the LED will get hot as hell at full intensider");
}

void loop() {
  if (Serial.available() > 0) {
    String inputString = Serial.readStringUntil('\n');  // Read the input value from the serial monitor
    inputValue = inputString.toInt();  // Convert the input string to an integer

    if (inputValue >= 0 && inputValue <= 100) {
      pwmValue = map(inputValue, 0, 100, 0, 255);  // Map the input value to PWM range (0-255)
      analogWrite(pwmPin, pwmValue);  // Set the PWM value on the pin
    } else {
      Serial.println("Please only enter a value between 0 and 100.");
    }
  }
  Serial.println(inputValue);
  delay(500);
}
