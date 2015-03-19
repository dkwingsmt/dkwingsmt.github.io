function [ im_blend ] = poissonBlend( im_s, mask_s, im_t, alpha, mixed )
%POISSONBLEND Summary of this function goes here
%   Detailed explanation goes here

if nargin < 5
    mixed = false;
end

if nargin < 4
    alpha = 1;
end

[imh, imw, nb] = size(im_t); 
ims2var = zeros(imh, imw); 
ims2var(1:imh*imw) = 1:imh*imw; 

% Pad everything with zeros of width 1 for edge cases of circshifting
masked_ims2var_ex = wextend(2, 'zpd', ims2var .* (mask_s*2-1), 1);

% 4-neighbors
neighb_shifts = [1,0; 0,1; -1,0; 0,-1];
nneighb = size(neighb_shifts, 1);
neighb_ids = zeros(imh+2, imw+2, nneighb);  % padded ver

for i = 1:nneighb
    % Negative if outside mask.
    neighb_ids(:, :, i) = circshift(masked_ims2var_ex, neighb_shifts(i, :));
end

% Cancel padding
neighb_ids = neighb_ids(2:end-1, 2:end-1, :);

masked_ims2var = ims2var .* mask_s;

% Construct neighborhood pairs
neighb_list = [repmat(masked_ims2var(:), [nneighb, 1]), neighb_ids(:)];
neighb_list_in = neighb_list(neighb_list(:, 1)~=0 & neighb_list(:, 2)>0, :);
neighb_list_out = neighb_list(neighb_list(:, 1)~=0 & neighb_list(:, 2)<0, :);
neighb_list_out(:, 2) = - neighb_list_out(:, 2);

neqin = size(neighb_list_in, 1);
neqout = size(neighb_list_out, 1);

im_s_vec = reshape(im_s, [], nb);
im_t_vec = reshape(im_t, [], nb);

%% Construct
Ain_i = [1:neqin,1:neqin];
Ain_j = neighb_list_in(:)';
Ain_s = [ones(1, neqin), -ones(1, neqin)];
A = sparse(Ain_i, Ain_j, Ain_s, neqin+neqout, imh*imw);
b = zeros(neqin+neqout, nb);
s_diff = im_s_vec(neighb_list_in(:, 1), :) - im_s_vec(neighb_list_in(:, 2), :);
t_diff = im_t_vec(neighb_list_in(:, 1), :) - im_t_vec(neighb_list_in(:, 2), :);
if mixed
    select_s = abs(s_diff) > (0.5 * abs(t_diff));
    b(1:neqin, :) = select_s .* s_diff + (1-select_s) .* t_diff;
else
    b(1:neqin, :) = alpha * s_diff + (1-alpha) * t_diff;
end

A(sub2ind(size(A), neqin+(1:neqout), neighb_list_out(:, 1)')) = 1;
b(neqin+(1:neqout), :) = im_t_vec(neighb_list_out(:, 2), :);

% Keep only necessary variables to solve
changeids = ims2var(mask_s);
A = A(:, changeids);
disp('lscov start')
changevals = lscov(A, b);
disp('lscov end')

% Combine target and solve
im_blend = reshape(im_t, [], nb);
im_blend(changeids, :) = changevals;
im_blend = reshape(im_blend, imh, imw, nb);

end