function [patch] = create_filter_patch(image, patch_region)
% create_filter_patch   Returns a matrix representing the patch defined by
% patch_region with format [x1 x2, y1 y2]

[image_width, image_height] = size(image);
x1 = patch_region(1);
x2 = patch_region(2);
y1 = patch_region(3);
y2 = patch_region(4);
assert(x2>x1)
assert(y2>y1)
assert(x1>0)
assert(y1>0)
assert(x2<=image_width)
assert(y2<=image_height)    
patch = image(x1:x2, y1:y2);       
end
