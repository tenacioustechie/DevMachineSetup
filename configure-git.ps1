# NOTE: do NOT run this as admin, it works better asking for admin on each install

git config --global pull.rebase true
git config --global core.autocrlf input
git config --global core.eol lf

# Set the default branch name for new repositories
git config --global init.defaultBranch main

# Set the default editor
git config --global core.editor "code --wait"

# Set the default diff and merge tool
git config --global merge.tool kdiff3
git config --global diff.tool kdiff3

# powershell prompt for persons Name and Email
Write-Host "Please enter your name and email for git"
$Name = Read-Host -Prompt "Enter your first and last name"
$Email = Read-Host -Prompt "Enter your work email"
# set name and email
git config --global user.name $Name
git config --global user.email $Email
