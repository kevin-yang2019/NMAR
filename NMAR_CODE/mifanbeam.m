function miu = mifanbeam(proj)
%   inverse radon transform
% Input:
% proj:       projection
% Output:
% miu:       linear attenuation coefficient of tissue (1/cm)

CTpara = CTscanpara();
miu = ifanbeam(proj,CTpara.SOD,...
    'FanSensorGeometry','arc',...
    'FanSensorSpacing',CTpara.angsize,...
    'OutputSize',CTpara.imPixNum,... 
    'FanRotationIncrement',360/CTpara.AngNum);
% miu = iradon(single(proj), 0:.5:179.5, 'nearest', 'Ram-Lak', 512);
miu = miu/CTpara.imPixScale;
end

