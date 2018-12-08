using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Application as App;
using Toybox.ActivityMonitor as ActMon;
using Toybox.Timer as Timer;

class WALLEClockfaceView extends Ui.WatchFace {
        
    // globals
    var debug = false;
    var cycle = 0;
    
    // My hack thing instead of actually trying to find out dimensions of 
    // the watch I'm putting this on. Version 2.0?
    var canvas_dimensions = 240;

    // timing of the animation when the watch exits sleep, and how many animation frames
    var frame_length = 100;
    var timer1 = null;

    // sensors / status
    var battery = 0;
    var bluetooth = true;
    
    // positional offsets for items
    var current_walle_position = walle_path_squish;
    var walle_path_squish = 10;
    var walle_y = 100;
    var date_y = 200;
    var time_y = 150;
    var eve_y = 10;
    var eve_x = 140;
    var batt_y = 40;
    var batt_x = 80;
    
    // fonts
    var big_font = null;
    var smol_font = null;
    
    // images
    var background = null;
    var body = null;
    var boot = null;
    var bot_hand_grab = null;
    var bot_hand = null;
    var eyes = null;
    var happy_eyes = null;
    var step_1 = null;
    var step_2 = null;
    var step_3 = null;
    var step_4 = null;
    var step = [];
    var top_hand_grab = null;
    var top_hand = null;
    var eve = null;
    var eve_blue = null;
    var eve_noblue = null;

    // settings
    var goal = 0;
    var steps = 0;
    var stepPercent = 0;
    var animation_on = true;
    
    // time
    var hour = null;
    var minute = null;
    var day = null;
    var day_of_week = null;
    var month_str = null;
    var month = null;

    function drawWalk(dc, xpos, ypos) {
        var part_of_cycle = cycle % 4;
        switch (part_of_cycle) {
            case 0:
            dc.drawBitmap(xpos, ypos, bot_hand);
            dc.drawBitmap(xpos, ypos, body);
            dc.drawBitmap(xpos, ypos, eyes);
            dc.drawBitmap(xpos, ypos, step[0]);
            dc.drawBitmap(xpos, ypos, top_hand);
            break;
            case 1:
            dc.drawBitmap(xpos, ypos, bot_hand);
            dc.drawBitmap(xpos, ypos+1, body);
            dc.drawBitmap(xpos, ypos+1, eyes);
            dc.drawBitmap(xpos, ypos+1, step[1]);
            dc.drawBitmap(xpos, ypos, top_hand);
            break;
            case 2:
            dc.drawBitmap(xpos, ypos+1, bot_hand);
            dc.drawBitmap(xpos, ypos+1, body);
            dc.drawBitmap(xpos, ypos+1, eyes);
            dc.drawBitmap(xpos, ypos+1, step[2]);
            dc.drawBitmap(xpos, ypos+1, top_hand);
            break;
            case 3:
            dc.drawBitmap(xpos, ypos+1, bot_hand);
            dc.drawBitmap(xpos, ypos, body);
            dc.drawBitmap(xpos, ypos, eyes);
            dc.drawBitmap(xpos, ypos, step[3]);
            dc.drawBitmap(xpos, ypos+1, top_hand);
            break;
        }
        dc.drawBitmap(canvas_dimensions - walle_path_squish - 40, ypos, boot);
        if (animation_on) {
            cycle += 1;
        }
    }
    
    function drawSuccess(dc, xpos, ypos) {
        var part_of_cycle = cycle % 4;
        if (part_of_cycle < 2) {
            dc.drawBitmap(xpos, ypos, bot_hand_grab);
            dc.drawBitmap(xpos, ypos, body);
            dc.drawBitmap(xpos, ypos, happy_eyes);
            dc.drawBitmap(xpos, ypos, boot);
            dc.drawBitmap(xpos, ypos, step_1);
            dc.drawBitmap(xpos, ypos, top_hand_grab);
        } else {
            dc.drawBitmap(xpos, ypos + 2, bot_hand_grab);
            dc.drawBitmap(xpos, ypos, body);
            dc.drawBitmap(xpos, ypos, happy_eyes);
            dc.drawBitmap(xpos, ypos + 2, boot);
            dc.drawBitmap(xpos, ypos, step_1);
            dc.drawBitmap(xpos, ypos + 2, top_hand_grab);
        }
        if (animation_on) {
            cycle += 1;
        }
    }

    function drawWalle(dc) {
        if (stepPercent >= 100) {
            drawSuccess(dc, current_walle_position, walle_y);
        } else {
            drawWalk(dc, current_walle_position, walle_y);
        }
    }
    
    function drawEve(dc, blue_status, xpos, ypos) {
        dc.drawBitmap(xpos, ypos, eve);
        if (blue_status) {
            dc.drawBitmap(xpos, ypos, eve_blue);
        } else {
            dc.drawBitmap(xpos, ypos, eve_noblue);
        }
    }
        
 
    function initialize() {
        WatchFace.initialize();
         
        //creating the timers for animations
        timer1 = new Timer.Timer();

        // loading all the bitmaps and fonts
        background = Ui.loadResource(Rez.Drawables.background);
        body = Ui.loadResource(Rez.Drawables.body);
        boot = Ui.loadResource(Rez.Drawables.boot);
        bot_hand_grab = Ui.loadResource(Rez.Drawables.bot_hand_grab);
        bot_hand = Ui.loadResource(Rez.Drawables.bot_hand);
        eyes = Ui.loadResource(Rez.Drawables.eyes);
        happy_eyes = Ui.loadResource(Rez.Drawables.happy_eyes);
        step_1 = Ui.loadResource(Rez.Drawables.step_1);
        step_2 = Ui.loadResource(Rez.Drawables.step_2);
        step_3 = Ui.loadResource(Rez.Drawables.step_3);
        step_4 = Ui.loadResource(Rez.Drawables.step_4);
        step = [step_1, step_2, step_3, step_4];
        body = Ui.loadResource(Rez.Drawables.body);
        top_hand_grab = Ui.loadResource(Rez.Drawables.top_hand_grab);
        top_hand = Ui.loadResource(Rez.Drawables.top_hand);
        eve = Ui.loadResource(Rez.Drawables.eve);
        eve_blue = Ui.loadResource(Rez.Drawables.eve_blue);
        eve_noblue = Ui.loadResource(Rez.Drawables.eve_noblue);
        big_font = Ui.loadResource(Rez.Fonts.big_font);
        smol_font = Ui.loadResource(Rez.Fonts.smol_font);
    }

    // Load your resources here
    function onLayout(dc) {
  }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }

    // Update the view
    function onUpdate(dc) {
        
        // Get the time
        var clockTime = Sys.getClockTime();
        var date = Time.Gregorian.info(Time.now(),0);
        hour = clockTime.hour;
        minute = clockTime.min;
        day = date.day;
        day_of_week = Time.Gregorian.info(Time.now(), Time.FORMAT_MEDIUM).day_of_week;
        month_str = Time.Gregorian.info(Time.now(), Time.FORMAT_MEDIUM).month;
        
        // System status
        var batteryRaw = Sys.getSystemStats().battery;
        battery = batteryRaw > batteryRaw.toNumber() ? (batteryRaw + 1).toNumber() : batteryRaw.toNumber();
        var deviceSettings = Sys.getDeviceSettings();
        bluetooth = deviceSettings.phoneConnected;
        if (debug) {
            goal = 10000;
            steps = 10000;
        } else {
            var walking = ActMon.getInfo();
            steps = walking.steps;
            goal = walking.stepGoal;
        }
        stepPercent = (100*(steps.toFloat()/goal.toFloat())).toNumber();
        
        // 12-hour support
        if (hour > 12 || hour == 0) {
            if (!deviceSettings.is24Hour)
                {
                if (hour == 0)
                    {
                    hour = 12;
                    } else {
                    hour = hour - 12;
                    }
                }
        }


        // add padding to units if required
        if( minute < 10 ) {
            minute = "0" + minute;
        }

        // add leading zero for 24hr settings
        if( hour < 10 && deviceSettings.is24Hour) {
            hour = "0" + hour;
        }

        if( day < 10 ) {
            day = "0" + day;
        }
        
        // clearing the screen in preparation for image
        dc.drawBitmap(0, 0, background);
        
        // Painting all of the images
        if (stepPercent >= 100) {
            current_walle_position = canvas_dimensions - 50 - 2*walle_path_squish;
        } else {
            current_walle_position = walle_path_squish + (canvas_dimensions - 50 - walle_path_squish)*stepPercent/100;
        }
        drawWalle(dc);
        drawEve(dc, bluetooth, eve_x, eve_y);
        // drawing the battery icon
        dc.setColor(Gfx.COLOR_YELLOW, Gfx.COLOR_TRANSPARENT);
        for (var i = 0; i < (battery / 10); i += 1) {
            dc.drawRectangle(batt_x, batt_y-3*i, 20, 2);
        }
        
        // Now for all the wordage
        dc.drawText(batt_x-5, batt_y+5, smol_font, battery.format("%02d")+"%", Gfx.TEXT_JUSTIFY_LEFT);
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawText(canvas_dimensions/2, date_y, smol_font, day_of_week + " " + day + " " + month_str, Gfx.TEXT_JUSTIFY_CENTER);
        dc.drawText(canvas_dimensions/2, time_y, big_font, hour + ":" + minute, Gfx.TEXT_JUSTIFY_CENTER);
        dc.drawText(canvas_dimensions/2, walle_y-25, smol_font, steps.format("%d") + " (" + stepPercent.format("%d") + "% OF " + goal.format("%d") + ")", Gfx.TEXT_JUSTIFY_CENTER);
    }
    
    function onPartialUpdate(dc) {
        var text_size = dc.getTextDimensions(hour + ":" + minute, big_font);
        dc.setClip(canvas_dimensions/2 - text_size[0] - 2, time_y - 2, text_size[0] + 4, text_size[1] + 4);
        dc.drawText(canvas_dimensions/2, time_y, big_font, hour + ":" + minute, Gfx.TEXT_JUSTIFY_CENTER);
        dc.clearClip();
    }
        

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

    function animate() {

        Ui.requestUpdate();

        timer1 = new Timer.Timer();
        timer1.start(method(:animate), frame_length, false );
    }

    //! The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {

        // let's start our animation loop
        animation_on = true;

        timer1 = new Timer.Timer();
        timer1.start(method(:animate), frame_length, false );
    }

    //! Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
        // put everything back to how it is before animation
        animation_on = false;
        cycle = 0;
        Ui.requestUpdate();

        if (timer1) {
            timer1.stop();
        }
    }
}
