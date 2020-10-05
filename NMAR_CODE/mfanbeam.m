function proj = mfanbeam(miu)
%  radon transform
% Input:
% miu:       linear attenuation coefficient of tissue (1/cm)
% Output:
% proj:       projection

CTpara = CTscanpara();
proj = fanbeam(single(miu), CTpara.SOD,...
    'FanSensorGeometry','arc',...
    'FanSensorSpacing', CTpara.angsize, ...
    'FanRotationIncrement',360/CTpara.AngNum);
% proj = radon(single(miu), 0:.5:179.5);
proj = proj*CTpara.imPixScale;
end

