
object Cells {
  import org.apache.spark.sql.Row
  import org.apache.spark.sql.functions._
  import org.apache.spark.ml.clustering.KMeans
  import org.apache.spark.mllib.linalg.{Vectors, Vector}
  import scala.collection.mutable.WrappedArray
  
  val sqlContext = new org.apache.spark.sql.SQLContext(sparkContext)

  /* ... new cell ... */

  val df = sqlContext.read.format("com.databricks.spark.csv").option("header","true")
    .load("C:\\Data\\pkdd-taxi\\train.csv")
    .filter("POLYLINE != '[]'").limit(20000)
  df.printSchema()

  /* ... new cell ... */

  import org.apache.spark.sql.functions.udf
  
  def parsePolyline (str : String) : Array[Array[Double]] = {
    str.substring(1,str.length-2).split("],")             // split coordinate list
        .map(_.substring(1).split(",").map(_.toDouble))   // parse coordinate values
  }
  
  // convert to User Defined Function for use in Data Frame
  val parsePolylineFunc = udf((x : String) => parsePolyline(x))
  
  def parseDistance (coordinates : WrappedArray[WrappedArray[Double]]) : Double = {
    var distance : Double = 0;
    for (i <- 1 to coordinates.length-1) {
      // Manhattan distance
      distance += (coordinates(i-1)(0)-coordinates(i)(0)) + (coordinates(i-1)(1)-coordinates(i)(1))
    }
    return distance;
  }
  val parseDistanceFunc = udf((x : WrappedArray[WrappedArray[Double]]) => parseDistance(x))
  
  // now create a new data frame with these columns
  val parsedDF = df.select("TRIP_ID", "TIMESTAMP", "POLYLINE")
    .withColumn("coordinates", parsePolylineFunc(col("POLYLINE")))
    .withColumn("distance", parseDistanceFunc(col("coordinates")))
  
  // and cache the result when we're done adding features
    .cache()

  /* ... new cell ... */

  // we need to convert the Row() format of our Data Frame into a simple, local array for the geo plot
  val pts = parsedDF.select("coordinates", "distance").map({
      case (Row(coords : WrappedArray[WrappedArray[_]], distance : Double)) 
            => (coords(0)(0), coords(0)(1), distance*50)
  }).collect()
  
  // funnily enough, the source data has lat and Long switched...
  widgets.GeoPointsChart(pts, latLonFields=Some(("_2", "_1")), rField=Some("_3"))

  /* ... new cell ... */

  // the KMeans algorithm requires its input to be in Vector format, so yet another map operation
  val getFeaturesF = udf((x : WrappedArray[WrappedArray[Double]]) => Vectors.dense(x(0).toArray))
  val clusterDF = parsedDF.select("TRIP_ID", "coordinates")
    .withColumn("features", getFeaturesF(col("coordinates")))
    .drop("coordinates").cache()

  /* ... new cell ... */

  val kmeans = new KMeans().setK(3).setFeaturesCol("features").setPredictionCol("prediction")
  val model = kmeans.fit(clusterDF)

  /* ... new cell ... */

  val centers = model.clusterCenters.map(x => (x(0),x(1)))
  widgets.GeoPointsChart(centers, latLonFields=Some(("_2", "_1")))

  /* ... new cell ... */

  val predictedDF = model.transform(clusterDF)
  predictedDF.groupBy("prediction").agg(count(col("features"))).show()
  
  // after a bit of digging, I actually found two
  val clusterDF2 = clusterDF.where("TRIP_ID != 1372846640620000473 AND TRIP_ID != 1372868646620000496")
  val model2 = kmeans.fit(clusterDF2)
  val predictedDF2 = model2.transform(clusterDF2)
  predictedDF2.groupBy("prediction").agg(count(col("features"))).show()

  /* ... new cell ... */

  // define a color scheme
  def predColor (p : Integer) : String = {
    if (p == 0) { return "red" }
    if (p == 1) { return "blue" }
    if (p == 2) { return "green" }
    if (p == 3) { return "black" }
    if (p == 4) { return "pink" }
    else { return "yellow" }
  }
  
  // and prepare the points
  val pts = predictedDF2.select("features", "prediction").map({
    case (Row(features : Vector, prediction : Integer)) 
              => (features(0), features(1), predColor(prediction))
  }).collect()

  /* ... new cell ... */

  var w = widgets.GeoPointsChart(pts, latLonFields=Some(("_2", "_1")), colorField=Some("_3"))
  for (i <- 0 to model.clusterCenters.length-1) {
    w.addAndApply(Array((model.clusterCenters(i)(0), model.clusterCenters(i)(1), "black")))
  }
  w

  /* ... new cell ... */

  // create a new getFeatures function and assemble a DF with this new input
  val getFeaturesF2 = udf((x : WrappedArray[WrappedArray[Double]], d: Double) 
                         => Vectors.dense(x(0)(0), x(0)(1), x(x.length-1)(0), x(x.length-1)(1), d))
  val clusterDF3 = parsedDF.where("TRIP_ID != 1372846640620000473 AND TRIP_ID != 1372868646620000496")
    .select("TRIP_ID", "coordinates", "distance")
    .withColumn("features", getFeaturesF2(col("coordinates"), col("distance")))
    .drop("coordinates").cache()
  
  // fit new model and apply
  val kmeans3 = new KMeans().setK(6).setFeaturesCol("features").setPredictionCol("prediction")
  val model3 = kmeans3.fit(clusterDF3)
  val predictedDF3 = model3.transform(clusterDF3)
  
  // assemble points for visualization
  val pts3 = predictedDF3.select("features", "prediction").map({
    case (Row(features : Vector, prediction : Integer)) 
              => (features(0), features(1), predColor(prediction))
  }).collect()

  /* ... new cell ... */

  // show distribution
  predictedDF3.groupBy("prediction").agg(count(col("features"))).show()
  
  // plot distribution on map
  widgets.GeoPointsChart(pts3, latLonFields=Some(("_2", "_1")), colorField=Some("_3"))
}
                  