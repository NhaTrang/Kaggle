#Kaggle Competition - What's Cooking
#Predict category of cuisine based on ingredients

#Init libraries
library(jsonlite) #Read json
library(tm) #Parse ingredients and get corpus

#Read input
test = fromJSON("test.json", flatten=TRUE)
train = fromJSON("train.json", flatten=TRUE)

#Preprocesses the data
preProcess = function(df){
    df$ingredients = lapply(df$ingredients, FUN=function(x) gsub("-", "_", x)) # Subs - with _
    df$ingredients = lapply(df$ingredients, FUN=function(x) gsub("[^a-z0-9_ ]", "", x)) # Allow regular character and spaces    
    return(df)
}

test = preProcess(test)
train = preProcess(train)

# Create a corpus of terms for train and test
##May want to look into ingredients with spaces or ' in them
ingred_corpus = c(Corpus(VectorSource(train$ingredients)), Corpus(VectorSource(test$ingredients)))

# Create document term matrix
##Maybe do preprocessing on documenttermmatrix
ingred_DTM = DocumentTermMatrix(ingred_corpus)
ingred_DTM = removeSparseTerms(ingred_DTM, 0.995) # 99.5% occurence only
ingred_DTM = as.data.frame(as.matrix(ingred_DTM))

# Features
##Add number of ingredients / recipe
ingred_DTM$num_ingred  = rowSums(ingred_DTM)

# Splits the document matrix back into train/test
word_train  = ingred_DTM[1:nrow(train), ]
word_test = ingred_DTM[-(1:nrow(train)), ]

#Add back dependent variable
word_train$cusine = train$cuisine

#Write to csv
submission = data.frame(test$id)
names(submission) = 'id'
#submission$cusine = predModel
write.csv(submission,filename="submission.csv",row.names=FALSE)