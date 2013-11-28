function [filter_matches] = do_matching(filter_peaks_a, filter_peaks_b)
% do_matching   Return a Nx2 matrix where each row contains the indices
% of the matched peaks: [ai bi]

filter_matches = [];

% slice out the 2xN matrices representing the birth/death pairs of
% peaks
birth_death_a = filter_peaks_a(:, 4:5);
birth_death_b = filter_peaks_b(:, 4:5);
num_a = size(birth_death_a,1);
num_b = size(birth_death_b,1);
num = min(num_a, num_b);

% bottleneck_distance_matlab requires pdist2.m
[dist, matching]  = bottleneck_distance_matlab(birth_death_a, birth_death_b);
assert(size(matching,1) == 1)
assert(size(matching,2) == num_a + num_b )

cur_matches = [];
% matches after num_b matches correspond to matches to diagonal
for j=1:num_b
  k = matching(j);
  % indices greater than num_a encode matches to points on diagonal
  if (k <= num_a)        
      cur_matches = [cur_matches; k j];
  end
end

filter_matches = cur_matches;

end




