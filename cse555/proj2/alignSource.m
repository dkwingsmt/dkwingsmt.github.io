function [im_s2, mask2, im_t2] = alignSource(im_s, mask, im_t)
% im_s2 = alignSource(im_s, mask, im_t)
% Asks user for bottom-center and top-center position and outputs an aligned source image.

figure(1), hold off, imagesc(im_s), axis image
figure(2), hold off, imagesc(im_t), axis image

%% Scale
[y, ~] = find(mask);
y1 = min(y)-1; y2 = max(y)+1;
disp('choose target bottom-center location')
[tx, ty] = ginput(1);
disp('choose target top location for scaling')
[~, ty2] = ginput(1);

ratio = (ty-ty2) / (y2-y1);
im_s = imresize(im_s, ratio);
mask = imresize(mask, ratio, 'nearest');

%% Origin code
[y, x] = find(mask);
y1 = min(y)-1; y2 = max(y)+1; x1 = min(x)-1; x2 = max(x)+1;
im_s2 = zeros(size(im_t));

yind = (y1:y2);
yind2 = yind - max(y) + round(ty);
xind = (x1:x2);
xind2 = xind - round(mean(x)) + round(tx);

y = y - max(y) + round(ty);
x = x - round(mean(x)) + round(tx);
ind = y + (x-1)*size(im_t, 1);
mask2 = false(size(im_t, 1), size(im_t, 2));
mask2(ind) = true;

im_s2(yind2, xind2, :) = im_s(yind, xind, :);
im_t2 = im_t;
im_t2(repmat(mask2, [1 1 3])) = im_s2(repmat(mask2, [1 1 3]));

figure(1), hold off, imagesc(im_s2), axis image;
figure(2), hold off, imagesc(im_t2), axis image;
figure(3), hold off, imagesc(mask2), axis image;
drawnow;
