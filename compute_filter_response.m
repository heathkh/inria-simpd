function [response] = compute_filter_response(image, filter_patch)
% compute_filter_response   Returns the normalized cross-correlation of the
% image with the filter_patch.  Output values can be in the range (0,1).
  [I_SSD,I_NCC]=template_matching(filter_patch,image);
  response = I_NCC;
  
  max_val = max(max(response))
  
  response = response./max_val;
  
  
end








