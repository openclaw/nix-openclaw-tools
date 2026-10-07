{ runCommand, jq, wacli }:

runCommand "wacli-runtime" { nativeBuildInputs = [ jq ]; } ''
  ${wacli}/bin/wacli --version
  ${wacli}/bin/wacli --store "$TMPDIR/store" doctor --json > "$out"
  jq -e '.success == true and .data.fts_enabled == true and
    .data.authenticated == false and .data.connected == false and
    .data.store.messages == 0 and (.data.store_error // "") == ""' "$out"
  test -f "$TMPDIR/store/wacli.db"
  ${wacli}/bin/wacli --store "$TMPDIR/store" messages search smoke --json |
    jq -e '.success == true'
''
