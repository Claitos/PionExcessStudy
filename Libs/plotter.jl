
ENV["PYTHON"]="home/tim/miniconda3/bin/python"
using PyPlot

include("data_lib.jl")
include("results_lib.jl")


function plot_spectra(results::Results, data::Data, mult_data; save=false)

    digits_print = 2;
    fig, ax = subplots(1,1, figsize=(5,5));

    stat_uncertainties = (-data.yerrm_stat, data.yerrp_stat)
    syst_uncertainties = (-data.yerrm_syst, data.yerrp_syst)
    total_uncertainties = (sqrt.(data.yerrm_stat.^2 .+ data.yerrm_syst.^2), sqrt.(data.yerrp_stat.^2 .+ data.yerrp_syst.^2))
    print("Total uncertainties: ", total_uncertainties, "\n")

    ax.errorbar(data.pt, data.dNdpt, yerr=total_uncertainties, xerr=data.xerrm, fmt=".", label="ALICE Data", color="black")
    #ax.plot(data.pt, getindex.(results.spectra_thermal[:],1), label="Thermal Spectrum", color="tab:red")
    ax.plot(data.pt, getindex.(results.spectra_total[:],1), label="PDG list", color="tab:orange")
    
    #ax.text(0.1, 0.2, "dN/dy = $(round(results.multiplicity_total[1], digits=digits_print))", fontsize=10, color="tab:blue")
    #ax.text(0.1, 0.1, "dN/dy = $(round(results.multiplicity_thermal[1], digits=digits_print))", fontsize=10, color="tab:red")
    #ax.text(0.1, 0.4, "dN/dy = $(round(mult_data[1], digits=digits_print)) ± $(round(mult_data[2], digits=digits_print))", fontsize=10, color="black")
    #ax.text(0.1, 0.05, L"($p_{\mathrm{T}}$ = 0.1 - 3.0 GeV/c)", fontsize=10, color="black")
    ax.axvline(0.5, color="gray", linestyle="--", label=L"$0.5 < p_{\mathrm{T}} < 2.0$ GeV/c")
    ax.axvline(2.0, color="gray", linestyle="--")
    ax.text(2.1, 300, "This Work", color="grey")
    ax.text(2.1, 150, "PbPb @ 2.76 TeV")
    ax.text(2.1, 75, "0-5% centrality")
    ax.text(2.1, 38, L"$\pi^+$ + $\pi^-$")
    #ax.set_title("Pion Spectra")
    ax.set_yscale("log")
    ax.set_xlabel(L"$p_{\mathrm{T}} \, $ [GeV/c]")
    ax.set_ylabel(L"$1 / (2\pi p_{\mathrm{T}}) \,\, dN/dp_{\mathrm{T}}dy \, $ [(GeV/c)$^{-2}$]")
    ax.tick_params(which="both", direction="in", top=true, right=true)
    ax.legend()
    ax.set_ylim(1e-2, 1e4)
    ax.set_xlim(0, 3.1)

    if save
        fig.savefig(directory*"spectra_pion_pce.png", dpi=300, bbox_inches="tight")
    end

end


function plot_spectra_with_excess(results::Results, data::Data, excess_data, rel_excess_data; save=false)

    digits_print = 2;
    fig, ax = subplots(1,1, figsize=(6,5));

    stat_uncertainties = (-data.yerrm_stat, data.yerrp_stat)
    syst_uncertainties = (-data.yerrm_syst, data.yerrp_syst)
    total_uncertainties = (sqrt.(data.yerrm_stat.^2 .+ data.yerrm_syst.^2), sqrt.(data.yerrp_stat.^2 .+ data.yerrp_syst.^2))
    print("Total uncertainties: ", total_uncertainties, "\n")

    rounded_excess_data = round.(excess_data, digits=digits_print)
    rounded_rel_excess_data = round.(rel_excess_data .* 100, digits=digits_print)
    print("Excess data: ", rounded_excess_data, "\n")   
    print("Relative excess data: ", rounded_rel_excess_data, "\n")

    ax.plot(data.pt, getindex.(results.spectra_thermal[:],1), label="Thermal Spectrum", color="tab:purple")
    ax.plot(data.pt, getindex.(results.spectra_total[:],1), label="Total Spectrum", color="tab:orange")
    ax.errorbar(data.pt, data.dNdpt, yerr=total_uncertainties, xerr=data.xerrm, fmt=".", label="ALICE Data", color="black")
    ax.text(0.1, 0.05, L"excess [(GeV/c)$^{-1}$]" * " = $(rounded_excess_data[1]) ± $(rounded_excess_data[2]) (exp.) ± $(rounded_excess_data[3]) (mod.)", fontsize=10, color="black")
    ax.text(0.1, 0.02, "rel. excess [%] = $(rounded_rel_excess_data[1]) ± $(rounded_rel_excess_data[2]) (exp.) ± $(rounded_rel_excess_data[3]) (mod.)", fontsize=10, color="black")
    ax.text(2.1, 300, "This Work", color="grey")
    ax.text(2.1, 150, "PbPb @ 2.76 TeV")
    ax.text(2.1, 75, "0-5% centrality")
    ax.text(2.1, 38, L"$\pi^+$ + $\pi^-$")
    #ax.set_title("Pion Spectra")
    ax.set_yscale("log")
    ax.set_xlabel(L"$p_{\mathrm{T}} \, $ [GeV/c]")
    ax.set_ylabel(L"$1 / (2\pi p_{\mathrm{T}}) \,\, dN/dp_{\mathrm{T}}dy \, $ [(GeV/c)$^{-2}$]")
    ax.tick_params(which="both", direction="in", top=true, right=true)
    ax.legend()
    ax.set_ylim(1e-2, 1e4)
    ax.set_xlim(0, 3.1)

    if save
        fig.savefig(directory*"spectra_pion_pce_with_excess.png", dpi=300, bbox_inches="tight")
    end

end



function plot_spectra_colors(results::Results, data, mult_data; save=false)

    digits_print = 2;
    fig, ax = subplots(1,1, figsize=(5,5));

    ax.plot(data, getindex.(results.spectra_thermal[:],1), label="Thermal Spectrum", color="tab:blue")
    ax.plot(data, getindex.(results.spectra_total[:],1), label="Total Spectrum", color="tab:orange")
    # ax.errorbar(data.pt, data.dNdpt, yerr=(-data.yerrm_stat,data.yerrp_stat), xerr=data.xerrm, fmt=".", label="ALICE Data", color="black")
    ax.text(0.1, 0.2, "dN/dy = $(round(results.multiplicity_total[1], digits=digits_print))", fontsize=10, color="tab:orange")
    ax.text(0.1, 0.1, "dN/dy = $(round(results.multiplicity_thermal[1], digits=digits_print))", fontsize=10, color="tab:blue")
    # ax.text(0.1, 0.4, "dN/dy = $(round(mult_data[1], digits=digits_print)) ± $(round(mult_data[2], digits=digits_print))", fontsize=10, color="black")
    # ax.text(0.1, 0.05, L"($p_{\mathrm{T}}$ = 0.1 - 3.0 GeV/c)", fontsize=10, color="black")
    #ax.axvline(0.5, color="gray", linestyle="--", label=L"$0.5 < p_{\mathrm{T}} < 2.0$ GeV/c")
    #ax.axvline(2.0, color="gray", linestyle="--")
    ax.text(2.1, 300, "This Work", color="grey")
    ax.text(2.1, 150, "PbPb @ 2.76 TeV")
    ax.text(2.1, 75, "0-5% centrality")
    ax.text(2.1, 38, L"$\pi^+$ + $\pi^-$")
    # ax.set_title("Pion momentum spectra")
    ax.set_yscale("log")
    ax.set_xlabel(L"$p_{\mathrm{T}} \, $ [GeV/c]")
    ax.set_ylabel(L"$1 / (2\pi p_{\mathrm{T}}) \,\, dN/dp_{\mathrm{T}}dy \, $ [(GeV/c)$^{-2}$]")
    ax.tick_params(which="both", direction="in", top=true, right=true)
    ax.legend()
    ax.set_ylim(1e-2, 1e4)
    ax.set_xlim(0, 3.1)

    if save
        fig.savefig(directory*"spectra_pion_pce_colors.png", dpi=300, bbox_inches="tight")
    end

end


function plot_ratio(results::Results, data::Data; save = false)

    

    ratio = data.dNdpt ./ (getindex.(results.spectra_total[:],1))
    yerrp_ratio = (data.yerrp_stat.^2 .+ data.yerrp_syst.^2).^0.5 ./ (getindex.(results.spectra_total[:],1))
    yerrm_ratio = (data.yerrm_stat.^2 .+ data.yerrm_syst.^2).^0.5 ./ (getindex.(results.spectra_total[:],1))
    fig, ax = subplots(1,1, figsize=(7,5));
    ax.plot(data.pt, ratio, label="Data / Total Spectrum", color="green")
    #ax.plot(pt, ratio .+ yerrp_ratio, linestyle="--", color="green", label="Data + Total. Uncertainty")
    #ax.plot(pt, ratio .- yerrm_ratio, linestyle="--", color="green", label="Data - Total. Uncertainty")
    ax.fill_between(data.pt, (ratio .+ yerrp_ratio), (ratio .- yerrm_ratio), color="green", alpha=0.2)
    ax.plot(data.pt,[1 for i in data.pt], linestyle="--", color="black", label="Unity")
    ax.set_xlabel("pT [GeV/c]")
    ax.set_ylim(0.2, 2.5)
    ax.set_ylabel("Ratio")
    ax.set_title("Ratio of Data to Total Spectrum")
    ax.tick_params(which="both", direction="in", top=true, right=true)
    ax.legend()

    if save
        fig.savefig(directory*"ratio_pion_spectra_pce.png", dpi=300, bbox_inches="tight")
    end


end




function plot_fo_surface(fo::FreezeOutResult{A,B};save=false) where {A<:SplineInterp,B<:SplineInterp}
    #x = [discretization.grid[i][1] for i in 2:lastindex(discretization.grid)-1]
    #rc("keymap.quit")
    fig, ax = subplots(1,1, figsize=(5,5))

    tau = [fo.x.a[i][1] for i in 1:100]
    radius = [fo.x.a[i][2] for i in 1:100]
    T = [fo.fields.a[i][1] for i in 1:100]
    
    ax.plot(radius, tau, linewidth=2.0, linestyle="-", "#0C7BDC",label=string(L"\mathrm{T =}", round(T[1];digits=3)*1000, " MeV"))
    ax.set_xlabel(L"\mathrm{r \ [fm]}")
    ax.set_ylabel(L"$\tau \ \mathrm{[fm]}$" )
    ax.legend()
    ax.tick_params(top=true, right=true, direction="in")
    ax.set_title(L"\mathrm{Freeze \ out \ surface}")

    fig.show()

    if save==true
        fig.savefig("Plots/fo_surface.png",bbox_inches="tight")
    end
end



function plot_result_fields(fields, radius, times, fluidproperties; save=false)
    fig, axs = subplots(2,3,figsize=(20,12))
    
    fmGeV = 1/0.197326978; # fm/GeV

    entropy = [pressure_derivative.(fields(time)[1,2:end-1],Ref(Val(1)),Ref(fluidproperties))*fmGeV for time in times]
    results1 = [fields(time)[1,2:end-1] for time in times]
    results2 = [fields(time)[2,2:end-1] for time in times]
    results3 = [fields(time)[3,2:end-1] for time in times]
    results4 = [fields(time)[4,2:end-1] for time in times]
    results5 = [fields(time)[5,2:end-1] for time in times]

    for i in eachindex(times)
        axs[1].plot(radius[2:end-1], results1[i], label=L"$\tau$ = "*string(times[i])*" fm/c")
        axs[2].plot(radius[2:end-1], results2[i], label=L"$\tau$ = "*string(times[i])*" fm/c")
        axs[3].plot(radius[2:end-1], results3[i]./entropy[i], label=L"$\tau$ = "*string(times[i])*" fm/c")
        axs[4].plot(radius[2:end-1], results4[i]./entropy[i], label=L"$\tau$ = "*string(times[i])*" fm/c")
        axs[5].plot(radius[2:end-1], results5[i]./entropy[i], label=L"$\tau$ = "*string(times[i])*" fm/c")
        axs[6].plot(radius[2:end-1], entropy[i], label=L"$\tau$ = "*string(times[i])*" fm/c")
    end

    for i in 1:6
        axs[i].set_xlabel("r [fm]")
        axs[i].set_yscale("linear")
        axs[i].tick_params(top=true, right=true, direction="in")
        axs[i].legend()
    end

    axs[1].set_ylabel("Temperature [GeV]")
    axs[2].set_ylabel("Velocity [c]")
    axs[3].set_ylabel("Shear [GeV/fm^3]")
    axs[4].set_ylabel("Shear [GeV/fm^3]")
    axs[5].set_ylabel("Bulk [GeV/fm^3]")
    axs[6].set_ylabel("Entropy density [GeV/fm^3]")

    fig.show()
    
    if save==true
        fig.savefig("Plots/result_fields.png", dpi=400, bbox_inches="tight")
    end

end


function plot_initial_field(fields; save=false, path="Plots/initial_field.png")

    phi = fields.initial_field
    discretization = fields.discretization

    x = [discretization.grid[i][1] for i in 2:lastindex(discretization.grid)-1]
    #rc("keymap.quit")
    fig, ax = subplots(1,1, figsize=(5,5))

    ax.plot(x, phi[1,eachindex(x)])

    ax.set_ylabel(L"$\mathrm{T \ [GeV]}$")
    ax.set_xlabel(L"\mathrm{r \ [fm]}")
    ax.tick_params(top=true, right=true, direction="in")

    fig.show()
    
    if save==true
        fig.savefig(path,bbox_inches="tight")
    end
    
end

