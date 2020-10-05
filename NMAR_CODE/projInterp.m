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

%���д���
for i = 1:NumofView
    
    %����ͶӰ��
    mslice = metalTrace(:,i);
    %ԭͼͶӰ��
    pslice = proj(:,i);
    pslice = dot_mean( mslice, pslice, num_mean );
    
    %��������
    metalpos = find(mslice);
    %��������
    nonmetalpos = find(mslice==0);
    
    %ԭͼͶӰ�еķǽ���
    pnonmetal = pslice(nonmetalpos);
    
    %���Բ�ֵ���
    pslice(metalpos) = (interp1(nonmetalpos,pnonmetal,metalpos))';
    Pinterp(:,i) = pslice;

end
