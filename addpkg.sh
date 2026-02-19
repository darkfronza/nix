#!/bin/bash

[ $# -lt 2 ] && {
    echo "usage: $0 <package_name> <version>"
    exit 1
}

pkg="$1"
version="$2"
pkg_with_version="${pkg}-${version}"
nix_entry="pkgs.callPackage ./pkgs/${pkg}/${pkg}-${version}.nix { }"

if ! grep -Eqs "${pkg_with_version}[[:blank:]]*=" default.nix; then
    echo "Adding new package entry to default.nix: pkg=$pkg  version=$version"

    sed -i "" "/<package-list>/a\\
  ${pkg_with_version} = ${nix_entry}" default.nix
fi

# patch default package name to point to the latest version
if ! grep -Eqs "${pkg}[[:blank:]]*=" default.nix; then
    echo "Adding default $pkg package entry..."
    sed -i "" "/<package-list>/a\\
  ${pkg} = ${nix_entry}" default.nix
else
    echo "Updating $pkg to point to new version $version"
    sed -i "" "s#^.*${pkg} *=.*\$#  ${pkg} = ${nix_entry}#" default.nix
fi
