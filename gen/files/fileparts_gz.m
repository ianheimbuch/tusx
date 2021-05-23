function [filepath,name,ext] = fileparts_gz(filename)
%fileparts_gz Wrapper of fileparts() that takes into account gzipped files
%   [filepath,name,ext] = fileparts_gz(filename)
[filepath,name,ext] = fileparts(filename);
switch ext
    case '.gz'
        ext_gz = ext;
        [filepath,name,ext] = fileparts(fullfile(filepath, name));
        ext = strcat(ext, ext_gz);
    otherwise
end
end