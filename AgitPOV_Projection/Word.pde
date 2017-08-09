public class Word {
  private PVector direction;//vector that change the direction of a word
  private PVector location;//vector that gives the position of each letter of the word
  private PVector locationTemp;// Vector that saves the valeu of location before it is transformed to it's current valeu

  private float speed;//speed 

  private float noiseScale;// scale of noise in the "movement" (trace) of the word
  private float noiseStrength;// Force that affects the scale of the noise

  private color c; // the color valeu of the word


  private int counter =0; //counter that helps to go through each letter of the word
  private float stepSize = 5.0; //The Distance between each letter
  private ArrayList<Letter> characters; // List of the characters that compose the word
  private int fontSize; //Size of the font for the word
  private float distancia; // minimal distances between letters

  private String word; //The String of the word
  //private float counterOP; //Counter that change the valeu of lowOpacity boolean 
  private int limiTime = maxDisplayedWordLifeTime; // Time that last the word with full opacity 


  private float opacity = 255; // Value of the word's opacity
  private boolean lowOpacity; //Boolean that triggers the decrease of the word's opacity

  private long timeCreated = 0;

  private boolean rainbow = false;

  void init(String word) {
    this.word=word;
    characters= new ArrayList<Letter>();
    timeCreated = millis();
  }


  public Word(String word, int colorID) { //Constructor for new typed words 

    fontSize= (int)random(120, 200);
    setRandomValues(colorID);

    init(word);
    //counterOP=second();
    //println("New word "+word+ " of color "+colorID);
  }

  public Word(String word) { //Constructor for background words


    if ((int)random(2)==1) {
      fontSize= (int)random(20, 30);
    } else {
      fontSize= (int)random(60, 120);
    }

    setRandomValues();

    init(word);
  }


  void setRandomValues (int colorID) { // Random Values for a word with a predefined color (new typed words)
    location = new PVector (random ((width/4), (3*width/4)), random ((height/4), (3*height/4)));

    float angle = random (TWO_PI);


    direction = new PVector ((cos (angle)), (sin (angle)));
    noiseScale = 8;
    noiseStrength = 1;

    setColor(colorID);
    distancia=random((fontSize*15)/100, fontSize*25)/100;



    locationTemp= new PVector(location.x, location.y);
  }

  void setRandomValues () { // Random Values for a word with no predefined color (old background words)
    location = new PVector (random (100, width-100), random (100, height-100));

    float angle = random (TWO_PI);


    direction = new PVector ((cos (angle)), (sin (angle)));

    noiseScale = 8;
    noiseStrength = 1;

    setRandomColor();
    distancia=random((fontSize*15)/100, fontSize*25)/100;


    locationTemp= new PVector(location.x, location.y);
  }

  void setRandomColor () { //Method to randomly choose one of four predefined color
    int colorDice = (int) random (4);



    if (colorDice == 0) c = #FFB700;
    else if (colorDice == 1) c = #FF033E;
    else if (colorDice == 2) c = #FF7403;
    else c = #FFF300;
  }

  void setColor(int id) { // Method to select the color depending of the id that is sended with the word 
    switch(id) {
    case 0:
      c= #FF0000;
      break;

    case 1:
      c=#FFB700;
      break;

    case 2:
      c=#FEFF00;
      break;

    case 3:
      c=#008E01;
      break;

    case 4:
      c=#0052FF;
      break;

    case 5:
      c=#7802B4;
      break;

    case 6:
      c=#FFFFFF;
      break;

    default:
      rainbow = true;
    }
  }

  void update () { //Method that is called in the main thread to move, add the noise, rotate the letters and draw the word.
    if (millis()-timeCreated>=limiTime) {
      lowOpacity= true;
    }


    move();
    addNoise();
    



    buildLetters();

    if ( fadeDisplayedWordDuringLifetime ) {
      opacity = map(millis()-timeCreated, 0., maxDisplayedWordLifeTime, 255., 0.);
    } else {
      if (lowOpacity) {
        opacity-=0.1;
      }
    }
    if ( opacity <= 0 ) opacity = 0;

    if ( rainbow ) c= java.awt.Color.HSBtoRGB( ((millis()-timeCreated) % 3000) / 3000.0, 1, 1);
    fill(c, opacity);
    textSize(fontSize);

    for (int i=0; i<characters.size (); i++) {
      characters.get(i).display();
    }
  }

  public void opacitar() { //Method  to trigger the change of the opacity
    lowOpacity= true;
  }

  void buildLetters() {// Method where is gived de position, rotate and draw each letter.
    if (counter < word.length()) {

      float d = dist(locationTemp.x, locationTemp.y, location.x, location.y);

      char newLetter = word.charAt(counter);
      // if (newLetter==' ') {
      //   stepSize= fontSize+distancia;
      // } else {
      stepSize= textWidth(newLetter)+distancia; // MODIFCARLO
      // }
      if (d > stepSize ) {

        float angle = atan2(location.y-locationTemp.y, location.x-locationTemp.x); 
        float tempAngle= angle;


        characters.add(new Letter(newLetter, locationTemp.x, locationTemp.y, tempAngle));


        counter++;


        locationTemp.x = location.x + (cos(angle) * stepSize);
        locationTemp.y = location.y + (sin(angle) * stepSize);
      }
    }
  }

  void move () { // Method that gives the shape of the word 
    speed = 15;
    PVector velocity = direction;
    velocity.mult (speed);
    location.add (velocity);
  }

  void addNoise () { // Method that add irregularity in the main shape of the word
    float noiseValue = noise (location.x /noiseScale, location.y / noiseScale, frameCount / noiseScale);
    noiseValue*= TWO_PI * noiseStrength;
    PVector force = new PVector (cos (noiseValue), sin (noiseValue));
    direction.add (force);
    direction.normalize();
  }

  public String getWord() { //Method to get the string of the word
    return word;
  }
}