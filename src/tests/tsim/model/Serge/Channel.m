classdef(Sealed) Channel < handle
	%CHANNEL Summary of this class goes here
	%   Detailed explanation goes here
	
	properties(SetAccess = private)
		State = 'inactive';
		detector;
		tracker;		
		PRN = 0;
		I = [];
		Q = [];
		CodeError = [];
		CarrierError = [];
		time = 1;
	end
	
	properties(Access = private)
		settings = initSettings();
		signalSource;
	end
	
	methods
		
		function this = Channel(PRN, signalSource)
			this.PRN = PRN;
			this.signalSource = signalSource;
			this.detector = Detector(PRN, this.signalSource);
			this.tracker = Tracker(PRN, this.signalSource);
			
			if this.settings.startTime > 0
				this.signalSource.Move(this.settings.startTime* ...
					this.tracker.bufferSize);
			end
			
			proc_time = this.settings.processTime;
			if this.settings.processTime == Inf
				proc_time = 60000;
			end
			
			this.I = zeros(proc_time, 1);
			this.Q = zeros(proc_time, 1);
			this.CodeError = zeros(proc_time, 1);
			this.CarrierError = zeros(proc_time, 1);
		end
		
		function Search(this)
			this.detector.Execute();
			if strcmp(this.detector.State, 'detected')
				this.State = 'active';
			end
		end
		
		function Run(this)
			if strcmp(this.State, 'inactive')
				this.Search();
			end
			
			if strcmp(this.State, 'active')
				this.tracker.Init(this.detector.CodePhase, ...
					this.detector.Frequency);
				
				while true
					this.tracker.Execute();

					if strcmp(this.tracker.State, 'nodata')
						break
					end

					this.I(this.time) = this.tracker.I;
					this.Q(this.time) = this.tracker.Q;
					this.CodeError(this.time) = this.tracker.codeErr;
					this.CarrierError(this.time) = this.tracker.carrErr;

					if this.time == this.settings.processTime
						break
					else
						this.time = this.time + 1;
					end
				end
			end
		end
		
	end
	
end