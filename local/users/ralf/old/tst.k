# $Id: tst.k,v 1.21 2004/02/03 13:09:11 Ralf Vosseler Exp $
#include "rvo.k";


class Samba {
	method init() {
		l = new RvoLog("Samba");
		$.inherit(l);
		d = new RvoGmDrummer();
		$.inherit(d);
		r = new RvoTrackGenerator($);
		$.inherit(r);
		$.Kick="Kick1";
		$.KickVel ="{v60..80}";
		$.Snare ="Snare2";
		$.Snares = [
			0=$.Snare+"{v10..32}",
			1=$.Snare+"{v32..63}",
			2=$.Snare+"{v63..95}",
			3=$.Snare+"{v96..127}"
		];
		$.Toms =[
			0="HiTom1",
			1="HiTom2",
			2="MidTom1",
			3="MidTom2",
			4="LoTom1",
			5="LoTom2"
		];
		$.TomVel ="{v80..127}"


		$.SetTempo(130);
		rand(-1000);
		$.SetTimeMBT(2);
		$.AddPattern("Intro","Intro");
		$.AddPattern("1","Ride1","Basic1");
		$.AddSequence("Intro",64,"1");
		$.Generate();
#		$.Play("play.mid");

	}

	method Intro() {
		#$.BeatQ(16,$.Roll($.Snares[3],32,$.MBT2Clicks(1,0,0),"-30%"),1);
		$.BeatQ(16,$.Roll($.Flam($.Snare+"{v0}",48,"80%"),32,$.MBT2Clicks(4,0,0),80),1);
		#$.BeatQ(16,$.Flam($.Snares[3],48,"-20%"),15);
		$.Advance(4);
	}

	method SpecialRide(vol) {
		r = 0;
		v1 =0;
		v2 =0;
		returnvalue ="";
		r = rand(0,80);
		v1 = vol;
		v2 = integer(r*vol/100);
		returnvalue = "Ride1{v"+string(v1)+"}"
			+" RideBell{v"+string(v2)+"}";
		return(returnvalue);

	}

	method Ride1() {
		crashes =[
			0="Crash1",
			1="China",
			2="Splash",
			3="Crash2"
		];
		crashvel="{v60..127}";
		i = 0;
		vol =0;
		s = "";
		for (i=0;i<4;i++) {
			if ((($.GetRun()%8) ==1) && (i ==0))
				s = crashes[rand(0,3)]+crashvel
					+" "+$.Kick+$.KickVel;
			else
				s = $.SpecialRide(rand(60,127));
			$.BeatQ(4,s,i+1);
		}
	}

	method Basic1() {

		#rand(-rand(1,20000));
		#rand(-rand(1,30000));
		rand(-rand(1,60000));
		$.BeatQ(8,"PdHiHat{v80}",2,4,6,8);
		$.BeatQ(16,$.Kick+$.KickVel,4,7,12,15);
		$.BeatQ(16,$.Snares[0],1,2,3,5,6);
		$.BeatQ(16,$.Snares[1],4,7,10,11,12);
		$.BeatQ(32,$.Snares[0],12);
		if (($.GetRun() %7) ==0)
			$.BeatQ(16,$.Toms[rand(0,2)]+$.TomVel,8);
		else
			$.BeatQ(16,$.Snares[3],8);
		$.OBeatQ(50,100,16,$.Snares[rand(0,3)],13,14);
		if (($.GetRun()%8) ==0) {
			$.OBeatQ(6,10,32,$.Snares[0],26,27,28);
			$.OBeatQ(50,100,16,$.Toms[rand(0,4)]+$.TomVel,15);
			$.OBeatQ(50,100,16,$.Toms[rand(0,4)]+$.TomVel,16);
		}
		else {
			$.OBeatQ(50,100,16,$.Snares[rand(0,3)],15,16);
		}
		$.Advance(1);
	}

}


class BassLine {
	method init() {
		l = new RvoLog("Samba");
		$.inherit(l);
		stools = new RvoStringTools();
		$.inherit(stools);
		i = new RvoInstrument();
		$.inherit(i);
		r = new RvoTrackGenerator($);
		$.inherit(r);

		$.AddPattern("Intro","Intro");
		$.AddPattern("1","Main");

		$.AddSequence("Intro",16,"1");
		$.Generate();


	}

	method Intro() {

		$.AppendNote(progchange(34,1),
				"rc1{d6},"
			);
	}

	method Transpose2Str(note,amount) {

		return ($.ToString(transpose(note,amount)));
	}

	method Up5(note,mode) {
		s = "";
		if (mode ==2)
			s += $.ToString(note)+"{d3/16},";
		else
			s +=$.ToString(note)+"{d5/16},";
		s += $.Transpose2Str(note,7)+"{d3/16},";
		return (s);
	}

	method Down5(note,mode) {
		s = $.ToString(note)+"{d5/16},";
		if (mode ==3)
			s += $.Transpose2Str(note,-5)+"{d3/16},"
				+ $.Transpose2Str(note,-17)+"{d2/16},";
		else
			s += $.Transpose2Str(note,-5)+"{d3/16},";
		return (s);
	}

	method Figure1(basicnote,variant) {

		if ((nargs() ==1) || (typeof(variant) !="integer"))
			v =1;
		else
			v = variant;

		s = $.Up5(basicnote,v)
			+ $.Down5(transpose(basicnote,12),v);
		return (s);
	}

 	method Main() {

		s = "";

		if ($.GetRun() ==1)
			s +=$.Figure1('co1v127',2);
		else
			s += $.Figure1('co1v127');
		s += $.Figure1('co1v127');
		s += $.Figure1('go0v127');
		s += $.Figure1('co1v127');
		$.AppendNote(s);
	}
}

#s = new Samba();

s = new RvoSong(
			new Samba()
			,new BassLine ()
		);
s.Play("play.mid");
deleteobject(s);


