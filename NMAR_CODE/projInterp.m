function Pinterp = projInterp(proj,metalTrace,num_mean)
% projection linear interpolation
% Input:
% proj:         uncorrected projection
% metalTrace:   metal trace in projection domain (binary image)
% num_mean:   number of pixel used in interpolation
% Output:
% Pinterp:      linear interpolation corrected projection
if nargin < 3
    num_mean = 1;
end

[NumofBin, NumofView] = size(proj);
Pinterp = zeros(NumofBin, NumofView);

%按列处理
for i = 1:NumofView
    
    %金属投影列
    mslice = metalTrace(:,i);
    %原图投影列
    pslice = proj(:,i);
    pslice = dot_mean( mslice, pslice, num_mean );
    
    %金属区域
    metalpos = find(mslice);
    %其他区域
    nonmetalpos = find(mslice==0);
    
    %原图投影中的非金属
    pnonmetal = pslice(nonmetalpos);
    
    %线性插值填充
    pslice(metalpos) = (interp1(nonmetalpos,pnonmetal,metalpos))';
    Pinterp(:,i) = pslice;

end
