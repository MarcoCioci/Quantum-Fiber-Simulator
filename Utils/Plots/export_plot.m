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
        error('export_plot_with_margins:InvalidNumInputs', ...
              'Expected 3 input arguments.');
    end

    if ~ischar(output_path) && ~isstring(output_path)
        error('export_plot_with_margins:InvalidOutputPath', ...
              'output_path must be a string or character vector.');
    end

    if ~isa(build_plot_function, 'function_handle')
        error('export_plot_with_margins:InvalidBuildFunction', ...
              'build_plot_function must be a function handle.');
    end

    if ~isstruct(style)
        error('export_plot_with_margins:InvalidStyle', ...
              'style must be a structure.');
    end


    % =========================
    % Export figure
    % =========================

    export_fig = figure( ...
        'Visible', 'off', ...
        'Units', 'pixels', ...
        'Position', style.export.figure_position, ...
        'Color', style.export.background_color, ...
        'Renderer', style.figure.renderer);

    build_plot_function(export_fig);

    set(export_fig, ...
        'PaperPositionMode', 'auto');

    print(export_fig, output_path, ...
        '-dpng', ...
        sprintf('-r%d', style.export.resolution));

end