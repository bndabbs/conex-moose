#!/bin/bash
set -euo pipefail

es_url=https://elastic:${ELASTIC_PASSWORD}@elasticsearch01:9200

role_data()
{
  cat <<EOF
{
  "cluster": ["manage_index_templates", "monitor"],
  "indices": [
    {
      "names": [ "*" ],
      "privileges": ["write","delete","create_index"]
    }
  ]
}
EOF
}

user_data()
{
  cat <<EOF
{
  "password" : "${INGEST_PASSWORD}",
  "roles" : [ "ingest" ],
  "full_name" : "Logstash Ingest"
}
EOF
}

# Wait for Elasticsearch to start up before doing anything.
until curl -k -s $es_url -o /dev/null; do
    sleep 1
done

# Set the password for the logstash_system user.
# REF: https://www.elastic.co/guide/en/x-pack/6.0/setting-up-authentication.html#set-built-in-user-passwords
until curl -k -s -H 'Content-Type:application/json' \
     -XPUT $es_url/_xpack/security/user/logstash_system/_password \
     -d "{\"password\": \"${LOGSTASH_PASSWORD}\"}"
do
    sleep 2
    echo Retrying...
done

# Add ingest role and user
role_status="$(curl --write-out %{http_code} --output /dev/null -k -s -H 'Content-Type:application/json' -XGET $es_url/_xpack/security/role/ingest)"

if [ "$role_status" == "404" ]; then
  echo "Ingest role not found. Creating it now"
  curl -s -k -XPOST $es_url/_xpack/security/role/ingest?pretty -H 'Content-Type: application/json' -d "$(role_data)"
elif [ $role_status == "200" ]; then
  echo "Ingest role already exists"
else
  echo "Something went wrong!"
fi

user_status="$(curl --write-out %{http_code} --output /dev/null -k -s -H 'Content-Type:application/json' -XGET $es_url/_xpack/security/user/$INGEST_USER)"

if [ "$user_status" == "404" ]; then
  echo "$INGEST_USER user not found. Creating it now"
  curl -s -k -XPOST $es_url/_xpack/security/user/"${INGEST_USER}"?pretty -H 'Content-Type: application/json' -d "$(user_data)"
elif [ $user_status == "200" ]; then
  echo "$INGEST_USER already exists"
else
  echo "Something went wrong!"
fi
