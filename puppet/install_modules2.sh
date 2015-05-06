
# "forge" modules
cat Puppetfile | grep "^mod" | grep -v "https://" | grep -v ":git =>" | awk '{ print $2 }' | sed 's/,//g' | while read module; do
  echo "puppet module install --ignore-dependencies ${module} --modulepath=modules" | bash
done

# "external" modules
cat Puppetfile | grep "^mod" | grep ":git =>" | grep -E 'https://|git@' | awk '{ print $5 " " $2 }' | sed 's/,//g' | awk -F\' '{print $2 " " $4}' | while read source destination; do
  if [ ! -d "modules/${destination}" ]; then
    echo "git clone ${source} modules/${destination}" | bash
  fi
done
