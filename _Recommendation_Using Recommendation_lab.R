# Load required library
library(recommenderlab) # package being evaluated
library(ggplot2) # For plots

# Load the data we are going to work with
data(MovieLense)
MovieLense
# 943 x 1664 rating matrix of class ‘realRatingMatrix’ with 99392 ratings.

#use only ratings with more than 100 ratings
MovieLense100=MovieLense[rowCounts(MovieLense)>100,]
train=MovieLense100[1:50]

#Learn UBCF
rec=Recommender(train,method="UBCF")
rec

Create top N recommendations for new users(users 101 and users 102)
pre=predict(rec,MovieLense100[101:102],n=10)
pre

as(pre,"list")
# Visualizing a sample of this
image(sample(MovieLense, 943), main = "Raw ratings")


# Visualizing ratings
qplot(getRatings(MovieLense), binwidth = 1, 
      main = "Histogram of ratings", xlab = "Rating")
summary(getRatings(MovieLense)) # Skewed to the right
# Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
# 1.00    3.00    4.00    3.53    4.00    5.00
recommenderRegistry$get_entries(dataType = "realRatingMatrix")
recommenderRegistry$get_entry_names()
# We have a few options

# Let's check some algorithms against each other
scheme <- evaluationScheme(MovieLense, method = "split", train = .9,
                           k = 1, given = -5, goodRating = 4)

scheme

algorithms <- list(
  "random items" = list(name="RANDOM", param=list(normalize = "Z-score")),
  "popular items" = list(name="POPULAR", param=list(normalize = "Z-score")),
  "user-based CF" = list(name="UBCF", param=list(normalize = "Z-score",
                                                 method="Cosine",
                                                 nn=50, minRating=3)),
  "item-based CF" = list(name="IBCF", param=list(k=50
  )),
  
  SVD = list(name = "SVD", param=list(normalize = "Z-score")),
  "ALS_explicit" = list(name="ALS", 
                        param = list(normalize=NULL, lambda=0.1, n_factors=200, 
                                     n_iterations=10, seed = 1234, verbose = TRUE)),
  "ALS_implicit" = list(name="ALS_implicit", 
                        param = list(lambda=0.1, alpha = 0.5, n_factors=10, 
                                     n_iterations=10, seed = 1234, verbose = TRUE))
  
)

# run algorithms, predict next n movies
results <- evaluate(scheme, algorithms, n=c(1, 3, 5, 10, 15, 20))

# Draw ROC curve
plot(results, annotate = 1:4, legend="topleft")

# See precision / recall
plot(results, "prec/rec", annotate=3)