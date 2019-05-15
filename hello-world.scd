/*

hello world

(
// DEPENDENCIES:

Quarks.install("https://github.com/madskjeldgaard/Particular.git");
Quarks.install("BenoitLib");
Quarks.install("JITLibExtensions")
Quarks.install("https://github.com/madskjeldgaard/Else")
)
*/
/***************** SETUP *****************/
(
p = Particular.new;

// Number of speakers 
~numChannels = 2;

// BUFFERS

fork{
	var amplitudes = [0, 1, 1, -2, 1];
	var sigs = [
		Signal.chebyFill(156+1, amplitudes, normalize: true, zeroOffset: true),
		Signal.chebyFill(256+1, amplitudes, normalize: true, zeroOffset: false),
		Signal.sineFill(126+256, amplitudes.scramble, phases: [0.2,0.4,0.6,0.3,0.9]),
		Signal.chebyFill(126+1, amplitudes, normalize: true, zeroOffset: true),
		Signal.chebyFill(26+1, amplitudes.scramble, normalize: true, zeroOffset: true),
		Signal.sineFill(126+256, amplitudes.scramble, phases: [0.6,0.2,0.4,0.8,0.3]),
	];
	~bfs = sigs.collect{ arg sig; Buffer.loadCollection(s, sig.asWavetableNoWrap)
	};
};
)

/******************* SASSYS *******************/
~bfs[0].plot;
p.postEnvs;


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
Ndef(\svend2, ~mod[\trigz]).set(\atk, 0.25, \rel, rrand(0.2,0.75), \trigrate,0.1);

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
~lyd.blip = {|self, freq=0.25, numharm=0.1, freqoffset=0.2, amp=0.23|
	var minfreq=20, maxfreq=5000;
    Blip.ar(
		freqoffset.linexp(0.0,1.0,minfreq,maxfreq) + freq.linexp(0.0,1.0,minfreq,maxfreq) + [0, - 1], // [0, -1] er bare stereo effekt hehe
		numharm.linexp(0.0,1.0,1,500) - [1, 0],   // SAMME HER
		mul: amp,
		add: 0.0
	).tanh;
};

// NDEFS
Ndef(\blip1, ~lyd[\blip]).mold(2, 'audio').set(\freqoffset, 0.0);
Ndef(\blip2, ~lyd[\blip]).mold(2, 'audio');
)

/***************** PATTERNS *****************/

( 

    // PATTERN ATOMS
    Pdefn(\outseq, Pseq(~numChannels.collect{|i|i}, inf));

    // Når dette pattern er færdig...
    Pdefn(\grainseq1,
        Pn(
            Pseq([
                Pstep([p.def("m", "buf1"), p.def("revperc", "buf1")], 2, 4),
                Pxrand([p.def("quasi", "buf1"), p.def("perc", "buf1"),p.def("click", "buf1")], 90),
            ], 1),
            repeats: inf, 
            key: \grainseqdone1)
        );

    // ... aktiveres dette pattern. 
    Pdefn(\graingate1, 
        Pgate.new(
            Pwhite(0.75, 2.0),
            repeats: inf,  
            key: \grainseqdone1
        )
    );

    // PATTERNS
    Pdef(\byo,
        Pbind(
            \out, Pdefn(\outseq),
            \instrument, Pdefn(\grainseq1),
            \dur, Pkr(Ndef(\sinesvend)).linlin(-1.0,1.0,0.25,2.5) * Pwhite(0.08, 0.15),
            \sustain, Pwhite(0.0,39.0) + 3.6 + Pkey(\dur) * (Pkey(\dur)*10000).reciprocal + 0.2,
            \buffer, Pstep([~bfs[0],~bfs[2],~bfs[3],~bfs[4],~bfs[5]], 10, inf),
            \amp, Pkr(Ndef(\sinesvend)).linexp(-1.0,1.0,4.0,0.1),
            \start, Psrp(0.1).abs,
            \rate, Pdefn(\graingate1) * Pstep([0.2,0.3,0.123,0.25,0.3],4,inf)+Psrpmod(0.01, 0.6).linlin(-1.0,1.0,-0.01,0.01),
        );
    )
)
/***************** MASTERFX *****************/
(
// define which FX are going to be used.
// As MasterFX is based on ProxyChain, these FX are the same as in ProxyChain.
ProxyChain.add3(
    \leakDC,  \filter -> { |in, leak=0.99| LeakDC.ar(in, leak) },
    1,
    (\leak: [0.5, 0.999, \exp])
);    

ProxyChain.add3(
    \limiter, \filter -> { |in, drive=1, ampLimit=0.8 |
        Limiter.ar(in * drive, ampLimit);
    },
    1,
    (
        \drive: [1, 10, \exp],
        \ampLimit: \amp
    )
);

// An 8-channel MasterFX on server s.
// The order in slotNames determines order of execution of the efx.
m = MasterFX.new(server: s,
    numChannels: ~numChannels,
    slotNames: [\leakDC, \limiter],
    busIndex: 0
);

m.add(\leakDC, 1);
m.set(\leak, 0.9); // filter lows

// Limiter
m.add(\limiter, 1);  // limit output

// overdrive!!!!!!!
// m.set(\drive, 10, 0.3); 

// See all
MasterFX.all

// Clear all
// MasterFX.clear('localhost')
)
/***************** GUI *****************/
// Specs
( 
ControlSpec.specs['offset'] = ControlSpec.new(0.0, 1.0, 'lin', 0.001);
)
(
Ndef(\blip1).gui;
Ndef(\blip2).gui;
)
(
// Modulation guis
Ndef(\svend1).gui;
Ndef(\svend2).gui;
Ndef(\sinesvend).gui;
Ndef(\slowsvend).gui;
)
/***************** PLAY *****************/
(
Ndef(\blip1).play;
Ndef(\blip2).play;
)

(
Ndef(\blip1).stop;
Ndef(\blip2).stop;
)

Pdef(\byo).play;
Pdef(\byo).stop;

