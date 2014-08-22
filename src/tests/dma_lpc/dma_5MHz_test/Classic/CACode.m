classdef (Sealed) CACode < handle
	%CACODE Summary of this class goes here
	%   Detailed explanation goes here
	
	properties (SetAccess = private)
		PRN;
		Bits;
	end
	
	methods
		
		function this = CACode(PRN)
			shiftTable = [
				5;		6;		7;		8;
				17;		18;		139;	140;
				141;	251;	252;	254;
				255;	256;	257;	258;
				469;	470;	471;	472;
				473;	474;	509;	512;
				513;	514;	515;	516;
				859;	860;	861;	862;
				];
			shift = shiftTable(PRN, 1);
			
			g1 = zeros(1023, 1);
			g2 = zeros(1023, 1);

			% ******* Generate G1 code *******
			% load shift register
			reg = -1*ones(10, 1);
			for i = 1:1023
				g1(i) = reg(10);
				save1 = reg(3)*reg(10);
				reg(2:10) = reg(1:9);
				reg(1) = save1;
			end

			% ******* Generate G2 code *******
			% load shift register
			reg = -1*ones(10, 1);
			for i = 1:1023
				g2(i) = reg(10);
				save2 = reg(2)*reg(3)*reg(6)*reg(8)*reg(9)*reg(10);
				reg(2:10) = reg(1:9);
				reg(1) = save2;
			end

			% ******* Shift G2 code *******
			g2tmp(1:shift, 1) = g2(1023 - shift + 1:1023);
			g2tmp(shift + 1:1023, 1) = g2(1:1023 - shift);
			g2 = g2tmp;

			% ******* Form single sample C/A code by multiplying G1 and G2
			ss_ca = g1.*g2;
			this.Bits = -ss_ca;
			this.PRN = PRN;
		end
		
	end
	
end

