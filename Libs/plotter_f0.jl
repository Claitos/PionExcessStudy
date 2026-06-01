include("results_lib.jl");
using LaTeXStrings


function plot_excess_f0(excess, excess_err_exp, excess_err_mod; nsigma::Bool=false, edge::Bool=false, save::Bool=false)

    fig, ax = subplots(1,1, figsize=(5,5));
    if nsigma == true
        excess1 = excess[3:8]
        excess2 = excess[10:15]
        println("length excess1: $(length(excess1))", " length excess2: $(length(excess2))");
        excess_err_exp1 = excess_err_exp[3:8]
        excess_err_exp2 = excess_err_exp[10:15]
        excess_err_mod1 = excess_err_mod[3:8]
        excess_err_mod2 = excess_err_mod[10:15]
        ax.errorbar(1, excess[1], yerr=excess_err_exp[1], fmt="o", color="black", label="Experimental Uncertainty")
        ax.errorbar(1, excess[1], yerr=excess_err_mod[1], fmt="o", color="black", alpha=0.3, elinewidth=6, label="Model Uncertainty")
        ax.errorbar(2, excess[2], yerr=excess_err_exp[2], fmt="o", color="black")
        ax.errorbar(2, excess[2], yerr=excess_err_mod[2], fmt="o", color="black", alpha=0.3, elinewidth=6)
        colors = ["tab:red", "tab:blue", "tab:green"]
        for i in 1:3
            ax.errorbar(3, excess1[2*i-1], yerr=excess_err_exp1[2*i-1], fmt="o", color=colors[i], label=L"%$i $\sigma$")
            ax.errorbar(3, excess1[2*i-1], yerr=excess_err_mod1[2*i-1], fmt="o", color=colors[i], alpha=0.3, elinewidth=6)
            ax.errorbar(4, excess1[2*i], yerr=excess_err_exp1[2*i], fmt="o", color=colors[i])
            ax.errorbar(4, excess1[2*i], yerr=excess_err_mod1[2*i], fmt="o", color=colors[i], alpha=0.3, elinewidth=6)
        end
        ax.errorbar(5, excess[9], yerr=excess_err_exp[9], fmt="o", color="black")
        ax.errorbar(5, excess[9], yerr=excess_err_mod[9], fmt="o", color="black", alpha=0.3, elinewidth=6)
        for i in 1:3
            ax.errorbar(6, excess2[2*i-1], yerr=excess_err_exp2[2*i-1], fmt="o", color=colors[i])
            ax.errorbar(6, excess2[2*i-1], yerr=excess_err_mod2[2*i-1], fmt="o", color=colors[i], alpha=0.3, elinewidth=6)
            ax.errorbar(7, excess2[2*i], yerr=excess_err_exp2[2*i], fmt="o", color=colors[i])
            ax.errorbar(7, excess2[2*i], yerr=excess_err_mod2[2*i], fmt="o", color=colors[i], alpha=0.3, elinewidth=6)
        end
    else
        ax.errorbar(collect(1:length(excess)), excess, yerr=excess_err_exp, fmt="o", color="black", label="Experimental Uncertainty")
        ax.errorbar(collect(1:length(excess)), excess, yerr=excess_err_mod, fmt="o", color="black", alpha=0.3, elinewidth=6, label="Model Uncertainty")
    end

    
    if edge == true
        labels = ["Reference", "with f0", "Mass +", "Mass -", "with f0 width", "Mass +", "Mass -"];
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





function plot_rel_excess_f0(rel_excess, rel_excess_err_exp, rel_excess_err_mod; nsigma::Bool=false, edge::Bool=false, save::Bool=false)

    fig, ax = subplots(1,1, figsize=(5,5));

    if nsigma == true
        excess1 = rel_excess[3:8]
        excess2 = rel_excess[10:15]
        println("length excess1: $(length(excess1))", " length excess2: $(length(excess2))");
        excess_err_exp1 = rel_excess_err_exp[3:8]
        excess_err_exp2 = rel_excess_err_exp[10:15]
        excess_err_mod1 = rel_excess_err_mod[3:8]
        excess_err_mod2 = rel_excess_err_mod[10:15]
        ax.errorbar(1, rel_excess[1], yerr=rel_excess_err_exp[1], fmt="o", color="black", label="Experimental Uncertainty")
        ax.errorbar(1, rel_excess[1], yerr=rel_excess_err_mod[1], fmt="o", color="black", alpha=0.3, elinewidth=6, label="Model Uncertainty")
        ax.errorbar(2, rel_excess[2], yerr=rel_excess_err_exp[2], fmt="o", color="black")
        ax.errorbar(2, rel_excess[2], yerr=rel_excess_err_mod[2], fmt="o", color="black", alpha=0.3, elinewidth=6)
        colors = ["tab:red", "tab:blue", "tab:green"]
        for i in 1:3
            ax.errorbar(3, excess1[2*i-1], yerr=excess_err_exp1[2*i-1], fmt="o", color=colors[i], label=L"%$i $\sigma$")
            ax.errorbar(3, excess1[2*i-1], yerr=excess_err_mod1[2*i-1], fmt="o", color=colors[i], alpha=0.3, elinewidth=6)
            ax.errorbar(4, excess1[2*i], yerr=excess_err_exp1[2*i], fmt="o", color=colors[i])
            ax.errorbar(4, excess1[2*i], yerr=excess_err_mod1[2*i], fmt="o", color=colors[i], alpha=0.3, elinewidth=6)
        end
        ax.errorbar(5, rel_excess[9], yerr=rel_excess_err_exp[9], fmt="o", color="black")
        ax.errorbar(5, rel_excess[9], yerr=rel_excess_err_mod[9], fmt="o", color="black", alpha=0.3, elinewidth=6)
        for i in 1:3
            ax.errorbar(6, excess2[2*i-1], yerr=excess_err_exp2[2*i-1], fmt="o", color=colors[i])
            ax.errorbar(6, excess2[2*i-1], yerr=excess_err_mod2[2*i-1], fmt="o", color=colors[i], alpha=0.3, elinewidth=6)
            ax.errorbar(7, excess2[2*i], yerr=excess_err_exp2[2*i], fmt="o", color=colors[i])
            ax.errorbar(7, excess2[2*i], yerr=excess_err_mod2[2*i], fmt="o", color=colors[i], alpha=0.3, elinewidth=6)
        end
    else
        ax.errorbar(collect(1:length(rel_excess)), rel_excess, yerr=rel_excess_err_exp, fmt="o", color="black", label="Experimental Uncertainty")
        ax.errorbar(collect(1:length(rel_excess)), rel_excess, yerr=rel_excess_err_mod, fmt="o", color="black", alpha=0.3, elinewidth=6, label="Model Uncertainty")
    end

    if edge == true
        labels = ["Reference", "with f0", "Mass +", "Mass -", "with f0 width", "Mass +", "Mass -"];
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




function plot_rel_excess_f0_colors(rel_excess, rel_excess_err_exp, rel_excess_err_mod; nsigma::Bool=false, edge::Bool=false, save::Bool=false)

    fig, ax = subplots(1,1, figsize=(5,5));

    if nsigma == true
        excess1 = rel_excess[3:8]
        excess2 = rel_excess[10:15]
        println("length excess1: $(length(excess1))", " length excess2: $(length(excess2))");
        excess_err_exp1 = rel_excess_err_exp[3:8]
        excess_err_exp2 = rel_excess_err_exp[10:15]
        excess_err_mod1 = rel_excess_err_mod[3:8]
        excess_err_mod2 = rel_excess_err_mod[10:15]
        colors = ["tab:red", "tab:blue", "tab:green"]
        ax.errorbar(1, rel_excess[1], yerr=rel_excess_err_exp[1], fmt="o", color=colors[1], label="Experimental Uncertainty")
        ax.axhline(rel_excess[1], color=colors[1], linestyle="dashed")
        ax.errorbar(1, rel_excess[1], yerr=rel_excess_err_mod[1], fmt="o", color=colors[1], alpha=0.3, elinewidth=6, label="Model Uncertainty")
        ax.errorbar(2, rel_excess[2], yerr=rel_excess_err_exp[2], fmt="o", color=colors[3], label="without Width")
        ax.errorbar(2, rel_excess[2], yerr=rel_excess_err_mod[2], fmt="o", color=colors[3], alpha=0.3, elinewidth=6)
        ax.errorbar(2, rel_excess[9], yerr=rel_excess_err_exp[9], fmt="o", color=colors[2], label="with Width")
        ax.errorbar(2, rel_excess[9], yerr=rel_excess_err_mod[9], fmt="o", color=colors[2], alpha=0.3, elinewidth=6)
        
        marker = "D"
        ax.errorbar(100, 1, yerr=1, fmt=marker, color="black", label=L"$f_0(500)$ mass edges") # only to show the marker in the legend

        for i in 1:3
            ax.errorbar(i+2, excess1[2*i-1], yerr=excess_err_exp1[2*i-1], fmt=marker, color=colors[3])
            ax.errorbar(i+2, excess1[2*i-1], yerr=excess_err_mod1[2*i-1], fmt=marker, color=colors[3], alpha=0.3, elinewidth=6)
            ax.errorbar(i+2, excess2[2*i-1], yerr=excess_err_exp2[2*i-1], fmt=marker, color=colors[2])
            ax.errorbar(i+2, excess2[2*i-1], yerr=excess_err_mod2[2*i-1], fmt=marker, color=colors[2], alpha=0.3, elinewidth=6)

            ax.errorbar(i+5, excess1[2*i], yerr=excess_err_exp2[2*i], fmt=marker, color=colors[3])
            ax.errorbar(i+5, excess1[2*i], yerr=excess_err_mod2[2*i], fmt=marker, color=colors[3], alpha=0.3, elinewidth=6)
            ax.errorbar(i+5, excess2[2*i], yerr=excess_err_exp2[2*i], fmt=marker, color=colors[2])
            ax.errorbar(i+5, excess2[2*i], yerr=excess_err_mod2[2*i], fmt=marker, color=colors[2], alpha=0.3, elinewidth=6)
        end
        
    else
        ax.errorbar(collect(1:length(rel_excess)), rel_excess, yerr=rel_excess_err_exp, fmt="o", color="black", label="Experimental Uncertainty")
        ax.errorbar(collect(1:length(rel_excess)), rel_excess, yerr=rel_excess_err_mod, fmt="o", color="black", alpha=0.3, elinewidth=6, label="Model Uncertainty")
    end

    if edge == true
        labels = ["Reference", L"with $f_{0}(500)$", L"+1$\sigma$", L"+2$\sigma$", L"+3$\sigma$", L"-1$\sigma$", L"-2$\sigma$", L"-3$\sigma$"];
        if nsigma == true
            ax.set_xticks(collect(1:length(excess1)+2))
        else
            ax.set_xticks(collect(1:length(rel_excess)))
        end
        ax.set_xticklabels(labels, rotation=45)
    end

    #ax.set_xlabel("sampling cases")
    ax.set_ylabel("relative pion excess")
    #ax.set_title("Relative Pion Excess")
   if nsigma == true
        ax.set_xlim(0.5, length(excess1)+2.5)
    else
        ax.set_xlim(0.5, length(rel_excess)+0.5)
    end

    ax.text(0.05, 0.92, "PbPb @ 2.76 TeV", transform=ax.transAxes)
    ax.text(0.05, 0.88, "0-5% centrality", transform=ax.transAxes)
    ax.text(0.05, 0.84, L"$\pi^+$ / $\pi^-$ ", transform=ax.transAxes)
    ax.text(0.05, 0.80, "PDG2016+", transform=ax.transAxes)


    mean_excess = mean(rel_excess)
    std_excess = std(rel_excess)
    println("Mean relative Excess: $(mean_excess) ± $(std_excess)")
    #ax.text(0.3 * length(rel_excess), 0.2, "Mean relative Excess: $(round(mean_excess, digits=2)) ± $(round(std_excess, digits=2))")
    ax.tick_params(which="both", direction="in", top=true, right=true)
    ax.legend()
    ax.set_ylim(0, 0.3)

    if save==true
        fig.savefig(directory*"pion_rel_excess_colors.png", dpi=400, bbox_inches="tight")
    end
    
end




function plot_sample_spectra_difference(results_cuts::ResultsList, data::Data, mult_data; excess::Bool=false, save::Bool=false)

    fig, ax = subplots(2,1, figsize=(5.1,5), sharex=true, gridspec_kw = Dict("height_ratios"=>[3,1], "hspace"=>0.05))

    # inidces = [1 ref, 2 f0, 3 +sigma, 4 -sigma, 5, 6, 7, 8, 9 f0w, 10 +sigma, 11 -sigma, 12, 13, 14, 15]
    indices = [1, 2, 3, 4, 9, 10, 11]
    colors = ["tab:red", "tab:blue", "tab:blue", "tab:blue", "tab:green", "tab:green", "tab:green"]
    labels = ["Reference", "with f0", "", "", "with f0 width", "", ""];

    for (j, i) in enumerate(indices)
        if i == 1
            alpha = 1.0
        else 
            alpha = 0.5
        end
        #ax[1].plot(data.pt, getindex.((results_cuts.spectra_thermal[i])[:],1), label=label_thermal, color="blue", alpha=alpha)
        ax[1].plot(data.pt, getindex.((results_cuts.spectra_total[i])[:],1), label=labels[j], color=colors[j], alpha=alpha)
        
    end

    ax[1].errorbar(data.pt, data.dNdpt, yerr=(-data.yerrm_stat,data.yerrp_stat), xerr=data.xerrm, fmt=".", label="ALICE Data", color="black")

    ax[1].set_yscale("log")
    #ax[1].set_xlabel(L"$p_{\mathrm{T}}$ [GeV/c]")
    ax[1].set_ylabel(L"$1/(2πp_{\mathrm{T}})$ $dN/dp_{\mathrm{T}}dy$ [1/GeV/c]")
    ax[1].tick_params(which="both", direction="in", top=true, right=true)
    ax[1].legend()
    ax[1].set_ylim(1e-2, 1e4)


    if excess == true
        ax[1].set_ylim(1e2, 2e3)
        ax[1].set_xlim(0.0, 0.5)
        ax[1].text(0.3, 1200, "PbPb @ 2.76 TeV")
        ax[1].text(0.3, 1000, "0-5% centrality")
    else
        ax[1].text(2, 3000, "PbPb @ 2.76 TeV")
        ax[1].text(2, 1500, "0-5% centrality")
    end

    for (j, i) in enumerate(indices)
        label_total   = labels[j]
        if i == 1
            alpha = 1.0
        else 
            alpha = 0.5
        end
        diff_spectra_thermal = getindex.((results_cuts.spectra_thermal[i])[:],1) .- getindex.((results_cuts.spectra_thermal[1])[:],1)
        diff_spectra_total   = getindex.((results_cuts.spectra_total[i])[:],1) .- getindex.((results_cuts.spectra_total[1])[:],1)

        #ax.plot(data.pt, rel_spectra_thermal, label=label_thermal, color="blue", alpha=alpha)
        ax[2].plot(data.pt, diff_spectra_total, label=label_total, color=colors[j], alpha=alpha)
        
    end

    ax[2].set_xlabel(L"$p_{\mathrm{T}}$ [GeV/c]")
    ax[2].set_ylabel("difference [1/GeV/c]")
    ax[2].tick_params(which="both", direction="in", top=true, right=true)
    ax[2].set_ylim(-10, 140)
    #ax[2].set_yscale("log")

    if excess == true
        ax[2].set_xlim(0, 0.5)
    end

    if save==true
        if excess == true
            fig.savefig(directory*"sample_pion_diff_spectra_pce_excess.png", dpi=300)
        else
            fig.savefig(directory*"sample_pion_diff_spectra_pce.png", dpi=300)
        end
    else
        fig.show()
    end

end


function plot_sample_spectra_difference_scaled(results_cuts::ResultsList, data::Data, scaling_factor; excess::Bool=false, save::Bool=false)

    fig, ax = subplots(2,1, figsize=(5.1,5), sharex=true, gridspec_kw = Dict("height_ratios"=>[3,1], "hspace"=>0.05))

    # inidces = [1 ref, 2 f0, 3 +sigma, 4 -sigma, 5, 6, 7, 8, 9 f0w, 10 +sigma, 11 -sigma, 12, 13, 14, 15]
    indices = [1, 2, 3, 4, 9, 10, 11]
    colors = ["tab:red", "tab:blue", "tab:blue", "tab:blue", "tab:green", "tab:green", "tab:green"]
    labels = ["Reference", "with f0", "", "", "with f0 width", "", ""];

    for (j, i) in enumerate(indices)
        if i == 1
            alpha = 1.0
        else 
            alpha = 0.5
        end
        #ax[1].plot(data.pt, getindex.((results_cuts.spectra_thermal[i])[:],1), label=label_thermal, color="blue", alpha=alpha)
        ax[1].plot(data.pt, getindex.((results_cuts.spectra_total[i])[:],1), label=labels[j], color=colors[j], alpha=alpha)
        
    end

    ax[1].errorbar(data.pt, data.dNdpt, yerr=(-data.yerrm_stat,data.yerrp_stat), xerr=data.xerrm, fmt=".", label="ALICE Data", color="black")

    ax[1].set_yscale("log")
    #ax[1].set_xlabel(L"$p_{\mathrm{T}}$ [GeV/c]")
    ax[1].set_ylabel(L"$1/(2πp_{\mathrm{T}})$ $dN/dp_{\mathrm{T}}dy$ [1/GeV/c]")
    ax[1].tick_params(which="both", direction="in", top=true, right=true)
    #ax[1].legend()
    ax[1].set_ylim(1e-2, 1e4)


    if excess == true
        ax[1].set_ylim(1e2, 2e3)
        ax[1].set_xlim(0.0, 0.5)
        ax[1].text(0.3, 1200, "PbPb @ 2.76 TeV")
        ax[1].text(0.3, 1000, "0-5% centrality")
    else
        ax[1].text(2, 3000, "PbPb @ 2.76 TeV")
        ax[1].text(2, 1500, "0-5% centrality")
    end

    for (j, i) in enumerate(indices)
        label_total   = labels[j]
        if i == 1
            alpha = 1.0
        else 
            alpha = 0.5
        end
        diff_spectra_thermal = getindex.((results_cuts.spectra_thermal[i])[:],1) .- getindex.((results_cuts.spectra_thermal[1])[:],1)
        diff_spectra_total   = getindex.((results_cuts.spectra_total[i])[:],1) .- getindex.((results_cuts.spectra_total[1])[:],1)

        #ax.plot(data.pt, rel_spectra_thermal, label=label_thermal, color="blue", alpha=alpha)
        ax[2].plot(data.pt, diff_spectra_total, label=label_total, color=colors[j], alpha=alpha)

        if i == 2 || i == 9 # only scale the f0 cases
            spectra_scaled_diff = diff_spectra_total .* scaling_factor .+ getindex.((results_cuts.spectra_total[1])[:],1)
            ax[1].plot(data.pt, spectra_scaled_diff, label=label_total*"*"*string(scaling_factor), color=colors[j], alpha=alpha, linestyle="--")
            pt_diff = data.ptp - data.ptm
            multiplicity_scaled = sum(2pi .* data.pt .* spectra_scaled_diff .* pt_diff) 
            println("Multiplicity for ", label_total, " scaled by ", scaling_factor, ": ", multiplicity_scaled)
        end
    end
    ax[1].legend()

    ax[2].set_xlabel(L"$p_{\mathrm{T}}$ [GeV/c]")
    ax[2].set_ylabel("difference [1/GeV/c]")
    ax[2].tick_params(which="both", direction="in", top=true, right=true)
    ax[2].set_ylim(-10, 140)
    #ax[2].set_yscale("log")

    if excess == true
        ax[2].set_xlim(0, 0.5)
    end

    if save==true
        if excess == true
            fig.savefig(directory*"sample_pion_diff_spectra_scaled_pce_excess.png", dpi=300)
        else
            fig.savefig(directory*"sample_pion_diff_spectra_scaled_pce.png", dpi=300)
        end
    else
        fig.show()
    end

end






function plot_yield_ratio_f0(yield_ratio, yield_ratio_err; nsigma::Bool=false, edge::Bool=false, save::Bool=false)

    fig, ax = subplots(1,1, figsize=(5,5));

    if nsigma == true
        excess1 = yield_ratio[3:8]
        excess2 = yield_ratio[10:15]
        println("length excess1: $(length(excess1))", " length excess2: $(length(excess2))");
        excess_err1 = yield_ratio_err[3:8]
        excess_err2 = yield_ratio_err[10:15]
        ax.errorbar(1, yield_ratio[1], yerr=yield_ratio_err[1], fmt="o", color="black")
        ax.errorbar(2, yield_ratio[2], yerr=yield_ratio_err[2], fmt="o", color="black")
        colors = ["tab:red", "tab:blue", "tab:green"]
        for i in 1:3
            ax.errorbar(3, excess1[2*i-1], yerr=excess_err1[2*i-1], fmt="o", color=colors[i], label=L"%$i $\sigma$")
            ax.errorbar(4, excess1[2*i], yerr=excess_err1[2*i], fmt="o", color=colors[i])
        end
        ax.errorbar(5, yield_ratio[9], yerr=yield_ratio_err[9], fmt="o", color="black")
        
        for i in 1:3
            ax.errorbar(6, excess2[2*i-1], yerr=excess_err2[2*i-1], fmt="o", color=colors[i])
            ax.errorbar(7, excess2[2*i], yerr=excess_err2[2*i], fmt="o", color=colors[i])    
        end
    else
        ax.errorbar(collect(1:length(yield_ratio)), yield_ratio, yerr=yield_ratio_err, fmt="o", color="black")
    end

    if edge == true
        labels = ["Reference", "with f0", "Mass +", "Mass -", "with f0 width", "Mass +", "Mass -"];
        if nsigma == true
            ax.set_xticks(collect(1:length(excess1)+1))
        else
            ax.set_xticks(collect(1:length(yield_ratio)))
        end
        ax.set_xticklabels(labels, rotation=45)
    end

    ax.set_ylabel("pion yield ratio")
   if nsigma == true
        ax.text(0.15 * length(excess1), maximum(yield_ratio) - 0.01, L"$0.1 < p_{\mathrm{T}} < 3.0$ GeV/c")
        ax.set_xlim(0.5, length(excess1)+1.5)
    else
        ax.text(0.15 * length(yield_ratio), maximum(yield_ratio) - 0.01, L"$0.1 < p_{\mathrm{T}} < 3.0$ GeV/c")
        ax.set_xlim(0.5, length(yield_ratio)+0.5)
    end
    mean_excess = mean(yield_ratio)
    std_excess = std(yield_ratio)
    println("Mean relative Excess: $(mean_excess) ± $(std_excess)")
    #ax.text(0.3 * length(yield_ratio), 0.2, "Mean relative Excess: $(round(mean_excess, digits=2)) ± $(round(std_excess, digits=2))")
    ax.tick_params(which="both", direction="in", top=true, right=true)
    ax.legend()
    #ax.set_ylim(0, 0.4)

    if save==true
        fig.savefig(directory*"pion_yield_ratio.png", dpi=400, bbox_inches="tight")
    end
    
end



















##########################################################
#
# Functions to plot unhandled f0 width results. These are not used in the final version, but are kept here for reference and potential future use.
#
##########################################################



 # list 1       -  reference
# list 2       -  stock f0(500) m = 449 MeV
# list 3-8     -  mass edge study +- (1-3sigma)   1+ 1- 2+ 2- 3+ 3-
# list 9-27    -  stock f0(500) m = 449 MeV and width = 550 MeV  (consideration of width via qunatiles 5%, 10% ,15%, ..)
# list 28-141  -  mass edge study +- (1-3sigma)   1+ 1- 2+ 2- 3+ 3-  (with consideration of the width like before)



function plot_width_spectra_difference(results_cuts::ResultsList, data::Data, index; excess::Bool=false, save::Bool=false)

    results_handled = handle_f0_widths(results_cuts)

    fig, ax = subplots(2,1, figsize=(5.1,5), sharex=true, gridspec_kw = Dict("height_ratios"=>[3,1], "hspace"=>0.05))

    sample_length = 19
    starting_point = 9 + sample_length * index
    indices = starting_point:starting_point+sample_length-1
    println(collect(indices))
    alpha = 0.3

    ax[1].plot(data.pt, getindex.((results_cuts.spectra_thermal[1])[:],1), label="Thermal", color="tab:blue", alpha=1.0)
    ax[1].plot(data.pt, getindex.((results_cuts.spectra_total[1])[:],1), label="Total", color="tab:red", alpha=1.0)

    ax[1].plot(data.pt, getindex.((results_handled.spectra_total[9+index])[:],1), label="Mean", color="tab:green", alpha=1.0)

    for (j, i) in enumerate(indices)
        ax[1].plot(data.pt, getindex.((results_cuts.spectra_thermal[i])[:],1), color="tab:blue", alpha=alpha)
        ax[1].plot(data.pt, getindex.((results_cuts.spectra_total[i])[:],1), color="tab:red", alpha=alpha)
        
    end

    ax[1].errorbar(data.pt, data.dNdpt, yerr=(-data.yerrm_stat,data.yerrp_stat), xerr=data.xerrm, fmt=".", label="ALICE Data", color="black")

    ax[1].set_yscale("log")
    #ax[1].set_xlabel(L"$p_{\mathrm{T}}$ [GeV/c]")
    ax[1].set_ylabel(L"$1/(2πp_{\mathrm{T}})$ $dN/dp_{\mathrm{T}}dy$ [1/GeV/c]")
    ax[1].tick_params(which="both", direction="in", top=true, right=true)
    ax[1].legend()
    ax[1].set_ylim(1e-2, 1e4)


    if excess == true
        ax[1].set_ylim(1e2, 2e3)
        ax[1].set_xlim(0.0, 0.5)
        ax[1].text(0.3, 1200, "PbPb @ 2.76 TeV")
        ax[1].text(0.3, 1000, "0-5% centrality")
    else
        ax[1].text(2, 3000, "PbPb @ 2.76 TeV")
        ax[1].text(2, 1500, "0-5% centrality")
    end

    for (j, i) in enumerate(indices)
        diff_spectra_thermal = getindex.((results_cuts.spectra_thermal[i])[:],1) .- getindex.((results_cuts.spectra_thermal[1])[:],1)
        diff_spectra_total   = getindex.((results_cuts.spectra_total[i])[:],1) .- getindex.((results_cuts.spectra_total[1])[:],1)
        diff_spectra_mean   = getindex.((results_handled.spectra_total[9+index])[:],1) .- getindex.((results_cuts.spectra_total[1])[:],1)

        #ax.plot(data.pt, rel_spectra_thermal, color="blue", alpha=alpha)
        ax[2].plot(data.pt, diff_spectra_total, color="tab:red", alpha=alpha)
        ax[2].plot(data.pt, diff_spectra_mean, color="tab:green", alpha=1.0)
        
    end

    ax[2].set_xlabel(L"$p_{\mathrm{T}}$ [GeV/c]")
    ax[2].set_ylabel("difference [1/GeV/c]")
    ax[2].tick_params(which="both", direction="in", top=true, right=true)
    ax[2].set_ylim(-10, 140)
    #ax[2].set_yscale("log")

    if excess == true
        ax[2].set_xlim(0, 0.5)
    end

    if save==true
        if !isdir(directory*"Width_sample/")
            mkdir(directory*"Width_sample/")
        end
        if excess == true
            fig.savefig(directory*"Width_sample/width_sample_pion_diff_spectra_pce_excess_$(index).png", dpi=300)
        else
            fig.savefig(directory*"Width_sample/width_sample_pion_diff_spectra_pce_$(index).png", dpi=300)
        end
    else
        fig.show()
    end

end


