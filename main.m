function [gray_image, image_stretch, image_binarized, image_closed, ...
          image_filled, overlayed_image, cyst_count] = main(selectedFile)

    % Load and preprocess the image
    image = imread(selectedFile);
    gray_image = im2gray(image);

    % Enhancement
    image_medfilt = medfilt2(gray_image);
    stretch_threshold = 0.1;
    image_stretch = imadjust(image_medfilt, stretchlim(image_medfilt, [0 stretch_threshold]), []);

    % Masking
    image_binarized = ~imbinarize(image_stretch, 'global');

    % Morphological processing
    se_open = strel('disk', 2);
    image_opened = imopen(image_binarized, se_open);
    se_close = strel('disk', 4);
    image_closed = imclose(image_opened, se_close);

    % Remove small objects
    min_size = 80;
    image_filtered = bwareaopen(image_closed, min_size);
    image_filled = imfill(image_filtered, 'holes');

    % Labelling
    [cyst_label, cyst_count] = bwlabel(image_filled, 8);

    % Highlighting
    original_rgb = cat(3, gray_image, gray_image, gray_image);
    overlay = label2rgb(cyst_label, 'jet', 'k', 'shuffle');
    overlayed_image = imfuse(original_rgb, overlay, 'blend', 'Scaling', 'none');
    
end
