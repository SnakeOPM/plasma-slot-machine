#!/bin/bash
# Копируем виджет в рабочую папку
cp -r ~/.local/share/plasma/plasmoids/onedarmbandit/* ~/plasma-slot-machine/
cd ~/plasma-slot-machine
git add .
git commit -m "Update widget: $(date +%Y-%m-%d)"
git push origin main
echo "✅ Widget updated on GitHub!"
