install.packages('RCassandra')

library(RCassandra)


connect.handle <- RC.connect(host="10.10.40.53", port=9160)


RC.cluster.name(connect.handle)

RC.describe.keyspaces(connect.handle)

 CREATE KEYSPACE aug_29 WITH REPLICATION = { 'class' : 'NetworkTopologyStrategy', 'datacenter1' : 2 };

# CREATE TABLE aug_29.table1 ( user_name varchar PRIMARY KEY );

df1 <- as.data.frame("qwe")
colnames(df) <- "user_name"

xx = RC.use(connect.handle, 'rcass')

library(datasets)
head(iris, 3)

iris_df <- as.data.frame(iris)
colnames(iris_df) = c('Sepal_Length', 'Sepal_Width', 'Petal_Length', 'Petal_Width', 'Species')
my_id = as.data.frame('')
my_id = as.data.frame(rownames(iris_df))
colnames(my_id) = 'id'
my_id$id = as.character(my_id$id)

table11 = as.data.frame(cbind(my_id,iris_df))
  
table11$id = as.character(table11$id)
table11$Sepal_Length = as.character(table11$Sepal_Length)
table11$Sepal_Width = as.character(table11$Sepal_Width)
table11$Petal_Length = as.character(table11$Petal_Length)
table11$Petal_Width = as.character(table11$Petal_Width)
table11$Species = as.character(table11$Species)

CREATE TABLE rcass.table11 (id text,Sepal_Length text, Sepal_Width text, Petal_Length text, Petal_Width text, Species text, PRIMARY KEY(id) ) WITH COMPACT STORAGE ;



iris_df$Species
table10_1 = as.data.frame(cbind(my_id$id,iris_df$Petal_Length,iris_df$Petal_Width,iris_df$Sepal_Length,iris_df$Sepal_Width))
table10_1 = cbind(table10_1,iris_df$Species)
colnames(table10_1) = c('id', 'petal_length', 'petal_width', 'sepal_length', 'sepal_width', 'species')
typeof(table10_1$petal_length)
table10_1$sepal_length = as.character(table10_1$sepal_length)
table10_1$sepal_width = as.character(table10_1$sepal_width)
table10_1$petal_length = as.character(table10_1$petal_length)
table10_1$petal_width = as.character(table10_1$petal_width)
table10_1$species = as.character(table10_1$species)
table10_1$id = as.character(table10_1$id)
CREATE TABLE rcass.table10 (id text,Sepal_Length text, Sepal_Width text, Petal_Length text, Petal_Width text, Species text, PRIMARY KEY(id) ) WITH COMPACT STORAGE ;
#################
RC.write.table(connect.handle, "table19", table10_1)

mycars <- as.data.frame(RC.read.table(connect.handle, "table10"))

install.packages('lubridate')

