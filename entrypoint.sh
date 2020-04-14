
#Args
set -u
VERSION_FILE=$1
VERSION_KEY=$2

FILE_VERSION=$(cat "$VERSION_FILE" | grep "$VERSION_KEY" | cut -d'=' -f2)
VERSION_VALUE=$(echo "$FILE_VERSION" | tr -d '[:space:]')

if [[ "$VERSION_VALUE" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  IS_RELEASE=true
else
  IS_RELEASE=false
fi

if [[ "$VERSION_VALUE" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-(M|RC)[0-9]+)$ ]]; then
  IS_PRE_RELEASE=true
else
  IS_PRE_RELEASE=false
fi

echo "::set-env name=VERSION_VALUE::$VERSION_VALUE"
echo "::set-env name=IS_RELEASE::$IS_RELEASE"
echo "::set-env name=IS_PRE_RELEASE::$IS_PRE_RELEASE"

# Bump up

if [[ $IS_RELEASE == 'true' ]]; then
  VERSION_PATCH=$(echo "$VERSION_VALUE" | awk -F"." '{print $NF}')
  NEXT_PATCH=$(($VERSION_PATCH + 1))
  ROOT_UNTIL=$(echo "$VERSION_VALUE" | awk -F "." '{print length($0)-length($NF)}')
  VERSION_ROOT=$(echo "$VERSION_VALUE" | cut -c 1-$ROOT_UNTIL)
  NEXT_VERSION="$VERSION_ROOT$NEXT_PATCH-SNAPSHOT"
  sed -i -e "s/$VERSION_KEY=$FILE_VERSION/$VERSION_KEY=$NEXT_VERSION/" "$VERSION_FILE"
  echo "Setting next version $NEXT_VERSION"
  echo "::set-output name=next_version::$NEXT_VERSION"
elif [[ $IS_PRE_RELEASE == 'true' ]]; then
  VERSION_PATCH=$(echo "$VERSION_VALUE" | awk -F"." '{print $NF}' | awk -F"-" '{print $1}')
  NEXT_PATCH=$(($VERSION_PATCH + 1))
  ROOT_UNTIL=$(echo "$VERSION_VALUE" | awk -F "." '{print length($0)-length($NF)}')
  VERSION_ROOT=$(echo "$VERSION_VALUE" | cut -c 1-$ROOT_UNTIL)
  NEXT_VERSION="$VERSION_ROOT$NEXT_PATCH-SNAPSHOT"
  sed -i -e "s/$VERSION_KEY=$FILE_VERSION/$VERSION_KEY=$NEXT_VERSION/" "$VERSION_FILE"
  echo "Setting next version $NEXT_VERSION"
  echo "::set-output name=next_version::$NEXT_VERSION"
else
  echo "Bump-up will not be executed, the version is a SNAPSHOT or has a bad format"
fi