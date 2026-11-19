#!/bin/sh
# À lancer avant chaque mise en ligne : change le numéro de version pour que les téléphones se mettent à jour tout seuls.
cd "$(dirname "$0")" || exit 1
V=$(date +%Y.%m.%d-%H%M)
sed -i "s/window.__APP_VER__=\"[^\"]*\"/window.__APP_VER__=\"$V\"/" index.html
sed -i "s/const CACHE = 'mgm-budget-[^']*'/const CACHE = 'mgm-budget-$V'/" sw.js
printf '{"v": "%s"}\n' "$V" > version.json
echo "Version $V"
