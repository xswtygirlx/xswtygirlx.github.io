$(document).ready(function() {
    // This is my test setup agent url.  Update this with your agent url.
    // Your agent url can be found in the Electric Imp ide at the top of the agent codeing window.
    var agentURL = "<YOUR_AGENT_URL>";

    getState(updatePowerSetting);
    getColor(updateColorSetting);

    $('.buttons button').on('click', getStateInput);
    $('#color').on('click', getColorInput);

    function getStateInput(e){
        var state = e.currentTarget.dataset.state;
        sendState(parseInt(state));
    }

    function getColorInput(e){
        e.preventDefault();
        var colors = {};
        colors.red = checkColorInput( $('#red').val() );
        colors.green = checkColorInput( $('#green').val() );
        colors.blue = checkColorInput( $('#blue').val() );
        sendColor(colors);
        $('#color-form').trigger('reset');
    }

    function checkColorInput(input) {
        input = parseInt(input);
        if ( isNaN(input) ) {
            return 0;
        } else {
            return input;
        }
    }

    function updatePowerSetting(power) {
        if (power == 1) power = 'OFF';
        if (power == 0) power = 'ON';
        $('.power-status span').text(power);
    }

    function updateColorSetting(color) {
        $('.red').text(color.red);
        $('.green').text(color.green);
        $('.blue').text(color.blue);
    }

    function getState(callback) {
        $.ajax({
            url : agentURL + '/state',
            type: 'GET',
            success : function(response) {
                if (callback && ('state' in response)) {callback(response.state)};
            }
        });
    }

    function getColor(callback) {
        $.ajax({
            url: agentURL + '/color',
            type: 'GET',
            success : function(response) {
                if (callback && ('color' in response)) {callback(response.color)};
            }
        });
    }

    function sendState(state) {
        $.ajax({
            url : agentURL + '/state',
            type: 'POST',
            data: JSON.stringify({ 'state' : state }),
            success : function(response) {
                if ('state' in response) updatePowerSetting(response.state);
            },
            error : function(jqXHR, textStatus, err) {
                console.log(jqXHR.status + ' ' + textStatus + ': ' + err + ' - ' + jqXHR.responseText);
            }
        });
    }

    function sendColor(color) {
        $.ajax({
            url : agentURL + '/color',
            type: 'POST',
            data: JSON.stringify({ 'color' : color }),
            success : function(response) {
                if ('color' in response) updateColorSetting(response.color);
            },
            error : function(jqXHR, textStatus, err) {
                console.log(jqXHR.status + ' ' + textStatus + ': ' + err + ' - ' + jqXHR.responseText);
            }
        });
    }

})
