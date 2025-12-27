# fedora-fixmyshit - Fedora 43 System Setup

I needed to upgrade several machines to Fedora 43 (my PC, a mini PC, and my kids’ PC), so I put together this setup to make the process repeatable.

The goal is simple: get a fresh Fedora 43 install configured the way I like it with one consistent, idempotent set of scripts. When I set up a new machine later, I can install and configure everything in minutes instead of redoing the same manual steps.

If you find this useful, feel free to fork it and change anything to match your own needs.

## 🚀 Quick Start

```bash
# Clone this repository
git clone <your-repo-url> ~/fedora-fixmyshit
cd ~/fedora-fixmyshit

# Make scripts executable
chmod +x setup.sh scripts/*.sh

# Run the setup wizard (will prompt for sudo password)
./setup.sh
```

### What to Expect

`setup.sh` is an interactive wizard. You can:

- **Quick Setup**: install everything this rig supports
- **Custom Setup**: pick only the components you want
- **View Components**: see what each component does before installing

Note: the scripts in `scripts/` are designed to be **sourced by the wizard**. If you want to run one manually, use `source scripts/<name>.sh` (not `./scripts/<name>.sh`).

## 📋 What This Does

This repository automates the setup of a fresh Fedora 43 installation with:

- **Shell + Prompt**: Zsh + Starship
- **Editor**: Neovim + LazyVim starter config
- **Fonts**: Nerd Fonts (JetBrainsMono / Victor Mono / FiraCode)
- **Languages/Tooling**: uv (Python), nvm (Node LTS), rustup (Rust), Go
- **Containers**: Docker + LazyDocker
- **Apps**: Flatpak + a small curated list of Flatpak apps
- **AI Tooling**: OpenCode (opencode.ai)
- **CLI utilities**: common terminal tools (ripgrep, bat, btop, zellij, etc.)
- **Git**: installs Git and sets global config (name/email/editor)
- **SSH**: imports SSH keys/config from `dotfiles/.ssh`

The setup is intended to be safe to re-run (it will skip things that are already installed/configured).

## 📁 Repository Structure

```
fedora-fixmyshit/
├── README.md
├── setup.sh
├── scripts/
│   ├── ai.sh
│   ├── docker.sh
│   ├── flatpak.sh
│   ├── git.sh
│   ├── golang.sh
│   ├── neovim_lazyvim.sh
│   ├── nerdfonts.sh
│   ├── nvm.sh
│   ├── rust.sh
│   ├── ssh.sh
│   ├── utils.sh
│   ├── uv.sh
│   └── zsh.sh
└── dotfiles/
	└── .ssh/   # Optional: keys/config to import into ~/.ssh
```

## 🔧 Customization

### Before First Run

Common things you’ll probably want to change:

1. **Git identity**: update the defaults in `scripts/git.sh` (name/email)
2. **Flatpak apps**: edit the `APPS=(...)` list in `scripts/flatpak.sh`
3. **SSH import**: add/remove files under `dotfiles/.ssh/` (or leave it empty to skip)

### Adding Your Own Scripts

Add custom scripts to the `scripts/` directory and wire them into `setup.sh`:

```bash
# In setup.sh
source scripts/your-custom-script.sh
```

## 🧰 Running Individual Components

The supported way is to run the wizard and pick components. If you really want to run just one piece, source it:

```bash
source scripts/flatpak.sh
source scripts/utils.sh
```

## 📦 What Gets Installed (Source of Truth)

The exact packages/tools are defined in the component scripts under `scripts/`.

- Flatpak app list: `scripts/flatpak.sh`
- Utility tools list: `scripts/utils.sh`
- Fonts: `scripts/nerdfonts.sh`
- Language runtimes/toolchains: `scripts/uv.sh`, `scripts/nvm.sh`, `scripts/rust.sh`, `scripts/golang.sh`
- Docker: `scripts/docker.sh`

## 🎯 Post-Installation

After running the setup:

1. **Log out and log back in** (the wizard will remind you)
2. **Confirm your Git identity** if you didn’t customize `scripts/git.sh`
3. **SSH**: verify `~/.ssh` permissions and that your keys/config are correct

## 🔒 Security Notes

- Never commit sensitive data (passwords, API keys, tokens)
- Use `.gitignore` for private configuration files
- Review scripts before running them

## 🆘 Troubleshooting

### Script Fails Midway
The scripts are designed to be idempotent - you can safely re-run them.

### Permission Denied
Make sure scripts are executable:
```bash
chmod +x setup.sh scripts/*.sh
```

### Package Not Found
Update your package lists:
```bash
sudo dnf check-update
```

## 🤝 Contributing

Feel free to fork this repository and customize it for your needs!

## 📝 License

MIT License - Feel free to use and modify as needed.

## 🔄 Maintenance

Keep this repository updated as you refine your setup:

```bash
# After making changes
git add .
git commit -m "Update configuration"
git push
```

---

**Last Updated**: December 2025  
**Fedora Version**: 43  
**Desktop Environment**: GNOME (customize for your DE)
