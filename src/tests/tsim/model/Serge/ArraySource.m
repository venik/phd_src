classdef(Sealed) ArraySource < SignalSource
    %ARRAYSOURCE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Access = private)
        data = [];
	end
    
	properties(SetAccess = protected)
		position = 0;
	end
	
	properties(SetAccess = private)
        size = 0;
    end
	
    methods
        
        function  this = ArraySource(data)
            this.data = data;
            this.size = numel(data);
		end
		
		function [samples, count] = Peek(this, size, offset)
			pos = this.position + offset;
			if size < 0 || pos < 0
				count = 0;
				samples = [];
				return
			end
			count = min([size; this.size - pos]);
			samples = this.data(pos + (1:count)');
		end
		
		function [samples, count] = Read(this, size)
			[samples, count] = this.Peek(size, 0);
			this.Move(count);
		end
		
		function status = Move(this, offset)
			new_pos = this.position + offset;
			status = new_pos >= 0 && new_pos <= this.size;
			if status
				this.position = new_pos;
			end
		end
        
	end
    
end

