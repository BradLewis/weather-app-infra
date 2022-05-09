module "stations_table" {
  source = "terraform-aws-modules/dynamodb-table/aws"

  name      = "Stations"
  hash_key  = "id"
  range_key = "name"

  attributes = [
    {
      name = "Id"
      type = "N"
    },
    {
      name = "Name"
      type = "S"
    }
  ]
}
