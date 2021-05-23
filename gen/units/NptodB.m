%Np to dB (Neper to Decibel)
function dB = NptodB(Np)
    dB = Np * ( 20 / log(10) ); %log() is natural log
end