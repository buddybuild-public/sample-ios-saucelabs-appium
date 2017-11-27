# Constants
ZIPPED_APP=/tmp/sandbox/workspace/zippedapp.zip

# Set up the custom reporting folders
mkdir -p /tmp/sandbox/workspace/buddybuild_artifacts/Appium

echo $'=== Building App for Simulator ==='

SIMULATOR_APP_PATH=$BUDDYBUILD_WORKSPACE'/sim_app'

# Build simulator app
xcodebuild -project "m2048.xcodeproj" \
    -scheme "$BUDDYBUILD_SCHEME" \
    -configuration "Debug" \
    -destination "platform=iOS Simulator,OS=11.0,name=iPhone 7" \
    -derivedDataPath $SIMULATOR_APP_PATH \
	CODE_SIGNING_REQUIRED=NO \
	CODE_SIGN_IDENTITY="" \
	CODE_SIGNING_ALLOWED=NO \
	ENABLE_BITCODE=NO \
	ONLY_ACTIVE_ARCH=YES \
	DEBUG_INFORMATION_FORMAT=dwarf-with-dsym

echo "=== Beginning upload of app to saucelabs ==="
# saucelabs expects the app to be zipped
zip -r $ZIPPED_APP $SIMULATOR_APP_PATH
curl -u $SAUCE_USERNAME:$SAUCE_ACCESS_KEY -X POST  \
	-H "Content-Type: application/octet-stream" \
	https://saucelabs.com/rest/v1/storage/$SAUCE_USERNAME/test_app.zip?overwrite=true \
	--data-binary @$ZIPPED_APP

echo "=== Completed upload of app to saucelabs ==="
brew install maven
cd tests

echo "=== Started test run ==="
mvn test

echo "=== Test Suite complete ==="
mv target/surefire-reports/*.xml /tmp/sandbox/workspace/buddybuild_artifacts/Appium
