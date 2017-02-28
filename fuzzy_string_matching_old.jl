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


# This function is used as a first pass through the candidate
# string. In particular, we use it to determine which words
# in the candidate string should be removed because of their
# dissimilarity to all words in the target string.
function should_cutword(targ, cand, thresh)
    n = length(cand)

    if targ[1] != cand[1]
        res = true
    # need perfect match for strings of length ≤ 3
    elseif n ≤ 3
        # should allow distance of 1 on pruning
        res = compare(Levenshtein(), targ, cand) != 1.0
    elseif n ≤ 5
        res = compare(Winkler(Jaro()), targ, cand) ≤ 0.85
    else
        res = compare(DamerauLevenshtein(), targ, cand) ≤ thresh
    end
    return res
end


function clean_string(x)
    xlwr = lowercase(x)
    xcln = replace(xlwr, r"[^-a-z]", " ")
    return xcln
end


function cut_stopwords(x_arr, stopwords)
    res = [z for z in x_arr if z ∉ stopwords]
    return res
end

## Sample use
#cut_stopwords(["this", "is", "it"], ["it", "this"])


# Given two arrays, one with target phrase, the other with
# a candidate phrase, this function iterates through the
# words in the candidate array and drops those flagged by
# should_cutword() as being too dissimilar from any word in
# the target array. Note that a prior version of this function
# actually "handled" spell checking by REPLACING words in
# `cand_arr` with their "matched" word in `targ_arr`.

function exclude_words(targ_arr, cand_arr, thresh)
    kept_words = Array{String,1}(0)

    for x in targ_arr
        for y in cand_arr
            if !should_cutword(x, y, thresh)
                if y ∉ kept_words
                    println("Keeping $y")
                    push!(kept_words, y)    # don't keep duplicates
                end
            end
        end
    end
    return kept_words
end


function prune_candidate(targ, cand, thresh, stopwords)
    # iterate over every word in candidate string and if not
    # close enough to word in target string then is dropped
    targ_cln = clean_string(targ)
    cand_cln = clean_string(cand)
    targ_arr = cut_stopwords(split(targ_cln), stopwords)
    cand_arr = split(cand_cln)
    n = length(cand_arr)

    kept_words = exclude_words(targ_arr, cand_arr, thresh)

    return kept_words
end


# Given two strings, `x` and `y`, and two thresholds, this
# function returns a boolean indicating whether or not the two
# strings are approximates matches. The first threshold argument
# controls the similarity level that we want in the first pass
# where irrelevant words are removed. The second threshold is
# used as the criteria for declaring a match in the final
# pruned strings.


#=function is_string_match(x, y, thresh1)
    y_arr = prune_candidate(x, y, thresh1)
    y_cln = join(y_arr, " ")
    x_cln = clean_string(x)
    res = contains(y_cln, x_cln)
    return res
end
=#

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

## Testing our function
# is_anagram("abc", "bac")

function string_match(targ, cand, thresh)
    n = length(cand)

    if targ[1] != cand[1]               # first letters much match
        res = true
    elseif n ≤ 3
        if is_anagram(targ, cand)       # anagrams w/ less than 4 letters match
            res = true
        else
            res = dist != 1.0
        end
    else
        similarity = compare(DamerauLevenshtein(), targ, cand)
        warn("dist: $similarity")
        res = similarity ≥ thresh
    end
    return res
end



# Improved is_string_match() function to include only checking
# for same length substrings

function is_string_match(x, y, thresh1, stopwords)
    cand_arr = prune_candidate(x, y, thresh1, stopwords) # create new short candidate array of correctly spelled words
    targ_cln = clean_string(x)
    cand_len = length(cand_arr)
    targ_len = length(split(targ_cln," "))

    res = false
    # Loops through the difference in lengths of the two strings to
    # create comparisons that are of the correct length
    len_diff = cand_len - targ_len
    println("length differences is: $len_diff")
    for i in 0:(len_diff)
        cand_cln = join(cand_arr[i+1:i+targ_len], " ")
        print(cand_cln)
        print("| |")
        println(targ_cln)

        if string_match(targ_cln, cand_cln, thresh1) ###*** needed different compare function to make exact match
            println("Matched $cand_cln to $targ_cln")
            # looking for a match in the correct order
            res = true
            break
        end
    end

    return res
end

# testing our functions
target1 = "pericardial effusion"
candidate1 = "Metastatic non-small cell lung cancer.  Dyspnea. No pulsus on exam. Evaluate for perracardial perracardial effusion/interval change, signs of tamponade."

#x = "pericardial effusion"
#y = "Metastatic non-small cell lung cancer.  Dyspnea. No pulsus on exam. Evaluate for perracardial perracardial effusion/interval change, signs of tamponade."
#thresh1 = 0.75

threshold1 = 0.75

is_string_match(target1, candidate1, threshold1, stopwords)

x1 = "left ventricular left ventricular hypertophy"
y1 = "left ventricular fxn"

is_string_match(x1, y1, 0.75, stopwords)
