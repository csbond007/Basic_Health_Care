
import CassandraMap._

//// Basic Spark Library
import org.apache.spark.SparkContext
import org.apache.spark.SparkContext._
import org.apache.spark.SparkConf
import org.apache.spark.rdd.RDD

//// Spark-Cassandra Connector Library
import com.datastax.spark.connector._

//// Spark-SQL Library
import org.apache.spark.sql.SQLContext
import org.apache.spark.sql.functions._
import org.apache.spark.sql.Row
import org.apache.spark.sql.functions.udf

//// MLLib (Spark Machine Learning Libraries)
import org.apache.spark.mllib.tree.DecisionTree
import org.apache.spark.mllib.tree.model.DecisionTreeModel
import org.apache.spark.mllib.util.MLUtils
import org.apache.spark.mllib.linalg.{Vector, Vectors}
import org.apache.spark.mllib.regression.LabeledPoint

object Main {
	def main(args: Array[String]) {

		/**
    val obj = new CassandraMap
    val css = obj.map_cassandra("10.10.40.138", "iris")

    val qry = "SELECT * FROM data"
    val df = obj.run_sql(css,qry)
   // println(df.show())
		 **/

		val conf = new SparkConf(true)
				.set("spark.cassandra.connection.host", "10.10.40.138")
				.setAppName(this.getClass.getSimpleName)
				.setMaster("spark://10.10.40.138:7077")
				// .setMaster("mesos://zk://10.10.40.138:2181/mesos")

				val sc =  new SparkContext(conf)

				// Spark-SQL Context
				val sqlCtx = new SQLContext(sc)

				val df = sqlCtx.read
				.format("org.apache.spark.sql.cassandra")
				.options(Map( "table" -> "data", "keyspace" -> "iris"))
				.load()


				//stateRegion($"state")

				// df.withColumn("flower", encodeLabel($"flower")).show()

				def encodeLabel=udf((flower: String) => {
					flower match {
					case "Iris_setosa" => 0.0
					case "Iris_versicolor" => 1.0
					case "Iris_virginica" => 2.0
					case _ => 0.0
					}})

				def toVec4 =udf((sepal_length: Double, sepal_width: Double,petal_length: Double,petal_width: Double) => {
					Vectors.dense(sepal_length, sepal_width, petal_length,petal_width)
				})

				val df_mod = df.withColumn(
						"features",
						toVec4(
								df("sepal_length"),
								df("sepal_width"),
								df("petal_length"),
								df("petal_width")
								)
						).withColumn("label", encodeLabel(df("flower"))).select("features", "label")

						df_mod.show()
        /**
				val splits = df_mod.randomSplit(Array(0.3, 0.7))

				val (training_split, test_split) = (splits(0), splits(1))

				val trainingData = training_split.rdd.map(row => LabeledPoint(
						row.getAs[Double]("label"),
						row.getAs[org.apache.spark.mllib.linalg.Vector]("features")
						))

				println("+++++++++++++++++++++++++++++++++++++++++++++++++++++" + trainingData.count())	

				val testData = test_split.rdd.map(row => LabeledPoint(
						row.getAs[Double]("label"),
						row.getAs[org.apache.spark.mllib.linalg.Vector]("features")
						))



				trainingData.cache()
				testData.cache()

				// Train a DecisionTree model.
				//  Empty categoricalFeaturesInfo indicates all features are continuous.
				val numClasses = 3
				val categoricalFeaturesInfo = Map[Int, Int]()
				val impurity = "gini"
				val maxDepth = 5
				val maxBins = 12


				val model = DecisionTree.trainClassifier(trainingData, numClasses, categoricalFeaturesInfo,
						impurity, maxDepth, maxBins)

				val labelAndPreds = testData.map { point =>
				val prediction = model.predict(point.features)
				(point.label, prediction)
		}

		val testErr = labelAndPreds.filter(r => r._1 != r._2).count().toDouble / testData.count()
				println("Test Error //////////////////////////////////////////////= " + testErr)
				println("Learned classification tree model/////////////////////////:\n" + model.toDebugString)

				*/
				/**
     val conf = new SparkConf(true)
    .set("spark.cassandra.connection.host", "10.10.40.138")
     .setAppName(this.getClass.getSimpleName)
     .setMaster("mesos://zk://10.10.40.138:2181/mesos")

     val sc =  new SparkContext(conf)

    // Spark-SQL Context
    val sqlCtx = new SQLContext(sc)
				 **/
				/**
 // Checking whether Cluster is distributing work properly or not
 // val NUM_SAMPLES = 1000000
 // val count = sc.parallelize(1 to NUM_SAMPLES).map{i =>
 //   val x = Math.random()
 //   val y = Math.random()
 //   if (x*x + y*y < 1) 1 else 0
 //   }.reduce(_ + _)
 // println("///////////////////// Pi is roughly " + 4.0 * count / NUM_SAMPLES)
				 */

				/** Possible HACKs to manipulate data
        val rdd = sc.parallelize(Array(
    					(1, List(1.0,3.0,8.0)),
				        (2, List(3.0, 3.0,8.0)),
				        (1, List(2.0,3.0,7.0)),
				        (1, List(5.0,5.0,9.0))))

	 val new_rdd = rdd.map { case (k, vs) =>
	 LabeledPoint(k.toDouble, Vectors.dense(vs.toArray))
	}
				 */

				// Non-DataFrame Approach

				/**

   val iris_data_rdd = sc.cassandraTable("iris", "data")


  def matchTest(x:String) : Double = x match {
    case "Iris-setosa" => 0.0
    case "Iris-versicolor" => 1.0
    case "Iris-virginica" => 2.0
    }

  val splits = iris_data_rdd.randomSplit(Array(0.7, 0.3))
  val (training_split, test_split) = (splits(0), splits(1))

  var training_points  = List[LabeledPoint]()
  var testing_points =  List[LabeledPoint]()

   var j =0
   var count = 0

   for( j <- training_split.toArray)
   {
    val flower_name = j.getString("flower")
    val label = matchTest(flower_name)

    val sepal_length = j.getDouble("sepal_length")
    val sepal_width = j.getDouble("sepal_width")
    val petal_length = j.getDouble("petal_length")
    val petal_width = j.getDouble("petal_width")

    val features = Vectors.dense(sepal_length, sepal_width, petal_length, petal_width)
    val point = new LabeledPoint(label,features)

    training_points ::= point
  //  println("TRAINING ////////////////////////////////////////////////" + count)
    count = count + 1
   }

  var k = 0
  var count_test = 0

 for( k <- test_split.toArray)
   {
    val flower_name = k.getString("flower")
    val label = matchTest(flower_name)

    val sepal_length = k.getDouble("sepal_length")
    val sepal_width = k.getDouble("sepal_width")
    val petal_length = k.getDouble("petal_length")
    val petal_width = k.getDouble("petal_width")

    val features = Vectors.dense(sepal_length, sepal_width, petal_length, petal_width)
    val point = new LabeledPoint(label,features)

    testing_points ::= point
//    println("TESTING////////////////////////////////////////////////" + count_test)
    count_test = count_test + 1
   }

  val numClasses = 3
  val categoricalFeaturesInfo = Map[Int, Int]()
  val impurity = "gini"
  val maxDepth = 2
  val maxBins = 2

  // Bringing the List to RDD Format
  val trainingData = sc.parallelize(training_points)
  val testData = sc.parallelize(testing_points)

  val model = DecisionTree.trainClassifier(trainingData, numClasses, categoricalFeaturesInfo,
                                           impurity, maxDepth, maxBins)

   val labelAndPreds = testData.map { point =>
                                     val prediction = model.predict(point.features)
                                       (point.label, prediction)
                                    }

   val testErr = labelAndPreds.filter(r => r._1 != r._2).count().toDouble / testData.count()
   println("Test Error //////////////////////////////////////////////= " + testErr)
   println("Learned classification tree model:\n" + model.toDebugString)

				 */
				/////////////////////////////////////////////////////////////////////////////////////////////

				/// Dataframe Approach 
				//  create dataframe
				/**
    val df = sqlCtx.read
                   .format("org.apache.spark.sql.cassandra")
                   .options(Map( "table" -> "data", "keyspace" -> "iris"))
                   .load()

//  sqlCtx.sql("set spark.sql.shuffle.partitions=2001")
				 */
				// df.registerTempTable("df")
				// df.cache()

				/**
   println("////////////////////////////// count ///////////////////////////////" + df.getClass)
   // println("////////////////    count ///////////////////////////////////////////////////////")

     def matchTest(x:String) : Double = x match {
    case "Iris-setosa" => 0.0
    case "Iris-versicolor" => 1.0
    case "Iris-virginica" => 2.0
    }

  // val Vec4: (Double a, Double b, Double c , Double d) => Vector = Vectors.dense(a, b, c, d) 


  // val toVec4 = udf(Vec4)

    val encodeLabel = udf[Double, String]( _ match { 
			case "Iris-setosa" => 0.0 
			case "Iris-versicolor" => 1.0 
			case "Iris-virginica" => 2.0 } )

			df.withColumn("flower", encodeLabel(df("flower"))).show()


    val df_mod = df.withColumn(
                               "features",
  				toVec4(
			               df("sepal_length"),
    				       df("sepal_width"),
    				       df("petal_length"),
    				       df("petal_width")
  				      )
				      ).withColumn("label", (df("flower"))).select("features", "label")

				      val new_df = df_mod.toDF()
				      df_mod.show()
				 */
				// val new_rdd = df_mod.rdd
				//  df_mod.registerTempTable("df_mod") 
				// df_mod.cache()

				/**

    val splits = new_rdd.randomSplit(Array(0.7, 0.3))
    val (training_split, test_split) = (splits(0), splits(1))

    val trainingData = training_split.rdd.map(row => LabeledPoint(
   						row.getAs[Double]("label"),
					        row.getAs[org.apache.spark.mllib.linalg.Vector]("features")
   						))

    val testData = test_split.rdd.map(row => LabeledPoint(
 				        row.getAs[Double]("label"),
    				        row.getAs[org.apache.spark.mllib.linalg.Vector]("features")
     				      ))



     // trainingData.cache()
  //val train_data = trainingData.repartition(3001)
// println("/////////////////////////////////" + train_data.partitions.size)

  // testData.cache()

// Dataframe to RDD
// val rows: org.apache.spark.rdd.RDD[org.apache.spark.sql.Row] = trainingData.rdd



     // Train a DecisionTree model.
     //  Empty categoricalFeaturesInfo indicates all features are continuous.
    val numClasses = 3
    val categoricalFeaturesInfo = Map[Int, Int]()
    val impurity = "gini"
    val maxDepth = 2
    val maxBins = 2


    val model = DecisionTree.trainClassifier(trainingData, numClasses, categoricalFeaturesInfo,
                                              impurity, maxDepth, maxBins)



// Evaluate model on test instances and compute test error
    val labelAndPreds = testData.map { point =>
    val prediction = model.predict(point.features)
      (point.label, prediction)
      }

   val testErr = labelAndPreds.filter(r => r._1 != r._2).count().toDouble / testData.count()
   println("//////////////////////////////////////////////////////////////Test Error = " + testErr)
   println("/////////////////////////////////////////////Learned classification tree model:\n" + model.toDebugString)

				 */
				//////////////////////////////////////////////////////////////////////////////////////////////////////////////

				// emr_data.foreach(println)
				// emr_data.toArray().foreach(line => println(line))
				// emr_data.collect().foreach(println)

				// Working 107535277
				// emr_labscorepopulated_data.take(50000).foreach(println)

				// sc.stop()
	}

}

