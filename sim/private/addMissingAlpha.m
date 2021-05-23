function tissue = addMissingAlpha(tissue, freq_MHz, alpha_power)
% Sets .alphaCoeff, in necessary
%   tissue:         struct (brain, skull, or water)
%   freq_MHz:       acoustic frequency (scalar)
%   alpha_power:    alpha power (scalar)
if ~isfield(tissue, 'alphaCoeff')
    % Check if need to produce precursor too
    if ~isfield(tissue, 'attenConstant_dB_cm')
        tissue.attenConstant_dB_cm = NptodB(tissue.attenConstant_Np_m) / 100;
    end
    % Produce it from other values
    tissue.alphaCoeff = tissue.attenConstant_dB_cm /...
        (freq_MHz^alpha_power); % [dB/(MHz^y cm)]
end
end