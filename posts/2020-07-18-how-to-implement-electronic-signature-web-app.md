# How to implement digital/electronic signature functionality in a web app? (No, really, how?)

Electronic and  digital signatures are not  the same
(TODO: citations),  but listed them with  a slash as
the latter  can be  used to create  valid electronic
signatures,  for example  as the  California Digital
Signatures regulation describes.

## 1. Electronic signature laws in the United States

### 1.1 Federal laws

### 1.2 California "Digital Signatures" regulations

At the time of this writing, there is an
[emergency regulation](https://www.sos.ca.gov/administration/regulations/current-regulations/technology/emergency-digital-signatures/)
in  effect,  temporarily superseding  the  permanent
regulations; see
[the diff between the two](./posts/california-digital-signatures.diff.html).

## 2. Implementation plan without using 3rd party services

In
[our]()
case,  we   need  this  to  make   it  possible  for
volunteers to sign the online application, but there
would be applications to our visually-impaired staff
and clients as well.

1. User fills out the  form, providing personal details
   such as their

   + name
   + address
   + phone number
   + username/password for the volunteer site (or choose an alternative authentication method, e.g., passwordless auth)

2. Show intent to sign the forms (e.g., type name, click checkboxes (TODO: about what? auth us to manage keys for one)), and

3. Submit.

4. A verification process is triggered (TODO: via Web OTP perhaps?) for email and/or phone number (whichever is preferred).

5. If verification is successful, generate public and private key pairs for user.

6. Digitally (i.e., cryptographically) sign the document generated from the filled out form  with necessary metadata (TODO: PDF, markdown, or something else?)

7. Revoke the private key and public key. (TODO: Or delete private key? The purpose of the generated key pair is to prove the identity of the user, their act of signing the document, and it is only to prove this single instance of their signature. Just as a wet signature on a document is only one instance, and does not mean all of a person's signatures. The key pair's only scope is to be used for this specific digital signature, and their authority also only lives with this single document. Heavily belaboring the point, but couldn't put it in writing in a succinct way yet.)

8. Save public key and document in DB.

9. Send signed document and public key to user.

As an alternative, allow users to download the application to have them sign digitally or with wet signature. In the case of the former, verify it on upload with their public key. (TODO: cert needed? We'll verify their personal info, just as a certificate authority would, and if they are impersonating someone, well, there are laws for that too; wet signatures would have the same problem.)

Used libraries:
+ OpenSSL
+ GnuPG
+ Erlang `public_key` and `crypto` modules

Adobe is doing something similar according to their ["Certificate-based signatures"](https://helpx.adobe.com/acrobat/using/certificate-based-signatures.html) guide:

> To    sign     a    document     with    a
> certificate-based   signature,  you   must
> obtain   a   digital   ID  or   create   a
> self-signed digital ID in Acrobat or Adobe
> Reader.

In our case though, the key pair is going to be generated in the web app, and not in Acrobat (TODO: user to authorize us to do so). Adobe's "digital ID" uses certificate's as a user's signature is going to be used for signing other documents as well, hence establishing an identity and maintaining it is important.
(TODO: We only plan on having users sign this one document, and they shouldn't have to sign more in the future, but there may be exceptions. How to prepare for this? With the current method, the user will need to be verified before each signature, but to have a certificate-based signature, we would have to build out a PKI, and become a CA, in the scope of our operations at least. Does this even make sense? In Adobe's case, they are the sole authority of certificates of their users. What do they do with the private key? A certificate establishes a one-to-one relationship between the signee and the public key, which is kind of public data, but what happens with the Acrobat generated private key? Is that stored securely on the user's behalf if they would like to sign documents in the future?)
