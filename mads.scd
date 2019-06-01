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
)
// -------------- SoUND processes --------------------
(
    ~bufLen = 2; // seconds
    ~bufs = 5.collect{Buffer.alloc(s, s.sampleRate * ~bufLen, 1)};
)
(
    // TODO
    Ndef(\record, { |in=0, buffer, offset=0, reclvl=1.0, prelvl=0.0, trig=0, loop=0|
        var input = SoundIn.ar(in);
        0.0*RecordBuf.ar(input.poll, buffer, offset, reclvl, prelvl,  run: trig,  loop: loop, trigger: trig,  doneAction: 0);
    });
    
)

// TODO: Buffer player ndef her!!

Ndef(\record).play;
Ndef(\record).set(\buffer, ~bufs[0], \trig, 1).play;

~bufs[0].plot;
~bufs[0].play;

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
    Ndef(\lfo0, {|f=0.1|
        var sig = SinOscFB.kr(f.linexp(0.0,1.0,0.00001,100), LFSaw.kr(Ndef(\lfo1).kr.lag * f.reciprocal));
        SendReply.kr(Impulse.kr(~sendInterval.reciprocal), '/mlfo0', sig);
    });

    OSCdef(\lfo0, {|msg, time, addr, port|
        ~objSpace[\mlfo0] = msg[3];
    }, '/mlfo0');

    // LFO1
    Ndef(\lfo1, {|f=0.25|
        var sig = SinOsc.kr(f.linexp(0.0,1.0,0.00001,100));
        SendReply.kr(Impulse.kr(~sendInterval.reciprocal), '/mlfo1', sig);
    });

    OSCdef(\lfo1, {|msg, time, addr, port|
        ~objSpace[\mlfo1] = msg[3];
    }, '/mlfo1');

    // LFO2
    Ndef(\lfo2, {|f=0.2|
        var sig = LFSaw.kr(Ndef(\lfo2).kr.lag * f.linexp(0.0,1.0,0.00001,100));
        SendReply.kr(Impulse.kr(~sendInterval.reciprocal), '/mlfo2', sig);
    });

    OSCdef(\lfo2, {|msg, time, addr, port|
        ~objSpace[\mlfo2] = msg[3];
    }, '/mlfo2');
)

s.meter;
