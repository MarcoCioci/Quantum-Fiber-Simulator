function export_plot(output_path, build_plot_function, style)
% EXPORT_PLOT  Export plot using a standalone hidden figure.
%
% Objective:
%   Export a plot with reliable PNG margins by rebuilding it inside a
%   standalone hidden figure, avoiding cropped exports from tab containers.
%
% Input:
%   output_path         - output image path
%   build_plot_function - function handle accepting a parent container
%   style               - plot style structure
%
% Output:
%   None

    % =========================
    % Robustness checks
    % =========================

    if nargin ~= 3
        error('export_plot:InvalidNumInputs', ...
              'Expected 3 input arguments.');
    end

    if ~ischar(output_path) && ~isstring(output_path)
        error('export_plot:InvalidOutputPath', ...
              'output_path must be a string or character vector.');
    end

    if ~isa(build_plot_function, 'function_handle')
        error('export_plot:InvalidBuildFunction', ...
              'build_plot_function must be a function handle.');
    end

    if ~isstruct(style)
        error('export_plot:InvalidStyle', ...
              'style must be a structure.');
    end

    if ~isfield(style, 'export') || ~isstruct(style.export)
        error('export_plot:MissingExportStyle', ...
              'style.export must exist and must be a structure.');
    end

    if ~isfield(style.export, 'figure_position')
        error('export_plot:MissingFigurePosition', ...
              'style.export.figure_position must be defined.');
    end

    if ~isfield(style.export, 'background_color')
        error('export_plot:MissingBackgroundColor', ...
              'style.export.background_color must be defined.');
    end

    if ~isfield(style.export, 'resolution')
        error('export_plot:MissingResolution', ...
              'style.export.resolution must be defined.');
    end

    if ~isfield(style, 'figure') || ~isstruct(style.figure) || ...
       ~isfield(style.figure, 'renderer')
        error('export_plot:MissingRenderer', ...
              'style.figure.renderer must be defined.');
    end

    output_path = char(output_path);


    % =========================
    % Select export geometry
    % =========================

    export_position = style.export.figure_position;

    if isfield(style.export, 'figure_position_current') && ...
       ~isempty(style.export.figure_position_current)
        export_position = style.export.figure_position_current;
    end

    if ~isnumeric(export_position) || ~isequal(size(export_position), [1, 4])
        error('export_plot:InvalidFigurePosition', ...
              'Export figure position must be a numeric 1x4 vector.');
    end

    if any(~isfinite(export_position)) || any(export_position(3:4) <= 0)
        error('export_plot:InvalidFigurePositionValues', ...
              'Export figure width and height must be positive finite values.');
    end


    % =========================
    % Ensure output folder exists
    % =========================

    output_folder = fileparts(output_path);

    if ~isempty(output_folder) && ~exist(output_folder, 'dir')
        mkdir(output_folder);
    end


    % =========================
    % Export figure
    % =========================

    export_fig = figure( ...
        'Visible', 'off', ...
        'Units', 'pixels', ...
        'Position', export_position, ...
        'Color', style.export.background_color, ...
        'Renderer', style.figure.renderer);

    cleanup_export_figure = onCleanup(@() close(export_fig));

    build_plot_function(export_fig);

    drawnow;

    set(export_fig, ...
        'PaperPositionMode', 'auto');

    print(export_fig, output_path, ...
        '-dpng', ...
        sprintf('-r%d', style.export.resolution));

    if ~isfile(output_path)
        error('export_plot:ExportFailed', ...
              'Export failed. Output file was not created: %s', output_path);
    end

end