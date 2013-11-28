function [peak_data] = compute_response_peaks(response_image, min_persistence)
% compute_response_peaks   Returns matrix with rows corresponding to peaks
% with following format [persistence, image row, image col, birth, death].
% Rows are ordered decreasing by persistence.

[width, height] = size(response_image);
assert(width >1)
assert(height >1)
num_pixels = width*height;
edge_count = 0;

%define graph reflecting 4-neighbor connectivity of image pixels
edges = zeros((width-1)*(height-1)*2,2,'uint32');
vertex_values = zeros((width-1)*(height-1),1);
for col=1:(width-1)
    for row=1:(height-1)
        v1 = col+(row-1)*width;
        n_right = [row col+1];
        n_bot =  [row+1 col];
        v_right = n_right(2)+(n_right(1)-1)*width;
        v_bot = n_bot(2)+(n_bot(1)-1)*width;
        edge_count = edge_count + 1;
        edges(edge_count,:) = [v1 v_right];
        edge_count = edge_count + 1;
        edges(edge_count,:) = [v1 v_bot];
    end
end

% pixel values are the function
vertex_values = reshape(response_image.',[],1);

[peak_linear_index peak_persistence] = graph_persistence(edges, vertex_values);
[num_peaks, foo] = size(peak_linear_index);

peak_data = []; % persistence, row, col, birth, death

for peak_id=1:num_peaks
    persistence = peak_persistence(peak_id);    
    % discard peaks with small persistence
    if (persistence < min_persistence)
        continue
    end   
    pixel_index = peak_linear_index(peak_id);
    row = ceil(pixel_index/width);
    col = mod(pixel_index, width);       
    birth = vertex_values(pixel_index);
    death = birth + persistence;
    bar = [persistence row col birth death ];
    peak_data = [peak_data; bar];
end

% sort peaks by decreasing persistence
assert(size(peak_data,1) > 0)
peak_data = sortrows(peak_data, -1);

end





    


