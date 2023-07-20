#!/bin/bash
red=$'\e[1;31m'
end=$'\e[0m'

# usage:
# put svg files and source code for visualization into src/assets/example_dir

set -e

# copy book.js to theme/
mkdir -p "./theme"
cp mdbook_plugin/book.js theme/book.js

if ! [[ -d "src" ]]; then
    mkdir src
fi

# clear assets and md files to mdbook directory
rm -f src/*md

# Write the first line of SUMMARY.md. This clears anything that was there previously
printf "# Summary\n\n" > src/SUMMARY.md

printf "Generating visualizations for the following examples: \n"

INPUT="./src/assets"
# Loop through the specified examples
for dir in "$INPUT"/*; do
    if [ -d "$dir" ]; then 
        # Add append corresponding line to SUMMARY.md
        target=$(basename "$dir")
        echo "- [$target](./$target.md)" >> src/SUMMARY.md
        echo "done"

        # Write into .md files
        printf "### %s\n\n" "$target" >> src/$target.md
        printf "\`\`\`rust\n" >> src/$target.md
        printf "{{#rustdoc_include assets/%s/source.rs}}\n" "$target" >> src/$target.md
        printf "\`\`\`\n" >> src/$target.md
        printf '<div class="flex-container vis_block" style="position:relative; margin-left:-75px; margin-right:-75px; display: flex;">\n' >> src/$target.md
        printf '\t<object type="image/svg+xml" class="%s code_panel" data="assets/%s/vis_code.svg"></object>\n' "$target" "$target">> src/$target.md
        printf '\t<object type="image/svg+xml" class="%s tl_panel" data="assets/%s/vis_timeline.svg" style="width: auto;" onmouseenter="helpers('"'"'%s'"'"')"></object>\n' "$target" "$target" "$target">> src/$target.md
        printf "</div>" >> src/$target.md
    fi
done

# Build mdbook
mdbook build

# Run HTTP server on docs directory
mdbook serve -p 8000
