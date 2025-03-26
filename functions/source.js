async function main(s) {
  try {
    const k = s['apiKey'];
    if (!k) throw 'Missing key';
    const r = Functions.makeHttpRequest({
      url: 'https://studio-api.cheqd.net/did/create',
      method: 'POST',
      headers: {
        accept: 'application/json',
        'x-api-key': k,
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      data: 'network=testnet&identifierFormatType=uuid&verificationMethodType=Ed25519VerificationKey2018&service=&key=&%40context=',
    });
    const res = await r;
    if (!res) throw 'Request failed';
    if (res.error) throw res.data.error || 'API error';
    const d = res.data.did;
    if (!d) throw 'No DID';
    return Functions.encodeString(d);
  } catch (e) {
    return Functions.encodeString(`Error: ${e}`);
  }
}
return main(secrets);
