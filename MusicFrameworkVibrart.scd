(
s.options.memSize= 8192*2;

s.waitForBoot({
// ----------------------------------------------------------------------------------------------------
// --------------------------------------------  GLOBAL VARIABLES --------------------------------------
// ----------------------------------------------------------------------------------------------------
// --------- SIMPLE GLOBAL VARS --------
~freqz = 100;
~nBin = 512;
~doOnce = false;
~listenToPython = false;
~tonality = 0;
~adjust = Array.fill(12, { arg i; 0 });    // adjust melody scale
~durationForRole = Array.fill(12, { arg i; [1,2,4].choose }); // duration for Role of the note in the scale
~octave = 0;

// Buffers used in granulator Grains, for vibratingWater
	b = Buffer.readChannel(server: s, path: thisProcess.nowExecutingPath.dirname +/+ "/Music/empty_vessels.wav", channels: [0]);
	c = Buffer.readChannel(server: s, path: thisProcess.nowExecutingPath.dirname +/+ "/Music/water_dripping.wav", channels: [0]);
	e = Buffer.cueSoundFile(server: s, path: thisProcess.nowExecutingPath.dirname +/+ "/Music/alberto_balsam.wav", channels: [0]);
// ----------------------------------------------------------------------------------------------------
// --------------------------------------------  SYNTHDEFS  -------------------------------------------
// ----------------------------------------------------------------------------------------------------
//  Init Synth

	SynthDef(\init,
		{
		arg gate;
		var env = EnvGen.kr(Env([0, 1, 1, 0], [1, 6.5, 3.5], [2, 0, 0, -2]), gate, doneAction:2);
			Out.ar(0, DiskIn.ar(2, e.bufnum, loop: 0)*env);
		}
	).add;

// Sinusoidal signal used for vibratingPlate
	SynthDef.new(
		"pureSine",
		{
			arg freq=220, rate=0.1, pan=0.0, amp=1.0, dur=1.0, lfor1=0.08, lfor2=0.05, nl=0.5, filt=5000, gate;
			var sig, sub, lfo1, lfo2, env, noise;

			lfo1  = SinOsc.kr(lfor1, 0.5, 1, 0);
			lfo2  = SinOsc.kr(lfor2, 0, 1, 0);
			sig   = SinOscFB.ar(freq, lfo1, 1, 0);
			sub   = SinOscFB.ar(freq*0.25, lfo2, 1, 0);
			env = EnvGen.kr(Env.asr(3, 0.3, 3, 0), gate, doneAction:2);
			noise = PinkNoise.ar(nl, 0);
			sig   = (sig + sub + noise) * env;
			sig   = MoogFF.ar(sig, filt * 0.5, 0, 0, 1, 0);
			sig   = Pan2.ar(sig, pan, amp);
			sig   = FreeVerb2.ar(sig[0], sig[1], 0.25, 0.99, 0.9);
			Out.ar(0, sig * 0.6);
		}
	).add;



// Water drop - used for vibratingWater when the user stimulates the water

SynthDef(\wdrop, { |out, gate = 0, amp = 1, x= 0.1, y = 0.1|
    var pan, env, freqdev, sig;
    // use mouse x to control panning
    pan = MouseX.kr(-1, 1);
    env = EnvGen.kr(Env.asr(0.5, 1, 2, -2), gate, doneAction:0);
    sig = GrainBuf.ar(2, Dust.kr(250), y, c, LFNoise1.kr.range(0.5, 2),
			x, 4, (x*2)-1, -1);
	Out.ar(out, FreeVerb.ar(
		in: BLowPass.ar(sig*env, EnvFollow.ar(sig, 0.008, 10000,100) ),
		mix: 0.55,
		room: 0.35,
		damp: 0.1)
		);
	}).add;

// Grains - used for vibratingWater as background sound
	SynthDef(\tgrains, {
		arg gate = 1, x = 0.1, y = 0.1;
			var trigRate, rate, snd, centerPos, env;

			// mouse movement X and Y:
		    trigRate = (y*200)+2;
			centerPos = x*BufDur.kr(b);

			rate = Dseq([1, 1, 1, 1, 2, 4, 8], inf);

			snd = TGrains.ar(
				numChannels: 2,
				trigger: Impulse.ar(trigRate),
				bufnum: b,
				rate: rate,
				centerPos: centerPos,
				dur: 4 / trigRate,
				pan: Dseq([-1, 1], inf),
				amp: 0.2,
				interp: 2
			);

	env = EnvGen.kr(Env.asr(3, 1, 3, 0), gate, doneAction:2);

		snd = snd * env;

		snd = FreeVerb.ar(
				in: snd,
				mix: 0.14,
				room: 0.5,
				damp: 0.5
			);

		Out.ar(0, 3*LPF.ar(snd, 7500));
		}).add;


// FFT sender - used for sending FFT to vibratingSunset FFTLines
	SynthDef(\avTrk, {|in= 0, t_trig= 0, amp= 1, bus|
		var z= Mix(In.ar(in, 2)*amp);
		var chain= FFT(LocalBuf(2*~nBin), z);
		Array.fill(~nBin, {|i|
			var a= Unpack1FFT(chain, 2*~nBin, i);
			var d= Demand.kr(chain>=0, 0, a);
			Out.kr(bus+i, d.min(1));
		});
	}).load;

// CrystalString - used when a string is plucked in vibratingStrings

	SynthDef(\crystalString,{
		|pShift = 1200, t_trig, freq, delT = 0.5, gSize = 0.5, tDisp = 0.5, fb = 0.25, dw = 0.8|
		var src, local;
		src = 2*( Pluck.ar(WhiteNoise.ar(0.1),
			t_trig,
			freq.reciprocal,
			freq.reciprocal,
			10,
		coef: 0.4)); // stereo input
		local = LocalIn.ar(2) + [src, 0];

		local = Greyhole.ar(
			local,
			delT,
			\damp.kr(0.7),
			\size.kr(1),
			\diff.kr(0.5),
			\fb.kr(0.8),
			\modDepth.kr(0.5),
			\modFreq.kr(0.5)
		);

		local = PitchShift.ar(
			local,    // stereo audio input
			gSize,             // grain size
			((pShift+SinOsc.kr(0.5, 0, 15))/1200 )+1,    // mouse x controls pitch shift ratio
			0,                 // pitch dispersion
			tDisp            // time dispersion
		);
		LocalOut.ar(local.reverse*fb);
		Out.ar(0,1.5*((local*dw)+(src*(1-dw))));
	}).add;

// Kalimba - used for melody generation in vibratingStrings

	SynthDef(\kalimba, {
		|out = 0, freq = 440, amp = 0.5, mix = 0.1|
		var snd, click;
		// Basic tone is a SinOsc
		snd = SinOsc.ar(freq) * EnvGen.ar(Env.perc(0.03, Rand(3.0, 4.0), 1, -7), doneAction: 2);
		snd = HPF.ar( LPF.ar(snd, 380), 120);
		// The "clicking" sounds are modeled with a bank of resonators excited by enveloped white noise
		click = DynKlank.ar(`[
			// the resonant frequencies are randomized a little to add variation
			// there are two high resonant freqs and one quiet "bass" freq to give it some depth
			[240*ExpRand(0.97, 1.02), 2020*ExpRand(0.97, 1.02), 3151*ExpRand(0.97, 1.02)],
			[-9, 0, -5].dbamp,
			[0.8, 0.07, 0.08]
		], BPF.ar(PinkNoise.ar, 6500, 0.1) * EnvGen.ar(Env.perc(0.001, 0.01))) * 0.1;
		snd = (snd*mix) + (click*(1-mix));
		snd = Mix( snd );
		Out.ar(out, 4*Pan2.ar(snd, 0, amp));
	}).add;

// KalimbaS - same of kalimba, generated with square waves - used for vibratingSunset melody

SynthDef("marimba", {arg freq = 440, amp = 0.4, pan = 0;
		var snd, env;
		env = Env.linen(
			attackTime: 0.015,
			sustainTime: 1,
			releaseTime: Rand(0.5,1.5),
			level: amp*2
		).kr(doneAction: 2);
		snd = BPF.ar(
			in: Saw.ar(0),
			freq: freq,
			rq: 0.02
		);
		snd = BLowShelf.ar(
			in: snd,
			freq: 220,
			rs: 0.81,
			db: 12
		);

		snd = HPF.ar(snd, 500);

		snd = LPF.ar((Formant.ar(freq, 2760, 1500, 0.0075) + snd) * env, 3500);
		Out.ar(0, Pan2.ar(snd, pan));
	},
	metadata: (
		credit: "unknown",
		category: \keyboards,
		tags: [\percussion, \marimba, \pitched, \keyboard]
	)
 ).add;

// Chicago Pad - used for chords in vibratingSunset
		SynthDef(\ChicagoPad, {
			|out = 0, f1 = 200, f2 =  300, f3 = 400, f4 = 500, cutoff = 500, amp = 0.4|
			var snd;
			f1 = f1 + SinOsc.kr(0.1, 0, 1, 20);
			snd = Saw.ar([f1,f2,f3])*0.1;
			snd = snd + VarSaw.ar(0.99*[f1,f2,f3,f4],0, LFTri.kr(0.3).range(0.25,0.7))*0.1;
			snd = Mix(snd);
			snd = RLPF.ar(snd, SinOsc.kr(0.1, 0, 100, 5000), 0.1);
		    snd = FreeVerb.ar(snd ,mix: 0.33, room: 0.5, damp: 0.5, mul: 1.0, add: 0.0);
			snd = MoogFF.ar(snd, SinOsc.kr(0.08, 0.5, cutoff/10, cutoff), 3, 0);
			snd = DelayC.ar(snd, 1.5, 1,0.8);
			Out.ar(out, [snd, AllpassC.ar(snd, 0.5, 0.05, 0.3)]*amp);
		}).add;

// simple FM - used for counterpoint in vibratingSunset

	SynthDef("melodyFM", {arg freq = 440, cmRatio = 3, modIndex = 10*(3*abs(SinOsc.kr(4/60))), amp = 0.01, att = 0.01, dec = 0.05, sus = 0.9, rel = 0.1, pan = 0, gate = 1;
		var carrier, modulator, modFreq, freqDev, snd, env;


		// C:M = freq:modFreq, thus modFreq = freq * B/A
		// When C:M is a simple integer ratio, FM generates harmonic spectra
		// When C:M is NOT a simple integer ratio, FM generates inharmonic spectra
		modFreq = freq * cmRatio.reciprocal;

		// Using Modulation Index to calculate freqDev
		// from formula index = freqDev/modfreq:
		freqDev = modIndex * modFreq;

		modulator = SinOsc.ar(freq: modFreq, mul: freqDev);
		carrier = SinOsc.ar(freq: freq + modulator);
		snd = 0.1*carrier * EnvGen.ar(Env.perc(0.3, Rand(1.0, 2.5), 1, -7), doneAction: 0);
		snd = Pan2.ar(snd, pan);
		Out.ar(0,0.04*snd);
		DetectSilence.ar(snd, doneAction: 2);
	}).add;

	// sunsetPad - used for chords in vibratingSunset
		SynthDef(\sunsetPad, {
			|out = 0, f1 = 200, f2 =  300, cutoff = 1200, amp = 0.7|
			var snd;
		snd = (1+0.15*SinOsc.kr(5/60))*Saw.ar([f1,f2])+ (1+0.5*SinOsc.kr(10/60))*Pulse.ar([f1,f2]);
			snd = snd + VarSaw.ar(0.99*[f1,f2],0, LFTri.kr(0.3).range(0.25,0.9))*0.1;
			snd = Mix(snd);
		snd = HPF.ar(RLPF.ar(snd, SinOsc.kr(0.1, 0, 100, 5000), 0.45),110+ abs(330*SinOsc.kr(2/60)) );
		snd = snd * (1.2 +0.3*SinOsc.kr(2.5/60));
		    snd = FreeVerb.ar(snd ,mix: 0.33, room: 0.5, damp: 0.5, mul: 1.0, add: 0.0);
			snd = MoogFF.ar(snd, SinOsc.kr(0.08, 0.5, cutoff/10, cutoff), 3, 0);
			snd = DelayC.ar(snd, 1.5, 1,0.8);
			Out.ar(out, [snd, AllpassC.ar(snd, 0.5, 0.05, 0.3)]*amp);
		}).add;
// -----------------------------------------------------------------------------------------------------
// ----------------------------------- MELODY DICTIONARIES ---------------------------------------------
// --------------------------------------- strng melody ------------------------------------------------

~evalStringMelody = { arg tone;
	    // C4  -- STATE 0
	  ~tonality = tone;
	  ~vibStringMel = [
		[60+~tonality, 1, [
			[1, 2],   [2, 3], [3, 3],    [4, 2],  [5, 1],    [6, 0.5],  [7, 1],
			[8, 1.5], [9, 2], [10, 0.8], [11, 2], [12, 0.3], [13, 0.3], [14, 0.8]
			]],
	    // D4  -- STATE 1
	    [62+~tonality, 0.5, [
			[0, 2.5], [2, 1.5], [3, 3],  [4, 2.5],  [5, 0.7], [6, 2],    [7, 0.3],
			[8, 2.5], [9, 1],   [10, 1], [11, 0.3], [12, 1],  [13, 0.8], [14, 0.5]
			]],
		// E4  -- STATE 2
		[64+~tonality, 1, [
			[0, 2],   [1, 2],   [3, 2.5],  [4, 1.5],  [5, 1.1],  [6, 0.5],  [7, 2],
			[8, 1.5], [9, 0.8], [10, 0.3], [11, 1.2], [12, 0.8], [13, 0.6], [14, 0.8]
			]],
		// F#4 -- STATE 3
		[66+~tonality, 0.5, [
		    [0, 2],   [1, 1.5], [2, 2],    [4, 1.5],  [5, 2],    [6, 0.5],  [7, 0.3],
			[8, 0.3], [9, 0.1], [10, 1.5], [11, 0.1], [12, 0.8], [13, 1],   [14, 0.2]
			]],
		// G4  -- STATE 4
		[67+~tonality, 1, [
			[0, 3], [1, 1.5], [2, 1.8],  [3, 2.5],    [5, 1.8],  [6, 1.8],  [7, 2.5],
			[8, 1], [9, 1.8], [10, 0.1], [11, 0.3], [12, 0.8], [13, 0.1], [14, 1]
			]],
		// A4  -- STATE 5
		[69+~tonality, 1.5, [
		    [0, 0.8], [1, 1.5], [2, 1],    [3, 1.5],    [4, 1.5],   [6, 1.5],  [7, 0.3],
			[8, 0.3], [9, 0.8], [10, 0.1], [11, 0.2], [12, 1.2],  [13, 0.2], [14, 0.1]
			]],
		// B4  -- STATE 6
		[71+~tonality, 1, [
			[0, 0.2], [1, 1], [2, 0.8],  [3, 1.2],  [4, 1.5],  [5, 1.5],  [7, 2],
			[8, 1],   [9, 1], [10, 0.3], [11, 0.3], [12, 1.5], [13, 0.5], [14, 1]
			]],
		// C5  -- STATE 7
		[72+~tonality, 2, [
			[0, 1.1],   [1, 0.3], [2, 1],  [3, 1.2], [4, 0.8],  [5, 0.5], [6, 0.2],
			[8, 0.7], [9, 1.5], [10, 1], [11, 1],  [12, 1.5], [13, 1],  [14, 0.5]
			]],
		// B3  -- STATE 8
		[59+~tonality, 0.5, [
			[0, 2.5], [1, 1.5], [2, 1],    [3, 1.2],  [4, 1.5],   [5, 0.5],  [6, 1],
			[7, 0.5], [9, 1.3], [10, 0.8], [11, 1],   [12, 0.3],  [13, 0.1], [14, 0.1]
			]],
		// G3  -- STATE 9
		[55+~tonality, 1, [
			[0, 2.5], [1, 1.5], [2, 0.4],  [3, 0.2],  [4, 1], [5, 0.3], [6, 0.8],
			[7, 1], [8, 1.3], [10, 1.5], [11, 1], [12, 0.3],  [13, 0.1], [14, 0.8]
			]],
		// F#3 -- STATE 10
		[54+~tonality, 0.5, [
			[0, 1.2], [1, 0.8], [2, 0.5],  [3, 1.2],  [4, 0.1], [5, 0.3], [6, 0.1],
			[7, 0.1], [8, 1.5], [9,1.8],  [11, 1.8], [12, 0.8],  [13, 1], [14, 0.5]
			]],
		// E3  -- STATE 11
		[52+~tonality, 0.5, [
			[0, 1], [1, 0.3], [2, 1],  [3, 0.4],  [4, 0.4], [5, 0.1], [6, 0.1],
			[7, 0.4], [8, 0.8], [9,1],  [10, 1.8], [12, 0.5],  [13, 0.1], [14, 0.1]
			]],
		// D5  -- STATE 12
		[74+~tonality, 1, [
			[0, 0.6], [1, 1],   [2, 0.3], [3, 1],    [4, 1],    [5, 0.3],  [6, 0.8],
			[7, 1.8], [8, 0.2], [9,0.5],  [10, 0.3], [11, 0.1], [13, 1.2], [14, 1.5]
			]],
		// F#5 -- STATE 13
		[78+~tonality, 0.5, [
			[0, 0.8], [1, 0.5], [2, 0.5],  [3, 1.2],  [4, 0.1], [5, 0.3], [6, 0.5],
			[7, 1.5], [8, 0.2], [9,0.3],  [10, 0.9], [11, 0.1],  [12, 1.2], [14, 0.5]
			]],
		// G5  -- STATE 14
		[79+~tonality, 0.25, [
			[0, 1.5], [1, 0.9], [2, 0.7],  [3, 0.5],  [4, 1.2], [5, 0.3], [6, 0.9],
			[7, 1.8], [8, 0.5], [9,1],  [10, 0.1], [11, 0.1],  [12, 0.5], [13, 1.2]
			]],
	];
};

// --------------------------- Sunset melody and counterpoint -----------------------------------------

~evalSunsetMelody = { arg adj, dur;

		~adjust = adj;
		~dur = dur;

		~sunsetMelody = [
			// C4 -- STATE 0
			[72+ ~adjust[0],
				~durationForRole[0], [
				 [2, 0.35], [3, 0.15], [4, 0.3], [6, 0.1], [7, 0.2]
			]],
			// D4 -- STATE 1
			[74+~adjust[1],
				~durationForRole[1], [
				[0, 0.3], [2, 0.3], [3, 0.15], [4, 0.1], [9, 0.15]
			]],
			// E4 -- STATE 2
			[75 +~adjust[2],
				~durationForRole[2], [
				[0, 0.4], [3, 0.2], [5, 0.2], [11, 0.1]
			]],
			// F4 -- STATE 3
			[77 +~adjust[3],
				~durationForRole[3], [
				[0, 0.3], [1, 0.3], [2, 0.1], [4, 0.1], [5, 0.2]
			]],
			// G4 -- STATE 4
			[79 +~adjust[4],
				~durationForRole[4], [
				[0, 0.5], [1, 0.1], [5, 0.1], [7, 0.3]
			]],
			// A4 -- STATE 5
			[81 + ~adjust[5],
				~durationForRole[5], [
				[1, 0.2],  [3, 0.3], [7, 0.1], [8, 0.2], [10, 0.2]
			]],
			// B4 -- STATE 6
			[82 + ~adjust[6],
				~durationForRole[6], [
				[4, 0.2], [7, 0.4], [9, 0.4]
			]],
			// C5 -- STATE 7
			[84 +~adjust[7],
				~durationForRole[7], [
				[0, 0.3], [4, 0.2], [10, 0.3], [11, 0.2]
			]],
			// D5 -- STATE 8
			[86 +~adjust[8],
				~durationForRole[8], [
					[2, 0.25], [3,0.05], [4, 0.1], [5, 0.1], [7, 0.3], [10, 0.2]
			]],
			// F5 -- STATE 9
			[89 +~adjust[9],
				~durationForRole[9], [
				[0, 0.15], [3, 0.1], [4, 0.1], [7, 0.35], [8, 0.1], [10, 0.15], [11, 0.05]
			]],
			// G5 -- STATE 10
			[91 +~adjust[10],
				~durationForRole[10], [
				[0, 0.25], [4, 0.15], [8, 0.25], [9, 0.2], [11, 0.15]
			]],
			// A5 -- STATE 11
			[93 +~adjust[11],
				~durationForRole[11], [
				[4, 0.05], [8, 0.3], [9, 0.35], [10, 0.2]
			]]
		];
	};

~evalSunsetCounterpoint = { arg oct, adj, dur;
		~octave = oct;
		~adjust = adj;
		~dur = dur;

		~sunsetCounterpoint = [
			// C4 -- STATE 0
			[48+~octave*12 + ~adjust[0],
				~durationForRole[0], [
				[1, 0.3], [2, 0.15], [3, 0.15], [4, 0.08], [6, 0.12], [7, 0.2]
			]],
			// D4 -- STATE 1
			[50+~octave +~adjust[1],
				~durationForRole[1], [
				[0, 0.3], [2, 0.15], [3, 0.15], [4, 0.1], [5, 0.15], [9, 1]
			]],
			// E4 -- STATE 2
			[51+~octave +~adjust[2],
				~durationForRole[2], [
				[0, 0.4], [1, 0.2], [3, 0.2], [5, 0.2], [11, 0.1]
			]],
			// F#4 -- STATE 3
			[53+~octave+~adjust[3],
				~durationForRole[3], [
				[0, 0.3], [1, 0.3], [2, 0.1], [4, 0.1], [5, 0.2]
			]],
			// G4 -- STATE 4
			[55+~octave +~adjust[4],
				~durationForRole[4], [
				[0, 0.45], [1, 0.15], [5, 0.1], [7, 0.2], [8, 0.1]
			]],
			// A4 -- STATE 5
			[57+~octave + ~adjust[5],
				~durationForRole[5], [
				[1, 0.2], [2, 0.1], [3, 0.2], [7, 0.1], [8, 0.2], [10, 0.2]
			]],
			// B4 -- STATE 6
			[58+ ~octave+ ~adjust[6],
				~durationForRole[6], [
				[4, 0.2], [7, 0.4], [9, 0.4]
			]],
			// C5 -- STATE 7
			[60+~octave +~adjust[7],
				~durationForRole[7], [
				[0, 0.4], [2, 0.05], [5, 0.2], [10, 0.15], [11, 0.2]
			]],
			// D5 -- STATE 8
			[62+~octave +~adjust[8],
				~durationForRole[8], [
				[1, 0.2], [2, 0.2], [3,0.05], [4, 0.1], [5, 0.05], [9, 0.15], [10, 0.1], [11, 0.15]
			]],
			// F5 -- STATE 9
			[65+~octave +~adjust[9],
				~durationForRole[9], [
				[0, 0.15], [3, 0.1], [4, 0.1], [7, 0.35], [8, 0.1], [10, 0.15], [11, 0.05]
			]],
			// G5 -- STATE 10
			[67 +~adjust[10],
				~durationForRole[10], [
				[0, 0.25], [4, 0.15], [8, 0.25], [9, 0.2], [11, 0.15]
			]],
			// A5 -- STATE 11
			[69+~octave +~adjust[11],
				~durationForRole[11], [
				[4, 0.05], [8, 0.3], [9, 0.35], [10, 0.2]
			]]
		];
		};


// ----------------------------------------------------------------------------------------------------
// --------------------------------------------  TASKS   ----------------------------------------------
// ----------------------------------------------------------------------------------------------------

~strings = Task({
	// Set attributes of each node
	// [freq, dur, [[next_state, weighted_random],…]]

	// TRANSITION PROBABILITY MATRIX -- COMPOSED BY US ON LYDIAN SCALE
	var node_list = node_list = ~evalStringMelody.value(~tonality);
	var node_index = 0;
	var bps = 80.0 / 60.0;  // Beats per second

	inf.do({
		var weight = 0;
		var random;
		var accumulator;
		var node = node_list[node_index];
		var freq = node[0].midicps;
		var dur = node[1] / bps;
		var paths = node[2];

		node_list = ~evalStringMelody.value(~tonality);
		// Get total statistical weight of connected nodes
		(0 .. paths.size - 1).do {|i| weight = weight + paths[i][1]};

		// Generate random value for choosing next node
		random = weight.rand;

		// Choose next node based on statistical weights
		accumulator = paths[0][1];

		node_index = block {|break|
			paths.size.do {|i|
				if ((random < accumulator), {
					break.value(paths[i][0])
				}, {
					accumulator = accumulator + paths[i + 1][1]
				})
			}
		};

		// Play
		Synth(\kalimba, [\dur, dur, \amp, 0.5, \freq, freq]);
		dur.wait;
	})
});

             //  -------------------------------------------------------------  //

~mel = Task({
	// Set attributes of each node
	// [freq, dur, [[next_state, weighted_random],…]]
	var node_list = ~evalSunsetMelody.value(~adjust,~durationForRole);
	var node_index = 0;
	var bps = 80.0 / 60.0;  // Beats per second

	inf.do({
		var weight = 0;
		var random;
		var accumulator;
		var node = node_list[node_index];
		var freq = node[0].midicps;
		var dur = node[1] / bps;
		var paths = node[2];
		    node_list = ~evalSunsetMelody.value(~adjust,~durationForRole);
		// Get total statistical weight of connected nodes
		(0 .. paths.size - 1).do {|i| weight = weight + paths[i][1]};

		// Generate random value for choosing next node
		random = weight.rand;

		// Choose next node based on statistical weights
		accumulator = paths[0][1];

		node_index = block {|break|
			paths.size.do {|i|
				if ((random < accumulator), {
					break.value(paths[i][0])
				}, {
					accumulator = accumulator + paths[i + 1][1]
				})
			}
		};

		// Play
		Synth(\marimba, [ \amp, 1, \freq, freq]);
		dur.wait;
	})
});

             //  -------------------------------------------------------------  //

~counterpoint =	Task({
		var node_list = ~evalSunsetCounterpoint.value(~octave, ~adjust,~durationForRole);
	 var node_index = 0;
	 var bps = 80.0 / 60.0;  // Beats per second

	 inf.do({
		var weight = 0;
		var random;
		var accumulator;
		var node = node_list[node_index];
		var freq = node[0].midicps;
		var dur = node[1] / bps;
		var paths = node[2];
		    node_list = ~evalSunsetCounterpoint.value(~octave,~adjust,~durationForRole);
		// Get total statistical weight of connected nodes
		(0 .. paths.size - 1).do {|i| weight = weight + paths[i][1]};

		// Generate random value for choosing next node
		random = weight.rand;

		// Choose next node based on statistical weights
		accumulator = paths[0][1];

		node_index = block {|break|
			paths.size.do {|i|
				if ((random < accumulator), {
					break.value(paths[i][0])
				}, {
					accumulator = accumulator + paths[i + 1][1]
				})
			}
		};

		// Play
		Synth(\melodyFM, [ \amp, 0.1, \freq, freq]);
		Synth(\melodyFM, [ \amp, 0.1, \freq,4.02*freq]);
		Synth(\melodyFM, [ \amp, 0.1, \freq,8.03*freq]);

		dur.wait;
	})
});

	       //  -------------------------------------------------------------  //

r = Routine.new({
		inf.do{
			var fftArray= d.getnSynchronous(~nBin);
			// 1.postln;
			n.sendMsg(\fftArray, *fftArray);  //sending 1024 values
			(1/61).wait;  //a tiny bit faster than framerate
		};
	});
// -----------------------------------------------------------------------------------------------------

~strings.start;
~strings.pause;
~counterpoint.play;
~counterpoint.pause;
~mel.play;
~mel.pause;
}); // end of waitForBoot



// ------------------------------------------------------------------------------------------------------
// ----------------------------------------    OSC SETTING   --------------------------------------------
// ------------------------------------------------------------------------------------------------------


// Use this command to start the server
NetAddr("127.0.0.1",57120);
n= NetAddr("127.0.0.1", 47120);
(
//  ---------- All settings for the different backgrounds
//  --INIT--
OSCdef('init',
	{
		arg msg;
		var freq, amp, cutoff, vibr;

		if(~pureSine.notNil,
			{~pureSine.set(\gate, 0);
				~pureSine = nil;},
			{});

		if(~grains.notNil && ~wdrop.notNil
			,{~grains.set(\gate, 0);
			   ~wdrop.set(\gate, 0);
				~wdrop.free;
			  ~grains = nil;
			  ~wdrop = nil;
			}
			,{});

		if(~trk.notNil,
			{~trk.free; ~trk = nil;
			r.stop; d.free;},
			{});

		if(~crystalString.notNil
			,{~crystalString.free;
				~crystalString = nil;}
			,{});

		if(~chordPad.notNil
			,{~chordPad.free;
				~chordPad = nil;}
			,{});


		~balsam = Synth.new(\init, [\gate, 1]);

	},
	"/Background/Init",);

// -- PLATE --
OSCdef('back1',
	{
		arg msg;
		var freq, amp, cutoff, vibr;

		msg.postln;
		~balsam.set(\gate, 0);
		~balsam = nil;
		~pureSine = Synth(\pureSine, [\gate, 1, \freq, ~freqz]);

		if(~grains.notNil && ~wdrop.notNil
			,{~grains.set(\gate, 0);
			   ~wdrop.set(\gate, 0);
				~wdrop.free;
			  ~grains = nil;
			  ~wdrop = nil;
			}
			,{});

		if(~trk.notNil,
			{~trk.free; ~trk = nil;
			r.stop; d.free;},
			{});

		if(~crystalString.notNil
			,{~crystalString.free;
				~crystalString = nil;}
			,{});

		if(~chordPad.notNil
			,{~chordPad.free;
				~chordPad = nil;}
			,{});

		~strings.pause;
		~mel.pause;
		~counterpoint.pause;

	},
	"/Background/Plate",);
~pureSine.postln;
// -- WATER --
OSCdef('back2',
	{
		arg msg;
		var freq, amp, cutoff, vibr;

		if(~pureSine.notNil,
			{~pureSine.set(\gate, 0);
				~pureSine = nil;},
			{});

		~grains = Synth(\tgrains, [\gate, 1]);
		~wdrop = Synth(\wdrop);

		if(~trk.notNil,
			{~trk.free; ~trk = nil;
			r.stop; d.free;},
			{});

		if(~crystalString.notNil
			,{~crystalString.free;
				~crystalString = nil;}
			,{});

		if(~chordPad.notNil
			,{~chordPad.free;
				~chordPad = nil;}
			,{});

		~mel.pause;
		~counterpoint.pause;

		~strings.pause;


	},
	"/Background/Water",);

// -- SUNSET --
OSCdef('back3',
	{
		arg msg;
		var freq, amp, cutoff, vibr;

		if(~grains.notNil && ~wdrop.notNil
			,{~grains.set(\gate, 0);
			   ~wdrop.set(\gate, 0);
				~wdrop.free;
			  ~grains = nil;
			  ~wdrop = nil;
			}
			,{});


		if(~pureSine.notNil
			,{~pureSine.set(\gate, 0);
				~pureSine = nil;}
			,{});

		d = Bus.control(s, ~nBin);
		~trk= Synth(\avTrk, [\in, 0, \amp, 0.3, \bus, c]);
		r.reset;
		r.play(TempoClock(1,1,0.5), Quant(0,0));

		if(~crystalString.notNil
			,{~crystalString.free;
				~crystalString = nil;}
			,{});

		//~chordPad = Synth(\ChicagoPad);
		~strings.pause;
		~counterpoint.resume;
		~mel.resume;
		~chordPad = Synth(\sunsetPad, [\f1, 48.midicps, \f2 , 60.midicps]);
		~listenToPython = msg[1];
		msg.postln;

	},
	"/Background/Sunset",);

// -- STRINGS --
OSCdef('back4',
	{
		arg msg;
		var freq, amp, cutoff, vibr;

		if(~grains.notNil && ~wdrop.notNil
			,{~grains.set(\gate, 0);
			  ~wdrop.set(\gate, 0);
				~wdrop.free;
			  ~grains = nil;
			  ~wdrop = nil;
			}
			,{});


		if(~pureSine.notNil
			,{~pureSine.set(\gate, 0);
				~pureSine = nil;}
			,{});

		if(~trk.notNil,
			{~trk.free; ~trk = nil;
			r.stop; d.free;},
			{});

		if(~chordPad.notNil
			,{~chordPad.free;
				~chordPad = nil;}
			,{});

		~crystalString = Synth(\crystalString, [\freq, 110,\delT,0.55, \gSize, 0.25, \dw, 0.8, \fb, 0.35]);
        ~mel.pause;
		~counterpoint.pause;
		~strings.resume;
		msg.postln;
		//freq=msg[1];
		//~instr.set(\freq,freq, \amp,amp, \cutoff, cutoff, \vibr, vibr);

	},
	"/Background/Strings",);

// -------- All kinds of control messages received
// Plate
OSCdef('contr0',
	{
		arg msg;
		var freq, amp, cutoff, vibr;

		msg.postln;
		~freqz = msg[1];
		postln(~freqz);
		~pureSine.set(\freq,msg[1]);

		~instr.set(\freq,freq, \amp,amp, \cutoff, cutoff, \vibr, vibr);
	},
	"/Control/setFreq",);

// Water
OSCdef('cont1',
	{
		arg msg;
		var freq, amp, cutoff, vibr;

		if(msg[1] == 1 && ~doOnce == false,

			{~wdrop.set(\gate, 1, \x, msg[2], \y, msg[3]);
			~grains.set(\x, msg[2], \y, msg[3]);
			~doOnce = true;},

			{~wdrop.set(\x, msg[2], \y, msg[3]);
			~grains.set(\x, msg[2], \y, msg[3])}
		);
		msg.postln;
		if(msg[1] == 0,
			{~doOnce = false; ~wdrop.set(\gate, 0)},
			{}
		);

	},
	"/Control/waterDrop",);

// Sunset    --- we control the modal scale of the melody and counterpoints, chords are controlled via Phyton
OSCdef('cont2',
	{
		arg msg;
		msg.postln;
		~adjust.size.do({|i|
			~adjust[i] = msg[i+2];
		});
		~adjust.postln;
	},
	"/Control/sunModeChange/Mode",);

 // Sunset    --- we control the modal scale of the melody and counterpoints, chords are controlled via Phyton
 OSCdef('cont3',
 	{
 		arg msg;
 		msg.postln;
 		// t = tonic // c = chord // s = scale //  a = approach // d = dominant
 		~durationForRole.size.do({|i|
			if(msg[i+2] == 't'
 				,{~durationForRole[i] = [ 1, 4 ].wchoose([0.8, 0.2])}
 			,{});

 			if(msg[i+2] == 'c'
 				,{~durationForRole[i] = [ 0.5, 1, 1.5, 2].wchoose([ 0.1, 0.45, 0.45])}
 			,{});

 			if(msg[i+2] == 's'
 				,{~durationForRole[i] =  [ 0.5, 1, 1.5, 2].wchoose([ 0.2, 0.4, 0.3])}
 			,{});

 			if(msg[i+2] == 'a'
 				,{~durationForRole[i] = [ 0.25, 0.5, 1].wchoose([0.1, 0.7, 0.2])}
 			,{});

 			if(msg[i+2] == 'd'
 				,{~durationForRole[i] = [ 0.25, 0.5, 1, 2].wchoose([ 0.05, 0.1, 0.45, 0.4])}
 			,{});


 		});
 		~durationForRole.postln;
 	},
	"/Control/sunModeChange/Role",);

// Strings
OSCdef('cont4',
	{
		arg msg;

		msg.postln;

		~crystalString.set(\t_trig, 1, \pShift, 600, \freq, (48+msg[1]).midicps );
		~tonality = msg[1];
		//~instr.set(\freq,freq, \amp,amp, \cutoff, cutoff, \vibr, vibr);
	},
	"/Control/StringPlucked",);


OSCdef('pyChord',
	{
		arg msg;
		var chord,note1,note2, add;
		msg.postln;
		add = 48;
		note1 = msg[1]+add;
		note2 = msg[2]+add;
		if(~listenToPython == true,
		{~chordPad.set(\f1, note1.midicps, \f2, note2.midicps);},
		{});

}, '/Python/Chords' );


OSCdef('pyListen',
	{
		arg msg;
		msg.postln;
		~listenToPython = msg[1];

}, '/Control/pythonListen' );

)
)
~listenToPython.postln;



~counterpoint.play;
;

~mel.pause
