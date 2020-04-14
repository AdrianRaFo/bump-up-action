
#Args
set -u
VERSION_FILE=$1
VERSION_KEY=$2
VERSION_VALUE=$3

if [[ "$VERSION_VALUE" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  IS_RELEASE=true
else
  IS_RELEASE=false
fi

echo "::set-env name=IS_RELEASE::$IS_RELEASE"

# Bump up

if [[ $IS_RELEASE == 'true' ]]; then
  VERSION_PATCH=$(echo "$VERSION_VALUE" | awk -F"." '{print $NF}')
  NEXT_PATCH=$(($VERSION_PATCH + 1))
  ROOT_UNTIL=$(echo "$VERSION_VALUE" | awk -F "." '{print length($0)-length($NF)}')
  VERSION_ROOT=$(echo "$VERSION_VALUE" | cut -c 1-$ROOT_UNTIL)
  NEXT_VERSION="$VERSION_ROOT$NEXT_PATCH-SNAPSHOT"
  sed -i -e "s/$VERSION_KEY=$VERSION_VALUE/$VERSION_KEY=0.0.2-SNAPSHOT/" "$VERSION_FILE"
  echo "Setting next version $NEXT_VERSION"
  echo "::set-output name=next_version::$NEXT_VERSION"
else
  echo "Bump-up will not be executed, the version is a SNAPSHOT or has a bad format"
fi