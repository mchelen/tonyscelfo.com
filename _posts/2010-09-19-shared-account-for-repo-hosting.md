/2010/09/shared-account-for-repo-hosting.html

Shared Account for Repo Hosting
SSH keys can be used to share a single account to host a git or subversion repo.  Putting the SSH keys into the ~/.ssh/authorized_keys file will give users full access to the shared account.  A better and safer way to share the account is to restrict access to only the commands needed for either git or svn.

For git, you can put the following at the beginning of each key line in the ~/.ssh/authorized_keys file:
command="git-shell -c \"$SSH_ORIGINAL_COMMAND\"",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty

For svn, you can replace <user> with the name of the user you'd like to have the commits logged as for svn log and svn blame accounting and put the following at the beginning of each line in the ~/.ssh/authorized_keys file:
command="/usr/bin/svnserve -t --tunnel-user=<user>",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty
