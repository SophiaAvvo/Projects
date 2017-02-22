SET mapred.output.compression.type=BLOCK;
SET mapred.output.compression.codec=org.apache.hadoop.io.compress.SnappyCodec;
SET hive.parquet.compression=SNAPPY;

CREATE TABLE IF NOT EXISTS tmp_data_src.SR_sparklers_ratings_from_May_2015
(professional_id INTEGER
,rating DOUBLE
,rating_date VARCHAR)