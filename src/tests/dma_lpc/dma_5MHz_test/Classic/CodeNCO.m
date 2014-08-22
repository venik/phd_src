classdef CodeNCO < handle
	%CODEGENERATOR Summary of this class goes here
	%   Detailed explanation goes here
	
	properties (Access = private)
		Settings = initSettings();
		caCode;
	end
	
	properties(SetAccess = private)
		PRN = 0;
		RP = 0;
		Phase = 0;
	end
	
	properties
		IgnorePhaseReminder = false;
	end
	
	methods
		
		function this = CodeNCO(PRN)
			this.PRN = PRN;
			this.caCode = CACode(PRN);
		end
		
		function [P E L] = Execute(this, freq, size)
			phaseStep = freq/this.Settings.samplingFreq;
			a = phaseStep*(0:size)';
			if ~this.IgnorePhaseReminder, a = a + this.RP; end
            
			this.RP = mod(a(end), 1023);
			
			p_phase = mod(phaseStep + a, 1023);
			e_phase = mod(phaseStep + a + this.Settings.corrSpacing, 1023);
			l_phase = mod(phaseStep + a - this.Settings.corrSpacing, 1023);
			
			e_idx = ceil(e_phase(1:size));
			l_idx = ceil(l_phase(1:size));
			p_idx = ceil(p_phase(1:size));
			
			E = this.caCode.Bits(e_idx + 1023*0.5*(abs(1 - e_idx) - e_idx + 1));
			L = this.caCode.Bits(l_idx + 1023*0.5*(abs(1 - l_idx) - l_idx + 1));
			P = this.caCode.Bits(p_idx + 1023*0.5*(abs(1 - p_idx) - p_idx + 1));
			
			this.Phase = a(1);
		end
		
		function Reset(this)
			this.RP = 0;
		end
	
	end
	
end