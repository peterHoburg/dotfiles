# TODO
Marking

# Files
ctr-p opens fuzzy searching

# File manager Vinigar
'-' open file manager

# Foulding
zR opens any fold
zo opens fold with cursor over

# Auto compolete
ctr-n completes nam

# System clipboard
"+p paste
"+y copy

# git
git status
git add .
git commit
git push

# vim
# in the same buffer (file)
:sp hosrizontal
:vs vertival
sp-tn new vim tab
gt switch tab
gT switch tab back
sp-% open vertival with file explorer
sp-" open horizontal with file explorer


# tmux
# Windows (tabs)
c  create window
w  list windows
n  next window
p  previous window
f  find window
,  name window
&  kill window
Panes (splits)
%  vertical split
"  horizontal split

# Pains
o  swap panes
q  show pane numbers
x  kill pane
+  break pane into window (e.g. to select text by mouse to copy)
-  restore pane from window
⍽  space - toggle between layouts
<prefix> q (Show pane numbers, when the numbers show up type the key to goto that pane)
<prefix> { (Move the current pane left)
<prefix> } (Move the current pane right)
<prefix> z toggle pane zoom


# rsync
rsync -a -v -z -h -r -e "ssh -i ~/.ssh/dev-systems.pem" ./ <ssh_user@ssh_location>:<destination_dir>

# Terminal
## fzf
CTRL + t
CTRL + r
