function [exp] = create_transform_exp(name)
  
    exp.image = [];
    
    function [transformed_image] = apply_blur_transform(step)
          final_blur_size = 6
          blur_size = round(final_blur_size*(step-1)/(exp.num_steps-1))          
          if blur_size > 0
            blur_kernel = fspecial('gaussian',[100 100], blur_size);
            transformed_image = imfilter(exp.image,blur_kernel,'same');            
          else
            transformed_image = exp.image;
          end          
    end

    function [transformed_image] = apply_scale_transform(step)
          a = 1.0;
          b = 1.5;
          alpha = (step-1)/(exp.num_steps-1);          
          param = b*alpha + a*(1-alpha);
          transformed_image = imresize(exp.image,param);     
          [h,w] = size(exp.image);
          transformed_image = transformed_image(1:h, 1:w);
    end

    function [transformed_image] = apply_saltandpeper_transform(step)
          final_noise_size = 0.1
          noise = final_noise_size*(step-1)/(exp.num_steps-1)          
          transformed_image = imnoise(exp.image,'salt & pepper',noise);                       
    end

    function [is_correct] = identity_match_is_correct(image_point_a, image_point_b, step)
          is_correct = false;
          dist = norm(image_point_a-image_point_b);          
          if dist < 4.0
              is_correct = true;          
          end
    end

    
    function [is_correct] = scale_match_is_correct(image_point_a, image_point_b, step)
          a = 1.0;
          b = 1.5;
          alpha = (step-1)/(exp.num_steps-1);          
          param = b*alpha + a*(1-alpha);
        
          is_correct = false;
          dist = norm(image_point_a*param-image_point_b);          
          if dist < 4.0
              is_correct = true;          
          end
    end

    function [transformed_image] = apply_interpolation_transform(step)
          alpha = (step-1)/(exp.num_steps-1);
          assert(size(exp.image,1) == size(exp.image_final,1));
          transformed_image = exp.image_final*alpha + exp.image*(1-alpha);
    end
    
    exp.name = name;

    if strcmp(name, 'lichtenstein-blur-steeple')        
        exp.image = load_image_grayscale('lichtenstein_01.png');
        exp.num_steps = 10;
        exp.filter_bounding_box = [76, 112, 188, 225]; % steeple        
        exp.filter_patch = create_filter_patch(exp.image, exp.filter_bounding_box); 
        exp.transform_image = @apply_blur_transform;
        exp.match_is_correct = @identity_match_is_correct;
    elseif strcmp(name, 'lichtenstein-blur-window')        
        exp.image = load_image_grayscale('lichtenstein_01.png');
        exp.num_steps = 10;
        exp.filter_bounding_box =  [305, 340, 112, 136]; % double window
        exp.filter_patch = create_filter_patch(exp.image, exp.filter_bounding_box); 
        exp.transform_image = @apply_blur_transform;
        exp.match_is_correct = @identity_match_is_correct;
    elseif strcmp(name, 'lichtenstein-blur-windowword')        
        exp.image = load_image_grayscale('lichtenstein_01.png');
        exp.num_steps = 10;
        exp.filter_bounding_box =  [305, 340, 112, 136]; % double window
        tmp_patch = create_filter_patch(exp.image, exp.filter_bounding_box); 
        tmp_patch = imfilter(tmp_patch,fspecial('gaussian',[20 20], 1),'same');            
        exp.filter_patch = imnoise(tmp_patch,'salt & pepper',0.1);                       
        %imshow(exp.filter_patch)        
        exp.transform_image = @apply_blur_transform;
        exp.match_is_correct = @identity_match_is_correct;
    elseif strcmp(name, 'lichtenstein-saltandpepper-steeple')
        exp.image = load_image_grayscale('lichtenstein_01.png');
        exp.num_steps = 10;
        exp.filter_bounding_box = [76, 112, 188, 225]; % steeple        
        exp.filter_patch = create_filter_patch(exp.image, exp.filter_bounding_box); 
        exp.transform_image = @apply_saltandpeper_transform;
        exp.match_is_correct = @identity_match_is_correct;
    elseif strcmp(name, 'lichtenstein-scale-steeple')
        exp.image = load_image_grayscale('lichtenstein_01.png');
        exp.num_steps = 10;
        exp.filter_bounding_box = [76, 112, 188, 225]; % steeple        
        exp.filter_patch = create_filter_patch(exp.image, exp.filter_bounding_box); 
        exp.transform_image = @apply_scale_transform;
        exp.match_is_correct = @scale_match_is_correct;        
    elseif strcmp(name, 'lichtenstein-scale-window')        
        exp.image = load_image_grayscale('lichtenstein_01.png');
        exp.num_steps = 10;
        exp.filter_bounding_box =  [305, 340, 112, 136]; % double window
        exp.filter_patch = create_filter_patch(exp.image, exp.filter_bounding_box); 
        exp.transform_image = @apply_scale_transform;
        exp.match_is_correct = @scale_match_is_correct;    
    elseif strcmp(name, 'lichtenstein-scene01-steeple')
        exp.image = load_image_grayscale('lichtenstein_01.png');
        exp.image_final = load_image_grayscale('lichtenstein_02.png');
        exp.num_steps = 10;
        exp.filter_bounding_box = [76, 112, 188, 225]; % steeple        
        exp.filter_patch = create_filter_patch(exp.image, exp.filter_bounding_box); 
        exp.transform_image = @apply_interpolation_transform;
        exp.match_is_correct = @identity_match_is_correct;    
    elseif strcmp(name, 'lichtenstein-scene01-window')
        exp.image = load_image_grayscale('lichtenstein_01.png');
        exp.image_final = load_image_grayscale('lichtenstein_02.png');
        exp.num_steps = 10;
        exp.filter_bounding_box =  [305, 340, 112, 136]; % double window
        exp.filter_patch = create_filter_patch(exp.image, exp.filter_bounding_box); 
        exp.transform_image = @apply_interpolation_transform;
        exp.match_is_correct = @identity_match_is_correct;           
    elseif strcmp(name, 'lichtenstein-scene01-windowword')
        exp.image = load_image_grayscale('lichtenstein_01.png');
        exp.image_final = load_image_grayscale('lichtenstein_02.png');
        exp.num_steps = 10;
        exp.filter_bounding_box =  [305, 340, 112, 136]; % double window
        
        tmp_patch = create_filter_patch(exp.image, exp.filter_bounding_box); 
        tmp_patch = imfilter(tmp_patch,fspecial('gaussian',[20 20], 1),'same');            
        exp.filter_patch = imnoise(tmp_patch,'salt & pepper',0.1);                       
        %imshow(exp.filter_patch)
        
        exp.transform_image = @apply_interpolation_transform;
        exp.match_is_correct = @identity_match_is_correct;                   
    else
        
        strcat('ERROR: invalid experiment:', name)
        assert(false)
    end

end

