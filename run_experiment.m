clear all
close all

% peaks with smaller persistence are ignored in matching
min_persistence = 0.2

% matches between peaks with larger mean persistence are considered
% confident matches (and line between corresponding points is plotted on image pair)
min_match_persistence = 0.4

% set of all experiements
exp_names_all = {'lichtenstein-blur-steeple',
             'lichtenstein-blur-window', 
             'lichtenstein-blur-windowword',
             'lichtenstein-saltandpepper-steeple',
             'lichtenstein-scale-steeple',
             'lichtenstein-scale-window',
             'lichtenstein-scene01-steeple',
             'lichtenstein-scene01-window',
             'lichtenstein-scene01-windowword'};

% set of experiements with funky matching 
exp_names_debug = {'lichtenstein-blur-window'};        

% select which set of experiments to run
exp_names = exp_names_all

scrsz = get(0,'ScreenSize');    
num_experiments = size(exp_names,1)
for exp_num=1:num_experiments
    exp = create_transform_exp(exp_names{exp_num});
    image_a = exp.image;
    filter_response_a = compute_filter_response(image_a, exp.filter_patch);
    peaks_a = compute_response_peaks(filter_response_a, min_persistence);
    
    figure('Position',[1 scrsz(4) scrsz(3) scrsz(4)])   
    
    for step=1:exp.num_steps
        image_b = exp.transform_image(step);
        filter_response_b = compute_filter_response(image_b, exp.filter_patch);
        peaks_b = compute_response_peaks(filter_response_b, min_persistence);         
        peak_matches = do_matching(peaks_a, peaks_b);
        [num_matches, dim] = size(peak_matches);
        assert(dim == 2);

        % classify matched peaks as correct / incorrect 
        % also generate list of matches that have high mean-match-persistence
        confident_matched_points = []; % in format [ax ay bx by is_correct]
        correct_match_indices = [];
        incorrect_match_indices = [];
        for match_index=1:num_matches
          ai = peak_matches(match_index,1);
          bi = peak_matches(match_index,2);
          image_point_a = peaks_a(ai,3:-1:2); % format [x y]
          image_point_b = peaks_b(bi,3:-1:2); % format [x y]         
          mean_match_persistence = (peaks_a(ai,1) + peaks_b(bi,1))/2.0; 
          
          is_correct = exp.match_is_correct(image_point_a, image_point_b, step);
          
          if mean_match_persistence > min_match_persistence
              confident_matched_points = [confident_matched_points; horzcat(image_point_a,image_point_b, is_correct)];
          end

          if is_correct
              correct_match_indices = [correct_match_indices; ai bi];
          else
              incorrect_match_indices = [incorrect_match_indices; ai bi];
          end    
        end    
        [num_correct_matches, dim] = size(correct_match_indices);
        assert(~num_correct_matches || dim == 2);
        [num_incorrect_matches, dim] = size(incorrect_match_indices);
        assert(~num_incorrect_matches || dim == 2);
        [num_confident_matches, dim] = size(confident_matched_points);
        assert(~num_confident_matches || dim == 5);
        
        subplot(2,2,1)
        draw_correspondences(exp, image_a, image_b, confident_matched_points)
        title_str = sprintf('experiment: %s\n step: %d\n min peak pers: %0.2f min match pers: %0.2f', exp.name, step, min_persistence, min_match_persistence);
        title(title_str);
        title_str
              
        subplot(2,2,3)
        imshow(horzcat(filter_response_a,filter_response_b))
        
        subplot(1,2,2)
        xmax = 2.0;
        ymax = xmax;

        % plot peaks from left image (o) and right image (x)
        plot(peaks_a(:,4), peaks_a(:,5), 'ok', peaks_b(:,4), peaks_b(:,5), 'xk', 'LineSmoothing','on')    
        axis equal
        axis([0 xmax 0 ymax])          
        legend('left image','right image', 'Location', 'SouthEast');
        
        % draw diagonal
        hold on
        plot([0 xmax], [0 ymax], 'Color', [0,0,0])    
        
        % draw min peak persistence threshold
        plot([0 xmax], [0+min_persistence ymax+min_persistence], 'Color', [0.5,0.5,0.5], 'LineStyle', '--', 'LineSmoothing','on')    
        
        % draw min peak persistence threshold
        plot([0 xmax], [0+min_match_persistence ymax+min_match_persistence], 'Color', [0.75,0.75,0.75], 'LineStyle', '--', 'LineSmoothing','on')    
        hold off
                
        % draw correct peak_matches in green
        hold on    
        for i=1:num_correct_matches
          ai = correct_match_indices(i,1);
          bi = correct_match_indices(i,2);
          x = [peaks_a(ai,4) peaks_b(bi,4) ];
          y = [peaks_a(ai,5) peaks_b(bi,5) ];
          plot(x,y,'g-');
        end    
        hold off

        % draw incorrect peak_matches in red
        hold on    
        for i=1:num_incorrect_matches
          ai = incorrect_match_indices(i,1);
          bi = incorrect_match_indices(i,2);
          x = [peaks_a(ai,4) peaks_b(bi,4) ];
          y = [peaks_a(ai,5) peaks_b(bi,5) ];
          plot(x,y,'r-');
        end    
        hold off
                
        title_str = sprintf('correct matches: %d incorrect matches: %d confident matches: %d', num_correct_matches, num_incorrect_matches, num_confident_matches);
        title(title_str);
        title_str
        
        
        
        % dump screenshot to "export" directory 
        % may need to create it if it doesn't exist
        addpath('export_fig') % using export_fig package
        filename_str = sprintf('export/%s.pdf', exp.name);
        export_fig(filename_str, '-append')        
    end
end

