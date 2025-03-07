#!/bin/sh

#
# Copyright © 2015-2021 the original authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

##############################################################################
#
#   Custom start up script for POSIX-like systems.  Adapted from Gradle's original.
#
#   Key Points:
#
#   (1) Requires a POSIX-compliant shell.  Ensure your /bin/sh meets requirements,
#       or specify a compliant shell (e.g., ksh, bash) before the command:
#
#           ksh PZModMenu
#
#       Simplified shells might lack essential features.
#
#   (2) Avoids Bash/Ksh extensions for broad compatibility.  Uses POSIX features only.
#       Minimizes space-separated strings to prevent bugs/security issues.
#
#   (3)  This is a customized script, adapted from a Gradle template.
#
##############################################################################

# Determine installation directory

# Follow symbolic links
executable_path=$0

# Handle chained symlinks.
while
    INSTALL_DIR=${executable_path%"${executable_path##*/}"}  # Directory containing the executable
    [ -h "$executable_path" ]
do
    link_info=$( ls -ld "$executable_path" )
    target_path=${link_info#*' -> '}
    case $target_path in
      /*)   executable_path=$target_path ;;
      *)    executable_path=$INSTALL_DIR$target_path ;;
    esac
done

# Setup environment variables

# Default values
APP_NAME="PZModMenu" # Name of application
DEFAULT_JVM_OPTIONS="-Xmx2g -Xms512m" # Standard memory settings
APP_CLASSPATH="lib/*" # Location of JAR files

# Allow overrides via environment variables
INSTALL_DIR=$(cd "$INSTALL_DIR" && pwd) # Get the absolute path
export INSTALL_DIR  #make it accesible

# Function to split a string into words, respecting quotes. (primitive alternative to arrays)
split_words() {
  local IFS="$1" string="$2"
  for word in $string; do
    echo "$word"
  done
}

# Collect JVM options
JVM_OPTIONS=()

# Incorporate DEFAULT_JVM_OPTS if defined, splitting on spaces
if [ -n "$DEFAULT_JVM_OPTS" ]; then
  for opt in $(split_words " " "$DEFAULT_JVM_OPTS"); do
        JVM_OPTIONS+=("$opt")
  done
fi

# Incorporate JAVA_OPTS if defined, splitting on spaces
if [ -n "$JAVA_OPTS" ]; then
   for opt in $(split_words " " "$JAVA_OPTS"); do
        JVM_OPTIONS+=("$opt")
  done
fi

# Incorporate PZModMenu_OPTS if defined, splitting on spaces
if [ -n "$PZModMenu_OPTS" ]; then
    for opt in $(split_words " " "$PZModMenu_OPTS"); do
        JVM_OPTIONS+=("$opt")
    done
fi


# Java invocation

# Construct the classpath
CLASSPATH="$INSTALL_DIR/$APP_CLASSPATH"

# Locate the Java executable.  Prioritize JAVA_HOME if defined
if [ -n "$JAVA_HOME" ]; then
    JAVA="$JAVA_HOME/bin/java"
else
    JAVA=$(which java)
    if [ -z "$JAVA" ]; then
        echo "Error: Java not found.  Please set JAVA_HOME or ensure Java is in your PATH."
        exit 1
    fi
fi

# Execute the Java application. Added '-Dfile.encoding=UTF-8' to JVM opts
exec "$JAVA" -Dfile.encoding=UTF-8 "${JVM_OPTIONS[@]}" -cp "$CLASSPATH" com.pzmodmenu.Main "$@"
