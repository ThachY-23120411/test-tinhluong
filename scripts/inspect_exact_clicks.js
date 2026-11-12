const fs = require('fs');
const readline = require('readline');

async function run() {
  const rl = readline.createInterface({
    input: fs.createReadStream('Trace-20261112T090845.json', { encoding: 'utf8' }),
    crlfDelay: Infinity
  });

  const nodes = new Map();
  const sampleChunks = [];
  const targetHitLines = [
    254666, 261257, 326777, 332926, 376068, 384408, 391304, 391350, 400818, 409642, 415359, 417086
  ];
  const interestingRange = (l) => (
    (l >= 254650 && l <= 254900) ||
    (l >= 261240 && l <= 261420) ||
    (l >= 312600 && l <= 313700) ||
    (l >= 326750 && l <= 327000) ||
    (l >= 332910 && l <= 333100) ||
    (l >= 376050 && l <= 376250) ||
    (l >= 384390 && l <= 384600) ||
    (l >= 391280 && l <= 391500) ||
    (l >= 400800 && l <= 401000) ||
    (l >= 409620 && l <= 409900) ||
    (l >= 415340 && l <= 415550)
  );

  let lineNo = 0;
  let startTs = null;
  for await (const rawLine of rl) {
    lineNo++;
    const line = rawLine.trim();
    if (!line || line === '{"traceEvents":[' || line === ']}') continue;
    const clean = line.endsWith(',') ? line.slice(0, -1) : line;
    let ev;
    try { ev = JSON.parse(clean); } catch { continue; }
    if (startTs === null && typeof ev.ts === 'number' && ev.ts > 0) startTs = ev.ts;
    const rel = typeof ev.ts === 'number' ? ((ev.ts - startTs) / 1e6).toFixed(3) : '?';

    if (interestingRange(lineNo)) {
      if (['HitTest', 'EventDispatch', 'FunctionCall', 'ScriptCatchup', 'ParseHTML', 'V8Console::Log', 'V8Console::Error', 'EvaluateScript'].includes(ev.name)) {
        console.log(`[L${lineNo} +${rel}s] ${ev.name} ${JSON.stringify(ev.args)}`);
      }
    }

    if (ev.name === 'ProfileChunk' && ev.args?.data?.cpuProfile) {
      const cp = ev.args.data.cpuProfile;
      if (Array.isArray(cp.nodes)) {
        for (const n of cp.nodes) nodes.set(n.id, n);
      }
      if (Array.isArray(cp.samples)) {
        sampleChunks.push({ lineNo, ts: ev.ts, rel, samples: cp.samples, timeDeltas: ev.args.data.timeDeltas || [] });
      }
    }
  }

  console.log('\n=== Checking all samples that hit 75264/75266/75274/75276/75280 ===');
  for (const ch of sampleChunks) {
    let t = ch.ts;
    for (let i = 0; i < ch.samples.length; i++) {
      t += (ch.timeDeltas[i] || 0);
      const sid = ch.samples[i];
      let cur = nodes.get(sid);
      const chain = [];
      let match = false;
      let d = 0;
      while (cur && d++ < 20) {
        const f = cur.callFrame || {};
        const sc = String(f.scriptId || '');
        if (['75264', '75266', '75274', '75276', '75280', '75247', '75249'].includes(sc)) match = true;
        chain.push(`${f.functionName || '(anon)'}@${sc}:${f.lineNumber}`);
        cur = cur.parent ? nodes.get(cur.parent) : null;
      }
      if (match) {
        const sampleRel = ((t - startTs) / 1e6).toFixed(4);
        console.log(`[Sample +${sampleRel}s node=${sid}] ${chain.join(' <= ')}`);
      }
    }
  }
}

run().catch(e => { console.error(e); process.exit(1); });
