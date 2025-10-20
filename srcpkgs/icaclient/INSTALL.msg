Citrix Workspace app (ICA Client) has been installed.

IMPORTANT NOTES:

1. The main Citrix installation is located at:
   /opt/Citrix/ICAClient

2. To use Citrix Workspace app, you may need to configure SSL certificates:
   Certificates are located in /opt/Citrix/ICAClient/keystore/cacerts

3. The ctxcwalogd service (Citrix log daemon) has been automatically
   enabled and started.

4. Desktop integration files have been installed. You should find Citrix
   applications in your desktop environment's application menu.

5. To connect to a Citrix server, you can:
   - Use the desktop applications (Self-Service, Workspace, etc.)
   - Use the command line: /opt/Citrix/ICAClient/wfica <connection-file>

6. If you encounter SSL/TLS certificate issues, you may need to install
   additional CA certificates in /opt/Citrix/ICAClient/keystore/cacerts/

7. Some features may require additional configuration. Refer to Citrix
   documentation for advanced setup.

For more information, visit:
https://docs.citrix.com/
