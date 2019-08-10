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

~clock.setGlobalTempo(2.0);

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