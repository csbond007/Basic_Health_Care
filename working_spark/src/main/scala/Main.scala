
 import org.apache.spark.SparkContext
import org.apache.spark.SparkContext._
import org.apache.spark.SparkConf
import com.datastax.spark.connector._


object Main {
  def main(args: Array[String]) {

     val conf = new SparkConf(true)
    .set("spark.cassandra.connection.host", "10.10.40.138")
     .setAppName(this.getClass.getSimpleName)
     .setMaster("mesos://zk://10.10.40.138:2181/mesos")

     val sc =  new SparkContext(conf)


 val NUM_SAMPLES = 1000000
val count = sc.parallelize(1 to NUM_SAMPLES).map{i =>
  val x = Math.random()
  val y = Math.random()
  if (x*x + y*y < 1) 1 else 0
}.reduce(_ + _)
println("///////////////////// Pi is roughly " + 4.0 * count / NUM_SAMPLES)

     val i = 1
     println("//////////////////////////////////")
     println(i)


val emr_labscorepopulated_data = sc.cassandraTable("emrbots_data", "emr_labscorepopulated")

println(emr_labscorepopulated_data.count())
println("//////////////////////////////// emr_labscorepopulated_data.count() ///////////////////////")

val firstRow = emr_labscorepopulated_data.first
println(firstRow.size )
println("/////////////////////////// firstRow.size /////////////////////////////// ")

// println("///////////////////////////////////////////// firstRow.getString(admissionid)////////")
// println(firstRow.getString("admissionid"))

// emr_data.foreach(println)
// emr_data.toArray().foreach(line => println(line))
// emr_data.collect().foreach(println)

// Working 107535277
emr_labscorepopulated_data.take(50000).foreach(println)

sc.stop()
}

}
 
