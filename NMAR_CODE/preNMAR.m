function [ imNMAR1 ] = preNMAR( dcm_data )
% prepare for NMAR
% Input:
% dcm_data:       uncorrected image
% Output:
% imNMAR1:      NMAR corrected image using the prior from LI image

    % ԭͼ -> miu �� ͶӰ
    miu_water = 0.192;
    src_miu = hu2miu(dcm_data, miu_water);

    % ����mask
    metal_mask = (dcm_data > 3000);
    metal_proj = mfanbeam(metal_mask);  % ����ͶӰ metal sinogram
    metal_trace = (metal_proj > 0);

    %NMAR����
    src_proj = mfanbeam(src_miu);
    im_li = marLI(src_proj, metal_trace);
    imNMAR = nmar(src_proj, src_miu, im_li, metal_trace, metal_mask, miu_water);
    imNMAR1 = miu2hu(imNMAR ,miu_water);
    
    %     �������
    imNMAR1(metal_mask) = dcm_data(metal_mask);
end

