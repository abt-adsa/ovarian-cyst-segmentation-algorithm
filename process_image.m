function [gray_image, image_stretch, image_binarized, image_closed, ...
          image_filled, overlayed_image, cyst_count] = process_image(selectedFile)
    % process_image.m
    % Function for main processing pipeline
    %
    % Input: Image file path
    % Output: Cyst count and image objects for viewing

    %% Load and preprocess the image
    image = imread(selectedFile);
    gray_image = im2gray(image);

    %% Enhancement
    image_medfilt = medfilt2(gray_image);

    % Histogram stretching
    stretch_threshold = 0.1;
    image_stretch = imadjust(image_medfilt, stretchlim(image_medfilt, [0 stretch_threshold]), []);

    %% Masking
    image_binarized = ~imbinarize(image_stretch, 'global');

    %% Morphological processing
    se_open = strel('disk', 2);
    image_opened = imopen(image_binarized, se_open);
    se_close = strel('disk', 4);
    image_closed = imclose(image_opened, se_close);

    %% Remove small objects
    min_size = 80;
    image_filtered = bwareaopen(image_closed, min_size);

    % Fill gaps
    image_filled = imfill(image_filtered, 'holes');

    %% Label Individual Cysts
    [cyst_label, cyst_count] = bwlabel(image_filled, 8);

    %% Highlighting

    % Add region overlays
    original_rgb = cat(3, gray_image, gray_image, gray_image);
    overlay = label2rgb(cyst_label, 'jet', 'k', 'shuffle');
    overlayed_image = imfuse(original_rgb, overlay, 'blend', 'Scaling', 'none');

    % Add numbers on overlays
    stats = regionprops(cyst_label, 'Centroid');
    centroids = cat(1, stats.Centroid);

    annotated_image = insertText(overlayed_image, centroids, ...
                                 arrayfun(@num2str, 1:cyst_count, 'UniformOutput', false), ...
                                 'TextColor', 'white', ...
                                 'FontSize', 18, ...
                                 'BoxOpacity', 0, ...
                                 'AnchorPoint', 'Center');

    overlayed_image = annotated_image;
    
end
