Formless
========

Ngram based sentence generator + training engine service implemented in Elixir

How to run
----------
Make sure you have Elixir and Docker Compose installed. Then run `docker-compose up`, `mix deps.get`, and `mix run --no-halt`

API
---

### Index text
`POST /index_text`
```json
{ "bucket": "myBucket", "text": "The quick brown fox jumps over the lazy dog" } 
```
Formless will accept either `application/json` or `application/x-www-form-urlencoded` encodings in the form body. Response body should be `ok` if the text was successfully indexed.

### Get random text
`GET /query_random?from_bucket=bucket1&to_bucket=bucket2`

Response body will be a sentence that was generated between the two specified buckets. Will return an empty body if the specified buckets don't exist, or if there's no intersection between the two indexes.
