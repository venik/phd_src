function init_rand(seed)
CompatibilityMode = 0 ;
if CompatibilityMode
    rng(seed,'twister') ;
else
    s = RandStream('mt19937ar','Seed', seed) ;
    RandStream.setDefaultStream(s) ;
end