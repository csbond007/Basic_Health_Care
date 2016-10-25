name := "SampleApp"

version := "1.0"

scalaVersion := "2.10.6"

libraryDependencies += "org.apache.spark" %% "spark-core" % "1.6.2"

libraryDependencies += "org.apache.spark" %% "spark-sql" % "1.6.2"

libraryDependencies += "com.datastax.spark" % "spark-cassandra-connector_2.10" % "1.6.1"

libraryDependencies += "com.datastax.cassandra" % "cassandra-driver-core" % "3.1.1"

jarName in assembly :="Fat.jar"

assemblyOption in assembly := (assemblyOption in assembly).value.copy(includeScala = false)

resolvers += "Akka Repository" at "http://repo.akka.io/releases/"

 // META-INF discarding
mergeStrategy in assembly <<= (mergeStrategy in assembly) { (old) =>
   {
    case PathList("META-INF", xs @ _*) => MergeStrategy.discard
    case x => MergeStrategy.first
   }
}

