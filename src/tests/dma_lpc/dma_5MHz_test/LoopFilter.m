classdef(Sealed) LoopFilter < handle
	%LOOPFILTER Summary of this class goes here
	%   Detailed explanation goes here
	
	properties(Access = private)
		k1 = 0;
		k2 = 0;		
		prev_y = 0;
		prev_x = 0;
		first = true;
	end
	
	methods
		
		function this = LoopFilter(T, k, LBW, zeta)
			Wn = LBW*8*zeta/(4*zeta^2 + 1);
			tau1 = k/Wn^2;
			tau2 = 2*zeta/Wn;
			this.k1 = tau2/tau1;
			this.k2 = T/tau1;
		end
		
		function y = Execute(this, x)
			if this.first, this.prev_x = x; this.first = false; end
			y = this.k1*(x - this.prev_x) + this.k2*x + this.prev_y;
			this.prev_y = y;
			this.prev_x = x;
		end
		
	end
	
end

