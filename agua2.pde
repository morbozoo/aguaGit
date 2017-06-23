/**
 * oscP5sendreceive by andreas schlegel
 * example shows how to send and receive osc messages.
 * oscP5 website at http://www.sojamo.de/oscP5
 */
 
import oscP5.*;
import netP5.*;
  
OscP5 oscP5;
NetAddress jetsonLocation;
NetAddress arduinoLocation;

PImage signature;
PImage splash;
PImage spotsOn;

Button leftB   = new Button();
Button rightB  = new Button();
Button centerB = new Button();
Button onOff   = new Button();

Slider sliderBright = new Slider();
Slider sliderSpeed  = new Slider();

boolean jetsonIsOn   = false;
boolean arduinoIsOn  = false;
boolean isLoading    = false;
boolean changeIt     = false;

int startTime     = 0;
int endTime       = 0;
int preset        = (int) random(1,15);
int spots         = 0; 
int cont          = 0;

void setup() {
  fullScreen();
  frameRate(30);

  signature     = loadImage("signature.png");
  splash        = loadImage("loading.png");
  spotsOn       = loadImage("CIRCULO_ON.png");

  onOff.setImg("On-off.png");
  onOff.setPos(new PVector(40, 40));
  onOff.isOnOff = true;

  leftB = new Button();
  leftB.setImg("mood_1.png");
  leftB.setPos(new PVector(40, 120));
  leftB.setSize(200, 400);

  rightB = new Button();
  rightB.setImg("mood_2.png");
  rightB.setPos(new PVector(580, 120));
  rightB.setSize(200, 400);

  centerB = new Button();
  centerB.setImg("CIRCULO_OFF.png");
  centerB.setPos(new PVector(210, 80));
  centerB.setSize(350, 350);
  centerB.on = false;

  sliderBright.setup(new PVector(50, 500), 300, 30, "brightness.png");
  sliderSpeed.setup(new PVector(450, 500), 300, 30, "speed.png");

  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this,2345);
  
  /* myRemoteLocation is a NetAddress. a NetAddress takes 2 parameters,
   * an ip address and a port number. myRemoteLocation is used as parameter in
   * oscP5.send() when sending osc packets to another computer, device, 
   * application. usage see below. for testing purposes the listening port
   * and the port of the remote location address are the same, hence you will
   * send messages back to this sketch.
   */
  jetsonLocation  = new NetAddress("192.168.15.22",9001);
  arduinoLocation = new NetAddress("192.168.15.166",666);
}


void draw() {
  noCursor();
  background(0);  

  if (onOff.on && !isLoading) {
    if (changeIt) {
      onOff.on = false;
      changeIt = false;
    }
    image(signature, 590, 20);
    if (spots == 1) {
      image(spotsOn, 210, 80,spotsOn.width/2, spotsOn.height/2);
    }
    onOff.update();
    if (!onOff.locked) {
      onOff.draw();
    }
    leftB.draw();
    rightB.draw();
    centerB.draw();
    //sliderBright.draw();
    //sliderSpeed.draw();  
  } else{
    if (isLoading) {
      image(splash, 0, 0);
      stroke(255);
      fill(0);
      rect(200, 380, 400, 25);
      fill(255);
      rect(205, 385, ((millis() - startTime) * (390.0f/35000.0f)), 15);
      if (millis() >= endTime) {
        isLoading = false;
        onOff.on = true;
        changeIt = false;
      }
    } else{
    if (!onOff.locked) {
      onOff.draw();
    }
    onOff.update();
  }
  }
}

void mousePressed() {
  if (onOff.on) {
    if (leftB.over(new PVector(mouseX, mouseY))) {
        spots = 1;
        if (preset >= 1) {
          preset --;
        }else{
          preset = 30;
        }
        OscMessage myMessage;
        myMessage = new OscMessage("/preset");
        myMessage.add(preset);
        oscP5.send(myMessage, jetsonLocation);
        print("sent: /preset " + preset + "---JETSON");
    }
    if (rightB.over(new PVector(mouseX, mouseY))) {
      spots = 1;
      if(preset <= 29){
        preset ++;
      }else{
        preset = 1;
      }
      
      OscMessage myMessage;
      myMessage = new OscMessage("/preset");
      myMessage.add(preset);
      oscP5.send(myMessage, jetsonLocation);
      println("sent: /preset " + preset + "---JETSON");
    }
    if (centerB.over(new PVector(mouseX, mouseY))) {
      OscMessage myMessage;
      myMessage = new OscMessage("/spots");
      if (spots == 1) {
        myMessage.add(0);
        spots = 0;
      }else{
        myMessage.add(1);
        spots = 1;
      }
      oscP5.send(myMessage, jetsonLocation);
      print("sent: /spots " + spots + "---JETSON");
    }
    boolean a = onOff.over(new PVector(mouseX, mouseY));
    if (a) {
      OscMessage myMessage;
      myMessage = new OscMessage("/shutdown");
      oscP5.send(myMessage, jetsonLocation);
      print("sent: /shutdown---JETSON");
      arduinoIsOn = false;
      changeIt = true;
      spots = 0;
    }
    if (sliderBright.over(new PVector(mouseX, mouseY))) {
      OscMessage myMessage;
      myMessage = new OscMessage("/bright");
      myMessage.add(sliderBright.getValor());
      oscP5.send(myMessage, jetsonLocation);
      print("sent: /bright " + sliderBright.getValor() + "---JETSON");
    }
    if (sliderSpeed.over(new PVector(mouseX, mouseY))) {
      OscMessage myMessage;
      myMessage = new OscMessage("/hue");
      myMessage.add(sliderSpeed.getValor());
      oscP5.send(myMessage, jetsonLocation);
      print("sent: /hue " + sliderSpeed.getValor() + "---JETSON");
    }
  }else if(!isLoading){
    boolean a = onOff.over(new PVector(mouseX, mouseY));
    if (a) {
      loading();
      OscMessage myMessage;
      myMessage = new OscMessage("1");
      oscP5.send(myMessage, arduinoLocation);
      print("sent: 1 ---ARDUINO");
      arduinoIsOn = true;
      spots = 0;
    }
  }
}

void loading(){
  print("loading");
  isLoading = true;
  startTime = millis();
  endTime   = startTime + 35000;
  //endTime   = startTime + 30;
}

/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  /* print the address pattern and the typetag of the received OscMessage */
  if (theOscMessage.checkAddrPattern("/imOff")==true) {
    jetsonIsOn = false;
  }else if (theOscMessage.checkAddrPattern("/imOn")==true) {
    OscMessage myMessage;
    if (arduinoIsOn) {
      jetsonIsOn = true;
      myMessage = new OscMessage("/preset");
      myMessage.add(preset);
    }else{
      myMessage = new OscMessage("/shutdown");
      onOff.lock();
      delay(4500);
    }
    oscP5.send(myMessage, jetsonLocation);
  }else if (theOscMessage.checkAddrPattern("/preset")==true) {
    print("preset " + theOscMessage.get(0).intValue() + " ready!");
  }
  print(" addrpattern: "+theOscMessage.addrPattern());
  println(" typetag: "+theOscMessage.typetag());
}