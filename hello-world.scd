/*
    __                               __                                 _ __  
   / /______  ____ ___  ____  __  __/ /____  _________ ___  __  _______(_) /__
  / //_/ __ \/ __ `__ \/ __ \/ / / / __/ _ \/ ___/ __ `__ \/ / / / ___/ / //_/
 / ,< / /_/ / / / / / / /_/ / /_/ / /_/  __/ /  / / / / / / /_/ (__  ) / ,<   
/_/|_|\____/_/ /_/ /_/ .___/\__,_/\__/\___/_/  /_/ /_/ /_/\__,_/____/_/_/|_|  
                    /_/                                                       
( 
// DEPENDENCIES:

Quarks.install("https://github.com/madskjeldgaard/Particular.git");
Quarks.install("BenoitLib");
Quarks.install("JITLibExtensions")

)
*/
/***************** SETUP *****************/
( 
    p = Particular.new;

    // SYNTH DEFS
)
/***************** MODULATION *****************/
(
    ~mod = ();

    // FUNCTIONS
    ~mod.trigz = {|trigrate=0.90, atk=0.05, suslvl=0.0, rel=0.75, curve=0.9|
        var trigz = ( Dust.kr(trigrate * 10.0,  mul: 1.0,  add: 0.0) > 0 ); 
        var dur = 1/( trigrate * 10.0);

        EnvGen.kr(
            Env.linen(atk, suslvl, rel, 1, curve.linlin(0.0,1.0,-10.0,10.0)), 
            trigz,  
            levelScale: 1.0,  
            levelBias: 0.0,  
            timeScale: dur,  
            doneAction: 0
        );
    };

    // NDEFS
    Ndef(\svend1, ~mod[\trigz]);
    Ndef(\svend2, ~mod[\trigz]).set(\atk, 0.25, \rel, rrand(0.2,0.75));

    Ndef(\slowsvend, {
        Ndef(\svend1).kr.lag3
    });

    Ndef(\sinesvend, {|offset=0.001|
        SinOsc.kr(offset+Ndef(\slowsvend).kr.linexp(0.0,1.0,0.0001, 10.0)).linlin(-1.0,1.0,0.0,1.0)
    });

    // MAPPINGS
    Ndef(\blip1).map(\numharm, Ndef(\svend1), \freq, Ndef(\slowsvend));
    Ndef(\blip2).map(\freq, Ndef(\svend2), \numharm, Ndef(\slowsvend));

    Ndef(\svend1).map(\curve, Ndef(\sinesvend));
    Ndef(\svend2).map(\curve, Ndef(\slowsvend));
)
/***************** LYD *****************/
(
    ~lyd = ();

    // FUNCTIONS
    ~lyd.blip = {|self, freq=0.25, numharm=0.1, freqoffset=0.2|
        var minfreq=20, maxfreq=5000;
        Blip.ar(
            freqoffset.linexp(0.0,1.0,minfreq,maxfreq) + freq.linexp(0.0,1.0,minfreq,maxfreq) + [0, - 1], // [0, -1] er bare stereo effekt hehe
            numharm.linexp(0.0,1.0,1,500) - [1, 0],   // SAMME HER
            mul: 0.5,  
            add: 0.0
        ).tanh;
    };

    // NDEFS
    Ndef(\blip1, ~lyd[\blip]).mold(2, 'audio').set(\freqoffset, 0.0);
    Ndef(\blip2, ~lyd[\blip]).mold(2, 'audio');
)
/***************** PLAY *****************/
(
    Ndef(\blip1).play;
    Ndef(\blip2).play;
)
