Platform.userExtensionDir
s.options.memSize_(32768*2)


/ ***************************** /
/ ********* setup ************* /
/ ***************************** /

~addrBook = AddrBook.new;

(
//~addrBook.addMe; // def user name
~addrBook.addMe(\niklas); // bestem selv
~hail = Hail(~addrBook);
)

~addrBook.names;

~chatter = Chatter(~addrBook)
~chatter.send("online")
~chatter.send("ja")
~chatter.send("nej")

~objSpace = OSCObjectSpace(~addrBook, oscPath:'/someObjs');


/ ****************************************** /
/ ********* lfos && sendReplys **************/
/ ****************************************** /


~objSpace[\degSeq] = [4,8];
~objSpace[\degSeq]

(
Event.addEventType(\indover, { |server|
	~degree = Pseq(~objSpace[\degSeq], inf);
	~type = \note; // now set type to note
    currentEnvironment.play;
})
)



.addDependant
~lolz = 1


(
//~degree = PatternProxy(Pn(~objSpace[\degSeq], inf));
//~dur = PatternProxy(Pn(0.25, inf));

p = Pbind(
    \degree, ~degree,
    \dur, ~dur
).play;
)



~dur.source = Pwrand(#[0.25, 0.5, 0.75], #[0.5, 0.3, 0.2], inf);

p.stop;





~objSpace = OSCObjectSpace(~addrBook, oscPath:'/someObjs');

~objSpace[\degSeq] = [4,8];
(
Event.addEventType(\indover, { |envir|
    ~degree.source = ~objSpace[\degSeq];
    //~type = \note; // now set type to a different one
    //currentEnvironment.play;
});
)

(
Pbind(
	\type, \indover,
	\degree, ~degree,
	\dur, Pwhite(0.1, 1.0, inf)
).play;
)








(
Pdef(\yessa, {|envir|
	Pbind(
		\type, \indover,
		\dur, 1,
		//\degree, Pseq(envir.deg, inf)
	)
}).play
)






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





/ ****************************** /
/ ********** ndefs ************* /
/ ****************************** /


(
Ndef(\a).fadeTime_(0.1);
Ndef(\a, {arg p0 = 0.69, p1 = 0.1;
	var sig, sum, res, freq;
	res = 2*p0;
	freq = 1e3*p1;
	sig = LPF18.ar(DPW4Saw.ar(LFNoise0.ar(0.1 * Ndef(\a).ar)), 0.1 % Ndef(\a).ar, res);
	sum = Limiter.ar(SinOsc.ar([sig%freq,sig%freq/pi]/sig),0.2);
	LeakDC.ar(Splay.ar(sum.flatten).clip2(0.99));
}).mold(2, 'audio').play
)

Ndef(\a)[1] = \filter -> {|in| PitchShift.ar(in, pitchRatio: 1.2)}
Ndef(\a)[2] = \filter -> {|in| in;}


Ndef(\a).set(\p0, 0.45, \p1, 0.7)
Ndef(\a).stop

// klassik sheit
(
Ndef(\c, {
	var sig, slider, dusts;
	t=1.2;
	d=LFDNoise0.kr(1).range(6,12);
	f=t*9999*d*LFDNoise3.kr(2);
	dusts = Dust.ar(t);
	k=SinGrain.ar([dusts,dusts],d,f).sum;

	sig=PitchShift.ar(k, 0.2, Ndef(\c).ar.linlin(-1.0,1.0,0.200,0.205));

	slider = EnvGen.kr(Env.asr, dusts);

	sig = PitchShift.ar(sig, 0.2, slider.linlin(0.0,1.0,0.5,2).poll);
	sig = sig * 0.4; // degain before stuffs
	sig = CombL.ar(sig, 0.8, 0.8, 10.0, 0.8);
	Splay.ar(LeakDC.ar(sig.clip2(1.0))) //potent sheis
}).play
)
Ndef(\c).fadeTime_(22)
Ndef(\c).stop


(
Ndef(\d, {
	var sig;
	t=(1..5);
	d=LFDNoise0.kr(1).range(0.01,0.8);
	f=t*9999*d*LFDNoise3.kr(2);
	e=t/20; // trigg 'slap af' faktor
	k=SinGrain.ar([Dust.ar(e),Dust.ar(e)],d,f).sum;
	k=PitchShift.ar(k, 0.5, Ndef(\d).ar.linlin(-1.0,1.0,0.5,12.5));
	sig=Squiz.ar(k!2,2.0,1,0.1).flatten * 0.25; // potent sheis
	Splay.ar(LeakDC.ar(sig.clip2(1.0))) * 0.95 // potent sheis
}).play
)

Ndef(\d).stop

// crushed r2d2
(
Ndef(\e, {|sineMaxDur = 1.5, pshiftlow = 0.01, pshifthigh = 7.5, dens = 0.3|
	var sig, lbuf, dusts, player, sines, sineDur;
	lbuf=LocalBuf(8192,2);
	dusts=Dust.kr(dens)+Dust2.kr([dens,dens*1.5]);
	player=PlayBuf.ar(2,lbuf,TExpRand.kr(0.01,0.02+19,dusts),dusts,0,1)/4;

	sineDur=LFDNoise0.kr(1).range(0.01,sineMaxDur);
	t=(1..5);
	f=t*9999*sineDur*LFDNoise3.kr(0.4);
	sines = SinGrain.ar(dusts,sineDur,f).sum;
	sines = PitchShift.ar(sines, 0.5, Ndef(\e).ar.linlin(-1.0,1.0,pshiftlow,pshifthigh));
	sines=Squiz.ar(sines!2,0.3,1,0.1).flatten * 0.45; // potent sheis

	FFT(lbuf,
		sines+PitchShift.ar(
			dusts+(dusts*player),
			0.5,
			Ndef(\e).ar.linlin(-1.0,1.0,pshiftlow,pshifthigh))
	);
	sig = Splay.ar(player.flatten);
	sig = PitchShift.ar(sig, 0.5, Ndef(\e).ar.linlin(-1.0,1.0,pshiftlow,pshifthigh));
	sig = GVerb.ar(sig, 10, 3, inputbw: 0.0);
	Splay.ar(LeakDC.ar(sig)).clip2(1.0) * 0.45 // potent sheis
}).play
)
Ndef(\e).set(\sineMaxDur, 0.06)
Ndef(\e).set(\pshiftlow, 0.01)
Ndef(\e).set(\pshifthigh, 0.56)
Ndef(\e).set(\pshiftlow, 0.7)
Ndef(\e).set(\pshifthigh, 7.56)
Ndef(\e).set(\sineMaxDur, 1.06)
Ndef(\e).set(\dens, 0.3)
Ndef(\e).set(\dens, 2.6)
Ndef(\e).set(\sineMaxDur, 0.03)

Ndef(\e).set(\dens, 0.25)
Ndef(\e).set(\sineMaxDur, 0.76)
Ndef(\e).set(\pshiftlow, 0.01)
Ndef(\e).set(\pshifthigh, 0.36)

Ndef(\e).set(\dens, 0.12)
Ndef(\e).set(\sineMaxDur, 1.76)
Ndef(\e).set(\pshiftlow, 0.01)
Ndef(\e).set(\pshifthigh, 0.26)


Ndef(\e).stop
Ndef(\e).clear



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


/ ********************************************* /
/ *********** control af mads ***************** /
/ ********************************************* /
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






/*(
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

*/
