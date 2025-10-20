# Citrix Workspace App for Void Linux

Build Citrix Workspace app (ICA Client) packages for Void Linux from official Citrix `.deb` files.

## Prerequisites

1. **void-packages** repository:
   ```bash
   git clone https://github.com/void-linux/void-packages.git ~/void-packages
   cd ~/void-packages
   ./xbps-src binary-bootstrap
   ```

2. **Citrix ICA Client .deb file**
   Download from: https://www.citrix.com/downloads/workspace-app/linux/
   (Requires free Citrix account)

3. **Enable restricted packages** (if not already done):
   ```bash
   echo XBPS_ALLOW_RESTRICTED=yes >> ~/void-packages/etc/conf
   ```

## Usage

```bash
VOID_PACKAGES_DIR=/path/to/void-packages ./build-xbps.sh icaclient.deb
```

Enable the log service (optional):
```bash
sudo ln -s /etc/sv/ctxcwalogd /var/service/
```

## Uninstall

```bash
sudo xbps-remove icaclient
```

## Version

Current template: **25.08.0.88**

To build a different version, just run the build script with the new `.deb` file - it auto-detects the version.

This packaging is provided for convenience following Void Linux packaging standards.
