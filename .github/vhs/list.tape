##Prints List: soar list
##SELF: https://raw.githubusercontent.com/Azathothas/soar/refs/heads/main/.github/vhs/list.tape
#Setup ENV
Output list.gif
Require soar
Set Shell "bash"
Set WindowBar Colorful
Set Padding 0
Set PlaybackSpeed 1.5
#Set Theme "rose-pine"
Env PROMPT "➜ "
Env PS1 "➜ "
Sleep 500ms
#Actual CMD
Type@300ms "soar list"
Enter
Sleep 3s
Type@450ms "soar list | wc -l"
Enter
Sleep 4s
