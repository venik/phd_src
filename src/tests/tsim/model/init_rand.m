function init_rand(seed)
CompatibilityMode = 1 ;
if CompatibilityMode
    rng(seed,'twister') ;
else
    s = RandStream('mt19937ar','Seed', seed) ;
    RandStream.setGlobalStream(s) ;
end