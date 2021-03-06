# VERSION 6 - DO NOT REMOVE THIS LINE
#==============================================================================
# Copyright (C) 2019-present Alces Flight Ltd.
#
# This file is part of Flight Directory.
#
# This program and the accompanying materials are made available under
# the terms of the Eclipse Public License 2.0 which is available at
# <https://www.eclipse.org/legal/epl-2.0>, or alternative license
# terms made available by Alces Flight Ltd - please direct inquiries
# about licensing to licensing@alces-flight.com.
#
# Flight Directory is distributed in the hope that it will be useful, but
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, EITHER EXPRESS OR
# IMPLIED INCLUDING, WITHOUT LIMITATION, ANY WARRANTIES OR CONDITIONS
# OF TITLE, NON-INFRINGEMENT, MERCHANTABILITY OR FITNESS FOR A
# PARTICULAR PURPOSE. See the Eclipse Public License 2.0 for more
# details.
#
# You should have received a copy of the Eclipse Public License 2.0
# along with Flight Directory. If not, see:
#
#  https://opensource.org/licenses/EPL-2.0
#
# For more information on Flight Directory, please visit:
# https://github.com/openflighthpc/flight-directory
#==============================================================================
# vim: set filetype=apache :
#ALCES_META
# Refer to `clusterware/scripts/development/propagate`.
#path=/opt/directory/share/ipa-block.conf.tpl
#ALCES_META_END

RewriteEngine on

# Use suexec to run eject CGI script as ejector user with required permissions.
SuexecUserGroup ejector ejector
Alias /eject/ /var/www/eject/
<Directory "/var/www/eject">
    Options +ExecCGI
    SetHandler cgi-script
</Directory>

# The following 2 rules are adapted from similar rules in
# `./ipa-rewrite.conf.tpl`.

# Redirect direct HTTP requests from outside the VPC to the external hostname.
RewriteCond %{REMOTE_ADDR} !^_ESCAPED-DOMAIN-NETWORK-PREFIX_
RewriteCond %{REMOTE_ADDR} !^127\.0\.0\.1$
RewriteCond %{HTTP_HOST} !^_ESCAPED-EXTERNAL-NAME_$ [NC]
RewriteRule ^/(.*) http://_EXTERNAL-NAME_/$1 [L,R=302]

# Redirect to the secure port if not displaying an IPA error or retrieving
# configuration.
# We only do this if the request is not from the localhost proxy.
RewriteCond %{SERVER_PORT}  !^443$
RewriteCond %{REQUEST_URI}  !^/ipa/(errors|config|crl)
RewriteCond %{HTTP_HOST}    !^127\.0\.0\.1$
RewriteRule ^/(.*)      https://%{HTTP_HOST}/$1 [L,R=302,NC]

# Explicitly redirect all `/ipa` requests to prevent later `401 unauthorized`,
# except whitelist necessary for nodes to register.
RewriteCond %{REQUEST_URI}  !^/ipa/(errors|config|crl|json)
RewriteRule "^/ipa" "/" [R]

# Redirect all other, non-whitelisted requests to the directory landing site,
# preventing access to ipa site.
RewriteCond %{REQUEST_URI}  !^/ipa/(errors|config|crl|json)
RewriteCond %{REQUEST_URI} "!^/(directory|eject|secure)"
RewriteRule "^/(.*)$" "/directory/$1" [L]
