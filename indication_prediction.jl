using DataTables
using CSV
using DecisionTree
# using MLBase


cd("/Users/pstey/projects_code/string_matching/")

include("tf_idf_utils.jl")


dt = CSV.read("AUCAdjudicatedCategories.csv", DataTable)

const STOPWORDS = [
    "the",
    "is",
    "at",
    "which",
    "on",
    "in",
    "for",
    "with"]


# Testing above functions
a = ["this is a string of words", "this is a sentence!", "this is it", "what about this?"]
tf_idf_datatable(a, STOPWORDS)





# Adding and ID column, and then make it the first
# column in the datatable.
dt[:id] = 1:(nrow(dt))
dt = dt[:, [3, 1, 2]]

# Get dataframe with TF/IDF values for each indication
dt_tf_idf = tf_idf_datatable(dt[:Indication], STOPWORDS)



## Fitting Random Forest
# Cast data to numeric arrays
labels = convert(Array{String,1}, dt[:Category])
features = convert(Array, dt_tf_idf)


## Split data into training and test set
function train_test_split(dat, pct_train; seed = rand(Int, 1))
    srand(seed)
    n = size(dat, 1)
    n_train = round(Int, pct_train * n)
    train_indcs = sample(1:n, n_train, replace = false)
    test_indcs = setdiff(1:n, train_indcs)
    return (train_indcs, test_indcs)
end

train, test = train_test_split(dt, 0.80, seed = 137)

labels_trn = labels[train]
labels_tst = labels[test]

features_trn = features[train, :]
features_tst = features[test, :]


# Run n-fold cross validation for forests using `m_try`
# random features, 100 trees, and 5 folds.
m_try = 100#floor(Int, sqrt(size(features_trn, 2)))
nfoldCV_forest(labels_trn, features_trn, m_try, 1000, 5, 0.7)

# Build forest with meta-parameters we like from CV above
fm1 = build_forest(labels_trn, features_trn, m_try, 1000, 10, 0.7)

yhat1 = apply_forest(fm1, features_tst)
fm1_acc = mean(yhat1 .== labels_tst)

cm = confusion_matrix(labels_tst, yhat1)
cm.kappa

## Get measure of model performance
# labmap = labelmap(convert(Array{String,1}, dt[:Category]))
# yhat1_int = labelencode(labmap, convert(Array{String,1}, yhat1))
# labels_int = labelencode(labmap, labels_tst)
