function [fig, tab] = get_experiment_figure_tab(experiment_id, tab_title, figure_name, style)
% GET_EXPERIMENT_FIGURE_TAB  Create or reuse one experiment figure with tabs.
%
% Objective:
%   Reuse one figure window per experiment and create one tab per plot.
%
% Input:
%   experiment_id - numeric MATLAB figure ID
%   tab_title     - title of the tab to create or replace
%   figure_name   - name of the experiment figure window
%   style         - plot style structure
%
% Output:
%   fig - MATLAB figure handle
%   tab - MATLAB uitab handle

    % =========================
    % Robustness checks
    % =========================

    if nargin < 4
        error('get_experiment_figure_tab:InvalidNumInputs', ...
              'Expected 4 input arguments.');
    end

    if ~isnumeric(experiment_id) || ~isscalar(experiment_id)
        error('get_experiment_figure_tab:InvalidExperimentId', ...
              'experiment_id must be a numeric scalar.');
    end


    % =========================
    % Figure and tab group
    % =========================

    fig = figure(experiment_id);

    set(fig, ...
        'Name', figure_name, ...
        'NumberTitle', 'off', ...
        'Units', 'normalized', ...
        'OuterPosition', [0, 0, 1, 1], ...
        'Renderer', style.figure.renderer, ...
        'Visible', style.figure.visible_during_build);

    tab_group = findobj(fig, 'Type', 'uitabgroup');

    if isempty(tab_group)
        clf(fig);
        tab_group = uitabgroup(fig);
    end


    % =========================
    % Replace existing tab if present
    % =========================

    old_tab = findobj(tab_group, 'Type', 'uitab', 'Title', tab_title);

    if ~isempty(old_tab)
        delete(old_tab);
    end

    tab = uitab(tab_group, 'Title', tab_title);
    tab_group.SelectedTab = tab;

end