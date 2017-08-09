
import processing.pdf.*;
import java.util.Calendar;

boolean recordPDF = false;


ArrayList <Word> words;



void setup() {
  // use full screen size 
  size(displayWidth, displayHeight, P2D);
  background(255);
  smooth();
  cursor(CROSS);
  words = new ArrayList();
  words.add(new Word());

}


void draw() {
    background(0);
    
  if (frameCount%30==0) {
    words.add(new Word());
    if (words.size()>10) {
      words.remove(words.get(0));
    }
  }
  
  
  pushMatrix();
  translate(width,height);
  scale(-1);
  for (int i = 0; i < words.size (); i++) {
    words.get(i).update();
  }
  popMatrix();
   
}


public class Letter{
private int opacity;
private float posX, posY;
private float angle;
private char letter;
private color c;
private PFont font;
private float charSize;

public Letter(char letter,float posX, float posY, color c, float angle, float charSize) {
  this.letter= letter;
  this.c= c;
  this.angle= angle;
  this.posX= posX;
  this.posY= posY;
  this.charSize= charSize;
  opacity= 255;


}

public void display(){
    textSize(charSize);
    pushMatrix();
      translate(posX, posY);
      rotate(angle);
      fill(c);
      text(letter, 0, 0);
      popMatrix();
}
}
public class Word {
  PVector direction;
  PVector location;
  PVector locationTemp;

  float speed;
  float SPEED;

  float noiseScale;
  float noiseStrength;
  float forceStrength;

  float ellipseSize;

  color c;

  PFont font;

  String letters =" ";
  String posiblesPalabras[];
  int counter =0;
  float stepSize = 5.0;
  float angleDistortion = 0.0;
  ArrayList<Letter> characters;
  int fontSizeMin;

  public Word() {
    characters= new ArrayList<Letter>();
    posiblesPalabras= new String[15];
    posiblesPalabras[0]= "Amour ";
    posiblesPalabras[1]= "No se ";
    posiblesPalabras[2]= "Misogeno ";
    posiblesPalabras[3]= "Alegría ";
    posiblesPalabras[4]= "Bolígrafo ";
    posiblesPalabras[5]= "Gafas ";
    posiblesPalabras[6]= "Elisabeth ";
    posiblesPalabras[7]= "Marianita ";
    posiblesPalabras[8]= "Sandia ";
    posiblesPalabras[9]= "Cali ";
    posiblesPalabras[9]= "Corazón ";
    posiblesPalabras[10]= "Melón ";
    posiblesPalabras[11]= "Rosa ";
    posiblesPalabras[12]= "Mapa ";
    posiblesPalabras[13]= "Antartica ";
    posiblesPalabras[14]= "Rotulador ";

    fontSizeMin= 40;
    letters= posiblesPalabras[(int)random(15)];
    setRandomValues();
  }

  void setRandomValues () {
    location = new PVector (random (width), random (height));
    ellipseSize = random (20, 45);

    float angle = random (TWO_PI);
    direction = new PVector ((cos (angle)), (sin (angle)));

    SPEED = speed;
    noiseScale = 8;
    noiseStrength = 1;
    forceStrength = random (0.1, 2);

    setRandomColor();


    //font = loadFont("Aquatico-Regular.vlw");
    font = loadFont("ScoreBoard.vlw");
    textFont(font);
    //font = createFont("American Typewriter", 80);

    textFont(font, fontSizeMin);
    textAlign(LEFT);

    locationTemp= new PVector(location.x, location.y);
  }

  void setRandomColor () {
    int colorDice = (int) random (4);

    if (colorDice == 0) c = #ffedbc;
    else if (colorDice == 1) c = #A75265;
    else if (colorDice == 2) c = #ec7263;
    else c = #febe7e;
  }

  void update () {
    move();
    //steer(location.x, location.y);
    checkEdgesAndRelocate();
    addNoise();
    // addRadial();
    rotateLetters();
    // display();
  }

  void rotateLetters() {

    float d = dist(locationTemp.x, locationTemp.y, location.x, location.y);
    float tempSize= random(40, 60)+d; // MODIFCARLO

    char newLetter = letters.charAt(counter);
    stepSize = textWidth(newLetter);//MODICARLO

    if (d > stepSize) {
      float angle = atan2(location.y-locationTemp.y, location.x-locationTemp.x); 
      float tempAngle= angle + random(angleDistortion);

      characters.add(new Letter(newLetter, location.x, location.y, c, tempAngle, tempSize));

      counter++;
      if (counter > letters.length()-1) counter = 0;

      locationTemp.x = locationTemp.x + cos(angle) * stepSize;
      locationTemp.y = locationTemp.y + sin(angle) * stepSize;
    }
    
    for (int i=0; i<characters.size (); i++) {
      characters.get(i).display();
    }
    if (characters.size()>20) {
      characters.remove(characters.get(0));
    }
  }

  void move () {
    speed = random (10, 20);
    PVector velocity = direction;
    velocity.mult (speed);
    location.add (velocity);
  }

  void checkEdgesAndRelocate () {
    float diameter = ellipseSize;

    if (location.x < -diameter/2)
    {
      location.x = random (-diameter/2, width+diameter/2);
      location.y = random (-diameter/2, height+diameter/2);
      locationTemp=new PVector(location.x, location.y);
    } else if (location.x > width+diameter/2)
    {
      location.x = random (-diameter/2, width+diameter/2);
      location.y = random (-diameter/2, height+diameter/2);
      locationTemp=new PVector(location.x, location.y);
    }

    if (location.y < -diameter/2)
    {
      location.x = random (-diameter/2, width+diameter/2);
      location.y = random (-diameter/2, height+diameter/2);
      locationTemp=new PVector(location.x, location.y);
    } else if (location.y > height + diameter/2)
    {
      location.x = random (-diameter/2, width+diameter/2);
      location.y = random (-diameter/2, height+diameter/2);
      locationTemp=new PVector(location.x, location.y);
    }
  }

  void addRadial () {

    float m = noise (frameCount / (20*noiseScale));
    m = map (m, 0, 1, - 1.2, 1.2);

    //   float maxDistance = m * dist (0, 0, width/2, height/2);
    float maxDistance = m * dist (0, 0, width/2, height/2);
    float distance = dist (location.x, location.y, random(width/2, width), random(height/2, height));

    float angle = map (distance, 0, maxDistance, 0, TWO_PI);

    PVector force = new PVector (cos (angle), sin (angle));
    force.mult (forceStrength);

    direction.add (force);
    // direction.normalize();
  }


  void addNoise () {
    float noiseValue = noise (location.x /noiseScale, location.y / noiseScale, frameCount / noiseScale);
    noiseValue*= TWO_PI * noiseStrength;

    PVector force = new PVector (cos (noiseValue), sin (noiseValue));
    //Processing 2.0:
    //PVector force = PVector.fromAngle (noiseValue);
    force.mult (forceStrength);
    direction.add (force);
    direction.normalize();
  }
  void steer (float x, float y)
  {
    steer (x, y, 1);
  }

  void steer (float x, float y, float strength)
  {

    float angle = atan2 (y-location.y, x -location.x);

    PVector force = new PVector (cos (angle), sin (angle));
    force.mult (forceStrength * strength);

    direction.add (force);
    direction.normalize();

    float currentDistance = dist (x, y, location.x, location.y);

    if (currentDistance < 70)
    {
      speed = map (currentDistance, 0, 70, 0, SPEED);
    } else speed = SPEED;
  }

  void display () {
    noStroke();
    fill (c);
    ellipse (location.x, location.y, ellipseSize, ellipseSize);
  }
}


