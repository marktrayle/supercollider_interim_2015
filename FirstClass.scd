(
SynthDef(\testOne,{|out=0,freq=440.0,amp=0|
	Out.ar( out,SinOsc.ar(freq,mul:amp))
}).store
)

a = Synth(\testOne,[\amp,0.2])
a.set(\freq,60.11111)

(
SynthDef(\testTwo,{|out=0,ffreq=100,q=0.2,amp=0.2|
	var filter;

	filter = BPF.ar( WhiteNoise.ar,ffreq,q,amp );
	Out.ar( out,filter );
}).store
)

b = Synth(\testTwo)
b.set(\ffreq,1000);
b.set(\q,0.01)

// changing things using a clock
c = SystemClock.sched(3.0,{ b.set(\ffreq,234) })
// changing things iteratively using a Task
t = Task({
	inf.do({
		b.set(\ffreq,rrand(50.5,1000.2));
		0.5.wait;
	})
});
t.start;

// to answer mint's question:
// unfinished!!
SynthDef(\testThree,{|out=0,freq=440.0,amp=0|
	var lfo;
	lfo = LFNoise2.ar( freq ).range(20,2000);
	Out.ar( out,SinOsc.ar(lfo,mul:amp))
}).store

a = Synth(\testThree,[\amp,0.2])
a.set(\freq,0)

/////// test the Env
(
SynthDef(\testGate,{|out=0,freq=440,atk=0.01,rls=1.0,amp=1,gate=1|
	var osc1,osc2,mod;
	var env;

	env = EnvGen.ar( Env.perc(atk,rls),gate,doneAction:2 );

	osc1 = SinOsc.ar(freq,mul:amp);
	osc2 = SinOsc.ar(freq * 0.918732,mul:amp);

	mod = osc1 + osc2;

	Out.ar(out,mod * env );
}).store
)

Pbind(
	\instrument,\testGate,
	\freq,Pwhite(100,1000,inf),
	\atk,Pwhite(0.01,1.0,inf),
	\rls,Pwhite(0.01,1.0,inf),
	\delta,Pwhite(0.1,1.0,inf) // loop speed control
).play

(
Ppar(
[
Pbind(
	\instrument,\testGate,
	\out,Prand([0,1]),
	\freq,Pwhite(50,100,inf),
	\atk,Pwhite(0.01,1.0,inf),
	\rls,Pwhite(0.01,1.0,inf),
	\delta,Pwhite(1,10.0,inf) // loop speed control
),
Pbind(
	\instrument,\testGate,
	\out,0,
	\freq,Pwhite(100,500,inf),
	\atk,Pwhite(0.01,1.0,inf),
	\rls,Pwhite(0.01,1.0,inf),
	\delta,Pwhite(0.1,1.0,inf) // loop speed control
),
Pbind(
	\instrument,\testGate,
	\out,1,
	\freq,Pwhite(500,1000,inf), // frequency range between 500hz and 1khz
	\atk,Pwhite(0.01,1.0,inf),
	\rls,Pwhite(0.01,1.0,inf),
	\delta,Pwhite(0.1,1.0,inf) // loop speed control
)
]).play
)