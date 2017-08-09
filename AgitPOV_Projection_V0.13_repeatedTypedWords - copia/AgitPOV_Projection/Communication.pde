/*Communication class that handles the thread dedicated to add and show the new words
 typed by the user in the web page.
 */
public class Communication extends Thread {
  public ArrayList<String> newWords; //String ArrayList for the new typed words in the server.
  public ArrayList<String>colorID; // String ArrayList for the color ID of the typed words.
  int lineasTotales; // Int, control variable that defines when to seach for new words by saving the last amount of words finded

  /*Constructor method:
   @param:
   */
  public Communication() {
    newWords= new ArrayList<String>();
    colorID= new ArrayList<String>();
    initializeWordsBank();
    lineasTotales=0;
  }

  /*Run method of the thread:
   @param:
   */
  public void run() {
    while (true) {
      try {
        searchForWords();
        sleep(500);
      }
      catch(InterruptedException ie) {
        println("Error en el hilo" + ie);
      }
    }
  }

  /* This method initialize and add to the newWords arraylist the last word
   in the web pages's database. First it loads all the words in the database to 
   the "lines" array. Then the last string in this array is splitted to extract the word and
   the color ID from this initial string. finally, these values are added to the newWords and
   colorID arraylists. lineasTotales takes the length of the lines array. In this way it can be compared to know if there is a new word in the database.
   @param
   */
  public void initializeWordsBank() {
    String[] lines = loadStrings("http://cociclo.io/AgitPOV/palabras.txt");
    lineasTotales=lines.length;
    println("There are " + lines.length + " lines");

    String[] splittedLines = split(lines[lines.length-1], ',');

    if (splittedLines.length>2) {
      newWords.add(splittedLines[1]);
      colorID.add(splittedLines[2]);
    } else {
      newWords.add(splittedLines[1]);
      colorID.add("6");
    }
  }

  /*This method is called in the run of the thread, in this way the application
   search continuosly if new words were typed by the users. First it loads all the words 
   in the data base to an array, then the lineasTotales value is compared with the length of
   the lines in the data base. If lineasTotales is less than the length of whe data base's array,
   it means that a new word were typed and thus the last word and its color ID of this array will be added to the 
   typed newWords arrayList. Finally, lineasTotales takes the new length value of the data base's array.
   @param
   */
  public void searchForWords() {
    if (newWords!=null) { 
      String[] lines = loadStrings("http://cociclo.io/AgitPOV/palabras.txt");
      if (lineasTotales<lines.length) {
        String[] splittedLines = split(lines[lines.length-1], ',');
        if (splittedLines.length>2) {
          newWords.add(splittedLines[1]);
          colorID.add(splittedLines[2]);
        } else {
          newWords.add(splittedLines[1]);
          colorID.add("6");
        }
        lineasTotales=lines.length;
      }
    }
  }
}