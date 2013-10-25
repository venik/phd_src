function [y, scale_y] = quantize_nbits(x,nbits)

% compute nBits representation limits
% zero value is disabled
nBitsUpLimit = 2^(nbits-1) ;
nBitslowLimit = -2^(nbits-1) ;

% compute scale factor
scale_y = 1.5*nBitsUpLimit/max(abs(x)) ;

% quantize signal
y = round(x*scale_y) ;

% apply quantization limits
y(y>nBitsUpLimit) = nBitsUpLimit ;
y(y<nBitslowLimit) = nBitslowLimit ;
