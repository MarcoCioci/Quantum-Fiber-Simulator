function palette = get_plot_palette()
% GET_PLOT_PALETTE  Centralized color palette for all figures.
%
% Objective:
%   Provide a consistent, readable, and extensible palette for:
%       - theory vs numerical comparison
%       - different observables (x, y, z)
%       - state metrics (purity, fidelity, concurrence)
%
% Output:
%   palette - structure containing RGB triplets in [0,1]

    % =========================
    % Core base colors
    % =========================

    palette.blue   = [0.22, 0.45, 0.70];
    palette.orange = [0.90, 0.50, 0.20];
    palette.green  = [0.30, 0.70, 0.40];
    palette.red    = [0.85, 0.30, 0.30];
    palette.purple = [0.60, 0.40, 0.80];
    palette.cyan   = [0.20, 0.70, 0.80];
    palette.black  = [0.00, 0.00, 0.00];

    % =========================
    % Neutral colors
    % =========================

    palette.gray_dark  = [0.30, 0.30, 0.30];
    palette.gray_mid   = [0.55, 0.55, 0.55];
    palette.gray_light = [0.85, 0.85, 0.85];

    % =========================
    % Role-based usage
    % =========================

    palette.theory     = palette.blue;
    palette.numerical  = palette.orange;
    palette.samples    = palette.gray_mid;
    palette.mean_line  = palette.black;
    palette.error_box  = palette.red;

    % =========================
    % Observable-based (Pauli)
    % =========================

    palette.obs_x = palette.blue;
    palette.obs_y = palette.orange;
    palette.obs_z = palette.green;

    % =========================
    % State metrics
    % =========================

    palette.metric_global = palette.blue;     % γ(ρ_AB)
    palette.metric_A      = palette.orange;   % γ(ρ_A)
    palette.metric_B      = palette.green;    % γ(ρ_B)
    palette.metric_F      = palette.purple;   % Fidelity
    palette.metric_C      = palette.red;      % Concurrence

    % =========================
    % Tensor (optional future)
    % =========================

    palette.tensor_diag = palette.blue;
    palette.tensor_off  = palette.gray_mid;

end