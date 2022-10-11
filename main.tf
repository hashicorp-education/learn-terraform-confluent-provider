# The provider will pull credentials from two environment variables:
# CONFLUENT_CLOUD_API_KEY and CONFLUENT_CLOUD_API_SECRET
provider "confluent" {
}

resource "confluent_environment" "tutorial" {
  display_name = "tutorial"
}

# Update the config to use a cloud provider and region of your choice.
# https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/confluent_kafka_cluster
resource "confluent_kafka_cluster" "inventory" {
  display_name = "inventory"
  availability = "SINGLE_ZONE"
  cloud        = "AWS"
  region       = "us-east-2"
  # Standard supports granular RBAC for admin, producer, consumer service accounts
  standard {}
  environment {
    id = confluent_environment.tutorial.id
  }
}


# Cluster administrator service account
resource "confluent_service_account" "admin" {
  display_name = "admin"
  description  = "Cluster management service account"
}

resource "confluent_service_account" "orders_producer" {
  display_name = "orders_producer"
  description  = "Service account that can write messages to the 'orders' topic"
}

resource "confluent_service_account" "orders_consumer" {
  display_name = "orders_consumer"
  description  = "Service account that can read messages from the 'orders' topic"
}


resource "confluent_api_key" "admin" {
  display_name = "admin"
  description  = "Kafka API Key owned by the 'admin' service account"
  owner {
    id          = confluent_service_account.admin.id
    api_version = confluent_service_account.admin.api_version
    kind        = confluent_service_account.admin.kind
  }

  managed_resource {
    id          = confluent_kafka_cluster.inventory.id
    api_version = confluent_kafka_cluster.inventory.api_version
    kind        = confluent_kafka_cluster.inventory.kind

    environment {
      id = confluent_environment.tutorial.id
    }
  }

  # Wait until the necessary role has been bound to the service account,
  # to avoid race condition with topic creation
  depends_on = [
    confluent_role_binding.admin
    #confluent_kafka_acl.admin
  ]
}

resource "confluent_api_key" "orders_consumer" {
  display_name = "orders_consumer"
  description  = "Kafka API Key owned by the 'orders_consumer' service account"
  owner {
    id          = confluent_service_account.orders_consumer.id
    api_version = confluent_service_account.orders_consumer.api_version
    kind        = confluent_service_account.orders_consumer.kind
  }

  managed_resource {
    id          = confluent_kafka_cluster.inventory.id
    api_version = confluent_kafka_cluster.inventory.api_version
    kind        = confluent_kafka_cluster.inventory.kind

    environment {
      id = confluent_environment.tutorial.id
    }
  }
}

resource "confluent_api_key" "orders_producer" {
  display_name = "orders_producer"
  description  = "Kafka API Key owned by the 'orders_producer' service account"
  owner {
    id          = confluent_service_account.orders_producer.id
    api_version = confluent_service_account.orders_producer.api_version
    kind        = confluent_service_account.orders_producer.kind
  }

  managed_resource {
    id          = confluent_kafka_cluster.inventory.id
    api_version = confluent_kafka_cluster.inventory.api_version
    kind        = confluent_kafka_cluster.inventory.kind

    environment {
      id = confluent_environment.tutorial.id
    }
  }
}




resource "confluent_role_binding" "admin" {
  principal   = "User:${confluent_service_account.admin.id}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = confluent_kafka_cluster.inventory.rbac_crn
}

resource "confluent_role_binding" "orders_producer_write_to_topic" {
  principal   = "User:${confluent_service_account.orders_producer.id}"
  role_name   = "DeveloperWrite"
  crn_pattern = "${confluent_kafka_cluster.inventory.rbac_crn}/kafka=${confluent_kafka_cluster.inventory.id}/topic=${confluent_kafka_topic.orders.topic_name}"
}

resource "confluent_role_binding" "orders_consumer_read_from_topic" {
  principal   = "User:${confluent_service_account.orders_consumer.id}"
  role_name   = "DeveloperRead"
  crn_pattern = "${confluent_kafka_cluster.inventory.rbac_crn}/kafka=${confluent_kafka_cluster.inventory.id}/topic=${confluent_kafka_topic.orders.topic_name}"
}





resource "confluent_kafka_topic" "orders" {
  kafka_cluster {
    id = confluent_kafka_cluster.inventory.id
  }
  topic_name       = "orders"
  rest_endpoint    = confluent_kafka_cluster.inventory.rest_endpoint
  credentials {
    key    = confluent_api_key.admin.id
    secret = confluent_api_key.admin.secret
  }
}






