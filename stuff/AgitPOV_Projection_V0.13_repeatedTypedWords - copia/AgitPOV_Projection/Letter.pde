/*Letter class, this class defines the atributes of the letter. Such as its position, rotation angle and
 every character that contains the typed works of the user.*/

public class Letter {
  private float posX, posY; //Coordinates
  private float angle; // Rotation angle
  private char letter; // Individual characters from the word

  /*Constructor method:
   @param: letter, the individual characters from the word
   posX, the x axis position
   posY, the y axis position
   angle, the rotation angle
   */
  public Letter(char letter, float posX, float posY, float angle) {
    this.letter= letter;
    this.angle= angle;
    this.posX= posX;
    this.posY= posY;
  }

  /*Method to apply required translate and rotation transformations to each character from the
   word.
   @param
   */
  public void display() {
    pushMatrix();
    translate(posX, posY);
    rotate(angle);
    text(letter, 0, 0);
    popMatrix();
  }
}