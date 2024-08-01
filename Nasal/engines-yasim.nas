#Initialise
var engine1 = engines.Turboprop.new(0, 0, 0);
var engine2 = engines.Turboprop.new(1, 0, 0);

engine1.init();
engine2.init();

props.globals.initNode("/sim/autostart/started", 0, "BOOL");

var eng1fuelon = func { setprop("/controls/engines/engine[0]/cutoff", 0); }
var eng2fuelon = func { setprop("/controls/engines/engine[1]/cutoff", 0); }

var eng1fueloff = func { setprop("/controls/engines/engine[0]/cutoff", 1); }
var eng2fueloff = func { setprop("/controls/engines/engine[1]/cutoff", 1); }

var eng1starter = func { setprop("/controls/engines/engine[0]/starter", 1); }
var eng2starter = func { setprop("/controls/engines/engine[1]/starter", 1); }

var eng1stop    = func { setprop("/controls/engines/engine[0]/starter", 0); }
var eng2stop    = func { setprop("/controls/engines/engine[1]/starter", 0); }

var eng1start = func {
  eng1fuelon();
  eng1starter();
  settimer(eng1fuelon, 2);
}

var eng2start = func {
  eng2fuelon();
  eng2starter();
  settimer(eng2fuelon, 2);
}

var engstart = func {
  settimer(eng1start, 2);
  setprop("/controls/engines/engine[0]/condition", 1);
  settimer(eng2start, 2);
  setprop("/controls/engines/engine[1]/condition", 1);
}

var engstop = func {
  eng1fueloff();
  eng1stop();
  setprop("/controls/engines/engine[0]/throttle", 0);
  setprop("/controls/engines/engine[0]/condition", 0);
  eng2fueloff();
  eng2stop();
  setprop("/controls/engines/engine[1]/throttle", 0);
  setprop("/controls/engines/engine[1]/condition", 0);
}

var autostart = func {
  var startstatus = getprop("/sim/autostart/started");
  if ( startstatus == 0 ) {
    gui.popupTip("Autostarting...");
    setprop("/sim/model/autostart", 1);
    setprop("/sim/autostart/started", 1);
    setprop("/controls/electric/battery-switch", 1);
    settimer(engstart, 0.4);
    gui.popupTip("Starting Engines");
  }
  if ( startstatus == 1 ) {
    gui.popupTip("Shutting Down...");
    setprop("/sim/model/autostart", 0);
    setprop("/sim/autostart/started", 0);
    setprop("/controls/electric/battery-switch", 0);
    engstop();
  }
}
