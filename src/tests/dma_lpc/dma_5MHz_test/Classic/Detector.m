classdef Detector < handle
	%DETECTOR Summary of this class goes here
	%   Detailed explanation goes here
	
	properties (Access = private)
		Settings = initSettings();
		Source;
		carrNCO;
		codeNCO;
		DopplerBins = [];
		DopplerBinsCount = 0;
		LocalSignals = [];
		caPeriodSize = 0;
	end
	
	properties (SetAccess = private)
		PRN = 0;
		State = '-';
		RSSI = 0;
		CodePhase = 0;
		Frequency = 0;
	end
	
	methods
		
		function this = Detector(PRN, signalSource)
			this.PRN = PRN;
			this.Source = signalSource;
			
			this.carrNCO = CarrierNCO();
			this.carrNCO.IgnorePhaseReminder = true;
			this.codeNCO = CodeNCO(PRN);
			this.codeNCO.IgnorePhaseReminder = true;

			this.caPeriodSize = round(this.Settings.samplingFreq/ ...
				(this.Settings.codeFreqBase/this.Settings.codeLength));

			this.DopplerBins = (0:this.Settings.acqSearchStep:this.Settings.acqSearchBand) - ...
				this.Settings.acqSearchBand/2;
			this.DopplerBinsCount = numel(this.DopplerBins);
			
			this.InitLocalSignals();
		end
		
		function Execute(this)
			[samples, count] = this.Source.Peek(this.caPeriodSize, 0);

			if count < this.caPeriodSize
				this.State = 'nodata';
				return;
			end
			
			Rs = fft(samples);
			
			for dopplerBinIdx = 1:this.DopplerBinsCount
				Ls = this.LocalSignals(:, dopplerBinIdx);
				[rssi, codePhaseIdx] = max(abs(ifft(Rs.*Ls)).^2);
				if rssi > this.RSSI
					this.RSSI = rssi;
					this.CodePhase = codePhaseIdx - 1;
					this.Frequency = this.Settings.IF + ...
						this.DopplerBins(dopplerBinIdx);
				end
			end
			
			if this.RSSI > this.Settings.acqThreshold
				switch this.Settings.ffAlg
					case 'tsui'
						this.Frequency = round(this.FineFreq());
					case 'alex'
						block_size = 2*this.caPeriodSize;
						[samples, count] = this.Source.Peek(block_size, ...
							this.CodePhase);

						if count < block_size
							this.State = 'nodata';
							return;
						end
						
						code = this.codeNCO.Execute(this.Settings.codeFreqBase, block_size);
						
						[ff, pwr] = this.get_precise_frequency2(samples.*code, ...
							this.Frequency, this.Settings.samplingFreq);
						this.Frequency = round(ff);
				end
				this.State = 'detected';
			else
				this.State = 'notdetected';
			end
		end
		
	end
	
	methods (Access = private)
		
		function InitLocalSignals(this)
			this.LocalSignals = zeros(this.caPeriodSize, this.DopplerBinsCount);
			for dopplerBinIdx = 1:this.DopplerBinsCount
				doppler_shift = this.DopplerBins(dopplerBinIdx);
				
				carr_freq = this.Settings.IF + doppler_shift;
				code_freq = this.Settings.codeFreqBase; %* ... 
				%	(1 + doppler_shift/this.Settings.L1Freq);
				
				code = this.codeNCO.Execute(code_freq, this.caPeriodSize);
				carrier = this.carrNCO.Execute(carr_freq, this.caPeriodSize);
				this.LocalSignals(:, dopplerBinIdx) = code.*carrier;
			end
			this.LocalSignals = conj(fft(this.LocalSignals));
		end
		
		function freq = FineFreq(this)
			block_size = 5*this.caPeriodSize;
			[samples, count] = this.Source.Peek(block_size, this.CodePhase);
			
			if count < block_size
				this.State = 'nodata';
				return;
			end
			
			code = this.codeNCO.Execute(this.Settings.codeFreqBase, block_size);
			cw5 = samples.*code;
			
			% find medium freq resolution 400 kHz apart
			for i = 1:3;
				fr = this.Frequency - 400 + (i - 1)*400;
				mfrq1(i) = abs(sum(cw5(1:this.caPeriodSize).* ...
					this.carrNCO.Execute(fr, this.caPeriodSize)));
			end
			[~, mrw] = max(mfrq1); % find highest peak
			fr = this.Frequency + 200*(mrw - 2); % medium freq

			
			% find fine freq
			zb5 = cw5.*this.carrNCO.Execute(fr, block_size);
			zc5 = diff(-angle(sum(reshape(zb5, this.caPeriodSize, 5)))); % find difference angle
			zc5fix = zc5;
 
			
			% Adjust phase and take out possible phase shift
			threshold = 2.3*pi/5;
			for i = 1:4
				% angle adjustment
				if abs(zc5(i)) > threshold
					zc5(i) = zc5fix(i) - 2*pi;
				else continue;
				end
				
				if abs(zc5(i)) > threshold
					zc5(i) = zc5fix(i) + 2*pi;
				else continue;
				end
				% /angle adjustment
				
				% pi phase shift correction
				if abs(zc5(i)) > threshold
					zc5(i) = zc5fix(i) - pi;
				else continue;
				end
				
				if abs(zc5(i)) > threshold
					zc5(i) = zc5fix(i) + pi;
				else continue;
				end
				% /pi phase shift correction
				
				if abs(zc5(i)) > threshold
					zc5(i) = zc5fix(i) - 2*pi;
				else continue;
				end

				if abs(zc5(i)) > threshold
					zc5(i) = zc5fix(i) + 2*pi;
				end
			end
			dfrq = mean(zc5)*1000/(2*pi);
			freq = fr + dfrq; % fine freq
		end
		
		function [preciseFreq, precisePower] = get_precise_frequency2(~, signal2ms, initialFreq, samplingFreq)
			% estimation parameters
			n1 = 14 ;
			n2 = 15 ;
			Nnw = 12 ; % Number of Newton iterations

			% estimation algorithm
			msSamples = length(signal2ms)/2 ;

			% estimate rxx
			totalPower = sum(signal2ms(1:msSamples).*conj(signal2ms(1:msSamples)))/msSamples ;
			r1 = sum(signal2ms(1:msSamples).*conj(signal2ms(1+n1:msSamples+n1)))/msSamples ;
			r2 = sum(signal2ms(1:msSamples).*conj(signal2ms(1+n2:msSamples+n2)))/msSamples ;

			z = zeros(2,Nnw) ;
			initialPower = totalPower*.8 ;
			InitialAlpha = 2*pi*initialFreq/samplingFreq*n1 ;
			z(:,1) = [initialPower InitialAlpha] ;
			for n=2:Nnw
				N_gamma = z(1,n-1) ;
				N_alpha = z(2,n-1) ;
				F = [N_gamma*cos(N_alpha)-r1; N_gamma*cos(n2/n1*N_alpha)-r2] ;
				J = [cos(N_alpha),        -N_gamma*sin(N_alpha); ...
					 cos(n2/n1*N_alpha),  -n2/n1*N_gamma*sin(n2/n1*N_alpha)] ;
				z(:,n) = z(:,n-1) - pinv(J)*F ;
			end

			preciseFreq = z(2,end)/2/pi*samplingFreq/n1 ;
			precisePower = z(1,end) ;
		end
		
	end
	
end