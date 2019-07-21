/*

mads.scd
2019-06-01
By: Mads Kjeldgaard, mail@madskjeldgaard.dk

*/
// -------------- UTOPIA setup --------------------
( 
    ~addrBook = AddrBook.new;

    ~addrBook.addMe; // will automatically add you using your user name
    //~addrBook.addMe(\adcxyz); // or specify one

    ~hail = Hail(~addrBook);

    ~objSpace = OSCObjectSpace(~addrBook, oscPath:'/someObjs');

    // ~objSpace.addDependant({|objectSpace, what, key, val|
    //     "Got some new stuff: %, %, %".format(what, key, val).postln;
    // });

    ~chatter = Chatter(~addrBook);
)
~addrBook.names;
~chatter.send("JEG GÅR UD OG TISSER");
// -------------- SoUND processes --------------------
(
    ~bufLen = 2; // seconds
    ~bufs = 5.collect{Buffer.alloc(s, s.sampleRate * ~bufLen, 1)};
)
(
    // Buffer recorder
    SynthDef(\record, { |in=0, buffer, offset=0, mix=0.5, trig=0, loop=0|
        var input = SoundIn.ar(in);
        RecordBuf.ar(
            input, 
            buffer, 
            offset, 
            mix, 
            1-mix,  
            run: trig,  
            loop: loop, 
            trigger: trig,  
            doneAction: 2
        );
    }).add;

    ~loopfunc = {|buffer, rate=0.41, trigger=1, start=0, loop=1, amp=0.25|
        amp*PlayBuf.ar(
            1, 
            buffer, 
            rate * BufRateScale.kr(buffer), 
            trigger, 
            [0, 0.5]*BufFrames.kr(buffer), 
            loop,  
            doneAction: 0);
    };

    // Looping sampler 1
    Ndef(\looper1).source = ~loopfunc;

    // Looping sampler 2
    Ndef(\looper2).source = ~loopfunc;
    
    // Looping sampler 3
    Ndef(\looper3).source = ~loopfunc;
)
(
    // Filter looper 1 
    Ndef(\looper1)[1] = \filter -> {|in| 
        GVerb.ar(in,  roomsize: 10,  revtime: 5,  damping: 0.1,  inputbw: 0.5,  spread: 15,  drylevel: 1,  earlyreflevel: 0.7,  taillevel: 0.5,  maxroomsize: 300,  mul: 1,  add: 0)
    };

    Ndef(\looper1)[2] = \filter -> {|in| 
        in
    };

    Ndef(\looper1).mold(2, 'audio');
    Ndef(\looper1)[1000] = \filter -> {|in| LeakDC.ar(in.tanh)};

    // Filter looper 2 
    Ndef(\looper2).mold(2, 'audio');

    Ndef(\looper2)[1] = \filter -> {|in, pan=0| Pan2.ar(in.sum, pan)};

    Ndef(\looper2)[2] = \filter -> {|in| 
        // FreeVerb2.ar(in[0], in[0]);
        GVerb.ar(in + ( Ndef(\looper3)*0.1 ),  roomsize: 5,  revtime: 2,  damping: 0.5,  inputbw: 0.5,  spread: 15,  drylevel: 1,  earlyreflevel: 0.7,  taillevel: 0.5,  maxroomsize: 300,  mul: 1,  add: 0)
    };

    Ndef(\looper2)[1000] = \filter -> {|in| LeakDC.ar(in.tanh)};
)

// RECORD
Synth(\record, [\buffer, ~bufs[2], \trig, 1, \mix, 0.51]);

// Looper1
Ndef(\looper1).play;
Ndef(\looper1).fadeTime=1;
Ndef(\looper1).mold(2);
Ndef(\looper1).gui;
Ndef(\looper1).map(\rate, Ndef(\lfo2));
Ndef(\looper1).set(\buffer, ~bufs[1].bufnum, \rate, 0.5, \amp, 0.3);
Ndef(\looper1).stop;

// Looper2
Ndef(\looper2).play;
Ndef(\looper2).fadeTime=1;
Ndef(\looper2).gui;
Ndef(\looper2).map(\rate, Ndef(\lfo0));
Ndef(\looper2).set(\buffer, ~bufs[2].bufnum, \rate, (-0.435), \amp, 0.5);
Ndef(\looper2).set(\amp, 0.75, \pan, 1.0)
Ndef(\looper2).set(\trigger, 1, \loop, 0)

Ndef(\looper2)[666] = \pset -> Pbind(\pan, Pwhite(-1.0,1.0),\dur, Pwhite(0.3, 2.0), \rate, 0.425, \trigger, 1, \loop, 1);
Ndef(\looper2)[666] = nil;

Ndef(\looper2)[6] = \filter -> {|in| PitchShift.ar(in,  windowSize: 0.2,  pitchRatio: 0.5,  pitchDispersion: 0.1,  timeDispersion: 0.01,  mul: 1.0,  add: 0.0)};

// Looper3
Ndef(\looper3).play;
Ndef(\looper3).fadeTime=1;
Ndef(\looper3).gui;
Ndef(\looper3).map(\rate, Ndef(\lfo1));
Ndef(\looper3).set(\buffer, ~bufs[1].bufnum, \rate, (-0.935), \amp, 0.85);
Ndef(\looper3).set(\amp, 0.75, \pan, 0.0)
Ndef(\looper3).set(\trigger, 1, \loop, 0)

s.meter;

// Normalize
~bufs = ~bufs.collect{|b| b.normalize};

~bufs[0] = ~bufs[0].normalize;
~bufs[0].plot;
~bufs[0].play;

~bufs[0].write("~/Desktop/nm1.wav".asAbsolutePath, "wav");

(
    // WARPER
    ~warpfunc = {|buffer, rate, rand=0.1| 
        Warp1.ar(1, buffer, LFSaw.kr(rate),  freqScale: 0.5,  windowSize: 0.5,  envbufnum: -1,  overlaps: 32,  windowRandRatio: rand,  interp: 4,  mul: 1,  add: 0)
};

    Ndef(\warp1,{|buffer, rate, rand=0.1, pan=0| 
        Pan2.ar(Warp1.ar(1, buffer, LFSaw.kr(rate),  freqScale: 0.5,  windowSize: 0.5,  envbufnum: -1,  overlaps: 32,  windowRandRatio: rand,  interp: 4,  mul: 1,  add: 0), pan)
});
)

Ndef(\warp1)[1] = \filter -> {|in| in};
Ndef(\warp1).play;
Ndef(\warp1).stop;
Ndef(\warp1).mold(2, 'audio');
Ndef(\warp1).set(\buffer, ~bufs[1], \amp, 0.9, \rate, 0.05).play;
Ndef(\warp1).scope;
Ndef(\warp1).numChannels;


/*
-------------- LFO --------------------

Values of these lfos can be found in these variables:
~objSpace[\mlfo0];
~objSpace[\mlfo1];
~objSpace[\mlfo2];

*/
( 
    ~sendInterval = 0.1; // ms

    // LFO0
    Ndef(\lfo0, {|f=0.5|
        var sig = LFPar.kr(f.linexp(0.0,1.0,0.00001,100));
        SendReply.kr(Impulse.kr(~sendInterval.reciprocal), '/mlfo0', sig);
        sig;
    });

    OSCdef(\lfo0, {|msg, time, addr, port|
        ~objSpace[\mlfo0] = msg[3];
    }, '/mlfo0');

    // LFO1
    Ndef(\lfo1, {|f=0.25|
        var sig = SinOsc.kr(f.linexp(0.0,1.0,0.00001,100));
        SendReply.kr(Impulse.kr(~sendInterval.reciprocal), '/mlfo1', sig);
        sig;
    });

    OSCdef(\lfo1, {|msg, time, addr, port|
        ~objSpace[\mlfo1] = msg[3];
    }, '/mlfo1');

    // LFO2
    Ndef(\lfo2, {|f=0.9, offset=0.4|
        var sig = offset+LFSaw.kr(LFNoise2.kr * f.linexp(0.0,1.0,0.01,100));
        SendReply.kr(Impulse.kr(~sendInterval.reciprocal), '/mlfo2', sig);
        sig;
    });

    OSCdef(\lfo2, {|msg, time, addr, port|
        ~objSpace[\mlfo2] = msg[3];
    }, '/mlfo2');
)
