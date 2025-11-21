from pyspark import SparkContext, SparkConf
import sys

if len(sys.argv) != 2:
    print("Usage: wordcount.py <file>")
    sys.exit(-1)

file_path = sys.argv[1]

conf = SparkConf().setAppName("WordCount")
sc = SparkContext(conf=conf)

# Lire le fichier
lines = sc.textFile(file_path)

# Compter les mots
counts = lines.flatMap(lambda line: line.split()) \
              .map(lambda word: (word, 1)) \
              .reduceByKey(lambda a, b: a + b)

# Afficher le résultat
for word, count in counts.collect():
    print(f"{word}: {count}")

sc.stop()
