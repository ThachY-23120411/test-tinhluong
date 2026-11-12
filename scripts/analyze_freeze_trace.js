const fs = require('fs');
const readline = require('readline');

function searchFile(file, regex) {
  console.log(`\n=== Matches in ${file} ===`);
  const lines = fs.readFileSync(file, 'utf8').split(/\r?\n/);
  lines.forEach((l, i) => {
    if (regex.test(l)) console.log(`  L${i + 1}: ${l.trim().slice(0, 180)}`);
  });
}

async function run() {
  const rx = /modalApproveAttendanceRequest|btnApproveModalRemake|HandleApproveAttendanceRequest|btnApprove|modal\(|appendTo|ghiChuNguoiDuyet2|select_inout|TimeInOut|extra-time-fields|sp_MakeupHours/;
  searchFile('scripts/script_75264.js', rx);
  searchFile('scripts/sp_MakeupHours_html.sql', /modalApproveAttendanceRequest|btnApproveModalRemake|HandleApproveAttendanceRequest|appendTo|btnApprove|ghiChuNguoiDuyet2|select_inout|TimeInOut|extra-time-fields/);
  searchFile('scripts/script_75221.js', /modal|tabContent|CloseTab|deleteTab|loadLiveData/);
  searchFile('scripts/script_75227.js', /openFormParam|modal|CloseTab|deleteTab|loadLiveData/);

  // Inspect trace events in key line ranges & build CPU profile node map
  const ranges = [
    ['C15-C16', 254650, 262000],
    ['C19',     312600, 315000],
    ['C20-C21', 326750, 333300],
    ['C27-C29', 376050, 391700],
    ['C31-C32', 409600, 415800],
  ];

  const cpuNodes = new Map();
  const childrenMap = new Map();
  const profileChunks = [];
  let traceStartTs = null;

  const rl = readline.createInterface({
    input: fs.createReadStream('Trace-20261112T090845.json', { encoding: 'utf8' }),
    crlfDelay: Infinity
  });

  let lineNo = 0;
  for await (const rawLine of rl) {
    lineNo++;
    const line = rawLine.trim();
    if (!line || line === '{"traceEvents":[' || line === ']}') continue;
    const clean = line.endsWith(',') ? line.slice(0, -1) : line;
    let ev;
    try { ev = JSON.parse(clean); } catch { continue; }

    if (traceStartTs === null && typeof ev.ts === 'number' && ev.ts > 0) traceStartTs = ev.ts;

    // Collect CPU profile nodes & chunks
    if (ev.name === 'ProfileChunk' && ev.args && ev.args.data && ev.args.data.cpuProfile) {
      const cp = ev.args.data.cpuProfile;
      if (Array.isArray(cp.nodes)) {
        for (const n of cp.nodes) {
          cpuNodes.set(n.id, n);
          if (n.parent !== undefined) {
            if (!childrenMap.has(n.parent)) childrenMap.set(n.parent, []);
            childrenMap.get(n.parent).push(n.id);
          }
        }
      }
      if (Array.isArray(cp.samples)) {
        profileChunks.push({
          lineNo,
          ts: ev.ts,
          samples: cp.samples,
          timeDeltas: ev.args.data.timeDeltas || []
        });
      }
    }

    // Print detailed interesting events in target line ranges
    const inRange = ranges.find(([, a, b]) => lineNo >= a && lineNo <= b);
    if (inRange) {
      const interesting = [
        'EventDispatch', 'HitTest', 'FunctionCall', 'EvaluateScript',
        'ScriptCatchup', 'ParseHTML', 'V8Console::Error', 'V8Console::Log',
        'ConsoleMessage::Error', 'ResourceSendRequest', 'ResourceReceiveResponse',
        'DOM.setOuterHTML', 'ScheduleStyleRecalculation'
      ];
      const name = ev.name || '';
      if (interesting.includes(name) || /error|exception|modal|dispatch/i.test(name)) {
        if (name === 'FunctionCall' || name === 'EvaluateScript') {
          const d = ev.args && ev.args.data ? ev.args.data : {};
          // Show all FunctionCall near C16/C21/C29/C32 clicks, or any involving 75264/75266/75274/75276
          const sid = String(d.scriptId || '');
          const nearClick =
            (lineNo >= 261250 && lineNo <= 261600) ||
            (lineNo >= 332920 && lineNo <= 333300) ||
            (lineNo >= 391290 && lineNo <= 391700) ||
            (lineNo >= 415350 && lineNo <= 415800);
          if (nearClick || ['75264', '75266', '75274', '75276', '75221', '75225', '75227'].includes(sid)) {
            console.log(`[${inRange[0]} L${lineNo}] ${name} sid=${d.scriptId} fn=${d.functionName} line=${d.lineNumber}:${d.columnNumber} url=${d.url || ''}`);
          }
        } else if (name === 'HitTest') {
          const d = ev.args && ev.args.data ? ev.args.data : {};
          console.log(`[${inRange[0]} L${lineNo}] HitTest nodeId=${d.nodeId} name="${d.nodeName}" rect=(${d.x},${d.y})`);
        } else if (name === 'EventDispatch') {
          const d = ev.args && ev.args.data ? ev.args.data : {};
          if (['click', 'mousedown', 'mouseup', 'show.bs.modal', 'shown.bs.modal', 'hide.bs.modal', 'hidden.bs.modal'].includes(d.type)) {
            console.log(`[${inRange[0]} L${lineNo}] EventDispatch type=${d.type} nodeId=${d.nodeId} sid=${d.scriptId || ''}`);
          }
        } else if (name === 'ScriptCatchup') {
          const d = ev.args && ev.args.data ? ev.args.data : {};
          const snippet = (d.sourceText || '').replace(/\s+/g, ' ').slice(0, 100);
          console.log(`[${inRange[0]} L${lineNo}] ScriptCatchup sid=${d.scriptId} len=${(d.sourceText || '').length} "${snippet}"`);
        } else if (name === 'ParseHTML') {
          const d = ev.args && ev.args.beginData ? ev.args.beginData : (ev.args && ev.args.data ? ev.args.data : {});
          const nearClick =
            (lineNo >= 261250 && lineNo <= 261600) ||
            (lineNo >= 332920 && lineNo <= 333300) ||
            (lineNo >= 391290 && lineNo <= 391700) ||
            (lineNo >= 415350 && lineNo <= 415800);
          if (nearClick) {
            console.log(`[${inRange[0]} L${lineNo}] ParseHTML lines=${d.startLine}..${d.endLine} url=${d.url || ''}`);
          }
        } else if (name === 'ResourceSendRequest') {
          const d = ev.args && ev.args.data ? ev.args.data : {};
          console.log(`[${inRange[0]} L${lineNo}] NET_SEND id=${d.requestId} ${d.requestMethod} ${d.url}`);
        } else if (name.includes('Console') || /error|exception/i.test(name)) {
          console.log(`[${inRange[0]} L${lineNo}] ${name} args=${JSON.stringify(ev.args).slice(0, 220)}`);
        }
      }
    }
  }

  // Dump subtrees of CPU profile nodes for sid 75266, 75274, 75264 HandleApproveAttendanceRequest
  function printSubtree(id, depth = 0, maxDepth = 8) {
    const n = cpuNodes.get(id);
    if (!n) return;
    const cf = n.callFrame || {};
    console.log(`${'  '.repeat(depth)}node ${id}: fn="${cf.functionName}" sid=${cf.scriptId} L${cf.lineNumber}:${cf.columnNumber}`);
    if (depth >= maxDepth) return;
    const kids = childrenMap.get(id) || [];
    for (const k of kids.slice(0, 30)) printSubtree(k, depth + 1, maxDepth);
    if (kids.length > 30) console.log(`${'  '.repeat(depth + 1)}... (${kids.length - 30} more children)`);
  }

  console.log('\n=== CPU Subtree for node 16132 (sid=75266) ===');
  printSubtree(16132, 0, 5);
  console.log('\n=== CPU Subtree for node 17999 (sid=75274) ===');
  printSubtree(17999, 0, 6);

  // Also print ALL nodes referencing sid 75266 or 75274 or 75276 or line 1133..1150 of 75264
  console.log('\n=== All CPU nodes with sid 75266, 75274, 75276, or 75264 lines 970..1155 ===');
  for (const [id, n] of cpuNodes.entries()) {
    const cf = n.callFrame || {};
    const sid = String(cf.scriptId || '');
    if (['75266', '75274', '75276'].includes(sid) || (sid === '75264' && cf.lineNumber >= 970 && cf.lineNumber <= 1155)) {
      console.log(`  node ${id} parent=${n.parent} fn="${cf.functionName}" sid=${sid} L${cf.lineNumber}:${cf.columnNumber}`);
    }
  }
}

run().catch(e => { console.error(e); process.exit(1); });
