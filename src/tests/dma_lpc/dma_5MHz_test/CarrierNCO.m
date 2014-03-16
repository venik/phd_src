classdef(Sealed) CarrierNCO < handle
	%CARRIERNCO Summary of this class goes here
	%   Detailed explanation goes here
	
	properties(Access = private)
		Settings = initSettings();
	end
	
	properties(SetAccess = private)
		RP = 0;
		Phase = 0;
	end
	
	properties
		IgnorePhaseReminder = false;
	end

	methods
		
		function signal = Execute(this, freq, size)
			phaseStep = 2*pi*freq/this.Settings.samplingFreq;
			a = phaseStep*(0:size)';
			if ~this.IgnorePhaseReminder, a = a + this.RP; end
			this.RP = mod(a(end), 2*pi);
			
			phase = mod(a, 2*pi);
			signal = exp(1i*phase(1:size));

			this.Phase = a(1);
		end
		
		function Reset(this)
			this.RP = 0;
		end
		
	end
	
end