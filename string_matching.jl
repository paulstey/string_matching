# String matching functions for Aaron
using StringDistances

# Fairly arbitrarily chosen list of stop words
const stopwords = [
    "the",
    "is",
    "at",
    "which",
    "on"
]


function clean_string(x)
    xlwr = lowercase(x)
    xcln = replace(xlwr, r"[^-a-z]", " ")
    return xcln
end


function cut_stopwords(x_arr, stopwords)
    res = [z for z in x_arr if z ∉ stopwords]
    return res
end



function is_anagram(a, b)
    if length(a) ≠ length(b)
        res = false
    else
        a_sorted = sort(collect(a))
        b_sorted = sort(collect(b))
        res = a_sorted == b_sorted
    end
    return res
end


function found_match(x_arr, y_arr)
    len_diff = length(x_arr) - length(y_arr)      # by convention, x_arr will be longer
    len_y = length(y_arr)

    for windowsize = 2:len_y
        for i = 1:(len_y - windowsize)
            x_str = join(x_arr[i:(i + windowsize - 1)], " ")
            for j = 1:

function is_string_match(x, y, thresh, stopwords)
    x_cln = clean_string(x)
    y_cln = clean_string(y)

    x_arr = cut_stopwords(split(x), stopwords)
    y_arr = cut_stopwords(split(y), stopwords)

    len_x = length(x_arr)
    len_y = length(y_arr)
