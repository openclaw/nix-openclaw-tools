{ runCommand, imsg, peekaboo }:

runCommand "macos-runtime-assets" {} ''
  test -s ${imsg}/bin/PhoneNumberKit_PhoneNumberKit.bundle/Contents/Resources/PhoneNumberMetadata.json
  test -s ${imsg}/bin/SQLite.swift_SQLite.bundle/Contents/Resources/PrivacyInfo.xcprivacy
  test -s ${imsg}/bin/imsg-bridge-helper.dylib
  test -s ${peekaboo}/bin/libswiftCompatibilitySpan.dylib
  ${imsg}/bin/imsg --version
  ${peekaboo}/bin/peekaboo --version
  touch "$out"
''
