use Mix.Config

config :neo4j_sips, Neo4j,
  url: "http://neo4j:7474",
  pool_size: 5,
  max_overflow: 2,
  timeout: 60
