
ENV["PYTHON"]="home/tim/miniconda3/bin/python"
using PyPlot

include("data_lib.jl")
include("results_lib.jl")


function plot_importance_spectra(results_cuts::ResultsList, data::Data, mult_data, cuts; save=false)

    no_of_lists = length(cuts)
    digits_print = 2;
    fig, ax = subplots(1,1, figsize=(6,5));
    red_gradient = get_cmap("Reds", no_of_lists+10);
    blue_gradient = get_cmap("Blues", no_of_lists+10);

    for i in 1:no_of_lists
        label_thermal = i == no_of_lists ? "Thermal Spectrum" : ""
        label_total   = i == no_of_lists ? "Total Spectrum" : ""

        ax.plot(data.pt, getindex.((results_cuts.spectra_thermal[i])[:],1), label=label_thermal, color=blue_gradient(i+5))
        ax.plot(data.pt, getindex.((results_cuts.spectra_total[i])[:],1), label=label_total, color=red_gradient(i+5))
        ax.text(1.0, 0.01*exp(3*i/no_of_lists), "dN/dy = $(round(results_cuts.multiplicity_total[i][1], digits=digits_print))", fontsize=7, color=red_gradient(i+5))
        ax.text(0.1, 0.01*exp(3*i/no_of_lists), "dN/dy = $(round(results_cuts.multiplicity_thermal[i][1], digits=digits_print))", fontsize=7, color=blue_gradient(i+5))
    end

    ax.errorbar(data.pt, data.dNdpt, yerr=(-data.yerrm_stat,data.yerrp_stat), xerr=data.xerrm, fmt="+", label="ALICE Data", color="black")
    ax.text(2, 300, "PbPb @ 2.76 TeV")
    ax.text(2, 170, "0-5% centrality")
    ax.text(0.1, 0.7, "dN/dy = $(round(mult_data[1], digits=digits_print)) ± $(round(mult_data[2], digits=digits_print))", fontsize=10, color="black")
    ax.set_title("Testing Importance scores")
    ax.set_yscale("log")
    ax.set_xlabel("pT [GeV/c]")
    ax.set_ylabel("1/(2πpT) dN/dpTdy [1/GeV/c]")
    ax.tick_params(which="both", direction="in", top=true, right=true)
    ax.legend()
    ax.set_ylim(1e-2, 1e4)
    #ax.set_xlim(0.01, 2)

    red_gradient_reverse = get_cmap("Reds_r", no_of_lists+5);
    norm = matplotlib.colors.LogNorm(vmin=maximum(cuts), vmax=minimum(cuts))
    sm = matplotlib.cm.ScalarMappable(norm=norm, cmap=red_gradient_reverse)
    cbar = fig.colorbar(sm, ax=ax, orientation="vertical", pad=0.01, aspect=20)
    cbar.set_label("Importance score cut", fontsize=10)
    cbar.ax.tick_params(labelsize=8)

    if save==true
        savefig(directory*"importance_pion_spectra_pce.png", dpi=300)
    end

end




function deviation_cuts(list, reference)
    return [100 * abs(x - reference) / reference for x in list]
end


function ratio_cuts(list, reference)
    return [x / reference for x in list]
end


function plot_importance_mults(results::Results, results_cuts::ResultsList, mult_data, mult_data_excess, cuts; save=false)

    mult_thermal_cuts_values = [mult_thermal_cut[1] for mult_thermal_cut in results_cuts.multiplicity_thermal]
    mult_thermal_cuts_excess_values = [mult_thermal_cut[1] for mult_thermal_cut in results_cuts.multiplicity_thermal_excess]

    mult_total_cuts_values = [mult_total_cut[1] for mult_total_cut in results_cuts.multiplicity_total]
    mult_total_cuts_excess_values = [mult_total_cut[1] for mult_total_cut in results_cuts.multiplicity_total_excess]

    mult_thermal_cuts_dev = deviation_cuts(mult_thermal_cuts_values, results.multiplicity_thermal[1])
    mult_total_cuts_dev = deviation_cuts(mult_total_cuts_values, results.multiplicity_total[1])

    mult_thermal_cuts_excess_dev = deviation_cuts(mult_thermal_cuts_excess_values, results.multiplicity_thermal_excess[1])
    mult_total_cuts_excess_dev = deviation_cuts(mult_total_cuts_excess_values, results.multiplicity_total_excess[1])

    mult_thermal_cuts_ratios = ratio_cuts(mult_thermal_cuts_values, results.multiplicity_thermal[1])
    mult_total_cuts_ratios = ratio_cuts(mult_total_cuts_values, results.multiplicity_total[1])

    mult_thermal_cuts_excess_ratios = ratio_cuts(mult_thermal_cuts_excess_values, results.multiplicity_thermal_excess[1])
    mult_total_cuts_excess_ratios = ratio_cuts(mult_total_cuts_excess_values, results.multiplicity_total_excess[1])

    markersize = 4;
    ratio = true;
    label_thermal_full = L"Thermal Pions $p_{\mathrm{T}}$ = 0.1 - 3.0 GeV/c"
    label_thermal_excess = L"Thermal Pions $p_{\mathrm{T}}$ = 0.1 - 0.5 GeV/c"
    label_total_full = L"Total Pions $p_{\mathrm{T}}$ = 0.1 - 3.0 GeV/c"
    label_total_excess = L"Total Pions $p_{\mathrm{T}}$ = 0.1 - 0.5 GeV/c"

    fig, ax = subplots(2,1, figsize=(5,6), sharex=true, height_ratios=[4, 1]);

    ax[1].plot(cuts, mult_thermal_cuts_values, label=label_thermal_full, color="blue", marker="o", markersize=markersize)
    ax[1].plot(cuts, mult_total_cuts_values, label=label_total_full, color="red", marker="o", markersize=markersize)

    ax[1].plot(cuts, mult_thermal_cuts_excess_values, label=label_thermal_excess, color="blue", linestyle="--", marker="s", markersize=markersize)
    ax[1].plot(cuts, mult_total_cuts_excess_values, label=label_total_excess, color="red", linestyle="--", marker="s", markersize=markersize)

    ax[1].plot(0, results.multiplicity_thermal[1], "o", color="blue", markersize=markersize)
    ax[1].plot(0, results.multiplicity_total[1], "o", color="red", markersize=markersize)

    ax[1].plot(0, results.multiplicity_thermal_excess[1], "s", color="blue", markersize=markersize)
    ax[1].plot(0, results.multiplicity_total_excess[1], "s", color="red", markersize=markersize)

    ax[1].plot(0, mult_data[1], "o", color="black", markersize=markersize, label=L"ALICE Data $p_{\mathrm{T}}$ = 0.1 - 3.0 GeV/c")
    ax[1].plot(0, mult_data_excess[1], "s", color="black", markersize=markersize, label=L"ALICE Data $p_{\mathrm{T}}$ = 0.1 - 0.5 GeV/c")

    if ratio == false
        ax[2].plot(cuts, mult_thermal_cuts_dev, label=label_thermal_full, color="blue", marker="o", markersize=markersize)
        ax[2].plot(cuts, mult_total_cuts_dev, label=label_total_full, color="red", marker="o", markersize=markersize)

        ax[2].plot(cuts, mult_thermal_cuts_excess_dev, label=label_thermal_excess, color="blue", linestyle="--", marker="s", markersize=markersize)
        ax[2].plot(cuts, mult_total_cuts_excess_dev, label=label_total_excess, color="red", linestyle="--", marker="s", markersize=markersize)
    else
        ax[2].plot(cuts, mult_thermal_cuts_ratios, label=label_thermal_full, color="blue", marker="o", markersize=markersize)
        ax[2].plot(cuts, mult_total_cuts_ratios, label=label_total_full, color="red", marker="o", markersize=markersize)

        ax[2].plot(cuts, mult_thermal_cuts_excess_ratios, label=label_thermal_excess, color="blue", linestyle="--", marker="s", markersize=markersize)
        ax[2].plot(cuts, mult_total_cuts_excess_ratios, label=label_total_excess, color="red", linestyle="--", marker="s", markersize=markersize)
    end

    ax[1].set_xscale("symlog", linthresh=1e-10)
    ax[1].tick_params(which="both", direction="in", top=true, right=true)
    ax[1].set_ylim(0, 1000)
    ax[1].set_ylabel(L"dN/dy")
    ax[1].set_title("Pion Multiplicities vs Importance score cut")
    ax[1].legend()

    ax[2].tick_params(which="both", direction="in", top=true, right=true)
    ax[2].set_xlabel("Importance score cut")

    if ratio == false
        ax[2].set_ylabel("Deviation [%]")
        #ax[2].set_yscale("log")
        ax[2].set_ylim(1e-2, 40)
    else
        ax[2].set_ylabel("Ratio")
        ax[2].set_ylim(0.6, 1.1)
    end

    fig.tight_layout()

    if save
        savefig(directory*"importance_pion_multiplicities_pce.png", dpi=300)
    end


end




function plot_importance_ratios(results::Results, results_cuts::ResultsList, cuts; save=false)

    mult_thermal_cuts_values = [mult_thermal_cut[1] for mult_thermal_cut in results_cuts.multiplicity_thermal]
    mult_thermal_cuts_excess_values = [mult_thermal_cut[1] for mult_thermal_cut in results_cuts.multiplicity_thermal_excess]

    mult_total_cuts_values = [mult_total_cut[1] for mult_total_cut in results_cuts.multiplicity_total]
    mult_total_cuts_excess_values = [mult_total_cut[1] for mult_total_cut in results_cuts.multiplicity_total_excess]

    mult_cuts_ratios = [mult_total_cuts_values[i] / mult_thermal_cuts_values[i] for i in 1:length(cuts)]
    mult_cuts_ratios_excess = [mult_total_cuts_excess_values[i] / mult_thermal_cuts_excess_values[i] for i in 1:length(cuts)]

    mult_ratio = results.multiplicity_total[1] / results.multiplicity_thermal[1]
    mult_ratio_excess = results.multiplicity_total_excess[1] / results.multiplicity_thermal_excess[1]

    mult_cuts_ratios_dev = deviation_cuts(mult_cuts_ratios, mult_ratio)
    mult_cuts_ratios_excess_dev = deviation_cuts(mult_cuts_ratios_excess, mult_ratio_excess)

    markersize = 4;
    label_full = L"Full pT range $p_{\mathrm{T}}$ = 0.1 - 3.0 GeV/c";
    label_excess = L"Excess pT range $p_{\mathrm{T}}$ = 0.1 - 0.5 GeV/c";

    fig, ax = subplots(2,1, figsize=(5,6), sharex=true, height_ratios=[4, 1]);

    ax[1].plot(cuts, mult_cuts_ratios, label=label_full, color="green", marker="o", markersize=markersize)
    ax[1].plot(cuts, mult_cuts_ratios_excess, label=label_excess, color="orange", marker="s", markersize=markersize)

    ax[1].plot(0, mult_ratio[1], "o", color="green", markersize=markersize)
    ax[1].plot(0, mult_ratio_excess[1], "s", color="orange", markersize=markersize)


    ax[2].plot(cuts, mult_cuts_ratios_dev, label=label_full, color="green", marker="o", markersize=markersize)
    ax[2].plot(cuts, mult_cuts_ratios_excess_dev, label=label_excess, color="orange", marker="s", markersize=markersize)


    ax[1].set_xscale("symlog", linthresh=1e-10)
    ax[1].tick_params(which="both", direction="in", top=true, right=true)
    ax[1].set_ylim(1, 3)
    ax[1].set_ylabel(L"$dN/dy_{\mathrm{Total}} \quad / \quad dN/dy_{\mathrm{Thermal}}$")
    ax[1].set_title("Ratio Pion Multiplicities vs Importance score cut")
    ax[1].legend()

    ax[2].tick_params(which="both", direction="in", top=true, right=true)
    ax[2].set_xlabel("Importance score cut")
    ax[2].set_ylabel("Deviation [%]")
    ax[2].set_yscale("log")
    ax[2].set_ylim(1e-2, 50)
    ax[2].grid()


    fig.tight_layout()

    if save
        savefig(directory*"importance_pion_ratio_multiplicities_pce.png", dpi=300)
    end


end

