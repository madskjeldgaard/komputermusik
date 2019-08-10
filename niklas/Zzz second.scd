Convenience.crawl("/home/salkin/Desktop/nogmlyde", 3)

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


~clock = BeaconClock( ~addrBook );
~clock.setGlobalTempo(1.0);
~clock.startBeacons
~clock.tempo

~clock.setGlobalTempo(8.0);

Convenience.list

Convenience.get(\udsagn, 9)


Convenience.s(\lay)

(
Convenience.p(\lay,
	tempo: ~clock,
	dur: Prand([1,2,3,Rest(3)], inf)/16,
	folder: \metallic_objects, //Pfunc({Convenience.randomFolder}),
	index: Pseq([120,130,50], inf),
	pos: Pwhite(0.1,0.11),
	amp: 1.89,
	bass: 1.5,
	rate: Pwhite(1.2, 1.3)+Psrp(0.003).linlin(-1.0,1.0,30,-20),
	pan: Pwhite(-0.9,1.0),
	cutoff: Pwhite(7000,12000),
	attack: 0.4,
	decay: 0.1,
	sustain: 0.8,
	release: Pwhite(0.01, 2.99),
))


(
Convenience.p(\lay,
	tempo: ~clock,
	dur: Prand([1,2,3,Rest(3)], inf)/2,
	folder: \metallic_objects, //Pfunc({Convenience.randomFolder}),
	index: Pseq([1290], inf),
	pos: Pwhite(0.05,0.11),
	amp: 1.29,
	bass: 1.5,
	rate: Pwhite(0.2, 0.3)+Psrp(0.233).linlin(-1.0,1.0,0.0,0.1),
	pan: Pwhite(-0.9,1.0),
	cutoff: Pwhite(200,3000),
	attack: 0.01,
	decay: 0.1,
	sustain: 0.2,
	release: Pwhite(0.001, 0.009),
))

Convenience.s(\lay)
(
Convenience.p(\lay,
	tempo: ~clock,
	dur: Prand([1,2,3,Rest(3)], inf)/16,
	folder: \metallic_objects, //Pfunc({Convenience.randomFolder}),
	index: Pseq([600], inf),
	pos: Pwhite(0.1,0.11),
	amp: 1.49,
	bass: 4.5,
	rate: Pwhite(1.2, 1.3)+Psrp(0.003).linlin(-1.0,1.0,1,-2),
	pan: Pwhite(-0.9,1.0),
	cutoff: Pwhite(7000,12000),
	attack: 0.4,
	decay: 0.1,
	sustain: 0.8,
	release: Pwhite(0.01, 2.99),
))