function [gray_image] = load_image_grayscale(name)
  color_image = im2double(imread(name));
  gray_image = rgb2gray(color_image);
end


