/* AgitPOV 2017_08_06
 
 BUG FIXES AND NEW VERSION :
 Thomas O Fredericks
 
 PREVIOUS VERSION :
 Mariangela Aponte
 Kammil Carranza
 Daniela Delgado
 Sebastián Vásquez
 
 */


// CONFIGURATION
int maxWordsDisplayed = 10; // maximum words on the screen per layer (background and foreground)

int maxDisplayedWordLifeTime = 30000; // how long the word stays on screen
boolean fadeDisplayedWordDuringLifetime = true; // fade the word during its whole lifetime instead of triggering it at its end

int displayAnOldWordInterval = 999; // the interval for displaying an old word
float probabilityOfLast20OldWords = 0.25; // between 0 and 1 : probability of selecting one the latest 20 new words instead of any of the last words

int timeToKeepNewWords = 30000; // how long before a new word becomes and old word
int maximumNumberOfNewWords = 30; // if there is more new words than this they become old words

int displayANewWordInterval = 1023; // the interval for displaying a new word

int networkFetchingSleep = 3000; // sleep interval between fetching data on the server... this should maybe be a Websocket because the list will become big very quickly

String fontName = "scoreboard.ttf"; //"ScoreBoard-128.vlw"; THOMAS SAYS : DO NOT USE VLW!!!!

boolean debugDisplayedWordCreation = false;
boolean debugWordManagement = false;



/*Imported class to implement the thread object
 */
import java.io.*;

//ArrayList <Word> iniciales; //Word ArrayList, for the background words from the data base.
ArrayList <Word> foregroundWords; //Word ArrayList, for the typed words.
ArrayList <Word> backgroundWords; //Word ArrayList, for the typed words.

ArrayList <String> oldWords; // arrayList to save the data base's words.
int cont, contEspera, contOpacidad; //Control counters to add the last words from the data base, define a time interval to add words to the background words and start to decrease the opacity of each word
boolean control;
PFont font; // PFont, creates the font to be used.


public Communication com; //Object for the Comunication class.


long lastTimeANewBackgroundWordWasCreated = 0; 

long lastTimeAnOnlineWordWasCreated = 0; 


int lastTimeANewWordWasSentToOldWords;


/* setup method for the main class
 @param
 */
void setup() {
  //Use full screen size, change it to the screen size defined in the brochure.
  size(displayWidth, displayHeight, P3D);
  //size(640, 480, P3D);
  //fullScreen(P3D);
  background(255);
  noCursor();

     font = createFont(fontName,128);
    textFont(font);

    textAlign(LEFT);

  //maxWordsSize=50; // Change to keep more words running at the same time

  com= new Communication();
  com.start(); //start of the Communication thread
  //iniciales = new ArrayList();
  foregroundWords = new ArrayList();
  backgroundWords = new ArrayList();

  /*All the words from the web page's data base are added to the lines array
   */
  /*
  String linesTemp[]= loadStrings("http://cociclo.io/AgitPOV/palabras.txt");
   oldWords= new String[linesTemp.length];
   for (int i=0; i<linesTemp.length; i++) {
   String[] splittedLines = split(linesTemp[i], ','); 
   oldWords[i]=splittedLines[1];
   }
   */
  oldWords = new ArrayList();

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

  // COMMENTED BECAUSE THIS DOES NOT MAKE SENSE TO THOMAS
  //The last 30 words from the data base's array are added to the background words arraylist.
  /*
  if (iniciales.size()< 30) {
   if (frameCount%30==0) {
   iniciales.add(new Word(lines[lines.length-cont]));
   cont++;
   }
   }
   */
   
 while (  backgroundWords.size() > maxWordsDisplayed ) {
   backgroundWords.remove(0);
 }
 
  while (  foregroundWords.size() > maxWordsDisplayed ) {
   foregroundWords.remove(0);
 }
 
 
 
  while ( com.newWords.size() > maximumNumberOfNewWords ) {
    moveNewToOld();
  }

  // Move new words to old words if they expired but never faster than every 5 seconds
  if ( com.newWords.size() > 0 && millis() - lastTimeANewWordWasSentToOldWords > 5000 ) {
    if ( millis() - com.foundTime.get(0) >= timeToKeepNewWords ) {
      moveNewToOld();
      lastTimeANewWordWasSentToOldWords = millis();
    }
  }

  // ADD BACKGROUND WORDS
  
  if ( millis() - lastTimeANewBackgroundWordWasCreated > displayAnOldWordInterval && oldWords.size() > 0 ) {
    lastTimeANewBackgroundWordWasCreated = millis();
    int index;
    if ( random(1) > probabilityOfLast20OldWords ) {
      // One of the last 20 words
      index = oldWords.size() - 1 - floor((random(1) * min(oldWords.size(), 20))) ; // floor((random(0.25 ) + 0.75) * oldWords.size() ); 
      if ( debugDisplayedWordCreation ) print("Displaying old word ");
    } else {
      // Any word
      index = floor(random(1) * oldWords.size() ); 
      if ( debugDisplayedWordCreation ) print("Displaying really old word ");
    }
    String text = oldWords.get(index); // String text = oldWords.get(oldWords.size()-oldWordIndex-1);

    backgroundWords.add(new Word(text));

    if ( debugDisplayedWordCreation ) println(text);
  }

  // ADD NEW WORDS FOUND ONLINE
  if ( millis() - lastTimeAnOnlineWordWasCreated > displayANewWordInterval  && com.newWords.size() > 0) {
    lastTimeAnOnlineWordWasCreated = millis();
    int index = floor(random(1) * com.newWords.size() );
    String text = com.newWords.get(index);
    int colorID = com.colorID.get(index);
    if ( debugDisplayedWordCreation ) println("Displaying new word "+text+" of color "+colorID);
    foregroundWords.add(new Word(text, colorID));
  }


  /*Flips all the screen laye, so the words will be directioned from left to right*/
  pushMatrix();
  translate(width, height);
  scale(-1);


  for (int i = backgroundWords.size() -1; i >= 0; i--) { //draw the typed words arrayList objects.
    if (  backgroundWords.get(i).opacity == 0 ) backgroundWords.remove(i);
    else backgroundWords.get(i).update();
  }

  for (int i =  foregroundWords.size() -1; i >= 0; i--) { //draw the typed words arrayList objects.
    if (  foregroundWords.get(i).opacity == 0 ) foregroundWords.remove(i);
    else foregroundWords.get(i).update();
  }

  popMatrix();
  
  if  (frameCount % 1000 == 0 ) {
    // The amount of memory allocated so far (usually the -Xms setting)
long allocated = Runtime.getRuntime().totalMemory();

// Free memory out of the amount allocated (value above minus used)
long free = Runtime.getRuntime().freeMemory();

// The maximum amount of memory that can eventually be consumed
// by this application. This is the value set by the Preferences
// dialog box to increase the memory settings for an application.
long maximum = Runtime.getRuntime().maxMemory();
   println("Memory: "+allocated+" " +free+" " +maximum);
   println("Free/Allocated: "+free/(float)allocated);
   println("Free/Maximum: "+free/(float)maximum);
   println("Allocated/Maximum: "+allocated/(float)maximum); 
  }
  
}

void moveNewToOld() {
  oldWords.add(com.newWords.get(0));
  if ( debugWordManagement ) println("Moving new word "+com.newWords.get(0)+" to old words");
  com.newWords.remove(0);
  com.colorID.remove(0);
  com.foundTime.remove(0);
}