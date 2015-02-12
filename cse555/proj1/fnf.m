%F = double(imread('carpet_00_flash.tif'));
%NF = double(imread('carpet_01_noflash.tif'));

F = double(imread('potsdetail_00_flash.tif'));
NF = double(imread('potsdetail_01_noflash.tif'));

F = F / max(F(:));
NF = NF / max(NF(:));
ANR = imguidedfilter(NF, F, 'DegreeOfSmoothing', .0005, 'NeighborhoodSize', [10 10]);
Abase = imguidedfilter(NF, 'DegreeOfSmoothing', .002, 'NeighborhoodSize', [10 10]);

epsilon = 0.02;
Fbase = imguidedfilter(F, 'DegreeOfSmoothing', .06, 'NeighborhoodSize', [10 10]);
Fdetail = (F + epsilon) ./ (Fbase + epsilon);

Fshadow = repmat(mean((F*sum(NF(:))/sum(F(:)))-NF<-.1, 3), [1 1 3]);
Fsb = min(imfilter(Fshadow*255, fspecial('gaussian', 5, 3)), 200);
Fsbu = double(Fsb) / max(Fsb(:));
Afinal = (1 - Fsbu) .* ANR .* Fdetail + Fsbu .* Abase;