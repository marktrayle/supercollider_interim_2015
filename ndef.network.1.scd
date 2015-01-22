(
var mw,dw,rw;
d = Server(\davy,NetAddr("10.0.1.8",57110));
r = Server(\ryan,NetAddr("10.0.1.11",57110));
m = Server(\martin,NetAddr("10.0.1.14",57110));
c = Server(\cordy,NetAddr("10.0.1.12",57110));

mw = m.makeWindow;
rw = r.makeWindow;
dw = d.makeWindow;
c.makeWindow;

ProxySpace.push(c);
ProxySpace.push(m);
ProxySpace.push(r);
ProxySpace.push(d);

CmdPeriod.add(
	{
	"pop".postln;
	ProxySpace.pop;
	ProxySpace.pop;
	ProxySpace.pop;
	}
);
)

(
Ndef(\out -> \cordy).play(numChannels:1);
Ndef(\out -> \cordy) <-- Ndef(\standard -> \cordy,{ |freq=10000,k=1.61,x=0.31830,y=0.788618379|
			StandardN.ar(freq,k,x,y)
		})
)

Ndef(\standard -> \cordy).set(\freq,10000)
Ndef(\standard -> \cordy).free(3)


Ndef(\standard -> \double).free(3)