classdef(Sealed) Receiver < handle
	%RECEIVER Summary of this class goes here
	%   Detailed explanation goes here
	
	properties(Access = private)
		settings = initSettings();
	end
	
	properties(SetAccess = private)
		channels = [];
		channelsCount = 0;
	end
	
	methods
		
		function this = Receiver()
			prn_list = this.settings.acqPRNList;
			this.channelsCount = size(prn_list, 2);
			for ch_idx = 1:this.channelsCount
				ss = FileSource(this.settings.fileName, 'int8', 'r');
				ch = Channel(prn_list(ch_idx), ss);
				this.channels = [this.channels; ch];
			end
		end
		
		function Run(this, isTrack)
			for ch_idx = 1:this.channelsCount
				channel = this.channels(ch_idx);
				channel.Search();
				if isTrack
					channel.Run();
				end
			end
		end
		
	end
	
end

