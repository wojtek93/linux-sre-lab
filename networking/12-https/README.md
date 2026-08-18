# NET-12 HTTPS and TLS

## Goal

Understand how HTTPS works, how TLS protects HTTP traffic, how certificates are verified and how to troubleshoot TLS connections using `openssl s_client`.

---

## What is HTTPS?

HTTPS = Hypertext Transfer Protocol Secure.

HTTPS is HTTP protected by TLS.

Typical flow:

```text
client
↓
TCP connection
↓
TLS handshake
↓
encrypted HTTP communication
↓
web server
```

HTTP commonly uses:

```text
TCP/80
```

HTTPS commonly uses:

```text
TCP/443
```

---

## HTTP vs HTTPS

HTTP:

```text
HTTP traffic
↓
TCP
↓
port 80
↓
no TLS encryption
```

HTTPS:

```text
HTTP traffic
↓
TLS encryption
↓
TCP
↓
port 443
```

The HTTP protocol still exists inside HTTPS.

TLS provides:

```text
encryption
authentication
integrity
```

---

## Basic HTTPS test

Command:

```bash
curl -I https://google.com
```

This sends an HTTPS request and returns HTTP response headers.

If the command works, it confirms that:

```text
DNS resolution works
TCP/443 is reachable
TLS negotiation succeeds
HTTP response is received
```

---

## Inspect TLS connection

Command:

```bash
openssl s_client -connect google.com:443
```

`openssl s_client` can be used to inspect a TLS connection manually.

The output includes information about:

```text
connection
TLS handshake
certificate chain
server certificate
TLS version
cipher
certificate verification
```

---

## TLS handshake

Before encrypted HTTP traffic can be exchanged, the client and server perform a TLS handshake.

Simplified flow:

```text
client
↓
TCP connection to port 443
↓
TLS ClientHello
↓
server certificate
↓
TLS parameters negotiated
↓
encrypted session established
↓
HTTPS traffic
```

The handshake allows both sides to agree on the cryptographic parameters used for the connection.

---

## Certificate chain

The `openssl s_client` output contains:

```text
Certificate chain
```

A simplified certificate chain looks like:

```text
server certificate
↓
intermediate CA
↓
root CA
```

CA = Certificate Authority.

The client verifies whether the server certificate can be linked to a trusted CA.

---

## Why certificate chains exist

A server certificate is usually not signed directly by a root CA.

Instead:

```text
root CA
↓
signs intermediate CA
↓
intermediate CA
↓
signs server certificate
```

This creates a chain of trust.

The client verifies the chain before trusting the server certificate.

---

## Inspect certificate details

Command:

```bash
openssl s_client -connect google.com:443 -servername google.com </dev/null 2>/dev/null | openssl x509 -noout -subject -issuer -dates
```

This extracts the most important information from the server certificate.

The output includes:

```text
subject
issuer
notBefore
notAfter
```

---

## Certificate subject

Example:

```text
subject=CN = *.google.com
```

`subject` identifies who the certificate belongs to.

In this example:

```text
*.google.com
```

is a wildcard certificate.

It can be used for multiple Google subdomains.

---

## Certificate issuer

Example:

```text
issuer=C = US, O = Google Trust Services, CN = WR2
```

`issuer` identifies the Certificate Authority that issued the certificate.

Simplified flow:

```text
Google server certificate
↓
issued by
↓
Google Trust Services
```

---

## Certificate validity

Certificates are only valid during a defined time period.

Important fields:

```text
notBefore
notAfter
```

`notBefore`:

```text
certificate is not valid before this date
```

`notAfter`:

```text
certificate expires after this date
```

Example troubleshooting question:

```text
Is the certificate expired?
```

Check:

```text
notAfter
```

---

## Certificate validation checklist

When troubleshooting a certificate, check:

```text
subject
issuer
notBefore
notAfter
```

Meaning:

```text
subject
↓
is this certificate for the expected hostname?

issuer
↓
who issued the certificate?

notBefore
↓
is the certificate already valid?

notAfter
↓
has the certificate expired?
```

---

## SNI

SNI = Server Name Indication.

Command:

```bash
openssl s_client -connect google.com:443 -servername google.com
```

The important option is:

```text
-servername google.com
```

This sends the hostname during the TLS handshake.

---

## Why SNI is needed

A single server IP address may host multiple HTTPS websites.

Example:

```text
same server IP
├── example.com
├── api.example.com
└── another-site.com
```

The server must know which certificate to send.

SNI provides the requested hostname.

Flow:

```text
client
↓
TLS ClientHello
↓
SNI: google.com
↓
server
↓
select certificate for google.com
```

---

## Check TLS version

Command:

```bash
openssl s_client -connect google.com:443 -servername google.com </dev/null 2>/dev/null | grep -E "Protocol|Cipher|Verify return code"
```

Example:

```text
Protocol: TLSv1.3
```

This means the connection negotiated:

```text
TLS 1.3
```

The client and server negotiate a TLS version supported by both sides.

---

## Cipher suite

Example:

```text
Cipher is TLS_AES_256_GCM_SHA384
```

The cipher suite defines cryptographic algorithms used to protect the TLS connection.

For troubleshooting purposes, the most important point is:

```text
client and server must negotiate a compatible cipher suite
```

If no compatible TLS parameters exist, the handshake can fail.

---

## Certificate verification

Example:

```text
Verify return code: 0 (ok)
```

This means certificate verification succeeded.

Important:

```text
0 (ok)
```

means that OpenSSL successfully verified the certificate chain.

---

## Failed certificate verification

If certificate verification fails, possible causes include:

```text
expired certificate
certificate not yet valid
untrusted issuer
missing intermediate certificate
invalid certificate chain
hostname mismatch
```

TLS problems can therefore exist even when TCP port 443 is reachable.

---

## TLS 1.3 test

During the lab, the default connection negotiated:

```text
TLSv1.3
```

Example cipher:

```text
TLS_AES_256_GCM_SHA384
```

Example result:

```text
Protocol: TLSv1.3
Cipher is TLS_AES_256_GCM_SHA384
Verify return code: 0 (ok)
```

This confirms:

```text
TLS handshake succeeded
TLS 1.3 is supported
cipher was successfully negotiated
certificate verification succeeded
```

---

## Force TLS 1.2

Command:

```bash
openssl s_client -connect google.com:443 -servername google.com -tls1_2
```

This forces the client to use TLS 1.2.

During the lab, the server successfully negotiated TLS 1.2.

Example:

```text
Protocol: TLSv1.2
Cipher: ECDHE-ECDSA-CHACHA20-POLY1305
Verify return code: 0 (ok)
```

---

## TLS 1.3 vs TLS 1.2

Example from the lab:

```text
TLS 1.3
Protocol: TLSv1.3
Cipher: TLS_AES_256_GCM_SHA384
```

TLS 1.2:

```text
TLS 1.2
Protocol: TLSv1.2
Cipher: ECDHE-ECDSA-CHACHA20-POLY1305
```

The server can support multiple TLS versions.

The client and server negotiate a version they both support.

---

## TLS negotiation

Simplified flow:

```text
client supports:
TLS 1.2
TLS 1.3

server supports:
TLS 1.2
TLS 1.3

↓
negotiation
↓
TLS 1.3 selected
```

If TLS 1.3 is explicitly disabled by the client:

```text
client forces TLS 1.2
↓
server supports TLS 1.2
↓
TLS 1.2 selected
```

---

## HTTPS troubleshooting layers

When HTTPS does not work, several different layers may be responsible.

Example:

```text
DNS
↓
TCP/443
↓
TLS handshake
↓
certificate verification
↓
HTTP
↓
application
```

A failure at one layer does not automatically mean another layer is broken.

---

## HTTPS troubleshooting workflow

Start with:

```bash
curl -I https://google.com
```

If it succeeds:

```text
basic HTTPS communication works
```

For TLS details:

```bash
openssl s_client -connect google.com:443 -servername google.com
```

Then inspect:

```text
certificate chain
subject
issuer
validity dates
TLS version
cipher
Verify return code
```

---

## Check certificate quickly

Command:

```bash
openssl s_client -connect google.com:443 -servername google.com </dev/null 2>/dev/null | openssl x509 -noout -subject -issuer -dates
```

This is useful when investigating:

```text
certificate expiration
wrong certificate
unexpected issuer
certificate validity period
```

---

## Check TLS negotiation quickly

Command:

```bash
openssl s_client -connect google.com:443 -servername google.com </dev/null 2>/dev/null | grep -E "Protocol|Cipher|Verify return code"
```

This quickly shows:

```text
TLS version
cipher
verification result
```

---

## Test specific TLS version

TLS 1.2:

```bash
openssl s_client -connect google.com:443 -servername google.com -tls1_2
```

This can help identify compatibility problems.

Example:

```text
TLS 1.3 works
TLS 1.2 fails
```

may indicate:

```text
server TLS policy
client compatibility issue
unsupported cipher
TLS configuration difference
```

---

## HTTP vs TLS troubleshooting

HTTP error:

```text
HTTP/1.1 404 Not Found
```

means:

```text
TCP works
TLS works
HTTP works
requested resource does not exist
```

TLS failure means the connection may fail before HTTP is even exchanged.

Flow:

```text
TCP connection
↓
TLS failure
↓
no HTTP request
```

This is an important distinction during troubleshooting.

---

## Lab files

```text
12-https/
├── README.md
└── tls-investigation.md
```

`README.md` contains the HTTPS and TLS concepts practiced during the lab.

`tls-investigation.md` contains the practical TLS investigation commands and results.

---

## Key troubleshooting commands

```bash
curl -I https://google.com

openssl s_client -connect google.com:443

openssl s_client -connect google.com:443 -servername google.com

openssl s_client -connect google.com:443 -servername google.com </dev/null 2>/dev/null | openssl x509 -noout -subject -issuer -dates

openssl s_client -connect google.com:443 -servername google.com </dev/null 2>/dev/null | grep -E "Protocol|Cipher|Verify return code"

openssl s_client -connect google.com:443 -servername google.com -tls1_2
```

---

## Key takeaways

```text
HTTPS = HTTP protected by TLS
HTTPS commonly uses TCP/443
TLS provides encryption, authentication and integrity
TLS handshake happens before HTTP communication
openssl s_client can inspect TLS connections
certificate chain creates a chain of trust
subject identifies the certificate identity
issuer identifies the Certificate Authority
notBefore shows when the certificate becomes valid
notAfter shows when the certificate expires
SNI tells the server which hostname the client wants
Protocol shows the negotiated TLS version
Cipher shows the negotiated cipher suite
Verify return code: 0 (ok) means certificate verification succeeded
servers may support multiple TLS versions
TLS problems can occur even when TCP/443 is reachable
```

Short interview answer:

```text
I use openssl s_client to troubleshoot HTTPS and TLS connections.

I check whether the TLS handshake succeeds, inspect the certificate subject,
issuer and validity dates, verify the negotiated TLS version and cipher,
and confirm that Verify return code is 0.

I also use -servername for SNI and can force a specific TLS version,
for example TLS 1.2, when investigating compatibility issues.
```
