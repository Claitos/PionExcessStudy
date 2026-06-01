using PyPlot
using Statistics

function plot_sample_spectra(results_cuts::ResultsList, data::Data, mult_data; edge::Bool=false, excess::Bool=false, save::Bool=false)

    no_of_lists = length(results_cuts.multiplicity_total)
    digits_print = 2;
    if edge == true
        fig, ax = subplots(1,1, figsize=(6,5));
    else
        fig, ax = subplots(1,1, figsize=(5,5));
    end
    red_gradient = get_cmap("Reds", no_of_lists+7);
    blue_gradient = get_cmap("Blues", no_of_lists+7);

    for i in 1:no_of_lists
        label_thermal = i == 1 ? "Thermal Spectrum" : ""
        label_total   = i == 1 ? "Total Spectrum" : ""
        if i == 1
            alpha = 1.0
        else 
            alpha = 0.2
        end
        ax.plot(data.pt, getindex.((results_cuts.spectra_thermal[i])[:],1), label=label_thermal, color="blue", alpha=alpha)
        ax.plot(data.pt, getindex.((results_cuts.spectra_total[i])[:],1), label=label_total, color="red", alpha=alpha)
        # ax.text(1.0, 0.01*exp(3*i/no_of_lists), "dN/dy = $(round(results_cuts.multiplicity_total[i][1], digits=digits_print))", fontsize=7, color="red")
        # ax.text(0.1, 0.01*exp(3*i/no_of_lists), "dN/dy = $(round(results_cuts.multiplicity_thermal[i][1], digits=digits_print))", fontsize=7, color="blue")
        
    end

    ax.errorbar(data.pt, data.dNdpt, yerr=(-data.yerrm_stat,data.yerrp_stat), xerr=data.xerrm, fmt=".", label="ALICE Data", color="black")
    if excess == true
        ax.text(0.12, 120, "dN/dy = $(round(results_cuts.multiplicity_total[1][1], digits=digits_print)) ± $(round(results_cuts.multiplicity_total[1][2], digits=digits_print))", fontsize=10, color="red")
        ax.text(0.12, 140, "dN/dy = $(round(results_cuts.multiplicity_thermal[1][1], digits=digits_print)) ± $(round(results_cuts.multiplicity_thermal[1][2], digits=digits_print))", fontsize=10, color="blue")
        ax.text(0.12, 180, "dN/dy = $(round(mult_data[1], digits=digits_print)) ± $(round(mult_data[2], digits=digits_print))", fontsize=10, color="black")
        ax.text(0.35, 900, "PbPb @ 2.76 TeV")
        ax.text(0.35, 800, "0-5% centrality")
    else
        ax.text(0.1, 0.2, "dN/dy = $(round(results_cuts.multiplicity_total[1][1], digits=digits_print)) ± $(round(results_cuts.multiplicity_total[1][2], digits=digits_print))", fontsize=10, color="red")
        ax.text(0.1, 0.1, "dN/dy = $(round(results_cuts.multiplicity_thermal[1][1], digits=digits_print)) ± $(round(results_cuts.multiplicity_thermal[1][2], digits=digits_print))", fontsize=10, color="blue")
        ax.text(0.1, 0.7, "dN/dy = $(round(mult_data[1], digits=digits_print)) ± $(round(mult_data[2], digits=digits_print))", fontsize=10, color="black")
        ax.text(2, 300, "PbPb @ 2.76 TeV")
        ax.text(2, 170, "0-5% centrality")
    end
    
    
    #ax.set_title("Sampled Spectra")
    ax.set_yscale("log")
    ax.set_xlabel(L"$p_{\mathrm{T}}$ [GeV/c]")
    ax.set_ylabel(L"$1/(2πp_{\mathrm{T}})$ $dN/dp_{\mathrm{T}}dy$ [1/GeV/c]")
    ax.tick_params(which="both", direction="in", top=true, right=true)
    ax.legend()
    ax.set_ylim(1e-2, 1e4)
    #ax.set_xlim(0.01, 2)

    if excess == true
        ax.set_ylim(1e2, 2e3)
        ax.set_xlim(0.0, 0.5)
    end

    if edge == true
        labels = ["Reference", "Mass +", "Mass -", "Width +", "Width -", "BR +", "BR -"];
        norm = matplotlib.colors.Normalize(vmin=0, vmax=1)
        sm = matplotlib.cm.ScalarMappable(cmap=red_gradient, norm=norm)
        cbar = fig.colorbar(sm, ax=ax, orientation="vertical", pad=0.01, aspect=20)
        # Set custom tick positions (from 0 to 1)
        tick_positions = range(0, stop=1, length=length(labels))
        cbar.set_ticks(tick_positions)
        cbar.set_ticklabels(labels)
    end


    if save==true
        if excess == true
            fig.savefig(directory*"sample_pion_spectra_pce_excess.png", dpi=300)
        else
            fig.savefig(directory*"sample_pion_spectra_pce.png", dpi=300)
        end
    else
        fig.show()
    end

end





function plot_sample_spectra_relative(results_cuts::ResultsList, data::Data, mult_data; excess::Bool=false, save::Bool=false)

    no_of_lists = length(results_cuts.multiplicity_total)
    digits_print = 2;
    red_gradient = get_cmap("Reds", no_of_lists+7);
    blue_gradient = get_cmap("Blues", no_of_lists+7);

    stat_uncertainties = (-data.yerrm_stat, data.yerrp_stat)
    syst_uncertainties = (-data.yerrm_syst, data.yerrp_syst)
    total_uncertainties = (sqrt.(data.yerrm_stat.^2 .+ data.yerrm_syst.^2), sqrt.(data.yerrp_stat.^2 .+ data.yerrp_syst.^2))

    fig, ax = subplots(2,1, figsize=(5.1,5), sharex=true, gridspec_kw = Dict("height_ratios"=>[3,1], "hspace"=>0.05))

    for i in 1:no_of_lists
        label_thermal = i == 1 ? "Thermal Spectrum" : ""
        label_total   = [["Reference", "Modified Parameters"]; fill("", no_of_lists - 2)][i]
        colors = i == 1 ? "tab:orange" : "tab:red"
        order = i == 1 ? 2 : 1
        if i == 1
            alpha = 1.0
        else 
            alpha = 0.3
        end
        # ax[1].plot(data.pt, getindex.((results_cuts.spectra_thermal[i])[:],1), label=label_thermal, color="blue", alpha=alpha)
        ax[1].plot(data.pt, getindex.((results_cuts.spectra_total[i])[:],1), label=label_total, color=colors, alpha=alpha, zorder=order)
        
    end

    ax[1].errorbar(data.pt, data.dNdpt, yerr=total_uncertainties, xerr=data.xerrm, fmt=".", label="ALICE Data", color="black")
    ax[1].axvline(0.5, color="gray", linestyle="--", label=L"$0.5 < p_{\mathrm{T}} < 2.0$ GeV/c")
    ax[1].axvline(2.0, color="gray", linestyle="--")

    ax[1].set_yscale("log")
    #ax[1].set_xlabel(L"$p_{\mathrm{T}}$ [GeV/c]")
    ax[1].set_ylabel(L"$1 / (2\pi p_{\mathrm{T}}) \,\, dN/dp_{\mathrm{T}}dy \, $ [(GeV/c)$^{-2}$]")
    ax[1].tick_params(which="both", direction="in", top=true, right=true)
    ax[1].legend()
    ax[1].set_ylim(1e-2, 1e4)

    if excess == true
        ax[1].set_ylim(1e2, 2e3)
        ax[1].set_xlim(0.0, 0.5)
        ax[1].text(0.32, 1200, "PbPb @ 2.76 TeV")
        ax[1].text(0.32, 1000, "0-5% centrality")
    else
        label_n = 10
        ax[1].text(2.1, 300/label_n, "PbPb @ 2.76 TeV")
        ax[1].text(2.1, 150/label_n, "0-5% centrality")
        ax[1].text(2.1, 75/label_n, L"$\pi^+$ / $\pi^-$ ")
        ax[1].text(2.1, 38/label_n, "PDG2016+")
    end

    for i in 1:no_of_lists
        label_thermal = i == 1 ? "Thermal Spectrum" : ""
        label_total   = [["Reference", "Modified Parameters"]; fill("", no_of_lists - 2)][i]
        colors = i == 1 ? "tab:orange" : "tab:red"
        order = i == 1 ? 2 : 1
        if i == 1
            alpha = 1.0
        else 
            alpha = 0.3
        end
        rel_spectra_thermal = getindex.((results_cuts.spectra_thermal[i])[:],1) ./ getindex.((results_cuts.spectra_thermal[1])[:],1)
        rel_spectra_total   = getindex.((results_cuts.spectra_total[i])[:],1) ./ getindex.((results_cuts.spectra_total[1])[:],1)

        #ax.plot(data.pt, rel_spectra_thermal, label=label_thermal, color="blue", alpha=alpha)
        ax[2].plot(data.pt, rel_spectra_total, label=label_total, color=colors, alpha=alpha, zorder=order)
        
    end
    ax[2].axvline(0.5, color="gray", linestyle="--", label=L"$0.5 < p_{\mathrm{T}} < 2.0$ GeV/c")
    ax[2].axvline(2.0, color="gray", linestyle="--")

    ax[2].set_xlabel(L"$p_{\mathrm{T}}$ [GeV/c]")
    ax[2].set_ylabel("Ratio to Ref.")
    ax[2].tick_params(which="both", direction="in", top=true, right=true)
    ax[2].set_ylim(0.6, 1.4)

    if excess == true
        ax[2].set_xlim(0, 0.5)
    end

    if save==true
        if excess == true
            fig.savefig(directory*"sample_pion_rel_spectra_pce_excess.png", dpi=300)
        else
            fig.savefig(directory*"sample_pion_rel_spectra_pce.png", dpi=300)
        end
    else
        fig.show()
    end

end






function plot_sample_spectra_relative_3(results_cuts::ResultsList, results_cuts_thermal::ResultsList, data::Data, mult_data; excess::Bool=false, save::Bool=false)

    no_of_lists = length(results_cuts.multiplicity_total)
    digits_print = 2;
    red_gradient = get_cmap("Reds", no_of_lists+7);
    blue_gradient = get_cmap("Blues", no_of_lists+7);

    stat_uncertainties = (-data.yerrm_stat, data.yerrp_stat)
    syst_uncertainties = (-data.yerrm_syst, data.yerrp_syst)
    total_uncertainties = (sqrt.(data.yerrm_stat.^2 .+ data.yerrm_syst.^2), sqrt.(data.yerrp_stat.^2 .+ data.yerrp_syst.^2))

    fig, ax = subplots(3,1, figsize=(5.1,6), sharex=true, gridspec_kw = Dict("height_ratios"=>[3,1,1], "hspace"=>0.05))

    for i in 1:no_of_lists
        label_thermal = i == 1 ? "Thermal Spectrum" : ""
        label_total   = [["Reference", "Modified Parameters"]; fill("", no_of_lists - 2)][i]
        colors = i == 1 ? "tab:orange" : "tab:red"
        order = i == 1 ? 2 : 1
        if i == 1
            alpha = 1.0
        else 
            alpha = 0.3
        end
        # ax[1].plot(data.pt, getindex.((results_cuts_thermal.spectra_thermal[i])[:],1), label=label_thermal, color="blue", alpha=alpha)
        ax[1].plot(data.pt, getindex.((results_cuts_thermal.spectra_total[i])[:],1), label=label_total, color=colors, alpha=alpha, zorder=order)
        
    end

    ax[1].errorbar(data.pt, data.dNdpt, yerr=total_uncertainties, xerr=data.xerrm, fmt=".", label="ALICE Data", color="black")
    ax[1].axvline(0.5, color="gray", linestyle="--", label=L"$0.5 < p_{\mathrm{T}} < 2.0$ GeV/c")
    ax[1].axvline(2.0, color="gray", linestyle="--")

    ax[1].set_yscale("log")
    #ax[1].set_xlabel(L"$p_{\mathrm{T}}$ [GeV/c]")
    ax[1].set_ylabel(L"$1 / (2\pi p_{\mathrm{T}}) \,\, dN/dp_{\mathrm{T}}dy \, $ [(GeV/c)$^{-2}$]")
    ax[1].tick_params(which="both", direction="in", top=true, right=true)
    ax[1].legend()
    ax[1].set_ylim(1e-2, 1e4)

    if excess == true
        ax[1].set_ylim(1e2, 2e3)
        ax[1].set_xlim(0.0, 0.5)
        ax[1].text(0.32, 1200, "PbPb @ 2.76 TeV")
        ax[1].text(0.32, 1000, "0-5% centrality")
    else
        label_n = 12
        ax[1].text(2.1, 300/label_n, "PbPb @ 2.76 TeV")
        ax[1].text(2.1, 150/label_n, "0-5% centrality")
        ax[1].text(2.1, 75/label_n, L"$\pi^+$ / $\pi^-$ ")
        ax[1].text(2.1, 38/label_n, "PDG2016+")
    end

    for i in 1:no_of_lists
        label_thermal = i == 1 ? "Thermal Spectrum" : ""
        label_total   = [["Reference", "Modified Parameters"]; fill("", no_of_lists - 2)][i]
        colors = i == 1 ? "tab:orange" : "tab:red"
        order = i == 1 ? 2 : 1
        if i == 1
            alpha = 1.0
        else 
            alpha = 0.3
        end
        rel_spectra_thermal = getindex.((results_cuts_thermal.spectra_thermal[i])[:],1) ./ getindex.((results_cuts_thermal.spectra_thermal[1])[:],1)
        rel_spectra_total   = getindex.((results_cuts_thermal.spectra_total[i])[:],1) ./ getindex.((results_cuts_thermal.spectra_total[1])[:],1)

        #ax.plot(data.pt, rel_spectra_thermal, label=label_thermal, color="blue", alpha=alpha)
        ax[2].plot(data.pt, rel_spectra_total, label=label_total, color=colors, alpha=alpha, zorder=order)
        
    end
    ax[2].axvline(0.5, color="gray", linestyle="--", label=L"$0.5 < p_{\mathrm{T}} < 2.0$ GeV/c")
    ax[2].axvline(2.0, color="gray", linestyle="--")

    ax[2].set_xlabel(L"$p_{\mathrm{T}}$ [GeV/c]")
    ax[2].set_ylabel("Ratio to Ref.")
    ax[2].tick_params(which="both", direction="in", top=true, right=true)
    ax[2].set_ylim(0.6, 1.4)
    ax[2].text(0.22, 0.8, "before rescaling", transform=ax[2].transAxes, fontsize=10, color="black")

    if excess == true
        ax[2].set_xlim(0, 0.5)
    end

    for i in 1:no_of_lists
        label_thermal = i == 1 ? "Thermal Spectrum" : ""
        label_total   = [["Reference", "Modified Parameters"]; fill("", no_of_lists - 2)][i]
        colors = i == 1 ? "tab:orange" : "tab:red"
        order = i == 1 ? 2 : 1
        if i == 1
            alpha = 1.0
        else 
            alpha = 0.3
        end
        rel_spectra_thermal = getindex.((results_cuts.spectra_thermal[i])[:],1) ./ getindex.((results_cuts.spectra_thermal[1])[:],1)
        rel_spectra_total   = getindex.((results_cuts.spectra_total[i])[:],1) ./ getindex.((results_cuts.spectra_total[1])[:],1)

        #ax.plot(data.pt, rel_spectra_thermal, label=label_thermal, color="blue", alpha=alpha)
        ax[3].plot(data.pt, rel_spectra_total, label=label_total, color=colors, alpha=alpha, zorder=order)
        
    end
    ax[3].axvline(0.5, color="gray", linestyle="--", label=L"$0.5 < p_{\mathrm{T}} < 2.0$ GeV/c")
    ax[3].axvline(2.0, color="gray", linestyle="--")

    ax[3].set_xlabel(L"$p_{\mathrm{T}}$ [GeV/c]")
    ax[3].set_ylabel("Ratio to Ref.")
    ax[3].tick_params(which="both", direction="in", top=true, right=true)
    ax[3].set_ylim(0.6, 1.4)
    ax[3].text(0.22, 0.8, "after rescaling", transform=ax[3].transAxes, fontsize=10, color="black")


    if save==true
        if excess == true
            fig.savefig(directory*"sample_pion_rel_spectra_pce_excess_3.png", dpi=300)
        else
            fig.savefig(directory*"sample_pion_rel_spectra_pce_3.png", dpi=300)
        end
    else
        fig.show()
    end

end




function plot_sample_spectra_relative_4(results_cuts::ResultsList, results_cuts_thermal::ResultsList, data::Data, mult_data; excess::Bool=false, save::Bool=false)

    no_of_lists = length(results_cuts.multiplicity_total)
    digits_print = 2;
    red_gradient = get_cmap("Reds", no_of_lists+7);
    blue_gradient = get_cmap("Blues", no_of_lists+7);

    stat_uncertainties = (-data.yerrm_stat, data.yerrp_stat)
    syst_uncertainties = (-data.yerrm_syst, data.yerrp_syst)
    total_uncertainties = (sqrt.(data.yerrm_stat.^2 .+ data.yerrm_syst.^2), sqrt.(data.yerrp_stat.^2 .+ data.yerrp_syst.^2))

    fig, ax = subplots(2,2, figsize=(10,5), sharex=true, sharey="row", gridspec_kw = Dict("height_ratios"=>[3,1], "hspace"=>0.05, "wspace"=>0.05))

    

    for i in 1:no_of_lists
        label_thermal = i == 1 ? "Thermal Spectrum" : ""
        label_total   = [["Reference", "Modified Parameters"]; fill("", no_of_lists - 2)][i]
        colors = i == 1 ? "tab:red" : "tab:orange"
        order = i == 1 ? 2 : 1
        if i == 1
            alpha = 1.0
        else 
            alpha = 0.3
        end
        # ax[1].plot(data.pt, getindex.((results_cuts_thermal.spectra_thermal[i])[:],1), label=label_thermal, color="blue", alpha=alpha)
        ax[1].plot(data.pt, getindex.((results_cuts_thermal.spectra_total[i])[:],1), label=label_total, color=colors, alpha=alpha, zorder=order)
        
    end

    ax[1].errorbar(data.pt, data.dNdpt, yerr=total_uncertainties, xerr=data.xerrm, fmt=".", label="ALICE Data", color="black")
    ax[1].axvline(0.5, color="gray", linestyle="--", label=L"$0.5 < p_{\mathrm{T}} < 2.0$ GeV/c")
    ax[1].axvline(2.0, color="gray", linestyle="--")

    ax[1].set_yscale("log")
    #ax[1].set_xlabel(L"$p_{\mathrm{T}}$ [GeV/c]")
    ax[1].set_ylabel(L"$1 / (2\pi p_{\mathrm{T}}) \,\, dN/dp_{\mathrm{T}}dy \, $ [(GeV/c)$^{-2}$]")
    ax[1].tick_params(which="both", direction="in", top=true, right=true)
    #ax[1].legend()
    ax[1].set_ylim(1e-2, 1e4)
    ax[1].set_xlim(0, 3.1)

    if excess == true
        ax[1].set_ylim(1e2, 2e3)
        ax[1].set_xlim(0.0, 0.5)
        ax[1].text(0.32, 1200, "PbPb @ 2.76 TeV")
        ax[1].text(0.32, 1000, "0-5% centrality")
    else
        label_n = 0.1
        ax[1].text(2.1, 300/label_n, "PbPb @ 2.76 TeV")
        ax[1].text(2.1, 150/label_n, "0-5% centrality")
        ax[1].text(2.1, 75/label_n, L"$\pi^+$ / $\pi^-$ ")
        ax[1].text(2.1, 38/label_n, "PDG2016+")
        ax[1].text(0.2, 0.1, "before rescaling", transform=ax[1].transAxes, fontsize=12, color="black")
    end

    for i in 1:no_of_lists
        label_thermal = i == 1 ? "Thermal Spectrum" : ""
        label_total   = [["Reference", "Modified Parameters"]; fill("", no_of_lists - 2)][i]
        colors = i == 1 ? "tab:red" : "tab:orange"
        order = i == 1 ? 2 : 1
        if i == 1
            alpha = 1.0
        else 
            alpha = 0.3
        end
        rel_spectra_thermal = getindex.((results_cuts_thermal.spectra_thermal[i])[:],1) ./ getindex.((results_cuts_thermal.spectra_thermal[1])[:],1)
        rel_spectra_total   = getindex.((results_cuts_thermal.spectra_total[i])[:],1) ./ getindex.((results_cuts_thermal.spectra_total[1])[:],1)

        #ax.plot(data.pt, rel_spectra_thermal, label=label_thermal, color="blue", alpha=alpha)
        ax[2].plot(data.pt, rel_spectra_total, label=label_total, color=colors, alpha=alpha, zorder=order)
        
    end
    ax[2].axvline(0.5, color="gray", linestyle="--", label=L"$0.5 < p_{\mathrm{T}} < 2.0$ GeV/c")
    ax[2].axvline(2.0, color="gray", linestyle="--")

    ax[2].set_xlabel(L"$p_{\mathrm{T}}$ [GeV/c]")
    ax[2].set_ylabel("Ratio to Ref.")
    ax[2].tick_params(which="both", direction="in", top=true, right=true)
    ax[2].set_ylim(0.6, 1.4)

    if excess == true
        ax[2].set_xlim(0, 0.5)
    end

    for i in 1:no_of_lists
        label_thermal = i == 1 ? "Thermal Spectrum" : ""
        label_total   = [["Reference", "Modified Parameters"]; fill("", no_of_lists - 2)][i]
        colors = i == 1 ? "tab:red" : "tab:orange"
        order = i == 1 ? 2 : 1
        if i == 1
            alpha = 1.0
        else 
            alpha = 0.3
        end
        # ax[1].plot(data.pt, getindex.((results_cuts.spectra_thermal[i])[:],1), label=label_thermal, color="blue", alpha=alpha)
        ax[3].plot(data.pt, getindex.((results_cuts.spectra_total[i])[:],1), label=label_total, color=colors, alpha=alpha, zorder=order)
        
    end

    ax[3].errorbar(data.pt, data.dNdpt, yerr=total_uncertainties, xerr=data.xerrm, fmt=".", label="ALICE Data", color="black")
    ax[3].axvline(0.5, color="gray", linestyle="--", label=L"$0.5 < p_{\mathrm{T}} < 2.0$ GeV/c")
    ax[3].axvline(2.0, color="gray", linestyle="--")
    ax[3].text(0.2, 0.1, "after rescaling", transform=ax[3].transAxes, fontsize=12, color="black")

    ax[3].set_yscale("log")
    #ax[3].set_xlabel(L"$p_{\mathrm{T}}$ [GeV/c]")
    #ax[3].set_ylabel(L"$1 / (2\pi p_{\mathrm{T}}) \,\, dN/dp_{\mathrm{T}}dy \, $ [(GeV/c)$^{-2}$]")
    ax[3].tick_params(which="both", direction="in", top=true, right=true)
    ax[3].legend()
    ax[3].set_ylim(1e-2, 1e4)

    for i in 1:no_of_lists
        label_thermal = i == 1 ? "Thermal Spectrum" : ""
        label_total   = [["Reference", "Modified Parameters"]; fill("", no_of_lists - 2)][i]
        colors = i == 1 ? "tab:red" : "tab:orange"
        order = i == 1 ? 2 : 1
        if i == 1
            alpha = 1.0
        else 
            alpha = 0.3
        end
        rel_spectra_thermal = getindex.((results_cuts.spectra_thermal[i])[:],1) ./ getindex.((results_cuts.spectra_thermal[1])[:],1)
        rel_spectra_total   = getindex.((results_cuts.spectra_total[i])[:],1) ./ getindex.((results_cuts.spectra_total[1])[:],1)

        #ax.plot(data.pt, rel_spectra_thermal, label=label_thermal, color="blue", alpha=alpha)
        ax[4].plot(data.pt, rel_spectra_total, label=label_total, color=colors, alpha=alpha, zorder=order)
        
    end
    ax[4].axvline(0.5, color="gray", linestyle="--", label=L"$0.5 < p_{\mathrm{T}} < 2.0$ GeV/c")
    ax[4].axvline(2.0, color="gray", linestyle="--")

    ax[4].set_xlabel(L"$p_{\mathrm{T}}$ [GeV/c]")
    #ax[4].set_ylabel("Ratio to Ref.")
    ax[4].tick_params(which="both", direction="in", top=true, right=true)
    ax[4].set_ylim(0.6, 1.4)

    if save==true
        if excess == true
            fig.savefig(directory*"sample_pion_rel_spectra_pce_excess_4.png", dpi=300, bbox_inches="tight")
        else
            fig.savefig(directory*"sample_pion_rel_spectra_pce_4.png", dpi=300, bbox_inches="tight")
        end
    else
        fig.show()
    end

end













































function plot_excess(excess, excess_err_exp, excess_err_mod; nsigma::Bool=false, edge::Bool=false, save::Bool=false)

    fig, ax = subplots(1,1, figsize=(5,5));
    if nsigma == true
        excess1 = excess[2:7]
        excess2 = excess[8:13]
        excess3 = excess[14:19]
        println("length excess1: $(length(excess1))", " length excess2: $(length(excess2))", " length excess3: $(length(excess3))");
        println("length excess1 x: $(collect(2:length(excess1)+1))", " length excess2 x: $(collect(2:length(excess2)+1))", " length excess3 x: $(collect(2:length(excess3)+1))");
        excess_err_exp1 = excess_err_exp[2:7]
        excess_err_exp2 = excess_err_exp[8:13]
        excess_err_exp3 = excess_err_exp[14:19]
        excess_err_mod1 = excess_err_mod[2:7]
        excess_err_mod2 = excess_err_mod[8:13]
        excess_err_mod3 = excess_err_mod[14:19]
        ax.errorbar(1, excess[1], yerr=excess_err_exp[1], fmt="o", color="black", label="Experimental Uncertainty")
        ax.errorbar(1, excess[1], yerr=excess_err_mod[1], fmt="o", color="black", alpha=0.3, elinewidth=6, label="Model Uncertainty")
        ax.errorbar(collect(2:length(excess1)+1), excess1, yerr=excess_err_exp1, fmt="o", color="tab:red", label=L"$1\sigma$")
        ax.errorbar(collect(2:length(excess1)+1), excess1, yerr=excess_err_mod1, fmt="o", color="tab:red", alpha=0.3, elinewidth=6)
        ax.errorbar(collect(2:length(excess2)+1), excess2, yerr=excess_err_exp2, fmt="o", color="tab:blue", label=L"$2\sigma$")
        ax.errorbar(collect(2:length(excess2)+1), excess2, yerr=excess_err_mod2, fmt="o", color="tab:blue", alpha=0.3, elinewidth=6)
        ax.errorbar(collect(2:length(excess3)+1), excess3, yerr=excess_err_exp3, fmt="o", color="tab:green", label=L"$3\sigma$")
        ax.errorbar(collect(2:length(excess3)+1), excess3, yerr=excess_err_mod3, fmt="o", color="tab:green", alpha=0.3, elinewidth=6)
    else
        ax.errorbar(collect(1:length(excess)), excess, yerr=excess_err_exp, fmt="o", color="black", label="Experimental Uncertainty")
        ax.errorbar(collect(1:length(excess)), excess, yerr=excess_err_mod, fmt="o", color="black", alpha=0.3, elinewidth=6, label="Model Uncertainty")
    end

    
    if edge == true
        labels = ["Reference", "Mass +", "Mass -", "Width +", "Width -", "BR +", "BR -"];
        if nsigma == true
            ax.set_xticks(collect(1:length(excess1)+1))
        else
            ax.set_xticks(collect(1:length(excess)))
        end
        ax.set_xticklabels(labels, rotation=45)
    end
    #ax.set_xlabel("Sampling cases")
    ax.set_ylabel("pion excess")
    #ax.set_title("Pion Excess")
    if nsigma == true
        ax.text(0.15 * length(excess1), 140, "PbPb @ 2.76 TeV")
        ax.text(0.15 * length(excess1), 130, "0-5% centrality")
        ax.set_xlim(0.5, length(excess1)+1.5)
    else
        ax.text(0.15 * length(excess), 140, "PbPb @ 2.76 TeV")
        ax.text(0.15 * length(excess), 130, "0-5% centrality")
        ax.set_xlim(0.5, length(excess)+0.5)
    end
    
    mean_excess = mean(excess)
    std_excess = std(excess)
    println("Mean Excess: $(mean_excess) ± $(std_excess)")
    #ax.text(0.4 * length(excess), 20, "Mean Excess: $(round(mean_excess, digits=2)) ± $(round(std_excess, digits=2))")
    ax.tick_params(which="both", direction="in", top=true, right=true)
    ax.legend()
    ax.set_ylim(0, 150)
    

    if save==true
        fig.savefig(directory*"pion_excess.png", dpi=300, bbox_inches="tight")
    end
    
end


function plot_rel_excess(rel_excess, rel_excess_err_exp, rel_excess_err_mod; nsigma::Bool=false, edge::Bool=false, save::Bool=false)

    fig, ax = subplots(1,1, figsize=(5,5));

    if nsigma == true
        excess1 = rel_excess[2:7]
        excess2 = rel_excess[8:13]
        excess3 = rel_excess[14:19]
        excess_err_exp1 = rel_excess_err_exp[2:7]
        excess_err_exp2 = rel_excess_err_exp[8:13]
        excess_err_exp3 = rel_excess_err_exp[14:19]
        excess_err_mod1 = rel_excess_err_mod[2:7]
        excess_err_mod2 = rel_excess_err_mod[8:13]
        excess_err_mod3 = rel_excess_err_mod[14:19]
        ax.errorbar(1, rel_excess[1], yerr=rel_excess_err_exp[1], fmt="o", color="black", label="Experimental Uncertainty")
        ax.errorbar(1, rel_excess[1], yerr=rel_excess_err_mod[1], fmt="o", color="black", alpha=0.3, elinewidth=6, label="Model Uncertainty")
        ax.errorbar(collect(2:length(excess1)+1), excess1, yerr=excess_err_exp1, fmt="o", color="tab:red", label=L"$1\sigma$")
        ax.errorbar(collect(2:length(excess1)+1), excess1, yerr=excess_err_mod1, fmt="o", color="tab:red", alpha=0.3, elinewidth=6)
        ax.errorbar(collect(2:length(excess2)+1), excess2, yerr=excess_err_exp2, fmt="o", color="tab:blue", label=L"$2\sigma$")
        ax.errorbar(collect(2:length(excess2)+1), excess2, yerr=excess_err_mod2, fmt="o", color="tab:blue", alpha=0.3, elinewidth=6)
        ax.errorbar(collect(2:length(excess3)+1), excess3, yerr=excess_err_exp3, fmt="o", color="tab:green", label=L"$3\sigma$")
        ax.errorbar(collect(2:length(excess3)+1), excess3, yerr=excess_err_mod3, fmt="o", color="tab:green", alpha=0.3, elinewidth=6)
    else
        ax.errorbar(collect(1:length(rel_excess)), rel_excess, yerr=rel_excess_err_exp, fmt="o", color="black", label="Experimental Uncertainty")
        ax.errorbar(collect(1:length(rel_excess)), rel_excess, yerr=rel_excess_err_mod, fmt="o", color="black", alpha=0.3, elinewidth=6, label="Model Uncertainty")
    end

    if edge == true
        labels = ["Reference", "Mass +", "Mass -", "Width +", "Width -", "BR +", "BR -"];
        if nsigma == true
            ax.set_xticks(collect(1:length(excess1)+1))
        else
            ax.set_xticks(collect(1:length(rel_excess)))
        end
        ax.set_xticklabels(labels, rotation=45)
    end

    #ax.set_xlabel("sampling cases")
    ax.set_ylabel("relative pion excess")
    #ax.set_title("Relative Pion Excess")
   if nsigma == true
        ax.text(0.15 * length(excess1), 0.35, "PbPb @ 2.76 TeV")
        ax.text(0.15 * length(excess1), 0.33, "0-5% centrality")
        ax.set_xlim(0.5, length(excess1)+1.5)
    else
        ax.text(0.15 * length(rel_excess), 0.35, "PbPb @ 2.76 TeV")
        ax.text(0.15 * length(rel_excess), 0.33, "0-5% centrality")
        ax.set_xlim(0.5, length(rel_excess)+0.5)
    end
    mean_excess = mean(rel_excess)
    std_excess = std(rel_excess)
    println("Mean relative Excess: $(mean_excess) ± $(std_excess)")
    #ax.text(0.3 * length(rel_excess), 0.2, "Mean relative Excess: $(round(mean_excess, digits=2)) ± $(round(std_excess, digits=2))")
    ax.tick_params(which="both", direction="in", top=true, right=true)
    ax.legend()
    ax.set_ylim(0, 0.4)

    if save==true
        fig.savefig(directory*"pion_rel_excess.png", dpi=400, bbox_inches="tight")
    end
    
end




function plot_excess_hist(excess; save::Bool=false)

    fig, ax = subplots(1,1, figsize=(5,5));
    ax.hist(excess, bins=15, alpha=1, label="Samples")
    ax.set_ylabel("Counts")
    ax.axvline(x=excess[1], linestyle="--", linewidth=2, label="Reference Case", color="black")
    #ax.axvline(x=excess[2002], linestyle="--", linewidth=2, label="Mean sampled masses", color="red")
    ax.set_xlabel(L"$dN/dy(data)_{0.1-0.5}$ - $dN/dy(model)_{0.1-0.5}$")
    #ax.set_title("Pion Excess")
    ax.text(0.05, 0.9, "PbPb @ 2.76 TeV", transform=ax.transAxes)
    ax.text(0.05, 0.85, "0-5% centrality", transform=ax.transAxes)
    ax.text(0.05, 0.8, "Total sampled: $(length(excess)-2)", transform=ax.transAxes)
    mean_excess = mean(excess)
    std_excess = std(excess)
    ax.text(0.05, 0.7, "Mean: $(round(mean_excess, digits=3))", transform=ax.transAxes)
    ax.text(0.05, 0.65, "Std: $(round(std_excess, digits=3))", transform=ax.transAxes)
    ax.tick_params(which="both", direction="in", top=true, right=true)
    ax.set_xlim(50, 80)
    ax.legend()

    if save==true
        fig.savefig(directory*"pion_excess_hist.png", dpi=300)
    end
    
end




function plot_rel_excess_hist(excess; save::Bool=false)

    fig, ax = subplots(1,1, figsize=(5,5));
    ax.hist(excess, bins=20, alpha=1, label="Samples")
    ax.set_ylabel("Counts")
    ax.axvline(x=excess[1], linestyle="--", linewidth=2, label="Reference Case", color="black")
    #ax.axvline(x=excess[2002], linestyle="--", linewidth=2, label="Mean sampled masses", color="red")
    ax.set_xlabel("relative pion excess")
    #ax.set_title("Pion Excess")
    ax.text(0.05, 0.9, "PbPb @ 2.76 TeV", transform=ax.transAxes)
    ax.text(0.05, 0.85, "0-5% centrality", transform=ax.transAxes)
    ax.text(0.05, 0.8, "Total sampled: $(length(excess)-2)", transform=ax.transAxes)
    mean_excess = mean(excess)
    std_excess = std(excess)
    ax.text(0.05, 0.7, "Mean: $(round(mean_excess, digits=4))", transform=ax.transAxes)
    ax.text(0.05, 0.65, "Std: $(round(std_excess, digits=4))", transform=ax.transAxes)
    ax.tick_params(which="both", direction="in", top=true, right=true)
    ax.set_xlim(0.08, 0.115)
    ax.legend()

    if save==true
        fig.savefig(directory*"pion_rel_excess_hist.png", dpi=300)
    end
    
end





function plot_mean_pT(mean_pT_list, mean_pT_err_list; nsigma::Bool=false, edge::Bool=false, save::Bool=false)

    if nsigma == true
        pT1 = mean_pT_list[2:7]
        pT2 = mean_pT_list[8:13]
        pT3 = mean_pT_list[14:19]
        pT_err1 = mean_pT_err_list[2:7]
        pT_err2 = mean_pT_err_list[8:13]
        pT_err3 = mean_pT_err_list[14:19]
    end

    fig, ax = subplots(2,1, figsize=(5,4.5), sharex=true, gridspec_kw = Dict("height_ratios"=>[3,1], "hspace"=>0.05));
    if nsigma == true
        ax[1].errorbar(1, mean_pT_list[1], yerr=mean_pT_err_list[1], fmt="o", color="black", label="Reference")
        ax[1].errorbar(collect(2:length(pT1)+1), pT1, yerr=pT_err1, fmt="o", color="tab:red", label=L"$1\sigma$")
        ax[1].errorbar(collect(2:length(pT2)+1), pT2, yerr=pT_err2, fmt="o", color="tab:blue", label=L"$2\sigma$")
        ax[1].errorbar(collect(2:length(pT3)+1), pT3, yerr=pT_err3, fmt="o", color="tab:green", label=L"$3\sigma$")
        ax[1].legend()
    else
        ax[1].errorbar(collect(1:length(mean_pT_list)), mean_pT_list, yerr=mean_pT_err_list, fmt="o", color="black")
    end
    if edge == true
        labels = ["Reference", "Mass +", "Mass -", "Width +", "Width -", "BR +", "BR -"];
        if nsigma == true
            ax[2].set_xticks(collect(1:length(pT1)+1))
        else
            ax[2].set_xticks(collect(1:length(mean_pT_list)))
        end
        ax[2].set_xticklabels(labels, rotation=45)
    end
    #ax[2].set_xlabel("Sampling cases")
    ax[1].set_ylabel(L"<pT>")
    #ax[1].set_title("Mean pT")
    if nsigma == true
        ax[1].text(0.15 * length(pT1), 1.07 * maximum(pT1), "PbPb @ 2.76 TeV")
        ax[1].text(0.15 * length(pT1), 1.05 * maximum(pT1), "0-5% centrality")
        ax[1].set_xlim(0.5, length(pT1)+1.5)
    else
        ax[1].text(0.65 * length(mean_pT_list), 1.01 * maximum(mean_pT_list), "PbPb @ 2.76 TeV")
        ax[1].text(0.65 * length(mean_pT_list), 1.007 * maximum(mean_pT_list), "0-5% centrality")
        ax[1].set_xlim(0.5, length(mean_pT_list)+0.5)
    end
    ax[1].tick_params(which="both", direction="in", top=true, right=true)
    ax[1].set_ylim(0.55, 0.65)

    rel_mean_pT_list = (mean_pT_list .- mean_pT_list[1]) ./ mean_pT_list[1]
    rel_mean_pT_err_list = mean_pT_err_list ./ mean_pT_list[1]

    if nsigma == true
        rel_pT1 = rel_mean_pT_list[2:7]
        rel_pT2 = rel_mean_pT_list[8:13]
        rel_pT3 = rel_mean_pT_list[14:19]
        rel_pT_err1 = rel_mean_pT_err_list[2:7]
        rel_pT_err2 = rel_mean_pT_err_list[8:13]
        rel_pT_err3 = rel_mean_pT_err_list[14:19]
        ax[2].errorbar(1, rel_mean_pT_list[1], yerr=rel_mean_pT_err_list[1], fmt="o", color="black")
        ax[2].errorbar(collect(2:length(rel_pT1)+1), rel_pT1, yerr=rel_pT_err1, fmt="o", color="tab:red")
        ax[2].errorbar(collect(2:length(rel_pT2)+1), rel_pT2, yerr=rel_pT_err2, fmt="o", color="tab:blue")
        ax[2].errorbar(collect(2:length(rel_pT3)+1), rel_pT3, yerr=rel_pT_err3, fmt="o", color="tab:green")
    else
        ax[2].errorbar(collect(1:length(mean_pT_list)), rel_mean_pT_list, yerr=rel_mean_pT_err_list, fmt="o", color="black")
    end
    ax[2].axhline(y=0, linestyle="--", linewidth=1, color="gray")
    ax[2].set_ylabel(L"$(<pT> - <pT>_{ref}) / <pT>_{ref}$")
    ax[2].set_ylim(-0.05, 0.05)
    ax[2].tick_params(which="both", direction="in", top=true, right=true)

    fig.tight_layout()

    if save==true
        fig.savefig(directory*"mean_pT.png", dpi=300, bbox_inches="tight")
    end
    
end
