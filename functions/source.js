// This source code has been written to be as compact as possible since it is stored in the bytecode of DIDRequestManager
async function main(a, s) {
  try {
    let d = a[0];
    if (!d) throw 'M';
    let k = s.apiKey;
    if (!k) throw 'K';
    let r = await Functions.makeHttpRequest({
      url: `https://studio-api.cheqd.net/did/search/${d}`,
      method: 'GET',
      headers: { accept: 'application/json', 'x-api-key': k },
    });
    if (r.error) throw r.data.error || 'E';
    let p = r.data.didDocument.verificationMethod[0].publicKeyBase58;
    if (!p) throw 'P';
    return Functions.encodeString(p);
  } catch (e) {
    return Functions.encodeString(`E:${e}`);
  }
}
return main(args, secrets);
