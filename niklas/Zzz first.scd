Convenience.crawl("/home/salkin/Desktop/nogmlyde", 3)

Convenience.list

Convenience.get(\udsagn, 9)


Convenience.s(\lay)

(
Convenience.p(\lay,
	tempo: ~clock,
	dur: 0.01+Psrp(0.1).linlin(-1.0,1.0,0.0,1.0),
	folder: \metallic_objects, //Pfunc({Convenience.randomFolder}),
	index: Prand((1..300), inf),
	pos: 0.0,//Pwhite(0.2,0.81),
	amp: 1.39,
	bass: 0.5,
	rate: 30,
	pan: Pwhite(-0.8,0.8),
	attack: 0.01,
	decay: 0.1,
	sustain: 1.0,
	release: Pwhite(0.005, 1.2),
	fftOnOff: 1,
	binRange: Pfunc({[Convenience.buckets(frame: ~frame, numBands: 20, band: 20.linrand)]})
))

(
Convenience.p(\lay,
	tempo: ~clock,
	dur: 5.5+Psrp(0.1).linlin(-1.0,1.0,0.0,8.0),
	folder: \udsagn, //Pfunc({Convenience.randomFolder}),
	index: Prand((1..300), inf),
	pos: 0.0,//Pwhite(0.2,0.81),
	amp: 1.39,
	//bass: 0.5,
	rate: Pwhite(0.2, 6),
	pan: Pwhite(-0.8,0.8),
	attack: 0.4,
	decay: 0.1,
	sustain: 1.0,
	release: Pwhite(0.5, 12.2),
	fftOnOff: 1,
	binRange: Pfunc({[Convenience.buckets(frame: ~frame, numBands: 20, band: 20.linrand)]})
))

Convenience.s(\noy)
(
Convenience.p(\noy,
	tempo: ~clock,
	dur: Pseq([1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,3,1,1,1,Rest(22)], inf),
	folder: \metallic_objects, //Pfunc({Convenience.randomFolder}),
	index: Pseq([3,7,9,10,3,3,3], inf)+Pstep([180,200], Pseq([128, 32], inf), inf),
	pos: 0.0,//Pwhite(0.2,0.81),
	amp: 1.39,
	bass: 6.5,
	rate: Pwhite([0.7,0.71]),
	pan: Pwhite(-0.2,0.2),
	attack: 0.01,
	decay: 0.1,
	sustain: 1.0,
	release: Pwhite(0.1, 3.2),
))

(
Convenience.p(\noy,
	tempo: ~clock,
	dur: Pseq([1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,3,1,1,1,Rest(64)], inf),
	folder: \metallic_objects, //Pfunc({Convenience.randomFolder}),
	index: Pseq([3,7,9,10,3,3,3], inf)+Pstep([180,200], Pseq([128, 32], inf), inf),
	pos: 0.0,//Pwhite(0.2,0.81),
	amp: 1.39,
	bass: 10.5,
	rate: Pwhite([0.4,0.41]),
	pan: Pwhite(-0.2,0.2),
	attack: 0.01,
	decay: 0.1,
	sustain: 1.0,
	release: Pwhite(0.1, 0.4),
))

(
Convenience.p(\noy,
	tempo: ~clock,
	dur: Pseq([1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,3,1,1,1], inf),
	folder: \metallic_objects, //Pfunc({Convenience.randomFolder}),
	index: Pseq([3,7,9,10,3,3,3], inf)+Pstep([180,200], Pseq([128, 32], inf), inf),
	pos: 0.0,//Pwhite(0.2,0.81),
	amp: 1.39,
	bass: 10.5,
	rate: Pwhite([0.4,0.41]),
	pan: Pwhite(-0.2,0.2),
	attack: 0.01,
	decay: 0.1,
	sustain: 1.0,
	release: Pwhite(0.1, 0.4),
))

Convenience.s(\noy)
(
Convenience.p(\noy,
	tempo: ~clock,
	dur: Pseq([1,1,1,1,1,1,1,1,1,1,1,1,Rest(64)], inf),
	folder: \metallic_objects, //Pfunc({Convenience.randomFolder}),
	index: Pseq([3,7,9,10,3,3,3], inf)+Pstep([240,230], Pseq([128, 32], inf), inf),
	pos: Pwhite(0.2,0.81),
	amp: 1.50,
	bass: 12.5,
	rate: Pwhite([0.4,0.41]),
	pan: Pwhite(-0.2,0.2),
	attack: 0.01,
	decay: 0.1,
	sustain: 1.0,
	release: Pwhite(0.1, 0.4),
))


Convenience.s(\trokku)
(
Convenience.p(\trokku,
	tempo: ~clock,
	dur: Pseq([3,5,2,7,1,2,1,1], inf),
	folder: \metallic_objects, //Pfunc({Convenience.randomFolder}),
	index: Pseq([3,7,9,10,3,3,3], inf)+Pstep([320,340], Pseq([128, 32], inf), inf),
	pos: 0.0,//Pwhite(0.2,0.81),
	amp: 0.99,
	bass: 6.5,
	cutoff: Pwhite(100,3800),
	rate: Pwhite([0.7,0.71]),
	pan: Pwhite(-0.2,0.2),
	attack: 0.01,
	decay: 0.1,
	sustain: 1.0,
	release: Pwhite(0.1, 3.2),
))


Convenience.list
Convenience.s(\wwert)
(
Convenience.p(\wwert,
	tempo: ~clock,
	dur: Pseq([3,5,2,7,1,2,1,1], inf),
	folder: \Pots_and_pans_bernt_ankers_gate, //Pfunc({Convenience.randomFolder}),
	index: Pseq([3,7,9,10,3,3,3], inf)+Pstep([320,340], Pseq([128, 32], inf), inf),
	pos: Pwhite(0.1,0.91),
	amp: 1.9,
	bass: 0.5,
	cutoff: Pwhite(100,9800),
	rate: Pwhite([0.1,0.11]),
	pan: Pwhite(-0.2,0.2),
	attack: 0.01,
	decay: 0.1,
	sustain: 1.0,
	release: Pwhite(8.1, 18.2),
))

