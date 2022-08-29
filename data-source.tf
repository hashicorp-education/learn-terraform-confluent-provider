resource "confluent_connector" "source" {
  environment {
    id = confluent_environment.tutorial.id
  }
  kafka_cluster {
    id = confluent_kafka_cluster.inventory.id
  }

  config_sensitive = {}

  config_nonsensitive = {
    "connector.class"          = "DatagenSource"
    "name"                     = "DatagenSourceConnector_0"
    "kafka.auth.mode"          = "SERVICE_ACCOUNT"
    "kafka.service.account.id" = confluent_service_account.orders_producer.id
    "kafka.topic"              = confluent_kafka_topic.orders.topic_name
    "output.data.format"       = "JSON"
    "quickstart"               = "ORDERS"
    "tasks.max"                = "1"
  }

}
