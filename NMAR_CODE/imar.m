function result_miu = imar(src_miu, metal_mask, metal_trace, miu_air, miu_water)
    %IMAR  ���ڵ�����ȥαӰ
    src_proj = mfanbeam(src_miu);  % ԭͼͶӰ original sinogram
%     figure, imshow(src_proj, []), title('src proj');

    % ���Բ�ֵ
    im_li = marLI(src_proj, metal_trace);

    % ����  ����Խ��Ȩ��Խ��
    output = im_li;
    [width, height] = size(output);
    sigmaSpatial  = min( width, height ) / 50;
    samplingSpatial=sigmaSpatial;
    % ����
    sigmaRange = ( max( output( : ) ) - min( output( : ) ) ) / 50;
    samplingRange= sigmaRange;
    output = bilateralFilter( output, output, sigmaSpatial, sigmaRange, ...
        samplingSpatial, samplingRange );
%     figure, imshow(output, []), title('bilateralFilter');
    
    % ���
    output(metal_mask) = miu_water;

    % ���� 
    im1d = reshape(output, numel(output), 1);
    [reconidx,~] = kmeans(im1d, 3, 'Replicates', 8, 'replicates', 1 , 'start', [miu_air; miu_water; 2*miu_water]);
    thresh_bone = min(im1d(reconidx==3));
    thresh_bone = max([thresh_bone, 1.2*miu_water]);
    thresh_water = min(im1d(reconidx==2));

    % ����
    im_tissue_classified = tissue_classified(output, thresh_water, thresh_bone, miu_air, miu_water);
    im_tissue_classified(metal_mask) = src_miu(metal_mask);
    proj_tissue_classified = mfanbeam(im_tissue_classified);  % ����ͶӰ tissue classified sinogram
%     figure, imshow(proj_tissue_classified, []), title('proj tissue classified');

    % error sinogram
    delta_proj = src_proj - proj_tissue_classified;
    delta_proj(~metal_trace) = 0;
%     figure, imshow(delta_proj, []), title('delta proj');
    delta_miu = mifanbeam(delta_proj);
%     delta_miu = frequencyFilter(delta_miu, 100);
%     figure, imshow(delta_miu, []), title('delta miu');
     result_miu = src_miu - delta_miu;
     result_miu(result_miu < 0) = 0;
%     min_miu = min(result_miu(:));
%     if min_miu < 0
%         result_miu = result_miu - min(result_miu(:));
%     end
%      result_miu = result_miu * .7 + output * .3;
end

function tc_img = tissue_classified(im,threshWater,threshBone,miuAir,miuWater)
    smFilter = fspecial('gaussian',[5 5],1);
    imSm = imfilter(im,smFilter,'replicate');  %�˲�

    tc_img = imSm;
    tc_img(imSm<=threshWater) = miuAir;
    tc_img(intersect(find(imSm>threshWater),find(imSm<threshBone))) = miuWater;
end
