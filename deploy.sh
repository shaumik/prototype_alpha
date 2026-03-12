#!/bin/bash
set -e

echo "Starting Godot Web export..."

# Ensure build directory exists
mkdir -p build

# Run Godot headless export for Web
~/Downloads/Godot.app/Contents/MacOS/Godot --headless --export-release "Web" build/index.html

echo "Export completed. Updating gh-pages branch..."

# Save the current branch name
CURRENT_BRANCH=$(git branch --show-current)

# Move build to a temporary directory outside the repo so it survives git clean
rm -rf /tmp/godot_web_build
mv build /tmp/godot_web_build

# Check if gh-pages branch exists locally, create it if not
if ! git rev-parse --verify gh-pages >/dev/null 2>&1; then
    echo "Creating gh-pages orphan branch..."
    git checkout --orphan gh-pages
    git rm -rf .
    git commit --allow-empty -m "Initial gh-pages commit"
else
    echo "Checking out existing gh-pages branch..."
    git checkout gh-pages
fi

# We are on the gh-pages branch now. 
# Clean out everything except the git files to pull fresh from build/
git rm -rf . || true
git clean -fdx

# Bring over the files from the temporary directory
cp -r /tmp/godot_web_build/* ./

# Ensure godot cross-origin headers are not blocked by jekyll (if needed via .nojekyll)
touch .nojekyll

# Add and commit the new build files
git add .
git commit -m "Deploy Web Build $(date +'%Y-%m-%d %H:%M:%S')"

# Push to remote. Force push in case of timeline divergence,
# though it shouldn't usually diverge if we strictly maintain the deployment branch this way.
echo "Pushing to remote origin gh-pages..."
git push origin gh-pages --force

echo "Deployment complete! Returning to previous branch."
git checkout $CURRENT_BRANCH
