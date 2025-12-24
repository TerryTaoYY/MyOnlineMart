#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-http://localhost:8080}"
LOG_FILE="api-test.log"
TMP_RESP=".tmp_response.json"

: > "$LOG_FILE"

call() {
  local method="$1"
  local url="$2"
  local data="${3-}"
  local token="${4-}"

  echo "### ${method} ${url}" >> "$LOG_FILE"
  if [ -n "$data" ]; then
    if [ -n "$token" ]; then
      status=$(curl -s -o "$TMP_RESP" -w "%{http_code}" -X "$method" "$url" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer ${token}" \
        -d "$data")
    else
      status=$(curl -s -o "$TMP_RESP" -w "%{http_code}" -X "$method" "$url" \
        -H "Content-Type: application/json" \
        -d "$data")
    fi
  else
    if [ -n "$token" ]; then
      status=$(curl -s -o "$TMP_RESP" -w "%{http_code}" -X "$method" "$url" \
        -H "Authorization: Bearer ${token}")
    else
      status=$(curl -s -o "$TMP_RESP" -w "%{http_code}" -X "$method" "$url")
    fi
  fi
  echo "HTTP ${status}" >> "$LOG_FILE"
  cat "$TMP_RESP" >> "$LOG_FILE"
  echo -e "\n" >> "$LOG_FILE"
}

parse_json() {
  local key="$1"
  python - <<PY
import json
with open("$TMP_RESP") as f:
    data = json.load(f)
print(data["$key"])
PY
}

BUYER_SUFFIX=$(date +%s)
BUYER_USERNAME="buyer${BUYER_SUFFIX}"
BUYER_EMAIL="buyer${BUYER_SUFFIX}@example.com"
BUYER_PASSWORD="Password123!"
ADMIN_USERNAME="admin"
ADMIN_PASSWORD="admin12345"

register_payload=$(cat <<JSON
{"username":"${BUYER_USERNAME}","email":"${BUYER_EMAIL}","password":"${BUYER_PASSWORD}"}
JSON
)
call "POST" "${BASE_URL}/api/auth/register" "$register_payload"
BUYER_TOKEN=$(parse_json "token")

invalid_login_payload=$(cat <<JSON
{"usernameOrEmail":"${BUYER_USERNAME}","password":"wrongpass"}
JSON
)
call "POST" "${BASE_URL}/api/auth/login" "$invalid_login_payload"

login_payload=$(cat <<JSON
{"usernameOrEmail":"${BUYER_USERNAME}","password":"${BUYER_PASSWORD}"}
JSON
)
call "POST" "${BASE_URL}/api/auth/login" "$login_payload"
BUYER_TOKEN=$(parse_json "token")

admin_login_payload=$(cat <<JSON
{"usernameOrEmail":"${ADMIN_USERNAME}","password":"${ADMIN_PASSWORD}"}
JSON
)
call "POST" "${BASE_URL}/api/auth/login" "$admin_login_payload"
ADMIN_TOKEN=$(parse_json "token")

product1_payload=$(cat <<JSON
{"description":"Organic Apples","wholesalePrice":1.00,"retailPrice":2.50,"stockQuantity":10}
JSON
)
call "POST" "${BASE_URL}/api/admin/products" "$product1_payload" "$ADMIN_TOKEN"
PRODUCT1_ID=$(parse_json "id")

product2_payload=$(cat <<JSON
{"description":"Almond Milk","wholesalePrice":2.00,"retailPrice":4.50,"stockQuantity":5}
JSON
)
call "POST" "${BASE_URL}/api/admin/products" "$product2_payload" "$ADMIN_TOKEN"
PRODUCT2_ID=$(parse_json "id")

product3_payload=$(cat <<JSON
{"description":"Coffee Beans","wholesalePrice":5.00,"retailPrice":9.00,"stockQuantity":2}
JSON
)
call "POST" "${BASE_URL}/api/admin/products" "$product3_payload" "$ADMIN_TOKEN"
PRODUCT3_ID=$(parse_json "id")

call "GET" "${BASE_URL}/api/admin/products" "" "$ADMIN_TOKEN"
call "GET" "${BASE_URL}/api/admin/products/${PRODUCT1_ID}" "" "$ADMIN_TOKEN"

product_update_payload=$(cat <<JSON
{"retailPrice":2.75,"stockQuantity":12}
JSON
)
call "PATCH" "${BASE_URL}/api/admin/products/${PRODUCT1_ID}" "$product_update_payload" "$ADMIN_TOKEN"

call "GET" "${BASE_URL}/api/buyer/products" "" "$BUYER_TOKEN"
call "GET" "${BASE_URL}/api/buyer/products/${PRODUCT1_ID}" "" "$BUYER_TOKEN"

call "POST" "${BASE_URL}/api/buyer/watchlist/${PRODUCT1_ID}" "" "$BUYER_TOKEN"
call "POST" "${BASE_URL}/api/buyer/watchlist/${PRODUCT1_ID}" "" "$BUYER_TOKEN"
call "GET" "${BASE_URL}/api/buyer/watchlist" "" "$BUYER_TOKEN"
call "DELETE" "${BASE_URL}/api/buyer/watchlist/${PRODUCT1_ID}" "" "$BUYER_TOKEN"
call "DELETE" "${BASE_URL}/api/buyer/watchlist/${PRODUCT1_ID}" "" "$BUYER_TOKEN"

order1_payload=$(cat <<JSON
{"items":[{"productId":${PRODUCT1_ID},"quantity":2},{"productId":${PRODUCT2_ID},"quantity":1}]}
JSON
)
call "POST" "${BASE_URL}/api/buyer/orders" "$order1_payload" "$BUYER_TOKEN"
ORDER1_ID=$(parse_json "id")

call "GET" "${BASE_URL}/api/buyer/orders" "" "$BUYER_TOKEN"
call "GET" "${BASE_URL}/api/buyer/orders/${ORDER1_ID}" "" "$BUYER_TOKEN"
call "GET" "${BASE_URL}/api/buyer/orders/top/frequent" "" "$BUYER_TOKEN"
call "GET" "${BASE_URL}/api/buyer/orders/top/recent" "" "$BUYER_TOKEN"

call "GET" "${BASE_URL}/api/admin/orders?page=0" "" "$ADMIN_TOKEN"
call "GET" "${BASE_URL}/api/admin/orders/${ORDER1_ID}" "" "$ADMIN_TOKEN"
call "PATCH" "${BASE_URL}/api/admin/orders/${ORDER1_ID}/complete" "" "$ADMIN_TOKEN"

order2_payload=$(cat <<JSON
{"items":[{"productId":${PRODUCT1_ID},"quantity":1}]}
JSON
)
call "POST" "${BASE_URL}/api/buyer/orders" "$order2_payload" "$BUYER_TOKEN"
ORDER2_ID=$(parse_json "id")
call "PATCH" "${BASE_URL}/api/admin/orders/${ORDER2_ID}/cancel" "" "$ADMIN_TOKEN"

order3_payload=$(cat <<JSON
{"items":[{"productId":${PRODUCT2_ID},"quantity":1}]}
JSON
)
call "POST" "${BASE_URL}/api/buyer/orders" "$order3_payload" "$BUYER_TOKEN"
ORDER3_ID=$(parse_json "id")
call "PATCH" "${BASE_URL}/api/buyer/orders/${ORDER3_ID}/cancel" "" "$BUYER_TOKEN"

inventory_payload=$(cat <<JSON
{"items":[{"productId":${PRODUCT3_ID},"quantity":5}]}
JSON
)
call "POST" "${BASE_URL}/api/buyer/orders" "$inventory_payload" "$BUYER_TOKEN"

call "GET" "${BASE_URL}/api/admin/summary/profit" "" "$ADMIN_TOKEN"
call "GET" "${BASE_URL}/api/admin/summary/popular" "" "$ADMIN_TOKEN"
call "GET" "${BASE_URL}/api/admin/summary/total-sold" "" "$ADMIN_TOKEN"

rm -f "$TMP_RESP"
