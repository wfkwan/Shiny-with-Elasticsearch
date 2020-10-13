library(DBI)
library(reticulate)

use_python("<PYTHONPATH>")

# Connect Amazon Elasticsearch Service
# py_awsauth <- import("requests_aws4auth")
# credentials <- data.frame(list('<key>', '<secret>', '<region>', '<service>'))
# authr <- py_awsauth$AWS4Auth(credentials$key, credentials$secret, credentials$region, credentials$service)
# colnames(credentials) <- c("key", "secret", "region", "service")
# hosts = c("<domain>:<port>")
# 
# es <- elasticsearch$Elasticsearch(hosts = list(hosts), http_auth = authr,
#                                   connection_class = elasticsearch$RequestsHttpConnection,
#                                   use_ssl = TRUE, verify_certs = TRUE)

elasticsearch <- import("elasticsearch")

host = "localhost:9200"

es <- elasticsearch$Elasticsearch(hosts = host)

# Elasticsearch Queries
airline_carrier_query <- '
{
  "aggs": {
    "agg_name": {
      "terms": {
        "field": "Carrier",
        "order": {
          "_count": "desc"
        },
        "size": 5
      }
    }
  },
  "size": 0,
  "query": {
    "bool": {
      "filter": [
        {
          "range": {
            "timestamp": {
              "gte": "2020-10-10",
              "lte": "2020-10-11"
            }
          }
        }
      ]
    }
  }
}
'

delay_type_query <- '
{
  "aggs": {
    "agg1_name": {
      "date_histogram": {
        "field": "timestamp",
        "fixed_interval": "30m",
        "time_zone": "Asia/Hong_Kong",
        "min_doc_count": 1
      },
      "aggs": {
        "agg2_name": {
          "terms": {
            "field": "FlightDelayType",
            "order": {
              "_count": "desc"
            },
            "size": 5
          }
        }
      }
    }
  },
  "size": 0,
  "script_fields": {
    "hour_of_day": {
      "script": {
        "source": "doc[\'timestamp\'].value.hourOfDay",
        "lang": "painless"
      }
    }
  },
  "query": {
    "bool": {
      "filter": [
        {
          "range": {
            "timestamp": {
              "gte": "2020-10-10",
              "lte": "2020-10-11"
            }
          }
        }
      ]
    }
  }
}
'

dest_weather_query <- '
{
  "aggs": {
    "agg_name": {
      "terms": {
        "field": "DestWeather",
        "order": {
          "_count": "desc"
        },
        "size": 10
      }
    }
  },
  "size": 0,
  "query": {
    "bool": {
      "filter": [
        {
          "range": {
            "timestamp": {
              "gte": "2020-10-10",
              "lte": "2020-10-11"
            }
          }
        }
      ]
    }
  }
}
'
