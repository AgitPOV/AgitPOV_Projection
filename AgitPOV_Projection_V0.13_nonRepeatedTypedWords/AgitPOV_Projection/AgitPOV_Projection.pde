/* AgitPOV V0.11.
 Application made by: 
 Mariangela Aponte
 Kammil Carranza
 Daniela Delgado
 Sebastián Vásquez
 */

/*Imported class to implement the thread object
*/
import java.io.*;

ArrayList <Word> iniciales; //Word ArrayList, for the background words from the data base.
ArrayList <Word> words; //Word ArrayList, for the typed words.

String lines[]; //String array to save the data base's words.
int cont, contEspera, contOpacidad; //Control counters to add the last words from the data base, define a time interval to add words to the background words and start to decrease the opacity of each word
boolean control;
PFont font; // PFont, creates the font to be used.
int maxWordsSize; // maximum words on the screen.

public Communication com; //Object for the Comunication class.

/* setup method for the main class
 @param
 */
void setup() {
  //Use full screen size, change it to the screen size defined in the brochure.
  size(displayWidth, displayHeight, P2D);
  background(255);
  noCursor();

  //Here is where the font is deffined, if you want to change the font, you need to put a new .vlw in the data folder
  font = loadFont("ScoreBoard-300.vlw");
  textFont(font);
  textAlign(LEFT);

  maxWordsSize=300; // Change to keep more words running at the same time

  com= new Communication();
  com.start(); //start of the Communication thread
  iniciales = new ArrayList();
  words = new ArrayList();

  /*All the words from the web page's data base are added to the lines array
  */
  String linesTemp[]= loadStrings("http://cociclo.io/AgitPOV/palabras.txt");
  lines= new String[linesTemp.length];
  for (int i=0; i<linesTemp.length; i++) {
    String[] splittedLines = split(linesTemp[i], ','); 
    lines[i]=splittedLines[1];
  }

  cont=1;
  contEspera=0;
  contOpacidad=0; 
  control=false;
}

/*draw method for the main class
@param
*/
void draw() {
  background(0);
  
  //The last 30 words from the data base's array are added to the background words arraylist. A NEW WORD IS ADDED
  if (iniciales.size()< 30) {
    if (frameCount%30==0) {
      iniciales.add(new Word(lines[lines.length-cont]));
      cont++;
    }
  }
  
  /*The String arraylist of the communicaction class is compared with the words arraylist of the main class. If the last
  words of each arraylist are diferent between them, the last word of the communication class arrayList is added to the 
  main class arrayList. contEspera takes the value of zero, making a 10 seconds stop to the adding action of the random
  background words that occur every half second, this will improve the readability of the words typed by the users
  */
  if (com!=null && com.newWords!=null) {
    if (words.size()>0) {
      if (!com.newWords.get(com.newWords.size()-1).equals(words.get(words.size()-1).word)) { //compares the last word of the two arrayLists
        words.add(new Word(com.newWords.get(com.newWords.size()-1), Integer.parseInt((com.colorID.get(com.colorID.size()-1))))); //adds the last word from the communication arrayList
        contEspera=0; // the wait time is trigger.
      } else {
        if (frameCount%60==0) { //contEspera increases its value every second
          contEspera++;
          //contOpacidad++;
        }
        
        /*If the last 30 words from the data base's array were added to the background words arraylist and
        the wait time is equals or higher than 10 seconds, a word from the data base's array or from the
        typed words arrayList will be added to the background arraylist in a randomly way
        */
        if (iniciales.size()>=29 && contEspera>=10) {
          if (frameCount%30==0) { // A NEW WORD IS ADDED
              iniciales.add(new Word(lines[(int)random(0, lines.length)]));            
          }
        }
      }
    } else { // if the typed words arrayList is empty, it will add the last word in the data base's array to this arrayList.
      words.add(new Word(com.newWords.get(com.newWords.size()-1)));
    }
    
    
    if (contOpacidad>=20 ) {
      for (int i = 0; i < 20; i++) {
        if (iniciales.size()>30) {
          iniciales.get(i).opacitar();
        }
        if (words.size()>30) { //Here you can change the moment when the typed words start to decrease
          words.get(i).opacitar();
        }
      }
      contOpacidad=0;
    }
    /*Removes the first word from the background's words arraylist when the size of this arrayList 
    is higher than the maxWordSize variable
    */
    if ( iniciales.size()>= maxWordsSize) {
      iniciales.remove(iniciales.get(0));
    }
  }
  
  /*Flips all the screen laye, so the words will be directioned from left to right*/
  pushMatrix();
  translate(width, height);
  scale(-1);
  
  for (int i = 0; i < iniciales.size (); i++) { //draw the background's words arrayList objects.
    iniciales.get(i).update();
  }
  for (int i = 0; i < words.size (); i++) { //draw the typed words arrayList objects.
    words.get(i).update();
  }
  popMatrix();
}