/2010/09/using-git-to-deploy-website.html

Using Git to Deploy a Website
I use git at work and I think it's a fantastic version control system.  I've also been using it on some personal projects and I've written a post-receive hook that is very useful for managing simple web applications.  Once configured, you can deploy to a staging server and/or a production server by simply running git-push.  Skim down to Step 4 if you need an example to be convinced.

This script is great for a simple site with the following requirements:
Site can be updated by hosting contents in a symlinked directory.  When the symlink is updated to point to a different directory, the website updates without a server restart.  This is basically how Capistrano works... a PHP website is a good example where this works.
You want to immediately update a staging server with you latest git push and update a production server with specific tagged commits.
You can configure two different urls such as http://staging.yourdomain.com -> /path/to/staging and http://www.yourdomain.com -> /path/to/current.  This is easy to do on a hosting service like DreamHost.
You have SSH keys enabled so you can easily connect to your server.
You're lazy and you want a script to do all your deployment work.
Assumptions:
You're comfortable using git.
You've read the man pages for git-push, git-pull, git-tag, git-status and git-diff.  (Can't hurt to read all the git man pages... there aren't that many.)
You know how to use an .htaccess file to prevent anyone from seeing the contents of your git repo or the data directory we'll create.  In my apache configuration, I use "RewriteRule ^.git.*$ - [F]" and "RewriteRule ^data.*$ - [F]".
Step 1:

Create a directory that we'll call /path/to for the rest of this post.

Configure your server to host a staging url from /path/to/staging and a production url from /path/to/current.  We'll create the contents of those directories in step 3.

Step 2:

Create the git repo on your server:
cd /path/to
mkdir repo
cd repo
git init --bare
cd hooks
wget http://www.tonyscelfo.com/git/post-receive
chmod u+x post-receive
Step 3:

Clone the repo on your local machine:
git clone -b master <user>@<hostname>:/path/to/repo (On the initial empty checkout, you will see: "warning: You appear to have cloned an empty repository."  Once we push, you won't see that again if/when you clone to other local machines.)
cd
mkdir data
echo "p0" > data/live
git add data/live
git commit -a -m "initial commit to create valid repo"
git tag p0
git push origin +master:refs/heads/master --tags
You will now have the following on your server:
/path/to/repo (a bare git repo)
/path/to/staging (contains the latest code)
/path/to/current -> /path/to/p0
/path/to/p0 (the directory containing what we tagged as p0)
Step 4 (repeat for as long as you work on the project):

Work on your site and push to staging:
work, work, work
git commit
git push
repeat
Every time you push, the staging directory will be updated immediately.  When you want to promote to production, do the following:
Checkout the appropriate commit if its not the current HEAD
git tag <tag_name> to tag your repo with a release name
Edit the contents of data/live to contain <tag_name>
git push --tags to push the tags and trigger the update to the current symlink
If you ever want to rollback, you can simply:
Run git tag -n to see a list of all the previous release tags with annotations
Edit the contents of data/live to contain <tag_name> of the previous release
Run git push to push and trigger the update to the current symlink.  (You don't need to push the tags when doing a rollback because you had previously pushed the tag definition to the git repo.)
Enjoy.  If you use this script, please comment with feedback!
