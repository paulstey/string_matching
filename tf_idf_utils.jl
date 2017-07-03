import CategoricalArrays: recode!

"""
    recode!(dat, col, recode_lookup, typ)
This function performs the re-coding specified by the `recode_lookup`
dictionary and modifies the `dat` argument in place. Note that we must
specify the type of the column using the `typ` argument. This should be
the type of recoded values.
"""

function recode!(dat::DataTable, col::Symbol, recode_lookup::Dict, typ::DataType)
    tmp = dat[col]
    n = size(dat, 1)
    dat[col] = NullableArray{typ, 1}(n)
    for i = 1:n
        dat[i, col] = recode_lookup[tmp[i]]
    end
end



"""
    clean_string(x)
Given a single string `x`, this function returns a copy of the string
where all non-alphabetic characters have been replaced with a blank space.
The exception is the hyphen, which is not removed or altered.
"""
function clean_string(x::T) where {T <: AbstractString}
    xlwr = lowercase(x)
    xcln = replace(xlwr, r"[^-a-z]", " ")     # keep only letters and hyphens
    return xcln
end



function cut_stopwords(x_arr, stopwords)
    res = [z for z in x_arr if z ∉ stopwords]
    return res
end


function clean_all_strings(x::NullableArray{T, 1}, stopwords::Array{String, 1}) where {T <: AbstractString}
    n = length(x)
    res = Array{String,1}(n)
    for i = 1:n
        xi_cln = clean_string(x[i].value)
        res[i] = join(cut_stopwords(split(xi_cln), stopwords), " ")
    end
    res
end


function clean_all_strings(x::Array{T, 1}, stopwords::Array{String, 1}) where {T <: AbstractString}
    n = length(x)
    res = Array{String,1}(n)
    for i = 1:n
        xi_cln = clean_string(x[i])
        res[i] = join(cut_stopwords(split(xi_cln), stopwords), " ")
    end
    res
end


function document_frequency(x::NullableArray{String, 1})
    n = length(x)
    res = Dict{String, Int}()
    for i = 1:n
        xi_dict = countmap(split(x[i].value))
        merge!(+, res, xi_dict)
    end
    res
end


function document_frequency(x::Array{String, 1})
    n = length(x)
    res = Dict{String, Int}()
    for i = 1:n
        xi_dict = countmap(split(x[i]))
        merge!(+, res, xi_dict)
    end
    res
end


function tf_idf_datatable(x::AbstractArray, stopwords::Array{String,1})
     x_cln = clean_all_strings(x, stopwords)
     doc_freq = document_frequency(x_cln)
     unq_words = collect(keys(doc_freq))
     sort!(unq_words)

     n = length(x)
     p = length(unq_words)

     word_idx = Dict{String, Int}()
     for j = 1:p
         word_idx[unq_words[j]] = j
     end

     mat = zeros(n, p)
     for i = 1:n
         word_arr = split(x_cln[i])
         for word in word_arr
             j = word_idx[word]
             mat[i, j] = doc_freq[word]
         end
     end
     res = convert(DataTable, mat)
     col_names = map(Symbol, unq_words)
     names!(res, col_names)
     res
 end
