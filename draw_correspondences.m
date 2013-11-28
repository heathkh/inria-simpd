function [] = draw_correspondences(exp, image_a, image_b, confident_matched_points)
    imshow( horzcat(image_a, image_b))
    
    % draw the template region on image a as a yellow rectange
    bb = exp.filter_bounding_box;        
    rectangle('Position',[bb(3) bb(1) bb(4)-bb(3) bb(2)-bb(1)], 'EdgeColor', [1,1,0]);

    [num_matches, dim] = size(confident_matched_points);
    assert(dim == 5) % format [ax ay bx by is_correct]
    
    [h_a, w_a] = size(image_a);
    for i=1:num_matches
        data = confident_matched_points(i,:);
        ax = data(1);
        ay = data(2);
        bx = data(3);
        by = data(4);
        is_correct = data(5);
        line_color = [];
        if is_correct
            line_color = [0,1,0];
        else
            line_color = [1,0,0];
        end
        line('XData', [ax; bx+w_a],'YData', [ay; by],'Color', line_color,  'Marker', '.')
    end
   
end








