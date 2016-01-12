#!/bin/bash

source ~/.bash_profile

# Create the database.
createdb {{cookiecutter.package_name}}

# Make the virtual environment.
if [ -z "$CI" ]; then

    {
        mkvirtualenv {{cookiecutter.repo_name}} && workon {{cookiecutter.repo_name}}
    } || {
        virtualenv -p python .venv && source .venv/bin/activate
    }
fi

# If GeoIP wasn't enabled, delete the GeoIP folder.
cat requirements.txt

if ! grep -iq GeoIP "requirements.txt"; then
    echo "Removing GeoIP folder";
    rm -rf {{cookiecutter.package_name}}/geoip/
fi

# Install Python dependencies.
if [ -z "$CI" ]; then
    pip install --upgrade pip
fi

# Remove anything which doesn't work on Python 3.
if [ "$(python -c 'import sys; print(sys.version_info[0])')" == "3" ]; then
    {% for requirement in ['onespacemedia-server-management'] %}
        perl -pi -e s,{{requirement}},,g requirements.txt
    {% endfor %}

    perl -pi -e s,python-memcached,python3-memcached,g requirements.txt
fi

pip install -r requirements.txt

# The requirements will now have versions pinned, so re-dump them.
pip freeze > requirements.txt

# We disable rendering of the templates folder to avoid having to wrap everything in
# raw tags, but that causes the parent directory path to also not be parse, so we need
# to move everything into the correct location, then remove the old parent directory.
mv {{ "{{" }}cookiecutter.package_name{{ "}}" }}/templates {{cookiecutter.package_name}}/templates
mv {{ "{{" }}cookiecutter.package_name{{ "}}" }}/assets {{cookiecutter.package_name}}/assets
rmdir {{ "{{" }}cookiecutter.package_name{{ "}}" }}

# Move the project app folders into the correct locations.
if [ -d "tmp" ]; then
    mv tmp/*/apps/* {{cookiecutter.package_name}}/apps/
    mv tmp/*/templates/* {{cookiecutter.package_name}}/templates/

    # Remove the tmp directory.
    rm -rf tmp/

    # Replace the project_name variable in the external apps.
    perl -pi -e 's/{{ "{{" }} project_name {{ "}}" }}/{{ cookiecutter.package_name }}/g' `grep -ril "{{ "{{" }} project_name {{ "}}" }}" *`
fi

# Generate a secret key and update the base settings file.
perl -pi -e s,SECRET_KEY\ =\ \"\ \",SECRET_KEY\ =\ \"$(printf '%q' $(./manage.py generate_secret_key))\",g {{cookiecutter.package_name}}/settings/base.py

# Install front-end dependencies.
npm install -g webpack
npm install
webpack

# The following commands don't need to be run under CI.
if [ -z "$CI" ]; then

    # Create a git repo and configure it for git flow.
    git init

    # If Git flow isn't installed, install it. This isn't optional.
    if ! which -s git-flow; then
        brew install git-flow
    fi

    git flow init -d

    # Add all of the project files to a Git commit and push to the remote repo.
    git add .
    git commit -am "Initial commit."

    # We can't push yet because we don't have a remote..
    # git push
fi
