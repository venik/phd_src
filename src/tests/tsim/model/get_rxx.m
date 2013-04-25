function rxx = get_rxx(signal2ms, Indices )
msSamples = length(signal2ms)/2 ;
rxx = zeros(size(Indices)) ;
for n=1:numel(Indices)
    rxx(n) = sum(signal2ms(1:msSamples).*conj(signal2ms(1+Indices(n):msSamples+Indices(n))))/msSamples ;
%    rxx(n) = sum(signal2ms(1:msSamples).*conj([signal2ms(1+Indices(n):msSamples) signal2ms(1:Indices(n))]))/msSamples ;
end
