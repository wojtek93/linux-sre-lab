# TLS Investigation

## Goal

Inspect a remote HTTPS service using OpenSSL and verify:

- TLS connectivity
- certificate subject
- certificate issuer
- certificate validity dates
- negotiated TLS version
- cipher suite
- certificate verification result

---

## Basic HTTPS test

```bash
curl -I https://google.com
```

This confirms that the remote HTTPS service is reachable and returns an HTTP response over TLS.

Typical HTTPS port:

```text
TCP/443
```

---

## Inspect TLS connection

```bash
openssl s_client -connect google.com:443
```

This displays detailed TLS information, including:

```text
TLS handshake
certificate chain
server certificate
TLS version
cipher suite
verification result
```

---

## Certificate chain

The output contains:

```text
Certificate chain
```

A simplified chain looks like:

```text
server certificate
↓
intermediate CA
↓
root CA
```

The certificate chain allows the client to verify whether the server certificate was issued by a trusted Certificate Authority.

---

## Inspect certificate details

Command:

```bash
openssl s_client -connect google.com:443 -servername google.com </dev/null 2>/dev/null | openssl x509 -noout -subject -issuer -dates
```

Important fields:

```text
subject
issuer
notBefore
notAfter
```

Meaning:

```text
subject   = identity the certificate belongs to
issuer    = Certificate Authority that issued it
notBefore = certificate validity start
notAfter  = certificate expiration date
```

Example from the lab:

```text
subject=CN = *.google.com
issuer=C = US, O = Google Trust Services, CN = WR2
```

---

## SNI

The command uses:

```bash
-servername google.com
```

This sends the hostname using SNI.

SNI = Server Name Indication.

It allows a server hosting multiple HTTPS sites on the same IP address to know which certificate should be presented.

Flow:

```text
client
↓
TLS ClientHello
↓
SNI: google.com
↓
server selects correct certificate
```

---

## Check TLS version and cipher

Command:

```bash
openssl s_client -connect google.com:443 -servername google.com </dev/null 2>/dev/null | grep -E "Protocol|Cipher|Verify return code"
```

Example result:

```text
Protocol: TLSv1.3
Cipher is TLS_AES_256_GCM_SHA384
Verify return code: 0 (ok)
```

Meaning:

```text
Protocol = negotiated TLS version
Cipher   = negotiated cipher suite
Verify return code = certificate verification result
```

---

## Certificate verification

Example:

```text
Verify return code: 0 (ok)
```

This means that certificate verification succeeded.

If verification fails, possible causes may include:

```text
expired certificate
untrusted issuer
incomplete certificate chain
hostname mismatch
invalid certificate
```

---

## TLS 1.3 test

Default negotiation selected:

```text
TLSv1.3
```

Example cipher:

```text
TLS_AES_256_GCM_SHA384
```

This confirms that the server supports TLS 1.3.

---

## Force TLS 1.2

Command:

```bash
openssl s_client -connect google.com:443 -servername google.com -tls1_2
```

Example result from the lab:

```text
Protocol: TLSv1.2
Cipher: ECDHE-ECDSA-CHACHA20-POLY1305
Verify return code: 0 (ok)
```

This confirms that the server also supports TLS 1.2.

---

## TLS 1.3 vs TLS 1.2

Example from the lab:

```text
TLS 1.3
Protocol: TLSv1.3
Cipher: TLS_AES_256_GCM_SHA384
```

```text
TLS 1.2
Protocol: TLSv1.2
Cipher: ECDHE-ECDSA-CHACHA20-POLY1305
```

The client and server negotiate a TLS version and cipher suite that both sides support.

---

## HTTPS troubleshooting workflow

Typical investigation:

```text
HTTPS problem
↓
check TCP/443
↓
test with curl
↓
inspect TLS handshake
↓
inspect certificate
↓
check issuer
↓
check validity dates
↓
check TLS version
↓
check cipher
↓
check verification result
```

Useful commands:

```bash
curl -I https://google.com
openssl s_client -connect google.com:443 -servername google.com
openssl s_client -connect google.com:443 -servername google.com </dev/null 2>/dev/null | openssl x509 -noout -subject -issuer -dates
openssl s_client -connect google.com:443 -servername google.com </dev/null 2>/dev/null | grep -E "Protocol|Cipher|Verify return code"
openssl s_client -connect google.com:443 -servername google.com -tls1_2
```

---

## Key takeaways

```text
HTTPS = HTTP over TLS
HTTPS commonly uses TCP/443
openssl s_client can inspect TLS handshakes
subject = certificate identity
issuer = certificate authority
notBefore = validity start
notAfter = expiration date
SNI selects the correct certificate for a hostname
Protocol shows the negotiated TLS version
Cipher shows the negotiated cipher suite
Verify return code: 0 (ok) means successful certificate verification
servers may support multiple TLS versions
```
