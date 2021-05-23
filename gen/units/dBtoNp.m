%dB to Np (decibel to Neper)
function Np = dBtoNp(dB)
    Np = dB * (log(dB)/20); %log() is natural log
end