 //MIDI and OSC control
//
Server.killAll
(
// a test synth
SynthDef(\osctester,{|out=0,freq=1000.0,nharms=10,amp=0.5|
	b = Blip.ar(freq,nharms,mul:amp);
	Out.ar(out,b);
}).send(s);
)
// receiving end of an OSC message
(
t = Synth(\osctester);
OSCFunc({|msg,time,addr,rcvr|
	msg.postln;
	t.set(\freq,msg[1]);
},\freq);
OSCFunc({|msg,time,addr,rcvr|
	msg.postln;
	t.set(\nharms,msg[1]);
},\nharms);
OSCFunc({|msg,time,addr,rcvr|
	msg.postln;
	t.set(\amp,msg[1]);
},\amp);
)
// sending an OSC message
(
m = NetAddr("10.2.32.9",NetAddr.langPort);
m.sendMsg(\freq,399.9999);
)

t.free
t.dump

t.set(\nharms,31)

//
//
//
// now do MIDI
//
//

(
MIDIIn.connectAll;
t = Synth(\osctester);
MIDIFunc.cc({|val,num,chn,src|
	val.postln;
	t.set(\freq,val.linlin(0,127,50,500));
},106);
MIDIFunc.cc({|val,num,chn,src|
	val.postln;
	t.set(\amp,val.linlin(0,127,0,1).postln);
},107);
MIDIFunc.cc({|val,num,chn,src|
	val.postln;
	t.set(\nharms,val.linlin(0,127,3,31));
},108);

)

// now try it with streams
(
(
~pfreq = 440;
~pamp = 0;
~pnharms = 10;
~delta = 1;
MIDIIn.connectAll;
t = Synth(\osctester);
MIDIFunc.cc({|val,num,chn,src|
	val.postln;
	~pfreq = val.linlin(0,127,50,500);
},106);
MIDIFunc.cc({|val,num,chn,src|
	val.postln;
	~pamp = val.linlin(0,127,0,1);
},107);
MIDIFunc.cc({|val,num,chn,src|
	val.postln;
	~pnharms = val.linlin(0,127,3,31);
},108);
MIDIFunc.cc({|val,num,chn,src|
	val.postln;
	~delta = val.linlin(0,127,1.3,0.1);
},109);

)
(
~pfreq = 440;
~pamp = 0.2;
~pnharms = 10;
~delta = 0.1;
// a test synth
SynthDef(\osctester,{|out=0,freq=1000.0,nharms=10,amp=0.5,gate=1|
	b = Blip.ar(freq,nharms,mul:amp);
	e = EnvGen.ar(Env.perc,gate,doneAction:2);
	Out.ar(out,b * e);
}).store;

Pbind(
	\instrument,\osctester,
	\freq,Pfunc({~pfreq}),
	\amp,Pfunc({~pamp}),
	\nharms,Pfunc({~pnharms}),
	\delta,Pfunc({~delta})
).play;
)

//////////////

CmdPeriod.doOnce({
	MIDIFunc.clear;
	OSCFunc.clear;
})

OSCFunc({|msg,time,addr,rcvr| ~pamp = msg[1]; "pamp".postln; },\pamp);

