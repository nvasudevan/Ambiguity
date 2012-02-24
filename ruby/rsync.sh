echo "rsync to mac"
rsync -r -e ssh *.sh mac:~/codespace/ruby/
rsync -r -e ssh /logs/*.sh mac:/logs/
rsync -r -e ssh *.rb mac:~/codespace/ruby/
rsync -r -e ssh build mac:~/codespace/ruby/
#rsync -r -e ssh --delete grammars mac:~/codespace/ruby/

echo "rsync to grammatix"
rsync -r -e ssh *.sh grammatix:~/codespace/ruby/
rsync -r -e ssh /logs/*.sh grammatix:/logs/
rsync -r -e ssh *.rb grammatix:~/codespace/ruby/
rsync -r -e ssh build grammatix:~/codespace/ruby/
#rsync -r -e ssh --delete grammars sambardude:~/codespace/ruby/
