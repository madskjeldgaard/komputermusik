/*

// Dependencies
Quarks.install("Utopia")
Quarks.install( "https://github.com/madskjeldgaard/Particular" );
Quarks.install( "https://github.com/madskjeldgaard/ndefextensions" );
Quarks.install("https://github.com/madskjeldgaard/PolyBuf.git");

*/
(
	// Setup
	~thisdir = "/home/mads/code/sc/niklas-og-mads";
	~snddir = ~thisdir +/+ "sounds";

	s.doWhenBooted{  
		b = BufFiles(s, ~snddir) 
	};

	// Keep track of who is on the network
	~addrBook = AddrBook.new;
	~addrBook.addMe; // will automatically add you using your user name

	// Ping the network
	~hail = Hail( ~addrBook );

	// Set up chat
	~chatter = Chatter( ~addrBook );
	~chatter.send("jeg ændrede i durrrren");

	// Code sharing
	~codeRelay = CodeRelay( ~addrBook );
	~codeRelay.post = false;

	p = Particular.new;

	// Shared clock
	~clock = BeaconClock( ~addrBook );
	~clock.setGlobalTempo( 1.45 );
	~clock.startBeacons;

	// Shared data space with other players
	~objSpace = OSCObjectSpace( ~addrBook, oscPath:'/someObjs' );

	// Callback when object space is updated
	~objSpace.dependants.do{|d| ~objSpace.removeDependant(d)};
	~objSpace.addDependant({|objectSpace, what, key, val|

		// Durations
		"new dur : %\n".postf(val);
		if(key == \dur, { 
			Pdefn(\gseqdur).source = Pseq(val, inf);
			Pdefn(\granddur).source = Prand(val, inf);
			Pdefn(\gxranddur).source = Pxrand(val, inf);
		})
	});

	// Dur
	~objSpace[\dur] = ~objSpace[\dur] ?? [1];

	// Scale
	~objSpace[\scale] = ~objSpace[\scale] ?? Scale.choose.tuning_( \just );
	Pdefn( \scale, Pfunc( { ~objSpace[\scale] } ) );
)

~objSpace[\dur] = [0.5, 0.17425, Rest( 2 ), 4, 12, Rest(32),2,3,0.325, Rest(8), 0.2, 0.25].scramble;
~objSpace[\dur] = [0.5, 0.17425, Rest( 2 ), Rest(12),2,3,0.325, Rest(8), 0.2, 0.25].scramble.collect{|item| item*rrand(0.5,4.0).postln};

~objSpace[\dur] = [0.5, 0.17425, 2, 1, 3, 2, 0.75, 1].scramble;
~clock.fadeTempo(0.1, dur: 48.0, warp: 'cos', verbose: true);

// lfo
// ~objSpace[\mlfo1] = 0.5;
// ~objSpace[\mlfo2] = 0.5;
// ~objSpace[\mlfo3] = 0.5;
// ~objSpace[\mlfo4] = 0.5;
// ~objSpace[\mlfo5] = 0.5;

// durs
// ~objSpace[\mdurs1] = [1, 2, 3];
// ~objSpace[\mdurs2] = [1, 2, 3];
// ~objSpace[\mdurs3] = [1, 2, 3];

(

	e = ['perc', 'click', 'rexpodec', 'expodec'].collect{ |n| p.def(n) };

	Pdef( \a,
		Pbind(
			\instrument, Prand(e, inf),
			\octave, Pxrand((7..9),inf),
			\scale, Pdefn( \scale ),
			\dur, Prand([0.5, 2, 3,4], 38) * Pdefn(\gseqdur) / 60,
			\sustain, Pwrand.new([1,2,4], [0.8, 0.075, 0.025], inf) * Pkey(\dur) * Pn(Pseries(0.01,0.1,10), inf),
			\degree, Pwhite( 0, 10 ),
			\amp, 0.5,
			\out, Pxrand([0, 1], inf)
		)
	);

	Pdef( \b,
		Pbind(
			\instrument, p.def( 'perc' ),
			\octave, [ 2, 3 ],
			\scale, Pdefn( \scale ),
			\dur, Prand([0.5, 2, 1,1.5, Rest(4)], inf) * Pdefn(\gseqdur) / 30,
			\sustain,1, 
			\degree, 0, // Pstutter(36, Pseq([0,5,3], inf)),
			\amp, 0.075,
			\out, Pxrand([0, 1], inf)
		)
	).play(~clock);

	Pdef( \c,
		Pbind(
			\instrument, p.def('expodec', 'buf2'),
			\buffer, c,
			// \octave, Pxrand((2..6),inf),
			// \scale, Pdefn( \scale ),
			\dur, Prand([0.5, 2, 1,1.5, Rest(4)], inf) * Pdefn(\gxranddur) / 10,
			\sustain, Pwrand.new([1, 0.5, 4], [0.5, 0.3, 0.2], inf), 
			\rate, Pkey(\sustain) * Pwhite(0.5, 2.0, inf),
			// \degree, Pstutter(36, Pseq([0,5,3], inf)),
			\amp, 0.135,
			\out, Pxrand([0, 1], inf)
		)
	).play(~clock);

	Pdef( \d,
		Pbind(
			\instrument, p.def('rexpodec', 'buf1'),
			\buffer, b,
			\dur, Pwrand([1, Rest(32)], [0.9, 0.1], inf) * Pdefn(\gxranddur)/100, 
			\sustain, Pwrand.new([1, 0.5, 4], [0.5, 0.3, 0.2], inf)/3, 
			\scale, Pdefn(\scale),
			\octave, 8, 
			\degree, Pwhite(0, 7),
			\rate, Pkey(\freq).value / 440, 
			// \start, Pwhite(0.0, 0.9),
			\amp, Pwhite(0.01, 0.2),
			\out, Pxrand([0, 1], inf)
		)
	).play(~clock);
)

