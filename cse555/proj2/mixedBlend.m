function [ im_blend ] = mixedBlend( im_s, mask_s, im_t )
%MIXEDBLEND Summary of this function goes here
%   Detailed explanation goes here

im_blend = poissonBlend(im_s, mask_s, im_t, 0, true );

end

