function proj_mean = dot_mean( metal_mask, proj, num_mean )

%   ѡȡ�����켣���¸�num_mean�����ص㣬ȡƽ��ֵ�󣬶Խ����켣�����ص���в�ֵ
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
flag = true;  % flag = true, ������ num_mean �����صľ�ֵ��flag = false�������� num_mean �����صľ�ֵ
proj_mean = proj;
for i = 1:n - 1
    if metal_mask(i) ~= metal_mask(i + 1)
        if flag  % flag = true
            r = i;
            l = max(1, r-num_mean+1);  % ��ֹԽ��
            sum_metal = sum(metal_mask(l:r) ~= 0);  % ȥ����������
            l = l + sum_metal;
            proj_mean(r) = mean(proj(l:r));
        else  % flag = false
            l = i + 1;
            r = min(l+num_mean-1, n);  % ��ֹԽ��
            sum_metal = sum(metal_mask(l:r) ~= 0);  % ȥ����������
            r = r - sum_metal;
            proj_mean(l) = mean(proj(l:r));
        end
        flag = ~flag;
    end
end

end

