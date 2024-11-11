clc, clearvars, close all;

%% Image loading and preprocessing

path = 'cystic/2.jpg';
image = imread(path);

gray_image = im2gray(image);

figure, subplot(2, 3, 1), imshow(gray_image), title("Original Image");

%% Enhancement

image_medfilt = medfilt2(gray_image);

stretch_threshold = 0.1;
image_stretch = imadjust(image_medfilt, stretchlim(image_medfilt, [0 stretch_threshold]), []);

subplot(2, 3, 2), imshow(image_stretch), title("Contrast Enhanced");

%% Masking

image_binarized = ~imbinarize(image_stretch, 'global');

subplot(2, 3, 3), imshow(image_binarized), title("Binarized");

%% Morphological Processing

se_open = strel('disk', 2);
image_opened = imopen(image_binarized, se_open);

se_close = strel('disk', 4);
image_closed = imclose(image_opened, se_close);

subplot(2, 3, 4), imshow(image_closed), title("Morphologically Processed");

%% Remove Small Objects

min_size = 70;
image_filtered = bwareaopen(image_closed, min_size);

image_filled = imfill(image_filtered, 'holes');

subplot(2, 3, 5), imshow(image_filled), title("Gaps Closed & Holes Filled");

%% Labelling

[label, count] = bwlabel(image_filled, 8);

%% Highlighting

original_rgb = cat(3, gray_image, gray_image, gray_image);

overlay = label2rgb(label, 'jet', 'k', 'shuffle');

alpha = 0.5;
overlayed_image = imfuse(original_rgb, overlay, 'blend', 'Scaling', 'none');

subplot(2, 3, 6), imshow(overlayed_image), title("Cysts Highlighted");

fprintf("Cysts detected: %i\n", count);
