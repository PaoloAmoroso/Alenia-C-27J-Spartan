# MAGNETIC ANOMALY DETECTOR by Paolo Amoroso

# Inizializzazione delle variabili
var detectionRange = 5000; 
# Raggio di rilevamento in metri
var detectedObjects = [];
var detectionEnabled = true;

# Funzione per rilevare oggetti magnetici
var detectMagneticObjects = func {
    var aircraftPosition = getprop("/position/position");
    var nearbyObjects = findObjectsInRange(aircraftPosition, detectionRange);
    
    foreach(obj; nearbyObjects) {
        var objectPosition = getprop(obj~"/position");
        var distance = distVincenty(aircraftPosition, objectPosition);
        if (distance < detectionRange) {
            var objectProperties = getprop(obj~"/properties");
            if (objectProperties["magnetic"]) {
                print("Oggetto magnetico rilevato a posizione:", objectPosition);
            }
        }
    }
};

# Funzione per trovare gli oggetti nell'intervallo di rilevamento
var findObjectsInRange = func(pos, range) {
    var objectsInRange = [];
    foreach(obj; getprop("/sim/objects")) {
        var objPos = getprop(obj~"/position");
        var distance = distVincenty(pos, objPos);
        if (distance < range) {
            objectsInRange.push(obj);
        }
    }
    return objectsInRange;
};

# Funzione per calcolare la distanza tra due punti sulla Terra utilizzando la formula di Vincenty
var distVincenty = func(p1, p2) {
    var a = 6378137.0; 
# Equatorial radius in meters
    var f = 1/298.257223563; 
# Flattening
    var b = (1 - f) * a; 
# Polar radius in meters
    var U1 = atan((1 - f) * tan(p1[0]));
    var U2 = atan((1 - f) * tan(p2[0]));
    var L = p2[1] - p1[1];
    var lambda = L;
    var lambdaP = 2 * pi;
    var iterLimit = 100;
    var sinU1 = sin(U1);
    var cosU1 = cos(U1);
    var sinU2 = sin(U2);
    var cosU2 = cos(U2);
    var cosLambda = 1;
    var sinLambda = 0;
    var sinSigma = 0;
    var cosSigma = 0;
    var sigma = 0;
    var sinAlpha = 0;
    var cosSqAlpha = 0;
    var cos2SigmaM = 0;
    var C;
    var dLambda;
    var sinLambdaP;
    var cosLambdaP;
    var sinSigmaP;
    var cosSigmaP;
    var sigmaP;
    while (abs(lambda - lambdaP) > 1e-12 && --iterLimit > 0) {
        sinLambda = sin(lambda);
        cosLambda = cos(lambda);
        sinSigma = sqrt(pow(cosU2 * sinLambda, 2) + pow(cosU1 * sinU2 - sinU1 * cosU2 * cosLambda, 2));
        cosSigma = sinU1 * sinU2 + cosU1 * cosU2 * cosLambda;
        sigma = atan2(sinSigma, cosSigma);
        sinAlpha = cosU1 * cosU2 * sinLambda / sinSigma;
        cosSqAlpha = 1 - pow(sinAlpha, 2);
        cos2SigmaM = cosSigma - 2 * sinU1 * sinU2 / cosSqAlpha;
        C = f / 16 * cosSqAlpha * (4 + f * (4 - 3 * cosSqAlpha));
        lambdaP = lambda;
        lambda = L + (1 - C) * f * sinAlpha * (sigma + C * sinSigma * (cos2SigmaM + C * cosSigma * (-1 + 2 * pow(cos2SigmaM, 2))));
    }
    if (iterLimit == 0) {
        print("Formula di Vincenty: limite di iterazione superato.");
        return -1;
    }
    var uSq = cosSqAlpha * (pow(a, 2) - pow(b, 2)) / pow(b, 2);
    var A = 1 + uSq / 16384 * (4096 + uSq * (-768 + uSq * (320 - 175 * uSq)));
    var B = uSq / 1024 * (256 + uSq * (-128 + uSq * (74 - 47 * uSq)));
    var deltaSigma = B * sinSigma * (cos2SigmaM + B / 4 * (cosSigma * (-1 + 2 * pow(cos2SigmaM, 2)) - B / 6 * cos2SigmaM * (-3 + 4 * pow(sinSigma, 2)) * (-3 + 4 * pow(cos2SigmaM, 2))));
    var s = b * A * (sigma - deltaSigma);
    return s;
};

# Avvio della funzione di rilevamento
detectMagneticObjects();

# Ripetere la funzione di rilevamento ogni 10 secondi
settimer(detectMagneticObjects, 10);

#Funzione per Attivare/Disattivare il Rilevamento
var toggleDetection = func(enable) {
    detectionEnabled = enable;
    if (enable) {
       print("Rilevamento delle Anomalie Magnetiche Attivato.");
    } else {
       print("Rilevamento delle Anomalie Magnetiche Disattivato.");
    }
};

# Evento con Retrazione del MAD a gestione del Tasto W
var keyEventHandler = func(event) {
    if (event == "w"){
        toggleDetection(!detectionEnabled);
    }
};

# Gestore dell'Evento "W"
setlistener("controls/keys/special", keyEventHandler); 

