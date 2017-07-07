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


###
# Data Cleaning and Prepartion
###

# Recode a couple of minor errors
recode!(dt, :Category, Dict("Aortic Disease" => "aortic", "hypotension" => "acute"), String)

# Testing our TF/IDF functions
a = ["this is a string of words", "this is a sentence!", "this is it", "what about this?"]
tf_idf_datatable(a, STOPWORDS)



# Adding and ID column, and then make it the first
# column in the datatable.
dt[:id] = 1:(nrow(dt))
dt = dt[:, [3, 1, 2]]

# Get dataframe with TF/IDF values for each indication
dt_tf_idf = tf_idf_datatable(dt[:Indication], STOPWORDS)




###
# Fitting Random Forest
###

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


# Run n-fold cross validation for forests using
# `mtry` random features, 100 trees, and 5 folds.
mtry = 250
ntrees = 1000
kfolds = 5

nfoldCV_forest(labels_trn, features_trn, mtry, ntrees, kfolds, 0.7)

# Build forest with meta-parameters we like from CV above
maxlabels = 5
fm1 = build_forest(labels_trn, features_trn, mtry, ntrees, maxlabels, 0.7)

# Get predicted category
yhat1 = apply_forest(fm1, features_tst)

# Write predictions to file
writecsv("/Users/pstey/Desktop/preds_labels.csv", hcat(yhat1, labels_tst))


# Get measures of model performance
fm1_acc = mean(yhat1 .== labels_tst)
cm1 = confusion_matrix(labels_tst, yhat1)
cm1.kappa
