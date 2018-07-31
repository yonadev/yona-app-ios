FABRIC_APIKEY_FILE="$FABRIC_API_KEY"
FABRIC_BUILDSECRET_FILE="$FABRIC_BUILD_SECRET"

if test ! -f "$FABRIC_APIKEY_FILE" -o ! -f "$FABRIC_BUILDSECRET_FILE"; then
# Let the build fail
exit 1
fi

FABRIC_APIKEY=$(cat "$FABRIC_APIKEY_FILE")
if test $? -ne 0; then
echo "Cannot read $FABRIC_APIKEY_FILE"
exit 1
fi

FABRIC_BUILDSECRET=$(cat "$FABRIC_BUILDSECRET_FILE")
if test $? -ne 0; then
echo "Cannot read $FABRIC_BUILDSECRET_FILE"
exit 1
fi

echo "Uploading dSYM files to Crashlytics"
"${PODS_ROOT}/Fabric/run" "$FABRIC_APIKEY" "$FABRIC_BUILDSECRET"
