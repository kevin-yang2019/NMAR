function imNMAR2 = nmar(proj, imRaw, imLI, metalTrace, metalBW, miuWater)

% This code is to reproduce normalized metal artifact reduction (NMAR) method
% using prior images generated from uncorrected and LI corrected images, respectively.
% Meyer, Esther, et al. "Normalized metal artifact reduction (NMAR) in computed 
% tomography." Medical physics 37.10 (2010): 5482-5493.
%
% Input:
% proj:         uncorrected projection
% imRaw:        uncorrected image (1/cm)
% imLI:         linear interpolation corrected image (1/cm)
% metalTrace:   metal trace in projection domain (binary image)
% metalBW:      binary metal image
% miuWater:     linear attenuation coefficient of water (1/cm)
% Output:
% imNMAR1:      NMAR corrected image using the prior from uncorrected image (1/cm)
% imNMAR2:      NMAR corrected image using the prior from LI image (1/cm)


miuAir = 0;     
smFilter = fspecial('gaussian',[5 5],1);  %滤波算子，sigma，标准差=1


%% NMAR method 1: Raw（伪影较轻，无需进行预校正）

% imRaw(metalBW) = miuWater;  % metal
% im1d = reshape(imRaw, numel(imRaw), 1);
% im1d(im1d < 0.22) = miuAir;
% 
% [reconidx,~] = kmeans(im1d, 3, 'Replicates',  1, 'start', [miuAir; 1.5*miuWater; 3*miuWater]);% [miuAir; miuWater; 2*miuWater] is the center of each class
% threshBone1 = min(im1d(reconidx==3));
% threshBone1 = max([threshBone1, 1.2*miuWater]); % not smaller than 200 HU
% threshWater1 = min(im1d(reconidx==2));
% 
% imPriorNMAR1 = nmarPrior(imRaw,threshWater1,threshBone1,miuAir,miuWater,smFilter);
% 
% projPrior1 = mfanbeam(imPriorNMAR1);  %先验投影图
% 
% PNMAR1 = nmar_proj(proj, projPrior1, metalTrace);  %归一化插值
% 
% imNMAR1 = mifanbeam(PNMAR1);  %反投影


%% NMAR method 2: LI  （伪影严重，使用FBP预校正）

imLI(metalBW) = miuWater;  %金属区域填充
im1d = reshape(imLI, numel(imLI), 1);


[reconidx,~] = kmeans(im1d, 3, 'Replicates', 8, 'replicates', 1 , 'start', [miuAir; miuWater; 2*miuWater]);  %聚类分割

threshBone2 = min(im1d(reconidx==3));
threshBone2 = max([threshBone2, 1.2*miuWater]);
threshWater2 = min(im1d(reconidx==2));

imPriorNMAR2 = nmarPrior(imLI,threshWater2,threshBone2,miuAir,miuWater,smFilter);  %填充

projPrior2 = mfanbeam(imPriorNMAR2);  %先验投影图

PNMAR2 = nmar_proj(proj, projPrior2, metalTrace);  %归一化插值

imNMAR2 = mifanbeam(PNMAR2);  %反投影

end

%% generate a prior image

function priorimgHU = nmarPrior(im,threshWater,threshBone,miuAir,miuWater,smFilter)

imSm = imfilter(im,smFilter,'replicate');  %滤波
priorimgHU = imSm;
priorimgHU(imSm<=threshWater) = miuAir;
priorimgHU(intersect(find(imSm>threshWater),find(imSm<threshBone))) = miuWater;

end

%% normalized interpolation in projection domain

function Pnmar = nmar_proj(proj,Pprior,metalTrace)
 
Pprior(Pprior<0) = 0;
eps = 10^(-6);
Pprior = Pprior + eps;
Pnorm = proj./Pprior;
Pnorminterp = projInterp(Pnorm,metalTrace,1);
Pnmar = Pnorminterp.*Pprior;
nonmetalpos = find(metalTrace == 0);
Pnmar(nonmetalpos) = proj(nonmetalpos);

end

