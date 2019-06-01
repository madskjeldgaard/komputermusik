(
Ndef(\gud, {|freq = 120, ps = 0.8|
	var sig, oter, mod, amp, pan, sum;
	mod = LFNoise1.kr(0.4).linlin(-1.0,1.0,400,2000);
	pan = SinOsc.kr(0.4);
	amp = SinOsc.kr(0.45).linlin(-1.0,1.0,0.0,0.2);
	sig = LPF.ar(Saw.ar(freq), mod);
	oter = PitchShift.ar(sig, pitchRatio: ps);
	sum = Splay.ar([sig+oter], 0.3, center: pan, level: amp);
	sum;
}).play
)

Ndef(\gud).free

~objSpace = OSCObjectSpace(~addrBook, oscPath:'/someObjs');
(
~objSpace.addDependant({|objectSpace, what, key, val|
	if(key == \ps, {Ndef(\gud).set(\ps, val)});
	if(key == \gudfreq, {Ndef(\gud).set(\freq, val)});
});
)


~objSpace[\freq666] = 130
~objSpace[\satandur] = 1


(
Ndef(\gud)[1000] = \pset -> Pbind(
	\dur, 0.06 + Pfunc({~objSpace[\gudDur]}),
	\ps, Pfunc({~objSpace[\gudps]}),
	\freq, Pfunc({~objSpace[\syglfo]}),
)
)


Pdef(\x, Pbind(\play, \stille, \dur, 0.4, \yessa, Pfunc({~objSpace[\andenlfo] = 1000.rand}))).play;



(
Ndef(\farlig, {arg dens = 0.2;
	var sig;
	~ge=LocalBuf(8192,2);
	~de=Dust.kr(dens)+Dust2.kr([dens*3,dens*2]);
	~re=PlayBuf.ar(2,~ge,TExpRand.kr(0.01,19,~de),~de,0,1)/4;
	FFT(~ge,~de+(~de*~re));
	sig = Splay.ar(~re.flatten);
	sig.clip2(0.99) * 0.5
}).play
)
