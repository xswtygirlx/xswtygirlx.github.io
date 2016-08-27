// Copyright (c) 2015 Electric Imp
// This file is licensed under the MIT License
// http://opensource.org/licenses/MIT

// AJAX LED Example - agent code


//////////////////////  ROCKY SETUP  //////////////////////////

#require "Rocky.class.nut:1.1.1"
app <- Rocky();


//////////////////  DEFAULT LED SETTINGS  /////////////////////

led <- {
    color = { red = 0, green = 0, blue = 0 },
    state = 1 //** If LED is cathode common this value will need to change
};


/////////////////////  AGENT DATA STORAGE  /////////////////////

//get settings stored on server
local serverSettings = server.load();

//store settings to server
function storeSettings(newSettings) {
    local err = server.save(newSettings);
    if (err == 0) {
        server.log("Settings saved");
    } else {
        server.log("Settings NOT saved. Error: " + err.tostring());
    }
}

if ("led" in serverSettings) {
    //if server has a stored LED settings then update local settings
    led = serverSettings.led;
} else {
    //else store default settings to server
    storeSettings({"led" : led});
}

//store new settings locally and on the server
function updateLEDSettings(newSettings) {
    if ("color" in newSettings) led.color = newSettings.color;
    if ("state" in newSettings) led.state = newSettings.state;
    storeSettings({"led" : led});
}


////////////////////////  FUNCTIONS  //////////////////////////

function checkColorRange(colors) {
    foreach(color, value in colors) {
        //make sure color value is integer
        if (typeof value == "string") value = value.tointeger();

        //ensure color value is in range
        if (value < 0) value = 0;
        if (value > 255) value = 255;

        //store adjusted color value in colors
        colors[color] = value;
    }
    return colors
}


/////////////////////  DEVICE LISTENER  ///////////////////////

//send device led settings
device.on("getSettings", function(dummy) {
    device.send("color", led.color);
    device.send("state", led.state);
});


//////////////////  ROCKY HTTP HANDELERS  /////////////////////

app.get("/color", function(context) {
    context.send(200, { color = led.color });
});

app.get("/state", function(context) {
    context.send(200, { state = led.state });
});

app.post("/color", function(context) {
    //convert JSON string to squirrel table
    local data = http.jsondecode(context.req.body)
    try {
        // Preflight check
        if (!("color" in data)) throw "Missing param: color";
        if (!("red" in data.color)) throw "Missing param: color.red";
        if (!("green" in data.color)) throw "Missing param: color.green";
        if (!("blue" in data.color)) throw "Missing param: color.blue";
    } catch (ex) {
        context.send(400, ex);
        return;
    }

    // if preflight check passed - do things
    local newColor = checkColorRange(data.color); //make sure colors are in range 0-255
    device.send("color", newColor); //send color to device
    updateLEDSettings({"color" : newColor}); //update local & server

    // send the response
    context.send(200, { color = data.color });

});

app.post("/state", function(context) {
    //convert JSON string to squirrel table
    local data = http.jsondecode(context.req.body)
    try {
        // Preflight check
        if (!("state" in data)) throw "Missing param: state";
    } catch (ex) {
        context.send(400, ex);
        return;
    }

    // if preflight check passed - do things
    device.send("state", data.state); //send state to device
    updateLEDSettings({"state" : data.state}); //update local & server

    // send the response
    context.send(200, { state = led.state });

});