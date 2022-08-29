output "inventory_cluster_rest_endpoint" {
  value = confluent_kafka_cluster.inventory.rest_endpoint
}

output "admin_api_key" {
  value = confluent_api_key.admin.id
}
output "admin_api_secret" {
  value     = confluent_api_key.admin.secret
  sensitive = true
}

output "orders_producer_api_key" {
  value = confluent_api_key.orders_producer.id
}
output "orders_producer_api_secret" {
  value     = confluent_api_key.orders_producer.secret
  sensitive = true
}

output "orders_consumer_api_key" {
  value = confluent_api_key.orders_consumer.id
}
output "orders_consumer_api_secret" {
  value     = confluent_api_key.orders_consumer.secret
  sensitive = true
}
