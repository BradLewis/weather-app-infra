module "stations_table" {
  source = "terraform-aws-modules/dynamodb-table/aws"

  name      = "Stations"
  hash_key  = "Id"
  range_key = "Name"

  attributes = [
    {
      name = "Id"
      type = "N"
    },
    {
      name = "Name"
    type = "S" }
  ]

  global_secondary_indexes = [{
    name               = "NameIndex"
    hash_key           = "Name"
    projection_type    = "INCLUDE"
    non_key_attributes = ["id"]
  }]
}
