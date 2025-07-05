# arch-deploy

### APPROACH
- i wrote many deployement script and they all had the same fundamental issue : they where too specific, repetitive and not modular enough
- the main issue is that these script where hard to adapt overtime for a student learning new tools everyday
- the approach for this script is to focus on few but curated features
- a config file allows the user to leverage these features
- idempotency is also at the center of the design for this script
- theoretically, you should be able to change your DE, all the programs and services you use without having to ever touch the script

### FEATURES
- install packages by groups (eg: desktop_apps, virtualization, audio_stack)
- install packages from third-party package managers (flatpak, pip, cargo, npm)
- setup firewall rules
- install your dotfiles
- control systemd services
- handle permissions
- download your personal repos

### TODO
