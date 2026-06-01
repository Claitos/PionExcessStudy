using CSV, DataFrames

struct Data
    pt::Vector{Float64}
    ptm::Vector{Float64}
    ptp::Vector{Float64}
    dNdpt::Vector{Float64}
    yerrp_stat::Vector{Float64}
    yerrm_stat::Vector{Float64}
    yerrp_syst::Vector{Float64}
    yerrm_syst::Vector{Float64}
    xerrm::Vector{Float64}
end


function get_data(filename::String, endlines::Int=1)
    df = CSV.File(filename; comment = "#") |> DataFrame
    rename!(df,[:pt,:ptm,:ptp,:dNdpt,:statplus,:statmin,:systplus,:systmin,:systunplus,:systunmin])
    
    pt = parse.(Float64, first(df.pt, endlines))
    ptm = parse.(Float64, first(df.ptm, endlines))
    ptp = parse.(Float64, first(df.ptp, endlines))

    dNdpt = parse.(Float64, first(df.dNdpt, endlines))

    yerrp_stat=parse.(Float64, first(df.statplus, endlines))
    yerrm_stat=parse.(Float64, first(df.statmin, endlines))

    yerrp_syst=parse.(Float64, first(df.systplus, endlines))
    yerrm_syst=parse.(Float64, first(df.systmin, endlines))

    xerrm=pt.-parse.(Float64, first(df.ptm, endlines))

    data_struct = Data(pt, ptm, ptp, dNdpt, yerrp_stat, yerrm_stat, yerrp_syst, yerrm_syst, xerrm)

    return data_struct
end



function calculate_yield(data_struct::Data; excess::Bool=false, verbose::Bool=false)

    pt_diff = data_struct.ptp - data_struct.ptm
    errp_stat = data_struct.yerrp_stat
    errm_stat = data_struct.yerrm_stat
    errp_syst = data_struct.yerrp_syst
    errm_syst = data_struct.yerrm_syst

    pt = data_struct.pt
    dNdpt = data_struct.dNdpt

    if excess
        pt_min_index = 1      # these indices correspond to 0.1 - 0.5 GeV/c for the ALICE pion data @ 2.76 TeV
        pt_max_index = 11
        pt = pt[pt_min_index:pt_max_index]
        dNdpt = dNdpt[pt_min_index:pt_max_index]
        errp_stat = errp_stat[pt_min_index:pt_max_index]
        errm_stat = errm_stat[pt_min_index:pt_max_index]
        errp_syst = errp_syst[pt_min_index:pt_max_index]
        errm_syst = errm_syst[pt_min_index:pt_max_index]
        pt_diff = pt_diff[pt_min_index:pt_max_index]
    end

    yield = sum(2pi * pt .* dNdpt .* pt_diff)
    yield_errm_stat = sum((2pi * pt .* errm_stat .* pt_diff).^2)^0.5
    yield_errp_stat = sum((2pi * pt .* errp_stat .* pt_diff).^2)^0.5
    yield_errm_syst = sum((2pi * pt .* errm_syst .* pt_diff).^2)^0.5
    yield_errp_syst = sum((2pi * pt .* errp_syst .* pt_diff).^2)^0.5

    yield_errp_tot = sqrt(yield_errp_stat^2 + yield_errp_syst^2)
    yield_errm_tot = sqrt(yield_errm_stat^2 + yield_errm_syst^2)
    yield_err_tot = (yield_errm_tot + yield_errp_tot)/2

    if verbose
        print("Yield: $yield", " + $yield_errp_stat (stat) - $yield_errm_stat (stat) + $yield_errp_syst (syst) - $yield_errm_syst (syst)\n")
        print("Yield: $yield ± $yield_err_tot (total) + $yield_errp_tot (total) - $yield_errm_tot (total)\n\n")
    end

    return yield, yield_err_tot, yield_errp_stat, yield_errm_stat, yield_errp_syst, yield_errm_syst
end
