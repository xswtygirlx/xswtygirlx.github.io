// Copyright (c) 2015 Electric Imp
// This file is licensed under the MIT License
// http://opensource.org/licenses/MIT

// AJAX LED Example - device code

//** This code is for an anode common RGB LED
//** If you have a cathode common LED make adjustments in the setup


////////////////////////  SETUP  //////////////////////////

function flipLEDPolarity(value) {
    return math.abs(value - 255);
}

on <- 0;
off <- 1;
colorOff <- flipLEDPolarity(0);


///////////////////  DEFAULT SETTINGS  //////////////////////

red <- colorOff;
green <- colorOff;
blue <- colorOff;
state <- off;


///////////////////  CONFIGURE HARDWARE  ////////////////////

redPin <- hardware.pin1;
greenPin <- hardware.pin2;
bluePin <- hardware.pin5;

redPin.configure(PWM_OUT, 1.0/400.0, off);
greenPin.configure(PWM_OUT, 1.0/400.0, off);
bluePin.configure(PWM_OUT, 1.0/400.0, off);


////////////////////////  FUNCTIONS  ///////////////////////

function setColor(colors) {
    foreach(color, value in colors) {
        //make sure color value is integer
        if (typeof value == "string") value = value.tointeger();

        //ensure color value is in range
        if (value < 0) value = 0;
        if (value > 255) value = 255;

        //reverse polarity for my led
        value = flipLEDPolarity(value);

        //store adjusted color value in colors
        colors[color] = value;
    }

    //set color variables
    red = colors.red;
    green = colors.green;
    blue = colors.blue;

    //update LED with new color
    update();
}

function setState(newState) {
    //set state variable to new state
    if (newState == 0) {
        state = 0;
    } else {
        state = 1;
    }

    //update LED with new state
    update();
}

function update() {
    if (state == off) {
        redPin.write(off);
        greenPin.write(off);
        bluePin.write(off);
    } else {
        redPin.write(red/255.0);
        greenPin.write(green/255.0);
        bluePin.write(blue/255.0);
    }
}


////////////////////////  LISTENERS  /////////////////////

agent.on("color", setColor);
agent.on("state", setState);


/////////////////////////  RUNTIME  //////////////////////

//wait 1s so on a cold boot agent has time to come online and get settings from the server then request LED settings
imp.wakeup(1, function() {
    agent.send("getSettings", null);
})