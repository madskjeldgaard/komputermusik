
/ ********* setup **************/
(
//~addrBook.addMe; // def user name
~addrBook.addMe(\niklas); // bestem selv
~hail = Hail(~addrBook);
)

~addrBook.names;


~objSpace = OSCObjectSpace(~addrBook, oscPath:'/someObjs');


(
    ~matchfunc = {|key, val|
        var paramkey;
        case
        {key.asString.beginsWith("n0_")} {
            paramkey = key.asString[3..].asSymbol;

            Ndef(\n0).set(paramkey, val)
        }
        {key.asString.beginsWith("n1_")} {
            paramkey = key.asString[3..].asSymbol;

            Ndef(\n1).set(paramkey, val)

        }
        {key.asString.beginsWith("n2_")} {
            paramkey = key.asString[3..].asSymbol;

            Ndef(\n2).set(paramkey, val)

        };
    };
)



(
~objSpace.addDependant({|objectSpace, what, key, val|
	~matchfunc.value(key, val);
});
)







/ ********* ndefs **************/


(
Ndef(\gst).fadeTime_(0.1);
Ndef(\gst, {arg p0 = 0.89, p1 = 0.01;
	var sig, sum, res, freq;
	res = 2*p0;
	freq = 1e3*p1;
	sig = LPF18.ar(DPW4Saw.ar(LFNoise0.ar(0.1 * Ndef(\gst).ar)), 0.1 % Ndef(\gst).ar, res);
	sum = Limiter.ar(SinOsc.ar([sig%freq,sig%freq]/sig),0.2);
	LeakDC.ar(Splay.ar(sum.flatten).clip2(0.99));
}).mold(2, 'audio').play
)

Ndef(\gst)[1] = \filter -> {|in| PitchShift.ar(in, pitchRatio: 3)}






(
Ndef(\n0, {|p0 = 1.0, p1 = 0.1, p2 = 0.5, p3 = 0.6|
	var sig, oter, amp, pan, sum;
	pan = SinOsc.kr(0.4);
	amp = SinOsc.kr(0.45).linlin(-1.0,1.0,0.0,0.2);
	sig = LPF.ar(Saw.ar(p1.linexp(0.0,1.0,40,4500)), p0.linlin(0.0,1.0,500,7000).lag(0.01));
	oter = PitchShift.ar(sig, pitchRatio: p2);
	sum = Splay.ar([sig+oter], 0.3, center: pan, level: amp);
	LeakDC.ar(sum)
}).play
)

Ndef(\n0).stop


(
Ndef(\n1, {|p0 = 0.3, p1 = 0.5, p2 = 0.5, p3 = 0.6|
	var sig, lbuf, dusts, player, dens = 3;
	lbuf=LocalBuf(8192,2);
	dusts=Dust.kr(dens*p0)+Dust2.kr([dens*p0*3,dens*p0*2]);
	player=PlayBuf.ar(2,lbuf,TExpRand.kr(0.01,0.02+19*p2,dusts),dusts,0,1)/4;
	FFT(lbuf,PitchShift.ar(dusts+(dusts*player), pitchRatio: p1));
	sig = Splay.ar(player.flatten);
	sig = sig.clip2(0.99) * 0.5;
	LeakDC.ar(sig);
}).play
)

Ndef(\n1).stop

/************ control af mads ******************/
(
Pdef(\nuller, Pbind(\play, \zzz,
	\dur, Pseq([0.3], inf),
	\yday, Pfunc({~objSpace[\m0_freq] = 0.7}),
	\y, Pfunc({~objSpace[\m0_amp] = 0.4}),
	\p0, Pfunc({~objSpace[\m0_p0] = 0.2}),
	\p1, Pfunc({~objSpace[\m0_p1] = 0.2}),
	\p2, Pfunc({~objSpace[\m0_p2] = 0.8})
)).play
)


