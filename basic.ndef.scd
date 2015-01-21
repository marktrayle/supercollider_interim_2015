// stereo
Ndef(\src, { Dust.ar(5 ! 2) }); // Dust.ar([5,5]),  \in.ar([0,0])
Ndef(\fx, { CombL.ar(\in.ar(0 ! 2), 1, LFNoise1.kr(0.1).range(0, 0.1), LFNoise1.kr(0.1).range(2, 15)) });
Ndef(\out, { \in.ar(0 ! 2) }).play; // just an empty out

Ndef(\out).fadeTime = 5; // replace by 20
Ndef(\out) <<> Ndef(\src);
Ndef(\out) <<> Ndef(\fx) <<> Ndef(\src);
Ndef(\fx).fadeTime = 5;
Ndef(\fx, { BPF.ar(\in.ar(0 ! 2),LFNoise1.kr(0.3).range(100,1000),0.2)});

// how to make an Ndef chain
// you can think of this as a chain of synths

// execute each line by highlighting the whole
// line and pressing shift-enter

// first, an output node
// it's taking whatever signal arrives at its input (\in.ar(0))
// and sending it to the output (an implied Out.ar)
// numChannels is specifically set to 1, because the default
// for Ndefs is stereo
//

Ndef.clear; // clean up the mess we've made
Ndef(\out,{ \in.ar(0)}).play(numChannels:1);

// now make a source Ndef, just Dust clicking away
Ndef(\src, { Dust.ar(5) });

// make an effect, this is a comb filter with some
// random modulators
Ndef(\fx, { CombL.ar(\in.ar(0), 1, LFNoise1.kr(0.1).range(0, 0.1), LFNoise1.kr(0.1).range(2, 15)) });

Ndef(\out) <<> Ndef(\src)
// now chain them
Ndef(\out) <<> Ndef(\fx) <<> Ndef(\src);

// now set the fade time..
Ndef(\fx).fadeTime = 0;
// and replace the comb filter with a bandpass filter
// (will be pretty quiet, listen carefully)
Ndef(\fx, { BPF.ar(\in.ar(0),LFNoise1.kr(0.3).range(100,1000),0.2)});

//////////////////////////////////////////

(
Ndef(\out, { |gain| \in.ar(0) }).play(numChannels:1); // just an empty out
Ndef(\fx, { |delay = 0.1,decay = 0| CombL.ar(\in.ar(0), 1, delay, decay) });
Ndef(\src,{ |freq=44.1,k=1,gain=0| StandardN.ar(freq,k,mul:gain) });
Ndef(\out) <<> Ndef(\fx) <<> Ndef(\src);

//Ndef(\src,{ |freq=44.1,a=1,b=0.2,gain=0| Henon2DN.ar(44.1,freq,a,b,mul:gain) });


MIDIFunc.cc({|val,num,chn,src|
	"chnage freq".postln;
		Ndef(\src).set(\freq,val.linlin(0,127,44.1,11025.0));
	},106);

~controllers = ~controllers.add(
	CCResponder({ |src,chn,num,val|
		Ndef(\src).set(\k,val.linlin(0,127,1.0,5.0));
	},num:107));

	~controllers = ~controllers.add(
	CCResponder({ |src,chn,num,val|
		Ndef(\fx).set(\delay,val.linlin(0,127,0.001,0.1));
	},num:108));

~controllers = ~controllers.add(
	CCResponder({ |src,chn,num,val|
		Ndef(\fx).set(\decay,val.linlin(0,127,-0.99,0.99));
	},num:109));

~controllers = ~controllers.add(
	CCResponder({ |src,chn,num,val|
		Ndef(\src).set(\a,val.linlin(0,127,-1.0,1.0));
	},num:5));

~controllers = ~controllers.add(
	CCResponder({ |src,chn,num,val|
		Ndef(\src).set(\b,val.linlin(0,127,-1.0,1.0));
	},num:6));


~controllers = ~controllers.add(
	CCResponder({ |src,chn,num,val|
		Ndef(\src).set(\gain,val.linlin(0,127,0,1));
	},num:10));

CmdPeriod.add({~controllers.do({|c| c.remove})});

)


// sample-mangler zone

(
		// declare the sample filenames
		~samples = 	[
						"/Users/marktrayle/samples/redneckloop1.aif",
						"/Users/marktrayle/samples/redneckloop2.aif",
						"/Users/marktrayle/samples/midriderloop.aif"
						];
		// make an array of sample buffers, one buffer per file
		~tsamples = [ Buffer.new(s),Buffer.new(s),Buffer.new(s) ];
		// now read them all in
		~tsamples.do({ | b,i | b.allocRead( ~samples[i] )});

		Ndef(\out,{ \in.ar(0)}).play(numChannels:1);

		Ndef(\granules,{| trate=100,dur=0.1,buffer=0,rate=1,pos=0,amp=0 |
			GrainBuf.ar(1,Impulse.ar(trate),dur,buffer,rate,pos,4,mul:amp)
		});

		~controllers = ~controllers.add(
			CCResponder({|src,chn,num,val|
//				postln("set amp "++val.linlin(0,127,0,1));
				Ndef(\granules).set(\amp,val.linlin(0,127,0,1));
			},num:10)
		);

		~controllers = ~controllers.add(
			CCResponder({|src,chn,num,val|
				Ndef(\granules).set(\trate,val.linlin(0,127,10,100));
			},num:1)
		);

		~controllers = ~controllers.add(
			CCResponder({|src,chn,num,val|
				Ndef(\granules).set(\dur,val.linlin(0,127,0.01,0.1));
			},num:2)
		);

		~controllers = ~controllers.add(
			CCResponder({|src,chn,num,val|
				Ndef(\granules).set(\buffer,~tsamples[val.linlin(0,127,0,2).asInteger]);
			},num:3);
		);

		~controllers = ~controllers.add(
			CCResponder({|src,chn,num,val|
				Ndef(\granules).set(\pos,val.linlin(0,127,0,1));
			},num:4)
		);


		Ndef(\out) <<> Ndef(\granules);

)