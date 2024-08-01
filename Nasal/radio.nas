print("*** LOADING radio.nas ... ***");

var init_Transpondeur = func() {
  # Init Transponder
  var poweroften = [1, 10, 100, 1000];
  var idcode = getprop('/instrumentation/transponder/id-code');
  setprop("/instrumentation/transponder/inputs/mode",0);
   
  if(idcode != nil) {
    for(var i = 0 ; i < 4 ; i += 1) {
      setprop("/instrumentation/transponder/inputs/digit[" ~ i ~ "]", int(math.mod(idcode / poweroften[i], 10)));
    }
  }
}

var adf = func() {
  # adf Split Freq
  var poweroften = [1, 10, 100, 1000];
  var idcode = getprop('/instrumentation/adf/frequencies/selected-khz');
    
  if(idcode != nil) {
    for(var i = 0 ; i < 4 ; i += 1) {
      setprop("/instrumentation/adf/frequencies/digit[" ~ i ~ "]", int(math.mod(idcode / poweroften[i], 10)));
    }
  }
}

radio_loop = func(){
  if(getprop("/instrumentation/transponder/inputs/mode")==5){
    var alt = getprop("/instrumentation/altimeter/indicated-altitude-ft");
    setprop("/instrumentation/transponder/altitude",alt);
  }else{
    setprop("/instrumentation/transponder/altitude",-9999);
  }
  adf();
  settimer(radio_loop,0.5);
}

set_adf = func(){

  var adf = getprop("/instrumentation/adf/frequencies/digit[3]");
  adf = adf~ getprop("/instrumentation/adf/frequencies/digit[2]");
  adf = adf~ getprop("/instrumentation/adf/frequencies/digit[1]");
  adf = adf~ getprop("/instrumentation/adf/frequencies/digit[0]");
  #print("adf:"~adf);
  
  setprop("/instrumentation/adf/frequencies/selected-khz",adf);
}

print("Transponder ... Check");
settimer(init_Transpondeur, 4.0);

print("adf ... Check");
settimer(adf, 4.0);

settimer(radio_loop, 4.0);
