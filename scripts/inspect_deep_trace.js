const fs = require('fs');
const readline = require('readline');

async function inspectDeep() {
  const filePath = 'Trace-20261112T090845.json';
  const rl = readline.createInterface({
    input: fs.createReadStream(filePath, { encoding: 'utf-8' }),
    crlfDelay: Infinity
  });

  const scriptsToExtract = new Set([75221, 75225, 75227, 75266, 75274, 75276]);
  const extractedScripts = {};
  const cpuNodes = [];
  const hitTestsNearClicks = [];
  const allEventNames = new Set();

  // Timestamps of key clicks (us):
  // C15: 90169222845, C16: 90170960732
  // C19: 90195815116, C20: 90197672077, C21: 90199136755
  // C27: 90244415807, C28: 90247207256, C29: 90249159349
  // C31: 90273662919, C32: 90274856903

  const windows = [
    { name: 'C15', start: 90169220000, end: 90169235000 },
    { name: 'C16', start: 90170958000, end: 90170970000 },
    { name: 'C20', start: 90197670000, end: 90197685000 },
    { name: 'C21', start: 90199134000, end: 90199150000 },
    { name: 'C28', start: 90247205000, end: 90247220000 },
    { name: 'C29', start: 90249157000, end: 90249175000 },
    { name: 'C31', start: 90273660000, end: 90273685000 },
    { name: 'C32', start: 90274854000, end: 90274870000 },
  ];

  let lineCount = 0;
  for await (const line of rl) {
    lineCount++;
    const trimmed = line.trim().replace(/^,/, '').replace(/,$/, '');
    if (!trimmed.startsWith('{') || !trimmed.endsWith('}')) continue;

    let obj;
    try {
      obj = JSON.parse(trimmed);
    } catch (e) { continue; }

    allEventNames.add(obj.name);

    if (obj.name === 'ScriptCatchup' && obj.args?.data?.sourceText && scriptsToExtract.has(obj.args.data.scriptId)) {
      extractedScripts[obj.args.data.scriptId] = obj.args.data.sourceText;
    }

    if (obj.args?.data?.cpuProfile?.nodes) {
      for (const n of obj.args.data.cpuProfile.nodes) {
        const sid = n.callFrame?.scriptId;
        if (sid == 75264 || sid == 75266 || sid == 75274 || (n.callFrame?.functionName || '').includes('Approve')) {
          cpuNodes.push({ line: lineCount, ts: obj.ts, node: n });
        }
      }
    }

    if (obj.name === 'HitTest' && obj.ts) {
      for (const w of windows) {
        if (obj.ts >= w.start - 50000 && obj.ts <= w.end) {
          hitTestsNearClicks.push({ win: w.name, line: lineCount, ts: obj.ts, endData: obj.args?.endData });
        }
      }
    }
  }

  console.log('Unique event names count:', allEventNames.size);
  console.log('Event names with error/exception/console/v8:', [...allEventNames].filter(n => /err|exc|con|v8|throw|catch|reject/i.test(n)));
  
  for (const [sid, src] of Object.entries(extractedScripts)) {
    fs.writeFileSync(`scripts/script_${sid}.js`, src);
    console.log(`Saved script_${sid}.js (len=${src.length})`);
  }

  console.log('\n=== HitTests right before/during clicks ===');
  // Deduplicate consecutive identical nodeIds per window
  const seen = new Set();
  for (const h of hitTestsNearClicks) {
    const key = `${h.win}:${h.endData?.nodeId}:${h.endData?.nodeName}`;
    if (!seen.has(key)) {
      seen.add(key);
      console.log(`[${h.win} L${h.line}] node=${h.endData?.nodeId} ${h.endData?.nodeName} (${h.endData?.x},${h.endData?.y})`);
    }
  }

  console.log('\n=== CPU Profile Nodes matching Approve / 75264 ===');
  cpuNodes.forEach(c => {
    console.log(`[L${c.line}] id=${c.node.id} parent=${c.node.parent} fn=${c.node.callFrame.functionName} line=${c.node.callFrame.lineNumber} col=${c.node.callFrame.columnNumber} sid=${c.node.callFrame.scriptId}`);
  });
}

inspectDeep().catch(console.error);
