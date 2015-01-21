

(
	m = Server("double",NetAddr("192.168.1.142",57110));
	m.boot;
	w = m.makeWindow;
	ProxySpace.push(m);
	CmdPeriod.add({"pop".postln; ProxySpace.pop});
)
// try these, one block at a time
(
	Ndef(\out -> \double,{ \in.ar(0) }).play(numChannels:1);
	Ndef(\source,{ \in.ar });
)
Ndef(\out -> \double).play(numChannels:1)
Ndef(\out -> \double) <-- Ndef(\noise -> \double,{|gain=0.4|
		WhiteNoise.ar(gain)
	})
Ndef(\noise -> \double).set(\gain,0.1)
Ndef(\noise -> \double).free(3)

Ndef(\out -> \double) <-- Ndef(\standard -> \double,{ |freq=10000,k=1.61,x=0.31830,y=0.788618379|
			StandardN.ar(freq,k,x,y)
		})

Ndef(\standard -> \double).free(3)


Ndef(\out -> \double) <-- Ndef(\sine -> \double,{|freq=1000|
		SinOsc.ar(freq)
})
Ndef(\sine -> \double).free(3)


(	// play noise on localhost server
	Ndef(\noise,{|gain=0.4|
		WhiteNoise.ar(gain)
	}).play;
)
(	// do this to stop it
	Ndef(\noise).free(1)
)

// another way to do it
(	// a noise-playing Ndef
	Ndef(\noise,{|gain=0.4|
		WhiteNoise.ar(gain)
	});
)
(	// do this to start it
	Ndef(\out) <<> Ndef(\noise)
)
(	// do this to stop it
	Ndef(\noise).free(1)
)

///////////////////////////////// remotely

(
	Ndef(\out -> \double,{ \in.ar(0) }).play(numChannels:1);
	Ndef(\source,{ \in.ar });
)
(	// play noise on the remote server
	Ndef(\noise -> \double,{|gain=0.4|
		WhiteNoise.ar(gain)
	}).play;
)
(	// do this to stop it
	Ndef(\noise -> \double).free(1)
)

// another way to do it
(	// a noise-playing Ndef
	Ndef(\noise -> \double,{|gain=0.4|
		WhiteNoise.ar(gain)
	});
)
(	// do this to start it
	Ndef(\out -> \double) <<> Ndef(\noise -> \double)
)
(	// do this to stop it
	Ndef(\noise -> \double).free(1)
)

// how can i change servers? use an array of symbols
(	// play noise on the remote server
	v = [\localhost,\double];
	Ndef(\noise -> v[0],{|gain=0.4|
		WhiteNoise.ar(gain)
	}).play;
)

(
	p = 0;
	CCResponder({|src,chn,num,val|
		v = [\localhost,\double];
		i = val.linlin(0,127,0,v.size).floor.min(v.size-1);
		v[i].postln;
		if( Ndef(\noise -> v[i]).isPlaying == false,{
			Ndef(\noise -> v[i],{|gain=0.4|
				WhiteNoise.ar(gain)
			}).play;
			Ndef(\noise -> v[p]).free(1);
			p = i;
		});
	},num:1)
)


Ndef(\noise -> \double).free(3);


Ndef(\noise -> \double).set(\gain,0.1);

(
		var ip,broadcast;

		// make an empty array for player's ip addresses:ports
		~players = [];
		// this OSCFunc receives the \newplayer message
		OSCFunc({|msg,time,rcvr,add|
			msg.postln;
			~players = ~players.add(NetAddr(msg[1].asString,57110));
			~players.postln;
		},\newplayer);

		ip = NetAddr.myIP;
		x = ip.split($\.);
		x.put(3,"255");
		z = x[0]++"."++x[1]++"."++x[2]++"."++x[3];
		z.postln;
		NetAddr.broadcastFlag = true;
		NetAddr(z,57120).sendMsg('/newplayer',ip);
		NetAddr.broadcastFlag = false;
)


// how to make an Ndef with a fixed duration
// it stops playing and releases the synth
// when the envelope is finished.
(
	Ndef(\foghorn,{|freq=70,attack=0.2,sustain=3,release=0.3|
		var env = EnvGen.kr( Env.linen(attack,sustain,release),1,doneAction:2);
		SinOsc.ar(freq) * env;
	}).play
)