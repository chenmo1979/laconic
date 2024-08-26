#!/bin/bash
set -e

# 设置临时文件
CONFIG_FILE=$(mktemp)
AR_RECORD_FILE=$(mktemp)

# 配置 Laconic
cat <<EOF > "$CONFIG_FILE"
services:
  registry:
    rpcEndpoint: 'https://laconicd.laconic.com'
    gqlEndpoint: 'https://laconicd.laconic.com/api'
    chainId: laconic_9000-1
    gas: 9550000
    fees: 15000000alnt
EOF

# 读取 package.json 并创建应用记录
rcd_name=$(jq -r '.name' package.json)
rcd_desc=$(jq -r '.description' package.json)
rcd_homepage=$(jq -r '.homepage' package.json)
rcd_license=$(jq -r '.license' package.json)
rcd_author=$(jq -r '.author' package.json)
rcd_app_version=$(jq -r '.version' package.json)

cat <<EOF > "$AR_RECORD_FILE"
record:
  type: ApplicationRecord
  version: ${next_ver}
  name: "$rcd_name"
  description: "$rcd_desc"
  homepage: "$rcd_homepage"
  license: "$rcd_license"
  author: "$rcd_author"
  repository:
    - "$rcd_repository"
  repository_ref: "$CERC_REPO_REF"
  app_version: "$rcd_app_version"
  app_type: "$CERC_APP_TYPE"
EOF

# 发布应用记录
AR_RECORD_ID=$(laconic -c $CONFIG_FILE registry record publish --filename $AR_RECORD_FILE --user-key "${CERC_REGISTRY_USER_KEY}" --bond-id ${CERC_REGISTRY_BOND_ID} | jq -r '.id')
echo "Application Record ID: $AR_RECORD_ID"

# 清理临时文件
rm -f $AR_RECORD_FILE $CONFIG_FILE
