using Fluidum


struct Results
    spectra_thermal::Vector{Tuple{Float64, Float64}}
    spectra_total::Vector{Tuple{Float64, Float64}}
    multiplicity_thermal::Tuple{Float64, Float64}
    multiplicity_total::Tuple{Float64, Float64}
    multiplicity_thermal_excess::Tuple{Float64, Float64}
    multiplicity_total_excess::Tuple{Float64, Float64}
    multiplicity_thermal_reference::Tuple{Float64, Float64}
    multiplicity_total_reference::Tuple{Float64, Float64}
end


function get_results(freeze_out_results, particle_dictionary, fluid_properties, pt_range::Vector{Float64}; interpolate_3d::Bool = false)

    pT_excess_min = 0.1
    pT_excess_max = 0.5
    pT_min = 0.1      #  is not 0.1 for plot
    pT_max = 3.0
    pT_reference_min = 0.5
    pT_reference_max = 2.0

    spectrum_thermal = spectra_lf(freeze_out_results, particle_dictionary, fluid_properties, pt_range; decays=false, interpolate_3d=interpolate_3d);
    spectrum_total = spectra_lf(freeze_out_results, particle_dictionary, fluid_properties, pt_range; decays=true, interpolate_3d=interpolate_3d);

    mult_thermal = multiplicity_lf(freeze_out_results, particle_dictionary, fluid_properties; decays=false,pt_min=pT_min,pt_max=pT_max, interpolate_3d=interpolate_3d);
    mult_total = multiplicity_lf(freeze_out_results, particle_dictionary, fluid_properties; decays=true,pt_min=pT_min,pt_max=pT_max, interpolate_3d=interpolate_3d);

    mult_thermal_excess = multiplicity_lf(freeze_out_results, particle_dictionary, fluid_properties; decays=false,pt_min=pT_excess_min,pt_max=pT_excess_max, interpolate_3d=interpolate_3d);
    mult_total_excess = multiplicity_lf(freeze_out_results, particle_dictionary, fluid_properties; decays=true,pt_min=pT_excess_min,pt_max=pT_excess_max, interpolate_3d=interpolate_3d);

    mult_thermal_reference = multiplicity_lf(freeze_out_results, particle_dictionary, fluid_properties; decays=false,pt_min=pT_reference_min,pt_max=pT_reference_max, interpolate_3d=interpolate_3d);
    mult_total_reference = multiplicity_lf(freeze_out_results, particle_dictionary, fluid_properties; decays=true,pt_min=pT_reference_min,pt_max=pT_reference_max, interpolate_3d=interpolate_3d);

    return Results(spectrum_thermal, spectrum_total, mult_thermal, mult_total, mult_thermal_excess, mult_total_excess, mult_thermal_reference, mult_total_reference)
end



struct ResultsList
    spectra_thermal::Vector{Vector{Tuple{Float64, Float64}}}
    spectra_total::Vector{Vector{Tuple{Float64, Float64}}}
    multiplicity_thermal::Vector{Tuple{Float64, Float64}}
    multiplicity_total::Vector{Tuple{Float64, Float64}}
    multiplicity_thermal_excess::Vector{Tuple{Float64, Float64}}
    multiplicity_total_excess::Vector{Tuple{Float64, Float64}}
    multiplicity_thermal_reference::Vector{Tuple{Float64, Float64}}
    multiplicity_total_reference::Vector{Tuple{Float64, Float64}}
end



function get_results_list(freeze_out_results, particle_dictionary_list, fluid_properties, pt_range::Vector{Float64}; particle::String = "pion", interpolate_3d::Bool = false)

    if particle == "pion"
        field = :pion
    end

    pT_excess_min = 0.1
    pT_excess_max = 0.5
    pT_min = 0.1
    pT_max = 3.0
    pT_reference_min = 0.5
    pT_reference_max = 2.0
    no_of_lists = length(particle_dictionary_list)

    spectra_thermal = [spectra_lf(freeze_out_results, getfield(particle_dictionary_list[i], field), fluid_properties, pt_range; decays=false, interpolate_3d=interpolate_3d) for i in 1:no_of_lists];
    spectra_total = [spectra_lf(freeze_out_results, getfield(particle_dictionary_list[i], field), fluid_properties, pt_range; decays=true, interpolate_3d=interpolate_3d) for i in 1:no_of_lists];

    mult_thermal = [multiplicity_lf(freeze_out_results, getfield(particle_dictionary_list[i], field), fluid_properties; decays=false,pt_min=pT_min,pt_max=pT_max, interpolate_3d=interpolate_3d) for i in 1:no_of_lists];
    mult_total = [multiplicity_lf(freeze_out_results, getfield(particle_dictionary_list[i], field), fluid_properties; decays=true,pt_min=pT_min,pt_max=pT_max, interpolate_3d=interpolate_3d) for i in 1:no_of_lists];

    mult_thermal_excess = [multiplicity_lf(freeze_out_results, getfield(particle_dictionary_list[i], field), fluid_properties; decays=false,pt_min=pT_excess_min,pt_max=pT_excess_max, interpolate_3d=interpolate_3d) for i in 1:no_of_lists];
    mult_total_excess = [multiplicity_lf(freeze_out_results, getfield(particle_dictionary_list[i], field), fluid_properties; decays=true,pt_min=pT_excess_min,pt_max=pT_excess_max, interpolate_3d=interpolate_3d) for i in 1:no_of_lists];

    mult_thermal_reference = [multiplicity_lf(freeze_out_results, getfield(particle_dictionary_list[i], field), fluid_properties; decays=false,pt_min=pT_reference_min,pt_max=pT_reference_max, interpolate_3d=interpolate_3d) for i in 1:no_of_lists];
    mult_total_reference = [multiplicity_lf(freeze_out_results, getfield(particle_dictionary_list[i], field), fluid_properties; decays=true,pt_min=pT_reference_min,pt_max=pT_reference_max, interpolate_3d=interpolate_3d) for i in 1:no_of_lists];

    return ResultsList(spectra_thermal, spectra_total, mult_thermal, mult_total, mult_thermal_excess, mult_total_excess, mult_thermal_reference, mult_total_reference)
end



function get_results_from_list_helper(results_list::ResultsList, index::Int)
    return Results(
        results_list.spectra_thermal[index],
        results_list.spectra_total[index],
        results_list.multiplicity_thermal[index],
        results_list.multiplicity_total[index],
        results_list.multiplicity_thermal_excess[index],
        results_list.multiplicity_total_excess[index],
        results_list.multiplicity_thermal_reference[index],
        results_list.multiplicity_total_reference[index]
    )
end



##########################################################
#
# Functions to do the f0 width thingy 
#
##########################################################

using Statistics

function mean_spectra(v::Vector{Vector{Tuple{Float64,Float64}}})
    N = length(v)
    M = length(v[1])  # == 2 since spectra are tuples of (value, error)

    out = Vector{Tuple{Float64,Float64}}(undef, M)

    for i in 1:M
        x̄ = mean(v[j][i][1] for j in 1:N)
        ȳ = mean(v[j][i][2] for j in 1:N)
        out[i] = (x̄, ȳ)
    end

    return out
end

function mean_multiplicity(v::Vector{Tuple{Float64,Float64}})
    N = length(v)
    x̄ = mean(v[i][1] for i in 1:N)
    ȳ = mean(v[i][2] for i in 1:N)
    return (x̄, ȳ)
end


function handle_f0_widths(results_org::ResultsList)
    # list 1       -  reference
    # list 2       -  stock f0(500) m = 449 MeV
    # list 3-8     -  mass edge study +- (1-3sigma)   1+ 1- 2+ 2- 3+ 3-
    # list 9-27    -  stock f0(500) m = 449 MeV and width = 550 MeV  (consideration of width via qunatiles 5%, 10% ,15%, ..)
    # list 28-141  -  mass edge study +- (1-3sigma)   1+ 1- 2+ 2- 3+ 3-  (with consideration of the width like before)

    no_of_lists = 19    #  for one width consideration
    skipped_lists = 9     # lists to skip before starting with width considerations 
    starting_idx = [skipped_lists+no_of_lists*(i-1) for i in 1:7]  # starting indices for width considerations
    println("Starting indices for width considerations: ", starting_idx);

    spectra_thermal_mean = results_org.spectra_thermal[1:skipped_lists-1]
    spectra_total_mean = results_org.spectra_total[1:skipped_lists-1]
    multiplicity_thermal_mean = results_org.multiplicity_thermal[1:skipped_lists-1]
    multiplicity_total_mean = results_org.multiplicity_total[1:skipped_lists-1]
    multiplicity_thermal_excess_mean = results_org.multiplicity_thermal_excess[1:skipped_lists-1]
    multiplicity_total_excess_mean = results_org.multiplicity_total_excess[1:skipped_lists-1]
    multiplicity_thermal_reference_mean = results_org.multiplicity_thermal_reference[1:skipped_lists-1]
    multiplicity_total_reference_mean = results_org.multiplicity_total_reference[1:skipped_lists-1]

    println("Handling width considerations. Number of spectra before handling widths: ", length(spectra_thermal_mean));

    for start_idx in starting_idx
        println("Handling width consideration starting at index: ", start_idx);
        println("Calculating mean spectra and multiplicities for lists ", start_idx, " to ", start_idx+no_of_lists-1);
        push!(spectra_thermal_mean, mean_spectra(results_org.spectra_thermal[start_idx:start_idx+no_of_lists-1]))
        push!(spectra_total_mean, mean_spectra(results_org.spectra_total[start_idx:start_idx+no_of_lists-1]))
        push!(multiplicity_thermal_mean, mean_multiplicity(results_org.multiplicity_thermal[start_idx:start_idx+no_of_lists-1]))
        push!(multiplicity_total_mean, mean_multiplicity(results_org.multiplicity_total[start_idx:start_idx+no_of_lists-1]))
        push!(multiplicity_thermal_excess_mean, mean_multiplicity(results_org.multiplicity_thermal_excess[start_idx:start_idx+no_of_lists-1]))
        push!(multiplicity_total_excess_mean, mean_multiplicity(results_org.multiplicity_total_excess[start_idx:start_idx+no_of_lists-1]))
        push!(multiplicity_thermal_reference_mean, mean_multiplicity(results_org.multiplicity_thermal_reference[start_idx:start_idx+no_of_lists-1]))
        push!(multiplicity_total_reference_mean, mean_multiplicity(results_org.multiplicity_total_reference[start_idx:start_idx+no_of_lists-1]))
    end
    
    println("Done handling width considerations. Number of mean spectra calculated: ", length(spectra_thermal_mean) - (skipped_lists-1));
    println("Total number of spectra in the result list: ", length(spectra_thermal_mean));

    return ResultsList(spectra_thermal_mean, spectra_total_mean, multiplicity_thermal_mean, multiplicity_total_mean, multiplicity_thermal_excess_mean, multiplicity_total_excess_mean, multiplicity_thermal_reference_mean, multiplicity_total_reference_mean)
end






##########################################################
#
# Functions to rescale results 
#
##########################################################

REFERENCE_MULT_TOTAL = 296.9204802282646
REFERENCE_MULT_THERMAL = 346.68494311992293

function rescale_result_list(result_list::ResultsList; reference_mult = REFERENCE_MULT_TOTAL)

    len = length(result_list.multiplicity_total)  # how many results are in the list (All cases: default, mass/br edge etc)
    rr_multiplicities = [result_list.multiplicity_total_reference[i][1] for i in 1:len];
    println("Multiplicities in the reference region (0.5 - 2.0 GeV/c): ", rr_multiplicities);
    
    scaling_factors = [reference_mult / rr_mult for rr_mult in rr_multiplicities];
    println("Scaling factors: ", scaling_factors);

    rescaled_mult_total = [scaling_factors[i] .*result_list.multiplicity_total[i] for i in 1:len]
    
    rescaled_mult_total_excess = [scaling_factors[i] .*result_list.multiplicity_total_excess[i] for i in 1:len]

    rescaled_spectra_total_values = [scaling_factors[i] .* [x[1] for x in result_list.spectra_total[i]] for i in 1:len]

    rescaled_spectra_total = [ [(rescaled_spectra_total_values[i][j], result_list.spectra_total[i][j][2]) for j in 1:length(result_list.spectra_total[i])] for i in 1:len]

    return ResultsList(result_list.spectra_thermal, rescaled_spectra_total, result_list.multiplicity_thermal, rescaled_mult_total, result_list.multiplicity_thermal_excess, rescaled_mult_total_excess, result_list.multiplicity_thermal_reference, result_list.multiplicity_total_reference)

end


function rescale_result_list_thermal(result_list::ResultsList; reference_mult = REFERENCE_MULT_THERMAL)

    len = length(result_list.multiplicity_thermal)
    multiplicities_thermal = [result_list.multiplicity_thermal[i][1] for i in 1:len];
    println("Reference thermal multiplicities (0.1 - 3.0 GeV/c): ", multiplicities_thermal);

    scaling_factors_thermal = [reference_mult / mult for mult in multiplicities_thermal];
    println("Scaling factors: ", scaling_factors_thermal);

    rescaled_mult_thermal = [scaling_factors_thermal[i] .*result_list.multiplicity_thermal[i] for i in 1:len]
    rescaled_mult_thermal_excess = [scaling_factors_thermal[i] .*result_list.multiplicity_thermal_excess[i] for i in 1:len]
    rescaled_mult_thermal_reference = [scaling_factors_thermal[i] .*result_list.multiplicity_thermal_reference[i] for i in 1:len]

    rescaled_mult_total = [scaling_factors_thermal[i] .*result_list.multiplicity_total[i] for i in 1:len]
    rescaled_mult_total_excess = [scaling_factors_thermal[i] .*result_list.multiplicity_total_excess[i] for i in 1:len]
    rescaled_mult_total_reference = [scaling_factors_thermal[i] .*result_list.multiplicity_total_reference[i] for i in 1:len]

    rescaled_spectra_thermal_values = [scaling_factors_thermal[i] .* [x[1] for x in result_list.spectra_thermal[i]] for i in 1:len]
    rescaled_spectra_thermal = [ [(rescaled_spectra_thermal_values[i][j], result_list.spectra_thermal[i][j][2]) for j in 1:length(result_list.spectra_thermal[i])] for i in 1:len]

    rescaled_spectra_total_values = [scaling_factors_thermal[i] .* [x[1] for x in result_list.spectra_total[i]] for i in 1:len]
    rescaled_spectra_total = [ [(rescaled_spectra_total_values[i][j], result_list.spectra_total[i][j][2]) for j in 1:length(result_list.spectra_total[i])] for i in 1:len]

    return ResultsList(rescaled_spectra_thermal, rescaled_spectra_total, rescaled_mult_thermal, rescaled_mult_total, rescaled_mult_thermal_excess, rescaled_mult_total_excess, rescaled_mult_thermal_reference, rescaled_mult_total_reference)
    
end

























##########################################################
#
# Functions to calculate excesses
#
##########################################################



# Model uncertaintys for PbPb @ 2.76 TeV ALICE -- for centrality classes 0-5%, 5-10%, 10-20%, 20-30%, 30-40%, taken from Rafet pion excess paper
ALICE_PbPb_276_model_uncertainty = [5, 4, 3, 2.1, 1.5]


function calculate_excess(results::Results, mult_data_excess; model_uncertainties=ALICE_PbPb_276_model_uncertainty)
    mult_excess = results.multiplicity_total_excess[1]
    mult_excess_err = results.multiplicity_total_excess[2]
    model_uncertainty = model_uncertainties[1] # ALICE_PbPb_276_model_uncertainty[1] for 0-5% centrality class

    value = mult_data_excess[1]
    err_stat = mult_data_excess[3]
    err_sys = mult_data_excess[5]

    diff = value - mult_excess
    diff_err_experimental = sqrt(err_stat^2 + err_sys^2)
    diff_err_model = sqrt(model_uncertainty^2 + mult_excess_err^2)

    return diff, diff_err_experimental, diff_err_model
end



function calculate_excess_list(results_list::ResultsList, mult_data_excess)
    no_of_lists = length(results_list.multiplicity_total_excess)
    diffs = zeros(no_of_lists)
    diffs_err_experimental = zeros(no_of_lists)
    diffs_err_model = zeros(no_of_lists)

    for i in 1:no_of_lists
        result = get_results_from_list_helper(results_list, i)
        diff, diff_err_experimental, diff_err_model = calculate_excess(result, mult_data_excess)
        diffs[i] = diff
        diffs_err_experimental[i] = diff_err_experimental
        diffs_err_model[i] = diff_err_model
    end

    return diffs, diffs_err_experimental, diffs_err_model
end








function calculate_rel_excess(results::Results, mult_data, mult_data_excess; model_uncertainties=ALICE_PbPb_276_model_uncertainty)
    mult_excess = results.multiplicity_total_excess[1]
    mult_excess_err = results.multiplicity_total_excess[2]
    model_uncertainty = model_uncertainties[1] # ALICE_PbPb_276_model_uncertainty[1] for 0-5% centrality class

    data_excess = mult_data_excess[1]
    data_excess_err_stat = mult_data_excess[3]
    data_excess_err_sys = mult_data_excess[5]

    data = mult_data[1]
    data_err_stat = mult_data[3]
    data_err_sys = mult_data[5]

    ratio = (data_excess - mult_excess) / data
    ratio_err_experimental = sqrt(data_excess_err_stat^2 + (data_err_stat - data_excess_err_sys)^2) / data
    ratio_err_model = sqrt(model_uncertainty^2 + mult_excess_err^2) / data

    return ratio, ratio_err_experimental, ratio_err_model
end


function calculate_rel_excess_list(results_list::ResultsList, mult_data, mult_data_excess)
    no_of_lists = length(results_list.multiplicity_total_excess)
    ratios = zeros(no_of_lists)
    ratios_err_experimental = zeros(no_of_lists)
    ratios_err_model = zeros(no_of_lists)

    for i in 1:no_of_lists
        result = get_results_from_list_helper(results_list, i)
        ratio, ratio_err_experimental, ratio_err_model = calculate_rel_excess(result, mult_data, mult_data_excess)
        ratios[i] = ratio
        ratios_err_experimental[i] = ratio_err_experimental
        ratios_err_model[i] = ratio_err_model
    end

    return ratios, ratios_err_experimental, ratios_err_model
end



##########################################################
#
# Functions to calc yield ratios
#
##########################################################



function calculate_yield_ratio(results::Results, result_ref::Results)
    mult_excess = results.multiplicity_total[1]
    mult_excess_err = results.multiplicity_total[2]

    mult_excess_ref = result_ref.multiplicity_total[1]
    mult_excess_ref_err = result_ref.multiplicity_total[2]

    ratio = mult_excess / mult_excess_ref
    ratio_err = sqrt((mult_excess_err / mult_excess_ref)^2 + (mult_excess * mult_excess_ref_err / mult_excess_ref^2)^2)

    return ratio, ratio_err
end



function calculate_yield_ratio_list(results_list::ResultsList)
    no_of_lists = length(results_list.multiplicity_total_excess)
    ratios = zeros(no_of_lists)
    ratios_err = zeros(no_of_lists)

    result_ref = get_results_from_list_helper(results_list, 1)  # assuming the first entry is the reference

    for i in 1:no_of_lists
        result = get_results_from_list_helper(results_list, i)
        ratio, ratio_err = calculate_yield_ratio(result, result_ref)
        ratios[i] = ratio
        ratios_err[i] = ratio_err
    end

    return ratios, ratios_err
end



##########################################################
#
# Functions to mean transverse momentum
#
##########################################################



function mean_pt_spectra(spectra::Vector{Tuple{Float64, Float64}}, pT::Vector{Float64}, pT_p::Vector{Float64}, pT_m::Vector{Float64})
    dNdydpT = [s[1] for s in spectra]
    dNdydpT_err = [s[2] for s in spectra]
    pT_widths = pT_p .- pT_m

    numerator = sum(2pi * pT .^2 .* dNdydpT .* pT_widths)
    numerator_err = sum((2pi * pT .^2 .* dNdydpT_err .* pT_widths).^2)^0.5
    denominator = sum(2pi * pT .* dNdydpT .* pT_widths)
    denominator_err = sum((2pi * pT .* dNdydpT_err .* pT_widths).^2)^0.5

    mean_pt = numerator / denominator
    mean_pT_err = sqrt( (numerator_err / denominator)^2 + (numerator * denominator_err / denominator^2)^2 )

    err_2 = 1 ./ denominator .* sqrt(sum(2pi * (pT .- mean_pt).^2 .* dNdydpT_err .* pT_widths).^2)     # correct error propagation for mean pT still to be discussed
    return mean_pt, err_2
end


function mean_pt_spectra_list(spectra_list::Vector{Vector{Tuple{Float64, Float64}}}, pT::Vector{Float64}, pT_p::Vector{Float64}, pT_m::Vector{Float64})
    no_of_lists = length(spectra_list)
    mean_pts = zeros(no_of_lists)
    mean_pt_errs = zeros(no_of_lists)

    for i in 1:no_of_lists
        mean_pt, mean_pt_err = mean_pt_spectra(spectra_list[i], pT, pT_p, pT_m)
        mean_pts[i] = mean_pt
        mean_pt_errs[i] = mean_pt_err
    end

    return mean_pts, mean_pt_errs
    
end