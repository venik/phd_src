classdef Tracker < handle
	%TRACKER Summary of this class goes here
	%   Detailed explanation goes here
	
	properties (SetAccess = private)
		State = '-';
		PRN = 0;
		bufferSize = 0;
		I = 0;
		Q = 0;
		CarrierFrequency = 0;
		CodeFrequency = 0;
		carrErr = 0;
		codeErr = 0;
	end
	
	properties %(Access = private)
		Settings = initSettings();
		Source;
		BaseCodeFrequency = 0;
		BaseCodePhase = 0;
		BaseCarrierFrequency = 0;
		codeNCO;
		carrNCO;
		DLLLoopFilter;
		PLLLoopFilter;
	end
	
	methods
		
		function this = Tracker(PRN, signalSource)
			this.Source = signalSource;
			this.PRN = PRN;
			
			this.codeNCO = CodeNCO(this.PRN);
			this.carrNCO = CarrierNCO();
			
			this.bufferSize = round(this.Settings.samplingFreq/ ...
				(this.Settings.codeFreqBase/this.Settings.codeLength));
			
			this.DLLLoopFilter = LoopFilter(0.001, ...
				this.Settings.DLL_K, ...
				this.Settings.DLL_LBW, ...
				this.Settings.DLL_zeta);
			this.PLLLoopFilter = LoopFilter(0.001, ...
				this.Settings.PLL_K, ...
				this.Settings.PLL_LBW, ...
				this.Settings.PLL_zeta);
		end
		
		function Execute(this)
			if ~any(strcmp(this.State, {'ready'; 'tracking'}))
				return
			end
			
			[samples, count] = this.Source.Read(this.bufferSize);
			
			if count < this.bufferSize
				this.State = 'nodata';
				return
			end
			
			% Генераторы локальных копий сигналов
			[PCode ECode LCode] = this.codeNCO.Execute(this.CodeFrequency, ...
				this.bufferSize);
			carrier = this.carrNCO.Execute(this.CarrierFrequency, ...
				this.bufferSize);
			
			LS = carrier.*samples;
			E = sum(LS.*ECode);
			P = sum(LS.*PCode);
			L = sum(LS.*LCode);
			this.I = imag(P);
			this.Q = real(P);
			I_E = imag(E);
			Q_E = real(E);
			I_L = imag(L);
			Q_L = real(L);

			% Дискриминаторы PLL, DLL
			this.carrErr = atan(this.Q/this.I)*2/pi;
                this.codeErr = ((I_E^2 + Q_E^2) - (I_L^2 + Q_L^2))/ ...
                    ((I_E^2 + Q_E^2) + (I_L^2 + Q_L^2));

			% Петлевые фильтры PLL, DLL
			this.CarrierFrequency = this.BaseCarrierFrequency + ...
				this.PLLLoopFilter.Execute(this.carrErr);
			this.CodeFrequency = this.BaseCodeFrequency + ...
				this.DLLLoopFilter.Execute(this.codeErr);
			
			%TODO: Доработать случай с потерей сигнала
			this.State = 'tracking';
		end
		
		function Init(this, codePhase, frequency)
			% Частота CA кода с компенсацией доплеровского смещения
			codeFreq = this.Settings.codeFreqBase* ...
				(1 + (frequency - this.Settings.IF)/this.Settings.L1Freq);
			this.BaseCodePhase = codePhase;
			this.BaseCodeFrequency = codeFreq;
			this.CodeFrequency = codeFreq;
			
			this.BaseCarrierFrequency = frequency;
			this.CarrierFrequency = frequency;
			
			this.codeNCO.Reset();
			this.carrNCO.Reset();
			
			if this.Source.Move(this.BaseCodePhase)
				this.State = 'ready';
			else
				this.State = 'nodata';
			end
		end
		
	end
	
end

