
ENV["PYTHON"]="home/tim/miniconda3/bin/python"
using PyPlot
using LaTeXStrings

function get_m(marker_list, iteration_idx)
        if iteration_idx % 2 == 0
            return marker_list[2]
        else
            return marker_list[3]
        end 
    end

function plot_excess(loaded_results_QM, loaded_results_PDG, loaded_results_f0)

    # 1 : reference spectrum
    # 2/3 : mass +-1sigma      8/9 : mass +-2sigma          14/15 : mass +-3sigma
    # 4/5 : width +-1sigma     10/11 : width +-2sigma       16/17 : width +-3sigma
    # 6/7 : br +-1sigma        12/13 : br +-2sigma          18/19 : br +-3sigma
    # if QM list 20 is the reference of QM list


    # 1       -  reference
    # 2       -  stock f0(500) m = 449 MeV
    # 3-8     -  mass edge study +- (1-3sigma)   1+ 1- 2+ 2- 3+ 3-
    # 9       -  stock f0(500) m = 449 MeV and width = 550 MeV  (consideration of width via qunatiles 5%, 10% ,15%, ..)
    # 10-15   -  mass edge study +- (1-3sigma)   1+ 1- 2+ 2- 3+ 3-  (with consideration of the width like before)

    excess_err_exp = loaded_results_PDG.rel_excess_err_exp[1]
    excess_err_mod = loaded_results_PDG.rel_excess_err_mod[1]
    println("excess_err_exp = $excess_err_exp")
    println("excess_err_mod = $excess_err_mod")

    excess_PDG = loaded_results_PDG.rel_excess[1]
    excess_QM = loaded_results_QM.rel_excess[20]
    excess_f0 = loaded_results_f0.rel_excess[2]
    excess_f0_width = loaded_results_f0.rel_excess[9]


    fig, ax = subplots(1, 1, figsize=(6, 5))
    colors = ["tab:red", "tab:purple", "tab:green", "tab:blue", "tab:orange"]
    markers = ["o", "^", "v"]

    ax.errorbar(1.1, excess_PDG, yerr=excess_err_exp, fmt="none", color=colors[1], elinewidth=8, label="Experimental Uncertainty")
    ax.errorbar(1.3, excess_PDG, yerr=excess_err_mod, fmt="none", color=colors[1], alpha=0.5, elinewidth=8, label="Model Uncertainty")
    ax.axhline(excess_PDG, color=colors[1], linestyle="dashed")

    mass_idx = [2, 3, 8, 9, 14, 15]
    width_idx = [4, 5, 10, 11, 16, 17]
    br_idx = [6, 7, 12, 13, 18, 19]
    indices = [2, 2, 3, 3, 4, 4]

    for (idx, i) in zip(mass_idx, indices)
        ax.scatter(i, loaded_results_PDG.rel_excess[idx], marker=get_m(markers, idx), color=colors[3], label= idx==2 ? "Upper Mass Edges" : idx==3 ? "Lower Mass Edges" : nothing)
    end

    for (idx, i) in zip(br_idx, indices)
        ax.scatter(i, loaded_results_PDG.rel_excess[idx], marker=get_m(markers, idx), color=colors[4], label= idx==6 ? "Upper BR Edges" : idx==7 ? "Lower BR Edges" : nothing)
    end

    ax.scatter(5, excess_QM, marker=markers[1], color=colors[2])
    ax.axhline(y=excess_QM, xmin=0.356, xmax=0.65, color=colors[2], linestyle="dashed")

    indices = [i+4 for i in indices]

    for (idx, i) in zip(mass_idx, indices)
        ax.scatter(i, loaded_results_QM.rel_excess[idx], marker=get_m(markers, idx), color=colors[3])
    end

    for (idx, i) in zip(br_idx, indices)
        ax.scatter(i, loaded_results_QM.rel_excess[idx], marker=get_m(markers, idx), color=colors[4])
    end

    ax.scatter(9, excess_f0, marker=markers[1], color=colors[5])
    #ax.scatter(9, excess_f0_width, marker=markers[1], color=colors[5])
    ax.axhline(y=excess_f0, xmin=0.7, xmax=1.0, color=colors[5], linestyle="dashed")

    wo_width_idx = [3, 4, 5, 6, 7, 8]
    w_width_idx = [10, 11, 12, 13, 14, 15]
    indices = [i+4 for i in indices]

    for (idx, i) in zip(wo_width_idx, indices)
        ax.scatter(i, loaded_results_f0.rel_excess[idx], marker=get_m(markers, idx+1), color=colors[3])
    end

    # for (idx, i) in zip(w_width_idx, indices)
    #     ax.scatter(i, loaded_results_f0.rel_excess[idx], marker=get_m(markers, idx+1), color=colors[4])
    # end


    labels = ["PDG2016+", L"$\pm1\sigma$", L"$\pm2\sigma$", L"$\pm3\sigma$", "QM2016+", L"$\pm1\sigma$", L"$\pm2\sigma$", L"$\pm3\sigma$", L"$f_0(500)$", L"$\pm1\sigma$", L"$\pm2\sigma$", L"$\pm3\sigma$"]
    ax.set_xticks(collect(1:12))
    ax.set_xticklabels(labels, rotation=45)

    tick_labels = ax.get_xticklabels()
    tick_labels[1].set_color("tab:red")   # PDG2016+
    tick_labels[5].set_color("tab:purple")  # QM2016+
    tick_labels[9].set_color("tab:orange") # f0(500)
    ax.set_xlim(1, 12.5)

    ax.set_ylabel("relative pion excess")
    ax.set_ylim(0, 0.3)
    ax.tick_params(which="both", direction="in", top=true, right=true)

    ax.text(0.05, 0.92, "PbPb @ 2.76 TeV", transform=ax.transAxes)
    ax.text(0.05, 0.88, "0-5% centrality", transform=ax.transAxes)
    #ax.text(0.05, 0.84, L"$\pi^+$ / $\pi^-$ ", transform=ax.transAxes)
    #ax.text(0.05, 0.83, L"$(\pi^+ \oplus \pi^-) / \, 2$ ", transform=ax.transAxes)
    ax.text(0.05, 0.84, L"$\pi^+$", transform=ax.transAxes)
    #ax.text(0.05, 0.80, "PDG2016+", transform=ax.transAxes) 
    ax.legend(loc="upper right", fontsize=10, frameon=true)
    

    directory = "Plots/Paper/"
    fig.savefig(directory * "pion_excess.png", dpi=400, bbox_inches="tight")
    
end








function plot_excess2(loaded_results_QM, loaded_results_PDG, loaded_results_f0)

    # 1 : reference spectrum
    # 2/3 : mass +-1sigma      8/9 : mass +-2sigma          14/15 : mass +-3sigma
    # 4/5 : width +-1sigma     10/11 : width +-2sigma       16/17 : width +-3sigma
    # 6/7 : br +-1sigma        12/13 : br +-2sigma          18/19 : br +-3sigma
    # if QM list 20 is the reference of QM list


    # 1       -  reference
    # 2       -  stock f0(500) m = 449 MeV
    # 3-8     -  mass edge study +- (1-3sigma)   1+ 1- 2+ 2- 3+ 3-
    # 9       -  stock f0(500) m = 449 MeV and width = 550 MeV  (consideration of width via qunatiles 5%, 10% ,15%, ..)
    # 10-15   -  mass edge study +- (1-3sigma)   1+ 1- 2+ 2- 3+ 3-  (with consideration of the width like before)

    excess_err_exp = loaded_results_PDG.rel_excess_err_exp[1]
    excess_err_mod = loaded_results_PDG.rel_excess_err_mod[1]
    println("excess_err_exp = $excess_err_exp")
    println("excess_err_mod = $excess_err_mod")

    excess_PDG = loaded_results_PDG.rel_excess[1]
    excess_QM = loaded_results_QM.rel_excess[20]
    excess_f0 = loaded_results_f0.rel_excess[2]
    excess_f0_width = loaded_results_f0.rel_excess[9]


    fig, ax = subplots(1, 1, figsize=(6, 5))
    colors = ["tab:red", "tab:purple", "tab:green", "tab:blue", "tab:orange"]
    markers = ["o", "^", "v"]

    ax.errorbar(1.1, excess_PDG, yerr=excess_err_exp, fmt="none", color=colors[1], elinewidth=8, label="Experimental Uncertainty")
    ax.errorbar(1.3, excess_PDG, yerr=excess_err_mod, fmt="none", color=colors[1], alpha=0.5, elinewidth=8, label="Model Uncertainty")
    ax.axhline(excess_PDG, color=colors[1], linestyle="dashed")

    mass_idx = [2, 3, 8, 9, 14, 15]
    width_idx = [4, 5, 10, 11, 16, 17]
    br_idx = [6, 7, 12, 13, 18, 19]
    indices = [2, 2, 3, 3, 4, 4]

    for (idx, i) in zip(mass_idx, indices)
        ax.scatter(i, loaded_results_PDG.rel_excess[idx], marker=get_m(markers, idx), color=colors[3], label= idx==2 ? "Upper Mass Edges" : idx==3 ? "Lower Mass Edges" : nothing)
    end

    for (idx, i) in zip(br_idx, indices)
        ax.scatter(i, loaded_results_PDG.rel_excess[idx], marker=get_m(markers, idx), color=colors[4], label= idx==6 ? "Upper BR Edges" : idx==7 ? "Lower BR Edges" : nothing)
    end

    ax.scatter(5, excess_QM, marker=markers[1], color=colors[2])
    # ax.axhline(y=excess_QM, xmin=0.356, xmax=0.65, color=colors[2], linestyle="dashed")

    # indices = [i+4 for i in indices]

    # for (idx, i) in zip(mass_idx, indices)
    #     ax.scatter(i, loaded_results_QM.rel_excess[idx], marker=get_m(markers, idx), color=colors[3])
    # end

    # for (idx, i) in zip(br_idx, indices)
    #     ax.scatter(i, loaded_results_QM.rel_excess[idx], marker=get_m(markers, idx), color=colors[4])
    # end

    ax.scatter(6, excess_f0, marker=markers[1], color=colors[5])
    #ax.scatter(9, excess_f0_width, marker=markers[1], color=colors[5])
    ax.axhline(y=excess_f0, xmin=0.6, xmax=1.0, color=colors[5], linestyle="dashed")

    wo_width_idx = [3, 4, 5, 6, 7, 8]
    w_width_idx = [10, 11, 12, 13, 14, 15]
    indices = [i+5 for i in indices]

    for (idx, i) in zip(wo_width_idx, indices)
        ax.scatter(i, loaded_results_f0.rel_excess[idx], marker=get_m(markers, idx+1), color=colors[3])
    end

    # for (idx, i) in zip(w_width_idx, indices)
    #     ax.scatter(i, loaded_results_f0.rel_excess[idx], marker=get_m(markers, idx+1), color=colors[4])
    # end


    labels = ["PDG2016+", L"$\pm1\sigma$", L"$\pm2\sigma$", L"$\pm3\sigma$", "QM2016+", L"$f_0(500)$", L"$\pm1\sigma$", L"$\pm2\sigma$", L"$\pm3\sigma$"]
    ax.set_xticks(collect(1:9))
    ax.set_xticklabels(labels, rotation=45)

    tick_labels = ax.get_xticklabels()
    tick_labels[1].set_color("tab:red")   # PDG2016+
    tick_labels[5].set_color("tab:purple")  # QM2016+
    tick_labels[6].set_color("tab:orange") # f0(500)
    ax.set_xlim(1, 9.5)

    ax.set_ylabel("relative pion excess")
    ax.set_ylim(0, 0.3)
    ax.tick_params(which="both", direction="in", top=true, right=true)

    ax.text(0.05, 0.92, "PbPb @ 2.76 TeV", transform=ax.transAxes)
    ax.text(0.05, 0.88, "0-5% centrality", transform=ax.transAxes)
    #ax.text(0.05, 0.84, L"$\pi^+$ / $\pi^-$ ", transform=ax.transAxes)
    #ax.text(0.05, 0.83, L"$(\pi^+ \oplus \pi^-) / \, 2$ ", transform=ax.transAxes)
    ax.text(0.05, 0.84, L"$\pi^+$", transform=ax.transAxes)
    #ax.text(0.05, 0.80, "PDG2016+", transform=ax.transAxes) 
    ax.legend(loc="upper right", fontsize=10, frameon=true)
    

    directory = "Plots/Paper/"
    fig.savefig(directory * "pion_excess2.png", dpi=400, bbox_inches="tight")
    
end





function plot_excess3(loaded_results_QM, loaded_results_PDG, loaded_results_f0)

    # 1 : reference spectrum
    # 2/3 : mass +-1sigma      8/9 : mass +-2sigma          14/15 : mass +-3sigma
    # 4/5 : width +-1sigma     10/11 : width +-2sigma       16/17 : width +-3sigma
    # 6/7 : br +-1sigma        12/13 : br +-2sigma          18/19 : br +-3sigma
    # if QM list 20 is the reference of QM list


    # 1       -  reference
    # 2       -  stock f0(500) m = 449 MeV
    # 3-8     -  mass edge study +- (1-3sigma)   1+ 1- 2+ 2- 3+ 3-
    # 9       -  stock f0(500) m = 449 MeV and width = 550 MeV  (consideration of width via qunatiles 5%, 10% ,15%, ..)
    # 10-15   -  mass edge study +- (1-3sigma)   1+ 1- 2+ 2- 3+ 3-  (with consideration of the width like before)

    excess_err_exp = loaded_results_PDG.rel_excess_err_exp[1]
    excess_err_mod = loaded_results_PDG.rel_excess_err_mod[1]
    println("excess_err_exp = $excess_err_exp")
    println("excess_err_mod = $excess_err_mod")

    excess_PDG = loaded_results_PDG.rel_excess[1]
    excess_QM = loaded_results_QM.rel_excess[20]
    excess_f0 = loaded_results_f0.rel_excess[2]
    excess_f0_width = loaded_results_f0.rel_excess[9]


    fig, ax = subplots(1, 1, figsize=(6, 5))
    colors = ["tab:red", "tab:purple", "tab:green", "tab:blue", "tab:orange"]
    markers = ["o", "^", "v"]

    ax.errorbar(1.05, excess_PDG, yerr=excess_err_exp, fmt="none", color=colors[1], elinewidth=8, label="Experimental Uncertainty")
    ax.errorbar(1.15, excess_PDG, yerr=excess_err_mod, fmt="none", color=colors[1], alpha=0.5, elinewidth=8, label="Model Uncertainty")
    ax.axhline(excess_PDG, color=colors[1], linestyle="dashed")

    mass_idx = [14, 15]
    width_idx = [4, 5, 10, 11, 16, 17]
    br_idx = [18, 19]
    indices = [2, 2]

    for (idx, i) in zip(mass_idx, indices)
        ax.scatter(i, loaded_results_PDG.rel_excess[idx], marker=get_m(markers, idx), color=colors[3], label= idx==14 ? "Upper Mass Edges" : idx==15 ? "Lower Mass Edges" : nothing)
    end

    for (idx, i) in zip(br_idx, indices)
        ax.scatter(i, loaded_results_PDG.rel_excess[idx], marker=get_m(markers, idx), color=colors[4], label= idx==18 ? "Upper BR Edges" : idx==19 ? "Lower BR Edges" : nothing)
    end

    ax.scatter(3, excess_QM, marker=markers[1], color=colors[2])
    # ax.axhline(y=excess_QM, xmin=0.356, xmax=0.65, color=colors[2], linestyle="dashed")

    # indices = [i+4 for i in indices]

    # for (idx, i) in zip(mass_idx, indices)
    #     ax.scatter(i, loaded_results_QM.rel_excess[idx], marker=get_m(markers, idx), color=colors[3])
    # end

    # for (idx, i) in zip(br_idx, indices)
    #     ax.scatter(i, loaded_results_QM.rel_excess[idx], marker=get_m(markers, idx), color=colors[4])
    # end

    ax.scatter(4, excess_f0, marker=markers[1], color=colors[5])
    #ax.scatter(9, excess_f0_width, marker=markers[1], color=colors[5])
    ax.axhline(y=excess_f0, xmin=0.66, xmax=1.0, color=colors[5], linestyle="dashed")

    wo_width_idx = [7, 8]
    w_width_idx = [14, 15]
    indices = [i+3 for i in indices]

    for (idx, i) in zip(wo_width_idx, indices)
        ax.scatter(i, loaded_results_f0.rel_excess[idx], marker=get_m(markers, idx+1), color=colors[3])
    end

    # for (idx, i) in zip(w_width_idx, indices)
    #     ax.scatter(i, loaded_results_f0.rel_excess[idx], marker=get_m(markers, idx+1), color=colors[4])
    # end


    labels = ["PDG2016+", L"$\pm3\sigma$", "QM2016+", L"$f_0(500)$", L"$\pm3\sigma$"]
    ax.set_xticks(collect(1:5))
    ax.set_xticklabels(labels, rotation=45)

    tick_labels = ax.get_xticklabels()
    tick_labels[1].set_color("tab:red")   # PDG2016+
    tick_labels[3].set_color("tab:purple")  # QM2016+
    tick_labels[4].set_color("tab:orange") # f0(500)
    ax.set_xlim(1, 5.5)

    ax.set_ylabel("relative pion excess")
    ax.set_ylim(0, 0.3)
    ax.tick_params(which="both", direction="in", top=true, right=true)

    ax.text(0.05, 0.92, "PbPb @ 2.76 TeV", transform=ax.transAxes)
    ax.text(0.05, 0.88, "0-5% centrality", transform=ax.transAxes)
    #ax.text(0.05, 0.84, L"$\pi^+$ / $\pi^-$ ", transform=ax.transAxes)
    #ax.text(0.05, 0.83, L"$(\pi^+ \oplus \pi^-) / \, 2$ ", transform=ax.transAxes)
    ax.text(0.05, 0.84, L"$\pi^+$", transform=ax.transAxes)
    #ax.text(0.05, 0.80, "PDG2016+", transform=ax.transAxes) 
    ax.legend(loc="upper right", fontsize=10, frameon=true)
    

    directory = "Plots/Paper/"
    fig.savefig(directory * "pion_excess3.png", dpi=400, bbox_inches="tight")
    
end





function plot_excess4(loaded_results_QM, loaded_results_PDG, loaded_results_f0)

    # 1 : reference spectrum
    # 2/3 : mass +-1sigma      8/9 : mass +-2sigma          14/15 : mass +-3sigma
    # 4/5 : width +-1sigma     10/11 : width +-2sigma       16/17 : width +-3sigma
    # 6/7 : br +-1sigma        12/13 : br +-2sigma          18/19 : br +-3sigma
    # if QM list 20 is the reference of QM list


    # 1       -  reference
    # 2       -  stock f0(500) m = 449 MeV
    # 3-8     -  mass edge study +- (1-3sigma)   1+ 1- 2+ 2- 3+ 3-
    # 9       -  stock f0(500) m = 449 MeV and width = 550 MeV  (consideration of width via qunatiles 5%, 10% ,15%, ..)
    # 10-15   -  mass edge study +- (1-3sigma)   1+ 1- 2+ 2- 3+ 3-  (with consideration of the width like before)

    excess_err_exp = loaded_results_PDG.rel_excess_err_exp[1]
    excess_err_mod = loaded_results_PDG.rel_excess_err_mod[1]
    println("excess_err_exp = $excess_err_exp")
    println("excess_err_mod = $excess_err_mod")

    excess_PDG = loaded_results_PDG.rel_excess[1]
    excess_QM = loaded_results_QM.rel_excess[20]
    excess_f0 = loaded_results_f0.rel_excess[2]
    excess_f0_width = loaded_results_f0.rel_excess[9]


    fig, ax = subplots(1, 1, figsize=(6, 5))
    colors = ["tab:red", "tab:purple", "tab:green", "tab:blue", "tab:orange"]
    #colors = ["tab:orange", "tab:blue", "tab:purple", "tab:red", "tab:green"]
    markers = ["o", "^", "v"]

    ax.errorbar(1.05, excess_PDG, yerr=excess_err_exp, fmt="none", color=colors[1], elinewidth=8, label="Experimental Uncertainty")
    ax.errorbar(1.15, excess_PDG, yerr=excess_err_mod, fmt="none", color=colors[1], alpha=0.5, elinewidth=8, label="Model Uncertainty")
    ax.axhline(excess_PDG, color=colors[1], linestyle="dashed")

    mass_idx = [14, 15]
    width_idx = [4, 5, 10, 11, 16, 17]
    br_idx = [18, 19]
    indices = [2, 2]

    for (idx, i) in zip(mass_idx, indices)
        ax.scatter(i, loaded_results_PDG.rel_excess[idx], marker=get_m(markers, idx), color=colors[3], label= idx==14 ? "Upper Mass Edges" : idx==15 ? "Lower Mass Edges" : nothing)
    end

    for (idx, i) in zip(br_idx, indices)
        ax.scatter(i, loaded_results_PDG.rel_excess[idx], marker=get_m(markers, idx), color=colors[4], label= idx==18 ? "Upper BR Edges" : idx==19 ? "Lower BR Edges" : nothing)
    end

    ax.scatter(3, excess_QM, marker=markers[1], color=colors[2], zorder=3)
    ax.axhline(y=excess_QM, xmin=0.356, xmax=0.63, color=colors[2], linestyle="dashed")

    indices = [i+2 for i in indices]

    for (idx, i) in zip(mass_idx, indices)
        ax.scatter(i, loaded_results_QM.rel_excess[idx], marker=get_m(markers, idx), color=colors[3])
    end

    for (idx, i) in zip(br_idx, indices)
        ax.scatter(i, loaded_results_QM.rel_excess[idx], marker=get_m(markers, idx), color=colors[4])
    end

    ax.scatter(5, excess_f0, marker=markers[1], color=colors[5])
    #ax.scatter(9, excess_f0_width, marker=markers[1], color=colors[5])
    ax.axhline(y=excess_f0, xmin=0.73, xmax=1.0, color=colors[5], linestyle="dashed")

    wo_width_idx = [7, 8]
    w_width_idx = [14, 15]
    indices = [i+2 for i in indices]

    for (idx, i) in zip(wo_width_idx, indices)
        ax.scatter(i, loaded_results_f0.rel_excess[idx], marker=get_m(markers, idx+1), color=colors[3])
    end

    # for (idx, i) in zip(w_width_idx, indices)
    #     ax.scatter(i, loaded_results_f0.rel_excess[idx], marker=get_m(markers, idx+1), color=colors[4])
    # end



    labels = ["PDG2016+", L"$\pm3\sigma$", "QM2016+", L"$\pm3\sigma$" , L"PDG2016+ & $f_0$", L"$\pm3\sigma$"]
    ax.set_xticks(collect(1:6))
    ax.set_xticklabels(labels, rotation=45)

    tick_labels = ax.get_xticklabels()
    tick_labels[1].set_color(colors[1])   # PDG2016+
    tick_labels[3].set_color(colors[2])  # QM2016+
    tick_labels[5].set_color(colors[5]) # f0(500)
    ax.set_xlim(1, 6.5)

    ax.set_ylabel("relative pion excess")
    ax.set_ylim(0, 0.3)
    ax.tick_params(which="both", direction="in", top=true, right=true)

    ax.text(0.05, 0.92, L"Fluid$\it{u}$m + FastReso", color="grey", transform=ax.transAxes)
    ax.text(0.05, 0.87, "PbPb @ 2.76 TeV", transform=ax.transAxes)
    ax.text(0.05, 0.82, "0-5% centrality", transform=ax.transAxes)
    ax.text(0.05, 0.77, L"$\pi^+$ + $\pi^-$ ", transform=ax.transAxes)
    #ax.text(0.05, 0.83, L"$(\pi^+ \oplus \pi^-) / \, 2$ ", transform=ax.transAxes)
    #ax.text(0.05, 0.84, L"$\pi^+$", transform=ax.transAxes)
    #ax.text(0.05, 0.80, "PDG2016+", transform=ax.transAxes) 
    ax.legend(loc="upper right", fontsize=10, frameon=true)
    

    directory = "Plots/Paper/"
    fig.savefig(directory * "pion_excess4.png", dpi=400, bbox_inches="tight")
    
end







function plot_excess5(loaded_results_QM, loaded_results_PDG, loaded_results_f0)

    # 1 : reference spectrum
    # 2/3 : mass +-1sigma      8/9 : mass +-2sigma          14/15 : mass +-3sigma
    # 4/5 : width +-1sigma     10/11 : width +-2sigma       16/17 : width +-3sigma
    # 6/7 : br +-1sigma        12/13 : br +-2sigma          18/19 : br +-3sigma
    # if QM list 20 is the reference of QM list


    # 1       -  reference
    # 2       -  stock f0(500) m = 449 MeV
    # 3-8     -  mass edge study +- (1-3sigma)   1+ 1- 2+ 2- 3+ 3-
    # 9       -  stock f0(500) m = 449 MeV and width = 550 MeV  (consideration of width via qunatiles 5%, 10% ,15%, ..)
    # 10-15   -  mass edge study +- (1-3sigma)   1+ 1- 2+ 2- 3+ 3-  (with consideration of the width like before)

    excess_err_exp = loaded_results_PDG.rel_excess_err_exp[1]
    excess_err_mod = loaded_results_PDG.rel_excess_err_mod[1]
    println("excess_err_exp = $excess_err_exp")
    println("excess_err_mod = $excess_err_mod")

    excess_PDG = loaded_results_PDG.rel_excess[1]
    excess_QM = loaded_results_QM.rel_excess[20]
    excess_f0 = loaded_results_f0.rel_excess[2]
    excess_f0_width = loaded_results_f0.rel_excess[9]


    fig, ax = subplots(1, 1, figsize=(6, 5))
    colors = ["tab:red", "tab:purple", "tab:green", "tab:blue", "tab:orange"]
    #colors = ["tab:orange", "tab:blue", "tab:purple", "tab:red", "tab:green"]
    markers = ["o", "^", "v"]

    ax.errorbar(1.05, excess_PDG, yerr=excess_err_exp, fmt="none", color=colors[1], elinewidth=8, label="Experimental Uncertainty")
    ax.errorbar(1.15, excess_PDG, yerr=excess_err_mod, fmt="none", color=colors[1], alpha=0.5, elinewidth=8, label="Model Uncertainty")
    ax.axhline(excess_PDG, color=colors[1], linestyle="dashed")

    mass_idx = [14, 15]
    width_idx = [4, 5, 10, 11, 16, 17]
    br_idx = [18, 19]
    indices = [2, 2]

    for (idx, i) in zip(mass_idx, indices)
        ax.scatter(i, loaded_results_PDG.rel_excess[idx], marker=get_m(markers, idx), color=colors[3], label= idx==14 ? "Upper Mass Edges" : idx==15 ? "Lower Mass Edges" : nothing)
    end

    for (idx, i) in zip(br_idx, indices)
        ax.scatter(i, loaded_results_PDG.rel_excess[idx], marker=get_m(markers, idx), color=colors[4], label= idx==18 ? "Upper BR Edges" : idx==19 ? "Lower BR Edges" : nothing)
    end

    ax.scatter(3, excess_QM, marker=markers[1], color=colors[2], zorder=3)
    ax.axhline(y=excess_QM, xmin=0.356, xmax=0.63, color=colors[2], linestyle="dashed")

    indices = [i+2 for i in indices]

    for (idx, i) in zip(mass_idx, indices)
        ax.scatter(i, loaded_results_QM.rel_excess[idx], marker=get_m(markers, idx), color=colors[3])
    end

    for (idx, i) in zip(br_idx, indices)
        ax.scatter(i, loaded_results_QM.rel_excess[idx], marker=get_m(markers, idx), color=colors[4])
    end

    ax.scatter(5, excess_f0, marker=markers[1], color=colors[5])
    #ax.scatter(9, excess_f0_width, marker=markers[1], color=colors[5])
    ax.axhline(y=excess_f0, xmin=0.73, xmax=1.0, color=colors[5], linestyle="dashed")

    wo_width_idx = [7, 8]
    w_width_idx = [14, 15]
    indices = [i+2 for i in indices]

    for (idx, i) in zip(wo_width_idx, indices)
        ax.scatter(i, loaded_results_f0.rel_excess[idx], marker=get_m(markers, idx+1), color=colors[3])
    end

    # for (idx, i) in zip(w_width_idx, indices)
    #     ax.scatter(i, loaded_results_f0.rel_excess[idx], marker=get_m(markers, idx+1), color=colors[4])
    # end



    labels = ["PDG2016+", L"$\pm3\sigma$", "QM2016+", L"$\pm3\sigma$" , L"PDG2016+ & $f_0$", L"$\pm3\sigma$"]
    ax.set_xticks(collect(1:6))
    ax.set_xticklabels(labels, rotation=45)

    tick_labels = ax.get_xticklabels()
    tick_labels[1].set_color(colors[1])   # PDG2016+
    tick_labels[3].set_color(colors[2])  # QM2016+
    tick_labels[5].set_color(colors[5]) # f0(500)
    ax.set_xlim(1, 6.5)

    ax.set_ylabel("relative pion excess")
    ax.set_ylim(0, 0.3)
    ax.tick_params(which="both", direction="in", top=true, right=true)

    ax.text(0.05, 0.92, L"Fluid$\it{u}$m + FastReso", color="grey", transform=ax.transAxes)
    ax.text(0.05, 0.87, "PbPb @ 2.76 TeV", transform=ax.transAxes)
    ax.text(0.05, 0.82, "0-5% centrality", transform=ax.transAxes)
    ax.text(0.05, 0.77, L"$\pi^+$ + $\pi^-$ ", transform=ax.transAxes)
    #ax.text(0.05, 0.83, L"$(\pi^+ \oplus \pi^-) / \, 2$ ", transform=ax.transAxes)
    #ax.text(0.05, 0.84, L"$\pi^+$", transform=ax.transAxes)
    #ax.text(0.05, 0.80, "PDG2016+", transform=ax.transAxes) 
    ax.legend(loc="upper right", fontsize=10, frameon=true)
    

    directory = "Plots/Paper/"
    fig.savefig(directory * "pion_excess4.png", dpi=400, bbox_inches="tight")
    
end