
function plot_reference_spectra(results_cuts::ResultsList, data::Data, rel_excess_data; save::Bool=false)

    no_of_lists = length(results_cuts.multiplicity_total)
    digits_print = 2

    stat_uncertainties = (-data.yerrm_stat, data.yerrp_stat)
    syst_uncertainties = (-data.yerrm_syst, data.yerrp_syst)
    total_uncertainties = (sqrt.(data.yerrm_stat .^ 2 .+ data.yerrm_syst .^ 2), sqrt.(data.yerrp_stat .^ 2 .+ data.yerrp_syst .^ 2))

    fig, ax = subplots(2, 1, figsize=(6, 5), sharex=true, gridspec_kw=Dict("height_ratios" => [3, 1], "hspace" => 0.05))

    labels = ["PDG2016+", "QM2016+", "sPDG2016+"]
    colors = ["tab:orange", "tab:blue", "tab:green"]

    for i in 1:no_of_lists

        order = i == 1 ? 2 : 1
        if i == 1
            alpha = 1.0
        else
            alpha = 0.9
        end
        # ax[1].plot(data.pt, getindex.((results_cuts.spectra_thermal[i])[:],1), label=label_thermal, color="blue", alpha=alpha)
        ax[1].plot(data.pt, getindex.((results_cuts.spectra_total[i])[:], 1), label=labels[i], color=colors[i], alpha=alpha, zorder=order)

    end

    ax[1].errorbar(data.pt, data.dNdpt, yerr=total_uncertainties, xerr=data.xerrm, fmt=".", label="ALICE Data", color="black")

    ax[1].set_yscale("log")
    #ax[1].set_xlabel(L"$p_{\mathrm{T}}$ [GeV/c]")
    ax[1].set_ylabel(L"$1 / (2\pi p_{\mathrm{T}}) \,\, dN/dp_{\mathrm{T}}dy \, $ [(GeV/c)$^{-2}$]")
    ax[1].tick_params(which="both", direction="in", top=true, right=true)
    ax[1].legend()
    ax[1].set_ylim(1e-2, 1e4)
    ax[1].set_xlim(0, 3.1)

    label_n = 10
    ax[1].text(2.1, 300 / label_n, "PbPb @ 2.76 TeV")
    ax[1].text(2.1, 150 / label_n, "0-5% centrality")
    ax[1].text(2.1, 75 / label_n, L"$\pi^+$ / $\pi^-$ ")

    rounded_rel_excess_data = map(v -> round.(v .* 100, digits=digits_print), rel_excess_data)
    print("Relative excess data: ", rounded_rel_excess_data, "\n")
    y_positions = [0.092, 0.04, 0.018]
    for i in 1:length(rel_excess_data[1])
        ax[1].text(0.1, y_positions[i], "rel. excess [%] = $(rounded_rel_excess_data[1][i]) ± $(rounded_rel_excess_data[2][i]) (exp.) ± $(rounded_rel_excess_data[3][i]) (mod.)", fontsize=10, color=colors[i])
    end



    for i in 1:no_of_lists
        order = i == 1 ? 2 : 1
        if i == 1
            alpha = 1.0
        else
            alpha = 0.9
        end
        rel_spectra_thermal = getindex.((results_cuts.spectra_thermal[i])[:], 1) ./ getindex.((results_cuts.spectra_thermal[1])[:], 1)
        rel_spectra_total = getindex.((results_cuts.spectra_total[i])[:], 1) ./ getindex.((results_cuts.spectra_total[1])[:], 1)

        #ax.plot(data.pt, rel_spectra_thermal, label=label_thermal, color="blue", alpha=alpha)
        ax[2].plot(data.pt, rel_spectra_total, label=labels[i], color=colors[i], alpha=alpha, zorder=order)

    end

    ax[2].set_xlabel(L"$p_{\mathrm{T}}$ [GeV/c]")
    ax[2].set_ylabel("Ratio to Ref.")
    ax[2].tick_params(which="both", direction="in", top=true, right=true)
    ax[2].set_ylim(0.92, 1.08)


    if save == true
        fig.savefig(directory * "reference_spectra.png", dpi=300, bbox_inches="tight")
    else
        fig.show()
    end

end














function plot_spectra_relative_colors(results_cuts::ResultsList, data::Data; excess::Bool=false, QM::Bool=false, save::Bool=false)

    # 1 : reference spectrum
    # 2/3 : mass +-1sigma      8/9 : mass +-2sigma          14/15 : mass +-3sigma
    # 4/5 : width +-1sigma     10/11 : width +-2sigma       16/17 : width +-3sigma
    # 6/7 : br +-1sigma        12/13 : br +-2sigma          18/19 : br +-3sigma
    # if QM list 20 is the reference of QM list

    stat_uncertainties = (-data.yerrm_stat, data.yerrp_stat)
    syst_uncertainties = (-data.yerrm_syst, data.yerrp_syst)
    total_uncertainties = (sqrt.(data.yerrm_stat .^ 2 .+ data.yerrm_syst .^ 2), sqrt.(data.yerrp_stat .^ 2 .+ data.yerrp_syst .^ 2))

    if QM == true
        println("Using QM reference list")
    end

    no_of_lists = length(results_cuts.multiplicity_total)
    colors = ["tab:red", "tab:blue", "tab:green", "tab:purple"]
    linestyles = ["solid", "solid", "dashed", "dashed", "dotted", "dotted"]
    mass_idx = [2, 3, 8, 9, 14, 15]
    width_idx = [4, 5, 10, 11, 16, 17]
    br_idx = [6, 7, 12, 13, 18, 19]

    spectra_masses = []
    spectra_widths = []
    spectra_br = []

    for i in 1:no_of_lists
        if i in mass_idx
            push!(spectra_masses, getindex.((results_cuts.spectra_total[i])[:], 1))
        end
        if i in width_idx
            push!(spectra_widths, getindex.((results_cuts.spectra_total[i])[:], 1))
        end
        if i in br_idx
            push!(spectra_br, getindex.((results_cuts.spectra_total[i])[:], 1))
        end
    end
    println("Spectra masses: ", length(spectra_masses))

    if length(data.pt) == length(spectra_masses[1])
        pT_range_plotted = data.pt
        subfix = ""
    else
        pT_range_plotted = collect(0:0.01:3)
        subfix = "0pT"
    end

    fig, ax = subplots(3, 1, figsize=(5, 6), sharex=true, gridspec_kw=Dict("height_ratios" => [3, 1, 1], "hspace" => 0.05))

    for i in 1:6
        label_mass = i == 1 ? "Mass edges" : ""
        label_br = i == 1 ? "BR edges" : ""
        ax[1].plot(pT_range_plotted, spectra_masses[i], label=label_mass, color=colors[3], linestyle=linestyles[1], alpha=0.5)
        #ax[1].plot(data.pt, spectra_widths[i], label="Width $(i)", color=colors[i], linestyle="dashed")
        ax[1].plot(pT_range_plotted, spectra_br[i], label=label_br, color=colors[2], linestyle=linestyles[1], alpha=0.5)
    end

    ax[1].plot(pT_range_plotted, getindex.((results_cuts.spectra_total[1])[:], 1), label="Reference", color=colors[1])
    if QM == true
        ax[1].plot(pT_range_plotted, getindex.((results_cuts.spectra_total[20])[:], 1), label="Default QM2016+", color=colors[4])
    end
    ax[1].errorbar(data.pt, data.dNdpt, yerr=total_uncertainties, xerr=data.xerrm, fmt=".", label="ALICE Data", color="black")

    ax[1].set_yscale("log")
    #ax[1].set_xlabel(L"$p_{\mathrm{T}}$ [GeV/c]")
    ax[1].set_ylabel(L"$1 / (2\pi p_{\mathrm{T}}) \,\, dN/dp_{\mathrm{T}}dy \, $ [(GeV/c)$^{-2}$]")
    ax[1].tick_params(which="both", direction="in", top=true, right=true)
    ax[1].legend()
    ax[1].set_ylim(1e-2, 1e4)

    if excess == true
        ax[1].set_ylim(2e1, 2e3)
        ax[1].set_xlim(0.0, 1.0)
    end

    ax[1].text(0.05, 0.24, "PbPb @ 2.76 TeV", transform=ax[1].transAxes)
    ax[1].text(0.05, 0.18, "0-5% centrality", transform=ax[1].transAxes)
    ax[1].text(0.05, 0.12, L"$\pi^+$ / $\pi^-$ ", transform=ax[1].transAxes)

    if QM == true
        ax[1].text(0.05, 0.06, "QM2016+", transform=ax[1].transAxes)
    else
        ax[1].text(0.05, 0.06, "PDG2016+", transform=ax[1].transAxes)
    end

    for i in 1:6
        label_mass = i == 1 ? "Mass edges" : ""
        label_br = i == 1 ? "BR edges" : ""
        rel_spectra_mass = spectra_masses[i] ./ getindex.((results_cuts.spectra_total[1])[:], 1)
        ax[2].plot(pT_range_plotted, rel_spectra_mass, label=label_mass, color=colors[3], alpha=0.5, linestyle=linestyles[1])
        rel_spectra_br = spectra_br[i] ./ getindex.((results_cuts.spectra_total[1])[:], 1)
        ax[3].plot(pT_range_plotted, rel_spectra_br, label=label_br, color=colors[2], alpha=0.5, linestyle=linestyles[1])
    end

    rel_spectra_ref = getindex.((results_cuts.spectra_total[1])[:], 1) ./ getindex.((results_cuts.spectra_total[1])[:], 1)
    ax[2].plot(pT_range_plotted, rel_spectra_ref, label="Reference", color=colors[1], linestyle="solid")
    ax[3].plot(pT_range_plotted, rel_spectra_ref, label="Reference", color=colors[1], linestyle="solid")

    if QM == true
        rel_spectra_qm_ref = getindex.((results_cuts.spectra_total[20])[:], 1) ./ getindex.((results_cuts.spectra_total[1])[:], 1)
        ax[2].plot(pT_range_plotted, rel_spectra_qm_ref, label="QM Reference", color=colors[4], linestyle="solid")
        ax[3].plot(pT_range_plotted, rel_spectra_qm_ref, label="QM Reference", color=colors[4], linestyle="solid")
    end

    ax[3].set_xlabel(L"$p_{\mathrm{T}}$ [GeV/c]")
    #ax[2].set_ylabel("ratio [arb.]")
    ax[2].tick_params(which="both", direction="in", top=true, right=true)
    ax[2].set_ylim(0.85, 1.15)
    ax[3].tick_params(which="both", direction="in", top=true, right=true)
    ax[3].set_ylim(0.85, 1.15)

    fig.text(0.02, 0.25, "Ratio to Ref.", va="center", rotation="vertical")

    if excess == true
        ax[2].set_xlim(0, 1.0)
        ax[3].set_xlim(0, 1.0)
    end

    if save == true
        if excess == true
            fig.savefig(directory * "colors_rel_spectra_excess" * subfix * ".png", dpi=300, bbox_inches="tight")
        else
            fig.savefig(directory * "colors_rel_spectra" * subfix * ".png", dpi=300, bbox_inches="tight")
        end
    else
        fig.show()
    end

end




function plot_rel_excess_colors(rel_excess, rel_excess_err_exp, rel_excess_err_mod; nsigma::Bool=false, QM::Bool=false, edge::Bool=false, save::Bool=false)

    # 1 : reference spectrum
    # 2/3 : mass +-1sigma      8/9 : mass +-2sigma          14/15 : mass +-3sigma
    # 4/5 : width +-1sigma     10/11 : width +-2sigma       16/17 : width +-3sigma
    # 6/7 : br +-1sigma        12/13 : br +-2sigma          18/19 : br +-3sigma
    # if QM list 20 is the reference of QM list

    if QM == true
        println("Using QM reference list")
    end

    mass_idx = [2, 3, 8, 9, 14, 15]
    width_idx = [4, 5, 10, 11, 16, 17]
    br_idx = [6, 7, 12, 13, 18, 19]

    excess_masses = []
    excess_widths = []
    excess_br = []

    for i in 1:19
        if i in mass_idx
            push!(excess_masses, rel_excess[i])
        end
        if i in width_idx
            push!(excess_widths, rel_excess[i])
        end
        if i in br_idx
            push!(excess_br, rel_excess[i])
        end
    end

    perm = [1:2:length(excess_masses); 2:2:length(excess_masses)]
    permute!(excess_masses, perm)
    permute!(excess_widths, perm)
    permute!(excess_br, perm)

    fig, ax = subplots(1, 1, figsize=(5, 5))

    println("Before plotting: ", length(rel_excess), length(rel_excess_err_exp), length(rel_excess_err_mod))

    if nsigma == true
        ax.errorbar(1, rel_excess[1], yerr=rel_excess_err_exp[1], fmt="o", color="tab:red", label="Experimental Uncertainty")
        ax.errorbar(1, rel_excess[1], yerr=rel_excess_err_mod[1], fmt="o", color="tab:red", alpha=0.3, elinewidth=6, label="Model Uncertainty")
        ax.axhline(rel_excess[1], color="tab:red", linestyle="dashed")
        if QM == true
            ax.errorbar(2, rel_excess[20], yerr=rel_excess_err_exp[20], fmt="o", color="tab:purple", label="Default QM2016+")
            ax.errorbar(2, rel_excess[20], yerr=rel_excess_err_mod[20], fmt="o", color="tab:purple", alpha=0.3, elinewidth=6)
            ax.errorbar(collect(3:length(excess_masses)+2), excess_masses, yerr=rel_excess_err_exp[mass_idx], fmt="o", color="tab:green", label="Mass edges")
            ax.errorbar(collect(3:length(excess_masses)+2), excess_masses, yerr=rel_excess_err_mod[mass_idx], fmt="o", color="tab:green", alpha=0.3, elinewidth=6)
            ax.errorbar(collect(3:length(excess_br)+2), excess_br, yerr=rel_excess_err_exp[br_idx], fmt="o", color="tab:blue", label="BR edges")
            ax.errorbar(collect(3:length(excess_br)+2), excess_br, yerr=rel_excess_err_mod[br_idx], fmt="o", color="tab:blue", alpha=0.3, elinewidth=6)
        else
            ax.errorbar(collect(2:length(excess_masses)+1), excess_masses, yerr=rel_excess_err_exp[mass_idx], fmt="o", color="tab:green", label="Mass edges")
            ax.errorbar(collect(2:length(excess_masses)+1), excess_masses, yerr=rel_excess_err_mod[mass_idx], fmt="o", color="tab:green", alpha=0.3, elinewidth=6)
            ax.errorbar(collect(2:length(excess_br)+1), excess_br, yerr=rel_excess_err_exp[br_idx], fmt="o", color="tab:blue", label="BR edges")
            ax.errorbar(collect(2:length(excess_br)+1), excess_br, yerr=rel_excess_err_mod[br_idx], fmt="o", color="tab:blue", alpha=0.3, elinewidth=6)
        end
    else
        ax.errorbar(collect(1:length(rel_excess)), rel_excess, yerr=rel_excess_err_exp, fmt="o", color="black", label="Experimental Uncertainty")
        ax.errorbar(collect(1:length(rel_excess)), rel_excess, yerr=rel_excess_err_mod, fmt="o", color="black", alpha=0.3, elinewidth=6, label="Model Uncertainty")
    end

    println("After plotting: ", length(rel_excess), length(rel_excess_err_exp), length(rel_excess_err_mod))

    if edge == true
        if QM == true
            labels = ["Reference", "QM2016+", L"$+1\sigma$", L"$+2\sigma$", L"$+3\sigma$", L"$-1\sigma$", L"$-2\sigma$", L"$-3\sigma$"]
        else
            labels = ["Reference", L"$+1\sigma$", L"$+2\sigma$", L"$+3\sigma$", L"$-1\sigma$", L"$-2\sigma$", L"$-3\sigma$"]
        end
        if nsigma == true
            if QM == true
                ax.set_xticks(collect(1:length(excess_masses)+2))
            else
                ax.set_xticks(collect(1:length(excess_masses)+1))
            end
        else
            ax.set_xticks(collect(1:length(rel_excess)))
        end
        ax.set_xticklabels(labels, rotation=45)
    end

    #ax.set_xlabel("sampling cases")
    ax.set_ylabel("relative pion excess")
    #ax.set_title("Relative Pion Excess")
    if nsigma == true
        if QM == true
            ax.set_xlim(0.5, length(excess_masses) + 2.5)
        else
            ax.set_xlim(0.5, length(excess_masses) + 1.5)
        end
    else
        ax.set_xlim(0.5, length(rel_excess) + 0.5)
    end

    ax.text(0.05, 0.92, "PbPb @ 2.76 TeV", transform=ax.transAxes)
    ax.text(0.05, 0.88, "0-5% centrality", transform=ax.transAxes)
    ax.text(0.05, 0.84, L"$\pi^+$ / $\pi^-$ ", transform=ax.transAxes)
    if QM == true
        ax.text(0.05, 0.80, "QM2016+", transform=ax.transAxes)
    else
        ax.text(0.05, 0.80, "PDG2016+", transform=ax.transAxes)
    end
    #ax.text(0.05, 0.1, "before rescaling", transform=ax.transAxes, fontsize=11, color="black")
    mean_excess = mean(rel_excess)
    std_excess = std(rel_excess)
    println("Mean relative Excess: $(mean_excess) ± $(std_excess)")
    #ax.text(0.3 * length(rel_excess), 0.2, "Mean relative Excess: $(round(mean_excess, digits=2)) ± $(round(std_excess, digits=2))")
    ax.tick_params(which="both", direction="in", top=true, right=true)
    ax.legend()
    ax.set_ylim(0, 0.3)

    if save == true
        fig.savefig(directory * "pion_rel_excess_colors.png", dpi=400, bbox_inches="tight")
    end

end