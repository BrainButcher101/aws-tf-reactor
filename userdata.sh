#!/bin/bash
sudo yum -y update 2>&1
sudo yum -y git 2>&1
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash 2>&1
. ~/.nvm/nvm.sh 2>&1
nvm install --lts 2>&1
git clone ${repo_name} 2>&1
url=${repo_name}
reponame="$(echo $url | sed -r 's/.+\/([^.]+)(\.git)?/\1/')"
cd $reponame
npm install 2>&1
npm run dev 2>&1
