const fs = require('fs');
const readline = require('readline');

async function run() {
  const rl = readline.createInterface({
    input: fs.createReadStream('Trace-20261112T090845.json', { encoding: 'utf8' }),
    crlfDelay: Infinity
  });

  let lineNo = 0;
  let startTs = null;
  const cpuNodes = new Map();
  const hitTests = [];
  const clicks = [];

  for await (const rawLine of rl) {
    lineNo++;
    const line = rawLine.trim();
    if (!line || line === '{"traceEvents":[' || line === ']}') continue;
    const clean = line.endsWith(',') ? line.slice(0, -1) : line;
    let ev;
    try { ev = JSON.parse(clean); } catch { continue; }
    if (startTs === null && typeof ev.ts === 'number' && ev.ts > 0) startTs = ev.ts;
    const rel = typeof ev.ts === 'number' ? ((ev.ts - startTs) / 1e6).toFixed(3) : '?';

    if (ev.name === 'ProfileChunk' && ev.args?.data?.cpuProfile) {
      const cp = ev.args.data.cpuProfile;
      if (Array.isArray(cp.nodes)) {
        for (const n of cp.nodes) cpuNodes.set(n.id, n);
      }
      if (Array.isArray(cp.samples)) {
        // Check if any sample is in handle approve/reject/modal/75264/75266/75274/75276
        const special = cp.samples.filter(sid => {
          let cur = cpuNodes.get(sid);
          let depth = 0;
          while (cur && depth++ < 15) {
            const f = cur.callFrame || {};
            if (['75264', '75266', '75274', '75276'].includes(String(f.scriptId))) {
              if (f.lineNumber >= 970 && f.lineNumber <= 1200) return true;
              if (['75266', '75274', '75276'].includes(String(f.scriptId))) return true;
            }
            cur = cur.parent ? cpuNodes.get(cur.parent) : null;
          }
          return false;
        });
        if (special.length > 0) {
          const stacks = [...new Set(special)].map(sampleId => {
            const parts = [];
            let cur = cpuNodes.get(sampleId);
            let d = 0;
            while (cur && d++ < 10) {
              const f = cur.callFrame || {};
              parts.push(`${f.functionName || '(anon)'}@${f.scriptId}:${f.lineNumber}`);
              cur = cur.parent ? cpuNodes.get(cur.parent) : null;
            }
            return parts.join(' <- ');
          });
          console.log(`[CPU +${rel}s L${lineNo}] ${stacks.join(' | ')}`);
        }
      }
    }

    if (ev.name === 'ScriptCatchup' && ev.args?.data) {
      const d = ev.args.data;
      if (d.sourceText && Number(d.scriptId) >= 75200) {
        const preview = d.sourceText.replace(/\s+/g, ' ').slice(0, 120);
        console.log(`[CATCHUP +${rel}s L${lineNo}] sid=${d.scriptId} len=${d.sourceText.length} "${preview}"`);
      }
    }

    if (ev.name === 'ResourceSendRequest' && ev.args?.data) {
      const d = ev.args.data;
      if (d.url && d.url.includes('paradise')) {
        console.log(`[NET +${rel}s L${lineNo}] ${d.requestMethod} ${d.url.slice(0, 140)} id=${d.requestId}`);
      }
    }

    if (ev.name === 'HitTest' && ev.args && lineNo >= 240000 && lineNo <= 420000) {
      const d = ev.args.endData || ev.args.data || ev.args;
      const nName = d.nodeName || '';
      if (nName.includes('btn') || nName.includes('Approve') || nName.includes('Remake') || nName.includes('modal') || nName.includes('BUTTON') || nName === '#text') {
        const last = hitTests[hitTests.length - 1];
        if (!last || last.nodeId !== d.nodeId || lineNo - last.lineNo > 30) {
          hitTests.push({ rel, lineNo, nodeId: d.nodeId, nodeName: nName, x: d.x, y: d.y });
        }
      }
    }

    if (ev.name === 'EventDispatch' && ev.args?.data?.type === 'click') {
      console.log(`[CLICK +${rel}s L${lineNo}] args=${JSON.stringify(ev.args.data)}`);
    }

    if (ev.name && (ev.name.includes('Console') || ev.name.includes('Exception')) && lineNo >= 240000) {
      console.log(`[LOG +${rel}s L${lineNo}] ${ev.name} ${JSON.stringify(ev.args).slice(0, 200)}`);
    }
  }

  console.log('\n=== Relevant HitTests ===');
  for (const h of hitTests) {
    console.log(`[+${h.rel}s L${h.lineNo}] nodeId=${h.nodeId} (${h.x},${h.y}) ${h.nodeName}`);
  }
}

run().catch(e => { console.error(e); process.exit(1); });
