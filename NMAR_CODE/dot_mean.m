function proj_mean = dot_mean( metal_mask, proj, num_mean )

%   选取金属轨迹上下各num_mean个像素点，取平均值后，对金属轨迹内像素点进行插值
% Input:
% metal_mask:       metal trace in projection domain (binary image)
% proj:                   uncorrected projection
% num_mean:        The number of pixels selected

% Output:
% proj_mean:      linear interpolation corrected projection

if nargin < 3
    num_mean = 20;
end

if num_mean == 1
    proj_mean = proj;
    return;
end

n = size(proj, 1);
flag = true;  % flag = true, 计算上 num_mean 个像素的均值；flag = false，计算下 num_mean 个像素的均值
proj_mean = proj;
for i = 1:n - 1
    if metal_mask(i) ~= metal_mask(i + 1)
        if flag  % flag = true
            r = i;
            l = max(1, r-num_mean+1);  % 防止越界
            sum_metal = sum(metal_mask(l:r) ~= 0);  % 去除金属区域
            l = l + sum_metal;
            proj_mean(r) = mean(proj(l:r));
        else  % flag = false
            l = i + 1;
            r = min(l+num_mean-1, n);  % 防止越界
            sum_metal = sum(metal_mask(l:r) ~= 0);  % 去除金属区域
            r = r - sum_metal;
            proj_mean(l) = mean(proj(l:r));
        end
        flag = ~flag;
    end
end

end

