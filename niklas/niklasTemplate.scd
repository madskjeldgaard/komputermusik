Quarks.install("https://github.com/madskjeldgaard/ndefextensions.git")
Quarks.install()

Quarks.gui // install wavesets

(
// start network and join
~win = Window("our_network").front;
~win.layout = VLayout.new.add(~listView = ListView.new);
~addrBook = AddrBook.new;
// to get updates, just add a dependant
~addrBook.addDependant({|addrBook, what, who|
	{~listView.items = addrBook.peers.collectAs({|peer|
		peer.name ++ " | " ++ peer.addr.ip ++ " | " ++ if(peer.online, "online", "offline");
	}, Array)}.defer;
});
~addrBook.addMe(\satan_pop); // or specify one
~hail = Hail(~addrBook);
)


~addrBook.names
~codeRelay = CodeRelay(~addrBook);
~codeRelay.post = false;

~chatter = Chatter(~addrBook);

~chatter.send("tuusinde");
~chatter.sendPrivate(\mads, "satans!");



(
~objSpace = OSCObjectSpace(~addrBook, oscPath:'/someObjs');
~objSpace.addDependant({|objectSpace, what, key, val|
	"New object for key %: %\n".postf(key, val);
});
// fælles objects
~objSpace[\scale] = Scale.chromatic;
~objSpace[\dur] = [1,6,3,Rest(1)];
// private objects
~objSpace[\nlfo1] = 1;
~objSpace[\nlfo2] = 1;
~objSpace[\nlfo3] = 1;
~objSpace[\nlfo4] = 1;
~objSpace[\nlfo5] = 1;
~objSpace[\ndurs1] = [1,2,3];
~objSpace[\ndurs2] = [2,3,4,Rest(2)];
~objSpace[\ndurs3] = [2,1,4,Rest(1)];
)


(
Pdefn(\scale, Plazy({ ~objSpace[\scale]}));

~objSpace.dependants.do{|d| ~objSpace.removeDependant(d)};
~objSpace.addDependant({|objectSpace, what, key, val|
	"new dur : %\n".postf(val);
	if(key == \dur,
		{
			Pdefn(\gseqdur).source = Pseq(val, inf);
			Pdefn(\granddur).source = Prand(val, inf);
			Pdefn(\gxranddur).source = Pxrand(val, inf);
	});
});
)



~clock = BeaconClock( ~addrBook );
~clock.setGlobalTempo(1.0);
~clock.startBeacons
~clock.tempo

// FÆLLES VARIABLER
~objSpace[\scale] = Scale.major.tuning_(\just);
~objSpace[\dur] = [1,3,2,4,Rest(10)];
// MINE VARIABLER

// lfoer
~objSpace[\nlfo1] = 0.5;
~objSpace[\nlfo2] = 0.5;
~objSpace[\nlfo3] = 0.5;
~objSpace[\nlfo4] = 0.5;
~objSpace[\nlfo5] = 0.5;

// durs
~objSpace[\ndurs1] = [0.2, 0.4, 0.8];
~objSpace[\ndurs2] = [1,2,3];
~objSpace[\ndurs3] = [1,2,3];



(
Pdef(\mythsa,
	Pbind(
		\dur, Pseq(~objSpace[\ndurs1], inf)*Psine(0.4).linlin(-1.0,1.0,0.2,3.0),
		\degree, Pxrand([1,2,3,4,5,6,7,8,9,10,11,12], inf),
		\scale, ~objSpace[\scale]
	);
).play(~clock, quant: 1)
)
Pdef(\mythsa).stop

// cleaup allls
Pdef.all.clear


//beginnings dark 80ies
Salk.loadFolders("/home/na/Desktop/forSalk/YAMAHA");
(
Salk.p(\lay,
	tempo: ~clock,
	tuningOnOff: 1,
	fftOnOff: 0,
	out: 0,
	dur: Pdefn(\gseqdur),
	stretch: 1.0,//Pstep([1.0,2.0,3.0], 12, inf),
	folder: Pseq([\tg500_fx], inf),
	index: Pseq([1,2,3,5,6,7,8,9,10,11,12,13], inf),
	rate: Pwhite(0.98,1.0)*Pstep([0.4,0.9,0.2], 3, inf),
	cutoff: 2900,
	degree: Pstep([1,3,5], 3, inf),
	octave: Pxrand([2], inf),
	root: 0,
	scale: ~objSpace[\scale],
	attack: 0.01,
	decay: 0.8,
	sustain: 1.0,
	release: 8.2,
	pan: Pwhite(-0.9,0.9),
	amp: 0.5,
	binRange: Pfunc({[Salk.buckets(frame: ~frame, numBands: 20, band: 20.linrand)]})
);
)
// slay
Salk.s(\lay)

//more
(
Salk.p(\lott,
	tempo: ~clock,
	tuningOnOff: 1,
	fftOnOff: 0,
	out: 0,
	dur: Pdefn(\gseqdur)/10,
	stretch: 1.0,//Pstep([1.0,2.0,3.0], 12, inf),
	folder: Pseq([\tg500_fx], inf),
	index: Pxrand([2], inf),
	//index: Pxrand([40,41,42,43,44,46,47,48,49], inf),
	degree: Pstep([0], 3, inf),
	octave: Pxrand([3], inf),
	cutoff: 3000,
	root: 0,
	scale: ~objSpace[\scale],
	attack: 0.01,
	decay: 0.01,
	sustain: Pwhite(0.01,0.3),
	release: 0.01,
	pan: Pwhite(-0.9,0.9),
	amp: 0.5,
	binRange: Pfunc({[Salk.buckets(frame: ~frame, numBands: 20, band: 20.linrand)]})
);
)
// slay
Salk.s(\lott)



//// OOOTHERERERERE

Salk.loadFolders("/home/na/Desktop/forSalk/ball");
Salk.folders
(
Salk.p(\oth,
	tempo: ~clock,
	tuningOnOff: 1,
	fftOnOff: 1,
	out: 0,
	dur: Pdefn(\gseqdur)/Pstep([1,3], 64, inf),
	stretch: 1.0,//Pstep([1.0,2.0,3.0], 12, inf),
	folder: Pseq([\proc], inf),
	index: Pxrand([1], inf),
	pos: Pxrand([0.75,0.78,0.43], inf),//Pwhite(0.0,0.99),
	degree: Pstep([0,5,8], 3, inf),
	octave: Pxrand([2,3], inf),
	cutoff: 22000,
	root: 0,
	scale: ~objSpace[\scale],
	attack: 1.81,
	decay: 0.2,
	sustain: 1.0,
	release: 2.1,
	pan: Pwhite(-0.9,0.9),
	amp: 2.79,
	binRange: Pfunc({[Salk.buckets(frame: ~frame, numBands: 20, band: 20.linrand)]})
);
)
// slay
Salk.s(\oth)

(
Salk.p(\snapper,
	tempo: ~clock,
	tuningOnOff: 0,
	fftOnOff: 0,
	out: 0,
	dur: Pdefn(\gseqdur)/Pstep([15,25], 64, inf),
	stretch: 1.0,//Pstep([1.0,2.0,3.0], 12, inf),
	folder: Pseq([\proc], inf),
	index: Pxrand([7], inf),
	pos: Pseq((0..100)/100, inf),
	rate: 1.0,
	cutoff: 22000,
	attack: 0.01,
	decay: 0.2,
	sustain: 0.3,
	release: 0.1,
	pan: Pwhite(-0.9,0.9),
	amp: 1.99,
	binRange: Pfunc({[Salk.buckets(frame: ~frame, numBands: 20, band: 20.linrand)]})
);
)
// slay
Salk.s(\snapper)

(
Salk.p(\tumpo,
	tempo: ~clock,
	tuningOnOff: 0,
	fftOnOff: 0,
	out: 0,
	dur: Pdefn(\gseqdur)/Pstep([1,3], 64, inf),
	stretch: 1.0,//Pstep([1.0,2.0,3.0], 12, inf),
	folder: Pseq([\proc], inf),
	index: Pxrand([1], inf),
	pos: Pseq((0..100)/100, inf),
	rate: 9.8,
	cutoff: 22000,
	attack: 0.01,
	decay: 0.2,
	sustain: 0.01,
	release: 0.01,
	pan: Pwhite(-0.9,0.9),
	amp: 0.3,
	binRange: Pfunc({[Salk.buckets(frame: ~frame, numBands: 20, band: 20.linrand)]})
);
)
// slay
Salk.s(\tumpo)

(
Salk.p(\hat,
	tempo: ~clock,
	tuningOnOff: 0,
	fftOnOff: 0,
	out: 0,
	dur: 0.5,
	stretch: 1.0,//Pstep([1.0,2.0,3.0], 12, inf),
	folder: Pseq([\all], inf),
	index: Pxrand([1], inf),
	pos: 0.8,//Pseq((0..100)/100, inf),
	rate: 8.8,
	cutoff: 22000,
	attack: 0.01,
	decay: 0.2,
	sustain: 0.01,
	release: 0.11,
	pan: Pwhite(-0.9,0.9),
	amp: 1.8,
	binRange: Pfunc({[Salk.buckets(frame: ~frame, numBands: 20, band: 20.linrand)]})
);
)
// slay
Salk.s(\hat)



(
Salk.p(\oth,
	tempo: ~clock,
	tuningOnOff: 1,
	fftOnOff: 0,
	out: 0,
	dur: Pdefn(\gseqdur)/Pstep([9,12], 64, inf),
	stretch: Pstep([0.5,1.0,2.0,7.0], 3, inf)*3,
	folder: Pseq([\proc], inf),
	index: Pxrand([2], inf),
	pos: Pxrand([0.75,0.78,0.43], inf),//Pwhite(0.0,0.99),
	degree: Pstep([0], 3, inf),
	octave: Pstep([2], 3, inf),
	cutoff: Pwhite(3000,18000),
	root: 0,
	scale: ~objSpace[\scale],
	attack: 0.01,
	decay: 0.2,
	sustain: 0.3,
	release: 0.01,
	pan: Pwhite(-0.9,0.9),
	amp: 1.79,
	binRange: Pfunc({[Salk.buckets(frame: ~frame, numBands: 20, band: 20.linrand)]})
);
)
// slay
Salk.s(\oth)



////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
// other beeegiiin, mads kan godt lide, mis mis
Salk.loadFolders("/home/na/Desktop/forSalk/ball");
(
Salk.p(\nammi,
	tempo: ~clock,
	tuningOnOff: 1,
	fftOnOff: 0,
	out: 0,
	dur: 0.2,//Pdefn(\gseqdur)/Pstep([9,12], 64, inf),
	stretch: 1.0,//Pstep([0.5,1.0,2.0,7.0], 3, inf)*3,
	folder: Pseq([\proc], inf),
	index: Pxrand([3], inf),
	pos: Pseq((0..100)/100, inf),
	degree: Pstep([0], 3, inf),
	octave: Pstep([6], 3, inf),
	cutoff: Pwhite(3000,18000),
	root: 0,
	scale: ~objSpace[\scale],
	attack: 0.01,
	decay: 0.02,
	sustain: 0.5,
	release: 0.04,
	pan: Pwhite(-0.9,0.9),
	amp: 3.50,
	binRange: Pfunc({[Salk.buckets(frame: ~frame, numBands: 20, band: 20.linrand)]})
);
)
// slay
Salk.s(\nammi)
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
(
Salk.p(\yutr,
	tempo: ~clock,
	tuningOnOff: 1,
	fftOnOff: 0,
	out: 0,
	dur: 0.4,//Pdefn(\gseqdur)/Pstep([9,12], 64, inf),
	stretch: 1.0,//Pstep([0.5,1.0,2.0,7.0], 3, inf)*3,
	folder: Pseq([\proc], inf),
	index: Pxrand([7], inf),
	pos: Pseq((0..100)/100, inf),
	degree: Pstep([0], 3, inf),
	octave: Pstep([6], 3, inf),
	cutoff: Pwhite(3000,18000),
	root: 0,
	scale: ~objSpace[\scale],
	attack: 0.01,
	decay: 0.02,
	sustain: 1.0,
	release: 0.04,
	pan: Pwhite(-0.9,0.9),
	amp: 4.50,
	binRange: Pfunc({[Salk.buckets(frame: ~frame, numBands: 20, band: 20.linrand)]})
);
)
// slay
Salk.s(\yutr)

~objSpace[\dur]
(
Salk.p(\krosant,
	tempo: ~clock,
	tuningOnOff: 1,
	fftOnOff: 1,
	out: 0,
	dur: Pdefn(\gseqdur)/Pstep([9,10], 64, inf),
	stretch: 1.0,//Pstep([0.5,1.0,2.0,7.0], 3, inf)*3,
	folder: Pseq([\all], inf),
	index: 8,
	pos: Psine(0.1).linlin(-1.0,1.0,0.0,1.0),//Pseq((0..100)/100, inf),
	degree: Pstep([0], 3, inf),
	octave: Pstep([6], 3, inf),
	root: 0,
	scale: ~objSpace[\scale],
	attack: 2.31,
	decay: 0.2,
	sustain: 1.0,
	release: 1.74,
	pan: Pwhite(-0.9,0.9),
	amp: 3.50,
	binRange: Pfunc({[Salk.buckets(frame: ~frame, numBands: 20, band: 20.linrand)]})
);
)
// slay
Salk.s(\krosant)

(
Salk.p(\pedern,
	tempo: ~clock,
	tuningOnOff: 1,
	fftOnOff: 1,
	out: 0,
	dur: Pdefn(\gseqdur)/Pstep([9,12], 64, inf),
	stretch: 1.0,//Pstep([0.5,1.0,2.0,7.0], 3, inf)*3,
	folder: Pseq([\all], inf),
	index: Pxrand([6], inf),
	pos: Pseq((0..100)/100, inf),
	degree: Pstep([0,6,3], 3, inf),
	octave: Pstep([6,5], 3, inf),
	cutoff: Pwhite(3000,18000),
	root: 0,
	scale: ~objSpace[\scale],
	attack: 0.01,
	decay: 0.02,
	sustain: 1.0,
	release: 0.4,
	pan: Pwhite(-0.9,0.9),
	amp: 1.30,
	binRange: Pfunc({[Salk.buckets(frame: ~frame, numBands: 20, band: 20.linrand)]})
);
)
// slay
Salk.s(\pedern)









~clock.setGlobalTempo(2.0);

Salk.folders

/////// ryyth
(
Salk.p(\rumss,
	tempo: ~clock,
	//tuningOnOff: 0,
	out: 0,
	dur: Pseq([1,2,3], inf)+Pwhite(-0.03, 0.03),
	stretch: 1.0,
	folder: Pseq([\tg500_drum, \tg500_fx], inf),
	index: Pseq([3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,2,5,1], inf),
	rate: 0.05*Pseq([1,2,2,2,2,3], inf),
	cutoff: Pwhite(100,14e3),
	attack: 0.01,
	decay: 0.08,
	bass: 0.5,
	sustain: 1.0,
	release: 5.2,
	pan: Pwhite(-0.9,0.9),
	amp: 0.29,
	binRange: Pfunc({[Salk.buckets(frame: ~frame, numBands: 20, band: 20.linrand)]})
);
)
Salk.s(\rumss)