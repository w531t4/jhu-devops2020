#!/bin/bash

# credit to this user who submitted the script
#https://gist.github.com/michaellihs/5ef5e8dbf48e63e2172a573f7b32c638

# minor modifications made by Aaron White to grab more than just api rights.


gitlab_host="http://localhost:10080"
gitlab_user="root"
gitlab_password="adminadmin"

# 1. curl for the login page to get a session cookie and the sources with the auth tokens
body_header=$(curl -c cookies.txt -i "${gitlab_host}/users/sign_in" -s)

# grep the auth token for the user login for
#   not sure whether another token on the page will work, too - there are 3 of them
csrf_token=$(echo $body_header | perl -ne 'print "$1\n" if /new_user.*?authenticity_token"[[:blank:]]value="(.+?)"/' | sed -n 1p)

# 2. send login credentials with curl, using cookies and token from previous request
curl -b cookies.txt -c cookies.txt -i "${gitlab_host}/users/sign_in" \
	--data "user[login]=${gitlab_user}&user[password]=${gitlab_password}" \
	--data-urlencode "authenticity_token=${csrf_token}"

# 3. send curl GET request to personal access token page to get auth token
body_header=$(curl -H 'user-agent: curl' -b cookies.txt -i "${gitlab_host}/profile/personal_access_tokens" -s)
csrf_token=$(echo $body_header | perl -ne 'print "$1\n" if /authenticity_token"[[:blank:]]value="(.+?)"/' | sed -n 1p)

# 4. curl POST request to send the "generate personal access token form"
#      the response will be a redirect, so we have to follow using `-L`
body_header=$(curl -L -b cookies.txt "${gitlab_host}/profile/personal_access_tokens" \
	--data-urlencode "authenticity_token=${csrf_token}" \
	--data 'personal_access_token[name]=golab-generated&personal_access_token[expires_at]=&personal_access_token[scopes][]=api&personal_access_token[scopes][]=read_user&personal_access_token[scopes][]=read_api&personal_access_token[scopes][]=read_repository&personal_access_token[scopes][]=write_repository&personal_access_token[scopes][]=read_registry&personal_access_token[scopes][]=write_registry&personal_access_token[scopes][]=sudo')

# 5. Scrape the personal access token from the response HTML
personal_access_token=$(echo $body_header | perl -ne 'print "$1\n" if /created-personal-access-token"[[:blank:]]value="(.+?)"/' | sed -n 1p)
echo "token=${personal_access_token}"
