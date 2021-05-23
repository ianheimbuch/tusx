function CPUorGPU = setParallel(runOnGPU)
%SETPARALLEL Set k-Wave to run simulation on parallel (CUDA) or not (CPU)
%   If runOnGPU == true:  Tries to run on parallel
%   If runOnGPU == false: Runs on CPU
%
%   For simulation3D_setup()

% Check input is boolean/logical
if ~islogical(runOnGPU)
    error('Parameter "runOnGPU" must be logical/boolean');
end

if runOnGPU == true
    g = gpuDevice;
    cuda = str2num(g.ComputeCapability);
    
    if cuda >=3          % CUDA version 3.0 or higher
        CPUorGPU = 'gpuArray-single';   % Matlab minimum is 3.0
        disp('Running on GPU')
    else
        CPUorGPU = 'single';
        warning('GPU CUDA version does not meet minimum requirement. Running on CPU instead')
    end
else
    CPUorGPU = 'single';
end
end