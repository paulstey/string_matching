# String matching functions for Aaron
using StringDistances

# Fairly arbitrarily chosen list of stop words
const stopwords = [
    "the",
    "is",
    "at",
    "which",
    "on",
    "in",
    "for",
    "with"
]


function clean_string(x)
    xlwr = lowercase(x)
    xcln = replace(xlwr, r"[^-a-z]", " ")     # keep only letters
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


# Given two strings, this function returns a boolean indicating
# whether or not the first letters of all words in the phrases
# are the same.
function same_first_letters(x, y)
    x_arr = split(x)
    y_arr = split(y)
    n_words = length(x_arr)
    res = true
    if n_words ≠ length(y_arr)
        error("Attempted to compare phrases with differing number of words")
    else
        for i = 1:n_words
            if first(x_arr[i]) ≠ first(y_arr[i])
                res = false
                break
            end
        end
    end
    return res
end

## testing
same_first_letters("this is a phrase", "this is also phrase")
same_first_letters("this is a phrase", "this also phrase")



# This function uses moving window to compare words
# combination from two strings (strings are arrays of words).
function found_match(x_arr, y_arr, thresh)
    len_diff = length(x_arr) - length(y_arr)      # by convention, x_arr will be longer
    len_y = length(y_arr)
    len_x = length(x_arr)

    for windowsize = 2:len_y
        for i = 1:(len_y - windowsize + 1)
            y_str = join(y_arr[i:(i + windowsize - 1)], " ")
            n_char = length(y_str)

            for j = 1:(len_x - windowsize + 1)
                x_str = join(x_arr[j:(j + windowsize - 1)], " ")

                if !same_first_letters(x_str, y_str)
                    continue
                end

                println("Comparing: \'$y_str\' and \'$x_str\'")
                similarity = compare(DamerauLevenshtein(), y_str, x_str)

                if n_char ≤ 8 && similarity ≥ thresh
                    println("Matched \'$y_str\' and \'$x_str\'")
                    return true
                elseif n_char ≤ 12 && similarity ≥ thresh - 0.05
                    println("Matched \'$y_str\' and \'$x_str\' with similarity $similarity")
                    return true
                elseif n_char ≤ 18 && similarity ≥ thresh - 0.1
                    println("Matched \'$y_str\' and \'$x_str\' with similarity $similarity")
                    return true
                elseif similarity ≥ thresh - 0.15
                    println("Matched \'$y_str\' and \'$x_str\' with similarity $similarity")
                    return true
                end
            end
        end
    end
    return false
end


function is_string_match(x, y, thresh, stopwords)
    x_cln = clean_string(x)
    y_cln = clean_string(y)

    x_arr = cut_stopwords(split(x_cln), stopwords)
    y_arr = cut_stopwords(split(y_cln), stopwords)

    len_x = length(x_arr)
    len_y = length(y_arr)

    if len_x > len_y
        res = found_match(x_arr, y_arr, thresh)
    else
        # switching position of x and y
        res = found_match(y_arr, x_arr, thresh)
    end
    return res
end


# testing our functions
target1 = "pericardial effusion"
candidate1 = "Metastatic non-small cell lung cancer.  Dyspnea. No pulsus on exam. Evaluate for perracardial perracardial effusion/interval change, signs of tamponade."

threshold1 = 0.75

is_string_match(target1, candidate1, threshold1, stopwords)
is_string_match(candidate1, target1, threshold1, stopwords)


x1 = "left ventricular left ventricular hypertophy"
y1 = "left ventricular fxn"

is_string_match(x1, y1, 0.95, stopwords)
is_string_match(y1, x1, 0.95, stopwords)
