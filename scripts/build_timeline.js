const fs = require('fs');
const readline = require('readline');

async function buildTimeline() {
  const filePath = 'Trace-20261112T090845.json';
  const rl = readline.createInterface({
    input: fs.createReadStream(filePath, { encoding: 'utf-8' }),
    crlfDelay: Infinity
  });

  const timeline = [];
  const reqMap = new Map();
  let lastHitTest = null;
  let lineCount = 0;

  for await (const line of rl) {
    lineCount++;
    const trimmed = line.trim().replace(/^,/, '').replace(/,$/, '');
    if (!trimmed.startsWith('{') || !trimmed.endsWith('}')) continue;

    let obj;
    try {
      obj = JSON.parse(trimmed);
    } catch (e) {
      continue;
    }

    if (obj.name === 'HitTest' && obj.args?.endData?.nodeName) {
      lastHitTest = {
        ts: obj.ts,
        nodeName: obj.args.endData.nodeName,
        x: obj.args.endData.x,
        y: obj.args.endData.y
      };
    }

    if (obj.name === 'EventDispatch' && obj.args?.data?.type === 'click') {
      timeline.push({
        type: 'CLICK',
        ts: obj.ts,
        line: lineCount,
        dur: obj.dur,
        hitTarget: lastHitTest ? `${lastHitTest.nodeName} (${lastHitTest.x},${lastHitTest.y})` : 'unknown'
      });
    }

    if (obj.name === 'ResourceSendRequest') {
      const url = obj.args?.data?.url || '';
      if (url.includes('paradise2') || url.includes('.ashx') || url.includes('Tai3')) {
        const stack = (obj.args?.data?.stackTrace || []).slice(0, 5).map(s => `${s.functionName || 'anon'}@${s.lineNumber}(${s.scriptId})`).join(' <- ');
        const entry = {
          type: 'NET_REQ',
          ts: obj.ts,
          line: lineCount,
          requestId: obj.args?.data?.requestId,
          method: obj.args?.data?.requestMethod,
          url,
          stack
        };
        reqMap.set(entry.requestId, entry);
        timeline.push(entry);
      }
    }

    if (obj.name === 'ResourceReceiveResponse') {
      const reqId = obj.args?.data?.requestId;
      if (reqMap.has(reqId)) {
        const req = reqMap.get(reqId);
        req.statusCode = obj.args?.data?.statusCode;
        req.mimeType = obj.args?.data?.mimeType;
        req.resLine = lineCount;
      }
    }

    if (obj.name === 'ResourceFinish') {
      const reqId = obj.args?.data?.requestId;
      if (reqMap.has(reqId)) {
        const req = reqMap.get(reqId);
        req.decodedBodyLength = obj.args?.data?.decodedBodyLength;
        req.didFail = obj.args?.data?.didFail;
        req.finTs = obj.ts;
      }
    }

    if (obj.name === 'ScriptCatchup' && obj.args?.data?.sourceText) {
      const src = obj.args.data.sourceText;
      if (src.length < 300 && !src.includes('webpack')) {
        timeline.push({
          type: 'EVAL_SNIPPET',
          ts: obj.ts,
          line: lineCount,
          scriptId: obj.args.data.scriptId,
          sourceText: src
        });
      }
    }

    if (obj.name && (obj.name.includes('Console') || obj.name.includes('Exception') || obj.name.includes('Error'))) {
      timeline.push({
        type: 'ERR_OR_CONSOLE',
        ts: obj.ts,
        line: lineCount,
        name: obj.name,
        args: JSON.stringify(obj.args).substring(0, 300)
      });
    }
  }

  timeline.sort((a, b) => (a.ts || 0) - (b.ts || 0));
  const t0 = timeline[0]?.ts || 0;

  const outLines = timeline.map(item => {
    const relSec = ((item.ts - t0) / 1e6).toFixed(3);
    if (item.type === 'CLICK') {
      return `[+${relSec}s] [Line ${item.line}] CLICK on: ${item.hitTarget} (dur=${item.dur}us)`;
    } else if (item.type === 'NET_REQ') {
      if (!item.url.includes('paradise2')) return null; // focus on paradise2 API calls
      return `[+${relSec}s] [Line ${item.line}] API ${item.method} ${item.url} | reqId=${item.requestId} | status=${item.statusCode} | len=${item.decodedBodyLength} | fail=${item.didFail} | stack=${item.stack}`;
    } else if (item.type === 'EVAL_SNIPPET') {
      return `[+${relSec}s] [Line ${item.line}] INLINE_EXEC (${item.scriptId}): ${item.sourceText.replace(/\n/g, ' ')}`;
    } else if (item.type === 'ERR_OR_CONSOLE') {
      return `[+${relSec}s] [Line ${item.line}] ${item.name}: ${item.args}`;
    }
  }).filter(Boolean);

  fs.writeFileSync('scripts/timeline.txt', outLines.join('\n'));
  console.log('Total timeline items written:', outLines.length);
}

buildTimeline().catch(console.error);
