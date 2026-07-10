
function write_results_to_file(rel_excess, rel_excess_err_exp, rel_excess_err_mod, filename)
    open(filename, "w") do io
        println(io, "Relative Excess Results:")
        println(io, "------------------------")
        println(io, "Relative Excess: ", rel_excess)
        println(io, "Experimental Error: ", rel_excess_err_exp)
        println(io, "Model Error: ", rel_excess_err_mod)
    end
end

function parse_txt_value(value_str::AbstractString)
    value_str = strip(value_str)

    if startswith(value_str, "[") && endswith(value_str, "]")
        inner = strip(value_str[2:end-1])
        isempty(inner) && return Float64[]
        return parse.(Float64, strip.(split(inner, ",")))
    end

    return parse(Float64, value_str)
end

function read_results_from_file(filename::AbstractString)
    isfile(filename) || error("File not found: $(filename)")

    parsed = Dict{Symbol, Any}()
    key_map = Dict(
        "Relative Excess" => :rel_excess,
        "Experimental Error" => :rel_excess_err_exp,
        "Model Error" => :rel_excess_err_mod
    )

    for line in readlines(filename)
        if !occursin(":", line)
            continue
        end

        key_raw, value_raw = split(line, ":"; limit=2)
        key = strip(key_raw)

        if haskey(key_map, key)
            parsed[key_map[key]] = parse_txt_value(value_raw)
        end
    end

    for required_key in values(key_map)
        haskey(parsed, required_key) || error("Missing key $(required_key) in $(filename)")
    end

    return (
        rel_excess = parsed[:rel_excess],
        rel_excess_err_exp = parsed[:rel_excess_err_exp],
        rel_excess_err_mod = parsed[:rel_excess_err_mod]
    )
end