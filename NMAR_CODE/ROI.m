function [Image_dicom, close_region] = ROI(dcm_data,thresh_air,kernel_size)
% Get the region of interest
% Input:
% dcm_data:       uncorrected image
% thresh_air:       CT of air
% kernel_size:      Convolution kernel size
% Output:
% Image_dicom:     image of ROI
% close_region:      ROI mask (binary image)

    soft_mask = (dcm_data > thresh_air);
    soft_mask = imfill(soft_mask, 'holes');
    
    %先腐蚀后膨胀，去掉组织外无关影响
    kernel = strel('square', kernel_size);
    soft_mask = imerode(soft_mask, kernel);
    soft_mask = imdilate(soft_mask, kernel);
%     figure, imshow(soft_mask, []), title('soft mask');
    
    %连通域中只选取最大的那一个，如果前两个连通域面积接近，则选择两个。
    regions = regionprops(soft_mask, 'Area', 'PixelIdxList');
    [~, area_idx] = sort([regions.Area], 'descend');
    regions = struct2cell(regions);
    pixels = cell2mat(regions(2, area_idx(1)));
    if length(area_idx) > 1
        num_pixels = length(pixels);
        pixels_1 = cell2mat(regions(2, area_idx(2)));
        num_pixels_1 = length(pixels_1);
        if double(num_pixels_1) / num_pixels > .5
            pixels = [pixels; pixels_1];
        end
    end

    max_region = zeros([512 512], 'int8');
    max_region(pixels) = 1;
%     figure, imshow(max_region, []), title('max region');
    close_region = max_region;
    Image_dicom =  zeros([512  512], 'int16');
    Image_dicom(close_region==1) = dcm_data(close_region==1);
%     figure, imshow(Image_dicom, []), title('ROI');
    
end