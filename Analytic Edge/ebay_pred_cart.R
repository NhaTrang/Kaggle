# KAGGLE COMPETITION - DEALING WITH THE TEXT DATA

#CART seems to be more towards classification so might not be useful p wise

#Reads the training and test data
eBayTrain = read.csv("eBayiPadTrain.csv", stringsAsFactors=FALSE)
eBayTest = read.csv("eBayiPadTest.csv", stringsAsFactors=FALSE)
train_mod = eBayTrain

#Loads TM,ROCR, rpart
library(tm)
library(ROCR)
library(rpart)
library(caret)
library(e1071)

#Merge the dataset into a single data frame
total = merge(eBayTrain, eBayTest, all.x=TRUE, all.y=TRUE, sort=FALSE)

#Clean up ipad mini retina(might be ipad mini 3) and set all to unknown
train_mod$productline[train_mod$productline == 'iPad mini Retina'] = 'Unknown'
total$productline[total$productline == 'iPad mini Retina'] = 'Unknown'

#Set unknown ipad 5 to unknown
total$productline[total$productline == 'iPad 5'] = 'Unknown'
train_mod$productline[train_mod$productline == 'iPad 5'] = 'Unknown'

#Set nonexistent storage of iPads to unknown
total$storage[total$productline == 'iPad 3' & total$storage == '128'] = 'Unknown'
train_mod$storage[train_mod$productline == 'iPad 3' & train_mod$storage == '128'] = 'Unknown'
total$storage[total$productline == 'iPad Air 2' & total$storage == '32'] = 'Unknown'
train_mod$storage[train_mod$productline == 'iPad Air 2' & train_mod$storage == '32'] = 'Unknown'
total$storage[total$productline == 'iPad mini' & total$storage == '128'] = 'Unknown'
train_mod$storage[train_mod$productline == 'iPad mini' & train_mod$storage == '128'] = 'Unknown'

# Make the damaged column
for(i in 1:length(total$description)){
    total$damaged[i] = 0
    if(grepl('scratch', total$description[i])){total$damaged[i] = 1}
    if(grepl('dent', total$description[i])){total$damaged[i] = 1}
    if(grepl('crack', total$description[i])){total$damaged[i] <- 1}
}

#Avgvalue based on avg of start within productline/model
#Has a lot of noise so might not be good predictor unless it was final price given
total$avgvalue = 0
for(n in 1:3){
    for(i in 0:1){
        total$avgvalue[total$productline == paste('iPad',n) & total$cellular == i & total$storage == '16'] = mean(train_mod$startprice[train_mod$productline == paste('iPad',n) & train_mod$cellular == i & train_mod$storage == '16' & train_mod$sold == 1])    
        total$avgvalue[total$productline == paste('iPad',n) & total$cellular == i & total$storage == '32'] = mean(train_mod$startprice[train_mod$productline == paste('iPad',n) & train_mod$cellular == i & train_mod$storage == '32' & train_mod$sold == 1])    
        total$avgvalue[total$productline == paste('iPad',n) & total$cellular == i & total$storage == '64'] = mean(train_mod$startprice[train_mod$productline == paste('iPad',n) & train_mod$cellular == i & train_mod$storage == '64' & train_mod$sold == 1])    
        total$avgvalue[total$productline == paste('iPad',n) & total$cellular == i & total$storage == 'Unknown'] = mean(train_mod$startprice[train_mod$productline == paste('iPad',n) & train_mod$cellular == i & train_mod$storage == 'Unknown' & train_mod$sold == 1])       
    }    
}

for(n in 1:3){
    total$avgvalue[total$productline == paste('iPad',n) & total$cellular == 'Unknown' & total$storage == '16'] = mean(train_mod$startprice[train_mod$productline == paste('iPad',n) & train_mod$cellular == 'Unknown' & train_mod$storage == '16' & train_mod$sold == 1])    
    total$avgvalue[total$productline == paste('iPad',n) & total$cellular == 'Unknown' & total$storage == '32'] = mean(train_mod$startprice[train_mod$productline == paste('iPad',n) & train_mod$cellular == 'Unknown' & train_mod$storage == '32' & train_mod$sold == 1])    
    total$avgvalue[total$productline == paste('iPad',n) & total$cellular == 'Unknown' & total$storage == '64'] = mean(train_mod$startprice[train_mod$productline == paste('iPad',n) & train_mod$cellular == 'Unknown' & train_mod$storage == '64' & train_mod$sold == 1])    
    total$avgvalue[total$productline == paste('iPad',n) & total$cellular == 'Unknown' & total$storage == 'Unknown'] = mean(train_mod$startprice[train_mod$productline == paste('iPad',n) & train_mod$cellular == 'Unknown' & train_mod$storage == 'Unknown' & train_mod$sold == 1])        
}

for(i in 0:1){
    total$avgvalue[total$productline == 'iPad 4' & total$cellular == i & total$storage == '16'] = mean(train_mod$startprice[train_mod$productline == 'iPad 4' & train_mod$cellular == i & train_mod$storage == '16' & train_mod$sold == 1])    
    total$avgvalue[total$productline == 'iPad 4' & total$cellular == i & total$storage == '32'] = mean(train_mod$startprice[train_mod$productline == 'iPad 4' & train_mod$cellular == i & train_mod$storage == '32' & train_mod$sold == 1])    
    total$avgvalue[total$productline == 'iPad 4' & total$cellular == i & total$storage == '64'] = mean(train_mod$startprice[train_mod$productline == 'iPad 4' & train_mod$cellular == i & train_mod$storage == '64' & train_mod$sold == 1])    
    total$avgvalue[total$productline == 'iPad 4' & total$cellular == i & total$storage == '128'] = mean(train_mod$startprice[train_mod$productline == 'iPad 4' & train_mod$cellular == i & train_mod$storage == '128' & train_mod$sold == 1])    
    total$avgvalue[total$productline == 'iPad 4' & total$cellular == i & total$storage == 'Unknown'] = mean(train_mod$startprice[train_mod$productline == 'iPad 4' & train_mod$cellular == i & train_mod$storage == 'Unknown' & train_mod$sold == 1])       
}

total$avgvalue[total$productline == 'iPad 4' & total$cellular == 'Unknown' & total$storage == '16'] = mean(train_mod$startprice[train_mod$productline == 'iPad 4' & train_mod$cellular == 'Unknown' & train_mod$storage == '16' & train_mod$sold == 1])    
total$avgvalue[total$productline == 'iPad 4' & total$cellular == 'Unknown' & total$storage == '32'] = mean(train_mod$startprice[train_mod$productline == 'iPad 4' & train_mod$cellular == 'Unknown' & train_mod$storage == '32' & train_mod$sold == 1])    
total$avgvalue[total$productline == 'iPad 4' & total$cellular == 'Unknown' & total$storage == '64'] = mean(train_mod$startprice[train_mod$productline == 'iPad 4' & train_mod$cellular == 'Unknown' & train_mod$storage == '64' & train_mod$sold == 1])    
total$avgvalue[total$productline == 'iPad 4' & total$cellular == 'Unknown' & total$storage == '128'] = mean(train_mod$startprice[train_mod$productline == 'iPad 4' & train_mod$cellular == 'Unknown' & train_mod$storage == '128' & train_mod$sold == 1])    
total$avgvalue[total$productline == 'iPad 4' & total$cellular == 'Unknown' & total$storage == 'Unknown'] = mean(train_mod$startprice[train_mod$productline == 'iPad 4' & train_mod$cellular == 'Unknown' & train_mod$storage == 'Unknown' & train_mod$sold == 1])        

for(i in 0:1){
    total$avgvalue[total$productline == 'iPad mini' & total$cellular == i & total$storage == '16'] = mean(train_mod$startprice[train_mod$productline == 'iPad mini' & train_mod$cellular == i & train_mod$storage == '16' & train_mod$sold == 1])    
    total$avgvalue[total$productline == 'iPad mini' & total$cellular == i & total$storage == '32'] = mean(train_mod$startprice[train_mod$productline == 'iPad mini' & train_mod$cellular == i & train_mod$storage == '32' & train_mod$sold == 1])    
    total$avgvalue[total$productline == 'iPad mini' & total$cellular == i & total$storage == '64'] = mean(train_mod$startprice[train_mod$productline == 'iPad mini' & train_mod$cellular == i & train_mod$storage == '64' & train_mod$sold == 1])    
    total$avgvalue[total$productline == 'iPad mini' & total$cellular == i & total$storage == '128'] = mean(train_mod$startprice[train_mod$productline == 'iPad mini' & train_mod$cellular == i & train_mod$storage == '128' & train_mod$sold == 1])    
    total$avgvalue[total$productline == 'iPad mini' & total$cellular == i & total$storage == 'Unknown'] = mean(train_mod$startprice[train_mod$productline == 'iPad mini' & train_mod$cellular == i & train_mod$storage == 'Unknown' & train_mod$sold == 1])       
}

total$avgvalue[total$productline == 'iPad mini' & total$cellular == 'Unknown' & total$storage == '16'] = mean(train_mod$startprice[train_mod$productline == 'iPad mini' & train_mod$cellular == 'Unknown' & train_mod$storage == '16' & train_mod$sold == 1])    
total$avgvalue[total$productline == 'iPad mini' & total$cellular == 'Unknown' & total$storage == '32'] = mean(train_mod$startprice[train_mod$productline == 'iPad mini' & train_mod$cellular == 'Unknown' & train_mod$storage == '32' & train_mod$sold == 1])    
total$avgvalue[total$productline == 'iPad mini' & total$cellular == 'Unknown' & total$storage == '64'] = mean(train_mod$startprice[train_mod$productline == 'iPad mini' & train_mod$cellular == 'Unknown' & train_mod$storage == '64' & train_mod$sold == 1])    
total$avgvalue[total$productline == 'iPad mini' & total$cellular == 'Unknown' & total$storage == '128'] = mean(train_mod$startprice[train_mod$productline == 'iPad mini' & train_mod$cellular == 'Unknown' & train_mod$storage == '128' & train_mod$sold == 1])    
total$avgvalue[total$productline == 'iPad mini' & total$cellular == 'Unknown' & total$storage == 'Unknown'] = mean(train_mod$startprice[train_mod$productline == 'iPad mini' & train_mod$cellular == 'Unknown' & train_mod$storage == 'Unknown' & train_mod$sold == 1])        

for(n in 2:3){
    for(i in 0:1){
        total$avgvalue[total$productline == paste('iPad mini',n) & total$cellular == i & total$storage == '16'] = mean(train_mod$startprice[train_mod$productline == paste('iPad mini',n) & train_mod$cellular == i & train_mod$storage == '16' & train_mod$sold == 1])    
        total$avgvalue[total$productline == paste('iPad mini',n) & total$cellular == i & total$storage == '32'] = mean(train_mod$startprice[train_mod$productline == paste('iPad mini',n) & train_mod$cellular == i & train_mod$storage == '32' & train_mod$sold == 1])    
        total$avgvalue[total$productline == paste('iPad mini',n) & total$cellular == i & total$storage == '64'] = mean(train_mod$startprice[train_mod$productline == paste('iPad mini',n) & train_mod$cellular == i & train_mod$storage == '64' & train_mod$sold == 1])    
        total$avgvalue[total$productline == paste('iPad mini',n) & total$cellular == i & total$storage == '128'] = mean(train_mod$startprice[train_mod$productline == paste('iPad mini',n) & train_mod$cellular == i & train_mod$storage == '128' & train_mod$sold == 1])    
        total$avgvalue[total$productline == paste('iPad mini',n) & total$cellular == i & total$storage == 'Unknown'] = mean(train_mod$startprice[train_mod$productline == paste('iPad mini',n) & train_mod$cellular == i & train_mod$storage == 'Unknown' & train_mod$sold == 1])       
    }    
}

for(n in 2:3){
    total$avgvalue[total$productline == paste('iPad mini',n) & total$cellular == 'Unknown' & total$storage == '16'] = mean(train_mod$startprice[train_mod$productline == paste('iPad mini',n) & train_mod$cellular == 'Unknown' & train_mod$storage == '16' & train_mod$sold == 1])    
    total$avgvalue[total$productline == paste('iPad mini',n) & total$cellular == 'Unknown' & total$storage == '32'] = mean(train_mod$startprice[train_mod$productline == paste('iPad mini',n) & train_mod$cellular == 'Unknown' & train_mod$storage == '32' & train_mod$sold == 1])    
    total$avgvalue[total$productline == paste('iPad mini',n) & total$cellular == 'Unknown' & total$storage == '64'] = mean(train_mod$startprice[train_mod$productline == paste('iPad mini',n) & train_mod$cellular == 'Unknown' & train_mod$storage == '64' & train_mod$sold == 1])    
    total$avgvalue[total$productline == paste('iPad mini',n) & total$cellular == 'Unknown' & total$storage == '128'] = mean(train_mod$startprice[train_mod$productline == paste('iPad mini',n) & train_mod$cellular == 'Unknown' & train_mod$storage == '128' & train_mod$sold == 1])    
    total$avgvalue[total$productline == paste('iPad mini',n) & total$cellular == 'Unknown' & total$storage == 'Unknown'] = mean(train_mod$startprice[train_mod$productline == paste('iPad mini',n) & train_mod$cellular == 'Unknown' & train_mod$storage == 'Unknown' & train_mod$sold == 1])        
}

for(i in 0:1){
    total$avgvalue[total$productline == 'iPad Air' & total$cellular == i & total$storage == '16'] = mean(train_mod$startprice[train_mod$productline == 'iPad Air' & train_mod$cellular == i & train_mod$storage == '16' & train_mod$sold == 1])    
    total$avgvalue[total$productline == 'iPad Air' & total$cellular == i & total$storage == '32'] = mean(train_mod$startprice[train_mod$productline == 'iPad Air' & train_mod$cellular == i & train_mod$storage == '32' & train_mod$sold == 1])    
    total$avgvalue[total$productline == 'iPad Air' & total$cellular == i & total$storage == '64'] = mean(train_mod$startprice[train_mod$productline == 'iPad Air' & train_mod$cellular == i & train_mod$storage == '64' & train_mod$sold == 1])    
    total$avgvalue[total$productline == 'iPad Air' & total$cellular == i & total$storage == '128'] = mean(train_mod$startprice[train_mod$productline == 'iPad Air' & train_mod$cellular == i & train_mod$storage == '128' & train_mod$sold == 1])    
    total$avgvalue[total$productline == 'iPad Air' & total$cellular == i & total$storage == 'Unknown'] = mean(train_mod$startprice[train_mod$productline == 'iPad Air' & train_mod$cellular == i & train_mod$storage == 'Unknown' & train_mod$sold == 1])       
}

total$avgvalue[total$productline == 'iPad Air' & total$cellular == 'Unknown' & total$storage == '16'] = mean(train_mod$startprice[train_mod$productline == 'iPad Air' & train_mod$cellular == 'Unknown' & train_mod$storage == '16' & train_mod$sold == 1])    
total$avgvalue[total$productline == 'iPad Air' & total$cellular == 'Unknown' & total$storage == '32'] = mean(train_mod$startprice[train_mod$productline == 'iPad Air' & train_mod$cellular == 'Unknown' & train_mod$storage == '32' & train_mod$sold == 1])    
total$avgvalue[total$productline == 'iPad Air' & total$cellular == 'Unknown' & total$storage == '64'] = mean(train_mod$startprice[train_mod$productline == 'iPad Air' & train_mod$cellular == 'Unknown' & train_mod$storage == '64' & train_mod$sold == 1])    
total$avgvalue[total$productline == 'iPad Air' & total$cellular == 'Unknown' & total$storage == '128'] = mean(train_mod$startprice[train_mod$productline == 'iPad Air' & train_mod$cellular == 'Unknown' & train_mod$storage == '128' & train_mod$sold == 1])    
total$avgvalue[total$productline == 'iPad Air' & total$cellular == 'Unknown' & total$storage == 'Unknown'] = mean(train_mod$startprice[train_mod$productline == 'iPad Air' & train_mod$cellular == 'Unknown' & train_mod$storage == 'Unknown' & train_mod$sold == 1])        

for(i in 0:1){
    total$avgvalue[total$productline == 'iPad Air 2' & total$cellular == i & total$storage == '16'] = mean(train_mod$startprice[train_mod$productline == 'iPad Air 2' & train_mod$cellular == i & train_mod$storage == '16' & train_mod$sold == 1])    
    total$avgvalue[total$productline == 'iPad Air 2' & total$cellular == i & total$storage == '32'] = mean(train_mod$startprice[train_mod$productline == 'iPad Air 2' & train_mod$cellular == i & train_mod$storage == '32' & train_mod$sold == 1])    
    total$avgvalue[total$productline == 'iPad Air 2' & total$cellular == i & total$storage == '64'] = mean(train_mod$startprice[train_mod$productline == 'iPad Air 2' & train_mod$cellular == i & train_mod$storage == '64' & train_mod$sold == 1])    
    total$avgvalue[total$productline == 'iPad Air 2' & total$cellular == i & total$storage == '128'] = mean(train_mod$startprice[train_mod$productline == 'iPad Air 2' & train_mod$cellular == i & train_mod$storage == '128' & train_mod$sold == 1])    
    total$avgvalue[total$productline == 'iPad Air 2' & total$cellular == i & total$storage == 'Unknown'] = mean(train_mod$startprice[train_mod$productline == 'iPad Air 2' & train_mod$cellular == i & train_mod$storage == 'Unknown' & train_mod$sold == 1])       
}

total$avgvalue[total$productline == 'iPad Air 2' & total$cellular == 'Unknown' & total$storage == '16'] = mean(train_mod$startprice[train_mod$productline == 'iPad Air 2' & train_mod$cellular == 'Unknown' & train_mod$storage == '16' & train_mod$sold == 1])    
total$avgvalue[total$productline == 'iPad Air 2' & total$cellular == 'Unknown' & total$storage == '32'] = mean(train_mod$startprice[train_mod$productline == 'iPad Air 2' & train_mod$cellular == 'Unknown' & train_mod$storage == '32' & train_mod$sold == 1])    
total$avgvalue[total$productline == 'iPad Air 2' & total$cellular == 'Unknown' & total$storage == '64'] = mean(train_mod$startprice[train_mod$productline == 'iPad Air 2' & train_mod$cellular == 'Unknown' & train_mod$storage == '64' & train_mod$sold == 1])    
total$avgvalue[total$productline == 'iPad Air 2' & total$cellular == 'Unknown' & total$storage == '128'] = mean(train_mod$startprice[train_mod$productline == 'iPad Air 2' & train_mod$cellular == 'Unknown' & train_mod$storage == '128' & train_mod$sold == 1])    
total$avgvalue[total$productline == 'iPad Air 2' & total$cellular == 'Unknown' & total$storage == 'Unknown'] = mean(train_mod$startprice[train_mod$productline == 'iPad Air 2' & train_mod$cellular == 'Unknown' & train_mod$storage == 'Unknown' & train_mod$sold == 1])        

for(i in 0:1){
    total$avgvalue[total$productline == 'Unknown' & total$cellular == i & total$storage == '16'] = mean(train_mod$startprice[train_mod$productline == 'Unknown' & train_mod$cellular == i & train_mod$storage == '16' & train_mod$sold == 1])    
    total$avgvalue[total$productline == 'Unknown' & total$cellular == i & total$storage == '32'] = mean(train_mod$startprice[train_mod$productline == 'Unknown' & train_mod$cellular == i & train_mod$storage == '32' & train_mod$sold == 1])    
    total$avgvalue[total$productline == 'Unknown' & total$cellular == i & total$storage == '64'] = mean(train_mod$startprice[train_mod$productline == 'Unknown' & train_mod$cellular == i & train_mod$storage == '64' & train_mod$sold == 1])    
    total$avgvalue[total$productline == 'Unknown' & total$cellular == i & total$storage == '128'] = mean(train_mod$startprice[train_mod$productline == 'Unknown' & train_mod$cellular == i & train_mod$storage == '128' & train_mod$sold == 1])    
    total$avgvalue[total$productline == 'Unknown' & total$cellular == i & total$storage == 'Unknown'] = mean(train_mod$startprice[train_mod$productline == 'Unknown' & train_mod$cellular == i & train_mod$storage == 'Unknown' & train_mod$sold == 1])       
}

total$avgvalue[total$productline == 'Unknown' & total$cellular == 'Unknown' & total$storage == '16'] = mean(train_mod$startprice[train_mod$productline == 'Unknown' & train_mod$cellular == 'Unknown' & train_mod$storage == '16' & train_mod$sold == 1])    
total$avgvalue[total$productline == 'Unknown' & total$cellular == 'Unknown' & total$storage == '32'] = mean(train_mod$startprice[train_mod$productline == 'Unknown' & train_mod$cellular == 'Unknown' & train_mod$storage == '32' & train_mod$sold == 1])    
total$avgvalue[total$productline == 'Unknown' & total$cellular == 'Unknown' & total$storage == '64'] = mean(train_mod$startprice[train_mod$productline == 'Unknown' & train_mod$cellular == 'Unknown' & train_mod$storage == '64' & train_mod$sold == 1])    
total$avgvalue[total$productline == 'Unknown' & total$cellular == 'Unknown' & total$storage == '128'] = mean(train_mod$startprice[train_mod$productline == 'Unknown' & train_mod$cellular == 'Unknown' & train_mod$storage == '128' & train_mod$sold == 1])    
total$avgvalue[total$productline == 'Unknown' & total$cellular == 'Unknown' & total$storage == 'Unknown'] = mean(train_mod$startprice[train_mod$productline == 'Unknown' & train_mod$cellular == 'Unknown' & train_mod$storage == 'Unknown' & train_mod$sold == 1])        

#Split total back into training and testing for corpus
train = head(total,nrow(eBayTrain))
test = tail(total, nrow(eBayTest))

##
## CORPUS CREATION
##

#Create a corpus from the description variable
CorpusDescription = Corpus(VectorSource(c(train$description, test$description)))

#Preprocessing of Corpus based on description
CorpusDescription = tm_map(CorpusDescription, content_transformer(tolower), lazy=TRUE)
CorpusDescription = tm_map(CorpusDescription, PlainTextDocument, lazy=TRUE)
CorpusDescription = tm_map(CorpusDescription, removePunctuation, lazy=TRUE)
CorpusDescription = tm_map(CorpusDescription, removeWords, stopwords("english"), lazy=TRUE)
CorpusDescription = tm_map(CorpusDescription, stemDocument, lazy=TRUE)

#Convert corpus to a DocumentTermMatrix, remove sparse terms, and turn it into a data frame. 
#.95 occurence
dtm = DocumentTermMatrix(CorpusDescription)
sparse = removeSparseTerms(dtm, 0.96)
DescriptionWords = as.data.frame(as.matrix(sparse))

#Ensure variable names are readable for R
colnames(DescriptionWords) = make.names(colnames(DescriptionWords))

#Creates a correlation plot of the word variables
wordCor = cor(DescriptionWords)
corrplot(wordCor)

#Merge datasets together and break again in order to get equal factors
eBay = merge(eBayTest,eBayTrain, all.x = TRUE, all.y = TRUE, sort = FALSE)

eBayTest = head(eBay, nrow(eBayTest))
eBayTrain = tail(eBay, nrow(eBayTrain))

eBayTest$sold = NULL

#Resplit entries back into training and test data sets
DescriptionWordsTrain = head(DescriptionWords, nrow(eBayTrain))
DescriptionWordsTest = tail(DescriptionWords, nrow(eBayTest))

#Add dependent variable to the training set
#Add variables from eBayTrain and wordcount to training/testing sets
DescriptionWordsTrain$sold = eBayTrain$sold

DescriptionWordsTrain$WordCount = eBayTrain$WordCount
DescriptionWordsTest$WordCount = eBayTest$WordCount

DescriptionWordsTrain$biddable = eBayTrain$biddable
DescriptionWordsTest$biddable = eBayTest$biddable

DescriptionWordsTrain$color = eBayTrain$color
DescriptionWordsTest$color = eBayTest$color

DescriptionWordsTrain$storage = eBayTrain$storage
DescriptionWordsTest$storage = eBayTest$storage

DescriptionWordsTrain$carrier = eBayTrain$carrier
DescriptionWordsTest$carrier = eBayTest$carrier

DescriptionWordsTrain$condition = eBayTrain$condition
DescriptionWordsTest$condition = eBayTest$condition

DescriptionWordsTrain$productline = eBayTrain$productline
DescriptionWordsTest$productline = eBayTest$productline

DescriptionWordsTrain$startprice = eBayTrain$startprice
DescriptionWordsTest$startprice = eBayTest$startprice

DescriptionWordsTrain$condition = eBayTrain$condition
DescriptionWordsTest$condition = eBayTest$condition

DescriptionWordsTest$carrier = eBayTest$carrier
DescriptionWordsTrain$carrier = eBayTrain$carrier

DescriptionWordsTest$color = eBayTest$color
DescriptionWordsTrain$color = eBayTrain$color

DescriptionWordsTest$avgvalue = test$color
DescriptionWordsTrain$avgvalue = train$color

DescriptionWordsTest$damaged = test$damaged
DescriptionWordsTrain$damaged = train$damaged


# Split the data
set.seed(50)
spl = sample.split(DescriptionWordsTrain$sold, SplitRatio = 0.6)
SoldTrain = subset(DescriptionWordsTrain, spl==TRUE)
SoldTest = subset(DescriptionWordsTrain, spl==FALSE)

# Define cross-validation experiment
numFolds = trainControl( method = "cv", number = 10 )
cpGrid = expand.grid( .cp = seq(0.01,0.5,0.01)) 

# Perform the cross validation which shows .31 seemed to have lowest r^2
train(sold ~ ., data = DescriptionWordsTrain, method = "rpart", trControl = numFolds, tuneGrid = cpGrid )
train(sold ~ ., data = SoldTrain, method = "rpart", trControl = numFolds, tuneGrid = cpGrid )

#Checks the AUC value, 
testRF = rpart(sold ~ ., data=SoldTrain, method="class", cp=.06)
predicttestRF = predict(testRF, newdata=SoldTest, type="class")

predicttestRF = as.numeric(predicttestRF)
ROCRpred = prediction(predicttestRF, SoldTest$sold)
as.numeric(performance(ROCRpred, "auc")@y.values)

#AUC of .7654651, probably overfitting but eitherway this is for classification

#CART regression model using all of the variables
DescriptCART = rpart(sold ~ ., DescriptionWordsTrain, method="class",cp=.31)

#Predictions on our test set:
PredTest = predict(DescriptCART, newdata=DescriptionWordsTest, type="class")

#Preps file for kaggle submission
MySubmission = data.frame(UniqueID = eBayTest$UniqueID, Probability1 = PredTest)

#Creates csv for kaggle
write.csv(MySubmission, "SubmissionDescriptionCART.csv", row.names=FALSE)

