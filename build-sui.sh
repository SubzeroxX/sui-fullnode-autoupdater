start_time=$SECONDS
cd "$(dirname "$0")"
if [ ! -d "sui-build" ]; then
	mkdir sui-build
fi
cd sui-build
if [ ! -d "sui" ]; then
	git clone https://github.com/MystenLabs/sui.git --depht=1
fi
latest_version=$(curl -s "https://api.github.com/repos/MystenLabs/sui/releases" | jq -r '.[] | select(.tag_name | startswith("mainnet-")) | .tag_name' | head -n 1)
echo "The latest release tag is: $latest_version"
cd sui
git fetch --tags
local_version=$(git describe --tags --exact-match 2>/dev/null)
echo "The local release tag is: $local_version"
echo "Current tag ($local_version) is different from the latest tag ($latest_version)."

result=$([ "$latest_version" = "$local_version" ] && echo "✅ Matches" || echo "❌ Update required")
message_color=$([ "$latest_version" = "$local_version" ] && echo 1099008 || echo 13172736)
time_utc=$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")
report_url="{redacted}"
report_message=$(cat <<EOM
{"embeds":[{"title":"Version check","color": ${message_color},"fields":[
{"name":"Version","value":"Latest: ${latest_version}\nLocal:    ${local_version}"},
{"name":"Result","value":"${result}"}],"footer":{"text":"Checked at"},
"timestamp":"${time_utc}"}]}
EOM
)
curl -H "Content-Type: application/json" -d "$report_message" -X POST "$report_url"
if [ "$local_version" = "$latest_version" ]; then
    echo "Current local tag ($local_version) MATCHES the latest tag ($latest_version)."
    echo "No update required. Shutting down script."
    exit 0  # Exit successfully
fi

message_color=15303425
time_utc=$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")
report_message=$(cat <<EOM
{"embeds":[{"title":"Build started","color": ${message_color},"footer":
{"text":"Started at"},"timestamp":"${time_utc}"}]}
EOM
)
curl -H "Content-Type: application/json" -d "$report_message" -X POST "$report_url"

echo "Initiating update and build..."
git checkout "$latest_version"
export PATH="/home/$USER/.cargo/bin:$PATH"
export RUSTFLAGS="-C target-cpu=native -C target-feature=-avx512f,-avx512dq,-avx512cd,-avx512bw,-avx512vl"
cargo build --release
find target/release/ -maxdepth 1 -type f -executable -exec mv -f {} ../../sui-bin/ \;
rm -rf target
cd ../../
time_utc=$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")
report_message=$(cat <<EOM
{"embeds":[{"title":"Deploy started","color": ${message_color},"footer":
{"text":"Started at"},"timestamp":"${time_utc}"}]}
EOM
)
curl -H "Content-Type: application/json" -d "$report_message" -X POST "$report_url"

exec ./deploy.sh

message_color=1099008
time_utc=$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")
report_message=$(cat <<EOM
{"embeds":[{"title":"Deployed","color": ${message_color},"footer":
{"text":"Deployed at"},"timestamp":"${time_utc}"}]}
EOM
)
curl -H "Content-Type: application/json" -d "$report_message" -X POST "$report_url"

echo One more version check
exec "$0"

elapsed_time=$(( SECONDS - start_time ))
formatted_elapsed=$(date -u -d @"$elapsed_time" +"%T")
message_color=2960177
time_utc=$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")
report_message=$(cat <<EOM
{"embeds":[{"title":"Stats","description": "Elapsed time: ${formatted_elapsed}","color": ${message_color},"footer":
{"text":"Sent at"},"timestamp":"${time_utc}"}]}
EOM
)
curl -H "Content-Type: application/json" -d "$report_message" -X POST "$report_url"

