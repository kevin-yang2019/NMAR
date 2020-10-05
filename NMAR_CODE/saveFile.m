%运行该文件，使用NMAR方法完成金属伪影图像的修复,并保存结果

close all;clear;fclose all;

miuWater = 0.192;
thresh_air = -600;
kernel_size = 5;

uiwait(msgbox('先选择病例文件，再选择结果保存位置！','help','modal'));
input = uigetdir('','选择病例文件夹');
input = strcat(input,'\');

 dcmOut = uigetdir('','选择结果保存位置');
dcmOut = strcat(dcmOut,'\');

fileFolder=fullfile(input);
dirOutput=dir(fullfile(fileFolder,'*.dcm'));
fileNames={dirOutput.name};

inputPath = fileNames;
% dcmOutPath = fileNames;
% pngOutPath = fileNames;

dcm_input = zeros([512 512 numel(fileNames)]);
dcms_info = cell(numel(fileNames), 1);
dcm_output = zeros([512 512 numel(fileNames)], 'int16');
cnt = 0;
disp(numel(fileNames));

tic
for i = 1:numel(fileNames)
    inputPath{i} = [input,fileNames{i}];
    Image_dicom=dicomread(inputPath{i}); 
    if size(Image_dicom, 1) ~= 512 || size(Image_dicom, 2) ~= 512
        continue;
    end
    dicom_info = dicominfo(inputPath{i});
    cnt = cnt + 1;
    dcms_info{cnt} = dicom_info;
    dcm_input(:,:,cnt)=Image_dicom;
    disp(i);
end    



parfor i = 1:cnt
    dcm_src = double(dcm_input(:,:,i)) + dcms_info{i}.RescaleIntercept;
    [Image_dicom, close_region] = ROI(dcm_src,thresh_air,kernel_size);
    Image_dicom = double(Image_dicom);
    if max(max(Image_dicom)) > 3000
        Image_dicom(close_region==0) = -1000;
        NMAR_dcm = preNMAR(Image_dicom);
        NMAR_dcm(close_region==0) = dcm_src(close_region==0);
        dcm_output(:,:,i) = NMAR_dcm - dcms_info{i}.RescaleIntercept;
    else
        dcm_output(:,:,i) = dcm_src - dcms_info{i}.RescaleIntercept;
    end
    disp(['第',num2str(i),'层处理完成']);
end



for i = 1:cnt
    dcm = dcm_output(:,:,i);
    dicomwrite(dcm, [dcmOut,num2str(i),'.dcm'], dcms_info{i});
    disp(['第',num2str(i),'层保存成功']);
end
toc


