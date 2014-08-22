classdef SignalSource < handle
	%SIGNALSOURCE Summary of this class goes here
	%   Detailed explanation goes here
	
	properties (SetAccess = protected, Abstract)
		position;
	end
	
	methods(Abstract)
		[samples, count] = Peek(this, size, offset);
		[samples, count] = Read(this, size);
		status = Move(this, offset);
	end
	
end