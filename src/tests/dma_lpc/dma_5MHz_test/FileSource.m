classdef(Sealed) FileSource < SignalSource
	%FILESOURCE Summary of this class goes here
	%   Detailed explanation goes here
	
	properties (Access = private)
		file;
		elType = '';
		format = '';
		elBySample = 0;
	end

	properties(SetAccess = protected)
		position;
	end
	
	properties (SetAccess = private)
		fileName = '';
	end
		
	methods
		
		function this = FileSource(fileName, elType, format)
			this.fileName = fileName;
			this.elType = elType;
			switch format
				case 'r'
					this.elBySample = 1;
				case {'iq', 'qi'}
					this.elBySample = 2;
				otherwise
					error('Unknown format');
			end
			this.format = format;
			this.file = fopen(this.fileName, 'r');
		end
		
		function delete(this)
			fclose(this.file);
		end
		
		function value = get.position(this)
			value = ftell(this.file)/this.elBySample;
		end
		
		function [samples, count] = Peek(this, size, offset)
			pos = this.position;
			this.Move(offset);
			[samples, count] = this.Read(size);
			fseek(this.file, pos, 'bof');
		end
		
		function [samples, count] = Read(this, size)
			samples = fread(this.file, size*this.elBySample, this.elType);
			switch this.format
				case 'iq'
					samples = samples(1:2:end) + 1i*samples(2:2:end);
				case 'qi'
					samples = samples(2:2:end) + 1i*samples(1:2:end);
			end
			count = numel(samples);
		end
		
		function status = Move(this, offset)
			status = fseek(this.file, offset*this.elBySample, 'cof') == 0;
		end
		
	end
	
end

