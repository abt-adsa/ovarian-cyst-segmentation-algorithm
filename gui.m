function gui()
    clc, close all force;

    fig = uifigure('Name', 'Cyst Detection GUI', 'Position', [100, 100, 600, 500]);

    grid = uigridlayout(fig, [3, 3]);
    grid.RowHeight = {'1x', '2x', '2x'};
    grid.ColumnWidth = {'1x', '1x', '1x'};
    
    files = get_files_in_workspace();
    dropdown = uidropdown(grid, ...
        'Items', files, ...
        'Value', files{1}, ...
        'ValueChangedFcn', @(src, event) process_image(src));
    dropdown.Layout.Row = 1;
    dropdown.Layout.Column = 1;

    titleText = uilabel(grid, ...
        'Text', sprintf('Ovarian\nCyst\nSegmenter'), ...
        'HorizontalAlignment', 'center', ...
        'FontWeight', 'bold', ...
        'FontSize', 20);
    titleText.Layout.Row = 1;
    titleText.Layout.Column = 2;

    cystCountText = uilabel(grid, ...
        'Text', 'Cysts detected: ', ...
        'HorizontalAlignment', 'center', ...
        'FontWeight', 'bold', ...
        'FontSize', 16);
    cystCountText.Layout.Row = 1;
    cystCountText.Layout.Column = 3;

    axesArray = gobjects(6, 1);
    for i = 1:6
        axesArray(i) = uiaxes(grid);
        axesArray(i).Layout.Row = ceil((i + 3) / 3);
        axesArray(i).Layout.Column = mod(i - 1, 3) + 1;
    end

    if ~strcmp(files{1}, 'No files available')
        process_image(dropdown);
    end

    function process_image(src)
        selectedFile = src.Value;
        fullFilePath = fullfile('images', selectedFile);
        
        if ~isfile(fullFilePath)
            disp('File does not exist!');
            return;
        end
    
        [gray_image, image_stretch, image_binarized, image_closed, ...
         image_filled, overlayed_image, cyst_count] = main(fullFilePath);
    
        cystCountText.Text = sprintf('Cysts detected: %i', cyst_count);
    
        imshow(gray_image, 'Parent', axesArray(1));
        title(axesArray(1), 'Original Image');
    
        imshow(image_stretch, 'Parent', axesArray(2));
        title(axesArray(2), 'Contrast Enhanced');
    
        imshow(image_binarized, 'Parent', axesArray(3));
        title(axesArray(3), 'Binarized');
    
        imshow(image_closed, 'Parent', axesArray(4));
        title(axesArray(4), 'Morphologically Processed');
    
        imshow(image_filled, 'Parent', axesArray(5));
        title(axesArray(5), 'Gaps Closed & Holes Filled');
    
        imshow(overlayed_image, 'Parent', axesArray(6));
        title(axesArray(6), 'Cysts Highlighted');
    end

    function files = get_files_in_workspace()
        
        fileStructPNG = dir(fullfile('images', '*.png'));
        fileStructJPG = dir(fullfile('images', '*.jpg'));
        
        files = [{fileStructPNG.name}, {fileStructJPG.name}];
        
        if isempty(files)
            files = {'No files available'};
        end
    end
end
