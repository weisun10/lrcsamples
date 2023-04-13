## Samples
The **Public APIs samples** folder has some sample PowerShell scripts about using LoadRunner Cloud Public APIs.
For authentication, it demonstrates both username/password and API access keys.

## FAQ

**Q: Error: "invoke-restmethod : the request was aborted: could not create ssl/tls secure channel"**  
**A:** Try to set TLS version. For example: [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12  

**Q: Error: "invoke-restmethod : the servicepointmanager does not support proxies with the https scheme"**     
**A:** Sample codes use proxy. If it's not needed in your environment, remove those proxy related codes.
