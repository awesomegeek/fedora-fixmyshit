#!/bin/bash

# Docker + LazyDocker installation script for Fedora 43
# Docker install: https://docs.docker.com/engine/install/fedora/
# LazyDocker: https://github.com/jesseduffield/lazydocker#installation

set -e  # Exit on error

echo "=========================================="
echo "Installing Docker + LazyDocker"
echo "=========================================="

is_sourced() {
    [[ "${BASH_SOURCE[0]}" != "${0}" ]]
}

fail() {
    local msg="$1"
    echo "$msg" >&2
    if is_sourced; then
        return 1
    fi
    exit 1
}

ensure_pkg() {
    local pkg="$1"
    if rpm -q "$pkg" >/dev/null 2>&1; then
        return 0
    fi
    sudo dnf install -y "$pkg"
}

echo "Ensuring 'dnf config-manager' is available..."
if dnf config-manager --help >/dev/null 2>&1; then
    :
else
    # Fedora dnf4 uses dnf-plugins-core; Fedora dnf5 uses dnf5-plugins.
    set +e
    if ! sudo dnf install -y dnf-plugins-core >/dev/null 2>&1; then
        sudo dnf install -y dnf5-plugins >/dev/null 2>&1 || true
    fi
    set -e

    if ! dnf config-manager --help >/dev/null 2>&1; then
        fail "dnf config-manager is not available (install dnf plugins and retry)."
    fi
fi

ensure_pkg curl
ensure_pkg tar

echo "Configuring Docker CE repository (idempotent)..."
if [ ! -f /etc/yum.repos.d/docker-ce.repo ]; then
    repo_url="https://download.docker.com/linux/fedora/docker-ce.repo"

    # dnf4: dnf config-manager --add-repo URL
    # dnf5: dnf config-manager addrepo --from-repofile=URL
    if sudo dnf config-manager --add-repo "$repo_url" >/dev/null 2>&1; then
        :
    elif sudo dnf config-manager addrepo --from-repofile="$repo_url" >/dev/null 2>&1; then
        :
    elif sudo dnf config-manager addrepo --from-repo="$repo_url" >/dev/null 2>&1; then
        :
    else
        fail "Failed to add Docker CE repo via dnf config-manager."
    fi
else
    echo "Docker repo already present, skipping..."
fi

echo "Installing Docker Engine packages..."
# Install in one shot; if already installed, dnf will skip
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

if ! command -v docker >/dev/null 2>&1; then
    fail "docker command not found after installation."
fi

echo "Enabling and starting Docker service..."
sudo systemctl enable --now docker

# Add current user to docker group for non-root usage
if getent group docker >/dev/null 2>&1; then
    if id -nG "$USER" | tr ' ' '\n' | grep -Fxq docker; then
        echo "User $USER is already in docker group, skipping..."
    else
        echo "Adding $USER to docker group..."
        sudo usermod -aG docker "$USER"
        echo "⚠️  Docker without sudo requires a new login session."
        echo "    - Recommended: log out and log back in"
        echo "    - Or for this terminal only: run 'newgrp docker'"
        echo "    - Or run a single command now: 'sg docker -c "\"docker ps\""'"
    fi
else
    echo "docker group not found (will rely on sudo for docker)."
fi

# Best-effort: ensure the docker socket is owned by docker group.
if [ -S /var/run/docker.sock ] && getent group docker >/dev/null 2>&1; then
    sudo chgrp docker /var/run/docker.sock >/dev/null 2>&1 || true
    sudo chmod 660 /var/run/docker.sock >/dev/null 2>&1 || true
fi

echo "Installing LazyDocker..."
if command -v lazydocker >/dev/null 2>&1; then
    echo "lazydocker already installed, skipping..."
else
    arch="$(uname -m)"
    case "$arch" in
        x86_64|amd64) asset_suffix="Linux_x86_64.tar.gz" ;;
        aarch64|arm64) asset_suffix="Linux_arm64.tar.gz" ;;
        *) fail "Unsupported architecture for lazydocker: $arch" ;;
    esac

    api_url="https://api.github.com/repos/jesseduffield/lazydocker/releases/latest"
    download_url="$(curl -fsSL "$api_url" | grep -Eo '"browser_download_url"\s*:\s*"[^"]+' | cut -d'"' -f4 | grep -F "$asset_suffix" | head -n 1)"

    if [ -z "$download_url" ]; then
        fail "Could not determine lazydocker download URL from GitHub releases."
    fi

    tmp_dir="$(mktemp -d)"
    tar_path="$tmp_dir/lazydocker.tar.gz"

    echo "Downloading lazydocker from: $download_url"
    curl -fsSL -o "$tar_path" "$download_url"

    tar -xzf "$tar_path" -C "$tmp_dir"

    if [ ! -f "$tmp_dir/lazydocker" ]; then
        fail "lazydocker binary not found in extracted archive."
    fi

    # Install system-wide (requires sudo)
    sudo install -m 755 "$tmp_dir/lazydocker" /usr/local/bin/lazydocker

    rm -rf "$tmp_dir"
fi

echo ""
docker --version || true
lazydocker --version || true

echo "✅ Docker + LazyDocker installation complete!"